trigger FreightDistanceTrigger on Freight_Distance__c (before insert, before update) {

    fflib_SObjectDomain.triggerHandler(FreightDistance.class);

}