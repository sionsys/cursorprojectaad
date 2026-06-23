public with sharing class CPQ_CustomQuoteFinalizeController {

    public static void checkIfATPNeedsResync(Datetime atpResyncedTime) {
        Long maximumTimeBeforeATPNeedsResyncInMiliseconds = 15*60*1000;
        Boolean quoteNeedsATPResync;
        if (atpResyncedTime != null) {
            quoteNeedsATPResync = didTimePassUntilNow(atpResyncedTime, maximumTimeBeforeATPNeedsResyncInMiliseconds);
        } else {
            quoteNeedsATPResync = true;
        }
        if(quoteNeedsATPResync) {
            AuraHandledException e = new AuraHandledException(Label.CPQ_Controller_ATPSyncRequired_Exception);
            e.setMessage(Label.CPQ_Controller_ATPSyncRequired_Exception); //this line is needed, otherwise message cannot be read in apex try/catch block
            throw e;
        }
    }

    /**
     * @param   timeInPast          time in past which will be compared to "now" to see if "timeToBeVerified" passed since then
     * @param   timeToBeVerified    [miliseconds] time passed mention in "timeInPast" param description
     * @return  returns true if timeToBeVerified passed since timeInPast until now
     */
    public static Boolean didTimePassUntilNow(Datetime timeInPast, Long timeToBeVerified) {
        Datetime currentTime = Datetime.now();
        Long timeDifference = currentTime.getTime() - timeInPast.getTime();
        if (timeDifference > timeToBeVerified) {
            return true;
        }
        return false;
    }
}