@isTest
private with sharing class PrescreenReasonTriggerHandlerTest {
    
    @TestSetup
    static void initData(){
        Condition_Report__c report = new Condition_Report__c();
        report.Name = 'Test';
        report.ACV_Saved_Auction_Id__c = '1638529';
        report.CR_Doc_Complete__c = true;
        report.Floor_Price__c = 1;
        insert report;

        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.Condition_Report__c = report.Id;
        insert prescreen;
    }

    @isTest static void afterInsert(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c];

        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Arb Guard';
        reason.Condition_Report_Prescreen__c = prescreen.Id;

        Test.startTest();
        insert reason;
        Test.stopTest();
    }

    @isTest static void afterUpdate(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c];

        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Arb Guard';
        reason.Condition_Report_Prescreen__c = prescreen.Id;
        insert reason;

        Test.startTest();
        reason.Name = 'Exotic';
        Test.stopTest();
    }

    @isTest static void afterDelete(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c];

        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Arb Guard';
        reason.Condition_Report_Prescreen__c = prescreen.Id;
        insert reason;

        Test.startTest();
        delete reason;
        Test.stopTest();
    }

}