@isTest
public with sharing class OP_Product2SelectorTest {
    
    @isTest
    static void executeSelectorMethods() {
        Product2 testProduct = new CPQ_TestHelper.Product2Builder()
                                .build()
                                .withName('Test Product')
                                .save()
                                .getRecord();

        Test.startTest();
        OP_Product2Selector.newInstance().selectOneById(testProduct.Id);
        Test.stopTest();
    }
}