@isTest(isParallel=true)
private class PrescreenClosingSchedulerTest {
    
    @isTest static void executeScheduledLogicLessThan30(){
        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        insert prescreen;

        Test.setCreatedDate(prescreen.Id, Datetime.now().addMinutes(-25));
        
        PrescreenClosingScheduler scheduler = new PrescreenClosingScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
        System.assertNotEquals('Closed', [SELECT Status__c FROM Condition_Report_Prescreen__c][0].Status__c);
    }
    
    @isTest static void executeScheduledLogicLessThan60(){
        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        insert prescreen;

        Test.setCreatedDate(prescreen.Id, Datetime.now().addMinutes(-35));
        
        PrescreenClosingScheduler scheduler = new PrescreenClosingScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
        System.assertEquals('Closed', [SELECT Status__c FROM Condition_Report_Prescreen__c][0].Status__c);
    }

}