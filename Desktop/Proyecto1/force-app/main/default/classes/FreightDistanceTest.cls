@IsTest
public with sharing class FreightDistanceTest {

    // Construct FreightDistance with valid Freight_Distance__c records
    @isTest
    private static void constructFreightDistanceWithValidRecords() {
        // Arrange
        List<Freight_Distance__c> records = new List<Freight_Distance__c>{
            new Freight_Distance__c(Freight_Hauling_Mode__c = 'Air', Load_Address__Street__s = '123 Main St', Load_Address__PostalCode__s = '12345', Load_Address__City__s = 'Metropolis', Load_Address__StateCode__s = 'CA', Load_Address__CountryCode__s = 'US', Unload_Address__Street__s = '456 Elm St', Unload_Address__PostalCode__s = '67890', Unload_Address__City__s = 'Gotham', Unload_Address__StateCode__s = 'NY', Unload_Address__CountryCode__s = 'US')
        };
        
        // Act
        FreightDistance freightDistance = new FreightDistance(records);
        
        // Assert
        System.assertNotEquals(null, freightDistance);
        System.assertEquals(1, freightDistance.records.size());
    }

    // Handle null Freight_Distance__c records gracefully
    @isTest
    private static void handleNullFreightDistanceRecordsGracefully() {
        // Arrange
        List<Freight_Distance__c> records = new List<Freight_Distance__c>{ new Freight_Distance__c() };
        
        // Act
        FreightDistance freightDistance = new FreightDistance(records);
        freightDistance.onBeforeInsert();
        
        // Assert
        System.assertNotEquals(null, freightDistance);
        System.assertEquals(1, freightDistance.records.size());
        System.assertEquals('', ((Freight_Distance__c)(freightDistance.records[0])).External_Id__c);
    }

}