/**
 * Created by zdeng on 9/19/2019.
 */

@IsTest
global class tracGenerate_Test {

    global static Occurrence__c generateTestOcc(Timeline__c tl0, String testName, String frequency, Integer every, String day, String WeekNum){
        Occurrence__c occ0 = new Occurrence__c();
        occ0.Timeline__c = tl0.Id;
        occ0.Is_Active__c = true;
        occ0.Start_Time__c = Time.newInstance(12,0,0,0);
        occ0.End_Time__c = Time.newInstance(13,0,0,0);
        occ0.Date_of_Last_Generation__c = tl0.Start_Date__c;
        occ0.Is_Active__c = true;
        occ0.Frequency__c = frequency;
        occ0.Every__c = every;
        occ0.Day__c = day;
        occ0.Week_Number__c = WeekNum;
        occ0.TestName__c = testName;

        return occ0;
    }

    @TestSetup
    global static void setUp(){
        insert FSLTestUtility.createWorkTypes();
        WorkType wt2 = FSLWorkProcessUtility.availableWTMap.get( 'inspection' );

        OperatingHours oh = new OperatingHours();
        oh.Name = 'vciTest';
        insert oh;

        ServiceTerritory stParent = new ServiceTerritory();
        stParent.Name = 'vciParent';
        stParent.IsActive = true;
        stParent.OperatingHoursId = oh.Id;
        insert stParent;

        ServiceTerritory st = new ServiceTerritory();
        st.ParentTerritoryId = stParent.Id;
        st.Name = 'vciTest';
        st.IsActive = true;
        st.OperatingHoursId = oh.Id;
        insert st;
        System.debug(st.Id);

        Account ac = TestUtility.createAccount();
        ac.Name = 'vciTest';
        ac.Service_Territory__c = st.Id;
        insert ac;

        Timeline__c tl0 = new Timeline__c();
        tl0.Account__c = ac.Id;
        tl0.Is_Active__c = TRUE;
        tl0.Start_Date__c = Date.newInstance(2019,9,8);
        tl0.Average_Number_Cars__c = 1;
//        tl0.End_Date__c = Date.newInstance(2019,9,22).addMonths(6);
        tl0.Is_Active__c = true;
        tl0.Work_Type__c = wt2.Id;
        insert tl0;

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
        insert occs;
    }

    @IsTest
    static void testGenerate_01() {
        List<Occurrence__c> occs = getOccurrences( 'testocc0' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(6));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_02() {
        List<Occurrence__c> occs = getOccurrences( 'testocc1' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(6));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_03() {
        List<Occurrence__c> occs = getOccurrences( 'testocc2' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_04() {
        List<Occurrence__c> occs = getOccurrences( 'testocc3' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }
    @IsTest
    static void testGenerate_05() {
        List<Occurrence__c> occs = getOccurrences( 'testocc4' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_06() {
        List<Occurrence__c> occs = getOccurrences( 'testocc5' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(3));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    @IsTest
    static void testGenerate_07() {
        List<Occurrence__c> occs = getOccurrences( 'testocc6' );
        Test.startTest();
        tracGenerate.generate(occs,Date.today().addMonths(1));
        Test.stopTest();
        Occurrence__c occ = occs[0];
        List<WorkOrder> genereatedWOs = [SELECT Id,StartDate,EndDate,Origin__c FROM WorkOrder WHERE Occurrence__c = :occ.Id];

        System.assert(genereatedWOs.size() > 0);
    }

    private static List<Occurrence__c> getOccurrences( String filterName ) {
        return [SELECT  Date_of_Last_Generation__c,
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
                Timeline__r.Average_Number_Cars__c
        FROM Occurrence__c WHERE TestName__c = :filterName ];
    }

}