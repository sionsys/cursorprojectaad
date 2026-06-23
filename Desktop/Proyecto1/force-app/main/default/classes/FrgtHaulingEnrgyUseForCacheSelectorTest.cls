@IsTest
public with sharing class FrgtHaulingEnrgyUseForCacheSelectorTest {

    @IsTest
    static void testNewInstance() {
        Test.startTest();
        FrgtHaulingEnrgyUseForCacheSelector selector = FrgtHaulingEnrgyUseForCacheSelector.newInstance();
        Test.stopTest();
        System.assertNotEquals(null, selector, 'Selector instance should not be null');
    }

    @IsTest
    static void testGetRelatedFields() {
        // Arrange
        Map<Schema.SObjectField, List<Schema.SObjectField>> fields = new Map<Schema.SObjectField, List<Schema.SObjectField>>();
        Schema.SObjectField parentField = Account.ParentId;
        Schema.SObjectField childField1 = Account.Name;
        Schema.SObjectField childField2 = Account.Industry;
        fields.put(parentField, new List<Schema.SObjectField>{childField1, childField2});
        
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Account.SObjectType);
        
        // Act
        FrgtHaulingEnrgyUseForCacheSelector selector = FrgtHaulingEnrgyUseForCacheSelector.newInstance();
        queryFactory = selector.getRelatedFields(fields, queryFactory);
        
        // Assert
        System.assert(queryFactory.getSelectedFields().contains('Parent.Name'));
        System.assert(queryFactory.getSelectedFields().contains('Parent.Industry'));
    }

    @IsTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        FrgtHaulingEnrgyUseForCacheSelector selector = FrgtHaulingEnrgyUseForCacheSelector.newInstance();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();
        Test.stopTest();
        System.assert(fields.contains(FrgtHaulingEnrgyUse.Id), 'Field list should contain Id');
        System.assert(fields.contains(FrgtHaulingEnrgyUse.FreightHaulingMode), 'Field list should contain FreightHaulingMode');
    }

    @IsTest
    static void testGetSObjectType() {
        Test.startTest();
        FrgtHaulingEnrgyUseForCacheSelector selector = FrgtHaulingEnrgyUseForCacheSelector.newInstance();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Test.stopTest();
        System.assertEquals(FrgtHaulingEnrgyUse.sObjectType, sObjectType, 'SObjectType should match FrgtHaulingEnrgyUse.sObjectType');
    }

    @IsTest
    static void testSelectById() {
        FrgtHaulingEnrgyUse frgtHaulingEnrgyUseRecord = new FrgtHaulingEnrgyUse(Id = '0orKL00000004v3YAA', Distance = 0);

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        FrgtHaulingEnrgyUseForCacheSelector mockFrgHaulEnrUseSelector = (FrgtHaulingEnrgyUseForCacheSelector)mocks.mock(FrgtHaulingEnrgyUseForCacheSelector.class);

        mocks.startStubbing();
        mocks.when(mockFrgHaulEnrUseSelector.sObjectType()).thenReturn(Schema.FrgtHaulingEnrgyUse.SObjectType);
        mocks.when(mockFrgHaulEnrUseSelector.selectById('0orKL00000004v3YAA')).thenReturn(frgtHaulingEnrgyUseRecord);
        mocks.stopStubbing();

        NetZeroDistanceCacheApplication.Selector.setMock(mockFrgHaulEnrUseSelector);

        Test.startTest();
        FrgtHaulingEnrgyUseForCacheSelector selector = FrgtHaulingEnrgyUseForCacheSelector.newInstance();
        FrgtHaulingEnrgyUse result = selector.selectById('0orKL00000004v3YAA');
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(frgtHaulingEnrgyUseRecord.Id, result.Id, 'Ids should match');
    }

    
}