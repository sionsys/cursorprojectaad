@IsTest
public with sharing class AsyncApexJobSelectorTest {
    
    // Create a new instance of CPQ_QuoteSelector successfully
    @isTest
    private static void testCreateNewInstanceSuccessfully() {        
        // Act
        AsyncApexJobSelector result = AsyncApexJobSelector.newInstance();
        
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
        AsyncApexJobSelector selector = AsyncApexJobSelector.newInstance();
        queryFactory = selector.getRelatedFields(fields, queryFactory);
        
        // Assert
        System.assert(queryFactory.getSelectedFields().contains('Parent.Name'));
        System.assert(queryFactory.getSelectedFields().contains('Parent.Industry'));
    }

    // Returns a list containing AsyncApexJob.Id and AsyncApexJob.Status
    @isTest
    private static void returnsListWithAsyncApexJobFields() {
        // Arrange
        AsyncApexJobSelector selector = new AsyncApexJobSelector();
        
        // Act
        List<Schema.SObjectField> result = selector.getSObjectFieldList();
        
        // Assert
        System.assertEquals(4, result.size());
        System.assertEquals(AsyncApexJob.Id, result[0]);
        System.assertEquals(AsyncApexJob.Status, result[1]);
        System.assertEquals(AsyncApexJob.JobItemsProcessed, result[2]);
        System.assertEquals(AsyncApexJob.TotalJobItems, result[3]);
    }

    // Retrieves active async jobs with specific Apex class name
    @isTest
    private static void retrievesActiveAsyncJobsWithSpecificApexClassName() {
        // Setup test data
        AsyncApexJob job1 = new AsyncApexJob();
        List<AsyncApexJob> jobs = new List<AsyncApexJob>{job1};

        // Create a mock selector
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        AsyncApexJobSelector mockApexJobSelector = (AsyncApexJobSelector)mocks.mock(AsyncApexJobSelector.class);
        
        mocks.startStubbing();
        mocks.when(mockApexJobSelector.sObjectType()).thenReturn(Schema.AsyncApexJob.SObjectType);
        mocks.when(mockApexJobSelector.getActiveAsyncJobsByApexClassName('FrgtHaulingEnrgyUseDistanceCalcBatch')).thenReturn(jobs);
        mocks.when(mockApexJobSelector.getActiveAsyncJobsByApexClassName('OtherClassName')).thenReturn(new List<AsyncApexJob>());
        mocks.stopStubbing();

        NetZeroApplication.Selector.setMock(mockApexJobSelector);

        // Execute method
        AsyncApexJobSelector selector = AsyncApexJobSelector.newInstance();
        List<AsyncApexJob> result = selector.getActiveAsyncJobsByApexClassName('FrgtHaulingEnrgyUseDistanceCalcBatch');
        List<AsyncApexJob> otherClassResult = selector.getActiveAsyncJobsByApexClassName('OtherClassName');

        // Verify results
        System.assertEquals(1, result.size());
        System.assertEquals(0, otherClassResult.size());
    }
}