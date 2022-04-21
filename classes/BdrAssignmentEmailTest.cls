/**
 * Test Class for BdrAssignmentEmailTest
 * @author James Andre LaCour
 */
@isTest
public class BdrAssignmentEmailTest {
    public static final Group defaultLeadQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'BDR_Organization_Lead_Queue'];
    /**
     * Test Setup method for the test methods
     * 
     */
    @TestSetup
    public static void makeData(){
        //TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>();
        Lead l = TestUtility.createLead();
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        l.Email = 'test123321@bdrTest.test';
        l.State = 'Ak';
        l.Referral_Code__c='BDR';
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        l.setOptions(dmo); 
        Lead l1 = TestUtility.createLead();
        l1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        l1.Email = 'testjp@bdrTest.test';
        l1.State = 'Ak';
        l1.Referral_Code__c='blitzteam';
        l1.setOptions(dmo);
        insert new List<Lead>{l,l1};
        User u = TestUtility.createUser();
        u.Username = 'test123UserTest@userTest.comTest';
        u.Calendly_Link__c = 'Test Calendy Link';
        User u2 = TestUtility.createUser();
        u2.Username = 'blankCalendlyLink@userTest.comTest';
        insert new List<User>{u,u2};
    }
    /**
     * Test that the assignment of a BDR to a User with a Calendly link works
     */
    @IsTest
    public static void assignedToBlitzTestWithDontSendEmail(){
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;

        Test.startTest();
            Lead l1 = TestUtility.createLead();
            l1.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
            l1.Email = 'hereTest@testhere.com';
            l1.State = 'Ak';
            l1.Referral_Code__c='blitzteam';
            l1.Dont_Send_BDR_Email__c = true;
            l1.setOptions(dmo);
            insert l1;
        Test.stopTest();
        Lead updatedLead = [ SELECT Id, BDR_Email_Sent__c, OwnerId, IST_Account_Owner__c FROM Lead WHERE Id = :l1.Id ];
        System.assertEquals( false, updatedLead.BDR_Email_Sent__c );
        System.assertEquals( updatedLead.OwnerId, updatedLead.IST_Account_Owner__c );
        
    }

    /**
     * Test that the assignment of a BDR to a User with a Calendly link works
     */
    @IsTest
    public static void assignedToBDRwithLinkTest(){
        User u = [ SELECT Id FROM User WHERE Username = 'test123UserTest@userTest.comTest' LIMIT 1 ];
        Lead l = [ SELECT Id FROM Lead WHERE Email = 'test123321@bdrTest.test' LIMIT 1 ];
        Test.startTest();
            l.OwnerId = u.Id;
            update l;
        Test.stopTest();
        Lead updatedLead = [ SELECT Id, BDR_Email_Sent__c, OwnerId, IST_Account_Owner__c FROM Lead WHERE Id = :l.Id ];
        System.assertEquals( true, updatedLead.BDR_Email_Sent__c );
        System.assertEquals( u.Id, updatedLead.IST_Account_Owner__c );
    } 

    /**
     * Test that the assignment of a BDR to a User without a Calendly link does not work
     */
    @IsTest
    public static void assignedToBDRwithoutLinkTest(){
        User u = [ SELECT Id, Calendly_Link__c FROM User WHERE Username = 'blankCalendlyLink@userTest.comTest' LIMIT 1 ];
        Lead l = [ SELECT Id, OwnerId, Owner.Name FROM Lead WHERE Email = 'test123321@bdrTest.test' LIMIT 1 ];
        Test.startTest();
            l.OwnerId = defaultLeadQueue.Id; //need to set to the queue first
            update l;
            
            l.OwnerId = u.Id;
            l.BDR_Email_Sent__c = false;
            try{
                update l;
                System.assert(false, 'Expecting a failure since there is no Calendly Link for this user');
            }catch(Exception ex){
                
            }
        Test.stopTest();
    } 
    
}