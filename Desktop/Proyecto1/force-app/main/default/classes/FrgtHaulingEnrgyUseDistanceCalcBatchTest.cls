@isTest
public class FrgtHaulingEnrgyUseDistanceCalcBatchTest {
    
    @testSetup
    static void setup() {
        NetZeroTestDataFactory.createFreightHaulingEnergyUseRecordsForBatch();
    }

    @isTest
    static void testBatchExecution() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpGoogleMapsResponseGenerator());

        List<FrgtHaulingEnrgyUse> recordsToProcess =  [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                                                            FROM FrgtHaulingEnrgyUse 
                                                            WHERE Distance = 0 
                                                                AND Failed_Distance_Calculation__c != true];

        // Start test context
        Test.startTest();
        
        // Create instance of the batch class
        FrgtHaulingEnrgyUseDistanceCalcBatch batch = new FrgtHaulingEnrgyUseDistanceCalcBatch();
        batch.processRecords(recordsToProcess);
        
        // End test context
        Test.stopTest();
        
        // Perform assertions
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = false];
        System.assertEquals(7, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 7 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(1816.193, frgtHaulingEnrgyUse.Distance);
            System.assertEquals('Kilometers', frgtHaulingEnrgyUse.DistanceUnit);
        }

        frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = true];
        System.assertEquals(3, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be true for 3 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(0, frgtHaulingEnrgyUse.Distance);
        }
    }

    @isTest
    static void testSearatesBatchExecution() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpSearatesResponseGenerator());

        

        List<FrgtHaulingEnrgyUse> recordsToProcess =  [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                                                            FROM FrgtHaulingEnrgyUse 
                                                            WHERE Distance = 0 
                                                                AND Failed_Distance_Calculation__c != true];

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : recordsToProcess) {
            frgtHaulingEnrgyUse.FreightHaulingMode = 'Water';
        }
        
        // Start test context
        Test.startTest();
        
        // Create instance of the batch class
        FrgtHaulingEnrgyUseDistanceCalcBatch batch = new FrgtHaulingEnrgyUseDistanceCalcBatch();
        batch.processRecords(recordsToProcess);
        
        // End test context
        Test.stopTest();
        
        // Perform assertions
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = false];
        System.assertEquals(7, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 7 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(1816.193, frgtHaulingEnrgyUse.Distance);
            System.assertEquals('Kilometers', frgtHaulingEnrgyUse.DistanceUnit);
        }

        frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = true];
        System.assertEquals(3, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be true for 3 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(0, frgtHaulingEnrgyUse.Distance);
        }
    }

    @isTest
    static void testDistanceToBatchExecution() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpDistanceToResponseGeneratorSuccess());

        

        List<FrgtHaulingEnrgyUse> recordsToProcess =  [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                                                            FROM FrgtHaulingEnrgyUse 
                                                            WHERE Distance = 0 
                                                                AND Failed_Distance_Calculation__c != true];

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : recordsToProcess) {
            frgtHaulingEnrgyUse.FreightHaulingMode = 'Air';
        }
        
        // Start test context
        Test.startTest();
        
        // Create instance of the batch class
        FrgtHaulingEnrgyUseDistanceCalcBatch batch = new FrgtHaulingEnrgyUseDistanceCalcBatch();
        batch.processRecords(recordsToProcess);
        
        // End test context
        Test.stopTest();
        
        // Perform assertions
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = false];
        System.assertEquals(7, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 7 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(1816.193, frgtHaulingEnrgyUse.Distance);
            System.assertEquals('Kilometers', frgtHaulingEnrgyUse.DistanceUnit);
        }

        frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = true];
        System.assertEquals(3, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be true for 3 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(0, frgtHaulingEnrgyUse.Distance);
        }
    }

    @IsTest
    static void testActualBatchRun() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpGoogleMapsResponseGenerator());

        Test.startTest();
        Database.executeBatch(new FrgtHaulingEnrgyUseDistanceCalcBatch(), 200);
        Test.stopTest();
    }

    @isTest
    static void testTranslateFreightHaulingMode() {
        // Create an instance of the class containing the method
        FrgtHaulingEnrgyUseDistanceCalcBatch batchInstance = new FrgtHaulingEnrgyUseDistanceCalcBatch();

        // Test case for 'Water'
        String result = batchInstance.translateFreightHaulingMode('Water');
        System.assertEquals('SEA', result, 'Expected SEA for input Water');

        // Test case for 'AIR'
        result = batchInstance.translateFreightHaulingMode('AIR');
        System.assertEquals('AIR', result, 'Expected AIR for input AIR');

        // Test case for 'RAIL'
        result = batchInstance.translateFreightHaulingMode('RAIL');
        System.assertEquals('RAIL', result, 'Expected RAIL for input RAIL');

        // Test case for 'ROAD'
        result = batchInstance.translateFreightHaulingMode('ROAD');
        System.assertEquals('ROAD', result, 'Expected ROAD for input ROAD');

        // Test case for a lowercase mode
        result = batchInstance.translateFreightHaulingMode('road');
        System.assertEquals('ROAD', result, 'Expected ROAD for input road');
    }

    private class MockHttpSearatesResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"success": true, "status_code": "OK", "metadata": { "request_parameters": { "from": "Madrid, Spain", "to": "Ibiza, Spain", "transport_modes": "ROAD", "alternative_routes": false, "routing_mode": "short" } }, "data": { "route": { "summary": { "duration": 47730, "distance": 1816193, "speed": 40 }, "from": { "description": "Madrid, Comunidad de Madrid, Spain", "name": "Madrid", "state": "Comunidad de Madrid", "country": "Spain", "country_code": "ES", "locode": "ESMAD", "lat": 40.4165, "lng": -3.70256 }, "to": { "description": "Santa Eularia des Riu, Comunitat Autonoma de les Illes Balears, Spain", "name": "Santa Eularia des Riu", "state": "Comunitat Autonoma de les Illes Balears", "country": "Spain", "country_code": "ES", "locode": "ESSTE", "lat": 38.98457, "lng": 1.53409 }, "sections": [] }, "alternative_routes": [] } }');
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpDistanceToResponseGeneratorSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String responseBody = '{"route":{"vincenty":1816.193}}';
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testProcessRecordsWithExistingFreightDistance() {
        Scope3EmssnSrc scope3emSource = [SELECT Id FROM Scope3EmssnSrc LIMIT 1];

        // Arrange: Create a Freight_Distance__c record in the database
        Freight_Distance__c existingFreightDistance = new Freight_Distance__c(
            Distance__c = 100.5,
            Freight_Hauling_Mode__c = 'Road',
            Load_Address__Street__s = '123 Main St',
            Load_Address__City__s = 'CityA',
            Load_Address__StateCode__s = 'NV',
            Load_Address__PostalCode__s = '12345',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__Street__s = '456 Elm St',
            Unload_Address__City__s = 'CityB',
            Unload_Address__StateCode__s = 'CA',
            Unload_Address__PostalCode__s = '67890',
            Unload_Address__CountryCode__s = 'US'
        );
        insert existingFreightDistance;

        // Create a FrgtHaulingEnrgyUse record that matches the existing Freight_Distance__c
        FrgtHaulingEnrgyUse energyUseRecord = new FrgtHaulingEnrgyUse(
            Name = 'Test 1',
            Load_Address__Street__s = '123 Main St',
            Load_Address__City__s = 'CityA',
            Load_Address__StateCode__s = 'NV',
            Load_Address__PostalCode__s = '12345',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__Street__s = '456 Elm St',
            Unload_Address__City__s = 'CityB',
            Unload_Address__StateCode__s = 'CA',
            Unload_Address__PostalCode__s = '67890',
            Unload_Address__CountryCode__s = 'US',
            FreightHaulingMode = 'Road',
            Distance = 0,
            Scope3EmssnSrcId = scope3emSource.Id
        );
        insert energyUseRecord;

        // Create an instance of the batch class
        FrgtHaulingEnrgyUseDistanceCalcBatch batchInstance = new FrgtHaulingEnrgyUseDistanceCalcBatch();

        // Act: Call processRecords
        List<FrgtHaulingEnrgyUse> energyUseRecordsList = [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                                                            FROM FrgtHaulingEnrgyUse 
                                                            WHERE Id = :energyUseRecord.Id];

        Test.startTest();
        batchInstance.processRecords(energyUseRecordsList);
        Test.stopTest();

        // Assert: Verify the record was updated with the distance from the existing Freight_Distance__c
        FrgtHaulingEnrgyUse updatedRecord = [SELECT Distance FROM FrgtHaulingEnrgyUse WHERE Id = :energyUseRecord.Id];
        System.assertEquals(100.5, updatedRecord.Distance, 'Distance should match the existing Freight_Distance__c record');
    }

    @isTest
    static void testProcessRecordsCreatesFreightDistanceAndUsesMap() {
        Scope3EmssnSrc scope3emSource = [SELECT Id FROM Scope3EmssnSrc LIMIT 1];

        // Arrange: Create two FrgtHaulingEnrgyUse records with the same mode, load address, and unload address
        FrgtHaulingEnrgyUse record1 = new FrgtHaulingEnrgyUse(
            Name = 'Test 3',
            Load_Address__Street__s = '789 Oak St',
            Load_Address__City__s = 'CityC',
            Load_Address__StateCode__s = 'NV',
            Load_Address__PostalCode__s = '12345',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__Street__s = '123 Pine St',
            Unload_Address__City__s = 'CityD',
            Unload_Address__StateCode__s = 'CA',
            Unload_Address__PostalCode__s = '67890',
            Unload_Address__CountryCode__s = 'US',
            FreightHaulingMode = 'Road',
            Distance = 0,
            Scope3EmssnSrcId = scope3emSource.Id
        );
        FrgtHaulingEnrgyUse record2 = new FrgtHaulingEnrgyUse(
            Name = 'Test 2',
            Load_Address__Street__s = '789 Oak St',
            Load_Address__City__s = 'CityC',
            Load_Address__StateCode__s = 'NV',
            Load_Address__PostalCode__s = '12345',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__Street__s = '123 Pine St',
            Unload_Address__City__s = 'CityD',
            Unload_Address__StateCode__s = 'CA',
            Unload_Address__PostalCode__s = '67890',
            Unload_Address__CountryCode__s = 'US',
            FreightHaulingMode = 'Road',
            Distance = 0,
            Scope3EmssnSrcId = scope3emSource.Id
        );
        insert new List<FrgtHaulingEnrgyUse>{record1, record2};

        // Mock the API call (or ensure the method internally mocks it for testing)
        Test.setMock(HttpCalloutMock.class, new MockHttpGoogleMapsResponseGenerator());

        // Create an instance of the batch class
        FrgtHaulingEnrgyUseDistanceCalcBatch batchInstance = new FrgtHaulingEnrgyUseDistanceCalcBatch();

        // Act: Call processRecords
        List<FrgtHaulingEnrgyUse> energyUseRecordsList = [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                                                            FROM FrgtHaulingEnrgyUse 
                                                            WHERE Id = :record1.Id OR Id = :record2.Id];

        Test.startTest();
        batchInstance.processRecords(energyUseRecordsList);
        Test.stopTest();

        // Assert: Verify a Freight_Distance__c record was created and used for both records
        Freight_Distance__c createdFreightDistance = [SELECT Id, Distance__c FROM Freight_Distance__c];
        System.assertNotEquals(null, createdFreightDistance, 'A Freight_Distance__c record should be created');

        FrgtHaulingEnrgyUse updatedRecord1 = [SELECT Distance FROM FrgtHaulingEnrgyUse WHERE Id = :record1.Id];
        FrgtHaulingEnrgyUse updatedRecord2 = [SELECT Distance FROM FrgtHaulingEnrgyUse WHERE Id = :record2.Id];

        System.assertEquals(createdFreightDistance.Distance__c, updatedRecord1.Distance, 'Record 1 should use the created Freight_Distance__c');
        System.assertEquals(createdFreightDistance.Distance__c, updatedRecord2.Distance, 'Record 2 should use the created Freight_Distance__c');
    }

    @isTest
    static void testDistanceCalculatedEqualsZero() {
        // Mock the GoogleMapsDistanceMatrixAPI to return 0
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpGoogleMapsResponseGenerator(0));
        Database.executeBatch(new FrgtHaulingEnrgyUseDistanceCalcBatch());
        Test.stopTest();

        // Verify the distance was calculated as 0 and the record was updated correctly
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit, Failed_Distance_Calculation__c FROM FrgtHaulingEnrgyUse  WHERE Failed_Distance_Calculation__c = false];
        System.assertEquals(0, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 0 records');

        frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit, Failed_Distance_Calculation__c FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = true];
        System.assertEquals(10, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 10 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(0, frgtHaulingEnrgyUse.Distance, 'Distance should be 0');
            System.assertEquals(true, frgtHaulingEnrgyUse.Failed_Distance_Calculation__c, 'Failed_Distance_Calculation__c should be true for distance 0');
        }
    }

    @isTest
    static void testDistanceCalculatedEquals123() {
        // Mock the GoogleMapsDistanceMatrixAPI to return 123
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpGoogleMapsResponseGenerator(123000)); // 123 km in meters
        Database.executeBatch(new FrgtHaulingEnrgyUseDistanceCalcBatch());
        Test.stopTest();

        // Verify the distance was calculated as 0 and the record was updated correctly
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit, Failed_Distance_Calculation__c FROM FrgtHaulingEnrgyUse  WHERE Failed_Distance_Calculation__c = false];
        System.assertEquals(7, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 7 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(123, frgtHaulingEnrgyUse.Distance, 'Distance should be 123');
            System.assertEquals('Kilometers', frgtHaulingEnrgyUse.DistanceUnit, 'DistanceUnit should be Kilometers');
            System.assertEquals(false, frgtHaulingEnrgyUse.Failed_Distance_Calculation__c, 'Failed_Distance_Calculation__c should be false for a valid distance');
        }

        frgtHaulingEnrgyUseList = [SELECT Id, Distance, DistanceUnit, Failed_Distance_Calculation__c FROM FrgtHaulingEnrgyUse WHERE Failed_Distance_Calculation__c = true];
        System.assertEquals(3, frgtHaulingEnrgyUseList.size(), 'Failed_Distance_Calculation__c should be false for 3 records');

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUse : frgtHaulingEnrgyUseList) {
            System.assertEquals(0, frgtHaulingEnrgyUse.Distance, 'Distance should be 0');
            System.assertEquals(true, frgtHaulingEnrgyUse.Failed_Distance_Calculation__c, 'Failed_Distance_Calculation__c should be true for distance 0');
        }
    }

    // Handles case when all feature flags are disabled
    @isTest
    private static void testDistanceCalculationWithAllFeaturesDisabled() {
        // Setup test data
        FrgtHaulingEnrgyUse frgtHaulingEnrgyUseRecord = [SELECT Id, FreightHaulingMode, Load_Address__c, Unload_Address__c FROM FrgtHaulingEnrgyUse  WHERE Failed_Distance_Calculation__c = false LIMIT 1];

        AddressInfo loadAddressInfo = new AddressInfo(frgtHaulingEnrgyUseRecord.Load_Address__c);
        AddressInfo unloadAddressInfo = new AddressInfo(frgtHaulingEnrgyUseRecord.Unload_Address__c);

        // Disable all feature flags
        FeatureFlag__c featureFlags = FeatureFlag__c.getInstance();
        featureFlags.NetZero_Enable_Google_Integration__c = false;
        featureFlags.NetZero_Enable_DistanceTo_Integration__c = false;
        featureFlags.NetZero_Enable_Searates_Integration__c = false;
        upsert featureFlags;

        Test.startTest();

        FrgtHaulingEnrgyUseDistanceCalcBatch calcBatch = new FrgtHaulingEnrgyUseDistanceCalcBatch();
        Decimal distance = calcBatch.pickAndRunDistanceCalculationService(frgtHaulingEnrgyUseRecord, loadAddressInfo, unloadAddressInfo);

        Test.stopTest();

        System.assertEquals(0, distance, 'Distance should be 0 when all features are disabled');
    }

    private class MockHttpGoogleMapsResponseGenerator implements HttpCalloutMock {
        private Integer distance;

        public MockHttpGoogleMapsResponseGenerator() {
            distance = 1816193;
        }

        public MockHttpGoogleMapsResponseGenerator(Integer distance) {
            this.distance = distance;
        }

        public HTTPResponse respond(HTTPRequest req) {
            Integer distanceInKm = this.distance / 1000;

            Map<String, Object> jsonMap = new Map<String, Object>{
                'destination_addresses' => new List<String>{'EINDHOVEN, 5651GH, NL'},
                'origin_addresses' => new List<String>{'VOLDA, 6103, NO'},
                'rows' => new List<Map<String, Object>>{
                    new Map<String, Object>{
                        'elements' => new List<Map<String, Object>>{
                            new Map<String, Object>{
                                'distance' => new Map<String, Object>{
                                    'text' => distanceInKm+' km',
                                    'value' => this.distance
                                },
                                'duration' => new Map<String, Object>{
                                    'text' => '10 hours',
                                    'value' => 36000
                                },
                                'status' => 'OK'
                            }
                        }
                    }
                },
                'status' => 'OK'
            };

            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(jsonMap));
            res.setStatusCode(200);
            return res;
        }
    }

    @IsTest
    private static void testDistanceCalculationException() {
       
        // Mock Google Maps API to return 0
        MockHttpGoogleMapsResponseGenerator mockGoogleResponse = 
            new MockHttpGoogleMapsResponseGenerator(0);
        Test.setMock(HttpCalloutMock.class, mockGoogleResponse);

        List<FrgtHaulingEnrgyUse> recordsToProcess =  [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                                                            FROM FrgtHaulingEnrgyUse 
                                                            WHERE Failed_Distance_Calculation__c != true
                                                            AND FreightHaulingMode = 'Road'
                                                            AND Distance = 0];
        
        // Start test context
        Test.startTest();
        
        // Create instance of the batch class
        FrgtHaulingEnrgyUseDistanceCalcBatch batch = new FrgtHaulingEnrgyUseDistanceCalcBatch();
        batch.processRecords(recordsToProcess);
        
        Test.stopTest();
        
        // Verify results
        FrgtHaulingEnrgyUse updatedRecord = [
            SELECT Id, Failed_Distance_Calculation__c, Distance
            FROM FrgtHaulingEnrgyUse 
            WHERE Id = :recordsToProcess[0].Id
        ];
        
        System.assertEquals(true, updatedRecord.Failed_Distance_Calculation__c, 
            'Record should be marked as failed when distance calculation returns 0');
        System.assertEquals(0, updatedRecord.Distance, 
            'Distance should remain 0 when calculation fails');
    }

}