@IsTest
public with sharing class HaltTrue360AppointmentsTest {
    
    @TestSetup
    static void createData() {

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );

        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );


        WorkType wt = FSLWorkProcessUtility.availableWTMap.get( 'true360' );

        ServiceResource sr = FSLTestUtility.makeResourceData();

        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];

        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.id, ServiceTerritoryId = st.id, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P',
            OperatingHoursId = optHour.Id
        );
        insert stm;

        List<Timeline__c> timelines = new List<Timeline__c>();
        Timeline__c tl1 = new Timeline__c();
        tl1.Account__c = a.Id;
        tl1.Start_Date__c = Date.newInstance(2021,9,8);
        tl1.Average_Number_Cars__c = 1;
		tl1.Work_Type__c = wt.Id;
        tl1.Is_Active__c = true;
        timelines.add(tl1);

        Timeline__c tl2 = new Timeline__c();
        tl2.Account__c = a.Id;
        tl2.Start_Date__c = Date.newInstance(2021,9,8);
        tl2.Average_Number_Cars__c = 1;
		tl2.Work_Type__c = wt.Id;
        tl2.Is_Active__c = false;
        timelines.add(tl2);
        insert timelines;

        List<Occurrence__c> occurrences = new List<Occurrence__c>();
        Occurrence__c occ1 = new Occurrence__c();
        occ1.Timeline__c = tl1.Id;
        occ1.Is_Active__c = true;
        occ1.Start_Time__c = Time.newInstance(12,0,0,0);
        occ1.End_Time__c = Time.newInstance(13,0,0,0);
        occ1.Date_of_Last_Generation__c = tl1.Start_Date__c;
        occ1.Farthest_Date_Generated__c = tl1.Start_Date__c;
        occ1.Frequency__c = tracConstants.FREQUENCY_MONTHLY;
        occ1.Every__c = 2;
        occ1.Day__c = tracDateUtils.FRIDAY;
        occ1.Week_Number__c = tracDateUtils.THIRD;
        occ1.TestName__c = 'testocc1';
        occurrences.add(occ1);

        Occurrence__c occ2 = new Occurrence__c();
        occ2.Timeline__c = tl2.Id;
        occ2.Is_Active__c = false;
        occ2.Start_Time__c = Time.newInstance(12,0,0,0);
        occ2.End_Time__c = Time.newInstance(13,0,0,0);
        occ2.Date_of_Last_Generation__c = tl2.Start_Date__c;
        occ2.Farthest_Date_Generated__c = tl2.Start_Date__c;
        occ2.Frequency__c = tracConstants.FREQUENCY_MONTHLY;
        occ2.Every__c = 2;
        occ2.Day__c = tracDateUtils.FRIDAY;
        occ2.Week_Number__c = tracDateUtils.THIRD;
        occ2.TestName__c = 'testocc2';
        occurrences.add(occ2);
        insert occurrences;

        FSLTestUtility.generateWork(wt, null, a, '14209', st, 0);
    }

    @isTest
    static void testCancelTrue360Appointments(){
        Account acc = [SELECT Id, Name, Halt_True360_Appointments__c FROM Account LIMIT 1];
        acc.Halt_True360_Appointments__c = true;
        
        Timeline__c tl1 = new Timeline__c();
        Timeline__c tl2 = new Timeline__c();
        List<Timeline__c> tlList = [SELECT Id, Is_Active__c, (SELECT Id, Is_Active__c FROM Occurrences__r ORDER BY CreatedDate DESC LIMIT 1) FROM Timeline__c WHERE Account__c=:acc.Id];
        for(Timeline__c tl : tlList) {
            if(tl.Is_Active__c == true) {
                tl1 = tl;
            }
            else {
                tl2 = tl;
            }
        }

        test.startTest();
        update acc;
        test.stopTest();

        tlList = [SELECT Id, Is_Active__c, Deactivated_by_Halt_True360_Checkbox__c, (SELECT Id, Is_Active__c FROM Occurrences__r ORDER BY CreatedDate DESC LIMIT 1) FROM Timeline__c WHERE Account__c=:acc.Id];
        for(Timeline__c tl : tlList) {
            if(tl.Id == tl1.Id) {
                System.assertEquals(false, tl.Is_Active__c);
                System.assertEquals(true, tl.Deactivated_by_Halt_True360_Checkbox__c);
		        System.assertEquals(false, tl.Occurrences__r[0].Is_Active__c);
            }
            else {
                System.assertEquals(false, tl.Is_Active__c);
                System.assertEquals(false, tl.Deactivated_by_Halt_True360_Checkbox__c);
		        System.assertEquals(false, tl.Occurrences__r[0].Is_Active__c);
            }
        }
        
        
        ServiceAppointment sa = [SELECT Id, Status, Account__c FROM ServiceAppointment WHERE Account__c=:acc.Id LIMIT 1];
        System.assertEquals('Canceled', sa.Status);
    }
    
    @isTest
    static void testReactivateTrue360RevolvingAppointments(){
        Account acc = [SELECT Id, Name, Halt_True360_Appointments__c FROM Account LIMIT 1];
        acc.Halt_True360_Appointments__c = true;

        Timeline__c tl1 = new Timeline__c();
        Timeline__c tl2 = new Timeline__c();
        List<Timeline__c> tlList = [SELECT Id, Is_Active__c, (SELECT Id, Is_Active__c FROM Occurrences__r ORDER BY CreatedDate DESC LIMIT 1) FROM Timeline__c WHERE Account__c=:acc.Id];
        for(Timeline__c tl : tlList) {
            if(tl.Is_Active__c == true) {
                tl1 = tl;
            }
            else {
                tl2 = tl;
            }
        }

        update acc;

        Test.startTest();
        acc.Halt_True360_Appointments__c = false;
        update acc;
        Test.stopTest();
        
        tlList = [SELECT Id, Is_Active__c, Deactivated_by_Halt_True360_Checkbox__c, (SELECT Id, Is_Active__c FROM Occurrences__r ORDER BY CreatedDate DESC LIMIT 1) FROM Timeline__c WHERE Account__c=:acc.Id];
        for(Timeline__c tl : tlList) {
            if(tl.Id == tl1.Id) {
                System.assertEquals(true, tl.Is_Active__c);
                System.assertEquals(false, tl.Deactivated_by_Halt_True360_Checkbox__c);
		        System.assertEquals(true, tl.Occurrences__r[0].Is_Active__c);
            }
            else {
                System.assertEquals(false, tl.Is_Active__c);
                System.assertEquals(false, tl.Deactivated_by_Halt_True360_Checkbox__c);
		        System.assertEquals(false, tl.Occurrences__r[0].Is_Active__c);
            }
        }
    }

    @isTest
    static void testGetTrue360Id(){
        
        Id true360Id = HaltTrue360Appointments.getTrue360Id();

        System.assert(String.isNotBlank(true360Id));
    }
}