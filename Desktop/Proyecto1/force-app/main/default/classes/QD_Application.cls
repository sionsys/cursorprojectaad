public with sharing class QD_Application {
    
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UnitOfWork = new fflib_Application.UnitOfWorkFactory(
        new List<SObjectType> {
            SBQQ__Quote__c.SObjectType
        }
    ); 

    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory Service = new fflib_Application.ServiceFactory( 
        new Map<Type, Type> {}
    );

    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory Selector = new fflib_Application.SelectorFactory(
        new Map<SObjectType, Type> {
            SBQQ__Quote__c.SObjectType => QD_QuoteSelector.class
        }
    );

    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory Domain = new fflib_Application.DomainFactory(
        SRV_Application.Selector,
        new Map<SObjectType, Type> {}
    );

}