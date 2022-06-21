@isTest(isParallel=true)
private class PrescreenEmailsSchedulerTest {
    
    @testSetup static void initData(){
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Legal_Name__c = 'Test';
        acc.Dealer_Type__c = 'Franchise';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c();
        prescreen.VCI__c = con.Id;
        prescreen.Status__c = 'New';
        prescreen.VCI_Creator_Email__c = 'test@test.com';
        insert prescreen;
        
        Prescreen_Reason__c reason = new Prescreen_Reason__c();
        reason.Name = 'Exotic';
        reason.Condition_Report_Prescreen__c = prescreen.Id;
        insert reason;
        
        CR_Question__c question = new CR_Question__c();
		question.Question_Type__c = 'Exterior';
        question.Question_Sub_Type__c = 'Scratches';
        question.Condition_Report_Prescreen__c = prescreen.Id;
        insert question;
    }
    
    @isTest static void crSentToPrescreen(){
        PrescreenEmailsScheduler scheduler = new PrescreenEmailsScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
       	System.assertEquals(true, [SELECT Sent_To_Prescreen_Email__c FROM Condition_Report_Prescreen__c][0].Sent_To_Prescreen_Email__c);
    }
    
    @isTest static void crTimeout(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c][0];
        prescreen.CR_Review_Timeout__c = true;
        prescreen.Sent_To_Prescreen_Email__c = true;
        update prescreen;
        
        PrescreenEmailsScheduler scheduler = new PrescreenEmailsScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
       	System.assertEquals(true, [SELECT Time_Out_Email__c FROM Condition_Report_Prescreen__c][0].Time_Out_Email__c);
    }
    
    @isTest static void crUnderReview(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c][0];
        prescreen.Status__c = 'Under Review';
        update prescreen;
        
        PrescreenEmailsScheduler scheduler = new PrescreenEmailsScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
       	System.assertEquals(true, [SELECT Under_Review_Email__c FROM Condition_Report_Prescreen__c][0].Under_Review_Email__c);
    }
    
    @isTest static void closedWithChanges(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c][0];
        prescreen.Status__c = 'Closed';
        update prescreen;
                
        PrescreenEmailsScheduler scheduler = new PrescreenEmailsScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
       	System.assertEquals(true, [SELECT Completed_Review_Changes_Email__c FROM Condition_Report_Prescreen__c][0].Completed_Review_Changes_Email__c);
    }
    
    @isTest static void closedWithChangesButNoQuestions(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c][0];
        prescreen.Status__c = 'Closed';
        prescreen.CR_Update_by_pre_Screener__c = 'Yes';
        update prescreen;
        
        delete [select id from CR_Question__c];
        
        PrescreenEmailsScheduler scheduler = new PrescreenEmailsScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
       	System.assertEquals(true, [SELECT Completed_Review_Changes_Email__c FROM Condition_Report_Prescreen__c][0].Completed_Review_Changes_Email__c);
    }
    
    @isTest static void closedWithoutChanges(){
        Condition_Report_Prescreen__c prescreen = [SELECT Id FROM Condition_Report_Prescreen__c][0];
        prescreen.Status__c = 'Closed';
        update prescreen;
        
        delete [select id from CR_Question__c];
        
        PrescreenEmailsScheduler scheduler = new PrescreenEmailsScheduler();
        Test.startTest();
        scheduler.executeScheduledLogic();
        Test.stopTest();
        
       	System.assertEquals(true, [SELECT Completed_Reviewed_No_Changes_Email__c FROM Condition_Report_Prescreen__c][0].Completed_Reviewed_No_Changes_Email__c);
    }

}