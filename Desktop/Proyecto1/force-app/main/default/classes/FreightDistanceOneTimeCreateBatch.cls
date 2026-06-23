public with sharing class FreightDistanceOneTimeCreateBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext context) {
        // Define the query to fetch the records to be processed
        return Database.getQueryLocator([SELECT Id, 
                                                Load_Address__CountryCode__s, Load_Address__StateCode__s, Load_Address__PostalCode__s, Load_Address__City__s, Load_Address__Street__s, 
                                                Unload_Address__CountryCode__s, Unload_Address__StateCode__s, Unload_Address__PostalCode__s, Unload_Address__City__s, Unload_Address__Street__s, 
                                                FreightHaulingMode, Distance
                                            FROM FrgtHaulingEnrgyUse 
                                            WHERE Distance <> 0 
                                                AND Failed_Distance_Calculation__c != true
                                                AND Load_Address__CountryCode__s != null
                                                AND UnLoad_Address__CountryCode__s != null
                                            ORDER BY CarbonFootprintReportDate DESC]);
    }

    public void execute(Database.BatchableContext context, List<FrgtHaulingEnrgyUse> records) {
        List<Freight_Distance__c> freightDistanceList = new List<Freight_Distance__c>();

        // Process each batch of records
        for (FrgtHaulingEnrgyUse frghHaulingEnergyUse : records) {
            Freight_Distance__c freightDistance = FreightDistanceService.freightDistanceFromFrgtHaulingEnrgyUse(frghHaulingEnergyUse);
            freightDistanceList.add(freightDistance);
        }

        // we are not interested in the result of the insert, we expect errors related to duplicate external id values
        Database.insert(freightDistanceList, false);
    }

    public void finish(Database.BatchableContext context) {
        // Post-processing logic here
    }
}