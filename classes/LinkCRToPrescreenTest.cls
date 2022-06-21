@isTest
public class LinkCRToPrescreenTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Condition_Report__c cr = TestUtility.createCr(v);
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(cr, a, c);
        crp.Inspection_Id__c = '2312111';
        insert crp;
    }

    @IsTest
    static void testNonSIACR(){
        Vehicle__c v = [SELECT id FROM Vehicle__c LIMIT 1];
        Condition_Report__c cr = TestUtility.createCr(v);
        
        Test.startTest();
            insert cr;
        Test.stopTest();
        System.assertEquals([SELECT Count() FROM Condition_Report_Prescreen__c WHERE Condition_Report__c = null],1);
    }

    @IsTest
    static void testSIACR(){
        Vehicle__c v = [SELECT id FROM Vehicle__c LIMIT 1];
        Condition_Report__c cr = TestUtility.createCr(v);
        cr.Inspection_Guid__c = '2312111';
        Test.startTest();
            insert cr;
        Test.stopTest();
        System.assertEquals([SELECT Count() FROM Condition_Report_Prescreen__c WHERE Condition_Report__c = null],0);
    }
}