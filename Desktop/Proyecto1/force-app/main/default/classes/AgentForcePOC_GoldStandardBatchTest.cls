@isTest
private class AgentForcePOC_GoldStandardBatchTest {

    @isTest(SeeAllData=true)
    static void testGoldStandardBatchNoKnowledgeArticle() {
        Product2 productStandard = new Product2(Name = 'Rheo Knee Standard', External_ID__c='PN20226Test', comesFromIntegration__c=true, 
        ProductCode = 'B-8391680', IsActive = true, HierachyLocation__c = 'SKU', LevelA__c = 'Prosthetics');
        insert productStandard;

        Account acc = new COM_TestHelper.AccountBuilder()
            .withName('AgentForcePoc Test Account')
            .withCustomerSourceId('AB124156')
            .withCustomerOriginId(20.0)
            .save()
            .getRecord();
        
        Opportunity opp = new COM_TestHelper.OpportunityBuilder(
                acc.Id,
                'AgentForcePoc Opp Name',
                'Capital',
                System.today()
            )
            .getRecord();
       	insert opp;
        Profile p = [SELECT Id FROM Profile WHERE Name='System administrator']; 
        User u = new User(Alias = 'Agent', Email='AgentForcePocBatchUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='AgentForcePocBatchUser', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='AgentForcePocBatchUser@testorg.com');
        insert u;
        AgentForcePOC_GoldStandardBatch testBatch = new AgentForcePOC_GoldStandardBatch();
        testBatch.withGoldStandardToProcess(new List<AgentForcePOC_Gold_Standard__mdt>{
            new AgentForcePOC_Gold_Standard__mdt(
                Country__c = 'TestCountry',
                OpportunityIds__c = opp.Id,
                Notified_Username__c = u.Email
            )
        });
        Test.startTest();
            Database.executeBatch(testBatch);
        Test.stopTest();
        Knowledge__kav knowledgeArticle = [SELECT Procedure_Steps__c FROM Knowledge__kav WHERE Title = 'Gold Standard TestCountry' LIMIT 1];
        Assert.isTrue(
            String.isNotBlank(knowledgeArticle.Procedure_Steps__c),
            'Procedure Steps should be populated with prompt response'
        );
    }

    @isTest(SeeAllData=true)
    static void testGoldStandardBatchExistingKnowledgeArticle() {
        Product2 productStandard = new Product2(Name = 'Rheo Knee Standard', External_ID__c='PN20226Test', comesFromIntegration__c=true, 
        ProductCode = 'B-8391680', IsActive = true, HierachyLocation__c = 'SKU', LevelA__c = 'Prosthetics');
        insert productStandard;

        Account acc = new COM_TestHelper.AccountBuilder()
            .withName('AgentForcePoc Test Account')
            .withCustomerSourceId('AB124156')
            .withCustomerOriginId(20.0)
            .save()
            .getRecord();
        
        Opportunity opp = new COM_TestHelper.OpportunityBuilder(
                acc.Id,
                'AgentForcePoc Opp Name',
                'Capital',
                System.today()
            )
            .getRecord();
       	insert opp;
        Knowledge__kav article = new Knowledge__kav(
            Title = 'Gold Standard TestCountry',
            Language = 'en_US',
            PublishStatus = 'Draft',
            UrlName = 'Gold-Standard-TestCountry');
        insert article;
        Knowledge__kav articleCreated = [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :article.Id];
        KbManagement.PublishingService.publishArticle(articleCreated.KnowledgeArticleId, true);
        AgentForcePOC_GoldStandardBatch testBatch = new AgentForcePOC_GoldStandardBatch();
        testBatch.withGoldStandardToProcess(new List<AgentForcePOC_Gold_Standard__mdt>{
            new AgentForcePOC_Gold_Standard__mdt(
                Country__c = 'TestCountry',
                OpportunityIds__c = opp.Id
            )
        });
        Test.startTest();
            Database.executeBatch(testBatch);
        Test.stopTest();
        Knowledge__kav knowledgeArticle = [SELECT Procedure_Steps__c FROM Knowledge__kav WHERE Title = 'Gold Standard TestCountry' and PublishStatus = 'Draft' LIMIT 1];
        Assert.isTrue(
            String.isNotBlank(knowledgeArticle.Procedure_Steps__c),
            'Procedure Steps should be populated with prompt response'
        );
    }
}