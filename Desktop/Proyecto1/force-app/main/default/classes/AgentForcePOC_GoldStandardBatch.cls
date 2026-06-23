/**
 * Batch: Generates "Gold Standard" knowledge articles from curated Opportunity sets in MDT.
 * - Reads AgentForcePOC_Gold_Standard__mdt rows
 * - Builds JSON payload from Opportunities ( related activities/meetings)
 * - Calls Prompt Builder template 'AgentForcePOC_Gold_Standard_Generation'
 * - Upserts Knowledge__kav (Procedure RT), optional category assignment
 * - Sends finish-time email notifications to addresses in Notified_Username__c (MDT)
 */
public with sharing class AgentForcePOC_GoldStandardBatch
    implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts
{
    // ---------------------------
    // Config
    // ---------------------------
    private static final Integer PAYLOAD_MAX = 120000;
    private static final String PROMPT_TEMPLATE_API_NAME = 'AgentForcePOC_Gold_Standard_Generation';
    private static final String KNOWLEDGE_LANG = 'en_US';
    private static final String KNOWLEDGE_TITLE_PREFIX = 'Gold Standard ';
    private static final String CATEGORY_GROUP = 'AgentForcePoc_Gold_Standard';
    private static final String CATEGORY_NAME = 'All';

    private List<String> errors = new List<String>();
    private List<String> notifiedUserEmails = new List<String>();

    List<AgentForcePOC_Gold_Standard__mdt> goldStandardToProcess;

    // Track (article + country + notify email) for finish-time email (kept as-is; not used by finish)
    private class ArticleNotification {
        Knowledge__kav article;
        String country;
        String notifyEmailCsv;
        ArticleNotification(Knowledge__kav a, String c, String e) {
            article = a; country = c; notifyEmailCsv = e;
        }
    }
    private List<ArticleNotification> toEmail = new List<ArticleNotification>();

    public AgentForcePOC_GoldStandardBatch withGoldStandardToProcess(List<AgentForcePOC_Gold_Standard__mdt> goldStandardToProcess) {
        this.goldStandardToProcess = goldStandardToProcess;
        return this;
    }

    // ---------------------------
    // START
    // ---------------------------
    public Iterable<SObject> start(Database.BatchableContext bc) {
        if(this.goldStandardToProcess != null && !this.goldStandardToProcess.isEmpty()) {
            return this.goldStandardToProcess;
        }
        return [
            SELECT Country__c, OpportunityIds__c, Notified_Username__c
            FROM AgentForcePOC_Gold_Standard__mdt
        ];
    }

    // ---------------------------
    // EXECUTE
    // ---------------------------
    public void execute(Database.BatchableContext bc, List<AgentForcePOC_Gold_Standard__mdt> scope) {
        List<String> lstUserEmails = new List<String>();
        Map<String, String> mapRecipientIdByEmail = new Map<String, String>();
        List<User> lstUsers;
        for (AgentForcePOC_Gold_Standard__mdt mdtRecord : scope) {
            lstUserEmails.add(mdtRecord.Notified_Username__c);
        }
        if(!lstUserEmails.isEmpty()) {
            lstUsers = [SELECT Id, Email FROM USER WHERE Email IN :lstUserEmails];
        }

        if(lstUsers != null && !lstUsers.isEmpty()) {
            for(User u : lstUsers) {
                mapRecipientIdByEmail.put(u.Email, u.Id);
            }
        }
        
        for (AgentForcePOC_Gold_Standard__mdt row : scope) {
            try {
                final String country = String.isBlank(row.Country__c) ? 'General' : row.Country__c.trim();

                // 1) Parse & validate Opp Ids
                Set<Id> oppIds = parseOppIds(row.OpportunityIds__c);
                if (oppIds.isEmpty()) continue;

                // 2) Query Opportunities + relations
                List<Opportunity> opps = queryOpportunities(oppIds);
                if (opps.isEmpty()) continue;

                // 3) Build JSON payload
                String payload = buildPayload(opps);

                // 4) Call Prompt Builder template
                String steps = runPromptTemplate(country, payload);

                // 5) Upsert Knowledge (Procedure)
                String userEmail;
                if(row.Notified_Username__c != null) {
                    userEmail = row.Notified_Username__c.trim();
                }  
                Knowledge__kav article = upsertKnowledgeArticle(country, steps, mapRecipientIdByEmail.get(userEmail));
                if (String.isNotBlank(userEmail)) {
                    notifiedUserEmails.add(userEmail);
                }

                // 6) Assign Category
                assignCategorySafe(article);

                // Track for finish() email (kept)
                toEmail.add(new ArticleNotification(article, country, row.Notified_Username__c));

            } catch (Exception e) {
                errors.add('Row error - MDT Id: ' + row.Id + ' -> ' + e.getMessage());
            }
        }
    }

    // ---------------------------
    // FINISH
    // ---------------------------
    public void finish(Database.BatchableContext bc) {
        System.debug('AgentForcePOC_GoldStandardBatch finished. Errors: ' + errors.size());
        for (String err : errors) System.debug('error here ' + err);

        // Build a clean recipient list from all MDT rows: split, trim, dedupe, basic validate
        Set<String> recipients = new Set<String>();
        for (String raw : notifiedUserEmails) {
            if (String.isBlank(raw)) continue;
            for (String token : raw.split('[,;\\s]+')) {
                String t = token == null ? null : token.trim();
                if (String.isNotBlank(t) && t.contains('@')) {
                    recipients.add(t);
                }
            }
        }

        if (!recipients.isEmpty()) {
            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>(recipients));
                mail.setSubject('Gold Standard Knowledge Article Update');
                mail.setPlainTextBody('One or more Gold Standard Knowledge Articles were created or updated successfully.');
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('Notification email sent to: ' + recipients);
            } catch (Exception e) {
                System.debug('Failed to send notification email: ' + e.getMessage());
            }
        }
    }

    // ===========================
    // Helpers
    // ===========================
    private static Set<Id> parseOppIds(String raw) {
        Set<Id> result = new Set<Id>();
        if (String.isBlank(raw)) return result;

        for (String token : raw.split('[,\\n\\r]+')) {
            String t = token == null ? null : token.trim();
            if (String.isNotBlank(t)) {
                try {
                    result.add(Id.valueOf(t));
                } catch (Exception ex) {
                    System.debug('Skipped invalid Id: ' + t);
                }
            }
        }
        return result;
    }

    private static List<Opportunity> queryOpportunities(Set<Id> oppIds) {
        return [
            SELECT Id, Name, Amount, CloseDate, IsClosed, IsWon, LostReason__c,
                   CreatedDate, LastModifiedDate, LastActivityDate, LastStageChangeDate,
                   Account.Name, Account.Country__c,
                   PrimaryProduct__r.Name, PrimaryProduct__r.Combined_Hiearchy__c,
                   (SELECT Name, TeamMemberRole FROM OpportunityTeamMembers ORDER BY CreatedDate DESC LIMIT 10),
                   (SELECT Id, Subject, Description, Status, Priority, CreatedDate, LastModifiedDate
                      FROM Tasks ORDER BY CreatedDate DESC LIMIT 10),
                   (SELECT Id, Subject, StartDateTime, EndDateTime, CreatedDate, LastModifiedDate
                      FROM Events ORDER BY StartDateTime DESC LIMIT 5),
                   (SELECT Id, Name, Meeting_Objective__c, Meeting_Notes__c, Meeting_Preparation__c,
                           Meeting_Type__c, Virtual_Meeting__c, CreatedDate, LastModifiedDate
                      FROM Meetings__r ORDER BY CreatedDate DESC LIMIT 5)
            FROM Opportunity
            WHERE Id IN :oppIds
        ];
    }

    private static String buildPayload(List<Opportunity> opps) {
        String payload;
        try {
            payload = AgentForcePOC_JsonSummarizer.summarizeToJson(opps);
        } catch (Exception e) {
            payload = JSON.serialize(opps, false);
        }
        if (payload != null && payload.length() > PAYLOAD_MAX) {
            payload = payload.left(PAYLOAD_MAX);
        }
        return payload;
    }

    // Call Prompt Builder and return only the generated output (text or structured JSON)
    private static String runPromptTemplate(String country, String payload) {
        if (String.isBlank(payload)) return 'No input JSON provided.';

        ConnectApi.WrappedValue inputVal = new ConnectApi.WrappedValue();
        inputVal.value = payload;

        ConnectApi.EinsteinPromptTemplateGenerationsInput req =
            new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        req.inputParams = new Map<String, ConnectApi.WrappedValue>{
            'Input:JSON_Data_Input' => inputVal
        };
        req.isPreview = false;

        req.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        req.additionalConfig.applicationName = 'PromptBuilderPreview';

        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation res =
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(PROMPT_TEMPLATE_API_NAME, req);

        if (res == null || res.generations == null || res.generations.isEmpty()) {
            return 'No generations returned.';
        }
        ConnectApi.EinsteinLLMGenerationItemOutput gen = res.generations[0];

        if (gen.structuredResponse != null) {
            return JSON.serialize(gen.structuredResponse, false);
        }
        return String.isBlank(gen.text) ? 'Empty generation.' : gen.text;
    }

    private Knowledge__kav upsertKnowledgeArticle(String country, String steps, String recipientId) {
        String title = KNOWLEDGE_TITLE_PREFIX + country;
        String urlName = (KNOWLEDGE_TITLE_PREFIX.trim() + country).replace(' ', '-');

        Knowledge__kav article;
        try {
            article = [
                SELECT Id, PublishStatus, Procedure_Steps__c, KnowledgeArticleId
                FROM Knowledge__kav
                WHERE Title = :title
                  AND Language = :KNOWLEDGE_LANG
                LIMIT 1
            ];
        } catch (QueryException e) {
            article = null;
        }

        Knowledge__kav notificationArticle;

        if (article == null) {
            article = new Knowledge__kav(
                Title = title,
                UrlName = urlName,
                Language = KNOWLEDGE_LANG,
                RecordTypeId = fetchProcedureRecordType(),
                Procedure_Steps__c = steps
            );
            insert article;
            notificationArticle = article;
        } else {
            String draftArticleId = KbManagement.PublishingService.editOnlineArticle (article.KnowledgeArticleId, false);
            Knowledge__kav draftArticle = [SELECT Id FROM Knowledge__kav WHERE Id = :draftArticleId];
            draftArticle.Procedure_Steps__c = steps;
            update draftArticle;
            notificationArticle = draftArticle;
        }
        if(String.isNotBlank(recipientId) && String.isNotBlank(notificationArticle.Id)) {
            invokeGoldStandardFlow(notificationArticle.Id, recipientId);
        }
        return notificationArticle;
    }

    private void assignCategorySafe(Knowledge__kav article) {
        try {
            insert new Knowledge__DataCategorySelection(
                ParentId = article.Id,
                DataCategoryGroupName = CATEGORY_GROUP,
                DataCategoryName = CATEGORY_NAME
            );
        } catch (Exception e) {
            System.debug('Category assign skipped: ' + e.getMessage());
        }
    }

    private static Id fetchProcedureRecordType() {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Knowledge__kav'
              AND DeveloperName = 'Procedure'
            LIMIT 1
        ];
        return rt != null ? rt.Id : null;
    }
    
    private static void invokeGoldStandardFlow(String notificationTargetId, Id recipientUserId) {
    // Inputs must match the Flow variable API names and types
    Map<String, Object> flowInputs = new Map<String, Object>{
        'NotificationTargetId' => notificationTargetId,
        'NotificationRecipientsIdsInput' => (recipientUserId == null ? null : String.valueOf(recipientUserId))
    };
 
    // Start the autolaunched flow (must be Active)
    Flow.Interview.AgentForcePOC_Gold_Standard_Generation fl =
        new Flow.Interview.AgentForcePOC_Gold_Standard_Generation(flowInputs);
    fl.start();
}
}