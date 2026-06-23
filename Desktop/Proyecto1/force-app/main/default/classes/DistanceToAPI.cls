public with sharing class DistanceToAPI {
    private static final String DISTANCE_TO_API_SERVICE = WebserviceSettings__mdt.getInstance('DistanceToApi').WebserviceURL__c;
    private static final String DISTANCE_TO_API_KEY = WebserviceSettings__mdt.getInstance('DistanceToApi').Value__c;
    
    public static Decimal getDistanceInMeters(String sourceCity, String sourceCountry, String destinationCity, String destinationCountry) {
        // Result variable
        Decimal calculatedDistance = null;

        // Build request body
        List<Map<String, String>> route = new List<Map<String, String>>();
        
        Map<String, String> sourcePoint = new Map<String, String>();
        sourcePoint.put('country', sourceCountry);
        sourcePoint.put('name', sourceCity);
        
        Map<String, String> destinationPoint = new Map<String, String>();
        destinationPoint.put('country', destinationCountry);
        destinationPoint.put('name', destinationCity);
        
        route.add(sourcePoint);
        route.add(destinationPoint);
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('route', route);
        
        String requestBodyJson = JSON.serialize(requestBody);
        
        // Build HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(DISTANCE_TO_API_SERVICE);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-rapidapi-key', DISTANCE_TO_API_KEY);
        req.setHeader('x-rapidapi-host', DistanceToAPI.getHostNameForParam(DISTANCE_TO_API_SERVICE) );
        req.setBody(requestBodyJson);
        
        // Send request
        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
        } catch (System.CalloutException e) {
            // Handle exception
            String errorMessage = 'Callout error: ' + e.getMessage() + '\n Request Body JSON: ' + requestBodyJson;
            Logger.warn(errorMessage).addTag('DistanceToAPI');
            throw new DistanceCalculationException(errorMessage);
        }

        // Check response status and handle accordingly
        Integer responseStatusCode = res.getStatusCode();
        String responseStatus = res.getStatus();
        
        if (responseStatusCode == 200) {
            String responseBody = res.getBody();
            
            // Parse the response & store the result
            calculatedDistance = parseDistanceToResponse(responseBody) * 1000; // Convert to meters
        } else {
            String errorMessage = 'Error: ' + responseStatus + ' ' + responseStatusCode + '\n Request Body JSON: ' + requestBodyJson;
            Logger.warn(errorMessage).addTag('DistanceToAPI');
            throw new DistanceCalculationException(errorMessage);
        }      
        
        // Return the calculated distance
        return calculatedDistance;
    }

    private static Decimal parseDistanceToResponse(String responseBody) {
        // Deserialize the response
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        if (responseMap == null) {
            Logger.warn('Invalid response: empty body').addTag('DistanceToAPI');
            throw new DistanceCalculationException('Invalid response: empty body');
        }

        if (!responseMap.containsKey('route')) {
            Logger.warn('Invalid response: missing route information, Response: '+responseBody).addTag('DistanceToAPI');
            throw new DistanceCalculationException('Invalid response: missing route information');
        }

        Map<String, Object> routeMap = (Map<String, Object>) responseMap.get('route');

        if (routeMap == null) {
            Logger.warn('Invalid response: route is null, Response: '+responseBody).addTag('DistanceToAPI');
            throw new DistanceCalculationException('Invalid response: route is null');
        }

        Object vincentyDistanceObj = routeMap.get('vincenty');
        if (vincentyDistanceObj == null) {
            Logger.warn('Invalid response: vincenty distance is null, Response: '+responseBody).addTag('DistanceToAPI');
            throw new DistanceCalculationException('Invalid response: vincenty distance is null');
        }

        Decimal vincentyDistanceMeters;
        try {
            vincentyDistanceMeters = Decimal.valueOf(String.valueOf(vincentyDistanceObj));
        } catch (Exception e) {
            Logger.warn('Invalid response: vincenty distance is not a number, Response: '+responseBody).addTag('DistanceToAPI');
            throw new DistanceCalculationException('Invalid response: vincenty distance is not a number');
        }

        return vincentyDistanceMeters;
    }

    public class DistanceCalculationException extends Exception {
    }

    private static String getHostNameForParam(String url) {
        return new Url(url).getHost();
    }
}