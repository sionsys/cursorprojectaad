public with sharing class FrgtHaulingEnrgyUseForCacheSelector extends fflib_SObjectSelector {
    
    public static FrgtHaulingEnrgyUseForCacheSelector newInstance(){
		return (FrgtHaulingEnrgyUseForCacheSelector) NetZeroDistanceCacheApplication.Selector.newInstance(FrgtHaulingEnrgyUse.SObjectType);
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
            FrgtHaulingEnrgyUse.Id,
            FrgtHaulingEnrgyUse.FreightHaulingMode,
            FrgtHaulingEnrgyUse.Load_Address__c,
            FrgtHaulingEnrgyUse.Unload_Address__c
        };
    }

    public Schema.SObjectType getSObjectType() {
        return FrgtHaulingEnrgyUse.sObjectType;
    }

    public FrgtHaulingEnrgyUse selectById(String id) {
        // String soql = newQueryFactory()
        //                 .setCondition(FrgtHaulingEnrgyUse.Id + ' = :id')
        //                 .toSOQL();

		// List<FrgtHaulingEnrgyUse> queryResult = (List<FrgtHaulingEnrgyUse>)Database.query(soql);

        List<FrgtHaulingEnrgyUse> queryResult = [SELECT Id, FreightHaulingMode, Load_Address__c, Unload_Address__c
                                                 FROM FrgtHaulingEnrgyUse
                                                 WHERE Id = :id];

        return queryResult.size() > 0 ? queryResult[0] : null;
	}

}