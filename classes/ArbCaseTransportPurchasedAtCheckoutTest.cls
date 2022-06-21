@isTest
private class ArbCaseTransportPurchasedAtCheckoutTest {
    public static final Id arbId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Salesforce_Setting__mdt setting = [SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Transportation Case SF Consumer Name' LIMIT 1];
        User user = [SELECT Id FROM User WHERE Name = :setting.Value__c];

        List<Account> acctList = new List<Account>();
        acctList.add(TestUtility.createAccount('Test 1'));
        acctList.add(TestUtility.createAccount('Test 2'));
        insert acctList;

        List<Contact> contList = new List<Contact>();
        contList.add(TestUtility.createContact(acctList[0]));
        contList.add(TestUtility.createContact(acctList[1]));
        insert contList;

        List<Vehicle__c> vehList = new List<Vehicle__c>();
        vehList.add(TestUtility.createVehicle());
        vehList.add(TestUtility.createVehicle());
        insert vehList;

        List<Auction__c> aucList = new List<Auction__c>();
        aucList.add(TestUtility.createAuctionWithUniqueId(acctList[0], contList[0], vehList[0])); //need an account, contact and vehicle for each ... maybe only a vehicle?
        aucList.add(TestUtility.createAuctionWithUniqueId(acctList[1], contList[1], vehList[1])); //are these going to have two different id's or no? it doesn't look like it...
        insert aucList;

        Transportation_Address__c add = TestUtility.createAddress();
        insert add;

        //need an auction with a transportation case created by ACV Integration
        Case transCase1 = TestUtility.createTransportCase(add, acctList[0], contList[0], aucList[0]);
        System.runAs(user) { 
            insert transCase1;
        }
        //need an auction with a transportation case created by someone else - the user running the test?
        Case transCase2 = TestUtility.createTransportCase(add, acctList[1], contList[1], aucList[1]);
        insert transCase2;
    }

    @isTest
    static void testInsertArbs() {
        List<Account> acctList = [SELECT Id, Name FROM Account ORDER BY Name ASC];
        List<Contact> contList = [SELECT Id FROM Contact];
        List<Vehicle__c> vehList = [SELECT Id FROM Vehicle__c]; //can i order this by anything?
        List<Auction__c> aucList = [SELECT Id FROM Auction__c]; //can i order this by anything? i need to know which one is the one with the 'good' transpo case
        //create and insert two arb cases for the two Auctions above. one should have the checkbox checked, the other should not
        List<Case> arbList = new List<Case>();
        arbList.add(new Case (RecordTypeId = arbId, Origin = 'Phone')); //TestUtility.createCase(aucList[0], vehList[0], acctList[0], contList[0])
        arbList.add(new Case (RecordTypeId = arbId, Origin = 'Phone')); //TestUtility.createCase(aucList[1], vehList[1], acctList[1], contList[1])
        insert arbList;
        for (Integer i = 0; i < 2; i ++) { //doing it this way so i can use i
            arbList[i].Auction_Number__c=aucList[i].Id;
            arbList[i].Description='Description Test';
            arbList[i].Origin='Email';
            arbList[i].Priority='High';
            arbList[i].Status='New';
            arbList[i].Subject='Testing';
            arbList[i].Vehicle__c=vehList[i].Id;
            arbList[i].Type = 'Arbitration';
            arbList[i].AccountId = acctList[i].Id;
            arbList[i].ContactId = contList[i].Id;
            arbList[i].Seller_Dealership__c = acctList[i].Id;
            arbList[i].Buyer_Confusion__c = 'No';
        }

        Test.startTest();
            update arbList;
        Test.stopTest();

        //system.asserts
        for (Case a : [SELECT Id, ACV_Transport_Purchased_at_Checkout__c, Account.Name FROM Case WHERE RecordType.DeveloperName = 'Arbitration_Claim' LIMIT 2]) {
            if (a.Account.Name == 'Test 1') {
                System.assertEquals(true, a.ACV_Transport_Purchased_at_Checkout__c);
            }
            else {
                System.assertEquals(false, a.ACV_Transport_Purchased_at_Checkout__c);
            }
        }
    }
}