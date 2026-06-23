public class AgentForcePoc_OpportunityUpsellSelector {

    @InvocableMethod(label='Query Upsell Opportunity Data' description='used in upsell prompts')
    public static List<Response> getOpportunityData(List<Request> requests) {
        if (requests.size() != 1)
            throw new ListException('The requests list must contain one entry only');
        String opportunityId = requests[0].OpportunityId;

        List<OpportunityLineItem> lstOpportunityLineItems = 
                                        [SELECT Product2.Name, Product2.Description, Product2.LevelA__c, Product2.LevelB__c, Product2.LevelC__c
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId = :opportunityId];
    
    
        List<ProductWrapper> products = new List<ProductWrapper>();
        for(OpportunityLineItem item : lstOpportunityLineItems) {
            ProductWrapper pw = new ProductWrapper();
            pw.levelB = item.Product2.LevelB__c;
            pw.levelC = item.Product2.LevelC__c;
            pw.name = item.Product2.Name;
            pw.description = item.Product2.Description;
            products.add(pw);
        }
    
        
        List<Response> responses = new List<Response>();
        String responseData = null;
        if(lstOpportunityLineItems.isEmpty()) {
            responseData = 'There is no opportunity.';
        } else {
            responseData = JSON.serialize(products);
        }
        Response res = new Response();
        res.Prompt = responseData;
        responses.add(res);
        return responses;  
    }
    
    public class Request {
        @InvocableVariable
        public String OpportunityId;
    }
    
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
    
    public class ProductWrapper {
        public String name;
        public String levelB;
        public String levelC;
        public String description;
    }

}