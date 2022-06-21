@isTest
public class DueDateAdjustmentEngineTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
    }

    @isTest
    static void createDealershipIdServiceAppointment() {
        System.assert( !( DueDateAdjustmentEngine.dueDateConfigMap.isEmpty() || DueDateAdjustmentEngine.dueDateConfigMap?.get( DueDateAdjustmentEngine.DueDateEngineConfig.DEALER_ID ) == null ), 'There is no metadata records for Dealership Id Metadata - Testing cannot happen' );

        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = new List<String>( DueDateAdjustmentEngine.dueDateConfigMap.get( DueDateAdjustmentEngine.DueDateEngineConfig.DEALER_ID ).keySet() )[0];
        insert a;

        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        Test.startTest();
            WorkOrder woRec = new WorkOrder(
                AccountId = a.Id,
                WorkTypeId = standardWorkType.Id,
                Subject = standardWorkType.Name + ' ' + a.Name,
                Duration = standardWorkType.EstimatedDuration,
                DurationType = standardWorkType.DurationType,
                Origin__c = 'Apex Test Code',
                Status = 'New'
            );

            insert woRec;
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment LIMIT 1 ];
        Salesforce_Setting__mdt defaultDayRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Service_Appointment_Range' LIMIT 1 ];
        
        System.assertNotEquals( saRec.EarliestStartTime.addDays( Integer.valueOf( defaultDayRange.Value__c ) ), saRec.DueDate, 'The due date was not properly adjusted for this use case' );
    }

    @isTest
    static void createDealershipTypeServiceAppointment() {
        System.assert( !( DueDateAdjustmentEngine.dueDateConfigMap.isEmpty() || DueDateAdjustmentEngine.dueDateConfigMap?.get( DueDateAdjustmentEngine.DueDateEngineConfig.DEALER_TYPE ) == null ), 'There is no metadata records for Dealership Id Metadata - Testing cannot happen' );

        Account a = TestUtility.createAccount();
        a.Dealer_Type__c = new List<String>( DueDateAdjustmentEngine.dueDateConfigMap?.get( DueDateAdjustmentEngine.DueDateEngineConfig.DEALER_TYPE ).keySet() )[0];
        insert a;

        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        Test.startTest();
            WorkOrder woRec = new WorkOrder(
                AccountId = a.Id,
                WorkTypeId = standardWorkType.Id,
                Subject = standardWorkType.Name + ' ' + a.Name,
                Duration = standardWorkType.EstimatedDuration,
                DurationType = standardWorkType.DurationType,
                Origin__c = 'Apex Test Code',
                Status = 'New'
            );

            insert woRec;
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment LIMIT 1 ];
        Salesforce_Setting__mdt defaultDayRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Service_Appointment_Range' LIMIT 1 ];
        
        System.assertNotEquals( saRec.EarliestStartTime.addDays( Integer.valueOf( defaultDayRange.Value__c ) ), saRec.DueDate, 'The due date was not properly adjusted for this use case' );
    }

    @isTest
    static void createUserIdServiceAppointment() {
        System.assert( !( DueDateAdjustmentEngine.dueDateConfigMap.isEmpty() || DueDateAdjustmentEngine.dueDateConfigMap?.get( DueDateAdjustmentEngine.DueDateEngineConfig.USER_ID ) == null ), 'There is no metadata records for Dealership Id Metadata - Testing cannot happen' );

        Id userId = new List<String>( DueDateAdjustmentEngine.dueDateConfigMap?.get( DueDateAdjustmentEngine.DueDateEngineConfig.USER_ID ).keySet() )[0];
        User testUser = [ SELECT Id FROM User WHERE Id = :userId AND IsActive = TRUE LIMIT 1 ];

        Account a = TestUtility.createAccount();
        insert a;

        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        Test.startTest();
            System.runAs( testUser ) {
                WorkOrder woRec = new WorkOrder(
                    AccountId = a.Id,
                    WorkTypeId = standardWorkType.Id,
                    Subject = standardWorkType.Name + ' ' + a.Name,
                    Duration = standardWorkType.EstimatedDuration,
                    DurationType = standardWorkType.DurationType,
                    Origin__c = 'Apex Test Code',
                    Status = 'New'
                );

                insert woRec;
            }
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment LIMIT 1 ];
        Salesforce_Setting__mdt defaultDayRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Service_Appointment_Range' LIMIT 1 ];
        
        System.assertNotEquals( saRec.EarliestStartTime.addDays( Integer.valueOf( defaultDayRange.Value__c ) ), saRec.DueDate, 'The due date was not properly adjusted for this use case' );
    }

    @isTest
    static void createNormalServiceAppointment() {
        Account a = TestUtility.createAccount();
        insert a;

        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        Test.startTest();
            WorkOrder woRec = new WorkOrder(
                AccountId = a.Id,
                WorkTypeId = standardWorkType.Id,
                Subject = standardWorkType.Name + ' ' + a.Name,
                Duration = standardWorkType.EstimatedDuration,
                DurationType = standardWorkType.DurationType,
                Origin__c = 'Apex Test Code',
                Status = 'New'
            );

            insert woRec;
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, EarliestStartTime, DueDate FROM ServiceAppointment LIMIT 1 ];
        Salesforce_Setting__mdt defaultDayRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Service_Appointment_Range' LIMIT 1 ];
        
        System.assertEquals( saRec.EarliestStartTime.addDays( Integer.valueOf( defaultDayRange.Value__c ) ), saRec.DueDate, 'The due date was not properly adjusted for this use case' );
    }
}