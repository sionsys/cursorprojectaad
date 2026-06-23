public with sharing class QuoteDocumentService {

    public static final String CONNECTED_APP_NAMED_CREDENTIAL = 'callout:CPQ_Integration';
    public static final String ENDPOINT = '/services/apexrest/QuoteDocument';

    public class GenerateQuoteDocRequest {
        @InvocableVariable(required=true)
        public Id quoteId;
        @InvocableVariable(required=true)
        public Conga_Template_Mapping__mdt congaTemplate;
        @InvocableVariable
        public Boolean sendEmailAutomatically; // default in flow is true
        @InvocableVariable 
        public String userSelectedEmailAddresses; // JSON format with corresponding class: List<QuoteDocEmailRecipientsController.EmailRecipient>
        public Id salesforceUserId; // user who triggered quote document generation
    }

    /**
    * Call to Salesforce connected app REST API (custom REST endpoint) to run conga as cpq@ossur.com (otherwise each user would need licenses)
     */
    @InvocableMethod(label='Generate Quote Document' description='Uses Conga Composer to generate Quote Document' callout=true category='SBQQ__Quote__c')
    public static List<Id> generateQuoteDocumentFromREST(List<GenerateQuoteDocRequest> inputParameters){
        String connectedAppUrl = CONNECTED_APP_NAMED_CREDENTIAL + ENDPOINT;
        for (GenerateQuoteDocRequest param : inputParameters) {
            param.salesforceUserId = UserInfo.getUserId(); // set user who triggered quote document generation
        }        
        String connectedAppRequestBody = JSON.serialize(inputParameters);
        HTTPResponse response = new HttpCalloutService(connectedAppUrl).post(connectedAppRequestBody);
        QuoteDocumentRestEndpoint.QuoteDocServiceResponse responseDeserialized = 
            (QuoteDocumentRestEndpoint.QuoteDocServiceResponse) JSON.deserialize(response.getBody(), QuoteDocumentRestEndpoint.QuoteDocServiceResponse.class);
        return responseDeserialized.enqueuedJobsIds;
        
    }

    public static List<Id> generateQuoteDocument(List<GenerateQuoteDocRequest> inputParameters) {
        List<Id> asyncApexJobIdList = new List<Id>();
        for (GenerateQuoteDocRequest inputParam: inputParameters){
            Id quoteId = inputParam.quoteId;
            Conga_Template_Mapping__mdt congaTemplate = inputParam.congaTemplate;
            Id salesforceUserId = inputParam.salesforceUserId;
            Boolean sendEmailAutomatically = inputParam.sendEmailAutomatically;
            String emailRecipientsJson = inputParam.userSelectedEmailAddresses;
            Id jobId = enqueueGenerateQuoteDoc(quoteId, congaTemplate, salesforceUserId, sendEmailAutomatically, emailRecipientsJson);
            asyncApexJobIdList.add(jobId);
        }
        return asyncApexJobIdList;
    }

    public static Id enqueueGenerateQuoteDoc(Id quoteId, Conga_Template_Mapping__mdt congaTemplate, Id salesforceUserId, Boolean sendEmailAutomatically, String emailRecipientsJson) {
        Id asyncApexJobId;
        try {
            // SBQQ__Quote__c thisQuote = [SELECT Id, Name, SBQQ__PrimaryContact__r.Email FROM SBQQ__Quote__c WHERE Id = :quoteId];
            QD_QuoteSelector quoteSelector = QD_QuoteSelector.newInstance();
            SBQQ__Quote__c thisQuote = quoteSelector.selectOneById(quoteId);
            
            Integer nextDocVersionNumber = getNextQuoteDocVersionNumber(quoteId);

            String quoteDocumentFileName = String.format(
                '{0}-{1}',
                new List<String> {
                    thisQuote.Name,
                    String.valueOf(nextDocVersionNumber)
                }
            );
            Map<String, String> congaParams = new Map<String, String> {
                'APIMode' => '1',
                'OFN' => quoteDocumentFileName, // file name
                'TemplateId' => congaTemplate.Conga_Template_Key__c, // Conga Template Key
                'TPV' => '1', // translate labels defined in SF translation workbench
                'DefaultPDF' => '1', // generate document as adobe pdf
                'solmgr' => '1', // solution works without this parameter, but I need to figure out what it is used for
                'SC0' => '1', // enable audit
                'SC1' => 'SalesforceFile', // audit field - save generated document in salesforce as File
                'QueryId' => '[QuoteData]0Q_0222A0868294,[SkuQL]0Q_0112AU522712,[GOQL]0Q_025MAN265057'
            };
            update new SBQQ__Quote__c(Id=quoteId, SBQQ__DocumentStatus__c = 'Pending');
            asyncApexJobId = System.enqueueJob(new QuoteDocumentQueueable(quoteId, congaParams, salesforceUserId, sendEmailAutomatically, emailRecipientsJson, congaTemplate.Language__c));
        } catch (Exception e) {
            update new SBQQ__Quote__c(Id=quoteId, SBQQ__DocumentStatus__c = 'Failed');
            Logger.warn(e.getMessage(), quoteId);
            Logger.saveLog();
        }
        return asyncApexJobId;
    }

    /*
    * Generate Conga Document using Conga API and attach that document to the given record.
    */
    public static String callGenerateDocument(Id quoteId, Map<String, String> params) {
        String sessId = UserInfo.getSessionId();
        String servUrl = Url.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/47.0/' + UserInfo.getOrganizationId();
        Map<String, String> allParams = new  Map<String, String>{
            'sessionId' => sessId, 
            'serverUrl' => servUrl, 
            'id' => quoteId
        };
        allParams.putAll(params);

        HTTPResponse res;
        try {
            res = new HttpCalloutService('CPQ_Conga_Generate_Document', true).get(allParams);
        } catch (Exception e) {
            update new SBQQ__Quote__c(Id=quoteId, SBQQ__DocumentStatus__c = 'Failed');
            Logger.warn(e.getMessage(), quoteId);
            Logger.saveLog();
        }

        if(res.getStatusCode() != 200 && res.getBody().contains('error')) {
            Logger.warn('Conga generateDocument error message: ' + res.getBody(), quoteId);
            Logger.saveLog();
            return '';
        } else {
            String congaResponseBody = res.getBody();
            return congaResponseBody;
        }
    }

    @testVisible
    private static Integer getNextQuoteDocVersionNumber(Id quoteId) {
        COM_ContentDocumentLinkSelector cdlSelector = COM_ContentDocumentLinkSelector.newInstance();
        List<ContentDocumentLink> relatedCDLList = cdlSelector.selectByLinkedEntityId(quoteId);
        Integer maxVersionNumber = 0;
        for (ContentDocumentLink cdl : relatedCDLList) {
            String rawFileName = cdl.ContentDocument.Title;
            String stringAfterLastDash =  rawFileName.substringAfterLast('-').substringBefore('.');
            if (stringAfterLastDash.isNumeric() == true && stringAfterLastDash.length() < 4) { 
                Integer versionNumber = Integer.valueOf(stringAfterLastDash);
                if (maxVersionNumber < versionNumber) {
                    maxVersionNumber = versionNumber;
                }
            }
        }
        return maxVersionNumber + 1;
    }

}