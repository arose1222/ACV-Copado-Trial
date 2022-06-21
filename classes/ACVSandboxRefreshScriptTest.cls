/**
 * This class holds the test methods for the Apex Refresh Class
 * @author James Andre LaCour
 */
@isTest
public class ACVSandboxRefreshScriptTest {
    /**
     * creates test data for test methods
     * @return void
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Environment_Information__c ei = Environment_Information__c.getOrgDefaults();
        ei.Sandbox_Name__c = 'TestCode';
        ei.Organization_Id__c = 'testOrgId';
        ei.Sandbox_Id__c = 'testSandboxId';
        insert ei;
    }
    /**
     * Expects the creation of the 4 Work Types indicated in
     * ACVSandboxRefreshSCriptQueueable.createFSLRequiredData
     * @return void
     */
    @isTest
    static void createFSLRequiredData(){
        ACVSandboxRefreshScript.refreshActions.add('Create FSL Required Data');
        Integer verifyWTCount = [ SELECT Count() FROM WorkType ];
        System.assertEquals( 0, verifyWTCount, 'There should be no Work Types in the system when the test begins' );
        Test.startTest();
            Test.testSandboxPostCopyScript(
                new ACVSandboxRefreshScript(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName()
            );
        Test.stopTest();
        verifyWTCount = [ SELECT Count() FROM WorkType ];
        System.assertEquals( 4, verifyWTCount, 'There should be 4 Work Types in the system after the test runs' );
    }
    /**
     * Expects the updating of the Custom Setting that holds the current Environments Info
     * ACVSandboxRefreshSCriptQueueable.updateEnvironmentInformation
     * @return void
     */
    @isTest
    static void updateEnvironmentInformation(){
        ACVSandboxRefreshScript.refreshActions.add('Update Environment Information');
        Test.startTest();
            Test.testSandboxPostCopyScript(new ACVSandboxRefreshScript(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
        Environment_Information__c ei = Environment_Information__c.getOrgDefaults();
        System.assertEquals(UserInfo.getOrganizationName(), ei.Sandbox_Name__c,'Sandbox name was not correctly updated');
        System.assertEquals(UserInfo.getOrganizationId(), ei.Sandbox_Id__c, 'Organization Id was not correctly updated');
        System.assertEquals(UserInfo.getOrganizationId(), ei.Organization_Id__c, 'Organization Id was not correctly updated');
    }
    /**
     * Expects the testUser has the .invalid and profile updated
     * ACVSandboxRefreshSCriptQueueable.updateAllFlaggedUsers
     * @return void
     */
    @isTest
    static void updateAllFlaggedUsers(){
        TestUtility.insertValidationBypass();
        ACVSandboxRefreshScript.refreshActions.add('Update All Flagged Users');
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'testLast',
            Email = 'testuser@testacv.com' + ACVSandboxRefreshScriptQueueable.EMAIL_SUFFIX_REMOVAL,
            Username = 'testuser@testacv.com',
            CompanyName = 'ACVTest',
            Title = 'Test User',
            Alias = 'testAli',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;
        ACVSandboxRefreshScriptQueueable.testUser = testUser;
        Test.startTest();
            Test.testSandboxPostCopyScript(new ACVSandboxRefreshScript(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
        User userToCheck = [ SELECT Id, Email, Profile.Name FROM User WHERE Id = :testUser.Id LIMIT 1 ];
        System.assertEquals('testuser@testacv.com', userToCheck.Email,'Email did not get the ' + ACVSandboxRefreshScriptQueueable.EMAIL_SUFFIX_REMOVAL + ' removed');
        System.assertEquals('System Administrator', userToCheck.Profile.Name, 'The Users profile was not updated to System Administrator');
    }
    /**
     * Expects if a user has the API Only User Permission set, removes it from that user.
     * @return void
     */
    @isTest
    static void removeApiOnlyFromAllUsers(){
        ACVSandboxRefreshScript.refreshActions.add('Remove API Only User From All Users');
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            LastName = 'testLast',
            Email = 'testuser@testacv.com' + ACVSandboxRefreshScriptQueueable.EMAIL_SUFFIX_REMOVAL,
            Username = 'testuser@testacv.com',
            CompanyName = 'ACVTest',
            Title = 'Test User',
            Alias = 'testAli',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;
        List<PermissionSet> psList = [ SELECT Id FROM PermissionSet WHERE Name = :ACVSandboxRefreshScriptQueueable.API_ONLY_PERMISSION_SET_NAME LIMIT 1 ];
        System.assertEquals(1, psList.size(), 'API Only User Permission Set not found');
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = testUser.Id;
        psa.PermissionSetId = psList[0].Id;
        insert psa;
        Test.startTest();
            Test.testSandboxPostCopyScript(new ACVSandboxRefreshScript(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
        List<PermissionSetAssignment> psaCheck = [ SELECT Id FROM PermissionSetAssignment WHERE Id = :psa.Id LIMIT 1 ];
        System.assertEquals(0, psaCheck.size(),'The test user did not have the Permission Set Assignment deleted');
    }
    /**
     * Expects the successful post of a Slack Message
     * ACVSandboxRefreshSCriptQueueable.createFSLRequiredData
     * @return void
     */
    @isTest
    static void start(){
        ACVSandboxRefreshScript.refreshActions.add('start');
        Test.setMock( HttpCalloutMock.class, new SlackPostSuccessMockResponse() );
        Test.startTest();
            Test.testSandboxPostCopyScript(new ACVSandboxRefreshScript(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
    }
    /**
     * Expects the successful post of a Slack Message
     * ACVSandboxRefreshSCriptQueueable.createFSLRequiredData
     * @return void
     */
    @isTest
    static void finish(){
        ACVSandboxRefreshScript.refreshActions.add('finish');
        Test.setMock( HttpCalloutMock.class, new SlackPostSuccessMockResponse() );
        Test.startTest();
            Test.testSandboxPostCopyScript(new ACVSandboxRefreshScript(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
    }
}