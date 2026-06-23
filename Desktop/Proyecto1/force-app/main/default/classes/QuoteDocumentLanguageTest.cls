@isTest
public class QuoteDocumentLanguageTest {

    @isTest
    static void testGetMostCommonLanguageTemplate() {
        List<Contact> contacts = new List<Contact>{
            new Contact(Language__c = 'English', LastName = 'Test', Email = 'testemail@example.com'),
            new Contact(Language__c = 'English', LastName = 'Test', Email = 'testemail@example.com'),
            new Contact(Language__c = 'French', LastName = 'Test', Email = 'testemail@example.com')
        };
        
        List<Conga_Template_Mapping__mdt> templates = new List<Conga_Template_Mapping__mdt>{
            new Conga_Template_Mapping__mdt(Language__c = 'English', DeveloperName = 'English_Template'),
            new Conga_Template_Mapping__mdt(Language__c = 'French', DeveloperName = 'French_Template')
        };

        QuoteDocumentLanguage.RequestWrapper request = new QuoteDocumentLanguage.RequestWrapper();
        request.contacts = contacts;
        request.templates = templates;
        List<QuoteDocumentLanguage.RequestWrapper> requests = new List<QuoteDocumentLanguage.RequestWrapper>{request};

        Test.startTest();
        	List<QuoteDocumentLanguage.ResponseWrapper> responses = QuoteDocumentLanguage.getMostCommonLanguageTemplate(requests);
        Test.stopTest();
        
        Assert.areEqual(1, responses.size(), 'Should have one response');
        Assert.isNotNull(responses[0].selectedTemplate, 'Selected template should not be null');
        Assert.areEqual('English_Template', responses[0].selectedTemplate.DeveloperName, 'The most common language template should be English');
    }

    @isTest
    static void testNoCommonLanguageTemplate() {
        List<Contact> contacts = new List<Contact>{
            new Contact(Language__c = 'German', LastName = 'Test', Email = 'testemail@example.com')
        };
        List<Conga_Template_Mapping__mdt> templates = new List<Conga_Template_Mapping__mdt>{
            new Conga_Template_Mapping__mdt(Language__c = 'Spanish', DeveloperName = 'Spanish_Template')
        };

        QuoteDocumentLanguage.RequestWrapper request = new QuoteDocumentLanguage.RequestWrapper();
        request.contacts = contacts;
        request.templates = templates;
        List<QuoteDocumentLanguage.RequestWrapper> requests = new List<QuoteDocumentLanguage.RequestWrapper>{request};

        Test.startTest();
        	List<QuoteDocumentLanguage.ResponseWrapper> responses = QuoteDocumentLanguage.getMostCommonLanguageTemplate(requests);
        Test.stopTest();
        
        Assert.areEqual(1, responses.size(), 'Should have one response');
    }
}