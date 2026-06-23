public with sharing class QuoteDocumentQueueable implements Queueable, Database.AllowsCallouts {
    public Id quoteId;
    public Map<String, String> params;
    public Id salesforceUserId; // user who triggered quote document generation
    public Boolean sendEmailAutomatically;
    public String emailRecipientsJson;
    public String emailLanguage;

    public QuoteDocumentQueueable(Id quoteId, Map<String, String> params, Id salesforceUserId, Boolean sendEmailAutomatically, String emailRecipientsJson, String emailLanguage) {
        this.quoteId = quoteId;
        this.params = params;
        this.salesforceUserId = salesforceUserId;
        this.sendEmailAutomatically = sendEmailAutomatically;
        this.emailRecipientsJson = emailRecipientsJson;
        this.emailLanguage = emailLanguage;
    }

    public void execute(QueueableContext context) {
        Finalizer finalizer = new QuoteDocumentFinalizer(this.quoteId, this.salesforceUserId, this.sendEmailAutomatically, emailRecipientsJson, this.emailLanguage);
        System.attachFinalizer(finalizer);        
        QuoteDocumentService.callGenerateDocument(quoteId, params);
    }   

}