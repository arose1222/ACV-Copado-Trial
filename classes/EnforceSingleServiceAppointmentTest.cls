@isTest
public class EnforceSingleServiceAppointmentTest {
    @TestSetup
    static void createTerritory() {
        Account a = TestUtility.createAccount();
        a.Dealership_Id__c = '1';
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = new Affiliation__c(
            Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true, 
            Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
            type__c='rep'
        );
        insert aff;

        FSLTestUtility.createData( a, 1 );
    }

    @IsTest
    static void makeServiceAppointment(){

        WorkOrder woRec = [ SELECT Id, ServiceTerritoryId, AccountId, Duration, DurationType, WorkTypeId, Inspection_Number_of_Vehicles__c, Account.Name, OwnerId, Subject, 
                                Description, Street, City, PostalCode, State, Country FROM WorkOrder LIMIT 1 ];
        
        System.assertEquals( 1, [ SELECT Count() FROM ServiceAppointment ], 'There was an unexpected amount of Service Appointments in the system' );

        Test.startTest();
            insert ServiceAppointmentUtility.createAppointmentFromWorkOrder( woRec, 'New', DateTime.now(), DateTime.now().addDays( 7 ) );
        Test.stopTest();

        System.assertEquals( 1, [ SELECT Count() FROM ServiceAppointment ], 'There was an unexpected amount of Service Appointments in the system' );
    }
}