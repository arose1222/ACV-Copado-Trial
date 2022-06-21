@isTest
public class TseRequestTriggerHandlerTest {
    private static final String USER_NAME = 'vciUser';
    public static final Date DATE_TODAY = Date.today();
    public static final Date DATE_NEXT_WEEK = Date.today().addDays(7);
    public static final DateTime DT_NOW = Datetime.now();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = new ServiceTerritory( Name = 'Great Lakes', OperatingHoursId = oh.Id, IsActive = TRUE );
        insert st1;

        ServiceResource sr1 = FSLTestUtility.makeResourceData();

        TimeSheet ts = new TimeSheet(ServiceResourceId=sr1.id, StartDate = DATE_TODAY, EndDate = DATE_NEXT_WEEK);
        insert ts;

    }

    @isTest
    public static void testWorkEntry(){
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TSE_Request__c tser = new TSE_Request__c(Action__c = 'Work Entry', Type__c = 'Work In Progress');
            insert tser;
        }
        Test.stopTest();
        TimeSheet ts = [SELECT Id FROM Timesheet LIMIT 1];
        List<TimeSheetEntry> tseList = [SELECT id FROM TimeSheetEntry WHERE TimeSheetId = :ts.id];
        system.assert(tseList.size()>0);
        
    }

    @isTest
    public static void testClockIn(){
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TSE_Request__c tser = new TSE_Request__c(Action__c = 'Clock In');
            insert tser;
        }
        Test.stopTest();
        TimeSheet ts = [SELECT Id FROM Timesheet LIMIT 1];
        List<TimeSheetEntry> tseList = [SELECT id FROM TimeSheetEntry WHERE TimeSheetId = :ts.id];
        system.assert(tseList.size()>0);
    }
    @isTest
    public static void testClockOut(){
        
        TimeSheet ts = [SELECT Id FROM Timesheet LIMIT 1];
        TimeSheetEntry tse = new TimeSheetEntry(Status = 'New',StartTime = DT_NOW,Type = 'Idle',TimeSheetId = ts.id);
        insert tse;

        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TSE_Request__c tser = new TSE_Request__c(Action__c = 'Clock Out');
            insert tser;
        }
        Test.stopTest();
        List<TimeSheetEntry> tseList = [SELECT id, EndTime FROM TimeSheetEntry WHERE TimeSheetId = :ts.id];
        system.assert(tseList[0].EndTime != null);

    }
    @isTest
    public static void testInterrupt(){
        
        TimeSheet ts = [SELECT Id FROM Timesheet LIMIT 1];
        TimeSheetEntry tse = new TimeSheetEntry(Status = 'New',StartTime = DT_NOW,Type = 'Idle',TimeSheetId = ts.id);
        insert tse;

        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TSE_Request__c tser = new TSE_Request__c(Action__c = 'Interrupt Activity');
            insert tser;
        }
        Test.stopTest();
        List<TimeSheetEntry> tseList = [SELECT id, EndTime, Interrupted_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.id];
        Integer interruptedCount = 0;
        for(TimeSheetEntry queriedEntry : tseList){
            if(queriedEntry.Interrupted_Entry__c != null){
                interruptedCount++;
            }
        }
        system.assert(interruptedCount>0);
    }
    @isTest
    public static void testResume(){
        TimeSheet ts = [SELECT Id FROM Timesheet LIMIT 1];

        TimeSheetEntry tse = new TimeSheetEntry(Status = 'New',StartTime = DT_NOW,Type = 'Idle',TimeSheetId = ts.id);
        insert tse;

        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u = [SELECT Id FROM User WHERE Id = :sr.RelatedRecordId LIMIT 1];
        Test.startTest();
        System.runAs(u){
            TSE_Request__c tser1 = new TSE_Request__c(Action__c = 'Interrupt Activity');
            insert tser1;
            TSE_Request__c tser2 = new TSE_Request__c(Action__c = 'Resume Activity');
            insert tser2;
        }
        Test.stopTest();
        Integer workOrderIdCount = 0;
        List<TimeSheetEntry> tseList = [SELECT id, Type FROM TimeSheetEntry WHERE TimeSheetId = :ts.id];
        for(TimeSheetEntry queriedEntry : tseList){
            if(queriedEntry.Type == 'Idle'){
                workOrderIdCount++;
            }
        }
        system.assert(workOrderIdCount==2);

        
    }

}