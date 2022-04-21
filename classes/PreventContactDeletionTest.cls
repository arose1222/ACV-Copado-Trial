/**
 * Test class for PreventContactDeletion
 * @author Jyothsna P
 * @since 04/19/2021
 */
@isTest
public class PreventContactDeletionTest {

    @TestSetup
    static void createTestData(){
       
        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        
        Account a = TestUtility.createAccount('Jyothsna Test');
        insert a;

        List<Contact> ctctList = new List<Contact>();
        Contact c = TestUtility.createContact(a);
        c.LastName = 'Contact1';
        c.RecordTypeId = acvuserRecordTypeId;
        
        Contact c1 = TestUtility.createContact(a);
        c1.LastName = 'Contact2';
        c1.RecordTypeId = acvuserRecordTypeId;
        
        ctctList.add(c);
        ctctList.add(c1);
        insert ctctList;

    }

    @isTest
    static void deleteACVContactAsStandardUserWithDeletePermissionSet() {
      
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Can_Modify_All_Contacts'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = TestUtility.createUser(p.Id);
        insert u;
        
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);
        insert psa;

        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, LastName FROM Contact Where LastName='Contact1'];
        Boolean checkContactDeletionErrorFlag = FALSE;
       
        System.runAs(u)
        {
            checkContactDeletionErrorFlag=  checkError(newCon);
            System.assertEquals(FALSE, checkContactDeletionErrorFlag, 'Error was thrown when attempting to delete the record for a user with delete custom permission' );
        }
    }

    @isTest
    static void deleteACVContactAsSysAdminWithoutPermissionSet() {
      
        // Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        // User u = TestUtility.createUser(p.Id);
        User u = TestUtility.createSystemAdministratorUser();
        insert u;
              

        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, LastName FROM Contact Where LastName='Contact2'];
        Boolean checkContactDeletionErrorFlag = FALSE;
       
        System.runAs(u)
        {
            checkContactDeletionErrorFlag=  checkError(newCon);
            System.assertEquals(TRUE, checkContactDeletionErrorFlag, 'No error (or a different error) was thrown when attempting to delete the record' );
        }
    }

    private static Boolean checkError( sObject obj ) {
        Boolean threwError = FALSE;
        try {
            delete obj;
        } catch ( exception e ) {
            threwError= TRUE;
        }

        return threwError;
    }

}