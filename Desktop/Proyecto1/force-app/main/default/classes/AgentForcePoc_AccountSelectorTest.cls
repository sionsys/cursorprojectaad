@isTest
private class AgentForcePoc_AccountSelectorTest {

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
    static void testAgentForcePoc_AccountSelector() {
        String accountId = [SELECT Id FROM Account]?.Id;
        AgentForcePoc_AccountSelector.Request request = new AgentForcePoc_AccountSelector.Request();
        request.AccountId = accountId;
        List<AgentForcePoc_AccountSelector.Response> response;
        Test.startTest();
            response = AgentForcePoc_AccountSelector.getAccountData(new List<AgentForcePoc_AccountSelector.Request>{request});
        Test.stopTest();
        List<AgentForcePoc_AccountSelector.ProductWrapper> productResponse = (List<AgentForcePoc_AccountSelector.ProductWrapper>)JSON.deserialize(response[0].Prompt, List<AgentForcePoc_AccountSelector.ProductWrapper>.class);

        Assert.areEqual(
            'Rheo Knee Standard',
            productResponse[0].name,
            'Rheo Knee Standard is expeted as s name of the product'
        );
    }
}