@isTest
public class FrgtHaulingEnrgyUseDistProcessingTest {

    @isTest
    static void testIsFreightHaulingEnergyUseProcessingNotRunning() {

        Test.startTest();
        Boolean result = FrgtHaulingEnrgyUseDistanceProcessing.isFreightHaulingEnergyUseProcessingRunning();
        Test.stopTest();

        System.assertEquals(false, result, 'Expected the batch job to NOT be running');
    }

    @IsTest
    static void testIsFreightHaulingEnergyUseProcessingIsRunning() {
        // Arrange
        List<AsyncApexJob> asyncJobs = new List<AsyncApexJob>{
            new AsyncApexJob()
        };

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AsyncApexJobSelector asyncApexJobSelector = (AsyncApexJobSelector)mocks.mock(AsyncApexJobSelector.class);
        
        mocks.startStubbing();
        mocks.when(asyncApexJobSelector.sObjectType()).thenReturn(Schema.AsyncApexJob.SObjectType);
        mocks.when(asyncApexJobSelector.getActiveAsyncJobsByApexClassName('FrgtHaulingEnrgyUseDistanceCalcBatch')).thenReturn(asyncJobs);
        mocks.stopStubbing();

        NetZeroApplication.Selector.setMock(asyncApexJobSelector);

        Test.startTest();
        Boolean result = FrgtHaulingEnrgyUseDistanceProcessing.isFreightHaulingEnergyUseProcessingRunning();
        Test.stopTest();

        // Assert
        System.assertEquals(true, result, 'Expected the batch job to be running');
    }

    @isTest
    static void testTriggerDistanceCalculation() {
        Test.startTest();
        FrgtHaulingEnrgyUseDistanceProcessing.triggerDistanceCalculation();
        Test.stopTest();

        // Verify that the batch job was enqueued
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'FrgtHaulingEnrgyUseDistanceCalcBatch'];
        System.assert(!jobs.isEmpty(), 'Expected the batch job to be enqueued');
    }

    // Returns correct counts when FrgtHaulingEnrgyUse records are accessible
    @isTest
    private static void testCountsWhenRecordsAccessible() {
        // Setup test data
        Scope3EmssnSrc scope3emSource = new Scope3EmssnSrc();
        scope3emSource.Name = 'Test Record';
        insert scope3emSource;

        Map<String, String> loadAddress = new Map<String, String>{'Load_Address__City__s' => 'EINDHOVEN', 'Load_Address__PostalCode__s' => '5651GH', 'Load_Address__CountryCode__s' => 'NL'};
        Map<String, String> unloadAddress = new Map<String, String>{'Unload_Address__City__s' => 'DRESDEN', 'Unload_Address__PostalCode__s' => '1109', 'Unload_Address__CountryCode__s' => 'DE'};

        // Create test data
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = new List<FrgtHaulingEnrgyUse>();
        for (Integer i = 0; i < 3; i++) {
            FrgtHaulingEnrgyUse frgtHaulingEnrgyUse = new FrgtHaulingEnrgyUse();
            
            // load address
            frgtHaulingEnrgyUse.Load_Address__Street__s = (i == 2 ? '-, -, -' : '');
            frgtHaulingEnrgyUse.Load_Address__City__s = loadAddress.get('Load_Address__City__s');
            frgtHaulingEnrgyUse.Load_Address__PostalCode__s = loadAddress.get('Load_Address__PostalCode__s');
            frgtHaulingEnrgyUse.Load_Address__CountryCode__s = loadAddress.get('Load_Address__CountryCode__s');
            
            // unload address
            frgtHaulingEnrgyUse.Unload_Address__City__s = unloadAddress.get('Unload_Address__City__s');
            frgtHaulingEnrgyUse.Unload_Address__PostalCode__s = unloadAddress.get('Unload_Address__PostalCode__s');
            frgtHaulingEnrgyUse.Unload_Address__CountryCode__s = unloadAddress.get('Unload_Address__CountryCode__s');

            // Set other standard fields
            frgtHaulingEnrgyUse.Name = 'Test Record ' + i;
            frgtHaulingEnrgyUse.Transport_Type__c = 'Outbound';
            frgtHaulingEnrgyUse.Scope3EmssnSrcId = scope3emSource.Id;
            frgtHaulingEnrgyUse.Distance = i == 0 ? 10 : 0;
            if (i == 2) {
                frgtHaulingEnrgyUse.Failed_Distance_Calculation__c = true;
            }

            // Add the record to the list
            frgtHaulingEnrgyUseList.add(frgtHaulingEnrgyUse);
        }
        insert frgtHaulingEnrgyUseList;

        Test.startTest();

        // Call the method
        Map<String, Integer> result = FrgtHaulingEnrgyUseDistanceProcessing.getFrgtHaulingEnrgyUseStats();

        Test.stopTest();

        // Assertions
        System.assertEquals(1, result.get('NumberOfRecordsWithZeroDistance'));
        System.assertEquals(1, result.get('NumberOfRecordsWithIssuesAndZeroDistance'));
    }

    // Handles inaccessible FrgtHaulingEnrgyUse object gracefully
    @isTest
    private static void testInaccessibleFrgtHaulingEnrgyUseObject() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testInaccessibleFrgtHaulingEnrgyUseObject@testorg.com');

        Test.startTest();

        Map<String, Integer> result = new Map<String, Integer>();
        
        System.runAs(u) {
            // Call the method
            result = FrgtHaulingEnrgyUseDistanceProcessing.getFrgtHaulingEnrgyUseStats();
        }
        
        // Assertions
        System.assertEquals(-1, result.get('NumberOfRecordsWithZeroDistance'));
        System.assertEquals(-1, result.get('NumberOfRecordsWithIssuesAndZeroDistance'));
        
        Test.stopTest();
    }

    // Handle case when TotalJobItems is 0
    @isTest
    private static void testGetBatchJobProgressWithZeroTotalItems() {
        // Arrange
        List<AsyncApexJob> asyncJobs = new List<AsyncApexJob>{
            new AsyncApexJob()
        };

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AsyncApexJobSelector asyncApexJobSelector = (AsyncApexJobSelector)mocks.mock(AsyncApexJobSelector.class);
        String batchJobTriggeredName = 'FrgtHaulingEnrgyUseDistanceCalcBatch';

        Test.startTest();

        // Act
        Integer progress = FrgtHaulingEnrgyUseDistanceProcessing.getBatchJobProgress(batchJobTriggeredName);

        Test.stopTest();

        // Assert
        System.assertEquals(-1, progress, 'Progress should be -1 when total items is 0');
    }

    // Handle case when TotalJobItems is 0
    @isTest
    private static void testGetBatchJobProgressWithOneItemWith50PercentJobs() {
        // Arrange

        // Constructing a mock AsyncApexJob record
        String jobJson = '{"attributes":{"type":"AsyncApexJob"},"TotalJobItems":10,"JobItemsProcessed":5,"Status":"Processing"}';
        AsyncApexJob fakeJob = (AsyncApexJob)JSON.deserialize(jobJson, AsyncApexJob.class);

        List<AsyncApexJob> asyncJobs = new List<AsyncApexJob>{fakeJob};

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AsyncApexJobSelector asyncApexJobSelector = (AsyncApexJobSelector)mocks.mock(AsyncApexJobSelector.class);

        mocks.startStubbing();
        mocks.when(asyncApexJobSelector.sObjectType()).thenReturn(Schema.AsyncApexJob.SObjectType);
        mocks.when(asyncApexJobSelector.getActiveAsyncJobsByApexClassName('FrgtHaulingEnrgyUseDistanceCalcBatch')).thenReturn(asyncJobs);
        mocks.stopStubbing();

        NetZeroApplication.Selector.setMock(asyncApexJobSelector);
        String batchJobTriggeredName = 'FrgtHaulingEnrgyUseDistanceCalcBatch';

        Test.startTest();

        // Act
        Integer progress = FrgtHaulingEnrgyUseDistanceProcessing.getBatchJobProgress(batchJobTriggeredName);

        Test.stopTest();

        // Assert
        System.assertEquals(50, progress, 'Progress should be 50 when total items is 5/10');
    }

    @isTest
    private static void testGetBatchJobProgressWithOneItemWith0PercentJobs() {
        // Arrange
        List<AsyncApexJob> asyncJobs = new List<AsyncApexJob>{
            new AsyncApexJob()
        };

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AsyncApexJobSelector asyncApexJobSelector = (AsyncApexJobSelector)mocks.mock(AsyncApexJobSelector.class);

        mocks.startStubbing();
        mocks.when(asyncApexJobSelector.sObjectType()).thenReturn(Schema.AsyncApexJob.SObjectType);
        mocks.when(asyncApexJobSelector.getActiveAsyncJobsByApexClassName('FrgtHaulingEnrgyUseDistanceCalcBatch')).thenReturn(asyncJobs);
        mocks.stopStubbing();

        NetZeroApplication.Selector.setMock(asyncApexJobSelector);
        String batchJobTriggeredName = 'FrgtHaulingEnrgyUseDistanceCalcBatch';

        Test.startTest();

        // Act
        Integer progress = FrgtHaulingEnrgyUseDistanceProcessing.getBatchJobProgress(batchJobTriggeredName);

        Test.stopTest();

        // Assert
        System.assertEquals(0, progress, 'Progress should be 0 when total items is 0');
    }

    @isTest
    static void testInaccessibleAsyncApexJob() {
        // Query the Minimal Access profile
        Profile minimalProfile = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' LIMIT 1];

        User restrictedUser = new User(
            Username = 'restrictedUser@test.com',
            LastName = 'Restricted',
            Email = 'restrictedUser@test.com',
            Alias = 'restr',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = minimalProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert restrictedUser;

        System.runAs(restrictedUser) {
            Boolean caughtException1 = false;
            Boolean caughtException2 = false;

            try {
                FrgtHaulingEnrgyUseDistanceProcessing.isFreightHaulingEnergyUseProcessingRunning();
                System.assert(false, 'Expected an exception to be thrown.');
            } catch (AuraHandledException e) {
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception message to be "Script-thrown exception"');
                caughtException1 = true;
            }

            try {
                String batchJobTriggeredName = 'FrgtHaulingEnrgyUseDistanceCalcBatch';
                FrgtHaulingEnrgyUseDistanceProcessing.getBatchJobProgress(batchJobTriggeredName);
                System.assert(false, 'Expected an exception to be thrown.');
            } catch (AuraHandledException e) {
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception message to be "Script-thrown exception"');
                caughtException2 = true;
            }

            System.assertEquals(true, caughtException1, 'Expected to catch exception for isFreightHaulingEnergyUseProcessingRunning()');
            System.assertEquals(true, caughtException2, 'Expected to catch exception for getBatchJobProgress()');
        }
    }

    // Successfully creates and executes FrgtHaulingEnrgyUseClearFailureFlagBatch job
    @isTest
    private static void test_trigger_clear_failure_flag_success() {
        Test.startTest();

        FrgtHaulingEnrgyUseDistanceProcessing.triggerClearFailureFlag();

        Test.stopTest();

        List<AsyncApexJob> jobs = [
            SELECT Id, Status, ApexClass.Name 
            FROM AsyncApexJob 
            WHERE ApexClass.Name = 'FrgtHaulingEnrgyUseClearFailureFlagBatch'
            AND JobType = 'BatchApex'
        ];

        System.assertEquals(1, jobs.size(), 'One batch job should be created');
        System.assertEquals('Completed', jobs[0].Status, 'Batch job should complete successfully');
    }

}