@isTest
public class SAReassignClassicWorkDateBatchTest {
    
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
        FSLTestUtility.createData( a, 1 );

        List<ServiceAppointment> saLst = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment ];
        for ( ServiceAppointment saRec : saLst ) {
            saRec.EarliestStartTime = Date.today().addDays(-1);
            saRec.dueDate = Date.today();
        }
        update saLst;
    }

    @isTest
    static void runBatch() {

        List<ServiceAppointment> saLst = [ SELECT Id, DueDate FROM ServiceAppointment ];
        for ( ServiceAppointment saRec : saLst ) {     
            System.assertEquals( Date.today(), saRec.DueDate, 'The Due Date was an unexpected Date of ' + saRec.DueDate );
        }

        Test.startTest();
            SAReassignClassicWorkDateBatch batch = new SAReassignClassicWorkDateBatch();
            batch.executeScheduledLogic();
        Test.stopTest();     

        saLst = [ SELECT Id, DueDate FROM ServiceAppointment ];
        for ( ServiceAppointment saRec : saLst ) {
            System.assertEquals( DateTime.newInstance( Date.today().addDays( SAReassignClassicWorkDateBatch.DEFAULT_DAY_RANGE ), Time.newInstance( 21, 0, 0, 0 ) ), saRec.DueDate, 'The Due Date was an unexpected Date of ' + saRec.DueDate );
        }
    }

    @isTest
    static void runBatchWithRevolvingAppointment() {
        Test.startTest();
            Timeline__c timeRec = new Timeline__c(
                Account__c = [ SELECT Id FROM Account LIMIT 1 ].Id,
                Is_Active__c = TRUE,
                Start_Date__c = Date.today().addDays(-7),
                Average_Number_Cars__c = 1,
                Work_Type__c = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ].Id
            );
            insert timeRec;
    
            Occurrence__c occRec = RevolvingTest.generateTestOcc( timeRec, 'TestName', 'Daily', 1, tracDateUtils.DAY, null );
            insert occRec;
    
            List<WorkOrder> woLst = [ SELECT Id FROM WorkOrder ];
            for ( WorkOrder woRec : woLst ) {
                woRec.Occurrence__c = occRec.Id;
            }
    
            for ( ServiceAppointment saRec : [ SELECT Id, DueDate FROM ServiceAppointment ] ) {     
                System.assertEquals( Date.today(), saRec.DueDate, 'The Due Date was an unexpected Date of ' + saRec.DueDate );
            }

        
            SAReassignClassicWorkDateBatch batch = new SAReassignClassicWorkDateBatch();
            batch.executeScheduledLogic();
        Test.stopTest();     

        List<ServiceAppointment> saLst = [ SELECT Id, DueDate, Work_Order__c, Work_Order__r.Occurrence__c FROM ServiceAppointment ];
        for ( ServiceAppointment saRec : saLst ) {
            if ( saRec.Work_Order__r.Occurrence__c == null ) {
                System.assertEquals( DateTime.newInstance( Date.today().addDays( SAReassignClassicWorkDateBatch.DEFAULT_DAY_RANGE ), Time.newInstance( 21, 0, 0, 0 ) ), saRec.DueDate, 'The Due Date was an unexpected Date of ' + saRec.DueDate );
            } else {
                System.assertNotEquals( DateTime.newInstance( Date.today().addDays( SAReassignClassicWorkDateBatch.DEFAULT_DAY_RANGE ), Time.newInstance( 21, 0, 0, 0 ) ), saRec.DueDate, 'The Due Date was an unexpected Date of ' + saRec.DueDate );
            }
        }
    }
}