@isTest
public class UpdateApptDateRangeAPITest {
    @TestSetup
    static void createData() {
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '1';
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = new Affiliation__c(
            Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true, 
            Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
            type__c='rep'
        );
        insert aff;

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Offer Attempted' );
        FSLTestUtility.createData( a, 1 );
    }

    @IsTest
    static void callAPI(){
        RestResponse res = new RestResponse();
        RestContext.response = res;

        ServiceAppointment saRec = [ SELECT Id, EarliestStartTime, DueDate, ParentRecordId FROM ServiceAppointment LIMIT 1 ];
        WorkOrderLineItem woliRec = [ SELECT Id, External_Record_Guid__c FROM WorkOrderLineItem WHERE WorkOrderId = :saRec.ParentRecordId LIMIT 1 ];
        
        Test.startTest();
            UpdateApptDateRangeAPI.RequestedApptRange dataRec = new UpdateApptDateRangeAPI.RequestedApptRange();
            dataRec.uuid = woliRec.External_Record_Guid__c;
            dataRec.startTime = saRec.EarliestStartTime.addDays(7);
            dataRec.endTime = saRec.DueDate.addDays(7);

            UpdateApptDateRangeAPI.saveOffer( dataRec );
        Test.stopTest();

        system.assert( res.responseBody.toString().contains( '200' ), 'The response did not return with a success call as expected' );
    }
}