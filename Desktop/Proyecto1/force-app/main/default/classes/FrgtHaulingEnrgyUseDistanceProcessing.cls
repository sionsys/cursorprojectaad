public with sharing class FrgtHaulingEnrgyUseDistanceProcessing {
    private static final String PERMISSION_SET_NAME = 'Net_Zero_Cloud_Distance_Calculation';

    @AuraEnabled
    public static Boolean isFreightHaulingEnergyUseProcessingRunning(){
        try {
            List<AsyncApexJob> runningJobs;
            if (Schema.sObjectType.AsyncApexJob.isAccessible()) {
                runningJobs = AsyncApexJobSelector.newInstance().getActiveAsyncJobsByApexClassName('FrgtHaulingEnrgyUseDistanceCalcBatch');
            } else {
                Logger.warn('AsyncApexJob object is not accessible.').addTag('FrgtHaulingEnrgyUseDistanceProcessing');
                Logger.saveLog();
                throw new AuraHandledException('AsyncApexJob object is not accessible.');
            }
            if (!runningJobs.isEmpty()) {
                return true;
            } else {
                return false;
            }
        } catch (Exception e) {
            Logger.warn('Exception: ' + e.getMessage(), e).addTag('FrgtHaulingEnrgyUseDistanceProcessing');
            Logger.saveLog();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void triggerDistanceCalculation(){
        try {
            FrgtHaulingEnrgyUseDistanceCalcBatch batchJob = new FrgtHaulingEnrgyUseDistanceCalcBatch();
            Database.executeBatch(batchJob,90);
        } catch (Exception e) {
            Logger.warn('Exception: ' + e.getMessage(), e).addTag('FrgtHaulingEnrgyUseDistanceProcessing');
            Logger.saveLog();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String,Integer> getFrgtHaulingEnrgyUseStats(){
        try {
            // query for FrgtHaulingEnrgyUse and count the records with Distance = 0
            FrgtHaulingEnrgyUseSelector frgtHaulingEnrgyUseSelector = FrgtHaulingEnrgyUseSelector.newInstance();
            Integer countOfRecordsWithZeroDistance = frgtHaulingEnrgyUseSelector.getCountOfRecordsWithZeroDistance();
            Integer numberOfRecordsWithIssuesAndZeroDistance = frgtHaulingEnrgyUseSelector.getCountOfRecordsWithIssuesAndZeroDistance();

            // map with results
            Map<String,Integer> results = new Map<String,Integer>();
            results.put('NumberOfRecordsWithZeroDistance', countOfRecordsWithZeroDistance);
            results.put('NumberOfRecordsWithIssuesAndZeroDistance', numberOfRecordsWithIssuesAndZeroDistance);

            return results;
        } catch (Exception e) {
            Logger.warn('Exception: ' + e.getMessage(), e).addTag('FrgtHaulingEnrgyUseDistanceProcessing');
            Logger.saveLog();
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Integer getBatchJobProgress(String batchJobName) {
        List<AsyncApexJob> runningJobs;
        if (Schema.sObjectType.AsyncApexJob.isAccessible()) {
            runningJobs = AsyncApexJobSelector.newInstance().getActiveAsyncJobsByApexClassName(batchJobName);
        } else {
            Logger.warn('AsyncApexJob object is not accessible.').addTag('FrgtHaulingEnrgyUseDistanceProcessing');
            Logger.saveLog();
            throw new AuraHandledException('AsyncApexJob object is not accessible.');
        }

        if (runningJobs.isEmpty()) {
            return -1;
        }
    
        if (!runningJobs.isEmpty()) {
            AsyncApexJob job = runningJobs[0];
            if (job.TotalJobItems > 0) {
                return Math.min(100, (job.JobItemsProcessed * 100) / job.TotalJobItems);
            }

            return 0;
        }

        return -2;
    }

    @AuraEnabled
    public static void triggerClearFailureFlag(){
        try {
            FrgtHaulingEnrgyUseClearFailureFlagBatch batchJob = new FrgtHaulingEnrgyUseClearFailureFlagBatch();
            Database.executeBatch(batchJob);
        } catch (Exception e) {
            Logger.warn('Exception: ' + e.getMessage(), e).addTag('FrgtHaulingEnrgyUseClearFailureFlagBatch');
            Logger.saveLog();
            throw new AuraHandledException(e.getMessage());
        }
    }
}