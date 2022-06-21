/**
 * @description       : Test class for IdentifyDuplicatedRevolvingAppointments
 * @author            : v-dchaves@acvauctions.com
 * @group             : Scheduling
 * @last modified on  : 05-20-2022
 * @last modified by  : v-dchaves@acvauctions.com
**/
@IsTest
public with sharing class IdentifyDuplicatedRevolvingAppointTest {
    public static void createData(Integer numRecords){
        // create 5000 records
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acc = TestUtility.createAccount();
        insert acc;

        WorkType inspectionWorkType = [SELECT Id, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];

        Timeline__c timeRec = new Timeline__c(
                Account__c = acc.Id,
                Is_Active__c = TRUE,
                Start_Date__c = Date.today().addDays(-7),
                Average_Number_Cars__c = 1,
                Work_Type__c = inspectionWorkType.Id
            );
        insert timeRec;
    
        Occurrence__c occRec = RevolvingTest.generateTestOcc( timeRec, 'TestName', 'Daily', 1, tracDateUtils.DAY, null );
        insert occRec;

        Id territoryId = [SELECT Id FROM ServiceTerritory LIMIT 1].Id;

        List<WorkOrder> wrkOrders = new List<WorkOrder>();

        for (Integer i = 0; i < numRecords; i++){
            WorkOrder workOrder = new WorkOrder(AccountId = acc.Id,
                                                ServiceTerritoryId = territoryId,
                                                WorkTypeId = inspectionWorkType.Id,
                                                Status = 'New',
                                                Priority = 'Low',
                                                Occurrence__c = occRec.Id);

            wrkOrders.add(workOrder);
        }
        insert wrkOrders;

        List<ServiceAppointment> toUpdate = [SELECT Id, Work_Order__r.Occurrence__c, EarliestStartTime, DueDate
                                             FROM ServiceAppointment
                                             LIMIT :numRecords];

        // assign different dates to make it not duplicated
        Datetime aDate = Datetime.newInstance(1996, 09, 28);
        Integer i = 1;
        for (ServiceAppointment srvcAppointment : toUpdate){
            srvcAppointment.DueDate = aDate.addDays(i * 2);
            srvcAppointment.EarliestStartTime = aDate.addDays(1);

            i++;
        }
        update toUpdate;
    }

    @IsTest
    public static Void generalTest(){
        Integer numDuplicated = 0;

        createData(10);

        List<ServiceAppointment> toUpdate = [SELECT Id, Work_Order__r.Occurrence__c, EarliestStartTime, DueDate
                                             FROM ServiceAppointment
                                             LIMIT 5];
        
        // make some records as duplicate
        for (Integer i = 0; i < toUpdate.size() - 1; i ++) {
            ServiceAppointment srvcA = toUpdate[i];
            ServiceAppointment srvcB = toUpdate[i + 1];

            srvcB.EarliestStartTime = srvcA.EarliestStartTime;
            srvcB.DueDate = srvcA.DueDate;

            numDuplicated += 1;
        }
        update toUpdate;

        Test.startTest();
            IdentifyDuplicatedRevolvingAppointments job = new IdentifyDuplicatedRevolvingAppointments();
            Database.executeBatch(job, 1000);
        Test.stopTest();

        System.assertEquals(numDuplicated, 
                            IdentifyDuplicatedRevolvingAppointments.batchReturn.errorReturnLst.size(), 
                            'The batch isnt getting all duplicated Service Appointments created today');
    }

    @IsTest
    public static Void emptyTest(){
        Integer numDuplicated = 0;

        createData(10);

        Test.startTest();
            IdentifyDuplicatedRevolvingAppointments job = new IdentifyDuplicatedRevolvingAppointments();
            Database.executeBatch(job, 1000);
        Test.stopTest();

        System.assertEquals(0, 
                            IdentifyDuplicatedRevolvingAppointments.batchReturn.errorReturnLst.size(), 
                            'The batch are getting some records that are not duplicated');
    }

    public static Void bulkTest(){
        Integer numDuplicated = 0;

        createData(400);

        List<ServiceAppointment> toUpdate = [SELECT Id, Work_Order__r.Occurrence__c, EarliestStartTime, DueDate
                                             FROM ServiceAppointment
                                             LIMIT 5];
        
        // make some records as duplicate
        for (Integer i = 0; i < toUpdate.size() - 1; i ++) {
            ServiceAppointment srvcA = toUpdate[i];
            ServiceAppointment srvcB = toUpdate[i + 1];

            srvcB.EarliestStartTime = srvcA.EarliestStartTime;
            srvcB.DueDate = srvcA.DueDate;

            numDuplicated += 1;
        }
        update toUpdate;

        Test.startTest();
            IdentifyDuplicatedRevolvingAppointments job = new IdentifyDuplicatedRevolvingAppointments();
            Database.executeBatch(job, 1000);
        Test.stopTest();

        System.assertEquals(numDuplicated, 
                            IdentifyDuplicatedRevolvingAppointments.batchReturn.errorReturnLst.size(), 
                            'The batch isnt getting all duplicated Service Appointments created today');
    }
}