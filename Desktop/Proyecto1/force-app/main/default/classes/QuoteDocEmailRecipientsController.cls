public with sharing class QuoteDocEmailRecipientsController {
    
    public class EmailRecipient {
        @AuraEnabled 
        public String contactId {get;set;}
        @AuraEnabled
        public String emailAddress {get;set;}
        @AuraEnabled 
        public String contactName {get;set;}
        @AuraEnabled 
        public Boolean isDefaultNotificationRecipient {get;set;}

        public Boolean equals(Object obj) {
            EmailRecipient other = (EmailRecipient) obj;
            return (contactName == other.contactName && emailAddress == other.emailAddress);
        }
    }

    @AuraEnabled
    public static List<EmailRecipient> getEmailRecipients(Id accountId) {
        List<EmailRecipient> recipients = new List<EmailRecipient>();
        List<Contact> contacts = new List<Contact>();
        List<Contact> contactsFromNR = new List<Contact>();

        for (Notification_Recipients__c nr : NotificationRecipientsSelector.newInstance().selectByAccountId(accountId)) {
            if(String.isNotBlank(nr.Contact__r.Email) && nr.Notification_Type__c == 'Email') {
                contactsFromNR.add(nr.Contact__r);
            }
        }
        contacts.addAll(contactsFromNR);
        contacts.addAll(COM_ContactsSelector.newInstance().selectByAccountId(new Set<Id> {accountId}));

        for (Contact singleContact : contacts) {
            if (singleContact.Email != null) {
                EmailRecipient currentRecipient = new EmailRecipient();
                currentRecipient.contactId = singleContact.Id; 
                currentRecipient.emailAddress = singleContact.Email; 
                currentRecipient.contactName = singleContact.Name; 
                currentRecipient.isDefaultNotificationRecipient = contactsFromNR.contains(singleContact);
                if (!recipients.contains(currentRecipient)) {
                    recipients.add(currentRecipient);
                }
            }
        }
        return recipients;
    }
}