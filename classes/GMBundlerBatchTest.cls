@isTest
public class GMBundlerBatchTest {
    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;
        ServiceTerritory testST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        List<String> workTypeUniqueIdList = new List<String>{'gmfia', 'cpogm'};
        List<WorkType> workTypeList = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c IN :workTypeUniqueIdList ORDER BY Work_Type_Unique_Id__c];
        WorkType cpogmWT = workTypeList[0];
        WorkType gmfiaWT = workTypeList[1];
        List<WorkOrder> woInsertList = new List<WorkOrder>();
        WorkOrder cpogmWO = FSLTestUtility.createWorkOrder( cpogmWT, acct, '14209', testST, null );
        WorkOrder gmfiaWO = FSLTestUtility.createWorkOrder( gmfiaWT, acct, '14209', testST, null );
        woInsertList.add(cpogmWO);
        woInsertList.add(gmfiaWO);
        insert woInsertList;
        List<WorkOrderLineItem> woliInsertList = new List<WorkOrderLineItem>();
        WorkOrderLineItem cpogmLineItem = FSLTestUtility.createWorkOrderLineItem( cpogmWO, cpogmWT, 0 );
        WorkOrderLineItem gmfiaLineItem = FSLTestUtility.createWorkOrderLineItem( gmfiaWO, gmfiaWT, 0 );
        woliInsertList.add(cpogmLineItem);
        woliInsertList.add(gmfiaLineItem);

        insert woliInsertList;
    }

    @IsTest
    static void successfulBundle(){
        List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, DueDate, WorkType.Work_Type_Unique_ID__c FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            if(sa.WorkType.Work_Type_Unique_ID__c == 'gmfia'){
                sa.EarliestStartTime = system.today().addDays(16);
                sa.DueDate = system.today().addDays(28);

            } else if(sa.WorkType.Work_Type_Unique_ID__c == 'cpogm'){
                sa.EarliestStartTime = system.today().addDays(18);
                sa.DueDate = system.today().addDays(30);
            }
        }
        update saList;

        Test.startTest();
        Database.executeBatch( new GMBundlerBatch(), 200 );
        Test.stopTest();

        List<WorkOrder> workOrderList = [SELECT Id, LineItemCount FROM WorkOrder];
        system.assert(workOrderList.size() == 1, 'Exptected 1 work order, actual = ' + workOrderList.size());
        system.assert(workOrderList[0].LineItemCount == 2, 'Expected 2 line items, actual = ' + workOrderList[0].LineItemCount);

        List<ServiceAppointment> updatedSAList = [SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment];
        system.assert(updatedSAList.size() == 1, 'Expect 1 SA, actual = ' + updatedSAList.size());
        system.assert(updatedSAList[0].EarliestStartTime == system.today().addDays(18), 'Expected ' + system.today().addDays(18) + ', Actual ' + updatedSAList[0].EarliestStartTime);
        system.assert(updatedSAList[0].DueDate == system.today().addDays(28), 'Expected ' + system.today().addDays(28) + ', Actual ' + updatedSAList[0].DueDate);

    }

    @IsTest
    static void noBundleNotEnoughOverlap(){
        List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, DueDate, WorkType.Work_Type_Unique_ID__c FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            if(sa.WorkType.Work_Type_Unique_ID__c == 'gmfia'){
                sa.EarliestStartTime = system.today().addDays(16);
                sa.DueDate = system.today().addDays(25);

            } else if(sa.WorkType.Work_Type_Unique_ID__c == 'cpogm'){
                sa.EarliestStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(30);
            }
        }
        update saList;

        Test.startTest();
        Database.executeBatch( new GMBundlerBatch(), 200 );
        Test.stopTest();

        List<WorkOrder> workOrderList = [SELECT Id, LineItemCount FROM WorkOrder];
        system.assert(workOrderList.size() == 2, 'Exptected 2 work order, actual = ' + workOrderList.size());
    }

    @IsTest
    static void noBundleNotEnoughLeadTime(){
        List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, DueDate, WorkType.Work_Type_Unique_ID__c FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            if(sa.WorkType.Work_Type_Unique_ID__c == 'gmfia'){
                sa.EarliestStartTime = system.today().addDays(10);
                sa.DueDate = system.today().addDays(25);

            } else if(sa.WorkType.Work_Type_Unique_ID__c == 'cpogm'){
                sa.EarliestStartTime = system.today().addDays(10);
                sa.DueDate = system.today().addDays(25);
            }
        }
        update saList;

        Test.startTest();
        Database.executeBatch( new GMBundlerBatch(), 200 );
        Test.stopTest();

        List<WorkOrder> workOrderList = [SELECT Id, LineItemCount FROM WorkOrder];
        system.assert(workOrderList.size() == 2, 'Exptected 2 work order, actual = ' + workOrderList.size());
    }

    @IsTest
    static void noBundleWrongStatus(){
        FSL.GlobalAPIS.addStatusTransition('New', 'Dispatched');
        List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, DueDate, WorkType.Work_Type_Unique_ID__c, SchedEndTime, SchedStartTime FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            if(sa.WorkType.Work_Type_Unique_ID__c == 'gmfia'){
                sa.EarliestStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(30);

            } else if(sa.WorkType.Work_Type_Unique_ID__c == 'cpogm'){
                sa.EarliestStartTime = system.today().addDays(20);
                sa.SchedStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(30);
                sa.SchedEndTime = system.today().addDays(30);
                sa.Status = 'Dispatched';
            }
        }
        update saList;

        Test.startTest();
        Database.executeBatch( new GMBundlerBatch(), 200 );
        Test.stopTest();

        List<WorkOrder> workOrderList = [SELECT Id, LineItemCount FROM WorkOrder];
        system.assert(workOrderList.size() == 2, 'Exptected 2 work order, actual = ' + workOrderList.size());
    }

    @IsTest
    static void noBundleDifferentAddresses(){

        List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, DueDate, WorkType.Work_Type_Unique_ID__c FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            if(sa.WorkType.Work_Type_Unique_ID__c == 'gmfia'){
                sa.Street = 'Different Street';
                sa.EarliestStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(40);

            } else if(sa.WorkType.Work_Type_Unique_ID__c == 'cpogm'){
                sa.EarliestStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(40);
            }
        }
        update saList;
        Test.startTest();
        Database.executeBatch( new GMBundlerBatch(), 200 );
        Test.stopTest();

        List<WorkOrder> workOrderList = [SELECT Id, LineItemCount FROM WorkOrder];
        system.assert(workOrderList.size() == 2, 'Exptected 2 work order, actual = ' + workOrderList.size());

    }

    @IsTest
    static void noBundleDifferentWorkTypes(){
        delete [SELECT Id FROM WorkOrder WHERE WorkType.Work_Type_Unique_ID__c = 'cpogm'];

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];

        ServiceTerritory testST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];

        WorkType standardInspectionWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'inspection' LIMIT 1];

        WorkOrder standardInspectionWO = FSLTestUtility.createWorkOrder( standardInspectionWT, acct, '14209', testST, null );
        insert standardInspectionWO;

        WorkOrderLineItem standardInspectionWOLI = FSLTestUtility.createWorkOrderLineItem( standardInspectionWO, standardInspectionWT, 0 );
        insert standardInspectionWOLI;


        List<ServiceAppointment> saList = [SELECT Id, EarliestStartTime, DueDate, WorkType.Work_Type_Unique_ID__c FROM ServiceAppointment];
        for(ServiceAppointment sa : saList){
            if(sa.WorkType.Work_Type_Unique_ID__c == 'gmfia'){
                sa.EarliestStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(40);

            } else if(sa.WorkType.Work_Type_Unique_ID__c == 'inspection'){
                sa.EarliestStartTime = system.today().addDays(20);
                sa.DueDate = system.today().addDays(40);
            }
        }
        update saList;

        Test.startTest();
        Database.executeBatch( new GMBundlerBatch(), 200 );
        Test.stopTest();

        List<WorkOrder> workOrderList = [SELECT Id, LineItemCount FROM WorkOrder];
        system.assert(workOrderList.size() == 2, 'Exptected 2 work order, actual = ' + workOrderList.size());
    }
}