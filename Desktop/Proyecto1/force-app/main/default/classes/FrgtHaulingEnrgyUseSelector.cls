public with sharing class FrgtHaulingEnrgyUseSelector extends fflib_SObjectSelector {
    
    public static FrgtHaulingEnrgyUseSelector newInstance(){
		return (FrgtHaulingEnrgyUseSelector) NetZeroApplication.Selector.newInstance(FrgtHaulingEnrgyUse.SObjectType);
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
            FrgtHaulingEnrgyUse.Id
        };
    }

    public Schema.SObjectType getSObjectType() {
        return FrgtHaulingEnrgyUse.sObjectType;
    }

    public Integer getCountOfRecordsWithZeroDistance() {
        if (Schema.sObjectType.FrgtHaulingEnrgyUse.isAccessible()) {
            return [SELECT COUNT() 
                        FROM FrgtHaulingEnrgyUse 
                        WHERE Distance = 0
                            AND Failed_Distance_Calculation__c != true];
        } else {
            return -1;
        }
    }
    
    public Integer getCountOfRecordsWithIssuesAndZeroDistance() {
        if (Schema.sObjectType.FrgtHaulingEnrgyUse.isAccessible()) {
            return [SELECT COUNT() 
                        FROM FrgtHaulingEnrgyUse 
                        WHERE Distance = 0 
                            AND Failed_Distance_Calculation__c = true];
        } else {
            return -1;
        }
    }

}