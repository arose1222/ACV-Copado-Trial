@isTest
public class CheckForInProgressWorkTest {

    static Date TODAY = system.today();
    static Datetime SCHED_START = system.now();
    static Datetime SCHED_END = system.now().addHours(1);

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
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
        WorkType vciWorkType = new WorkType(
            Name = 'Standard Inspection',
            EstimatedDuration = 1,
            ShouldAutoCreateSvcAppt = false
        );
        insert vciWorkType;

        // Create 4 Work Orders (needed for Service Appointment):
        List<WorkOrder> woInsertList = new List<WorkOrder>();
        for (Integer i = 0, j = 0; i < 4; i++){
            woInsertList.add(
                new WorkOrder(
                    AccountId = vciAccount.Id,
                    ServiceTerritoryId = vciServiceTerritory.Id,
                    WorkTypeId = vciWorkType.Id,
                    Priority = 'Low'
                    )
            );
        }

        insert woInsertList;

        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData();

        List<ServiceAppointment> saUpdateList = [SELECT Id, Current_Service_Resource__c, SchedStartTime, SchedEndTime FROM ServiceAppointment];
        for(ServiceAppointment sa : saUpdateList){
            Integer i = 0;

            sa.Current_Service_Resource__c = vciServiceResource.Id;

            if(i < saUpdateList.size()/2){
                sa.SchedStartTime = SCHED_START;
                sa.SchedEndTime = SCHED_END.addHours(1);
                sa.Subject = 'today';
            } else {
                sa.SchedStartTime = SCHED_START.addDays(1);
                sa.SchedEndTime = SCHED_END.addDays(1).addHours(1);
                sa.Subject = 'tomorrow';
            }
            i++;
        }
        update saUpdateList;
    }

    @isTest
    public static void wipStatusUpdate(){
        List<ServiceAppointment> saList = [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, Status, SchedStartTime FROM ServiceAppointment];

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment sa : saList){
            system.assert(sa.Assigned_Resource_Has_In_Progress_Work__c == false);
        }

        //Update the status of one of todays SA's to In Progress
        FSL.GlobalAPIS.addStatusTransition( 'New', 'In Progress' );
        ServiceAppointment firstSA = [SELECT Id, Status FROM ServiceAppointment WHERE Subject = 'today' LIMIT 1];
        firstSA.Status = 'In Progress';
        update firstSA;

        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, SchedStartTime FROM ServiceAppointment]){
            //Assert that all of Todays SA are marked as WIP = true
            if(updatedSA.SchedStartTime.date() == TODAY){
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == true);
            } else {
                //Assert that all SA that are not starting today are marked as WIP = false
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
            }
        }
        test.startTest();
        //Update the In Progress SA to Acknowledged
        FSL.GlobalAPIS.addStatusTransition( 'In Progress', 'Acknowledged' );
        firstSA.Status = 'Acknowledged';
        update firstSA;

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment]){
            system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
        }
        test.stopTest();

    }

    @isTest
    public static void wipCurrentResourceUpdate(){
        List<ServiceAppointment> saList = [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, Status, SchedStartTime FROM ServiceAppointment];

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment sa : saList){
            system.assert(sa.Assigned_Resource_Has_In_Progress_Work__c == false);
        }

        //Update the status of one of todays SA's to In Progress
        FSL.GlobalAPIS.addStatusTransition( 'New', 'In Progress' );
        ServiceAppointment firstSA = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment WHERE Subject = 'today' LIMIT 1];
        firstSA.Status = 'In Progress';
        update firstSA;

        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, SchedStartTime FROM ServiceAppointment]){
            //Assert that all of Todays SA are marked as WIP = true
            if(updatedSA.SchedStartTime.date() == TODAY){
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == true);
            } else {
                //Assert that all SA that are not starting today are marked as WIP = false
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
            }
        }

        test.startTest();
        //Change the service resource of the in progress SA
        ServiceResource vciServiceResource2 = FSLTestUtility.makeResourceData();
        firstSA.Current_Service_Resource__c = vciServiceResource2.Id;
        update firstSA;

        //Assert that all SA assigned to the new resource are marked as WIP = true
        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, Current_Service_Resource__c FROM ServiceAppointment]){
            if(updatedSA.Current_Service_Resource__c == vciServiceResource2.Id){
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == true);
            } else {
                //Assert that all SA assigned to the new resource are marked as WIP = false
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
            }
        }
        test.stopTest();

    }


    @isTest
    public static void wipSchedStartUpdate(){
        List<ServiceAppointment> saList = [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, Status, SchedStartTime FROM ServiceAppointment];

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment sa : saList){
            system.assert(sa.Assigned_Resource_Has_In_Progress_Work__c == false);
        }

        //Update the status of one of todays SA's to In Progress
        FSL.GlobalAPIS.addStatusTransition( 'New', 'In Progress' );
        ServiceAppointment firstSA = [SELECT Id, Status, Current_Service_Resource__c FROM ServiceAppointment WHERE Subject = 'today' LIMIT 1];
        firstSA.Status = 'In Progress';
        update firstSA;

        test.startTest();
        //Retrieve one of todays SAs that is not in progress
        ServiceAppointment notInProgressSA = [SELECT Id, Status, Assigned_Resource_Has_In_Progress_Work__c, SchedStartTime, SchedEndTime FROM ServiceAppointment WHERE Subject = 'today' AND StatusCategory != 'InProgress' LIMIT 1];
        system.assert(notInProgressSA.Assigned_Resource_Has_In_Progress_Work__c == true);
        //Change the sched start of todays SA that is not in progress to a different day
        notInProgressSA.SchedStartTime = SCHED_START.addDays(1);
        notInProgressSA.SchedEndTime = SCHED_END.addDays(1).addHours(1);
        update notInProgressSA;


        //Assert that the SA is no longer mareked as WIP = true
        ServiceAppointment updatedNotInProgressSA = [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment WHERE Id = :notInProgressSA.Id];
        system.assert(updatedNotInProgressSA.Assigned_Resource_Has_In_Progress_Work__c == false);
        test.stopTest();

    }

    @isTest
    public static void wipDeleteInProgressSA(){
        List<ServiceAppointment> saList = [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, Status, SchedStartTime FROM ServiceAppointment];

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment sa : saList){
            system.assert(sa.Assigned_Resource_Has_In_Progress_Work__c == false);
        }

        //Update the status of one of todays SA's to In Progress
        FSL.GlobalAPIS.addStatusTransition( 'New', 'In Progress' );
        ServiceAppointment firstSA = [SELECT Id, Status FROM ServiceAppointment WHERE Subject = 'today' LIMIT 1];
        firstSA.Status = 'In Progress';
        update firstSA;

        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c, SchedStartTime FROM ServiceAppointment]){
            //Assert that all of Todays SA are marked as WIP = true
            if(updatedSA.SchedStartTime.date() == TODAY){
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == true);
            } else {
                //Assert that all SA that are not starting today are marked as WIP = false
                system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
            }
        }

        test.startTest();
        //Delete the 'In Progress' SA
        delete firstSA;

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment]){
            system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
        }
        test.stopTest();

    }

    @isTest
    public static void RemoveInProgressWorkBatchTest(){
        List<ServiceAppointment> saToUpdateList = new List<ServiceAppointment>();
        for(ServiceAppointment sa : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment]){
            sa.Assigned_Resource_Has_In_Progress_Work__c = true;
            saToUpdateList.add(sa);
        }
        update saToUpdateList;

        //Assert that all SA are marked as WIP = true
        for(ServiceAppointment sa : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment]){
            system.assert(sa.Assigned_Resource_Has_In_Progress_Work__c == true);
        }

        test.startTest();
        Database.executeBatch(new RemoveInProgressWorkBatch());
        test.stopTest();

        //Assert that all SA are marked as WIP = false
        for(ServiceAppointment updatedSA : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment]){
            system.assert(updatedSA.Assigned_Resource_Has_In_Progress_Work__c == false);
        }
    }
}