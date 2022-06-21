@isTest
public class WorkRequestSearchControllerTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        
        Account a = TestUtility.createAccount();
        insert a;
        FSLTestUtility.createData( a, 1 );

        ServiceAppointment testSA = [ SELECT Id, ServiceTerritoryId FROM ServiceAppointment LIMIT 1 ];
        testSA.SchedStartTime = DateTime.now().addMinutes(60);
        testSA.SchedEndTime = DateTime.now().addMinutes(90);
        update testSA;
    }

    private static void makeAR( ServiceAppointment testSA ) {
        ServiceResource testSR = FSLTestUtility.makeResourceData();
        
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            OperatingHoursId = testSA.ServiceTerritory.OperatingHoursId, 
            ServiceTerritoryId = testSA.ServiceTerritoryId, 
            ServiceResourceId = testSR.Id,
            EffectiveStartDate = Date.today().addDays(-1), 
            TerritoryType = 'P'
        );
        insert stm;
        
        AssignedResource testAR = new AssignedResource(
            ServiceAppointmentId = testSA.Id,
            ServiceResourceId = testSR.Id
        );
        insert testAR;
    }

    @isTest
    static void searchDBForVIN() {
        Test.startTest();
            // Make AR due to query limits in earlier test
            ServiceAppointment sa  = [ SELECT Id, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];
            makeAR( sa );

            String searchTerm = '1234567890123456';
            WorkOrderLineItem testWOLI = [ SELECT Id FROM WorkOrderLineItem LIMIT 1 ];
            testWOLI.VIN__c = searchTerm;
            update testWOLI;

            WorkRequestSearchController.DataWrapper returnData;
            String rawJSON = WorkRequestSearchController.getData( searchTerm );
            returnData = (WorkRequestSearchController.DataWrapper) JSON.deserialize( rawJSON, WorkRequestSearchController.DataWrapper.class );

            System.assert( returnData != null, 'There was no proper return given' );
            System.assert( !returnData.allRows.isEmpty(), 'The return provided zero search results' );
            System.assertEquals( searchTerm, returnData.allRows[0].vin, 'The returned value had an unexpected output of ' + returnData.allRows[0].vin );
        Test.stopTest();
    }

    @isTest
    static void searchDBForAssignmentId() {

        WorkRequestSearchController.DataWrapper returnData;

        Test.startTest();
            // Make AR due to query limits in earlier test
            ServiceAppointment sa  = [ SELECT Id, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];
            makeAR( sa );

            String searchTerm = '123456';
            WorkOrderLineItem testWOLI = [ SELECT Id FROM WorkOrderLineItem LIMIT 1 ];
            testWOLI.External_Assignment_Id__c = searchTerm;
            update testWOLI;

            String rawJSON = WorkRequestSearchController.getData( searchTerm );
            returnData = (WorkRequestSearchController.DataWrapper) JSON.deserialize( rawJSON, WorkRequestSearchController.DataWrapper.class );
        Test.stopTest();

        System.assert( returnData != null, 'There was no proper return given' );
        System.assert( !returnData.allRows.isEmpty(), 'The return provided zero search results' );
        System.assertEquals( searchTerm, returnData.allRows[0].assignmentId, 'The returned value had an unexpected output of ' + returnData.allRows[0].assignmentId );
    }
}