public with sharing class NetZeroDistanceCacheApplication {
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = 
        new fflib_Application.UnitOfWorkFactory(
                new List<SObjectType> {
                    Freight_Distance__c.SObjectType,
                    FrgtHaulingEnrgyUse.SObjectType
                });	


    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service = 
        new fflib_Application.ServiceFactory( 
            new Map<Type, Type> {
                // CPQ_ConfiguratorQuoteLineGroupService.class => CPQ_ConfiguratorQuoteLineGroupService.class
            });

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = 
        new fflib_Application.SelectorFactory(
            new Map<SObjectType, Type> {
                Freight_Distance__c.SObjectType => FreightDistanceSelector.class,
                FrgtHaulingEnrgyUse.SObjectType => FrgtHaulingEnrgyUseForCacheSelector.class
            });

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain = 
        new fflib_Application.DomainFactory(
            NetZeroDistanceCacheApplication.Selector,
            new Map<SObjectType, Type> {
                // Patient_Measurement__c.SObjectType => CPQ_Patient_Measurements.class
            });
}