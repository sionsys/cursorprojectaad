public class FrgtHaulingEnrgyUseClearFailureFlagBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        // Check if the user has the required custom permission, this should help us to avoid the scenario 
        // when a not authorized user starts the batch job and consumes the API calls from costly services
        if (!FeatureManagement.checkPermission('Can_View_Freight_Hauling_Energy_Use_Distance_Processing_LWC')
                && Test.isRunningTest() == false) {
            throw new AsyncException('You do not have permission to start this batch job.');
        }

        return Database.getQueryLocator(
                [SELECT Id
                FROM FrgtHaulingEnrgyUse 
                WHERE Distance = 0 
                    AND Failed_Distance_Calculation__c = true
                ORDER BY CarbonFootprintReportDate ASC]
            );
    }

    public void execute(Database.BatchableContext context, List<FrgtHaulingEnrgyUse> energyUseRecordsList) {
        this.processRecords(energyUseRecordsList);
    }

    @TestVisible
    private void processRecords(List<FrgtHaulingEnrgyUse> energyUseRecordsList) {
        for (FrgtHaulingEnrgyUse energyUseRecord : energyUseRecordsList) {
            energyUseRecord.Failed_Distance_Calculation__c = false;
        }
        update energyUseRecordsList;
    }

    public void finish(Database.BatchableContext context) {
        // nothing to do here
    }

}