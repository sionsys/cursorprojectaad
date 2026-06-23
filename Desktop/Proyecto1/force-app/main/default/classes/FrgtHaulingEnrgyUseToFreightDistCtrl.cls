public with sharing class FrgtHaulingEnrgyUseToFreightDistCtrl {
    
    public class FreightDistanceData {
        @AuraEnabled public String externalId;
        @AuraEnabled public String linkToFreightDistance;
        @AuraEnabled public String freightDistanceName;
        @AuraEnabled public Decimal distanceValue;
        @AuraEnabled public Datetime createdDate;
    }

    @AuraEnabled(cacheable=true)
    public static FreightDistanceData getFreightDistanceData(Id recordId) {
        FrgtHaulingEnrgyUseForCacheSelector frgtHaulingEnrgyUseForCacheSelector = FrgtHaulingEnrgyUseForCacheSelector.newInstance();
        FrgtHaulingEnrgyUse frgtHaulingEnrgyUseRecord = frgtHaulingEnrgyUseForCacheSelector.selectById(recordId);

        FreightDistanceData data = new FreightDistanceData();
        
        if (frgtHaulingEnrgyUseRecord == null) {
            return data;
        } 

        String externalId = FreightDistanceService.buildExternalId(frgtHaulingEnrgyUseRecord.FreightHaulingMode, frgtHaulingEnrgyUseRecord.Load_Address__c, frgtHaulingEnrgyUseRecord.Unload_Address__c);

        FreightDistanceSelector frDistSelector = FreightDistanceSelector.newInstance();
        Freight_Distance__c freightDistance = frDistSelector.selectOneFreightDistanceByAddressesAndFreightHaulingMode(
                                                                            frgtHaulingEnrgyUseRecord.FreightHaulingMode,
                                                                            frgtHaulingEnrgyUseRecord.Load_Address__c, 
                                                                            frgtHaulingEnrgyUseRecord.Unload_Address__c
                                                                        );

        Id i = freightDistance?.Id;
        String href = URL.getOrgDomainUrl().toExternalForm() + '/' + i;
        
        // Replace with actual logic to fetch data using recordId
        data.externalId = externalId;
        data.linkToFreightDistance = freightDistance == null ? null : href;
        data.freightDistanceName = freightDistance?.Name;
        data.distanceValue = freightDistance?.Distance__c;
        data.createdDate = freightDistance?.CreatedDate;
        return data;
    }

}