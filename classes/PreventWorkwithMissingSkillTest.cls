@isTest
public class PreventWorkwithMissingSkillTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );

        Account acct = TestUtility.createAccount();
        insert acct;
        FSLTestUtility.createData( acct, 1 );
        FSLTestUtility.makeResourceData();
        
        ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource
        ServiceAppointment sa = [ SELECT Id, ServiceTerritoryId, ServiceTerritory.OperatingHoursId FROM ServiceAppointment LIMIT 1 ];
        Skill testSkill = [ SELECT Id, DeveloperName FROM Skill LIMIT 1 ]; // Skills cannot be created in test code
        WorkType inspectionWT = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_Id__c = 'inspection' LIMIT 1 ]; // Get a test-created WorkType

        insert FSLTestUtility.makePrimarySTM( userResource.Id, sa.ServiceTerritoryId, sa.ServiceTerritory.OperatingHoursId );
        insert new SkillRequirement( RelatedRecordId = inspectionWT.Id, SkillId = testSkill.Id ); // Make Skill Requirement to link WT to skill
    }

    @IsTest
    static void resourceWithSkill(){
        Test.startTest();
            ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource
            Skill testSkill = [ SELECT Id, DeveloperName FROM Skill LIMIT 1 ]; // Skills cannot be created in test code
    
            DateTime currentTime = DateTime.now();
            insert new ServiceResourceSkill(
                EffectiveStartDate = currentTime.addMinutes(-5),
                ServiceResourceId = userResource.Id,
                SkillId = testSkill.Id
            );
    
            Boolean errorThrown = FALSE;
            String errorMsg;
        
            ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
            sa.SchedStartTime = currentTime.addMinutes(30);
            sa.SchedEndTime = currentTime.addMinutes(60);
            update sa;

            // If no error, test ran as properly
            insert new AssignedResource(
                ServiceAppointmentId = sa.Id,
                ServiceResourceId = userResource.Id
            );
        Test.stopTest();
    }

    @IsTest
    static void assignResourceWithoutSkill(){
        ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource

        DateTime currentTime = DateTime.now();
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
            sa.SchedStartTime = currentTime.addMinutes(30);
            sa.SchedEndTime = currentTime.addMinutes(60);
            update sa;

            try {
                insert new AssignedResource(
                    ServiceAppointmentId = sa.Id,
                    ServiceResourceId = userResource.Id
                );
            } catch ( exception e ) {
                errorMsg = e.getMessage();
                if ( e.getMessage().contains( PreventWorkwithMissingSkill.INVALID_RESOURCE_CONFIG_ERROR ) ) {
                    errorThrown = TRUE;
                }
            }
        Test.stopTest();
        
        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );  
    }

    @IsTest
    static void resourceWithWrongSkill(){
        Test.startTest();
            ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource
            List<Skill> testSkillLst = [ SELECT Id, DeveloperName FROM Skill LIMIT 2 ]; // Skills cannot be created in test code
    
            DateTime currentTime = DateTime.now();
            insert new ServiceResourceSkill(
                EffectiveStartDate = currentTime.addMinutes(-5),
                ServiceResourceId = userResource.Id,
                SkillId = testSkillLst[1].Id
            );
    
            Boolean errorThrown = FALSE;
            String errorMsg;
        
            ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
            sa.SchedStartTime = currentTime.addMinutes(30);
            sa.SchedEndTime = currentTime.addMinutes(60);
            update sa;

            try {
                insert new AssignedResource(
                    ServiceAppointmentId = sa.Id,
                    ServiceResourceId = userResource.Id
                );
            } catch ( exception e ) {
                errorMsg = e.getMessage();
                if ( e.getMessage().contains( PreventWorkwithMissingSkill.INVALID_RESOURCE_CONFIG_ERROR ) ) {
                    errorThrown = TRUE;
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );  
    }
}