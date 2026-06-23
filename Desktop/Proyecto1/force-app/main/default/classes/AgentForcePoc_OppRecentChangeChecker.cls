public with sharing class AgentForcePoc_OppRecentChangeChecker {

    // ====== INPUT (from Flow) ======
    public class Request {
        @InvocableVariable(required=true description='Id of the Opportunity to check')
        public Id opportunityId;

        @InvocableVariable(description='Lookback window in days (defaults to 14 if null/<=0)')
        public Integer lookbackDays;
    }

    // ====== OUTPUT (to Flow) ======
    public class Response {
        @InvocableVariable(description='Opportunity Id processed')
        public Id opportunityId;

        @InvocableVariable(description='True if Opportunity or related records changed within lookback')
        public Boolean hasRecentChange;

        @InvocableVariable(description='Datetime of the most recent change detected')
        public Datetime latestChangeAt;

        @InvocableVariable(description='Sources where the change was found (comma-separated)')
        public String changeSources;
    }

    @InvocableMethod(
        label='Check Recent Opp Changes (AgentForcePoc_)'
        description='Returns TRUE if the Opportunity or related records have updates within the lookback window'
    )
    public static List<Response> checkRecentChanges(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null || requests.isEmpty()) return responses;

        // Collect Opp Ids and lookback config
        Set<Id> oppIds = new Set<Id>();
        Map<Id, Integer> oppToDays = new Map<Id, Integer>();
        for (Request r : requests) {
            if (r != null && r.opportunityId != null) {
                oppIds.add(r.opportunityId);
                Integer days = (r.lookbackDays == null || r.lookbackDays <= 0) ? 14 : r.lookbackDays;
                oppToDays.put(r.opportunityId, days);
            }
        }
        if (oppIds.isEmpty()) return responses;

        // Query opportunities with 1 latest child record each
        List<Opportunity> opps = [
            SELECT Id,
                   LastModifiedDate,
                   LastActivityDate,
                   LastStageChangeDate,
                   (SELECT Id, CreatedDate, LastModifiedDate
                      FROM Tasks ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1),
                   (SELECT Id, CreatedDate, LastModifiedDate
                      FROM Events ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1),
                   (SELECT Id, CreatedDate, LastModifiedDate
                      FROM Meetings__r ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1),
                   (SELECT Id, CreatedDate, LastModifiedDate
                      FROM OpportunityContactRoles ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1),
                   (SELECT Id, CreatedDate, LastModifiedDate
                      FROM OpportunityTeamMembers ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1),
                   (SELECT Id, CreatedDate, LastModifiedDate
                      FROM OpportunityLineItems ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1)
            FROM Opportunity
            WHERE Id IN :oppIds
        ];

        Map<Id, Response> oppToResponse = new Map<Id, Response>();

        for (Opportunity o : opps) {
            Integer days = oppToDays.get(o.Id);
            Datetime cutoff = Datetime.now().addDays(-days);

            Datetime latest = null;
            Set<String> sources = new Set<String>();

            // Parent fields
            latest = pickLatest(latest, o.LastModifiedDate, 'Opportunity', sources);
            latest = pickLatest(latest, toDateTime(o.LastActivityDate), 'Opportunity', sources);
            latest = pickLatest(latest, o.LastStageChangeDate, 'Opportunity', sources);

            // Children (LIMIT 1 each)
            if (o.Tasks != null && !o.Tasks.isEmpty())
                latest = pickLatest(latest, maxChildDt(o.Tasks), 'Task', sources);

            if (o.Events != null && !o.Events.isEmpty())
                latest = pickLatest(latest, maxChildDt(o.Events), 'Event', sources);

            List<SObject> meetings = (List<SObject>) o.getSObjects('Meetings__r');
            if (meetings != null && !meetings.isEmpty())
                latest = pickLatest(latest, maxChildDt(meetings), 'Meeting', sources);

            if (o.OpportunityContactRoles != null && !o.OpportunityContactRoles.isEmpty())
                latest = pickLatest(latest, maxChildDt(o.OpportunityContactRoles), 'OCR', sources);

            if (o.OpportunityTeamMembers != null && !o.OpportunityTeamMembers.isEmpty())
                latest = pickLatest(latest, maxChildDt(o.OpportunityTeamMembers), 'OTM', sources);

            if (o.OpportunityLineItems != null && !o.OpportunityLineItems.isEmpty())
                latest = pickLatest(latest, maxChildDt(o.OpportunityLineItems), 'OLI', sources);

            Response resp = new Response();
            resp.opportunityId   = o.Id;
            resp.latestChangeAt  = latest;
            resp.hasRecentChange = (latest != null && latest >= cutoff);
            resp.changeSources   = sources.isEmpty() ? '' : String.join(new List<String>(sources), ', ');

            oppToResponse.put(o.Id, resp);
        }

        // Preserve input order
        for (Request r : requests) {
            if (r == null || r.opportunityId == null) continue;
            responses.add(oppToResponse.containsKey(r.opportunityId)
                ? oppToResponse.get(r.opportunityId)
                : buildDefault(r.opportunityId));
        }

        return responses;
    }

    // ====== Helpers ======
    private static Datetime toDateTime(Date d) {
        return (d == null) ? null : Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0));
    }

    private static Datetime maxChildDt(List<SObject> rows) {
        if (rows == null || rows.isEmpty()) return null;
        SObject s = rows[0]; // LIMIT 1
        Datetime cd = (Datetime) s.get('CreatedDate');
        Datetime lm = (Datetime) s.get('LastModifiedDate');
        if (cd == null) return lm;
        if (lm == null) return cd;
        return (lm > cd) ? lm : cd;
    }

    private static Datetime pickLatest(Datetime current, Datetime candidate, String src, Set<String> sources) {
        if (candidate == null) return current;
        if (current == null || candidate > current) {
            sources.add(src);
            return candidate;
        }
        return current;
    }

    private static Response buildDefault(Id oppId) {
        Response r = new Response();
        r.opportunityId   = oppId;
        r.hasRecentChange = false;
        r.latestChangeAt  = null;
        r.changeSources   = '';
        return r;
    }
}