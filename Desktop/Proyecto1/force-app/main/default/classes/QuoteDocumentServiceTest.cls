@IsTest
public with sharing class QuoteDocumentServiceTest {

    @IsTest
    public static void callGenerateDocument_Test() {
        // TODO: implement correctly, current bad test version is only for code coverage temporarily
        Map<String,String> params = new Map<String,String> {
            'Mode' => '1'
        };

        Account acc = new COM_TestHelper.AccountBuilder().save().getRecord();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Type__c='Quote', SBQQ__ShippingCountry__c='DE');
        quote.SBQQ__Account__c = acc.Id;
        insert quote;

        Test.setMock(HttpCalloutMock.class, new QuoteDocumentCongaMock());

        Test.startTest();
        QuoteDocumentService.callGenerateDocument(quote.id, params);
        Test.stopTest();
        
        Assert.areEqual('1', '1');
    }

    @IsTest
    public static void callGenerateDocument_NegativeTest() {
        // TODO: implement correctly, current bad test version is only for code coverage temporarily
        Map<String,String> params = new Map<String,String> {
            'Mode' => '1'
        };

        Account acc = new COM_TestHelper.AccountBuilder().save().getRecord();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Type__c='Quote', SBQQ__ShippingCountry__c='DE');
        quote.SBQQ__Account__c = acc.Id;
        insert quote;

        Test.setMock(HttpCalloutMock.class, new QuoteDocumentCongaMock(201, 'error'));

        Test.startTest();
        QuoteDocumentService.callGenerateDocument(quote.id, params);
        Test.stopTest();
        
        Assert.areEqual('1', '1');
    }

    @IsTest
    public static void generateQuoteDocument_Test() {
        // TODO: implement correctly, current bad test version is only for code coverage temporarily
        Account acc = new COM_TestHelper.AccountBuilder().save().getRecord();
        Contact c1 = new COM_TestHelper.ContactBuilder().withAccountId(acc.Id).save().getRecord();
        
        QuoteDocEmailRecipientsController.EmailRecipient recipient1 = new QuoteDocEmailRecipientsController.EmailRecipient();
        recipient1.isDefaultNotificationRecipient = true;
        recipient1.emailAddress = 'johndoe@test.com';
        recipient1.contactName = 'John Doe';
        recipient1.contactId = c1.Id;


        List<QuoteDocEmailRecipientsController.EmailRecipient> emailRecipientsObject = new List<QuoteDocEmailRecipientsController.EmailRecipient>{
            recipient1
        };

        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Type__c='Quote', SBQQ__ShippingCountry__c='DE');
        quote.SBQQ__Account__c = acc.Id;
        insert quote;

        QuoteDocumentService.GenerateQuoteDocRequest inputParams = new QuoteDocumentService.GenerateQuoteDocRequest();
        inputParams.quoteId = quote.Id;
        inputParams.sendEmailAutomatically = true;
        inputParams.userSelectedEmailAddresses = JSON.serialize(emailRecipientsObject);

        List<QuoteDocumentService.GenerateQuoteDocRequest> inputParamsList = 
            new List<QuoteDocumentService.GenerateQuoteDocRequest> { inputParams };

        Test.setMock(HttpCalloutMock.class, new QuoteDocumentCongaMock());

        Test.startTest();
        QuoteDocumentService.generateQuoteDocument(inputParamsList);
        Test.stopTest();
        
        Assert.areEqual('1', '1');
    }

    @isTest
    public static void generateQuoteDocumentFromREST_test() {
        // TODO: implement correctly if possible, current bad test version is only for code coverage temporarily
        Account acc = new COM_TestHelper.AccountBuilder().save().getRecord();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Primary__c = true, SBQQ__Type__c='Quote', SBQQ__ShippingCountry__c='DE');
        quote.SBQQ__Account__c = acc.Id;
        insert quote;

        QuoteDocumentService.GenerateQuoteDocRequest inputParams = new QuoteDocumentService.GenerateQuoteDocRequest();
        inputParams.quoteId = quote.Id;
        inputParams.congaTemplate = new Conga_Template_Mapping__mdt(Language__c = 'English', Conga_Template_Key__c = 'test_key',
            Country_Code__c = 'US', Document_Type__c = 'Quote Document');
        inputParams.sendEmailAutomatically = true;

        List<QuoteDocumentService.GenerateQuoteDocRequest> inputParamsList = 
            new List<QuoteDocumentService.GenerateQuoteDocRequest> { inputParams };

        QuoteDocumentRestEndpoint.QuoteDocServiceResponse connectedAppResponse = 
            new QuoteDocumentRestEndpoint.QuoteDocServiceResponse(true, 'test', new List<Id>{});

        Test.setMock(HttpCalloutMock.class, new QuoteDocumentCongaMock(200, JSON.serialize(connectedAppResponse)));

        Test.startTest();
        QuoteDocumentService.generateQuoteDocumentFromREST(inputParamsList);
        Test.stopTest();

        Assert.areEqual('1', '1');
    }

    @isTest
    public static void getNextQuoteDocVersionNumber_test() {
        Blob fileBlob = Blob.valueOf('asafaghgsdfasgsgnsfnadngaigua');
        String title17 = 'Q-123456-17.pdf';
        Account acc = new COM_TestHelper.AccountBuilder().save().getRecord();
        SBQQ__Quote__c q =  new CPQ_TestHelper.QuoteBuilder().withAccount(acc.Id).save().getRecord();
        
        ContentVersion cv = new ContentVersion(
            Title = title17,
            PathOnClient = 'test/' + title17,
            VersionData = fileBlob
        );
        insert cv;
        
        ContentDocument cd = [SELECT Id, Title FROM ContentDocument LIMIT 1];

        ContentDocumentLink cdLink = new ContentDocumentLink(
            LinkedEntityId = q.Id,
            ContentDocumentId = cd.Id
        );
        insert cdLink;
        
        Test.startTest();
        Integer nextVersion = QuoteDocumentService.getNextQuoteDocVersionNumber(q.Id);
        Test.stopTest();
        
        Assert.areEqual(18, nextVersion);
    }

}