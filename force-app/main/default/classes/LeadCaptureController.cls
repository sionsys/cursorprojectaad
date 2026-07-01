public with sharing class LeadCaptureController {
    @AuraEnabled
    public static Lead createLeadRecord(Lead leadRecord) {
        try {
            insert leadRecord;
            return leadRecord;
        } catch (Exception e) {
            throw new AuraHandledException('Error al crear el Prospecto: ' + e.getMessage());
        }
    }
}