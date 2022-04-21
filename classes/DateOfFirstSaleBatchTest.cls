@isTest
public class DateOfFirstSaleBatchTest {
    @isTest
    static void batchTest() {
        //need a date (endTime)
        DateTime firstDate = DateTime.newInstance(2019, 11, 15, 6, 0, 0);
        DateTime secondDate = firstDate.addDays(-1);
        //get ID of transporter accounts
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        //need accounts with blank DateOfFirstSale and one of the accounts needs to be a transporter account
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(name = '1', legal_name__c='1', dealer_type__c='1')); //seller for one auction
        accountList.add(new Account(name = '2', legal_name__c='2', dealer_type__c='2')); //seller for two auctions
        accountList.add(new Account(name = '3', No_DOT__c = true, RecordTypeId = recordTypeId)); //this is the transporter
        //insert accounts
        insert accountList;
        //need auction where the sellers where they are the accounts that we made
        List<Auction__c> auctionList = new List<Auction__c>();
        auctionList.add(new Auction__c(Name = '1111', Status__c = 'Ended_Accepted', end_time__c = firstDate, seller_dealership__c = accountList[0].Id));
        auctionList.add(new Auction__c(Name = '2222', Status__c = 'Counter_Accepted', end_time__c = secondDate, seller_dealership__c = accountList[1].Id));
        auctionList.add(new Auction__c(Name = '3333', Status__c = 'Counter_Original_Accepted', end_time__c = firstDate, seller_dealership__c = accountList[1].Id));
        auctionList.add(new Auction__c(Name = '4444', Status__c = 'Ended_Accepted', end_time__c = firstDate, seller_dealership__c = accountList[2].Id)); //should not have transporter as seller, but testing that batch doesn't accept them
        //insert auctions
        insert auctionList;
        //call batch
        Test.startTest();
            SchedulableContext sc = null;
            DateOfFirstSaleBatch batch = new DateOfFirstSaleBatch();
            Batch.execute(sc);
        Test.stopTest();
        //query
        List<Account> checkAccountList = [SELECT date_of_first_sale__c FROM Account ORDER BY Name ASC];
        System.debug(checkAccountList);
        //system.asserts
        system.assertEquals(firstDate.date(), checkAccountList[0].date_of_first_sale__c);
        system.assertEquals(secondDate.date(), checkAccountList[1].date_of_first_sale__c);
        system.assertEquals(null, checkAccountList[2].date_of_first_sale__c);
    }

    //@isTest
    static void bulkTest(){
        //need date
        Date today = System.Today();
        //create 200 accounts
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 50; i ++) {
            bulkAccounts.add(new Account(Name = 'Account' + i));
        }
        //insert accounts
        insert bulkAccounts;
        //create 200 auctions
        List<Auction__c> bulkAuctions = new List<Auction__c>();
        for (Integer i = 0; i < 50; i++){
            bulkAuctions.add(new Auction__c(Name = 'Auction'+i, Status__c = 'Ended_Accepted', end_time__c = today, seller_dealership__c = bulkAccounts[i].Id));
        }
        //insert auctions
        insert bulkAuctions;
        //call batch
        Test.startTest();
            SchedulableContext sc = null;
            DateOfFirstSaleBatch batch = new DateOfFirstSaleBatch();
            Batch.execute(sc);
        Test.stopTest();
    }
}