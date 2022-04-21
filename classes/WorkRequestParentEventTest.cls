@isTest
public class WorkRequestParentEventTest {
    private static final String LEGACY_INSPECTION_DB_INTEGRATION_USER = 'Legacy Inspection Services';
    private final static String TIME_ZONE = 'America/New_York';
    private final static String WORK_TYPE_UNIQUE_NAME = 'cpo';
    private final static String ZIPCODE = '14209';
    private final static String TERRITORY_NAME = 'Buffalo';

    @TestSetup
    static void makeData(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        WorkType cpo = new workType( Name = WORK_TYPE_UNIQUE_NAME, EstimatedDuration = 30, DurationType = 'Minutes', Work_Type_Unique_ID__c = WORK_TYPE_UNIQUE_NAME );
        insert cpo;

        Id integrationMappingUserId = [ SELECT SF_ID__c FROM Integration_User_Mapping__mdt WHERE Integration_Definition__c = :LEGACY_INSPECTION_DB_INTEGRATION_USER LIMIT 1 ].SF_ID__c;
        User integrationUser = new User( Id = integrationMappingUserId );

        Account acct = TestUtility.createAccount();
        insert acct;
        FSLTestUtility.createAllStructureWithParentST( TERRITORY_NAME, ZIPCODE );
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        System.runAs( integrationUser ) { // For These Integrations, WOLI must be created by this user
            WorkOrder testWork = FSLTestUtility.createWorkOrder( cpo, acct, ZIPCODE, stRec, null );
            testWork.Created_Without_Line_Items__c = TRUE;
            insert testWork;
        }

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        FSL.GlobalAPIS.addStatusTransition( 'Scheduled', FSLWorkProcessUtility.SA_DISPATCH_STATUS );
        FSL.GlobalAPIS.addStatusTransition( FSLWorkProcessUtility.SA_DISPATCH_STATUS, 'In Progress' );
        FSL.GlobalAPIS.addStatusTransition( FSLWorkProcessUtility.SA_DISPATCH_STATUS, 'Completed' );
        FSL.GlobalAPIS.addStatusTransition( FSLWorkProcessUtility.SA_DISPATCH_STATUS, 'Cannot Complete' );
        FSL.GlobalAPIS.addStatusTransition( 'Scheduled', 'New' );

        OperatingHours opt = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        opt.TimeZone = TIME_ZONE;
        update opt;

        ServiceAppointment testSA = [ SELECT Id, ServiceTerritoryId FROM ServiceAppointment LIMIT 1 ];
        testSA.SchedStartTime = DateTime.now().addMinutes(60);
        testSA.SchedEndTime = DateTime.now().addMinutes(90);
        update testSA;
    }

    private static void makeAR( ServiceAppointment testSA ) {
        FSLTestUtility.makeAR( testSA );
    }

    @IsTest
    static void dispatchWork(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        Test.startTest();
            ServiceAppointment saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            // Make AR due to query limits in earlier test
            makeAR( saRec );

            AssignedResource arRec = [ SELECT Id, ServiceAppointmentId FROM AssignedResource LIMIT 1 ];

            WorkRequestDispatchEvent controller = new WorkRequestDispatchEvent();
            controller.afterInsert( new Map<Id, AssignedResource>{ arRec.Id => arRec } );
        Test.stopTest();
    }

    @IsTest
    static void unassighWork(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        Test.startTest();
            ServiceAppointment saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            // Make AR due to query limits in earlier test
            makeAR( saRec );

            AssignedResource arRec = [ SELECT Id, ServiceResourceId, ServiceAppointmentId FROM AssignedResource LIMIT 1 ];

            WorkRequestUnassignEvent controller = new WorkRequestUnassignEvent();
            controller.afterDelete( new List<AssignedResource>{ arRec } );
        Test.stopTest();
    }

    @IsTest
    static void pinWork(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        Test.startTest();
            ServiceAppointment saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, WorkTypeId, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            // Make AR due to query limits in earlier test
            makeAR( saRec );

            saRec.Status = FSLWorkProcessUtility.SA_DISPATCH_STATUS;
            update saRec;

            ServiceAppointment oldSaRec = saRec.clone(true, true, false, false);
            saRec.Committed__c = TRUE;
            update saRec;

            WorkRequestPinnedEvent controller = new WorkRequestPinnedEvent();
            controller.afterUpdate( new Map<Id, ServiceAppointment>{ oldSaRec.Id => oldSaRec }, new Map<Id, ServiceAppointment>{ saRec.Id => saRec } );
        Test.stopTest();
    }

    @IsTest
    static void updateWorkStatusToInProgress(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        Test.startTest();
            ServiceAppointment saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, StatusCategory, DueDate, EarliestStartTime, SchedEndTime,  Duration, DurationInMinutes, Original_Due_Date__c, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            // Make AR due to query limits in earlier test
            makeAR( saRec );

            saRec.Status = FSLWorkProcessUtility.SA_DISPATCH_STATUS;
            update saRec;

            ServiceAppointment oldSaRec = saRec.clone(true, true, false, false);
            saRec.Status = 'In Progress';
            update saRec;
            saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, StatusCategory, DueDate, EarliestStartTime, SchedEndTime, Duration, DurationInMinutes, Original_Due_Date__c, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            WorkRequestAppointmentUpdateEvent controller = new WorkRequestAppointmentUpdateEvent();
            controller.afterUpdate( new Map<Id, ServiceAppointment>{ oldSaRec.Id => oldSaRec }, new Map<Id, ServiceAppointment>{ saRec.Id => saRec } );
        Test.stopTest();
    }

    @IsTest
    static void updateWorkStatusToComplete(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        Test.startTest();
            ServiceAppointment saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, StatusCategory, DueDate, EarliestStartTime, SchedEndTime,  Duration, DurationInMinutes, Original_Due_Date__c, ActualEndTime, ActualStartTime, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            // Make AR due to query limits in earlier test
            makeAR( saRec );

            saRec.Status = FSLWorkProcessUtility.SA_DISPATCH_STATUS;
            update saRec;

            ServiceAppointment oldSaRec = saRec.clone(true, true, false, false);
            saRec.Status = 'Completed';
            DateTime now = DateTime.now();
            saRec.ActualStartTime = now;
            saRec.ActualEndTime = now.addMinutes(30);
            update saRec;
            saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, StatusCategory, DueDate, EarliestStartTime, SchedEndTime,  Duration, DurationInMinutes, Original_Due_Date__c, ActualEndTime, ActualStartTime, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            WorkRequestCompleteEvent controller = new WorkRequestCompleteEvent();
            controller.afterUpdate( new Map<Id, ServiceAppointment>{ oldSaRec.Id => oldSaRec }, new Map<Id, ServiceAppointment>{ saRec.Id => saRec } );
        Test.stopTest();
    }

    @IsTest
    static void updateWorkStatusToCannotComplete(){
        Test.setMock( HttpCalloutMock.class, new MockCalloutUpdateSuccess() );
        Test.startTest();
            ServiceAppointment saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, StatusCategory, ActualEndTime, Completed_Canceled_Notes__c, Cannot_Complete_Reason__c, Contact_Name__c, ActualStartTime, DueDate, EarliestStartTime, SchedEndTime,  Duration, DurationInMinutes, Original_Due_Date__c, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            // Make AR due to query limits in earlier test
            makeAR( saRec );

            saRec.Status = FSLWorkProcessUtility.SA_DISPATCH_STATUS;
            update saRec;

            ServiceAppointment oldSaRec = saRec.clone(true, true, false, false);
            saRec.Status = 'Cannot Complete';
            DateTime now = DateTime.now();
            saRec.ActualStartTime = now;
            saRec.ActualEndTime = now.addMinutes(30);
            saRec.Contact_Name__c = 'John Smith';
            saRec.Cannot_Complete_Reason__c = 'Other';
            saRec.Completed_Canceled_Notes__c = 'There was an issue finding the vehicle';
            update saRec;
            saRec = [ SELECT Id, Status, CreatedById, ParentRecordId, SchedStartTime, Committed__c, StatusCategory, ActualEndTime, Completed_Canceled_Notes__c, Cannot_Complete_Reason__c, Contact_Name__c, ActualStartTime, DueDate, EarliestStartTime, SchedEndTime,  Duration, DurationInMinutes, Original_Due_Date__c, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];

            WorkRequestIncompleteEvent controller = new WorkRequestIncompleteEvent();
            controller.beforeUpdate( new Map<Id, ServiceAppointment>{ oldSaRec.Id => oldSaRec }, new Map<Id, ServiceAppointment>{ saRec.Id => saRec } );
        Test.stopTest();
    }

    private class MockCalloutUpdateSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"UpdateWorkItemResult": {"ErrorID": null,"Message": "Success","ReturnCode": 0,"Status": null,"StatusID": null}}'
            );
            res.setStatus('OK');
            return res;
        }
    }
}