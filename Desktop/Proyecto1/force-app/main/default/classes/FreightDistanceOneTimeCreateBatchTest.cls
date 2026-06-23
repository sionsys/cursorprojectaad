@IsTest
public with sharing class FreightDistanceOneTimeCreateBatchTest {
    
    // Processes records with valid distances and addresses
    @isTest
    private static void testProcessRecordsWithValidDistancesAndAddresses() {
        Scope3EmssnSrc scope3emSource = new Scope3EmssnSrc();
        scope3emSource.Name = 'Test Record';
        insert scope3emSource;

        // Create test data
        FrgtHaulingEnrgyUse record = new FrgtHaulingEnrgyUse(
            Name = 'Test Record',
            Distance = 100,
            FreightHaulingMode = 'Road',
            Load_Address__CountryCode__s = 'US',
            Load_Address__StateCode__s = 'CA',
            Load_Address__PostalCode__s = '90001',
            Load_Address__City__s = 'Los Angeles',
            Load_Address__Street__s = '123 Main St',
            Unload_Address__CountryCode__s = 'US',
            Unload_Address__StateCode__s = 'NV',
            Unload_Address__PostalCode__s = '89101',
            Unload_Address__City__s = 'Las Vegas',
            Unload_Address__Street__s = '456 Elm St',
            Transport_Type__c = 'Outbound',
            Scope3EmssnSrcId = scope3emSource.Id
        );
        insert record;

        // Execute the batch
        FreightDistanceOneTimeCreateBatch batch = new FreightDistanceOneTimeCreateBatch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        List<Freight_Distance__c> results = [SELECT Id, Distance__c, 
                                                Load_Address__City__s, Load_Address__StateCode__s, Load_Address__CountryCode__s, Load_Address__Street__s, Load_Address__PostalCode__s, 
                                                Unload_Address__City__s, Unload_Address__StateCode__s, Unload_Address__CountryCode__s, Unload_Address__Street__s, Unload_Address__PostalCode__s
                                                FROM Freight_Distance__c];
                                                
        System.assertEquals(1, results.size(), 'Freight Distance does not exist.');
        System.assertEquals(100, results[0].Distance__c, 'Distance is incorrect');

        // Assert address fields
        System.assertEquals('Los Angeles', results[0].Load_Address__City__s, 'Load city is incorrect');
        System.assertEquals('CA', results[0].Load_Address__StateCode__s, 'Load state is incorrect');
        System.assertEquals('US', results[0].Load_Address__CountryCode__s, 'Load country is incorrect');
        System.assertEquals('123 Main St', results[0].Load_Address__Street__s, 'Load country is incorrect');
        System.assertEquals('90001', results[0].Load_Address__PostalCode__s, 'Unload country is incorrect');

        System.assertEquals('Las Vegas', results[0].Unload_Address__City__s, 'Unload city is incorrect');
        System.assertEquals('NV', results[0].Unload_Address__StateCode__s, 'Unload state is incorrect');
        System.assertEquals('US', results[0].Unload_Address__CountryCode__s, 'Unload country is incorrect');
        System.assertEquals('456 Elm St', results[0].Unload_Address__Street__s, 'Unload country is incorrect');
        System.assertEquals('89101', results[0].Unload_Address__PostalCode__s, 'Unload country is incorrect');
    }

    // Handles records with null Load_Address__CountryCode__s or Unload_Address__CountryCode__s
    @isTest
    private static void testHandleRecordsWithNullCountryCodes() {
        Scope3EmssnSrc scope3emSource = new Scope3EmssnSrc();
        scope3emSource.Name = 'Test Record';
        insert scope3emSource;


        // Create test data with null country codes
        FrgtHaulingEnrgyUse record1 = new FrgtHaulingEnrgyUse(
            Name = 'Test Record 1',
            Distance = 100,
            FreightHaulingMode = 'Road',
            Load_Address__CountryCode__s = null,
            Unload_Address__CountryCode__s = 'US',
            Transport_Type__c = 'Outbound',
            Scope3EmssnSrcId = scope3emSource.Id
        );
        FrgtHaulingEnrgyUse record2 = new FrgtHaulingEnrgyUse(
            Name = 'Test Record 2',
            Distance = 100,
            FreightHaulingMode = 'Road',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__CountryCode__s = null,
            Transport_Type__c = 'Outbound',
            Scope3EmssnSrcId = scope3emSource.Id
        );
        insert new List<FrgtHaulingEnrgyUse>{record1, record2};

        // Execute the batch
        FreightDistanceOneTimeCreateBatch batch = new FreightDistanceOneTimeCreateBatch();
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify no records were processed
        List<Freight_Distance__c> results = [SELECT Id FROM Freight_Distance__c];
        System.assertEquals(0, results.size());
    }
}