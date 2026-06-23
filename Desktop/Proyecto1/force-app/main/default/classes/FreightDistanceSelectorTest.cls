@IsTest
public with sharing class FreightDistanceSelectorTest {
    
    @isTest
    private static void testCreateNewInstanceSuccessfully() {        
        // Act
        FreightDistanceSelector result = FreightDistanceSelector.newInstance();
        
        // Assert
        System.assertNotEquals(null, result, 'The instance should not be null');
    }

    // Correctly adds related fields to the query factory
    @isTest
    private static void addRelatedFieldsToQueryFactory() {
        // Arrange
        Map<Schema.SObjectField, List<Schema.SObjectField>> fields = new Map<Schema.SObjectField, List<Schema.SObjectField>>();
        Schema.SObjectField parentField = Account.ParentId;
        Schema.SObjectField childField1 = Account.Name;
        Schema.SObjectField childField2 = Account.Industry;
        fields.put(parentField, new List<Schema.SObjectField>{childField1, childField2});
        
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Account.SObjectType);
        
        // Act
        FreightDistanceSelector selector = FreightDistanceSelector.newInstance();
        queryFactory = selector.getRelatedFields(fields, queryFactory);
        
        // Assert
        System.assert(queryFactory.getSelectedFields().contains('Parent.Name'));
        System.assert(queryFactory.getSelectedFields().contains('Parent.Industry'));
    }

    // Returns a list containing AsyncApexJob.Id and AsyncApexJob.Status
    @isTest
    private static void returnsListWithAsyncApexJobFields() {
        // Arrange
        FreightDistanceSelector selector = new FreightDistanceSelector();
        
        // Act
        List<Schema.SObjectField> result = selector.getSObjectFieldList();
        
        // Assert
        System.assertEquals(6, result.size());
        System.assertEquals(Freight_Distance__c.Id, result[0]);
    }

    @isTest
    private static void testGetSObjectType() {
        // Arrange
        FreightDistanceSelector selector = new FreightDistanceSelector();
        
        // Act
        Schema.SObjectType result = selector.getSObjectType();
        
        // Assert
        System.assertEquals(Freight_Distance__c.sObjectType, result, 'The SObjectType should be Freight_Distance__c.sObjectType');
    }

    @isTest
    private static void testSelectOneFreightDistanceByAddressesAndFreightHaulingMode() {
        // Arrange
        Freight_Distance__c record = new Freight_Distance__c();
        String freightHaulingMode = 'Road';
        
        Freight_Distance__c freightDistance = new Freight_Distance__c(
            Distance__c = 100,
            Freight_Hauling_Mode__c = freightHaulingMode,
            Load_Address__Street__s = 'ABC',
            Load_Address__City__s = 'XYZ',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__Street__s = 'ABC',
            Unload_Address__City__s = 'XYZUnl',
            Unload_Address__CountryCode__s = 'US'
        );
        insert freightDistance;

        Freight_Distance__c frRecord = [SELECT Id, Load_Address__c, Unload_Address__c, Freight_Hauling_Mode__c, External_Id__c FROM Freight_Distance__c WHERE Id = :freightDistance.Id];
        
        Test.startTest();
        FreightDistanceSelector selector = FreightDistanceSelector.newInstance();
        
        // Act
        Freight_Distance__c result = selector.selectOneFreightDistanceByAddressesAndFreightHaulingMode(frRecord.Freight_Hauling_Mode__c, frRecord.Load_Address__c, frRecord.Unload_Address__c);
        
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals(100, result.Distance__c, 'The External_Id__c should match the inserted record');
    }
}