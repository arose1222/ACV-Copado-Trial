@isTest
public class AccountUpdateLogisticsMonthlyBatchTest {
    @TestSetup
    static void makeData(){
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'test1', legal_name__c='test1', dealer_type__c='1', IST_Account_Owner__c = UserInfo.getUserId(), MTD_Purchases__c = 6, Purchase_Last_Month__c = 4));
        accountList.add(new Account(Name = 'test2', legal_name__c='test2', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), MTD_Purchases__c = 5, Purchase_Last_Month__c = 0));
        accountList.add(new Account(Name = 'test3', legal_name__c='test3', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), MTD_Purchases__c = 0, Purchase_Last_Month__c = 3));
        accountList.add(new Account(Name = 'test4', legal_name__c='test4', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), MTD_Purchases__c = 0, Purchase_Last_Month__c = 0));
        accountList.add(new Account(Name = 'test5', legal_name__c='test5', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), MTD_Purchases__c = null, Purchase_Last_Month__c = null));
        accountList.add(new Account(Name = 'test6', legal_name__c='test6', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), MTD_Sales__c = 2));
        insert accountList;
    }

    @isTest
    static void batchTest() {
        Test.startTest();
            SchedulableAccountUpdateLogistics schClass = new SchedulableAccountUpdateLogistics();
            String schedule = '0 0 23 * * ?';
            System.schedule('Test Account Update Check', schedule, schClass);
        //Test.stopTest(); 
            //String batchQuery = 'SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c FROM Account WHERE MTD_Purchases__c != NULL AND Purchase_Last_Month__c != NULL AND ((MTD_Purchases__c != 0) OR (Purchase_Last_Month__c != 0))';
            //'SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c FROM Account WHERE MTD_Purchases__c != NULL AND Purchase_Last_Month__c != NULL AND ((MTD_Purchases__c = 0 AND Purchase_Last_Month__c != 0) OR (MTD_Purchases__c != 0 AND Purchase_Last_Month__c = 0) OR (MTD_Purchases__c != 0 AND Purchase_Last_Month__c != 0))';
			AccountUpdateLogisticsMonthlyBatch aulmb = new AccountUpdateLogisticsMonthlyBatch();
			Database.executeBatch(aulmb, 200);
		Test.stopTest();

        List<Account> query = [SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c, MTD_Sales__c FROM Account ORDER BY Name ASC];

        System.assertEquals(6, query[0].Purchase_Last_Month__c);
        System.assertEquals(0, query[0].MTD_Purchases__c);
        System.assertEquals(5, query[1].Purchase_Last_Month__c);
        System.assertEquals(0, query[1].MTD_Purchases__c);
        System.assertEquals(0, query[2].Purchase_Last_Month__c);
        System.assertEquals(0, query[2].MTD_Purchases__c);
        System.assertEquals(0, query[3].Purchase_Last_Month__c);
        System.assertEquals(0, query[3].MTD_Purchases__c);
        System.assertEquals(null, query[4].Purchase_Last_Month__c);
        System.assertEquals(null, query[4].MTD_Purchases__c);
        System.assertEquals(0, query[5].MTD_Sales__c);
    }
}