@isTest
private class GoogleMapsDistanceMatrixAPITest {
    
    @isTest
    static void testGetDistance() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        String destinationAddress = 'EINDHOVEN, 5651GH, NL';
        String sourceAddress = 'VOLDA, 6103, NO';
        
        // Call the method to test
        Test.startTest();
        Decimal calculatedDistance = GoogleMapsDistanceMatrixAPI.getDistanceInMeters(sourceAddress, destinationAddress);
        Test.stopTest();
        
        // Verify the result
        System.assertEquals(1816193, calculatedDistance);
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"destination_addresses":["EINDHOVEN, 5651GH, NL"],"origin_addresses":["VOLDA, 6103, NO"],"rows":[{"elements":[{"distance":{"text":"1816 km","value":1816193},"duration":{"text":"10 hours","value":36000},"status":"OK"}]}],"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceNoSuccess() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseNoSuccessGenerator());

        String destinationAddress = 'EINDHOVEN, 5651GH, NL';
        String sourceAddress = 'VOLDA, 6103, NO';
        
        // Call the method to test
        Test.startTest();
        try {
            Decimal calculatedDistance = GoogleMapsDistanceMatrixAPI.getDistanceInMeters(sourceAddress, destinationAddress);
            System.assert(false, 'Expected DistanceCalculationException was not thrown.');
        } catch (Exception e) {
            System.assertEquals('Invalid response status: REQUEST_DENIED - The provided API key is invalid.', e.getMessage());
        }
        Test.stopTest();
    }

    private class MockHttpResponseNoSuccessGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"destination_addresses":[],"origin_addresses":[],"rows":[],"status":"REQUEST_DENIED","error_message":"The provided API key is invalid."}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceNoAddressFound() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseNoAddressFoundGenerator());

        String destinationAddress = 'EINDHOVEN, 5651GH, NL';
        String sourceAddress = 'VOLDA, 6103, NO';
        
        // Call the method to test
        Test.startTest();
        try {
            Decimal calculatedDistance = GoogleMapsDistanceMatrixAPI.getDistanceInMeters(sourceAddress, destinationAddress);
            System.assert(false, 'Expected DistanceCalculationException was not thrown.');
        } catch (Exception e) {
            System.assertEquals('No elements found in the address section. Address not recognized.', e.getMessage());
        }
        Test.stopTest();
    }

    private class MockHttpResponseNoAddressFoundGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"destination_addresses":["Alligator Creek QLD 4816, Australia"],"origin_addresses":[""],"rows":[{"elements":[{"status":"NOT_FOUND"}]}],"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceNoRowsFound() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseNoRowsGenerator());

        String destinationAddress = 'EINDHOVEN, 5651GH, NL';
        String sourceAddress = 'VOLDA, 6103, NO';
        
        // Call the method to test
        Test.startTest();
        try {
            Decimal calculatedDistance = GoogleMapsDistanceMatrixAPI.getDistanceInMeters(sourceAddress, destinationAddress);
            System.assert(false, 'Expected DistanceCalculationException was not thrown.');
        } catch (Exception e) {
            System.assertEquals('No rows found in the response', e.getMessage());
        }
        Test.stopTest();
    }

    private class MockHttpResponseNoRowsGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"destination_addresses":["Alligator Creek QLD 4816, Australia"],"origin_addresses":[""],"rows":[],"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }


    @isTest
    static void testGetDistanceHTTPRequestFailureSuccess() {
        // Set up the mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseHTTPRequestFailureGenerator());

        String destinationAddress = 'EINDHOVEN, 5651GH, NL';
        String sourceAddress = 'VOLDA, 6103, NO';
        
        // Call the method to test
        Test.startTest();
        try {
            Decimal calculatedDistance = GoogleMapsDistanceMatrixAPI.getDistanceInMeters(sourceAddress, destinationAddress);
            System.assert(false, 'Expected DistanceCalculationException was not thrown.');
        } catch (Exception e) {
            System.assertEquals('Error: Bad Request 400\n response.getBody(): ', e.getMessage());
        }
        Test.stopTest();
    }

    private class MockHttpResponseHTTPRequestFailureGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('');
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            return res;
        }
    }
}