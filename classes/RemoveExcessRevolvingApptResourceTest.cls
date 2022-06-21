@isTest
public class RemoveExcessRevolvingApptResourceTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createData( a, 1 );

        // Create Service Resource (needed for Service Territory Member):
        ServiceResource vciServiceResource = FSLTestUtility.makePreferredResourceData( a );
    }

    @isTest
    static void makeResourceWithoutRevolvingAppt() {
        Test.startTest();
        ServiceResource vciServiceResource = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        	Timeline__c timeRec = new Timeline__c(
                Account__c = [ SELECT Id FROM Account LIMIT 1 ].Id,
                Is_Active__c = TRUE,
                Start_Date__c = Date.today().addDays(-7),
                Average_Number_Cars__c = 1,
                Work_Type__c = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ].Id,
                Service_Resource__c = vciServiceResource.Id
            );
            insert timeRec;
    
            Occurrence__c occRec = RevolvingTest.generateTestOcc( timeRec, 'TestName', 'Daily', 1, tracDateUtils.DAY, null );
            insert occRec;
        
            ServiceResource vciServiceResource2 = FSLTestUtility.makePreferredResourceData( [ SELECT Id FROM WorkOrder LIMIT 1 ] );
        Test.stopTest();

        Integer rpCount = [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :vciServiceResource2.Id ];
        system.assertEquals( 1, rpCount, 'The Resource Preference should save without issue' );
    }

    @isTest
    static void makeRevolvingAppt() {
        Test.startTest();
        ServiceResource vciServiceResource = [ SELECT Id FROM ServiceResource LIMIT 1 ];
        	Timeline__c timeRec = new Timeline__c(
                Account__c = [ SELECT Id FROM Account LIMIT 1 ].Id,
                Is_Active__c = TRUE,
                Start_Date__c = Date.today().addDays(-7),
                Average_Number_Cars__c = 1,
                Work_Type__c = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ].Id,
                Service_Resource__c = vciServiceResource.Id
            );
            insert timeRec;
    
            Occurrence__c occRec = RevolvingTest.generateTestOcc( timeRec, 'TestName', 'Daily', 1, tracDateUtils.DAY, null );
            insert occRec;

            List<WorkOrder> woLst = [ SELECT Id FROM WorkOrder ];
            for ( WorkOrder woRec : woLst ) {
                woRec.Occurrence__c = occRec.Id;
            }
            update woLst;
        
            ServiceResource vciServiceResource2 = FSLTestUtility.makePreferredResourceData( [ SELECT Id FROM WorkOrder LIMIT 1 ] );

            Integer rpCount = [ SELECT Count() FROM ResourcePreference WHERE ServiceResourceId = :vciServiceResource2.Id ];
            system.assertEquals( 0, rpCount, 'The Resource Preference shouldn\'t save without issue' );
        Test.stopTest();
    }
}