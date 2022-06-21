@IsTest
public class WorkOrderLineItemTriggerUtilityTest {

    public final static String EMAIL = 'vciuser@testorg.com';

    // WorkType Names
    private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
    private final static String TRUE_360 = 'True 360';

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Completed' );
    }

   /* @isTest
    static void StatusRollUpTest(){

        Account acct = new Account(Name='test' + DateTime.now().getTime(), BillingStreet = '101 Main Street', BillingState = 'NY', BillingCity = 'Buffalo', BillingPostalCode = '14209', BillingCountry = 'US' );
        insert acct;

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        User u1 = new User(
            Alias = 'admint', Email= WorkOrderLineItemTriggerUtilityTest.EMAIL,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='America/New_York', ProfileId = p.Id,
            UserName= 'vciuser' + DateTime.now().getTime() + '@testorg.com.acvauctions'
         );
         insert u1;

                 User u2 = new User(
            Alias = 'admint2', Email= 'testuser2@test.org',
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='America/New_York', ProfileId = p.Id,
            UserName= 'vciuser' + DateTime.now().getTime() + '@testorg.com.acvauctions'
         );
         insert u2;

        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;
        ServiceTerritory st1 = [SELECT Id FROM ServiceTerritory WHERE Name = 'Great Lakes'];
     

        ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        insert sr1;
        ServiceResource sr2 = new ServiceResource(Name = 'Mr. HappyFace', RelatedRecordId = u2.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
        insert sr2;

        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st2.Id, TerritoryType = 'P', EffectiveStartDate = DateTime.now().addDays(-1));
        insert stm1;
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId = sr2.Id, ServiceTerritoryId = st1.Id, TerritoryType = 'P', EffectiveStartDate = DateTime.now().addDays(-1));
        insert stm2;

        List<WorkOrder> workOrderList = new List<WorkOrder>();
        final WorkType WORK_TYPE_AV = [ SELECT Id FROM WorkType WHERE Name = 'Asset Verification' LIMIT 1 ];
        final WorkType WORK_TYPE_SI = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION LIMIT 1 ];

        /*WorkOrder wo1 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo2 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo3 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo4 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo5 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo6 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo7 = new WorkOrder(WorkTypeId = WORK_TYPE_SI.Id, Status = 'New', AccountId = acct.Id );
        WorkOrder wo8 = new WorkOrder(WorkTypeId = WORK_TYPE_AV.Id, Status = 'New', AccountId = acct.Id );
        /*workOrderList.add(wo1);
        workOrderList.add(wo2);
        workOrderList.add(wo3);
        workOrderList.add(wo4);
        workOrderList.add(wo5);
        workOrderList.add(wo6);
        workOrderList.add(wo7);
        workOrderList.add(wo8);
        insert workOrderList;

        List<ServiceAppointment> saList = new List<ServiceAppointment>();
        /*ServiceAppointment sa1 = new ServiceAppointment(ParentRecordId = wo1.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id );
        ServiceAppointment sa2 = new ServiceAppointment(ParentRecordId = wo2.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id);
        ServiceAppointment sa3 = new ServiceAppointment(ParentRecordId = wo3.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id);
        ServiceAppointment sa4 = new ServiceAppointment(ParentRecordId = wo4.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id);
        ServiceAppointment sa5 = new ServiceAppointment(ParentRecordId = wo5.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id);
        ServiceAppointment sa6 = new ServiceAppointment(ParentRecordId = wo6.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id);
        ServiceAppointment sa7 = new ServiceAppointment(ParentRecordId = wo7.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car');
        ServiceAppointment sa8 = new ServiceAppointment(ParentRecordId = wo8.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st1.Id, Street = '101 Main', City = 'Bobs House', Country = 'US', PostalCode = '14209', State= 'NY');
        /*saList.add(sa1);
        saList.add(sa2);
        saList.add(sa3);
        saList.add(sa4);
        saList.add(sa5);
        saList.add(sa6);
        saList.add(sa7);
        saList.add(sa8);
        insert saList;

        List<AssignedResource> newAssignedLst = new List<AssignedResource>();
        /*AssignedResource ar = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa1.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar );
        AssignedResource ar2 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa2.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar2 );
        AssignedResource ar3 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa3.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar3 );
        AssignedResource ar4 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa4.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar4 );
        AssignedResource ar5 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa5.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar5 );
        AssignedResource ar6 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa6.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar6 );
        AssignedResource ar7 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa7.Id, ServiceResourceId = sr1.Id);
        newAssignedLst.add( ar7 );
        AssignedResource ar8 = new AssignedResource(ActualTravelTime = 123456, ServiceAppointmentId = sa8.Id, ServiceResourceId = sr2.Id);
        newAssignedLst.add( ar8 );
        insert newAssignedLst;

        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        /*orkOrderLineItem wolia1 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo1.id, Status ='SOT');
        // WorkOrderLineItem wolib1 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo1.id, Status ='New');
        // WorkOrderLineItem wolic1 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo1.id, Status ='New');
        // WorkOrderLineItem wolid1 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo1.id, Status ='New');
        woliList.add(wolia1);
        // woliList.add(wolib1);
        // woliList.add(wolic1);
        // woliList.add(wolid1);

        WorkOrderLineItem wolia2 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo2.id, Status ='Canceled');
        WorkOrderLineItem wolib2 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo2.id, Status ='New');
        WorkOrderLineItem wolic2 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo2.id, Status ='New');
        WorkOrderLineItem wolid2 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo2.id, Status ='New');
        woliList.add(wolia2);
        woliList.add(wolib2);
        woliList.add(wolic2);
        woliList.add(wolid2);

        WorkOrderLineItem wolia3 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo3.id, Status ='Canceled');
        WorkOrderLineItem wolib3 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo3.id, Status ='New');
        WorkOrderLineItem wolic3 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo3.id, Status ='Completed');
        WorkOrderLineItem wolid3 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo3.id, Status ='New');
        woliList.add(wolia3);
        woliList.add(wolib3);
        woliList.add(wolic3);
        woliList.add(wolid3);

        WorkOrderLineItem wolia4 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo4.id, Status ='Canceled');
        WorkOrderLineItem wolib4 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo4.id, Status ='Canceled');
        WorkOrderLineItem wolic4 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo4.id, Status ='Canceled');
        WorkOrderLineItem wolid4 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo4.id, Status ='Canceled');
        woliList.add(wolia4);
        woliList.add(wolib4);
        woliList.add(wolic4);
        woliList.add(wolid4);

        WorkOrderLineItem wolia5 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo5.id, Status ='Canceled');
        WorkOrderLineItem wolib5 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo5.id, Status ='In Progress');
        WorkOrderLineItem wolic5 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo5.id, Status ='New');
        WorkOrderLineItem wolid5 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo5.id, Status ='New');
        woliList.add(wolia5);
        woliList.add(wolib5);
        woliList.add(wolic5);
        woliList.add(wolid5);

        WorkOrderLineItem wolia6 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo6.id, Status ='Canceled');
        WorkOrderLineItem wolib6 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo6.id, Status ='In Progress');
        WorkOrderLineItem wolic6 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo6.id, Status ='New');
        WorkOrderLineItem wolid6 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo6.id, Status ='On Hold');
        woliList.add(wolia6);
        woliList.add(wolib6);
        woliList.add(wolic6);
        woliList.add(wolid6);

        WorkOrderLineItem wolia7 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo7.id, Status ='Completed');
        WorkOrderLineItem wolib7 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo7.id, Status ='Completed');
        WorkOrderLineItem wolic7 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo7.id, Status ='Completed');
        WorkOrderLineItem wolid7 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo7.id, Status ='Completed');
        woliList.add(wolia7);
        woliList.add(wolib7);
        woliList.add(wolic7);
        woliList.add(wolid7);

        WorkOrderLineItem wolia8 = new WorkOrderLineItem(WorkTypeId = WORK_TYPE_SI.Id, WorkOrderId = wo8.id, Status ='SOT');
        woliList.add(wolia8);

        insert woliList;


        test.startTest();
        Set<Id> workOrderIdSet = new Set<Id>();
        for(WorkOrder workOrd : workOrderList){
            workOrderIdSet.add(workOrd.Id);
        }
        WorkOrderLineItemUtility.processParentStatus(workOrderIdSet);


        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(workOrderList);
        workOrderList.clear();
        workOrderList = [SELECT Status, Id FROM WorkOrder WHERE Id in : woMap.keySet()];
        
        integer primeCounter = 1;

        for(WorkOrder wo : workOrderList){
            system.debug(wo);
            /*if(wo.Id == wo1.Id){
                primeCounter = primeCounter * 2;
                system.Assert(wo.Status == 'Completed', 'Status: ' + wo.Status + ' is not Status: Completed');
            }else if(wo.Id == wo2.Id){
                primeCounter = primeCounter * 3;
                system.Assert(wo.Status == 'New', 'Status: ' + wo.Status + ' is not Status: New');
            }else if(wo.Id == wo3.Id){
                primeCounter = primeCounter * 5;
                system.Assert(wo.Status == 'In Progress', 'Status: ' + wo.Status + ' is not Status: In Progress');
            }else if(wo.Id == wo4.Id){
                primeCounter = primeCounter * 7;
                system.Assert(wo.Status == 'Canceled', 'Status: ' + wo.Status + ' is not Status: Canceled');
            }else if(wo.Id == wo5.Id){
                primeCounter = primeCounter * 11;
                system.Assert(wo.Status == 'In Progress', 'Status: ' + wo.Status + ' is not Status: In Progress');
            }else if(wo.Id == wo6.Id){
                primeCounter = primeCounter * 13;
                system.Assert(wo.Status == 'On Hold', 'Status: ' + wo.Status + ' is not Status: On Hold');
            }else if(wo.Id == wo7.Id){
                primeCounter = primeCounter * 17;
                system.Assert(wo.Status == 'Completed', 'Status: ' + wo.Status + ' is not Status: Completed');
            }else if(wo.Id == wo8.Id){
                primeCounter = primeCounter * 19;
                system.Assert(wo.Status == 'Completed', 'Status: ' + wo.Status + ' is not Status: Completed');
            }
        }
        //system.Assert(primeCounter == 2*3*5*7*11*13*17*19, 'Work Orders have been checked an incorrect amount of times');






        

         test.stopTest();
    }*/


    // @IsTest
    // static void testTimeStamp(){

    //     Long stampTestBegin = datetime.now().getTime();

    //     Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
    //     User u1 = new User(
    //         Alias = 'admint', Email= WorkOrderLineItemTriggerUtilityTest.EMAIL,
    //         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    //         LocaleSidKey='en_US', TimeZoneSidKey='America/New_York', ProfileId = p.Id,
    //         UserName= 'vciuser' + DateTime.now().getTime() + '@testorg.com.acvauctions'
    //      );
    //      insert u1;

    //     OperatingHours oh = new OperatingHours(Name = 'Test Hours');
    //     insert oh;

    //     ServiceTerritory st1 = new ServiceTerritory(Name = 'Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
    //     insert st1;

    //     ServiceResource sr1 = new ServiceResource(Name = 'Mr. Grumpy', RelatedRecordId = u1.Id, IsActive = true, IsCapacityBased = false, ResourceType = 'T');
    //     insert sr1;

    //     ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, TerritoryType = 'P', EffectiveStartDate = DateTime.now().addDays(-1));
    //     insert stm1;

    //     system.debug([SELECT Id, Name FROM WorkType]);

    //     WorkType wT1 = new WorkType(Name = 'Asset Verification', EstimatedDuration = 5, DurationType = 'Hours');
    //     insert wT1;


    //     Account a = new Account(Name='test', BillingStreet = '101 Main Street', BillingState = 'NY', BillingCity = 'Buffalo', BillingPostalCode = '14209', BillingCountry = 'US' );
    //     insert a;

    //     WorkOrder workOrder = new WorkOrder(
    //         WorkTypeId = wT1.Id,
    //         AccountId = a.Id,
    //         Status = 'New'
    //     );
    //     insert workOrder;

    //     WorkOrderLineItem workItem = new WorkOrderLineItem(
    //             WorkTypeId = wT1.Id,
    //             WorkOrderId = workOrder.Id,
    //             Status = 'New',
    //             Job_Notes__c = 'Is this the Krusty Krab? -- No! This is Patrick!'
    //     );
    //     insert workItem;

    //     ServiceAppointment sa1 = new ServiceAppointment(ParentRecordId = workOrder.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st1.Id );
    //     insert sa1;
    //     Test.startTest();

        
    //     workItem.status = 'Completed';
    //     update workItem;

    //     WorkOrderLineItem woli = [SELECT Id, Completion_Time__c FROM WorkOrderLineItem WHERE Job_Notes__c = 'Is this the Krusty Krab? -- No! This is Patrick!' LIMIT 1];
    //     Long stampTestEnd = datetime.now().getTime();

    //     system.assert(stampTestEnd - woli.Completion_Time__c.getTime() < stampTestEnd - stampTestBegin, 'Line Item was not timestamped correctly');
    //     Test.stopTest();
    // }

    @IsTest
    static void processChildrenUpdates() {
        Account a = TestUtility.createAccount();
        insert a;

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        User u = new User(
            Alias = 'admint', Email= WorkOrderLineItemTriggerUtilityTest.EMAIL,
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', TimeZoneSidKey='America/New_York', ProfileId = p.Id,
            UserName= 'vciuser' + DateTime.now().getTime() + '@testorg.com.acvauctions'
         );
         insert u;

        OperatingHours oh = new OperatingHours(Name = 'Test Hours');
        insert oh;

        ServiceTerritory st2 = new ServiceTerritory(Name = 'Not Great Lakes', OperatingHoursId = oh.Id, IsActive = true);
        insert st2;

        final WorkType WORK_TYPE_RI = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' LIMIT 1 ];

        WorkOrder workOrder = new WorkOrder(
            WorkTypeId = WORK_TYPE_RI.Id,
            AccountId = a.Id,
            Status = 'New'
        );
        insert workOrder;

        WorkOrderLineItem workItem = new WorkOrderLineItem(
            WorkTypeId = WORK_TYPE_RI.Id,
            WorkOrderId = workOrder.Id,
            Status = 'New'
        );
        insert workItem;

        ServiceAppointment sa1 = new ServiceAppointment(ParentRecordId = workOrder.Id,  Completed_Canceled_Notes__c = 'SA1', SchedStartTime = Datetime.now(), SchedEndTime = Datetime.now().addMinutes(20), ArrivalWindowStartTime = DateTime.now().addMinutes(-60), ArrivalWindowEndTime = DateTime.now().addMinutes(60), Description = 'Meet Rick at the gate', Duration = 20, DurationType = 'Minutes', EarliestStartTime = DateTime.now().addMinutes(-120), ServiceNote = 'Talk to Rick before beginning', Status = 'New', Subject = 'Fix Rick\'s Car', ServiceTerritoryId = st2.Id,
        ActualStartTime = DateTime.now(), ActualEndTime = DateTime.now().addMinutes(30) );
        insert sa1;

        workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
        System.assertEquals( 'New', workOrder.Status, 'The Work Order is expected to update the status to New, it is currently: ' + workOrder.Status );

        Test.startTest();

            workItem.Status = 'In Progress';
            update workItem;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'In Progress', workOrder.Status, 'The Work Order is expected to update the status to In Progress, it is currently: ' + workOrder.Status );

            workItem.Status = 'Launched';
            update workItem;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'Completed', workOrder.Status, 'The Work Order is expected to update the status to Completed, it is currently: ' + workOrder.Status );

            WorkOrderLineItem workItem2 = new WorkOrderLineItem(
                WorkTypeId = WORK_TYPE_RI.Id,
                WorkOrderId = workOrder.Id,
                Status = 'New'
            );
            insert workItem2;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'In Progress', workOrder.Status, 'The Work Order is expected to update the status to In Progress, it is currently: ' + workOrder.Status );

            workItem.Status = 'Launched';
            workItem2.Status = 'Launched';
            List<WorkOrderLineItem> workItemUpdateLst = new List<WorkOrderLineItem>();
            workItemUpdateLst.add( workItem );
            workItemUpdateLst.add( workItem2 );
            update workItemUpdateLst;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'Completed', workOrder.Status, 'The Work Order is expected to update the status to Completed, it is currently: ' + workOrder.Status );

        Test.stopTest();
    }


    @IsTest
    static void processASIChildrenUpdates() {
        Account a = TestUtility.createAccount();
        insert a;

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];

        WorkType fbi = [ SELECT Id, Name, EstimatedDuration, DurationType, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_Id__c = 'fbi' LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        FSLTestUtility.generateWork( fbi, fbi, acct, '14209', st, 1 );

        WorkOrderLineItem workItem = [ SELECT Id FROM WorkOrderLineItem LIMIT 1 ];
        WorkOrder workOrder = [ SELECT Id FROM WorkOrder LIMIT 1 ];

        ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
        sa.ActualStartTime = DateTime.now();
        sa.ActualEndTime = DateTime.now().addMinutes(30);
        sa.SchedStartTime = DateTime.now();
        sa.SchedEndTime = DateTime.now().addMinutes(30);
        update sa;

        Test.startTest();

            workItem.Status = 'In Progress';
            update workItem;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'In Progress', workOrder.Status, 'The Work Order is expected to update the status to In Progress, it is currently: ' + workOrder.Status );

            workItem.Status = 'Launched';
            update workItem;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'Completed', workOrder.Status, 'The Work Order is expected to update the status to Completed, it is currently: ' + workOrder.Status );

            WorkOrderLineItem workItem2 = new WorkOrderLineItem(
                WorkTypeId = fbi.Id,
                WorkOrderId = workOrder.Id,
                Status = 'New'
            );
            insert workItem2;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'In Progress', workOrder.Status, 'The Work Order is expected to update the status to In Progress, it is currently: ' + workOrder.Status );

            workItem.Status = 'Launched';
            workItem2.Status = 'Launched';
            List<WorkOrderLineItem> workItemUpdateLst = new List<WorkOrderLineItem>();
            workItemUpdateLst.add( workItem );
            workItemUpdateLst.add( workItem2 );
            update workItemUpdateLst;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'Completed', workOrder.Status, 'The Work Order is expected to update the status to Completed, it is currently: ' + workOrder.Status );

        Test.stopTest();
    }

    @IsTest
    static void processPromoChildrenUpdates() {
        Account a = TestUtility.createAccount();
        insert a;

        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];

        WorkType promoWork = [ SELECT Id, Name, EstimatedDuration, DurationType, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_Id__c = 'promo work' LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        FSLTestUtility.generateWork( promoWork, promoWork, acct, '14209', st, 1 );

        WorkOrderLineItem workItem = [ SELECT Id FROM WorkOrderLineItem LIMIT 1 ];
        WorkOrder workOrder = [ SELECT Id FROM WorkOrder LIMIT 1 ];

        ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
        sa.ActualStartTime = DateTime.now();
        sa.ActualEndTime = DateTime.now().addMinutes(30);
        sa.SchedStartTime = DateTime.now();
        sa.SchedEndTime = DateTime.now().addMinutes(30);
        update sa;

        Test.startTest();

            workItem.Status = 'In Progress';
            update workItem;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'In Progress', workOrder.Status, 'The Work Order is expected to update the status to In Progress, it is currently: ' + workOrder.Status );

            workItem.Status = 'Launched';
            update workItem;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'Completed', workOrder.Status, 'The Work Order is expected to update the status to Completed, it is currently: ' + workOrder.Status );

            WorkOrderLineItem workItem2 = new WorkOrderLineItem(
                WorkTypeId = promoWork.Id,
                WorkOrderId = workOrder.Id,
                Status = 'New'
            );
            insert workItem2;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'In Progress', workOrder.Status, 'The Work Order is expected to update the status to In Progress, it is currently: ' + workOrder.Status );

            workItem.Status = 'Launched';
            workItem2.Status = 'Launched';
            List<WorkOrderLineItem> workItemUpdateLst = new List<WorkOrderLineItem>();
            workItemUpdateLst.add( workItem );
            workItemUpdateLst.add( workItem2 );
            update workItemUpdateLst;

            workOrder = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workOrder.Id LIMIT 1 ];
            System.assertEquals( 'Completed', workOrder.Status, 'The Work Order is expected to update the status to Completed, it is currently: ' + workOrder.Status );

        Test.stopTest();
    }

    // These 2 tests are disabled because date validation is disabled

    //@IsTest
    // static void stampStatusChange() {
    //     List<Account> aList = [Select id from account];
    //     final WorkType WORK_TYPE_RI = [ SELECT Id FROM WorkType WHERE Name = 'Asset Verification' LIMIT 1 ];

    //     WorkOrder workOrder = new WorkOrder(
    //         WorkTypeId = WORK_TYPE_RI.Id,
    //         AccountId = aList[0].Id,
    //         Status = 'New'
    //     );
    //     insert workOrder;

    //     User user = [ SELECT Id FROM User WHERE email = :WorkOrderLineItemTriggerUtilityTest.EMAIL LIMIT 1 ];

    //     Test.startTest();

    //         WorkOrderLineItem workItem = new WorkOrderLineItem(
    //             WorkTypeId = WORK_TYPE_RI.Id,
    //             WorkOrderId = workOrder.Id,
    //             Status = 'New'
    //         );
    //         System.runAs( user ) {
    //             insert workItem;
    //         }
    //         workItem = [ SELECT Id, Last_Status_Set_Time__c FROM WorkOrderLineItem WHERE Id = :workItem.Id LIMIT 1 ];
    //         System.assertNotEquals( null, workItem.Last_Status_Set_Time__c, 'The Work Order Line Item is expected to have the Last Status Set Time field stamped' );

    //     Test.stopTest();
    // }

    // @IsTest
    // static void invalidStatusChange() {
    //     List<Account> aList = [Select id from account];
    //     final WorkType WORK_TYPE_RI = [ SELECT Id FROM WorkType WHERE Name = 'Asset Verification' LIMIT 1 ];

    //     WorkOrder workOrder = new WorkOrder(
    //         WorkTypeId = WORK_TYPE_RI.Id,
    //         AccountId = aList[0].Id,
    //         Status = 'New'
    //     );
    //     insert workOrder;

    //     WorkOrderLineItem workItem = new WorkOrderLineItem(
    //         WorkTypeId = WORK_TYPE_RI.Id,
    //         WorkOrderId = workOrder.Id,
    //         Status = 'New'
    //     );
        
    //     User user = [ SELECT Id FROM User WHERE email = :WorkOrderLineItemTriggerUtilityTest.EMAIL LIMIT 1 ];

    //     System.runAs( user ) {
    //         insert workItem;
    //     }
    //     workItem = [ SELECT Id, Last_Status_Set_Time__c FROM WorkOrderLineItem WHERE Id = :workItem.Id LIMIT 1 ];
    //     System.assertNotEquals( null, workItem.Last_Status_Set_Time__c, 'The Work Order Line Item is expected to have the Last Status Set Time field stamped' );

    //     workItem.Last_Status_Set_Time__c = Datetime.now().addDays( -1 ).addMinutes( -5 );
    //     update workItem;

    //     Test.startTest();

    //         workItem.Status = 'In Progress';
    //         try {
    //             System.runAs( user ) {
    //                 update workItem;
    //             }
    //         } catch ( exception e ) {
    //             System.assert( e.getMessage().contains( 'You can not change a status after 1 days have passed' ), 'An error was expected to be thrown to prevent the update of this Work Order Line Item that was last updated over a day ago' );
    //         }

    //     Test.stopTest();
    // }
}