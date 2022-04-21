@isTest
public class IdentifyGoodAddressServiceApptBatchTest {

    @TestSetup
    static void createData() {
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
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
    }

    @isTest
    static void createValidAppt() {
        ServiceTerritory st1 = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        WorkType wtRec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];
        FSLTestUtility.generateWork( wtRec, wtRec, acct, '14209', st1, 1 );

        System.assertEquals( 0, [ SELECT Count() FROM ServiceAppointment WHERE Exclude_From_Optimization__c = TRUE ], 'There were an unexpected amount of Service Appointments Excluded from Optimization' );

        ServiceAppointment saRec = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
        saRec.Exclude_From_Optimization__c = TRUE;
        saRec.Longitude = 1.0;
        saRec.Latitude = 1.0;
        update saRec;

        Test.startTest();
            SchedulableContext sc = null;
            IdentifyGoodAddressServiceApptBatch batch = new IdentifyGoodAddressServiceApptBatch();
            batch.execute( sc );
        Test.stopTest();

        System.assertEquals( 0, [ SELECT Count() FROM ServiceAppointment WHERE Exclude_From_Optimization__c = TRUE ], 'There were an unexpected amount of Service Appointments Excluded from Optimization' ); // There should be no appointments marked at this point
    }
}