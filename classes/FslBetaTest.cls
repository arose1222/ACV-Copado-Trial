@isTest
public with sharing class FslBetaTest {

    // WorkType Names
   /* private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
    private final static String TRUE_360 = 'True 360';

    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory parentST = new ServiceTerritory(
            Name = 'Great Lakes', OperatingHoursId = oh.Id, 
            isActive = TRUE
        );
        insert parentST;
    }

    @isTest
    public static void stTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        List<ServiceTerritory> sevTerrLst = [ SELECT id, Name FROM ServiceTerritory WHERE Name IN :( new Set<String>( FslBeta.BETA_REGIONS ) ) ];
        
        ServiceTerritory stNegative = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert stNegative;
        
        //positive
        for ( ServiceTerritory sevTerrRec : sevTerrLst ) {
            System.Assert( FslBeta.isBeta( new List<ServiceTerritory>{ sevTerrRec } ) == true );
            System.Assert( FslBeta.isNotBeta( new List<ServiceTerritory>{ sevTerrRec } ) != true );
        }
        
        //negative
        System.Assert( FslBeta.isNotBeta([SELECT Id FROM ServiceTerritory WHERE Name = 'Not Great Lakes']) == true );
        System.Assert( FslBeta.isBeta([SELECT Id FROM ServiceTerritory WHERE Name = 'Not Great Lakes']) != true );
    }


    @isTest
    public static void stmTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u1;
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u2;

        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        insert sr1;
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        insert sr2;

        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        insert stm1;
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        insert stm2;



        Datetime endDate = Date.valueOf('2019-11-2 00:00:00');
        //positive
        System.Assert(FslBeta.isBeta([SELECT Id FROM ServiceTerritoryMember WHERE EffectiveEndDate =: endDate]) == true);
        //negative
        endDate = Date.valueOf('2019-11-4 00:00:00');
        System.Assert(FslBeta.isNotBeta([SELECT Id FROM ServiceTerritoryMember WHERE EffectiveEndDate =: endDate]) == true);
    }

    @isTest
    public static void srTest(){
                OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u1;
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u2;

        Test.startTest();
            ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
            insert sr1;
            ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
            insert sr2;

            ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
            insert stm1;
            ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
            insert stm2;

            //positive
            System.Assert(FslBeta.isBeta([SELECT Id FROM ServiceResource WHERE Name = 'Mr. Grumpy']) == true);
            //negative
            System.Assert(FslBeta.isNotBeta([SELECT Id FROM ServiceResource WHERE Name = 'Mr. Happyface']) == true);
        test.stopTest();
    }

    @isTest
    public static void saTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        List<User> userLst = new List<User>();
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u1 );
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u2 );
        insert userLst;

        List<ServiceResource> srLst = new List<ServiceResource>();
        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr1 );
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr2 );
        insert srLst;

        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm1 );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm2 );
        insert stmLst;
        
        List<Account> acctLst = new List<Account>();
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        acctLst.add( acc );
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        acctLst.add( acc2 );
        insert acctLst;

        Test.startTest();
            Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId);
            woLst.add( wo );
            WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId);
            woLst.add( wo2 );
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
            insert woliLst;

            List<ServiceAppointment> saLst = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saLst.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saLst.add( sa2 );
            insert saLst;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
        Test.stopTest();

        //positive
        System.Assert(FslBeta.isBeta([SELECT Id FROM ServiceAppointment WHERE Completed_Canceled_Notes__c = 'SA1']) == true);
        //negative
        System.Assert(FslBeta.isNotBeta([SELECT Id FROM ServiceAppointment WHERE Completed_Canceled_Notes__c = 'SA2']) == true);
    }

    @isTest
    public static void woliTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        List<User> userLst = new List<User>();
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u1 );
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u2 );
        insert userLst;

        List<ServiceResource> srLst = new List<ServiceResource>();
        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr1 );
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr2 );
        insert srLst;

        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm1 );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm2 );
        insert stmLst;
        
        List<Account> acctLst = new List<Account>();
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        acctLst.add( acc );
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        acctLst.add( acc2 );
        insert acctLst;

        Test.startTest();

            Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId);
            woLst.add( wo );
            WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId);
            woLst.add( wo2 );
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
            insert woliLst;

            List<ServiceAppointment> saLst = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saLst.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saLst.add( sa2 );
            insert saLst;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
        Test.stopTest();

        //positive
        System.Assert(FslBeta.isBeta([SELECT Id, ServiceTerritoryId FROM WorkOrderLineItem WHERE Subject = 'Woli1']) == true);
        //negative
        System.Assert(FslBeta.isNotBeta([SELECT Id, ServiceTerritoryId FROM WorkOrderLineItem WHERE Subject = 'Woli2']) == true);
    }

    @isTest
    public static void woTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        List<User> userLst = new List<User>();
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u1 );
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u2 );
        insert userLst;

        List<ServiceResource> srLst = new List<ServiceResource>();
        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr1 );
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr2 );
        insert srLst;

        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm1 );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm2 );
        insert stmLst;
        
        List<Account> acctLst = new List<Account>();
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        acctLst.add( acc );
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        acctLst.add( acc2 );
        insert acctLst;

        Test.startTest();

            Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId);
            woLst.add( wo );
            WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId);
            woLst.add( wo2 );
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
            insert woliLst;

            List<ServiceAppointment> saLst = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saLst.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saLst.add( sa2 );
            insert saLst;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
        Test.stopTest();

        //positive
        System.Assert(FslBeta.isBeta([SELECT Id, ServiceTerritoryId FROM WorkOrder WHERE Special_Instructions__c = 'Work Order 1']) == true);
        //negative
        System.Assert(FslBeta.isNotBeta([SELECT Id, ServiceTerritoryId FROM WorkOrder WHERE Special_Instructions__c = 'Work Order 2']) == true);
    }

    @isTest
    public static void arTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        List<User> userLst = new List<User>();
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u1 );
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u2 );
        insert userLst;

        List<ServiceResource> srLst = new List<ServiceResource>();
        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr1 );
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr2 );
        insert srLst;

        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm1 );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm2 );
        insert stmLst;
        
        List<Account> acctLst = new List<Account>();
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        acctLst.add( acc );
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        acctLst.add( acc2 );
        insert acctLst;

        Test.startTest(); 

            Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId );
            woLst.add( wo );
            WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId );
            woLst.add( wo2 );
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
            insert woliLst;

            List<ServiceAppointment> saLst = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saLst.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saLst.add( sa2 );
            insert saLst;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
        Test.stopTest();

        //positive
        System.Assert(FslBeta.isBeta([SELECT Id FROM AssignedResource WHERE ActualTravelTime = 123456]) == true);
        //negative
        System.Assert(FslBeta.isNotBeta([SELECT Id FROM AssignedResource WHERE ActualTravelTime = 111111]) == true);
    }

    @isTest
    public static void accTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u1;
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u2;

        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        insert sr1;
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        insert sr2;

        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        insert stm1;
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        insert stm2;
        
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        insert acc;
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        insert acc2;

        Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
        List<WorkOrder> woLst = new List<WorkOrder>();
        WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId);
        woLst.add( wo );
        WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId);
        woLst.add( wo2 );
        insert woLst;

        Test.startTest();

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
        
            List<ServiceAppointment> saLst = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saLst.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saLst.add( sa2 );
            insert saLst;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
            //positive
            System.Assert(FslBeta.isBeta([SELECT Id FROM Account WHERE Name = 'E Corp']) == true);
            //negative
            System.Assert(FslBeta.isNotBeta([SELECT Id FROM Account WHERE Name = 'F Society']) == true);
        Test.stopTest();
    }

    @isTest
    public static void uTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        List<User> userLst = new List<User>();
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u1 );
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u2 );
        insert userLst;

        List<ServiceResource> srLst = new List<ServiceResource>();
        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr1 );
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr2 );
        insert srLst;

        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm1 );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm2 );
        insert stmLst;
        
        List<Account> acctLst = new List<Account>();
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        acctLst.add( acc );
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        acctLst.add( acc2 );
        insert acctLst;

        Test.startTest();

            Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId);
            woLst.add( wo );
            WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId);
            woLst.add( wo2 );
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
            insert woliLst;

            List<ServiceAppointment> saList = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saList.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saList.add( sa2 );
            insert saList;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
        Test.stopTest();

        //positive
        System.Assert(FslBeta.isBeta([SELECT Id FROM User WHERE Username = 'Testy1@Testington.test']) == true);
        //negative
        System.Assert(FslBeta.isNotBeta([SELECT Id FROM User WHERE Username = 'Testy2@Testington.test']) == true);
    }

    @isTest
    public static void crpTest(){
        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st1 = [SELECT id, Name FROM ServiceTerritory WHERE Name = 'Great Lakes'];
        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        
        List<User> userLst = new List<User>();
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u1 );
        User u2 = new User(Username = 'Testy2@Testington.test', LastName = 'McTesty2', Email ='Testy2@Testington.test', Alias = 'TESTBOY2', CommunityNickname = 'tEsT2', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        userLst.add( u2 );
        insert userLst;

        List<ServiceResource> srLst = new List<ServiceResource>();
        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr1 );
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. Happyface', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        srLst.add( sr2 );
        insert srLst;

        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm1 );
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st2.Id, EffectiveStartDate = Date.ValueOf('2019-10-3 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-4 00:00:00'), TerritoryType = 'P');
        stmLst.add( stm2 );
        insert stmLst;
        
        List<Account> acctLst = new List<Account>();
        Account acc = TestUtility.createAccount('E Corp');
        acc.OwnerId = u1.Id;
        acctLst.add( acc );
        Account acc2 = TestUtility.createAccount('F Society');
        acc2.OwnerId = u2.Id;
        acctLst.add( acc2 );
        insert acctLst;

        Test.startTest();
            Id standardWTId = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id;
            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder wo = new WorkOrder(Special_Instructions__c = 'Work Order 1', AccountId = acc.Id, ServiceTerritoryId = st1.Id, WorkTypeId = standardWTId);
            woLst.add( wo );
            WorkOrder wo2 = new WorkOrder(Special_Instructions__c = 'Work Order 2', AccountId = acc2.Id, ServiceTerritoryId = st2.Id, WorkTypeId = standardWTId);
            woLst.add( wo2 );
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLIneItem woli = new WorkOrderLineItem(Subject = 'Woli1', VIN__c = '12341234', Status = 'New', workOrderId = wo.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli );
            WorkOrderLIneItem woli2 = new WorkOrderLineItem(Subject = 'Woli2', VIN__c = '43214321', Status = 'New', workOrderId = wo2.Id, Duration = 40, DurationType = 'Minutes', WorkTypeId = standardWTId);
            woliLst.add( woli2 );
            insert woliLst;
        
            List<ServiceAppointment> saLst = new List<ServiceAppointment>();
            ServiceAppointment sa = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA1', ParentRecordId = wo.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st1.Id);
            saLst.add( sa );
            ServiceAppointment sa2 = new ServiceAppointment(Completed_Canceled_Notes__c = 'SA2', ParentRecordId = wo2.Id, EarliestStartTime = Datetime.now(), DueDate = Datetime.now(), SchedStartTime=Datetime.valueOf('2019-10-22 00:00:00'), SchedEndTime = Datetime.valueOf('2019-10-23 00:00:00'), Status = 'None', ServiceTerritoryId = st2.Id);
            saLst.add( sa2 );
            insert saLst;

            AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa.Id, ServiceResourceId = sr1.Id);
            insert ar;
            AssignedResource ar2 = new AssignedResource(ActualTravelTime = 111111, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr2.Id);
            insert ar2;
        Test.stopTest();

        Condition_Report__c cr = new Condition_Report__c(Dealership__c = acc.id);
        insert cr;

        Condition_Report_Prescreen__C crp = new Condition_Report_Prescreen__c(Condition_Report__c = cr.id);
        insert crp;

        //positive
        System.Assert(FslBeta.isBeta([SELECT Id FROM Condition_Report_Prescreen__c WHERE Id =: crp.id]) == true);

    }*/
}