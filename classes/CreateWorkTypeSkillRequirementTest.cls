@isTest
public class CreateWorkTypeSkillRequirementTest {
    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;
    }   

    @IsTest
    static void createFBIPromoWork(){
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        Skill testSkill = [ SELECT Id, DeveloperName FROM Skill LIMIT 1 ]; // Skills cannot be created in test code
        WorkType fbiWT = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_Id__c = 'fbi' LIMIT 1 ];
		WorkType promoWT = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_Id__c = 'promo work' LIMIT 1 ];

        insert new SkillRequirement( RelatedRecordId = fbiWT.Id, SkillId = testSkill.Id ); // Make Skill Requirement to link WT to skill
        
        WorkOrder fbiWork;
        Test.startTest();
        	fbiWork = FSLTestUtility.createWorkOrder( promoWT, acct, '14209', st, null );
        	fbiWork.Promotional_Work_Type__c = fbiWT.Id;

        	insert fbiWork;
		Test.stopTest();
        
        List<SkillRequirement> skillReqLst = [ SELECT Id, SkillId FROM SkillRequirement WHERE RelatedRecordId = :fbiWork.Id ];
        system.assertEquals( TRUE, skillReqLst != null, 'There was a lack of Skill Requirements Found' );
        system.assertEquals( TRUE, !skillReqLst.isEmpty(), 'There was a lack of Skill Requirements Found' );
        system.assertEquals( 1, skillReqLst.size(), 'There was an unexpected number of Skill Requirements Found: ' + skillReqLst.size() );
        system.assertEquals( testSkill.Id, skillReqLst[0].SkillId, 'The wrong skill was found as a Skill Requirement' );
    }
}