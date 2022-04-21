@isTest
public class TitleLateFeeSchedulerTest {
    
    @isTest
    public static void  testSchedule() {        
        Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
        insert aFee;
        
        Test.StartTest();        
            TitleLateFeeScheduler sh1 = new TitleLateFeeScheduler();      
            sh1.executeScheduledLogic();
        Test.stopTest();
    }
}