@isTest
public class DistanceToAPITest {
    
    // Mock successful response
    private class MockHttpResponseGeneratorSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String responseBody = '{"route":{"vincenty":512.34}}';
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceInMeters_Success() {
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());

        // Call the method
        Decimal distance = DistanceToAPI.getDistanceInMeters('Paris', 'France', 'Berlin', 'Germany');

        // Assert the distance is as expected (51234 meters)
        Decimal expectedDistance = 512340;
        System.assertEquals(expectedDistance, distance, 'Distance should be 512340 meters');
    }

    // Mock response with invalid JSON
    private class MockHttpResponseGeneratorInvalidJSON implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String responseBody = '{ "invalid": "json" }';
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceInMeters_InvalidJSON() {
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorInvalidJSON());

        try {
            Decimal distance = DistanceToAPI.getDistanceInMeters('Paris', 'FR', 'Berlin', 'DE');
            System.assert(false, 'Expected an exception to be thrown due to invalid JSON');
        } catch (DistanceToAPI.DistanceCalculationException e) {
            // Expected exception
        }
    }

    // Mock response with missing 'route' key
    private class MockHttpResponseGeneratorMissingRoute implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String responseBody = '{"someOtherKey":{}}';
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceInMeters_MissingRoute() {
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorMissingRoute());

        try {
            Decimal distance = DistanceToAPI.getDistanceInMeters('Paris', 'FR', 'Berlin', 'DE');
            System.assert(false, 'Expected an exception to be thrown due to missing route key');
        } catch (DistanceToAPI.DistanceCalculationException e) {
            // Expected exception
        }
    }

    // Mock response with status code not 200
    private class MockHttpResponseGeneratorErrorStatus implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setStatus('404 Not Found');
            res.setBody('');
            return res;
        }
    }

    @isTest
    static void testGetDistanceInMeters_ErrorStatus() {
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorErrorStatus());

        try {
            Decimal distance = DistanceToAPI.getDistanceInMeters('Paris', 'FR', 'Berlin', 'DE');
            System.assert(false, 'Expected an exception to be thrown due to HTTP error status');
        } catch (DistanceToAPI.DistanceCalculationException e) {
            // Expected exception
        }
    }

    // Mock response with missing 'route' key
    private class MockHttpResponseGeneratorMissingRouteVincenty implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String responseBody = '{"route":{"anotherKey":51234}}';
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testGetDistanceInMeters_MissingRouteVincenty() {
        // Set the mock
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorMissingRouteVincenty());

        try {
            Decimal distance = DistanceToAPI.getDistanceInMeters('Paris', 'FR', 'Berlin', 'DE');
            System.assert(false, 'Expected an exception to be thrown due to missing route key');
        } catch (DistanceToAPI.DistanceCalculationException e) {
            // Expected exception
        }
    }

}