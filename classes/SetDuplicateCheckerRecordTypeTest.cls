@isTest
public class SetDuplicateCheckerRecordTypeTest {
 
    static String orgLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
    static String salesLeadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
    static String standardAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
    static String transportersAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
    
    @isTest
    public static void CreateOrgLead(){

        Test.startTest();
        Lead leadRec = TestUtility.createLead();
        leadRec.State = 'NY';
        leadRec.EIN_Number__c= '456123';
        leadRec.RecordTypeId = orgLeadRTId;
        leadRec.Dealer_Type__c='Franchise';
        insert leadRec;

        Test.stopTest();
        System.Assert([Select Count() from Lead Where Duplicate_Checker_Record_Type__c='Organization_Lead' ] == 1, 'Incorrect number of leads');
        
    }

    @isTest
    public static void CreateStandardAccount(){

        Test.startTest();
        Account acc= TestUtility.createAccount();
        acc.RecordTypeId= standardAccRTId;
        insert acc;
        Test.stopTest();
        System.Assert([Select Count() from Account Where Duplicate_Checker_Record_Type__c='Standard'] == 1, 'Incorrect number of accounts');
        
    }
    
    @isTest
    public static void CreateAndUpdateLead(){

        Test.startTest();
        Lead leadRec = TestUtility.createLead();
        leadRec.State = 'NY';
        leadRec.EIN_Number__c= '456123';
        leadRec.RecordTypeId = orgLeadRTId;
        leadRec.Dealer_Type__c='Franchise';
        insert leadRec;
        System.Assert([Select Count() from Lead Where Duplicate_Checker_Record_Type__c='Organization_Lead' ] == 1, 'Incorrect number of org leads');

        leadRec.RecordTypeId= salesLeadRTId;
        update leadRec;

        Test.stopTest();
        System.Assert([Select Count() from Lead Where Duplicate_Checker_Record_Type__c='Sales' ] == 1, 'Incorrect number of sales leads');
        
    }

    @isTest
    public static void CreateAndUpdateAccount(){

        Test.startTest();
        Account acc= TestUtility.createAccount();
        acc.RecordTypeId= standardAccRTId;
        insert acc;
        System.Assert([Select Count() from Account Where Duplicate_Checker_Record_Type__c='Standard'] == 1, 'Incorrect number of standard accounts');
        
        acc.RecordTypeId= transportersAccRTId;
        update acc;

        Test.stopTest();
        System.Assert([Select Count() from Account Where Duplicate_Checker_Record_Type__c='Transporters'] == 1, 'Incorrect number of transporter accounts');
        
    }

}