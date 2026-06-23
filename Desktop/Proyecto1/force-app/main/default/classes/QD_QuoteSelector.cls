public with sharing class QD_QuoteSelector extends fflib_SObjectSelector {
    
    public static QD_QuoteSelector newInstance(){
		return (QD_QuoteSelector) QD_Application.Selector.newInstance(SBQQ__Quote__c.SObjectType);
	}

    public virtual List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField>();
	}

    public Schema.SObjectType getSObjectType() {
        return SBQQ__Quote__c.sObjectType;
    }

    public SBQQ__Quote__c selectOneById(Id quoteId) {
        Set<String> fieldsToReturn = new Set<String> { 'Id', 'Name', 'SBQQ__PrimaryContact__r.Email' };
        fflib_QueryFactory quoteQuery = newQueryFactory(false)
                                    .selectFields(fieldsToReturn)
                                    .setCondition(SBQQ__Quote__c.Id + ' = :quoteId')
                                    .setLimit(1);
        String quoteQueryString = quoteQuery.toSOQL();
        return (SBQQ__Quote__c) Database.query(quoteQueryString);
    }
}