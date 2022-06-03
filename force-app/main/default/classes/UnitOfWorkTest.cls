@isTest
public with sharing class UnitOfWorkTest {
    @isTest
    public static void challengeComplete() {
        // create unit of work
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Account.SObjectType,
                Contact.SObjectType,
                Note.SObjectType
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
                
                Note newNote = new Note(
                    Body = 'Note Content ' + j,
                    Title = 'Test'
                );
                uow.registerNew(newNote, Note.ParentId, newContact);
            }
        }

        uow.commitWork();

        System.assertEquals(100, [Select Id from Account].size());
        System.assertEquals(500, [Select Id from Contact].size());
        System.assertEquals(500, [Select Id from Note].size());
    }
}