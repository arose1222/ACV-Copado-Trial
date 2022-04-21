@isTest
public class VehicleSoldOrArbedPreviouslyTest {
    private static string mockDataLocalString = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"Vehicle__r.Make__c","Trigger_Value__c":"Saab","Value_Type__c":"String"}]';
    
    @TestSetup
    static void makeData() {
        Account a = new Account(Name = 'ACV');
        insert a;
        Contact c = new Contact(FirstName = 'Jinx', LastName = 'Best VCI', AccountId = a.id);
        insert c;

        List<Vehicle__c> vehList = new List<Vehicle__c>();
        vehList.add(new Vehicle__c(id__c = '123', VIN__c = '1234567890', Make__c = 'Saab'));
        vehList.add(new Vehicle__c(id__c = '124', VIN__c = '0987654321', Make__c = 'Saab'));
        insert vehList;

        Auction__c au = TestUtility.createAuctionWithUniqueId(a, c, vehList[0]);
        insert au;

        Case arb = TestUtility.createCase(au, vehList[0], a, c);
        insert arb;
    }

    @isTest
    static void testInsertNewCR() {
        Account a = [SELECT Id FROM Account];
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalString, List<CR_Review_Trigger__mdt>.class);

        List<Vehicle__c> vehList = [SELECT Id FROM Vehicle__c ORDER BY Vin__c ASC];

        List<Condition_Report__c> crList = new List<Condition_Report__c>();
        crList.add(new Condition_Report__c(Name = 'Test 1', ACV_Saved_Auction_Id__c = '890', Floor_Price__c = 1, Vehicle__c = vehList[0].Id, VIN__c = '1234567890', Dealership__c = a.Id)); //, VIN__c = '1234567890'
        crList.add(new Condition_Report__c(Name = 'Test 2', ACV_Saved_Auction_Id__c = '098', Floor_Price__c = 1, Vehicle__c = vehList[1].Id, VIN__c = '0987654321', Dealership__c = a.Id)); //, VIN__c = '0987654321'

        Test.startTest();
            insert crList;
        Test.stopTest();

        List<Condition_Report_Prescreen__c> crpList = [SELECT Id, Previous_Auction_Run__c, Previously_Arbitrated__c FROM Condition_Report_Prescreen__c ORDER BY Vehicle__r.VIN__c ASC];
        System.assertEquals(true, crpList[0].Previous_Auction_Run__c);
        System.assertEquals(true, crpList[0].Previously_Arbitrated__c);
        System.assertEquals(false, crpList[1].Previous_Auction_Run__c);
        System.assertEquals(false, crpList[1].Previously_Arbitrated__c);
    }
}