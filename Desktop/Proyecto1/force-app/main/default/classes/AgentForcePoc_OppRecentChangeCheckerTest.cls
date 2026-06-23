@isTest
private class AgentForcePoc_OppRecentChangeCheckerTest {

    @testSetup
    static void testSetup() {
                Product2 productStandard = new Product2(Name = 'Rheo Knee Standard', External_ID__c='PN20226', comesFromIntegration__c=true, 
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

        Task taskRelatedToOpportunity = new TAP_TestHelper.TAP_TaskBuilder().withRelatedTo(opp.Id).save().getRecord();
        Event eventRelatedToObjective = new TAP_TestHelper.TAP_EventBuilder().withRelatedTo(opp.Id).save().getRecord();
		
        Id stdPricebookId = Test.getStandardPricebookId();
        PricebookEntry peStd = new COM_TestHelper.PricebookEntryBuilder()
        .build().withIsActive(true).withUnitPrice(100).withPricebook2Id(stdPricebookId).withProduct2Id(productStandard.Id).getRecord();
        insert peStd;
        OpportunityLineItem oppLineItem = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = productStandard.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = peStd.Id
        );
        insert oppLineItem;

        Order order = new Order(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            EffectiveDate = Date.today(),
            Status = CPQ_Constants.QUOTE_DRAFT_STATUS,
            Pricebook2Id = stdPricebookId
        );
        insert order;
        
        OrderItem orderItem = new OrderItem(
            OrderId = order.Id,
            Product2Id = productStandard.Id,
            Quantity = 1,
            UnitPrice = 100,
            PricebookEntryId = peStd.Id
        );
        insert orderItem;
    }

    @isTest
    static void testAgentForcePoc_RecentChangeChecker() {
        String opportunityId = [SELECT Id FROM Opportunity]?.Id;
        AgentForcePoc_OppRecentChangeChecker.Request request = new AgentForcePoc_OppRecentChangeChecker.Request();
        request.OpportunityId = opportunityId;
        request.lookbackDays = 14;
        List<AgentForcePoc_OppRecentChangeChecker.Response> response;
        Test.startTest();
                response = AgentForcePoc_OppRecentChangeChecker.checkRecentChanges(new List<AgentForcePoc_OppRecentChangeChecker.Request>{request});
        Test.stopTest();

        Assert.areEqual(
            opportunityId,
            response[0].opportunityId,
            'Opportunity Id is expected to be returned'
        );

        Assert.isTrue(
            response[0].hasRecentChange,
            'Opportunity is expected to have a recent change'
        );
    }  
}