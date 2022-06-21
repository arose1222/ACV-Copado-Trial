@isTest
public class AccountUpdateLogisticsFromCaseTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'seller', IST_Account_Owner__c = UserInfo.getUserId()));
        accountList.add(new Account(Name = 'buyer', IST_Account_Owner__c = UserInfo.getUserId(), Purchases_All_Time__c = 2));
        Vehicle__c newCar = new Vehicle__c(Year__c='2009',Make__c='test make', Model__c='test model', VIN__c = '1234567890102030');
        insert newCar;
        insert accountList;
        Date firstDate = System.Today().addDays(-3);
        Date secondDate = System.Today().addDays(-2);
        Date thirdDate = System.Today().addDays(-1);

        Vehicle__c car = [SELECT Id FROM Vehicle__c LIMIT 1];

        Auction__c newAuction = new Auction__c(Status__c = 'Ended_Accepted', End_Time__c = secondDate, Buyer_Dealership__c = accountList[1].Id, 
                                                Seller_Dealership__c = accountList[0].Id, Floor_Price__c = 500, Winning_Bid_Price__c = 450, Vehicle_Id__c = car.Id);
        insert newAuction;

        Auction__c caseAuc = [SELECT Id FROM Auction__c LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Case testArb = new Case(Status = 'Closed', RecordTypeId = recordTypeId, AccountId = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Origin = 'Phone',
                                                    CreatedDate = firstDate, ClosedDate = secondDate, Buyer_Confusion__c = 'No', Auction_Number__c = caseAuc.Id);
        caseList.add(testArb);
        Case testArb2 = new Case(Status = 'Closed', RecordTypeId = recordTypeId, AccountId = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Origin = 'Phone',
                                                    CreatedDate = firstDate, ClosedDate = thirdDate, Buyer_Confusion__c = 'No', Auction_Number__c = caseAuc.Id);
        caseList.add(testArb2);
        Case testArb3 = new Case(Status = 'New', RecordTypeId = recordTypeId, AccountId = accountList[1].Id, Seller_Dealership__c = accountList[0].Id, Origin = 'Phone',
                                                    CreatedDate = firstDate, Buyer_Confusion__c = 'No', Auction_Number__c = caseAuc.Id);
        caseList.add(testArb3);
        insert caseList;
        // AccountUpdateLogisticsFromCase.toggle();
        // update caseList;
    }

    @isTest
    static void mainTest() {
        List<Case> caseList = [SELECT Id FROM CASE];
        update caseList;
        List<Account> buyerAccount = [SELECT Id, Name, All_Time_Arbs__c, Date_Most_Recent_Arb__c, Date_of_Last_Purchase__c, Date_of_First_Buy__c FROM Account WHERE Name = 'buyer'];
        List<Account> sellerAccount = [SELECT Id, Name FROM Account WHERE Name = 'seller'];
        Date thirdDate = System.Today().addDays(-1);

        System.debug('All Time Arbs: ' + buyerAccount[0].All_Time_Arbs__c);
        System.debug('Date of Most Recent Arb: ' + buyerAccount[0].Date_Most_Recent_Arb__c);
        System.debug('Date of Last Purchase: ' + buyerAccount[0].Date_of_Last_Purchase__c);
        System.debug('Date of First Purchase: ' + buyerAccount[0].Date_of_First_Buy__c);

        System.assertEquals(3, buyerAccount[0].All_Time_Arbs__c);
        System.assertEquals(thirdDate, buyerAccount[0].Date_Most_Recent_Arb__c);
    }

    @isTest
    static void selfReferenceTest() {
        List<Case> caseList = [SELECT Id FROM CASE];
        update caseList;
        //Account buyerAccount = [SELECT Id, Name, All_Time_Arbs__c, Date_Most_Recent_Arb__c, IST_Account_Owner__c FROM Account WHERE Name = 'buyer'];
        Account sellerAccount = [SELECT Id, Name FROM Account WHERE Name = 'seller'];
        User newUser = [SELECT Id FROM User WHERE Name LIKE 'Paul%' LIMIT 1];
        //buyerAccount.IST_Account_Owner__c = newUser.Id;
        sellerAccount.IST_Account_Owner__c = newUser.Id;
        //update buyerAccount;
        update sellerAccount;
    }
}