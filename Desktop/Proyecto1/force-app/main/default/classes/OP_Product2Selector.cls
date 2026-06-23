public with sharing class OP_Product2Selector extends fflib_SObjectSelector {

    public static OP_Product2Selector newInstance(){
		return (OP_Product2Selector) OP_Application.Selector.newInstance(Product2.SObjectType);
	}
    
	public virtual List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField> {
				Product2.Id,
				Product2.Name,
				Product2.LevelA__c,
				Product2.External_ID__c,
                Product2.ProductCode,
                Product2.ProductNumber__c,
                Product2.HierachyLocation__c,
                Product2.IsAccessoryProduct__c,
                Product2.isPreSelected__c,
                Product2.Product_Size__c,
                Product2.Product_Size_Range__c,
                Product2.Side__c,
                Product2.ProductCategory__c,
                Product2.Additional_Information__c,
				Product2.Service_Product_Type__c,
				Product2.Is_Service_Product__c,
                Product2.comesFromIntegration__c,
                Product2.IsCustom__c,
                Product2.IsArm__c,
                Product2.Family
			};
	}

	public Schema.SObjectType getSObjectType() {
		return Product2.sObjectType;
	}

    public List<Product2> selectById(Set<ID> idSet) {
        return (List<Product2>) selectSObjectsById(idSet);
    }

    public Product2 selectOneById(ID idOfRecord) {
        List<Product2> get_product = this.selectById(new Set<Id> { idOfRecord });
        return get_product.size() > 0 ? get_product[0] : null;
    }
}