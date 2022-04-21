@IsTest
public class workOrderIngestPermissionsTest {
    
    @TestSetup
    static void createTerritory() {

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Dispatched' );

        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = new Affiliation__c(
            Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true,
            Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
            type__c='rep'
        );
        insert aff;
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );

        ServiceResource sr = FSLTestUtility.makeResourceData();

        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.id, ServiceTerritoryId = st.id, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P',
            OperatingHoursId = optHour.Id
        );
        insert stm;
    }

    @isTest
    static void checkNegativeProfile(){
        Profile p = [ SELECT Id FROM Profile WHERE Name = 'Vehicle Condition Inspector' ];
        User u = TestUtility.createUser( p.Id );
        insert u;

        Boolean isAllowedToDisplayRevolving = TRUE;
        Test.startTest();
            System.runAs( u ) {
                isAllowedToDisplayRevolving = workOrderIngestPermissions.checkToDisplayRevolving();
            }
        Test.stopTest();

        System.assertEquals( FALSE, isAllowedToDisplayRevolving, 'There was an unexpected permission given to see Revolving Appointment Functionality' );
    }

    @isTest
    static void checkPositiveProfile(){
        User u = TestUtility.createUser();
        insert u;

        Boolean isAllowedToDisplayRevolving = FALSE;
        Test.startTest();
            System.runAs( u ) {
                isAllowedToDisplayRevolving = workOrderIngestPermissions.checkToDisplayRevolving();
            }
        Test.stopTest();

        System.assertEquals( TRUE, isAllowedToDisplayRevolving, 'There was an unexpected permission given to see Revolving Appointment Functionality' );
    }

}