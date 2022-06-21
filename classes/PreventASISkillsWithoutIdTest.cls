@isTest
public class PreventASISkillsWithoutIdTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;

        FSLTestUtility.makePreferredResourceData( acct );
    }   

    @IsTest
    static void throwError(){
        ServiceResource userResource = [ SELECT Id FROM ServiceResource LIMIT 1 ]; // Get pre-generated Resource
        Skill testSkill = [ SELECT Id, DeveloperName FROM Skill LIMIT 1 ]; // Skills cannot be created in test code
        WorkType fbiWT = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_Id__c = 'fbi' LIMIT 1 ]; // Get a test-created ASI Skill

        insert new SkillRequirement( RelatedRecordId = fbiWT.Id, SkillId = testSkill.Id ); // Make Skill Requirement to link WT to skill
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            DateTime currentTime = DateTime.now();
            try {
                insert new ServiceResourceSkill(
                    EffectiveStartDate = currentTime.addMinutes(-5),
                    ServiceResourceId = userResource.Id,
                    SkillId = testSkill.Id
                );
            } catch ( exception e ) {
                if ( e.getMessage().contains( PreventASISkillsWithoutId.ASI_SKILL_WITHOUT_ID_ERROR ) ) {
                    errorThrown = TRUE;
                    errorMsg = e.getMessage();
                }
            }
        Test.stopTest();

        System.assert( errorThrown, 'The error was not properly thrown as expected, instead the following was thronw: ' + errorMsg );        
    }
}