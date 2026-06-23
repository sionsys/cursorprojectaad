public with sharing class FreightDistanceSelector extends fflib_SObjectSelector {
    
    public static FreightDistanceSelector newInstance(){
		return (FreightDistanceSelector) NetZeroDistanceCacheApplication.Selector.newInstance(Freight_Distance__c.SObjectType);
	}

    @TestVisible
    private virtual fflib_QueryFactory getRelatedFields(Map<Schema.SObjectField, List<Schema.SObjectField>> fields, 
                                                      fflib_QueryFactory queryFactory) {
    
        for(Schema.SObjectField relation : fields.keySet()) {
            for(Schema.SObjectField field : fields.get(relation)) {
                queryFactory.selectField(relation.getDescribe().getRelationshipName() + '.' + field.getDescribe().getName());
            }
        }
        return queryFactory;
    }

    public virtual List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Freight_Distance__c.Id,
            Freight_Distance__c.Name,
            Freight_Distance__c.Distance__c,
            Freight_Distance__c.Freight_Hauling_Mode__c,
            Freight_Distance__c.External_Id__c,
            Freight_Distance__c.CreatedDate
        };
    }

    public Schema.SObjectType getSObjectType() {
        return Freight_Distance__c.sObjectType;
    }

    public Freight_Distance__c selectOneFreightDistanceByAddressesAndFreightHaulingMode(String freightHaulingMode, Address loadAddress, Address unloadAddress) {
        String externalId = FreightDistanceService.buildExternalId(freightHaulingMode, loadAddress, unloadAddress);

        String soql = newQueryFactory()
                        .setCondition(Freight_Distance__c.External_Id__c + ' = :externalId')
                        .toSOQL();

		List<Freight_Distance__c> queryResult = (List<Freight_Distance__c>)Database.query(soql);

        return queryResult.size() > 0 ? queryResult[0] : null;
	}

}