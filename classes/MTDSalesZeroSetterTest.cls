@isTest
public class MTDSalesZeroSetterTest {
    @isTest
    static void batchTest() {
        //get ID of transporter accounts
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Transporters').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        //need a few accouns with MTD_Sales__c null
        accountList.add(new Account(Name = '1', MTD_Sales__c = null, Dealer_Type__c = '1', legal_name__c = '1')); //have to set this as null to mimic what is in prod
        accountList.add(new Account(Name = '2', MTD_Sales__c = null, Dealer_Type__c = '1', legal_name__c = '2')); //have to set this as null to mimic what is in prod
        //one that is a transporter
        accountList.add(new Account(Name = '3', No_DOT__c = true, RecordTypeId = recordTypeId, MTD_Sales__c = null)); //have to set this as null to mimic what is in prod
        //otherwise it would populate as zero because that's the default
        //one with it as 0 (these should not be picked up in batch)
        accountList.add(new Account(Name = '4', MTD_Sales__c = 0, Dealer_Type__c = '1', legal_name__c = '4'));
        //one with it as 3 (these should not be picked up in batch)
        accountList.add(new Account(Name = '5', MTD_Sales__c = 3, Dealer_Type__c = '1', legal_name__c = '5'));
        //insert accounts
        insert accountList;

        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            MTDSalesZeroSetter batch = new MTDSalesZeroSetter();
            Batch.execute(sc);
        Test.stopTest();

        //query
        List<Account> accountListCheck = [SELECT Id, MTD_Sales__c, RecordTypeId, Name FROM Account ORDER BY Name ASC];
        //system.asserts
        System.assertEquals(0, accountListCheck[0].MTD_Sales__c);
        System.assertEquals(0, accountListCheck[1].MTD_Sales__c);
        System.assertEquals(null, accountListCheck[2].MTD_Sales__c);
        System.assertEquals(0, accountListCheck[3].MTD_Sales__c);
        System.assertEquals(3, accountListCheck[4].MTD_Sales__c);
    }

    @isTest
    static void bulkTest() {
        //create 50 accounts
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 50; i ++) {
            bulkAccounts.add(new Account(Name = 'Account' + i));
        }
        //insert accounts
        insert bulkAccounts;

        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            MTDSalesZeroSetter batch = new MTDSalesZeroSetter();
            Batch.execute(sc);
        Test.stopTest();
    }
}