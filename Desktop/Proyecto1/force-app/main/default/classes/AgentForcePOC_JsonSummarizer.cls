public with sharing class AgentForcePOC_JsonSummarizer {
    public class Wrapper {
        public List<Opportunity> opportunities;
    }
    // You can include only the fields you queried; JSON.serialize will include children too
    public static String summarizeToJson(List<Opportunity> opps) {
        Wrapper w = new Wrapper();
        w.opportunities = opps;
        return JSON.serialize(w, true);
    }
}