@isTest
public class CRQueueControllerTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        //Account a = new Account(Name='Bill Test', Active__c = true,legal_Name__c='Bill Test', dealer_type__c='1',phone = '1234567890',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        Account a = testUtility.createAccount();
        insert a;
        //Contact c = new Contact(FirstName = 'Bill', LastName = 'Test', AccountId = a.id, CR_Review__c = true, email='test@email.com', Prescreen_Type__c = 'New');
        Contact c = testUtility.createContact(a);
        c.CR_Review__c = true;
        c.Prescreen_Type__c ='New';
        insert c;
    }

    @IsTest
    static void getReasonListTest(){
        
        String Reasons = CRQueueController.getCRReasons();
        List<LWCUtility.Picklist> lwcList = (List<LWCUtility.Picklist>) JSON.deserialize(Reasons, List<LWCUtility.Picklist>.class);
        system.assert(lwcList.size() > 0, 'no active rules found');
    }

    @isTest
    static void getPrescreensTest(){
        Vehicle__c v = [select id from Vehicle__c limit 1];
        Contact c = [select id from contact limit 1];
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 1, vehicle__c = v.id, VCI_Creator__c = c.id, VIN__c = '123jf3245432234');
        insert cr;

        List<Condition_Report_Prescreen__c> crList = CRQueueController.getPrescreens();
        System.assert(crList.size() == 1, 'incorrect number of prescreens returned');
    }

    @isTest
    static void getPrescreensTestNoResult(){
        List<Condition_Report_Prescreen__c> crList = CRQueueController.getPrescreens();
        System.assert(crList.size() == 0, 'incorrect number of prescreens returned');
    }
}