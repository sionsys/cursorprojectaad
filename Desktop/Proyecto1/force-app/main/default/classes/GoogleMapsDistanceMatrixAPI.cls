public with sharing class GoogleMapsDistanceMatrixAPI {
    private static final String GOOGLE_MAPS_DISTANCE_MATRIX_API_SERVICE = WebserviceSettings__mdt.getInstance('Google_Maps_Distance_Matrix_Api').WebserviceURL__c;
    private static final String GOOGLE_MAPS_DISTANCE_MATRIX_API_SERVICE_VALUE = WebserviceSettings__mdt.getInstance('Google_Maps_Distance_Matrix_Api').Value__c;
    private static final String API_PARAM_ORIGINS = 'origins';
    private static final String API_PARAM_DESTINATION = 'destinations';
    private static final String API_PARAM_KEY = 'key';

    public static Decimal getDistanceInMeters(String sourceAddress, String destinationAddress) {
        // result
        Decimal calculatedDistance = null;
        
        // build callout
        HttpCalloutService calloutService = new HttpCalloutService(GOOGLE_MAPS_DISTANCE_MATRIX_API_SERVICE)
            .addUrlParam(API_PARAM_ORIGINS, sourceAddress)
            .addUrlParam(API_PARAM_DESTINATION, destinationAddress)
            .addUrlParam(API_PARAM_KEY, GOOGLE_MAPS_DISTANCE_MATRIX_API_SERVICE_VALUE)
            .convertParamstoQueryString()
            .handleOwnException();
        
        // Callout
        HTTPResponse response = calloutService.get();
        Integer responseStatusCode = response.getStatusCode();
        String responseStatus = response.getStatus();
        
        // Check response status and handle accordingly
        if (responseStatusCode == 200) {           
            // parse the response & store the result
            calculatedDistance = parseDistanceMatrixResponse(response.getBody());
        } else {
            String errorMessage = responseStatus + ' ' + responseStatusCode + '\n response.getBody(): ' + response.getBody();
            Logger.warn('Error : '+errorMessage).addTag('GoogleMapsDistanceMatrixAPI');
            throw new DistanceCalculationException('Error: ' + errorMessage);
        }      
        
        // return the calculated distance
        return calculatedDistance;
    }

    private static Decimal parseDistanceMatrixResponse(String responseBody) {
        DistanceMatrixResponse response = (DistanceMatrixResponse)JSON.deserialize(responseBody, DistanceMatrixResponse.class);
        Decimal calculatedDistance = null;

        // perform response checks
        validateResponse(response, responseBody);

        // extract the value we need
        calculatedDistance = response.rows[0].elements[0].distance.value;
        
        return calculatedDistance;
    }

    private static void validateResponse(DistanceMatrixResponse response, String responseBody) {
        if (response.status != 'OK') {
            Logger.warn('Error: Invalid response status: ' + response.status + ' - response.error_message: ' + response.error_message + '\n responseBody: ' + responseBody)
                .addTag('GoogleMapsDistanceMatrixAPI');
            throw new DistanceCalculationException('Invalid response status: ' + response.status + ' - ' + response.error_message);
        } 

        if (response.rows.size() == 0) {
            Logger.warn('Error: No rows found in the response: ' + response.status + ' - response.error_message: ' + response.error_message + '\n responseBody: ' + responseBody)
                .addTag('GoogleMapsDistanceMatrixAPI');
            throw new DistanceCalculationException('No rows found in the response');
        }

        if (response.rows[0].elements.size() == 0) {
            Logger.warn('Error: No elements found in the response: ' + response.status + ' - response.error_message: ' + response.error_message + '\n responseBody: ' + responseBody)
                .addTag('GoogleMapsDistanceMatrixAPI');
            throw new DistanceCalculationException('No elements found in the response');
        }

        if (response.rows[0].elements[0].status == 'NOT_FOUND') {
            Logger.warn('Error: No elements found in the address section. Address not recognized: ' + response.status + ' - response.error_message: ' + response.error_message + '\n responseBody: ' + responseBody)
                .addTag('GoogleMapsDistanceMatrixAPI');
            throw new DistanceCalculationException('No elements found in the address section. Address not recognized.');
        }
        
        if (response.rows[0].elements[0].status != 'OK') {
            Logger.warn('Error: Unknown problem with the address recognition: ' + response.status + ' - response.error_message: ' + response.error_message + '\n responseBody: ' + responseBody)
                .addTag('GoogleMapsDistanceMatrixAPI');
            throw new DistanceCalculationException('Unknown problem with the address recognition.');
        }
    }

    public class DistanceCalculationException extends Exception {
        
    }

    private class Row {
        public List<Element> elements { get; set; }
    }
    
    private class Element {
        public Distance distance { get; set; }
        public Duration duration { get; set; }
        public String status { get; set; }
    }
    
    private class Distance {
        public String text { get; set; }
        public Integer value { get; set; }
    }
    
    private class Duration {
        public String text { get; set; }
        public Integer value { get; set; }
    }

    private class DistanceMatrixResponse {
        @SuppressWarnings('PMD') // need to name property like this due to the JSON responses mapped to this wrapper class
        public List<String> destination_addresses { get; set; }
        @SuppressWarnings('PMD') // need to name property like this due to the JSON responses mapped to this wrapper class
        public List<String> origin_addresses { get; set; }
        public List<Row> rows { get; set; }
        public String status { get; set; }
        @SuppressWarnings('PMD') // need to name property like this due to the JSON responses mapped to this wrapper class
        public String error_message { get; set; }
    }

}