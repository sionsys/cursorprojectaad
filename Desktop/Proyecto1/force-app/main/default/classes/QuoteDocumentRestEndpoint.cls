@RestResource(urlMapping='/QuoteDocument/*')
global with sharing class QuoteDocumentRestEndpoint {
 
    global class QuoteDocServiceResponse {
        global Boolean isSuccess;
        global String message;
        global List<Id> enqueuedJobsIds;

        global QuoteDocServiceResponse(Boolean isSuccess, String message, List<Id> enqueuedJobsIds) {
            this.isSuccess = isSuccess;
            this.message = message;
            this.enqueuedJobsIds = enqueuedJobsIds;
        }
    }

    // In HTTP request to this enpoint - set request body as deserialized List<QuoteDocumentService.GenerateQuoteDocRequest>
    @HttpPost
    global static QuoteDocServiceResponse doPost() {
        String requestBody = RestContext.request.requestBody.toString();
        List<QuoteDocumentService.GenerateQuoteDocRequest> generateQuoteDocRequestParams = 
            (List<QuoteDocumentService.GenerateQuoteDocRequest>) JSON.deserialize(requestBody, List<QuoteDocumentService.GenerateQuoteDocRequest>.class);
        List<Id> enqueuedJobsIds = QuoteDocumentService.generateQuoteDocument(generateQuoteDocRequestParams);
        return new QuoteDocServiceResponse(true, 'Success', enqueuedJobsIds);
    }

}