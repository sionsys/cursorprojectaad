public with sharing class AsyncApexJobSelector extends fflib_SObjectSelector {
    
    public static AsyncApexJobSelector newInstance(){
		return (AsyncApexJobSelector) NetZeroApplication.Selector.newInstance(AsyncApexJob.SObjectType);
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
            AsyncApexJob.Id,
            AsyncApexJob.Status,
            AsyncApexJob.JobItemsProcessed, 
            AsyncApexJob.TotalJobItems 
        };
    }

    public Schema.SObjectType getSObjectType() {
        return AsyncApexJob.sObjectType;
    }

    public List<AsyncApexJob> getActiveAsyncJobsByApexClassName(String apexClassName) {
        // Define the statuses to filter by
        Set<String> statuses = new Set<String>{'Processing', 'Preparing', 'Queued', 'Holding'};

        fflib_QueryFactory asyncJobQuery = newQueryFactory()
                                                .selectFields(getSObjectFieldList())
                                                .setCondition(AsyncApexJob.JobType + ' = \'BatchApex\' AND ' 
                                                                + 'ApexClass.Name = :apexClassName AND ' 
                                                                + AsyncApexJob.Status + ' IN :statuses');

        return (List<AsyncApexJob>) Database.query(asyncJobQuery.toSOQL());
    }

}