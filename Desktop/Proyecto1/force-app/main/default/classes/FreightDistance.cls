public with sharing class FreightDistance extends fflib_SObjectDomain {
    
    public FreightDistance(List<Freight_Distance__c> records) {
        super(records);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
    	public fflib_SObjectDomain construct(List<SObject> sObjectList) {
      		return new FreightDistance(sObjectList);
    	}
  	}

    public override void onBeforeInsert() {
        this.fillInExternalIDField(this.records);
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        this.fillInExternalIDField(this.records);
    }

    @TestVisible
    private void fillInExternalIDField(List<Freight_Distance__c> records) {
        for (Freight_Distance__c record : records) {
            record.External_Id__c = FreightDistanceService.buildExternalId(record);
        }
    }

    

}