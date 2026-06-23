public with sharing class QuoteDocumentFinalizer implements Finalizer {
    public Id quoteId;
    public Id salesforceUserId; // user who triggered quote document generation
    public Boolean sendEmailAutomatically;
    public String emailRecipientsJson;
    public String emailLanguage;

    // empty constructor for Transaction Finalizer
    public QuoteDocumentFinalizer(Id quoteId, Id salesforceUserId, Boolean sendEmailAutomatically, String emailRecipientsJson, String emailLanguage) {
        this.quoteId = quoteId;
        this.salesforceUserId = salesforceUserId;
        this.sendEmailAutomatically = sendEmailAutomatically;
        this.emailRecipientsJson = emailRecipientsJson;
        this.emailLanguage = emailLanguage;
    } 

    // Finalizer implementation
    public void execute(FinalizerContext ctx) {
        if (ctx.getResult() == ParentJobResult.SUCCESS) {
            executeQuoteDocumentExtraSteps(ctx);
        } else {
            String errorMsg = 'Generate document queueable job result failed. Job id: ' + ctx.getAsyncApexJobId();
            Logger.warn(errorMsg, this.quoteId);
            Logger.saveLog();
        }        
    }

    public void executeQuoteDocumentExtraSteps(FinalizerContext ctx) {
        fflib_ISObjectUnitOfWork unitOfWork = CPQ_Application.UnitOfWork.newInstance();
        SBQQ__Quote__c relatedQuote;
        try {
            COM_ContentDocumentLinkSelector cdlSelector = new COM_ContentDocumentLinkSelector();
            ContentDocumentLink generatedCDL = cdlSelector.selectLatestQuoteDocumentCDL(this.quoteId);
            
            CPQ_QuoteSelector quoteSelector = new CPQ_QuoteSelector();
            relatedQuote = quoteSelector.selectQuoteForQuoteDocumentEmail(this.quoteId);
            if (this.sendEmailAutomatically == true) {
                String errorMessagesString = '';

                List<QuoteDocEmailRecipientsController.EmailRecipient> emailRecipients = (List<QuoteDocEmailRecipientsController.EmailRecipient>)
                    JSON.deserialize(this.emailRecipientsJson, List<QuoteDocEmailRecipientsController.EmailRecipient>.class);
                List<String> toAddresses = new List<String>();
                for (QuoteDocEmailRecipientsController.EmailRecipient recipient : emailRecipients) {
                    toAddresses.add(recipient.emailAddress);
                }

                String accountId = String.valueOf(relatedQuote.SBQQ__Account__r.Id);
                String countryCode = relatedQuote.SBQQ__ShippingCountry__c;
                String emailScenario = 'Send Quote pdf';
                Id attachmentIdAsId = generatedCDL?.ContentDocument?.LatestPublishedVersionId;
                String attachmentId = attachmentIdAsId != null ? String.valueOf(attachmentIdAsId) : null;
                Id relatedContact = relatedQuote.SBQQ__PrimaryContact__c;
            
                // error handling 
                // TODO: move it to separate method
                if (emailRecipients.size() == 0) {
                    errorMessagesString += ' No email recipients defined.';
                }
                if (countryCode == null) {
                    errorMessagesString += ' SBQQ__Quote__r.SBQQ__ShippingCountry__c field value is missing.';
                }
                if (attachmentId == null) {
                    errorMessagesString += ' No file (ContentDocument record) related to quote was found.';
                }
                if (String.isNotBlank(errorMessagesString)) {
                    throw new HandledException(errorMessagesString);
                }

                // set contact for email target if Quote.SBQQ__PrimaryContact__c field is null
                if (relatedContact == null) {
                    relatedContact = emailRecipients?.get(0)?.contactId;
                }

                Account relatedAccount = new COM_AccountsSelector().selectOneById(accountId);
            
                EmailPublisher.sendEmails(relatedContact, countryCode, emailScenario, attachmentId, this.emailLanguage, this.quoteId, toAddresses);
                relatedQuote.SBQQ__DocumentStatus__c = 'Sent';
                relatedQuote.SBQQ__Status__c = 'Quote Sent';
            } else if(generatedCDL != null) {
                relatedQuote.SBQQ__DocumentStatus__c = 'Generated';
            }
        } catch(Exception e) {
            relatedQuote.SBQQ__DocumentStatus__c = 'Failed';
            String errorMsg = String.format(
                'Email Generated Quote Document failed in queueable job: {0} with exception message: {1} and stack trace: {2}',
                new List<String> { String.valueOf(ctx.getAsyncApexJobId()), e.getMessage(), e.getStackTraceString() }
            );                        
            Logger.warn(errorMsg, this.quoteId);
            Logger.saveLog();
            CustomNotificationType[] notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'Quote_Document_Error'];
            CustomNotificationBuilder notificationObject = new CustomNotificationBuilder()
                .withTitle('Quote Document Error')
                .withBody('There was an error while sending quote document via email. Contact administrator to resolve the problem.')
                .withTargetId(relatedQuote.Id)
                .withNotificationRecipients(new Set<String> { this.salesforceUserId })
                .withNotificationTypeId(notificationType[0].Id);
            notificationObject.sendNotification();
        } finally {
            unitOfWork.registerDirty(new List<SBQQ__Quote__c> { relatedQuote });
            unitOfWork.commitWork();
        }
    }

}