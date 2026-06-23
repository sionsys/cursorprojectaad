public with sharing class QuoteDocumentLanguage {
    public class RequestWrapper {
        @InvocableVariable
        public List<Contact> contacts;

        @InvocableVariable
        public List<Conga_Template_Mapping__mdt> templates;
    }
    
    public class ResponseWrapper {
        @InvocableVariable
        public Conga_Template_Mapping__mdt selectedTemplate;
    }

    @InvocableMethod(label='Get Most Common Language Template' description='Returns the template matching the most common language among given contacts')
    public static List<ResponseWrapper> getMostCommonLanguageTemplate(List<RequestWrapper> requests) {
        List<ResponseWrapper> responses = new List<ResponseWrapper>();
        for(RequestWrapper request : requests) {
            ResponseWrapper response = new ResponseWrapper();
            Conga_Template_Mapping__mdt selectedTemplate = null;
            Map<String, Integer> languageCount = new Map<String, Integer>();
            if (request.contacts?.size() > 0) {
                for (Contact contact : request.contacts) {
                    String language = contact.Language__c;
                    if (language != null) {
                        languageCount.put(language, languageCount.get(language) == null ? 1 : languageCount.get(language) + 1);
                    }
                }
    
                String mostCommonLanguage = '';
                Integer maxCount = 0;
                for (String language : languageCount.keySet()) {
                    if (languageCount.get(language) > maxCount) {
                        mostCommonLanguage = language;
                        maxCount = languageCount.get(language);
                    }
                }
                
                for (Conga_Template_Mapping__mdt template : request.templates) {
                    if (mostCommonLanguage.equals(template.Language__c)) {
                        selectedTemplate = template;
                        break;
                    }
                }
            }

            response.selectedTemplate = selectedTemplate == null ? request.templates[0] : selectedTemplate;
            responses.add(response);
        }

        return responses;
    }
}