public with sharing class SearatesDistanceAndTimeAPI {
    private static final String SEARATES_DISTANCE_AND_TIME_API_SERVICE = WebserviceSettings__mdt.getInstance('Searates_API').WebserviceURL__c;
    private static final String SEARATES_DISTANCE_AND_TIME_API_KEY = WebserviceSettings__mdt.getInstance('Searates_API').Value__c;
    private static final String API_PARAM_FROM = 'from';
    private static final String API_PARAM_TO = 'to';
    private static final String API_PARAM_API_KEY = 'api_key';
    private static final String API_PARAM_TRANSPORT_MODES = 'transport_modes';
    private static final String API_PARAM_ALTERNATIVE_ROUTES = 'alternative_routes';
    private static final String API_PARAM_ROUTING_MODE = 'routing_mode';

    /**
     * transportMode
     *  Optional
     *  string
     *  Modes of transportation that are allowed to be used in route finding. Multiple modes of transportation can be specified separated by a comma.
     *  
     *  SEA - by sea
     *  ROAD - by road
     *  RAIL - by rail
     *  AIR - by air
     *  
     *  Examples:SEAAIR,ROAD
     */
    public static Decimal getDistanceInMeters(String sourceAddress, String destinationAddress, String transportMode) {
        // result
        Decimal calculatedDistance = null;
        
        // build callout
        HttpCalloutService calloutService = new HttpCalloutService(SEARATES_DISTANCE_AND_TIME_API_SERVICE)
            .addUrlParam(API_PARAM_API_KEY, SEARATES_DISTANCE_AND_TIME_API_KEY)
            .addUrlParam(API_PARAM_FROM, sourceAddress)
            .addUrlParam(API_PARAM_TO, destinationAddress)
            .addUrlParam(API_PARAM_TRANSPORT_MODES, transportMode)
            .convertParamstoQueryString()
            .handleOwnException();
        
        // Callout
        HTTPResponse response = calloutService.get();

        Integer responseStatusCode = response.getStatusCode();
        String responseStatus = response.getStatus();
        
        // Check response status and handle accordingly
        if (responseStatusCode == 200) {
            
            // parse the response & store the result
            calculatedDistance = parseDistanceAndTimeResponse(response.getBody());
        } else {
            String errorMessage = responseStatus + ' ' + responseStatusCode + '\n response: '+response.getBody();            
            Logger.warn('Error : '+errorMessage).addTag('SearatesDistanceAndTimeAPI');
            throw new DistanceCalculationException('Error: ' + errorMessage);
        }      
        
        // return the calculated distance
        return calculatedDistance;
    }

    private static Decimal parseDistanceAndTimeResponse(String responseBody) {
        DistanceAndTimeResponse response = (DistanceAndTimeResponse)JSON.deserialize(responseBody, DistanceAndTimeResponse.class);
        Decimal calculatedDistance = null;

        // perform response checks
        validateResponse(response, responseBody);

        // extract the value we need
        calculatedDistance = response.data.route.summary.distance;

        return calculatedDistance;
    }

    private static void validateResponse(DistanceAndTimeResponse response, String responseBody) {
        if (!response.success || response.status_code != 'OK') {
            String errorMessage = ' \n DistanceAndTimeResponse: ' + response + ' \n Response: ' + responseBody;
            Logger.warn('Error: Invalid response status_code: ' + response.status_code + errorMessage)
                .addTag('SearatesDistanceAndTimeAPI');
            throw new DistanceCalculationException('Invalid response status_code: ' + response.status_code);
        }

        if (response.data == null || response.data.route == null || response.data.route.summary == null || response.data.route.summary.distance == null) {
            String errorMessage = ' \n DistanceAndTimeResponse: ' + response + ' \n Response: ' + responseBody;
            Logger.warn('Error: No route found in the response ' + errorMessage)
                .addTag('SearatesDistanceAndTimeAPI');
            throw new DistanceCalculationException('No route found in the response');
        }
    }

    public class DistanceCalculationException extends Exception {
        
    }

    // Classes for response mapping

    public class DistanceAndTimeResponse {
        public Boolean success;
        public String status_code;
        public Metadata metadata;
        public Data data;
    }
    
    public class Metadata {
        public RequestParameters request_parameters;
    }
    
    public class RequestParameters {
        @JsonName('from')
        public String fromLocation;
        public String to;
        public String transport_modes;
        public Boolean alternative_routes;
        public String routing_mode;
    }
    
    public class Data {
        public Route route;
        public List<Route> alternative_routes;
    }
    
    public class Route {
        public Summary summary;
        @JsonName('from')
        public Location fromLocation;
        public Location to;
        public List<Section> sections;
    }
    
    public class Summary {
        public Decimal duration;
        public Decimal distance;
        public Decimal speed;
    }
    
    public class Location {
        public String description;
        public String name;
        public String state;
        public String country;
        public String country_code;
        public String locode;
        public Decimal lat;
        public Decimal lng;
    }
    
    public class Section {
        public Summary summary;
        @JsonName('from')
        public Location fromLocation;
        public Location to;
        public String transport_mode;
        public List<List<Decimal>> path;
        public List<List<List<Decimal>>> ferry_paths;
        public List<Stat> stats;
    }
    
    public class Stat {
        public String carrier_name;
        public String carrier_code;
        public Decimal duration;
        public Decimal speed;
        public Decimal popularity;
    }
}