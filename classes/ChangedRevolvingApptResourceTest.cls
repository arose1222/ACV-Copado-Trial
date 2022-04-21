@isTest
public class ChangedRevolvingApptResourceTest {
    // @TestSetup
    // static void makeData(){
    //     Account a = TestUtility.createAccount();
    //     insert a;

    //     Contact c = TestUtility.createContact( a );
    //     insert c;

    //     Affiliation__c aff = new Affiliation__c(
    //         Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true,
    //         Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
    //         type__c='rep'
    //     );
    //     insert aff;
    //     FSLTestUtility.createData( a, 1 );

    //     ServiceResource vciServiceResource = FSLTestUtility.makePreferredResourceData( a );

    //     Timeline__c timeRec = new Timeline__c(
    //         Account__c = [ SELECT Id FROM Account LIMIT 1 ].Id,
    //         Is_Active__c = TRUE,
    //         Start_Date__c = Date.today().addDays(-7),
    //         Average_Number_Cars__c = 1,
    //         Work_Type__c = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ].Id,
    //         Service_Resource__c = vciServiceResource.Id
    //     );
    //     insert timeRec;

    //     Occurrence__c occRec = RevolvingTest.generateTestOcc( timeRec, 'TestName', 'Daily', 1, tracDateUtils.DAY, null );
    //     insert occRec;
    // }

    // @isTest
    // static void updateAppointmentResource() {
    //     Account a = [ SELECT Id FROM Account LIMIT 1 ];
    //     ServiceResource newVciServiceResource = FSLTestUtility.makePreferredResourceData( a );

    //     Timeline__c revolvApptRec = [ SELECT Id FROM Timeline__c LIMIT 1 ];

    //     System.assertEquals( 0, [ SELECT Count() FROM Occurrence__c WHERE Cleanup_Marker__c = TRUE ] );

    //     Test.startTest();
    //         revolvApptRec.Service_Resource__c = newVciServiceResource.Id;
    //         update revolvApptRec;
    //     Test.stopTest();

    //     System.assertEquals( 1, [ SELECT Count() FROM Occurrence__c WHERE Cleanup_Marker__c = TRUE ] );
    // }
}