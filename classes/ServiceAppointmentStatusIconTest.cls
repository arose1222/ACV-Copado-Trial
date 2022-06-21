@isTest
public class ServiceAppointmentStatusIconTest {

    @TestSetup
    public static void makeData() {

        FSL.GlobalAPIS.addStatusTransition('New', 'Scheduled');
        FSL.GlobalAPIS.addStatusTransition('New', 'Dispatched');
        FSL.GlobalAPIS.addStatusTransition('New', 'Acknowledged');
        FSL.GlobalAPIS.addStatusTransition('New', 'Travel');
        FSL.GlobalAPIS.addStatusTransition('New', 'Arrived');
        FSL.GlobalAPIS.addStatusTransition('New', 'In Progress');
        FSL.GlobalAPIS.addStatusTransition('New', 'Completed');
        FSL.GlobalAPIS.addStatusTransition('New', 'Canceled');
        FSL.GlobalAPIS.addStatusTransition('New', 'Expired');
        FSL.GlobalAPIS.addStatusTransition('New', 'Offer Attempted');
        FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Cannot Complete');

        // Create Account (needed for Work Order):
        Account vciAccount = TestUtility.createAccount('vciTestAccount');
        insert vciAccount;

        // Create Operating Hours (needed for Service Service Territory & Service Territory Member):
        OperatingHours vciOperatingHours = new OperatingHours(Name = 'vciTestOpHours');
        insert vciOperatingHours;

        // Create Service Territory (needed for Work Order, Service Territory Member & Service Appointment):
        ServiceTerritory vciServiceTerritory = new ServiceTerritory(
            Name = 'Greater Buffalo',
            OperatingHoursId = vciOperatingHours.Id,
            IsActive = true
            );
        insert vciServiceTerritory;

        // Create Work Type (needed for Work Order):
        WorkType vciSIWorkType = new WorkType(
            Name = 'Standard Inspection',
            EstimatedDuration = 30,
            ShouldAutoCreateSvcAppt = false
        );
        insert vciSIWorkType;

        // Create Work Order (needed for Service Appointment):
        WorkOrder vciWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id,
            ServiceTerritoryId = vciServiceTerritory.Id,
            WorkTypeId = vciSIWorkType.Id,
            Subject = 'vciWorkOrderSubject',
            Status = 'New',
            Priority = 'Low'
        );
        insert vciWorkOrder;

        // Create Service Resource (needed for Service Territory Member):
        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData();

        // Create Service Territory Member:
        ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
            OperatingHoursId = vciOperatingHours.Id,
            ServiceTerritoryId = vciServiceTerritory.Id,
            ServiceResourceId = vciServiceResource.Id,
            EffectiveStartDate = Date.today(),
            TerritoryType = 'P'
        );
        insert vciServiceTerritoryMember;

        // Create Service Appointment:
        ServiceAppointment vciServiceAppointment = new ServiceAppointment(
            Description = '1',
            ServiceTerritoryId = vciServiceTerritory.Id,
            Work_Order__c = vciWorkOrder.Id,
            ParentRecordId = vciWorkOrder.Id,
            Status = 'New',
            Committed__c = false,
            Subject = 'vciServiceAppointmentSubject',
            DueDate = Date.today().addMonths(1),
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10),
            SchedEndTime = DateTime.now().addHours(15),
            FSL__GanttIcon__c = ''
        );
        insert vciServiceAppointment;

    }


    @IsTest
    static void testInsertNewServiceAppointmentCommittedTrue() {

        List<ServiceTerritory> testSvcTerrList = [ SELECT Id FROM ServiceTerritory WHERE  Name = 'Greater Buffalo' ];
        List<WorkOrder> testWorkOrderList = [ SELECT Id FROM WorkOrder WHERE Subject = 'vciWorkOrderSubject' ];

        test.startTest();

        // Create Service Appointment to TEST INSERT:
        ServiceAppointment vciServiceAppointment2 = new ServiceAppointment(
            Description = '2', 
            ServiceTerritoryId = testSvcTerrList[0].Id, 
            Work_Order__c = testWorkOrderList[0].Id, 
            ParentRecordId = testWorkOrderList[0].Id,
            Status = 'New',
            Committed__c = true,
            Subject = 'vciServiceAppointmentSubject2', 
            DueDate = Date.today().addMonths(1), 
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10), 
            SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment2;

        test.stopTest();
        
        String urlCommittedExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCommitted'}).get('FSLCommitted');
        // query
        List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, Status, Committed__c, FSL__GanttIcon__c 
                                                                       FROM ServiceAppointment 
                                                                      WHERE Subject = 'vciServiceAppointmentSubject2' ];

        // system.asserts
        System.assertEquals(urlCommittedExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToScheduled() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLScheduled'}).get('FSLScheduled');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, Status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Scheduled';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, Status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToDispatched() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLDispatched'}).get('FSLDispatched');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, Status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Dispatched';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, Status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToAcknowledged() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLAcknowledged'}).get('FSLAcknowledged');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Acknowledged';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToTravel() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLTravel'}).get('FSLTravel');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Travel';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToArrived() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLArrived'}).get('FSLArrived');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Arrived';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToInProgress() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLInProgress'}).get('FSLInProgress');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'In Progress';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToCompleted() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCompleted'}).get('FSLCompleted');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Completed';
                sa.SchedStartTime = DateTime.now().addHours(10);
                sa.SchedEndTime = DateTime.now().addHours(15);
                sa.ActualStartTime = DateTime.now().addHours(10);
                sa.ActualEndTime = DateTime.now().addHours(15);
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToCannotComplete() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCannotComplete'}).get('FSLCannotComplete');
            ServiceAppointment testSvcApptNew2Sched = [ SELECT Id, status, FSL__GanttIcon__c, Cannot_Complete_Reason__c, Completed_Canceled_Notes__c 
                                                          FROM ServiceAppointment 
                                                         WHERE Subject = 'vciServiceAppointmentSubject' LIMIT 1];

            ServiceResource testSvcResource = [SELECT Id FROM ServiceResource LIMIT 1];

            // Create Assigned Resource:
            AssignedResource vciAssignedResource = new AssignedResource(
                ServiceResourceId = testSvcResource.Id,
                ServiceAppointmentId = testSvcApptNew2Sched.Id
            );
            insert vciAssignedResource;

            ServiceAppointment testSvcApptSched2CC = [ SELECT Id, status, FSL__GanttIcon__c, Cannot_Complete_Reason__c, Completed_Canceled_Notes__c 
                                                         FROM ServiceAppointment 
                                                        WHERE Subject = 'vciServiceAppointmentSubject' LIMIT 1];

            testSvcApptSched2CC.status = 'Cannot Complete';
            testSvcApptSched2CC.Cannot_Complete_Reason__c = 'Other';
            testSvcApptSched2CC.Completed_Canceled_Notes__c = 'Notes for Other Reason';

            update testSvcApptSched2CC;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                          FROM ServiceAppointment
                                                                         WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');

        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToCanceled() {
        Test.startTest();
            String urlExpected = null;
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Canceled';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToExpired() {
        Test.startTest();
            String urlExpected = null;
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Expired';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusChangedToOfferAttempted() {
        Test.startTest();
            String urlExpected = null;
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.status = 'Offer Attempted';
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentCommittedOnlyChanged() {
        Test.startTest();
            String urlCommittedExpected1 = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCommitted'}).get('FSLCommitted');

            List<ServiceAppointment> testSvcApptList1 = [ SELECT Id, Status, Committed__c, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa1 : testSvcApptList1) {
                sa1.committed__c = True;
            }
            update testSvcApptList1;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon1 = [SELECT Id, Status, Committed__c, FSL__GanttIcon__c
                                                                            FROM ServiceAppointment
                                                                           WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlCommittedExpected1, checkServiceAppointmentGanttIcon1[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');

            String urlCommittedExpected2 = null;

            List<ServiceAppointment> testSvcApptList2 = [ SELECT Id, Status, Committed__c, FSL__GanttIcon__c 
                                                            FROM ServiceAppointment 
                                                           WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa2 : testSvcApptList2) {
                sa2.committed__c = False;
            }
            update testSvcApptList2;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon2 = [SELECT Id, Status, Committed__c, FSL__GanttIcon__c
                                                                            FROM ServiceAppointment
                                                                           WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlCommittedExpected2, checkServiceAppointmentGanttIcon2[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');

            Test.stopTest();
    }


    @IsTest
    static void testServiceAppointmentStatusAndCommittedChanged() {
        Test.startTest();
            String urlCommittedExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCommitted'}).get('FSLCommitted');
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLScheduled'}).get('FSLScheduled');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, Status, Committed__c, FSL__GanttIcon__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.committed__c = True;
                sa.status = 'Scheduled';
                }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, Status, Committed__c, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlCommittedExpected + ';' + urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Status Icons do not match.');
        Test.stopTest();
    }

    @IsTest
    static void testServiceAppointmentDryRunChanged() {
        Test.startTest();
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLDryRun'}).get('FSLDryRun');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, status, FSL__GanttIcon__c, Dry_Run__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.Dry_Run__c = true;
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Dry Run Icons do not match.');
        Test.stopTest();
    }

    @IsTest
    static void testServiceAppointmentDryRunAndCommittedChanged() {
        Test.startTest();
            String urlCommittedExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCommitted'}).get('FSLCommitted');
            String urlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLDryRun'}).get('FSLDryRun');
            List<ServiceAppointment> testSvcApptList = [ SELECT Id, Status, Committed__c, FSL__GanttIcon__c, Dry_Run__c 
                                                           FROM ServiceAppointment 
                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            for (ServiceAppointment sa : testSvcApptList) {
                sa.committed__c = True;
                sa.Dry_Run__c = true;
            }
            update testSvcApptList;

            // query
            List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, Status, Committed__c, FSL__GanttIcon__c
                                                                           FROM ServiceAppointment
                                                                          WHERE Subject = 'vciServiceAppointmentSubject' ];

            // system.asserts
            System.assertEquals(urlCommittedExpected + ';' + urlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Dry Run Icons do not match.');
        Test.stopTest();
    }

    @IsTest
    static void testServiceAppointmentRescheduled() {
        Test.startTest();
        String cannotCompleteUrlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLCannotComplete'}).get('FSLCannotComplete');
        String rescheduleUrlExpected = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLRescheduled'}).get('FSLRescheduled');
        
        ServiceAppointment testSvcAppt = [ SELECT Id, status, FSL__GanttIcon__c, Cannot_Complete_Reason__c, Completed_Canceled_Notes__c 
                                                   FROM ServiceAppointment 
                                                   WHERE Subject = 'vciServiceAppointmentSubject' LIMIT 1];
        
        ServiceResource testSvcResource = [SELECT Id FROM ServiceResource LIMIT 1];
        
        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcResource.Id,
            ServiceAppointmentId = testSvcAppt.Id
        );
        insert vciAssignedResource;
        
        testSvcAppt = [ SELECT Id, status, FSL__GanttIcon__c, Cannot_Complete_Reason__c, Completed_Canceled_Notes__c 
                                                  FROM ServiceAppointment 
                                                  WHERE Subject = 'vciServiceAppointmentSubject' LIMIT 1];
        
        testSvcAppt.status = 'Cannot Complete';
        testSvcAppt.Cannot_Complete_Reason__c = 'Other';
        testSvcAppt.Completed_Canceled_Notes__c = 'Notes for Other Reason';
        testSvcAppt.Has_Been_Rescheduled__c = true;
        
        update testSvcAppt;
        
        // query
        List<ServiceAppointment> checkServiceAppointmentGanttIcon = [SELECT Id, status, FSL__GanttIcon__c
                                                                     FROM ServiceAppointment
                                                                     WHERE Subject = 'vciServiceAppointmentSubject' ];
        
        // system.asserts
        System.assertEquals(cannotCompleteUrlExpected + ';' + rescheduleUrlExpected, checkServiceAppointmentGanttIcon[0].FSL__GanttIcon__c, 'Service Appointment Reschedule Icons do not match.');
        Test.stopTest();
    }

}