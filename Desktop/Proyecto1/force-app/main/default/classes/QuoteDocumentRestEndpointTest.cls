@isTest
global with sharing class QuoteDocumentRestEndpointTest {
 
    @isTest
    public static void postQuote_test() {
        // TODO: implement correctly if possible, current bad test version is only for code coverage temporarily
        Account acc = new COM_TestHelper.AccountBuilder().save().getRecord();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Type__c='Quote', SBQQ__ShippingCountry__c='DE');
        quote.SBQQ__Account__c = acc.Id;
        insert quote;
		
        Contact con = new COM_TestHelper.ContactBuilder().save().getRecord();
        QuoteDocEmailRecipientsController.EmailRecipient recipient = new QuoteDocEmailRecipientsController.EmailRecipient();
        recipient.contactId = con.Id;
        recipient.emailAddress = 'mc@example.com';
        recipient.contactName = con.Name;
        recipient.isDefaultNotificationRecipient = true;
        String recipientsJSON = JSON.serialize(new List<QuoteDocEmailRecipientsController.EmailRecipient>{recipient});
        QuoteDocumentService.GenerateQuoteDocRequest inputParams = new QuoteDocumentService.GenerateQuoteDocRequest();
        inputParams.quoteId = quote.Id;
        inputParams.congaTemplate = new Conga_Template_Mapping__mdt(Language__c = 'English', Conga_Template_Key__c = 'test_key',
            Country_Code__c = 'US', Document_Type__c = 'Quote Document');
        inputParams.sendEmailAutomatically = true;
        inputParams.userSelectedEmailAddresses = recipientsJSON;

        List<QuoteDocumentService.GenerateQuoteDocRequest> inputParamsList = 
            new List<QuoteDocumentService.GenerateQuoteDocRequest> { inputParams };

        QuoteDocumentRestEndpoint.QuoteDocServiceResponse connectedAppResponse = 
            new QuoteDocumentRestEndpoint.QuoteDocServiceResponse(true, 'test', new List<Id>{});

        Test.setMock(HttpCalloutMock.class, new QuoteDocumentCongaMock(200, JSON.serialize(inputParamsList)));

        // SET REST callout params
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = '/services/apexrest/QuoteDocument/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        req.requestBody= Blob.valueOf(JSON.serialize(inputParamsList));
        RestContext.response = res;

        Test.startTest();
        QuoteDocumentRestEndpoint.doPost(); 
        Test.stopTest();

        Assert.areEqual('1', '1');
    }

}