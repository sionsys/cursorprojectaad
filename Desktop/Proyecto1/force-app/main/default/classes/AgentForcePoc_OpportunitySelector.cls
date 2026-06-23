public class AgentForcePoc_OpportunitySelector {

    @InvocableMethod(label='Query Opportunity Data' description='used in prompts')
    public static List<Response> getOpportunityData(List<Request> requests) {
        if (requests.size() != 1)
            throw new ListException('The requests list must contain one entry only');
        String opportunityId = requests[0].OpportunityId;
        
        List<Opportunity> lstOpportunities = [SELECT Id, Name, AccountId, Account.Name, StageName, Amount, PrimaryProduct__r.Name, Primary_Contact__r.Name, LastModifiedDate, CloseDate, CreatedDate, DaysInStage_DateTime__c, LastActivityDate, LastStageChangeDate, LastViewedDate, Stage_change_Date__c,
                                                (SELECT Contact.Name, Role FROM OpportunityContactRoles),
                                                (SELECT Subject, Description, Status, ActivityDate, CompletedDateTime, CreatedDate, LastModifiedDate FROM Tasks),
                                                (SELECT Id, Name, Meeting_Objective__c, Meeting_Notes__c, Meeting_Preparation__c, Meeting_Type__c, Virtual_Meeting__c, Contact__r.Name, CreatedDate, LastModifiedDate FROM Meetings__r),
                                                (SELECT Name, Title, TeamMemberRole  FROM OpportunityTeamMembers),
                                                (SELECT Product2.Name, Product2.LevelA__c, Product2.LevelB__c, Product2.LevelC__c, TotalPrice FROM OpportunityLineItems),
                                                (SELECT Subject, StartDateTime, Days_until_Due_Date__c, Description, EndDateTime, Who.Name FROM Events)
                                              FROM Opportunity WHERE Id = :opportunityId];
        
        Set<Id> setMeetingsIds = new Set<Id>();
        for(Meeting__c mt : lstOpportunities[0].Meetings__r) {
            setMeetingsIds.add(mt.Id);
        }
        
        List<Event> lstEvents = [SELECT StartDateTime, EndDateTime, Description, Subject, Who.Name, Meeting__c FROM Event WHERE AccountId = :lstOpportunities[0].AccountId and Meeting__c IN :setMeetingsIds];
        
        OpportunityData opportunityInfo = new OpportunityData();
        opportunityInfo.opportunity = lstOpportunities[0];
        opportunityInfo.events = lstEvents;
        
        List<Response> responses = new List<Response>();
        String responseData = null;
        if(lstOpportunities.isEmpty()) {
            responseData = 'There is no opportunity.';
        } else {
            responseData = JSON.serialize(opportunityInfo);
        }
        Response res = new Response();
        res.Prompt = responseData;
        responses.add(res);
        return responses;  
    }
    
    public class Request {
        @InvocableVariable
        public String OpportunityId;
        @InvocableVariable
        public String User_Question;
    }
    
    public class Response {
        @InvocableVariable
        public String Prompt;
    }
    
    public class OpportunityData {
        public Opportunity opportunity;
        public List<Event> events;
    }
}