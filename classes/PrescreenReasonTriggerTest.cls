@isTest(isParallel=false)
private class PrescreenReasonTriggerTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        insert prescreen;

        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Exotic';
        reason.Condition_Report_Prescreen__c = prescreen.Id;
        insert reason;
    }

    @isTest static void assignPrescreenToQueueInsert(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c LIMIT 1][0];

        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Arb Guard';
        reason.Condition_Report_Prescreen__c = prescreen.Id;
        
        Test.startTest();
        insert reason;
        Test.stopTest();

        System.assertNotEquals(UserInfo.getUserId(), [SELECT OwnerId FROM Condition_Report_Prescreen__c LIMIT 1][0].OwnerId);
    }

    @isTest static void assignPrescreenToQueueUpdate(){
        Prescreen_Reason__c reason = [SELECT Id FROM Prescreen_Reason__c LIMIT 1][0];
        reason.Name = 'Arb Guard';
        
        Test.startTest();
        update reason;
        Test.stopTest();

        System.assertNotEquals(UserInfo.getUserId(), [SELECT OwnerId FROM Condition_Report_Prescreen__c LIMIT 1][0].OwnerId);
    }

    @isTest static void assignPrescreenToQueueDelete(){
        Prescreen_Reason__c reason = [SELECT Id FROM Prescreen_Reason__c LIMIT 1][0];
        
        Test.startTest();
        delete reason;
        Test.stopTest();
        
        System.assertNotEquals(UserInfo.getUserId(), [SELECT OwnerId FROM Condition_Report_Prescreen__c LIMIT 1][0].OwnerId);
    }

}