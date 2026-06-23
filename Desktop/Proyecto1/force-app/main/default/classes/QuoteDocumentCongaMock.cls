public with sharing class QuoteDocumentCongaMock implements HttpCalloutMock {
    Integer statusCode;
    String body;
    
    public QuoteDocumentCongaMock() {
        this.statusCode = 200;
        this.body = '';
    }

    public QuoteDocumentCongaMock(Integer statusCode, String body) {
        this.statusCode = statusCode == null ? 200 : statusCode;
        this.body = body == null ? '' : body;
    }

    public HTTPResponse respond(HTTPRequest req) {
        COM_TestHelper.HttpResponseBuilder responseBuilder = new COM_TestHelper.HttpResponseBuilder().build();
        responseBuilder.withBody('ok').withStatusCode(this.statusCode).withBody(this.body);        
        return responseBuilder.getInstance();
    }


}