@IsTest
public with sharing class FrgtHaulingEnrgyUseClrFailFlgBatchTest {

    @testSetup
    static void setup() {
        NetZeroTestDataFactory.createFreightHaulingEnergyUseRecordsForBatch(true);
    }
    
    // Updates Failed_Distance_Calculation__c to false for all records in the input list
    @isTest
    private static void processRecordsShouldUpdateFailureFlagToFalse() {
        // Arrange
        FrgtHaulingEnrgyUseClearFailureFlagBatch batch = new FrgtHaulingEnrgyUseClearFailureFlagBatch();
        
        List<FrgtHaulingEnrgyUse> testRecords = [SELECT Id FROM FrgtHaulingEnrgyUse];
        
        // Act
        Test.startTest();
        batch.processRecords(testRecords);
        Test.stopTest();
        
        // Assert
        List<FrgtHaulingEnrgyUse> updatedRecords = [SELECT Failed_Distance_Calculation__c 
                                                    FROM FrgtHaulingEnrgyUse 
                                                    WHERE Id IN :testRecords];
        
        System.assertEquals(10, updatedRecords.size(), 'Should have 10 records');
        for(FrgtHaulingEnrgyUse record : updatedRecords) {
            System.assertEquals(false, record.Failed_Distance_Calculation__c, 
                            'Failed_Distance_Calculation__c should be false');
        }
    }

    @IsTest
    private static void testBatch() {
        Test.startTest();
        Database.executeBatch(new FrgtHaulingEnrgyUseClearFailureFlagBatch(), 200);
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