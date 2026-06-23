@IsTest
public class SearatesDistanceAndTimeAPITest {

    // Mock class for a successful response
    private class MockHttpResponseGeneratorSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake successful response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String responseBody = '{"success": true, "status_code": "OK", "metadata": { "request_parameters": { "from": "Madrid, Spain", "to": "Ibiza, Spain", "transport_modes": "ROAD", "alternative_routes": false, "routing_mode": "short" } }, "data": { "route": { "summary": { "duration": 47730, "distance": 530342, "speed": 40 }, "from": { "description": "Madrid, Comunidad de Madrid, Spain", "name": "Madrid", "state": "Comunidad de Madrid", "country": "Spain", "country_code": "ES", "locode": "ESMAD", "lat": 40.4165, "lng": -3.70256 }, "to": { "description": "Santa Eularia des Riu, Comunitat Autonoma de les Illes Balears, Spain", "name": "Santa Eularia des Riu", "state": "Comunitat Autonoma de les Illes Balears", "country": "Spain", "country_code": "ES", "locode": "ESSTE", "lat": 38.98457, "lng": 1.53409 }, "sections": [] }, "alternative_routes": [] } }';
            res.setBody(responseBody);
            return res;
        }
    }

    // Mock class for a successful response another real example from the API
    private class MockHttpResponseGeneratorSuccessSecondExample implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake successful response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String responseBody = '{"success":true,"status_code":"OK","metadata":{"request_parameters":{"from":"HK, 999077, HONG KONG","to":"MX, 22203, TIJUANA","transport_modes":"SEA,ROAD","alternative_routes":false,"routing_mode":"short"}},"data":{"route":{"summary":{"duration":1714590,"distance":12382632,"speed":26},"from":{"description":"Mong Kok, Yau Tsim Mong, Hong Kong","name":"Mong Kok","state":"Yau Tsim Mong","country":"Hong Kong","country_code":"HK","locode":"HKMKK","lat":22.31935,"lng":114.17136},"to":{"description":"Tijuana, Estado de Baja California, Mexico","name":"Tijuana","state":"Estado de Baja California","country":"Mexico","country_code":"MX","locode":"MXTIJ","lat":32.5027,"lng":-117.00371},"sections":[{"summary":{"duration":411,"distance":4572,"speed":40},"from":{"description":"Mong Kok, Yau Tsim Mong, Hong Kong","name":"Mong Kok","state":"Yau Tsim Mong","country":"Hong Kong","country_code":"HK","locode":"HKMKK","lat":22.31935,"lng":114.17136},"to":{"description":"Hong Kong, Central and Western District, Hong Kong","name":"Hong Kong","state":"Central and Western District","country":"Hong Kong","country_code":"HK","locode":"HKHKG","lat":22.27832,"lng":114.17469},"transport_mode":"ROAD","path":[[22.3193122,114.1711581],[22.27832,114.17471]],"ferry_paths":[],"stats":[]},{"summary":{"duration":1705951,"distance":12286644,"speed":25.93},"from":{"description":"Hong Kong, Central and Western District, Hong Kong","name":"Hong Kong","state":"Central and Western District","country":"Hong Kong","country_code":"HK","locode":"HKHKG","lat":22.27832,"lng":114.17469},"to":{"description":"Ensenada, Estado de Baja California, Mexico","name":"Ensenada","state":"Estado de Baja California","country":"Mexico","country_code":"MX","locode":"MXESE","lat":31.87149,"lng":-116.60071},"transport_mode":"SEA","path":[[22.2783,114.1747],[21.8093,114.3836],[21.7936,114.3947],[21.7877,114.4095],[21.7917,114.4282],[22.7369,116.5504],[22.7437,116.5716],[22.7454,116.5931],[22.742,116.6151],[21.5705,120.8501],[21.5664,120.8692],[21.5645,120.8885],[21.565,120.9081],[32.0789,-117.1456],[32.0776,-117.1317],[32.071,-117.121],[32.0591,-117.1137],[31.7477,-116.9962],[31.7363,-116.9892],[31.7317,-116.9792],[31.7337,-116.9661],[31.8715,-116.6007]],"ferry_paths":[],"stats":[{"carrier_name":"ONE","carrier_code":"oney","duration":2807090,"speed":15.76,"popularity":37.5},{"carrier_name":"Wan Hai","carrier_code":"whlc","duration":2690742,"speed":16.44,"popularity":21.88},{"carrier_name":"Hapag-Lloyd","carrier_code":"hlcu","duration":3736920,"speed":11.84,"popularity":12.5},{"carrier_name":"CMA CGM","carrier_code":"cmdu","duration":3686280,"speed":12,"popularity":9.38},{"carrier_name":"COSCO","carrier_code":"cosu","duration":3007360,"speed":14.71,"popularity":9.38},{"carrier_name":"DSV","carrier_code":"dsvf","duration":3842760,"speed":11.51,"popularity":6.25},{"carrier_name":"HMM","carrier_code":"hdmu","duration":3405240,"speed":12.99,"popularity":3.13}]},{"summary":{"duration":8227,"distance":91415,"speed":40},"from":{"description":"Ensenada, Estado de Baja California, Mexico","name":"Ensenada","state":"Estado de Baja California","country":"Mexico","country_code":"MX","locode":"MXESE","lat":31.87149,"lng":-116.60071},"to":{"description":"Tijuana, Estado de Baja California, Mexico","name":"Tijuana","state":"Estado de Baja California","country":"Mexico","country_code":"MX","locode":"MXTIJ","lat":32.5027,"lng":-117.00371},"transport_mode":"ROAD","path":[[31.871374,-116.600693],[31.88776,-116.689362],[31.948681,-116.755722],[32.00238,-116.828629],[32.0798,-116.880287],[32.167492,-116.90168],[32.249435,-116.941132],[32.277321,-117.02697],[32.363098,-117.05629],[32.448166,-117.024529],[32.502365,-117.003685]],"ferry_paths":[],"stats":[]}]},"alternative_routes":[]}}';
            res.setBody(responseBody);
            return res;
        }
    }

    // Mock class for an error response (e.g., 404 Not Found)
    private class MockHttpResponseGeneratorError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake error response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(404);
            res.setStatus('Not Found');
            res.setBody('{"error": "Not Found"}');
            return res;
        }
    }

    // Mock class for an invalid API response
    private class MockHttpResponseGeneratorInvalidResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake invalid response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String responseBody = '{"success": false, "status_code": "WRONG_PARAMETERS", "metadata": {}, "data": {}}';
            res.setBody(responseBody);
            return res;
        }
    }

    // Test method for a successful distance calculation
    @IsTest
    static void testGetDistanceInMetersSuccess() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccess());

        // Call the method
        String sourceAddress = 'Madrid, Spain';
        String destinationAddress = 'Ibiza, Spain';

        Decimal distance = SearatesDistanceAndTimeAPI.getDistanceInMeters(sourceAddress, destinationAddress, 'ROAD');

        // Verify the distance
        Decimal expectedDistance = 530342;
        System.assertEquals(expectedDistance, distance, 'Distance should match the expected value.');
    }

    // Test method for a successful distance calculation
    @IsTest
    static void testGetDistanceInMetersSuccessSecondExample() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorSuccessSecondExample());

        // Call the method
        String sourceAddress = 'Madrid, Spain';
        String destinationAddress = 'Ibiza, Spain';

        Decimal distance = SearatesDistanceAndTimeAPI.getDistanceInMeters(sourceAddress, destinationAddress, 'ROAD');

        // Verify the distance
        Decimal expectedDistance = 12382632;
        System.assertEquals(expectedDistance, distance, 'Distance should match the expected value.');
    }

    // Test method for handling HTTP error responses
    @IsTest
    static void testGetDistanceInMetersHttpError() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError());

        // Call the method and expect an exception
        String sourceAddress = 'Madrid, Spain';
        String destinationAddress = 'Ibiza, Spain';

        try {
            Decimal distance = SearatesDistanceAndTimeAPI.getDistanceInMeters(sourceAddress, destinationAddress, 'SEA');
            System.assert(false, 'Expected DistanceCalculationException was not thrown.');
        } catch (SearatesDistanceAndTimeAPI.DistanceCalculationException e) {
            // Expected exception was thrown
            System.assertEquals('Error: Not Found 404\n response: {"error": "Not Found"}', e.getMessage());
        }
    }

    // Test method for handling invalid API responses
    @IsTest
    static void testGetDistanceInMetersInvalidApiResponse() {
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorInvalidResponse());

        // Call the method and expect an exception
        String sourceAddress = 'Madrid, Spain';
        String destinationAddress = 'Ibiza, Spain';

        try {
            Decimal distance = SearatesDistanceAndTimeAPI.getDistanceInMeters(sourceAddress, destinationAddress, 'RAIL');
            System.assert(false, 'Expected DistanceCalculationException was not thrown.');
        } catch (SearatesDistanceAndTimeAPI.DistanceCalculationException e) {
            // Expected exception was thrown
            System.assertEquals('Invalid response status_code: WRONG_PARAMETERS', e.getMessage());
        }
    }
}