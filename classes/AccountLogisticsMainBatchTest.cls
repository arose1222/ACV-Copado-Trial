@isTest
public class AccountLogisticsMainBatchTest {
    //most of the testing for this ius handled in AccountUpdateLogisticsFromAuctionTest
    @isTest
    static void errorCheck() { //this should get code coverage for the error portion of the batch
        //populate errorList
        AccountUpdateLogisticsFromAuction.accountErrorList.add('error');
        //run batch
        Test.startTest();
            SchedulableContext sc = null;
            AccountLogisticsMainBatch batch = new AccountLogisticsMainBatch();
            Batch.execute(sc);
        Test.stopTest();
    }
}