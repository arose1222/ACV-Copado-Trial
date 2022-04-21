@isTest
private class TimeSheetCreationBatchTest {

    @TestSetup
    static void makeData(){
        Account acct = TestUtility.createAccount();
        insert acct;

        //make operating hours
        OperatingHours oh1 = new OperatingHours(Name = 'Test Hours');
        insert oh1;
        //make service territory
        ServiceTerritory st1 = new ServiceTerritory(Name = 'OV OH Akron', OperatingHoursId = oh1.Id, IsActive = TRUE, Generate_TimeSheets__c = TRUE );
        insert st1;
        //make profiles
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        //make users
        List<User> userList = new List<User>();
        List<ServiceResource> srList = new List<ServiceResource>();

        //20 users
        for(integer i = 1; i <= 20; i++){
            //generate data for user
            User u = TestUtility.createUser();
            userList.add(u);
        }
        insert userList;
        system.debug('Users Created: ' + userList.size());

        List<Contact> newConLst = new List<Contact>();
        for(integer i = 1; i <= 20; i++){
            Contact c = TestUtility.createContact( acct );
            c.Email = userList[(i-1)].Email;
            c.ACV_User__c = userList[(i-1)].Id;
            c.Identity_Id__c = ACVUtility.NewGuid();
            newConLst.add( c );
        }
        insert newConLst;

        // Make Permission Set Assignment for 'FSL Resource License' (Scheduling License)
        List<PermissionSetAssignment> psaLst = new List<PermissionSetAssignment>();
        System.runAs( userList[0] ) { 
            for(User u : userList) {
                psaLst.add( FSLTestUtility.makePermissionSet( u.Id ) );
            }
            insert psaLst;
        }

        for(User u : userList){
            ServiceResource sr = new ServiceResource();
            sr.Name = u.LastName;
            sr.RelatedRecordId = u.Id;
            sr.IsActive = true;
            sr.IsCapacityBased = false;
            //Resource Type is Technician
            sr.ResourceType = 'T';
            srList.add(sr);
        }

        insert srList;
        system.debug('Resources Created: ' + srList.size());

        List<ServiceTerritoryMember> stmList = new List<ServiceTerritoryMember>();

        for(ServiceResource sr : srList){
            ServiceTerritoryMember stm = new ServiceTerritoryMember();
            stm.ServiceResourceId = sr.id;
            //create primary membership here
            //criteria for service territory
            stm.ServiceTerritoryId = st1.id;
            stm.EffectiveStartDate = Date.valueOf('2020-8-1 00:00:00');
            stm.TerritoryType = 'P';
            stm.OperatingHoursId = oh1.Id;
            stmList.add(stm);
        }
        insert stmList;
        system.debug('Memberships Created: ' + stmList.size());

        //excluded resource 
        Time_Tracking_Resource__mdt excludedResource = new Time_Tracking_Resource__mdt();
        excludedResource.Resource_Action__c	= 'Exclude';
        
    }


    @isTest
    static private void noPreExistingTimeSheets(){
        System.debug('Start');
        Test.startTest();
            TimeSheetCreationBatch batch = new TimeSheetCreationBatch();
            batch.executeScheduledLogic();
        Test.stopTest();
        System.debug('Stop');
        List<TimeSheet> tsList = [SELECT id, StartDate, EndDate FROM TimeSheet];
        system.debug('TimeSheets created: ' + tsList.size());

        for(TimeSheet ts : tsList){
            system.debug(ts);
        }
    }

    @isTest
    static private void processError() {
        ServiceResource sr = [ SELECT Id, RelatedRecord.ManagerId FROM ServiceResource LIMIT 1 ];
        TimeSheetCreationBatch newBatch = new TimeSheetCreationBatch();
        
        Test.startTest();
            List<Timesheet> timesheetLst = new List<Timesheet>();
            timesheetLst.add( newBatch.createPayPeriodTimeSheet( sr, Date.today() ) );
            List<Database.SaveResult> dbSaveLst = Database.insert( timesheetLst, FALSE );
            newBatch.splunkErrorRecord( dbSaveLst[0] );
        Test.stopTest();
    }

    /*@isTest 
    static private void secondaryMembershipTest(){
        
    }

    @isTest
    static private void noMembershipTest(){

    }

    @isTest
    static private void allPreExistingTimeSheets(){

    }

    @isTest
    static private void mixedPreExistingTimeSheets(){

    }*/

    //pay period is 10-23 and 24-9
    @isTest
    static private void payPeriodStartTest(){
        system.assert(TimeSheetCreationBatch.currentPayPeriodStart(Date.newInstance(2020, 8, 14)) == Date.newInstance(2020, 8, 10));
        system.assert(TimeSheetCreationBatch.currentPayPeriodStart(Date.newInstance(2020, 8, 28)) == Date.newInstance(2020, 8, 24));
        system.assert(TimeSheetCreationBatch.currentPayPeriodStart(Date.newInstance(2021, 1, 1)) == Date.newInstance(2020, 12, 24));
        system.assert(TimeSheetCreationBatch.currentPayPeriodStart(Date.newInstance(2020, 12, 31)) == Date.newInstance(2020, 12, 24));
        system.assert(TimeSheetCreationBatch.currentPayPeriodStart(Date.newInstance(2020, 2, 29)) == Date.newInstance(2020, 2, 24));
    }

    @isTest
    static private void payPeriodEndTest(){
        system.assert(TimeSheetCreationBatch.currentPayPeriodEnd(Date.newInstance(2020, 8, 14)) == Date.newInstance(2020, 8, 23));
        system.assert(TimeSheetCreationBatch.currentPayPeriodEnd(Date.newInstance(2020, 8, 28)) == Date.newInstance(2020, 9, 9));
        system.assert(TimeSheetCreationBatch.currentPayPeriodEnd(Date.newInstance(2021, 1, 1)) == Date.newInstance(2021, 1, 9));
        system.assert(TimeSheetCreationBatch.currentPayPeriodEnd(Date.newInstance(2020, 12, 31)) == Date.newInstance(2021, 1, 9));
        system.assert(TimeSheetCreationBatch.currentPayPeriodEnd(Date.newInstance(2020, 2, 29)) == Date.newInstance(2020, 3, 9));
    }
}