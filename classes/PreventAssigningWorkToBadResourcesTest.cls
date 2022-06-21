@isTest
public class PreventAssigningWorkToBadResourcesTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '1';
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        FSLTestUtility.createData( a, 1 );

        ServiceResource testSR = FSLTestUtility.makeResourceData(c);

        ServiceTerritory st = [ SELECT Id, OperatingHoursId FROM ServiceTerritory LIMIT 1 ];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            OperatingHoursId = st.OperatingHoursId, 
            ServiceTerritoryId = st.Id, 
            ServiceResourceId = testSR.Id,
            EffectiveStartDate = Date.today().addDays(-1), 
            TerritoryType = 'P'
        );
        insert stm;
    } 

    @IsTest
    static void assignSAToBadResource(){
        ServiceResource srTest = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        ServiceAppointment saTest = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];

        DateTime now = DateTime.now().addMinutes(5);
        saTest.SchedStartTime = now;
        saTest.SchedEndTime = now.addMinutes(30);
        update saTest;

        Boolean checkError = FALSE;
        Test.startTest();
            Contact c = [ SELECT Id, Email FROM Contact LIMIT 1 ];
            c.ACV_User__c = null;
            update c;

            try {
                insert new AssignedResource(
                    ServiceResourceId = srTest.Id,
                    ServiceAppointmentId = saTest.Id
                );
            } catch ( exception e ) {        
                if ( e.getMessage().contains( PreventAssigningWorkToBadResources.INVALID_RESOURCE_CONFIG_ERROR ) ) {
                    checkError = TRUE;
                }
            }
        Test.stopTest();
        
        System.assertEquals( TRUE, checkError );
    }
}