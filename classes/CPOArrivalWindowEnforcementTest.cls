/**
 * @description Test class for CPOArrivalWindowEnforcement that ensures the Optimizer cannot schedule CPO Service Appointments to start outside of 9am to 2pm local time.
 * @author Matthew Fritschi
 * @since 4/4/2022
 * @group Inspector Dispatch
 */
@isTest
public class CPOArrivalWindowEnforcementTest {
    
    @TestSetup
    static void setUp(){
        insert FSLTestUtility.createWorkTypes();

        List<OperatingHours> ohList = new List<OperatingHours>();
        OperatingHours oh = new OperatingHours();
        oh.Name = 'vciTest';
        oh.TimeZone = 'America/New_York';
        ohList.add(oh);

        OperatingHours oh2 = new OperatingHours();
        oh2.Name = 'vciTest2';
        oh2.TimeZone = 'America/Chicago';
        ohList.add(oh2);
        insert ohList;

        List<ServiceTerritory> stParents = new List<ServiceTerritory>();
        ServiceTerritory stParent = new ServiceTerritory();
        stParent.Name = 'vciParent';
        stParent.IsActive = true;
        stParent.OperatingHoursId = oh.Id;
        stParents.add(stParent);
        
        ServiceTerritory stParent2 = new ServiceTerritory();
        stParent2.Name = 'vciParen2t';
        stParent2.IsActive = true;
        stParent2.OperatingHoursId = oh2.Id;
        stParents.add(stParent2);
        insert stParents;

        List<ServiceTerritory> sts = new List<ServiceTerritory>();
        ServiceTerritory st = new ServiceTerritory();
        st.ParentTerritoryId = stParent.Id;
        st.Name = 'vciTest';
        st.IsActive = true;
        st.OperatingHoursId = oh.Id;
        sts.add(st);
        
        ServiceTerritory st2 = new ServiceTerritory();
        st2.ParentTerritoryId = stParent2.Id;
        st2.Name = 'vciTest2';
        st2.IsActive = true;
        st2.OperatingHoursId = oh2.Id;
		sts.add(st2);
        insert sts;

        List<Account> accts = new List<Account>();
        Account ac = TestUtility.createAccount();
        ac.Name = 'vciTest';
        ac.Service_Territory__c = st.Id;
        accts.add(ac);
        
        Account ac2 = TestUtility.createAccount();
        ac2.Name = 'vciTest2';
        ac2.Service_Territory__c = st2.Id;
        accts.add(ac2);
		insert accts;
    }

    @IsTest
    static void testLocalTimezoneSuccess() {
        User scheduler = [SELECT Id, Name FROM User WHERE Name = 'FSL Optimization' LIMIT 1];
        WorkType wt = FSLWorkProcessUtility.availableWTMap.get( 'cpogm' );
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'vciTest' LIMIT 1];
        ServiceTerritory st = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'vciTest' LIMIT 1];
        FSL_Work_Type_Arrival_Window__mdt arrivalWindow = [SELECT Label, Active__c, Earliest_Start_Time__c FROM FSL_Work_Type_Arrival_Window__mdt WHERE Label = 'cpo' LIMIT 1];
        List<String> startTimes = arrivalWindow.Earliest_Start_Time__c.split(':');

        WorkOrder wo = FSLTestUtility.createWorkOrder(wt, acct, '14224', st, null);
        insert wo;
        ServiceAppointment sa = [SELECT Id, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];

        Date targetDate = System.Date.today();
        Time targetStartTime = Time.newInstance(Integer.valueOf(startTimes[0]), Integer.valueOf(startTimes[1]), 0, 0);
        Time targetEndTime = Time.newInstance(Integer.valueOf(startTimes[0]) + 1, Integer.valueOf(startTimes[1]), 0, 0);
        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
        Integer offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;
        Datetime startTime = Datetime.newInstanceGmt(targetDate, targetStartTime).addSeconds(-offsetSeconds);
        Datetime endTime = Datetime.newInstanceGmt(targetDate, targetEndTime).addSeconds(-offsetSeconds);

        Test.startTest();
        System.runAs(scheduler) {
            sa.SchedStartTime = startTime;
            sa.SchedEndTime = endTime;
            update sa;
        }
        Test.stopTest();

        sa = [SELECT Id, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id = :sa.Id];
        System.assertEquals(startTime, sa.SchedStartTime);
    }

    @IsTest
    static void testLocalTimezoneError() {
        User scheduler = [SELECT Id, Name FROM User WHERE Name = 'FSL Optimization' LIMIT 1];
        WorkType wt = FSLWorkProcessUtility.availableWTMap.get( 'cpogm' );
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'vciTest' LIMIT 1];
        ServiceTerritory st = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'vciTest' LIMIT 1];
        FSL_Work_Type_Arrival_Window__mdt arrivalWindow = [SELECT Label, Active__c, Earliest_Start_Time__c FROM FSL_Work_Type_Arrival_Window__mdt WHERE Label = 'cpo' LIMIT 1];
        List<String> startTimes = arrivalWindow.Earliest_Start_Time__c.split(':');

        WorkOrder wo = FSLTestUtility.createWorkOrder(wt, acct, '14224', st, null);
        insert wo;
        ServiceAppointment sa = [SELECT Id, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];
		
        String returnedError = '';
        Date targetDate = System.Date.today();
        Time targetStartTime = Time.newInstance(Integer.valueOf(startTimes[0]) - 1, Integer.valueOf(startTimes[1]), 0, 0);
        Time targetEndTime = Time.newInstance(Integer.valueOf(startTimes[0]), Integer.valueOf(startTimes[1]), 0, 0);
        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
        Integer offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;
        Datetime startTime = Datetime.newInstanceGmt(targetDate, targetStartTime).addSeconds(-offsetSeconds);
        Datetime endTime = Datetime.newInstanceGmt(targetDate, targetEndTime).addSeconds(-offsetSeconds);

        Test.startTest();
        System.runAs(scheduler) {
            sa.SchedStartTime = startTime;
            sa.SchedEndTime = endTime;
            try {
                update sa;
            }
            catch (Exception e) {
                returnedError = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(returnedError.contains('CPO Service Appointments must be scheduled between 9am and 2pm.'));
    }

    @IsTest
    static void testOtherTimezoneSuccess() {
        User scheduler = [SELECT Id, Name FROM User WHERE Name = 'FSL Optimization' LIMIT 1];
        WorkType wt = FSLWorkProcessUtility.availableWTMap.get( 'cpogm' );
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'vciTest2' LIMIT 1];
        ServiceTerritory st = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'vciTest2' LIMIT 1];
        FSL_Work_Type_Arrival_Window__mdt arrivalWindow = [SELECT Label, Active__c, Earliest_Start_Time__c FROM FSL_Work_Type_Arrival_Window__mdt WHERE Label = 'cpo' LIMIT 1];
        List<String> startTimes = arrivalWindow.Earliest_Start_Time__c.split(':');

        WorkOrder wo = FSLTestUtility.createWorkOrder(wt, acct, '14224', st, null);
        insert wo;
        ServiceAppointment sa = [SELECT Id, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];

        Date targetDate = System.Date.today();
        Time targetStartTime = Time.newInstance(Integer.valueOf(startTimes[0]) + 1, Integer.valueOf(startTimes[1]), 0, 0);
        Time targetEndTime = Time.newInstance(Integer.valueOf(startTimes[0]) + 2, Integer.valueOf(startTimes[1]), 0, 0);
        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
        Integer offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;
        Datetime startTime = Datetime.newInstanceGmt(targetDate, targetStartTime).addSeconds(-offsetSeconds);
        Datetime endTime = Datetime.newInstanceGmt(targetDate, targetEndTime).addSeconds(-offsetSeconds);

        Test.startTest();
        System.runAs(scheduler) {
            sa.SchedStartTime = startTime;
            sa.SchedEndTime = endTime;
            update sa;
        }
        Test.stopTest();

        sa = [SELECT Id, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Id = :sa.Id];
        System.assertEquals(startTime, sa.SchedStartTime);
    }

    @IsTest
    static void testOtherTimezoneError() {
        User scheduler = [SELECT Id, Name FROM User WHERE Name = 'FSL Optimization' LIMIT 1];
        WorkType wt = FSLWorkProcessUtility.availableWTMap.get( 'cpogm' );
        Account acct = [SELECT Id, Name FROM Account WHERE Name = 'vciTest2' LIMIT 1];
        ServiceTerritory st = [SELECT Id, Name FROM ServiceTerritory WHERE Name = 'vciTest2' LIMIT 1];
        FSL_Work_Type_Arrival_Window__mdt arrivalWindow = [SELECT Label, Active__c, Earliest_Start_Time__c FROM FSL_Work_Type_Arrival_Window__mdt WHERE Label = 'cpo' LIMIT 1];
        List<String> startTimes = arrivalWindow.Earliest_Start_Time__c.split(':');

        WorkOrder wo = FSLTestUtility.createWorkOrder(wt, acct, '14224', st, null);
        insert wo;
        ServiceAppointment sa = [SELECT Id, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];
		
        Date targetDate = System.Date.today();
        Time targetStartTime = Time.newInstance(Integer.valueOf(startTimes[0]), Integer.valueOf(startTimes[1]), 0, 0);
        Time targetEndTime = Time.newInstance(Integer.valueOf(startTimes[0]) + 1, Integer.valueOf(startTimes[1]), 0, 0);
        TimeZone targetTimezone = TimeZone.getTimeZone('America/New_York');
        Integer offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;
        Datetime startTime = Datetime.newInstanceGmt(targetDate, targetStartTime).addSeconds(-offsetSeconds);
        Datetime endTime = Datetime.newInstanceGmt(targetDate, targetEndTime).addSeconds(-offsetSeconds);

        String returnedError = '';
        Test.startTest();
        System.runAs(scheduler) {
            sa.SchedStartTime = startTime;
            sa.SchedEndTime = endTime;
            try {
                update sa;
            }
            catch (Exception e) {
                returnedError = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(returnedError.contains('CPO Service Appointments must be scheduled between 9am and 2pm.'));
    }
}