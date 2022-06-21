@isTest
public class LimitLogTest {
    
    //     @TestSetup
    // static void makeData() {
    //     TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        
    //     insert u;
    //     PermissionSet ps = [Select Id from PermissionSet where Name = 'System_Administrator_Extended' limit 1];
    //     PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);
    //     insert psa;
    // }

    @isTest
    public static void testLogOrgLimits(){
        User u = TestUtility.createSystemAdministratorUser();
        
        //User u = [Select id from User where email = 'test@AcvAuctions.com' limit 1];
        System.runAs(u){
            LimitLog.logOrgLimits();
        }
        //check to see if we can do an assert on code limits to see if a call out was made
        //system.assert([select id from Limit__c].size() > 0,'No Limit__c records found');
    }

    @isTest
    public static void testOrgLimitSchedulable(){
        Test.startTest();
            orgLimitLogSchedulable schLimitJob = new orgLimitLogSchedulable();
            schLimitJob.executeScheduledLogic();
        Test.stopTest();

        //String jobId = ACVUtility.scheduleJob(System.now().addMinutes(5),'orgLimitLogSchedulable');
        //List<CronTrigger> ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; - No longer a scheduled job
        //system.assertEquals(1, ct.size(), 'only found a single job');
    }
}