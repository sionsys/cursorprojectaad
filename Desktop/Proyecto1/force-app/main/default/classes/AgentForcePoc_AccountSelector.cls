public class AgentForcePoc_AccountSelector {

@InvocableMethod(label='Query Account Data' description='used in prompts')
    public static List<Response> getAccountData(List<Request> requests) {
        if (requests.size() != 1)
            throw new ListException('The requests list must contain one entry only');
        String accountId = requests[0].AccountId;
        
        List<OpportunityLineItem> lstOpportunityLineItems = 
                                    [SELECT Opportunity.StageName, Product2.Name, Product2.Subtype__c, Product2.LevelA__c, Product2.LevelB__c, Product2.LevelC__c 
                                        FROM OpportunityLineItem
                                        WHERE Opportunity.AccountId = :accountId and Product2.LevelA__c = 'Prosthetics'];

        List<OrderItem> lstOrderItems = 
                                        [SELECT Order.Status, Product2.Name, Product2.LevelA__c, Product2.LevelB__c, Product2.Levelc__c
                                        FROM OrderItem
                                        WHERE Product2.LevelA__c = 'Prosthetics' and Order.AccountId = :accountId];



        List<ProductWrapper> products = new List<ProductWrapper>();
        for(OpportunityLineItem item : lstOpportunityLineItems) {
            ProductWrapper pw = new ProductWrapper();
            pw.stage = item.Opportunity.StageName;
            pw.LevelB = item.Product2.LevelB__c;
            pw.LevelC = item.Product2.LevelC__c;
            pw.name = item.Product2.Name;
            pw.concatenatedFocusGroup = pw.LevelB + '-' + pw.LevelC;
            products.add(pw);
        }

        for(OrderItem item : lstOrderItems) {
            ProductWrapper pw = new ProductWrapper();
            pw.stage = item.Order.Status;
            pw.LevelB = item.Product2.LevelB__c;
            pw.LevelC = item.Product2.LevelC__c;
            pw.name = item.Product2.Name;
            pw.concatenatedFocusGroup = pw.LevelB + '-' + pw.LevelC;
            products.add(pw);
        }
        
        List<Response> responses = new List<Response>();
        String responseData = null;
        if(products.isEmpty()) {
            responseData = 'There is no account.';
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
        public String AccountId;
        @InvocableVariable
        public String User_Question;
    }
    
    public class Response {
        @InvocableVariable
        public String Prompt;
    }

    public class ProductWrapper {
        public String name;
        public String stage;
        public String LevelB;
        public String LevelC;
        public String concatenatedFocusGroup;
    }
}