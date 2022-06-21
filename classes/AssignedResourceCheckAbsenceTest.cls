@isTest
public class AssignedResourceCheckAbsenceTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

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
        WorkType vciWorkType = new WorkType(
            Name = 'Standard Inspection', 
            EstimatedDuration = 1, 
            ShouldAutoCreateSvcAppt = false
        );
        insert vciWorkType;

        // Create Work Order (needed for Service Appointment):
        WorkOrder vciWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciWorkType.Id, 
            Priority = 'Low'
        );
        insert vciWorkOrder;

        // insert vciServiceResource;
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
            Status = 'None',
            Subject = 'vciServiceAppointmentSubject', 
            DueDate = Date.today().addMonths(1), 
            EarliestStartTime = DateTime.now(),
            SchedStartTime = DateTime.now().addHours(10), 
            SchedEndTime = DateTime.now().addHours(15)
        );
        insert vciServiceAppointment;
    }


    @IsTest
    static void testResourceAbsenceBEFOREAppt() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject' ];

        // Create Resource Absence:
        ResourceAbsence vciResourceAbsence = new ResourceAbsence(
            resourceid = testSvcRsrcList[0].Id,
            recordTypeID = '0120a0000010R3lAAE',
            type = 'Vacation',
            start = DateTime.now().addHours(2),
            end = DateTime.now().addHours(5)
        );
        insert vciResourceAbsence;

        Test.startTest();

        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcRsrcList[0].Id, 
            ServiceAppointmentId = testSvcApptList[0].Id
        );

        Boolean checkError = false;
        TRY {
            insert vciAssignedResource;
        } CATCH(Exception eAbsence) {
            if (eAbsence.getMessage().contains(AssignedResourceCheckAbsence.ERROR_MSG)) {
                checkError = true;
            }
        }

        Test.stopTest();

        // System.debug('testResourceAbsenceBEFOREAppt checkError = ' + checkError);
        System.assert(!checkError, 'Assigned Resource should insert because Service Resource does NOT have a conflicting Resource Absence.');
        Integer numOfOps = [Select Id from AssignedResource].size();
        System.assert( numOfOps == 1, '1 Assigned Resource should exist because Service Resource does NOT have a conflicting Resource Absence.  Instead Found ' + numOfOps);
    }


    @IsTest
    static void testResourceAbsenceAFTERAppt() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject' ];

        // Create Resource Absence:
        ResourceAbsence vciResourceAbsence = new ResourceAbsence(
            resourceid = testSvcRsrcList[0].Id,
            recordTypeID = '0120a0000010R3lAAE',
            type = 'Vacation',
            start = DateTime.now().addHours(20),
            end = DateTime.now().addHours(23)
        );
        insert vciResourceAbsence;

        Test.startTest();

        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcRsrcList[0].Id, 
            ServiceAppointmentId = testSvcApptList[0].Id
        );

        Boolean checkError = false;
        TRY {
            insert vciAssignedResource;
        } CATCH(Exception eAbsence) {
            if (eAbsence.getMessage().contains(AssignedResourceCheckAbsence.ERROR_MSG)) {
                checkError = true;
            }
        }

        Test.stopTest();

        // System.debug('testResourceAbsenceAFTERAppt checkError = ' + checkError);
        System.assert(!checkError, 'Assigned Resource should insert because Service Resource does NOT have a conflicting Resource Absence.');
        Integer numOfOps = [Select Id from AssignedResource].size();
        System.assert( numOfOps == 1, '1 Assigned Resource should exist because Service Resource does NOT have a conflicting Resource Absence.  Instead Found ' + numOfOps);
    }


    @IsTest
    static void testResourceAbsenceOverlapsBeginningOfAppt() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject' ];

        // Create Resource Absence:
        ResourceAbsence vciResourceAbsence = new ResourceAbsence(
            resourceid = testSvcRsrcList[0].Id,
            recordTypeID = '0120a0000010R3lAAE',
            type = 'Vacation',
            start = DateTime.now().addHours(7),
            end = DateTime.now().addHours(12)
        );
        insert vciResourceAbsence;

        Test.startTest();

        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcRsrcList[0].Id, 
            ServiceAppointmentId = testSvcApptList[0].Id
        );

        Boolean checkError = false;
        TRY {
            insert vciAssignedResource;
        } CATCH(Exception eAbsence) {
            if (eAbsence.getMessage().contains(AssignedResourceCheckAbsence.ERROR_MSG)) {
                checkError = true;
            }
        }

        Test.stopTest();

        // System.debug('testResourceAbsenceOverlapsBeginningOfAppt checkError = ' + checkError);
        System.assert(checkError, 'Assigned Resource should NOT insert because Service Resource has a conflicting Resource Absence.');
        Integer numOfOps = [Select Id from AssignedResource].size();
        System.assert( numOfOps == 0, '0 Assigned Resource should exist because Service Resource has a conflicting Resource Absence.  Instead Found ' + numOfOps);
    }


    @IsTest
    static void testResourceAbsenceInMiddleOfAppt() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject' ];

        // Create Resource Absence:
        ResourceAbsence vciResourceAbsence = new ResourceAbsence(
            resourceid = testSvcRsrcList[0].Id,
            recordTypeID = '0120a0000010R3lAAE',
            type = 'Vacation',
            start = DateTime.now().addHours(11),
            end = DateTime.now().addHours(14)
        );
        insert vciResourceAbsence;

        Test.startTest();

        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcRsrcList[0].Id, 
            ServiceAppointmentId = testSvcApptList[0].Id
        );

        Boolean checkError = false;
        TRY {
            insert vciAssignedResource;
        } CATCH(Exception eAbsence) {
            if (eAbsence.getMessage().contains(AssignedResourceCheckAbsence.ERROR_MSG)) {
                checkError = true;
            }
        }

        Test.stopTest();

        // System.debug('testResourceAbsenceInMiddleOfAppt checkError = ' + checkError);
        System.assert(checkError, 'Assigned Resource should NOT insert because Service Resource has a conflicting Resource Absence.');
        Integer numOfOps = [Select Id from AssignedResource].size();
        System.assert( numOfOps == 0, '0 Assigned Resource should exist because Service Resource has a conflicting Resource Absence.  Instead Found ' + numOfOps);
    }


    @IsTest
    static void testResourceAbsenceOverlapsEndOfAppt() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject' ];

        // Create Resource Absence:
        ResourceAbsence vciResourceAbsence = new ResourceAbsence(
            resourceid = testSvcRsrcList[0].Id,
            recordTypeID = '0120a0000010R3lAAE',
            type = 'Vacation',
            start = DateTime.now().addHours(13),
            end = DateTime.now().addHours(18)
        );
        insert vciResourceAbsence;

        Test.startTest();

        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcRsrcList[0].Id, 
            ServiceAppointmentId = testSvcApptList[0].Id
        );

        Boolean checkError = false;
        TRY {
            insert vciAssignedResource;
        } CATCH(Exception eAbsence) {
            if (eAbsence.getMessage().contains(AssignedResourceCheckAbsence.ERROR_MSG)) {
                checkError = true;
            }
        }

        Test.stopTest();

        // System.debug('testResourceAbsenceOverlapsEndOfAppt checkError = ' + checkError);
        System.assert(checkError, 'Assigned Resource should NOT insert because Service Resource has a conflicting Resource Absence.');
        Integer numOfOps = [Select Id from AssignedResource].size();
        System.assert( numOfOps == 0, '0 Assigned Resource should exist because Service Resource has a conflicting Resource Absence.  Instead Found ' + numOfOps);
    }


    @IsTest
    static void testApptInMiddleOfResourceAbsence() {

        List<ServiceResource> testSvcRsrcList = [ SELECT Id FROM ServiceResource WHERE  Name = 'vciTestServiceResource' ];
        List<ServiceAppointment> testSvcApptList = [ SELECT Id FROM ServiceAppointment WHERE Subject = 'vciServiceAppointmentSubject' ];

        // Create Resource Absence:
        ResourceAbsence vciResourceAbsence = new ResourceAbsence(
            resourceid = testSvcRsrcList[0].Id,
            recordTypeID = '0120a0000010R3lAAE',
            type = 'Vacation',
            start = DateTime.now().addHours(7),
            end = DateTime.now().addHours(18)
        );
        insert vciResourceAbsence;

        Test.startTest();

        // Create Assigned Resource:
        AssignedResource vciAssignedResource = new AssignedResource(
            ServiceResourceId = testSvcRsrcList[0].Id, 
            ServiceAppointmentId = testSvcApptList[0].Id
        );

        Boolean checkError = false;
        TRY {
            insert vciAssignedResource;
        } CATCH(Exception eAbsence) {
            if (eAbsence.getMessage().contains(AssignedResourceCheckAbsence.ERROR_MSG)) {
                checkError = true;
            }
        }

        Test.stopTest();

        // System.debug('testApptInMiddleOfResourceAbsence checkError = ' + checkError);
        System.assert(checkError, 'Assigned Resource should NOT insert because Service Resource has a conflicting Resource Absence.');
        Integer numOfOps = [Select Id from AssignedResource].size();
        System.assert( numOfOps == 0, '0 Assigned Resource should exist because Service Resource has a conflicting Resource Absence.  Instead Found ' + numOfOps);
    }

}