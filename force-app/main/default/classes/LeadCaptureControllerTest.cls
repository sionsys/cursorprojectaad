@isTest
private class LeadCaptureControllerTest {
    @isTest
    static void testCreateLeadRecordSuccess() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Prospecto',
            Company = 'Test Company',
            Email = 'test@example.com',
            LeadSource = 'Web'
        );
        
        Test.startTest();
        Lead result = LeadCaptureController.createLeadRecord(testLead);
        Test.stopTest();
        
        System.assertNotEquals(null, result.Id, 'El Lead debió haberse insertado correctamente.');
    }

    @isTest
    static void testCreateLeadRecordException() {
        // Un lead sin LastName (campo obligatorio) provocará una excepción
        Lead invalidLead = new Lead(FirstName = 'Invalid');
        
        Test.startTest();
        try {
            LeadCaptureController.createLeadRecord(invalidLead);
            System.assert(false, 'Se esperaba una excepción AuraHandledException.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null, 'La excepción debe contener un mensaje.');
        }
        Test.stopTest();
    }
}