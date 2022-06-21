@isTest
public class VehicleSoldOrArbedPreviouslyCRUpdateTest {
    private static string mockDataLocalString = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"Vehicle__r.Make__c","Trigger_Value__c":"Saab","Value_Type__c":"String"}]';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = new Account(Name = 'ACV');
        insert a;
        Contact c = new Contact(FirstName = 'Jinx', LastName = 'Best VCI', AccountId = a.Id);
        insert c;

        Vehicle__c v = new Vehicle__c(Id__c = '123', VIN__c = '1234567890', Make__c = 'Saab');
        insert v;

        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, v);
        insert au;

        Case arb = TestUtility.createCase(au, v, a, c);
        insert arb;
    }

    @isTest
    static void testUpdateCR() {
        Account a = [SELECT Id FROM Account];
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalString, List<CR_Review_Trigger__mdt>.class);

        Vehicle__c v = [SELECT Id FROM Vehicle__c LIMIT 1];

        Condition_Report__c cr = new Condition_Report__c(Name = 'Test 1', ACV_Saved_Auction_Id__c = '890', Floor_Price__c = 1, Vehicle__c = v.Id, VIN__c = '0987654321', Dealership__c = a.Id);
        insert cr;

        Condition_Report_Prescreen__c crp = [SELECT Id, Previous_Auction_Run__c, Previously_Arbitrated__c FROM Condition_Report_Prescreen__c LIMIT 1];
        System.assertEquals(false, crp.Previous_Auction_Run__c);
        System.assertEquals(false, crp.Previously_Arbitrated__c);

        cr.VIN__c = '1234567890';

        Test.startTest();
            update cr;
        Test.stopTest();

        Condition_Report_Prescreen__c crp2 = [SELECT Id, Previous_Auction_Run__c, Previously_Arbitrated__c FROM Condition_Report_Prescreen__c LIMIT 1];
        System.assertEquals(true, crp2.Previous_Auction_Run__c);
        System.assertEquals(true, crp2.Previously_Arbitrated__c);
    }

    @isTest
    static void testClosedCRP() {
        Account a = [SELECT Id FROM Account];
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalString, List<CR_Review_Trigger__mdt>.class);

        Vehicle__c v = [SELECT Id FROM Vehicle__c LIMIT 1];

        Condition_Report__c cr = new Condition_Report__c(Name = 'Test 1', ACV_Saved_Auction_Id__c = '890', Floor_Price__c = 1, Vehicle__c = v.Id, VIN__c = '0987654321', Dealership__c = a.Id);
        insert cr;

        Condition_Report_Prescreen__c crp = [SELECT Id, Previous_Auction_Run__c, Previously_Arbitrated__c, Status__c FROM Condition_Report_Prescreen__c LIMIT 1];
        System.assertEquals(false, crp.Previous_Auction_Run__c);
        System.assertEquals(false, crp.Previously_Arbitrated__c);

        crp.Status__c = 'Closed';
        crp.CR_Update_by_pre_Screener__c = 'Yes';
        update crp;

        cr.VIN__c = '1234567890';

        Test.startTest();
            update cr;
        Test.stopTest();

        Condition_Report_Prescreen__c crp2 = [SELECT Id, Previous_Auction_Run__c, Previously_Arbitrated__c FROM Condition_Report_Prescreen__c LIMIT 1];
        System.assertEquals(false, crp2.Previous_Auction_Run__c);
        System.assertEquals(false, crp2.Previously_Arbitrated__c); //these should not update because the CRP record is closed
    }
}