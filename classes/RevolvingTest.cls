/**
 * @description Test class for RevolvingGenerator that ensures revolving work orders and service appointments are being created successfully
 * @author Adam Richbart
 * @since 3/29/2022
 * @group Inspector Dispatch
 */
@isTest
global class RevolvingTest {

    global static Occurrence__c generateTestOcc(Timeline__c tl0, String testName, String frequency, Integer every, String day, String WeekNum){
        Occurrence__c occ0 = new Occurrence__c();
        occ0.Timeline__c = tl0.Id;
        occ0.Is_Active__c = true;
        occ0.Start_Time__c = Time.newInstance(12,0,0,0);
        occ0.End_Time__c = Time.newInstance(13,0,0,0);
        occ0.Date_of_Last_Generation__c = tl0.Start_Date__c;
        occ0.Farthest_Date_Generated__c = tl0.Start_Date__c;
        occ0.Is_Active__c = true;
        occ0.Frequency__c = frequency;
        occ0.Every__c = every;
        occ0.Day__c = day;
        occ0.Week_Number__c = WeekNum;
        occ0.TestName__c = testName;

        return occ0;
    }

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Data_Schedule__c ds = new Data_Schedule__c();
        ds.Frequency__c = 'Daily';
        ds.Active__c = true;
        ds.Horizon_Type__c = 'Months';
        ds.Horizon_Length__c = 12;
        ds.Batch_Size__c = 50;
        insert ds;

        insert FSLTestUtility.createWorkTypes();
        WorkType wt2 = FSLWorkProcessUtility.availableWTMap.get( 'inspection' );

        List<OperatingHours> ohList = new List<OperatingHours>();
        OperatingHours oh = new OperatingHours();
        oh.Name = 'vciTest';
        ohList.add(oh);
        
        //Timezone tz = Timezone.getTimeZone('America/Chicago');
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
        
        List<Timeline__c> timelines = new List<Timeline__c>();
        Timeline__c tl0 = new Timeline__c();
        tl0.Account__c = ac.Id;
        tl0.Is_Active__c = TRUE;
        tl0.Start_Date__c = Date.newInstance(2021,9,8);
        tl0.Average_Number_Cars__c = 1;
		tl0.Work_Type__c = wt2.Id;
//        tl0.End_Date__c = Date.newInstance(2019,9,22).addMonths(6);
        tl0.Is_Active__c = true;
        timelines.add(tl0);

        Timeline__c tl1 = new Timeline__c();
        tl1.Account__c = ac2.Id;
        tl1.Is_Active__c = TRUE;
        tl1.Start_Date__c = Date.newInstance(2020,6,15);
        tl1.Average_Number_Cars__c = 2;
		tl1.Work_Type__c = wt2.Id;
        tl1.Is_Active__c = true;
        timelines.add(tl1);
        insert timelines;
        
        List<Occurrence__c> occs = new List<Occurrence__c>();
        Occurrence__c occ0 = generateTestOcc(tl0, 'testocc0', tracConstants.FREQUENCY_MONTHLY, 2, tracDateUtils.FRIDAY, tracDateUtils.THIRD);
        occs.add(occ0);

        Occurrence__c occ1 = generateTestOcc(tl0, 'testocc1', tracConstants.FREQUENCY_MONTHLY, 3, tracDateUtils.WEEKEND_DAY, tracDateUtils.LAST);
        occs.add(occ1);

        Occurrence__c occ2 = generateTestOcc(tl0, 'testocc2', tracConstants.FREQUENCY_MONTHLY, 1, tracDateUtils.WEEKDAY, tracDateUtils.FIRST);
        occs.add(occ2);

        Occurrence__c occ3 = generateTestOcc(tl0, 'testocc3', tracConstants.FREQUENCY_MONTHLY, 1, tracDateUtils.DAY, tracDateUtils.LAST);
        occs.add(occ3);

        Occurrence__c occ4 = generateTestOcc(tl0, 'testocc4', tracConstants.FREQUENCY_MONTHLY, 1, '1;15', null);
        occs.add(occ4);

        Occurrence__c occ5 = generateTestOcc(tl0, 'testocc5', tracConstants.FREQUENCY_WEEKLY, 2, tracDateUtils.WEDNESDAY, null);
        occs.add(occ5);

        Occurrence__c occ6 = generateTestOcc(tl0, 'testocc6', tracConstants.FREQUENCY_DAILY, 3, null, null);
        occs.add(occ6);
        
        Occurrence__c occ7 = generateTestOcc(tl1, 'testocc7', tracConstants.FREQUENCY_MONTHLY, 12, tracDateUtils.WEEKDAY, tracDateUtils.FIRST);
        occs.add(occ7);
        insert occs;
    }

    @IsTest
    static void testGenerate_01() {
        List<Occurrence__c> occs = getOccurrences( 'testocc0' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(6));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc0'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_02() {
        List<Occurrence__c> occs = getOccurrences( 'testocc1' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(6));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc1'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_03() {
        List<Occurrence__c> occs = getOccurrences( 'testocc2' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc2'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_04() {
        List<Occurrence__c> occs = getOccurrences( 'testocc3' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc3'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }
    @IsTest
    static void testGenerate_05() {
        List<Occurrence__c> occs = getOccurrences( 'testocc4' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc4'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_06() {
        List<Occurrence__c> occs = getOccurrences( 'testocc5' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc5'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    /**
     * @see https://acvauctions.atlassian.net/browse/SI-521
     */
    @IsTest
    static void testGenerate_07() {
        List<Occurrence__c> occs = getOccurrences( 'testocc6' );
        Test.startTest();
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(1));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc6'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_08() {
        List<Occurrence__c> occs = getOccurrences( 'testocc7' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(2));
        Test.stopTest();
        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc7'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];
        System.assert(genereatedWOs.size() > 0);
        
        List<Id> workOrderIds = new List<Id>();
        for(WorkOrder wo : genereatedWOs) {
            workOrderIds.add(wo.Id);
        }
        
        List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment WHERE Work_Order__c IN :workOrderIds ORDER BY EarliestStartTime ASC]);
        System.assert(saList.size() > 0);
        System.assert(saList[0].EarliestStartTime.time().hour() == 13);
        System.assert(saList[0].DueDate.time().hour() == 14);
    }
    
    @isTest
    static void testCleanup(){
        List<Occurrence__c> occs = getOccurrences( 'testocc1' );
        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(3));
        List<Occurrence__c> occList = new List<Occurrence__c>([SELECT Id, Is_Active__c, Timeline__c, Farthest_Date_Generated__c, Cleanup_Marker__c FROM Occurrence__c WHERE TestName__c = 'testocc1' ] );
        for(Occurrence__c occ : occList){
            occ.Is_Active__c = false;
        }
        RevolvingCleaner.deleteChangedRecords(occList);
        //RevolvingCleaner.removeInactiveRecords(occList);
        occList = new List<Occurrence__c>([SELECT Id, Is_Active__c, (SELECT Id FROM Work_Orders__r) FROM Occurrence__c WHERE TestName__c = 'testocc1' ]);
        for(Occurrence__c occ : occList) {
            System.assertEquals(false, occ.Is_Active__c);
            System.assertEquals(0, occ.Work_Orders__r.size());
        }
    }

    /**
     * @see https://acvauctions.atlassian.net/browse/SI-516
     */
    @isTest
    static void runBatches() {
        Test.startTest();
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        RevolvingCleanUpBatch cleanUpBatch = new RevolvingCleanUpBatch(true, 10, true);
        Database.executeBatch(cleanUpBatch, 10);
        Test.stopTest();

        List<WorkOrder> wos = [SELECT Id,EndDate,StartDate FROM WorkOrder];
        system.assert(wos.size() > 0);
    }

    private static List<Occurrence__c> getOccurrences( String filterName ) {
        return [SELECT  Date_of_Last_Generation__c,
                Farthest_Date_Generated__c,
                Day__c,
                End_Time__c,
                Every__c,
                Frequency__c,
                Id,
                Is_Active__c,
                Modified_Since_Last_Batch__c,
                Name,
                OwnerId,
                Start_Time__c,
                TestName__c,
                Timeline__c,
                Was_Modified__c,
                Week_Number__c,
                Timeline__r.End_Date__c,
                Timeline__r.Start_Date__c,
                Timeline__r.Service_Resource__c,
                Timeline__r.Service_Resource_Name__c,
                Timeline__r.Modified_Since_Last_Batch__c,
                Timeline__r.Account__r.Service_Territory__c,
                Timeline__r.Account__r.Service_Territory__r.OperatingHours.TimeZone,
                Timeline__r.Average_Number_Cars__c,
                Timeline__r.Work_Type__c,
                Timeline__r.Work_Type__r.DurationInMinutes,
                Timeline__r.Street__c,
                Timeline__r.City__c,
                Timeline__r.Postal_Code__c,
                Timeline__r.State__c,
                Timeline__r.Country__c,
                Timeline__r.Account__r.BillingStreet,
                Timeline__r.Account__r.BillingCity,
                Timeline__r.Account__r.BillingPostalCode,
                Timeline__r.Account__r.BillingState,
                Timeline__r.Account__r.BillingCountry,
                Timeline__r.Account__r.BillingLatitude,
                Timeline__r.Account__r.BillingLongitude
        FROM Occurrence__c WHERE TestName__c = :filterName ];
    }

    @IsTest
    static void testPreventRACreationWithNoAddress() {
        Account acc = [SELECT Id, BillingStreet FROM Account WHERE Name = 'vciTest' LIMIT 1];
        acc.BillingStreet = null;
        update acc;

        WorkType workType = [SELECT Id FROM WorkType LIMIT 1];

        Timeline__c revolvingAppt = new Timeline__c();
        revolvingAppt.Account__c = acc.Id;
        revolvingAppt.Is_Active__c = TRUE;
        revolvingAppt.Start_Date__c = Date.newInstance(2019,9,8);
        revolvingAppt.Average_Number_Cars__c = 1;
		revolvingAppt.Work_Type__c = workType.Id;
        revolvingAppt.Is_Active__c = true;

        Test.startTest();
        try{
            insert revolvingAppt;
        }catch(Exception e){
            System.Assert(e.getMessage().contains('An account with a billing address is required'));
        }
        Test.stopTest();
    }

    @IsTest
    static void testPreventWorkOrderCreationWithNoAddress() {
        Account acc = [SELECT Id, BillingStreet FROM Account WHERE Name = 'vciTest' LIMIT 1];
        acc.BillingStreet = null;
        update acc;

        List<Occurrence__c> occs = getOccurrences( 'testocc1' );

        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(6));
        Test.stopTest();

        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc1'];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() == 0);
    }
    
    @IsTest
    static void testUseTimelineAddress() {
        Timeline__c timeline = [SELECT Id, Account__c, Account__r.Name, Street__c, City__c, State__c, Postal_Code__c, Country__c FROM Timeline__c WHERE Account__r.Name = 'vciTest' LIMIT 1];
        timeline.Street__c = '123 fake st';
        timeline.City__c = 'TestCity';
        timeline.State__c = 'NY';
        timeline.Postal_Code__c = '12345';
        timeline.Country__c = 'US';
        update timeline;

        List<Occurrence__c> occs = getOccurrences( 'testocc1' );

        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(6));
        Test.stopTest();

        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc1'];
        List<WorkOrder> genereatedWOs = [SELECT Id,Street,City,State,PostalCode,Country FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
        System.assertEquals(genereatedWOs[0].Street, timeline.Street__c);
        System.assertEquals(genereatedWOs[0].City, timeline.City__c);
        System.assertEquals(genereatedWOs[0].State, timeline.State__c);
        System.assertEquals(genereatedWOs[0].Country, timeline.Country__c);
        System.assertEquals(genereatedWOs[0].PostalCode, timeline.Postal_Code__c);
    }

    @IsTest
    static void testUseAccountAddress() {
        Timeline__c timeline = [SELECT Id, Street__c, City__c, State__c, Postal_Code__c, Country__c,
                                Account__c, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingPostalCode, Account__r.BillingState, Account__r.BillingCountry FROM Timeline__c WHERE Account__r.Name = 'vciTest' LIMIT 1];
        timeline.Street__c = '123 fake st';
        timeline.City__c = 'TestCity';
        timeline.Postal_Code__c = '12345';
        timeline.Country__c = 'US';
        update timeline;

        List<Occurrence__c> occs = getOccurrences( 'testocc1' );

        Test.startTest();
        RevolvingGenerator.generate(occs,Date.today(),Date.today().addMonths(6));
        Test.stopTest();

        Occurrence__c occ = [SELECT Id FROM Occurrence__c WHERE TestName__c = 'testocc1'];
        List<WorkOrder> genereatedWOs = [SELECT Id,Street,City,State,PostalCode,Country FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
        System.assertEquals(genereatedWOs[0].Street, timeline.Account__r.BillingStreet);
        System.assertEquals(genereatedWOs[0].City, timeline.Account__r.BillingCity);
        System.assertEquals(genereatedWOs[0].State, timeline.Account__r.BillingState);
        System.assertEquals(genereatedWOs[0].Country, timeline.Account__r.BillingCountry);
        System.assertEquals(genereatedWOs[0].PostalCode, timeline.Account__r.BillingPostalCode);
    }
}