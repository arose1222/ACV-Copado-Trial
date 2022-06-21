@isTest
public class updateVLCountOnPrescreenCloseTest {

    public static String mockMetaDataString = '[{"DeveloperName": "updateVLCountOnPrescreenClose","Active__c":"true","NamespacePrefix": "","Before_Update__c": "true","sObject__c": "Condition_Report_Prescreen__c", "Class_Name__c": "updateVLCountOnPrescreenClose"}]';
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = new Account(Name = 'ACV');
        insert a;
        Contact c = new Contact(FirstName = 'Bill', LastName = 'Best VCI',AccountId = a.id);
        insert c;
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
        insert cr;
        Condition_Report_Prescreen__c crp = new Condition_Report_Prescreen__c(Condition_Report__c = cr.id, VCI__c = c.id,Seller_Dealership__c = a.id,Vehicle__c = v.id);
        insert crp;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Name = 'Virtual Lift', Condition_Report_Prescreen__c = crp.id);
        insert pr;
        //doing this to prevent call out in setup method
        c.Virtual_Lift_Enabled__c = true;
        update c;
    }

    @isTest
    public static void testBasicClose(){
        //TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Condition_Report_Prescreen__c crp = [select id, Closed_Date__c, CR_Review_Timeout__c from Condition_Report_Prescreen__c limit 1];
        //CR_Question__c crq = new CR_Question__c(Condition_Report_Prescreen__c = crp.id, Question_Type__c = 'Virtual Lift Image Issue');
        //insert crq;
        crp.Closed_Date__c = system.today();
        crp.CR_Review_Timeout__c = false;
        Test.startTest();
        update crp;
        Test.stopTest();
        Integer passedPrescreens = [Select Count() from Contact where Successful_Virtual_Lift_Prescreens__c > 0];
        System.assert(passedPrescreens == 1, 'Counter did not fire, this many found: '+passedPrescreens);
    }

    @isTest
    public static void testBasicCloseFailure(){
        //TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Condition_Report_Prescreen__c crp = [select id, Closed_Date__c, CR_Review_Timeout__c from Condition_Report_Prescreen__c limit 1];
        CR_Question__c crq = new CR_Question__c(Condition_Report_Prescreen__c = crp.id, Question_Type__c = 'Virtual Lift Image Issue (Image Removed)');
        insert crq;
        crp.Closed_Date__c = system.today();
        crp.CR_Review_Timeout__c = false;
        Test.startTest();
        update crp;
        Test.stopTest();
        Integer passedPrescreens = [Select Count() from Contact where Successful_Virtual_Lift_Prescreens__c > 0];
        System.assert(passedPrescreens == 0, 'Counter fired, too many found: '+passedPrescreens);
    }

    @isTest
    public static void testDoubleClose(){
        //TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);
        Condition_Report__c cr = [select id from Condition_Report__c limit 1];
        Contact c = [select id from contact limit 1];
        Account a = [select id from account limit 1];
        Vehicle__c v = [select id from Vehicle__c limit 1];
        Condition_Report_Prescreen__c crp = [select id, Closed_Date__c, CR_Review_Timeout__c from Condition_Report_Prescreen__c limit 1];
        Condition_Report_Prescreen__c crp1 = new Condition_Report_Prescreen__c(Condition_Report__c = cr.id, VCI__c = c.id,Seller_Dealership__c = a.id,Vehicle__c = v.id);
        insert crp1;
        Prescreen_Reason__c pr = new Prescreen_Reason__c(Name = 'Virtual Lift', Condition_Report_Prescreen__c = crp1.id);
        insert pr;
        List<Condition_Report_Prescreen__c> updateList = new List<Condition_Report_Prescreen__c>();
        crp.Closed_Date__c = system.today();
        crp.CR_Review_Timeout__c = false;
        crp1.Closed_Date__c = system.today();
        crp1.CR_Review_Timeout__c = false;
        updateList.add(crp);
        updateList.add(crp1);
        Test.startTest();
        update updateList;
        Test.stopTest();
        Decimal passedPrescreens = [Select Id, Successful_Virtual_Lift_Prescreens__c from Contact where id = :c.id limit 1].Successful_Virtual_Lift_Prescreens__c;
        System.assert(passedPrescreens == 2, 'Counter did not fire properly, this many found: '+passedPrescreens);
    }
}