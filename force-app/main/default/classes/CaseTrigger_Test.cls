@isTest
public with sharing class CaseTrigger_Test {
    @TestSetup
    static void makeData() {

        Trigger_Bypass__c bypassSetting = new Trigger_Bypass__c(
            SetupOwnerId = UserInfo.getUserId(),
            Bypass_All__c = false,
            Case__c = false
        );
        insert bypassSetting;

        
    }

    @isTest
    public static void testAll() {
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock());

        // create unit of work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Account.SObjectType,
                Contact.SObjectType,
                Case.SObjectType
            }
        );

        for (Integer i = 0; i < 100; i++) {
            Account newAcc = new Account(
                Name = 'Test Account ' + i
            );
            uow.registerNew(newAcc);

            for(Integer j = 0; j < 5; j++) {
                Contact newContact = new Contact(
                    FirstName = 'Test',
                    LastName = 'Contact ' + j,
                    Title='Test'
                );
                uow.registerNew(newContact, Contact.AccountId, newAcc);

                Case newCase = new Case(
                    Status = 'New',
                    Type = 'Credit Card',
                    Origin = 'Web',
                    Subject = 'Testing Bypass',
                    Description = 'Sample Card Description',
                    Comments = 'Sample Comment'
                );
                
                uow.registerRelationship(newCase, Case.ContactId, newContact);
                uow.registerNew(newCase, Case.AccountId, newAcc);
            }
        }

        uow.commitWork();
        
        List<Case> sampleList = [Select Subject From Case];
        System.assert(sampleList.size() > 0, 'Case wansn\'t created properly.');
    }
}
