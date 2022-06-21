@isTest
public class MarkPrescreenAsLaunchedTest {
    
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
        insert cr;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(cr,a,c);
        crp.status__c = 'New';
        insert crp;
    }

    @isTest
    static void testCRUpdateToHaveAuction(){
        List<Condition_Report__c> crList = [select id, ACV_Auction_Id__c from Condition_Report__c];
        system.debug([select id, Status__c from Condition_Report_Prescreen__c]);
        if(crList.size() > 0){
            crList[0].ACV_Auction_Id__c = '123';
            update crList;
        }

        system.assert([select id from Condition_Report_Prescreen__c where Launched_Before_Prescreen__c = true].size() > 0, 'No Prescreens Returned');
    }

    @isTest
    static void testCRUpdateToHaveAuctionButPrescreenFinished(){
        List<Condition_Report_Prescreen__c> crpList = [select id, Status__c,CR_Update_by_pre_Screener__c from Condition_Report_Prescreen__c];
        if(crpList.size() > 0){
            crpList[0].Status__c = 'Closed';
            crpList[0].CR_Update_by_pre_Screener__c = 'No';
            update crpList;
        }
        List<Condition_Report__c> crList = [select id, ACV_Auction_Id__c from Condition_Report__c];
        if(crList.size() > 0){
            crList[0].ACV_Auction_Id__c = '123';
            update crList;
        }

        system.assert([select id from Condition_Report_Prescreen__c where Launched_Before_Prescreen__c = TRUE].size() < 1, 'Prescreens Returned');
    }
}