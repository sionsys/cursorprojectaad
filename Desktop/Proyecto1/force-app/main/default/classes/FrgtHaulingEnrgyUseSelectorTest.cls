@IsTest
public with sharing class FrgtHaulingEnrgyUseSelectorTest {
    
    // Create a new instance of CPQ_QuoteSelector successfully
    @isTest
    private static void testCreateNewInstanceSuccessfully() {        
        // Act
        FrgtHaulingEnrgyUseSelector result = FrgtHaulingEnrgyUseSelector.newInstance();
        
        // Assert
        System.assertNotEquals(null, result, 'The instance should not be null');
    }

    // Correctly adds related fields to the query factory
    @isTest
    private static void addRelatedFieldsToQueryFactory() {
        // Arrange
        Map<Schema.SObjectField, List<Schema.SObjectField>> fields = new Map<Schema.SObjectField, List<Schema.SObjectField>>();
        Schema.SObjectField parentField = Account.ParentId;
        Schema.SObjectField childField1 = Account.Name;
        Schema.SObjectField childField2 = Account.Industry;
        fields.put(parentField, new List<Schema.SObjectField>{childField1, childField2});
        
        fflib_QueryFactory queryFactory = new fflib_QueryFactory(Account.SObjectType);
        
        // Act
        FrgtHaulingEnrgyUseSelector selector = FrgtHaulingEnrgyUseSelector.newInstance();
        queryFactory = selector.getRelatedFields(fields, queryFactory);
        
        // Assert
        System.assert(queryFactory.getSelectedFields().contains('Parent.Name'));
        System.assert(queryFactory.getSelectedFields().contains('Parent.Industry'));
    }

    // Returns a list containing AsyncApexJob.Id and AsyncApexJob.Status
    @isTest
    private static void returnsListWithAsyncApexJobFields() {
        // Arrange
        FrgtHaulingEnrgyUseSelector selector = FrgtHaulingEnrgyUseSelector.newInstance();
        
        // Act
        List<Schema.SObjectField> result = selector.getSObjectFieldList();
        
        // Assert
        System.assertEquals(1, result.size());
        System.assertEquals(FrgtHaulingEnrgyUse.Id, result[0]);
    }

    // Returns correct count when there are records with zero distance
    @isTest
    private static void returnsCorrectCountWithZeroAndNonZeroDistance() {
        // Arrange
        List<FrgtHaulingEnrgyUse> zeroDistanceRecords = new List<FrgtHaulingEnrgyUse>{
            new FrgtHaulingEnrgyUse(Distance = 0),
            new FrgtHaulingEnrgyUse(Distance = 0)
        };
        List<FrgtHaulingEnrgyUse> nonzeroDistanceRecords = new List<FrgtHaulingEnrgyUse>{
            new FrgtHaulingEnrgyUse(Failed_Distance_Calculation__c = true)
        };

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        FrgtHaulingEnrgyUseSelector mockFrgHaulEnrUseSelector = (FrgtHaulingEnrgyUseSelector)mocks.mock(FrgtHaulingEnrgyUseSelector.class);
        
        mocks.startStubbing();
        mocks.when(mockFrgHaulEnrUseSelector.sObjectType()).thenReturn(Schema.FrgtHaulingEnrgyUse.SObjectType);
        mocks.when(mockFrgHaulEnrUseSelector.getCountOfRecordsWithZeroDistance()).thenReturn(2);
        mocks.when(mockFrgHaulEnrUseSelector.getCountOfRecordsWithIssuesAndZeroDistance()).thenReturn(1);
        mocks.stopStubbing();

        NetZeroApplication.Selector.setMock(mockFrgHaulEnrUseSelector);

        Test.startTest();
        FrgtHaulingEnrgyUseSelector selector = FrgtHaulingEnrgyUseSelector.newInstance();
        Integer zeroDistanceRecordsCount = selector.getCountOfRecordsWithZeroDistance();
        Integer nonzeroDistanceRecordsCount = selector.getCountOfRecordsWithIssuesAndZeroDistance();
        Test.stopTest();

        // Assert
        System.assertEquals(2, zeroDistanceRecordsCount, 'The count of records with zero distance should be 2');
        System.assertEquals(1, nonzeroDistanceRecordsCount, 'The count of records with zero distance should be 2');
    }

}