@isTest
public class CleanUpExcessRevApptResourcePrefTest {
    @TestSetup
    static void createData() {
        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createData( a, 1 );

        // Makes Service Resource, with all required data, and sets the ResourcePreference in the DB of said Resource
        ServiceResource vciServiceResource = FSLTestUtility.makePreferredResourceData( a );
    }

    @isTest
    static void runBatch() {
        Test.startTest();
	        Account a = [ SELECT Id FROM Account LIMIT 1 ];
        	ServiceResource vciSR = [ SELECT Id FROM ServiceResource LIMIT 1 ];
            Timeline__c timeRec = new Timeline__c(
                Account__c = a.Id,
                Is_Active__c = TRUE,
                Start_Date__c = Date.today().addDays(-7),
                Work_Type__c = FSLWorkProcessUtility.availableWTMap.get( 'inspection' ).Id,
                Average_Number_Cars__c = 1,
                Service_Resource__c = vciSR.Id
            );
            insert timeRec;
            
            Occurrence__c occRec = RevolvingTest.generateTestOcc( timeRec, 'TestName', 'Daily', 1, tracDateUtils.DAY, null );
            insert occRec;
        
            WorkOrder wo = [ SELECT Id FROM WorkOrder LIMIT 1 ];

            // Makes Service Resource, with all required data, and sets the ResourcePreference in the DB of said Resource
            ServiceResource vciServiceResource = FSLTestUtility.makePreferredResourceData( wo );

            Integer rpCount = [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :vciServiceResource.Id ];
            system.assertEquals( 1, rpCount, 'The Resource Preference should save without issue' );

            Occurrence__c getORec = [ SELECT Id FROM Occurrence__c LIMIT 1 ];

            List<WorkOrder> woLst = [ SELECT Id FROM WorkOrder ];
            for ( WorkOrder woRec : woLst ) {
                woRec.Occurrence__c = getORec.Id;
            }
            update woLst;
            woLst = [ SELECT Id, Status, StatusCategory, Occurrence__c FROM WorkOrder ];

            CleanUpExcessRevApptResourcePrefBatch batchRec = new CleanUpExcessRevApptResourcePrefBatch();
            Database.executeBatch(batchRec, 200);
        Test.stopTest();

        rpCount = [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :vciServiceResource.Id ];
        system.assertEquals( 0, rpCount, 'The Resource Preference had an issue with removal' );

        rpCount = [ SELECT Count() FROM ResourcePreference ];
        system.assertEquals( 2, rpCount, 'The Resource Preference count has an issue' );
    }
}