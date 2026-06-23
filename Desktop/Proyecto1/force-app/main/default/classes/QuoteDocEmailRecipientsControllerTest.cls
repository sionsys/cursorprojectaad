@isTest
public with sharing class QuoteDocEmailRecipientsControllerTest {
    
    @isTest
    public static void getEmailRecipients_test() {
        String contact1emailAddress = 'test1@test.com';
        String contact2emailAddress = 'test2@test.com';
        String contact3emailAddress = 'test3@test.com';
        String contact4emailAddress = 'test4@test.com';
        String contact5emailAddress = 'test5@test.com';
        
        Account acc = new COM_TestHelper.AccountBuilder().getRecord();
        Account acc2 = new COM_TestHelper.AccountBuilder().withName('test2Acc').getRecord();
        insert new List<Account> {acc, acc2};
        
        Contact c1 = new COM_TestHelper.ContactBuilder().withAccountId(acc.Id).withEmail(contact1emailAddress).getRecord();
        Contact c2 = new COM_TestHelper.ContactBuilder().withAccountId(acc.Id).withEmail(contact2emailAddress).getRecord();
        Contact c3 = new COM_TestHelper.ContactBuilder().withAccountId(acc.Id).withEmail(contact3emailAddress).getRecord();
        Contact c4 = new COM_TestHelper.ContactBuilder().withAccountId(acc2.Id).withEmail(contact4emailAddress).getRecord();
        Contact c5 = new COM_TestHelper.ContactBuilder().withAccountId(acc2.Id).withEmail(contact5emailAddress).getRecord();
        Contact c6 = new COM_TestHelper.ContactBuilder().withAccountId(acc.Id).withEmail(contact1emailAddress).getRecord();
        insert new List<Contact> {c1, c2, c3, c4, c5, c6};

        Notification_Recipients__c notificationRecipient1 = new TestHelper.NotificationRecipientsBuilder()
            .build()
            .withAccount(acc.Id)
            .withContact(c2.Id)
            .withNotificationType('Email')
            .getRecord();
        Notification_Recipients__c notificationRecipient2 = new TestHelper.NotificationRecipientsBuilder()
            .build()
            .withAccount(acc2.Id)
            .withContact(c5.Id)
            .withNotificationType('Email')
            .getRecord();
        insert new List<Notification_Recipients__c> { notificationRecipient1, notificationRecipient2} ;

        Test.startTest();
        List<QuoteDocEmailRecipientsController.EmailRecipient> recipientsResult = QuoteDocEmailRecipientsController.getEmailRecipients(acc.Id);
        Test.stopTest();

        Assert.areEqual(3, recipientsResult.size());
        Integer verifiedResults = 0;
        for (QuoteDocEmailRecipientsController.EmailRecipient recipient : recipientsResult) {
            System.debug('recipient current: ' + recipient);
            if (recipient.emailAddress == contact1emailAddress || recipient.emailAddress == contact3emailAddress) {
                Assert.isFalse(recipient.isDefaultNotificationRecipient);
                verifiedResults++;
            } else if (recipient.emailAddress == contact2emailAddress) {
                Assert.isTrue(recipient.isDefaultNotificationRecipient);
                verifiedResults++;
            }
        }
        Assert.areEqual(3, verifiedResults);
        
    }
}