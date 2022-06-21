/**
* This Test class is for Round Robin assignment of BDRs to "Organization Leads"
* @author Bhavana Majety
*/

@isTest
public class LeadOwnerAssignmentBDRTest {
    public static Id orgLeadId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
    public static Group defaultLeadQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'BDR_Organization_Lead_Queue'];

	 /**
     * Test Setup method for the test methods
     * 
     */
    @TestSetup
    public static void makeData() {
        DateTime todayTime = System.now();
        DateTime yesterday = System.now().addDays(-1);
        DateTime beforeYesterday = System.now().addDays(-2);
        List<Lead_Assignment_Tracking__c> latList = new List<Lead_Assignment_Tracking__c>();
        Integer counter = 0;
        Map<Id,User> ineligibleUsers = new Map<Id,User>([SELECT Id FROM User WHERE (Calendly_Link__c = null OR IsActive = false)]);
        for (GroupMember gm : [SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE Group.DeveloperName = 'BDR_Rebuild_AM_team_English']) {
            if (!ineligibleUsers.containsKey(gm.UserOrGroupId)) {
                if (counter == 0) {
                    Lead_Assignment_Tracking__c lat = new Lead_Assignment_Tracking__c(Name = gm.UserOrGroupID, User_Id__c = gm.UserOrGroupID, Most_Recent_Assignment__c = beforeYesterday);
                    latList.add(lat);
                    counter ++;
                }
                else if (counter == 1) {
                    Lead_Assignment_Tracking__c lat = new Lead_Assignment_Tracking__c(Name = gm.UserOrGroupID, User_Id__c = gm.UserOrGroupID, Most_Recent_Assignment__c = yesterday);
                    latList.add(lat);
                    counter ++;
                }
                else {
                    Lead_Assignment_Tracking__c lat = new Lead_Assignment_Tracking__c(Name = gm.UserOrGroupID, User_Id__c = gm.UserOrGroupID, Most_Recent_Assignment__c = todayTime);
                    latList.add(lat);
                    counter ++;
                }
            }
        }
        insert latList;

        Id spanishTeamId = [SELECT Id FROM Group WHERE DeveloperName = 'BDR_Rebuild_AM_team_Spanish'].Id;
        User spanishUser = TestUtility.createUser();
        spanishUser.Calendly_Link__c = '1234';
        insert spanishUser;
        
        User adminUser = [SELECT Id FROM User WHERE profile.name = 'System Administrator' AND Id != :UserInfo.getUserId() AND isActive = true LIMIT 1];
        System.runAs(adminUser){
            GroupMember gm = new GroupMember(UserOrGroupId = spanishUser.Id, GroupId = spanishTeamId);
            insert gm;
        }
    }

    //test basic function of English leads
    @isTest
    public static void testInsertEnglishPrefLead() {
        //create and insert one lead with english language preference
        Test.startTest();
            Lead newLead = TestUtility.createLead();
            newLead.RecordTypeId = orgLeadId;
            newLead.Language_Preference__c = 'English';
            newLead.State = 'Ak';
            insert newLead;
        Test.stopTest();
        //check that the lead is assigned to a user and not the queue
        Lead checkLead = [SELECT Id, OwnerId, CreatedDate FROM Lead];
        System.assertNotEquals(defaultLeadQueue.Id, checkLead.OwnerId);
    }

    //test basic function of Spanish leads
    @isTest
    public static void testInsertSpanishPrefLead() {
        //create and insert one lead with english language preference
        Test.startTest();
            Lead newLead = TestUtility.createLead();
            newLead.RecordTypeId = orgLeadId;
            newLead.Language_Preference__c = 'Spanish';
            newLead.State = 'Ak';
            insert newLead;
        Test.stopTest();
        //check that the lead is assigned to a user and not the queue
        Lead checkLead = [SELECT Id, OwnerId, CreatedDate FROM Lead];
        System.assertNotEquals(defaultLeadQueue.Id, checkLead.OwnerId);
    }

    //test basic function of skipping users who have ooo message
    @isTest
    public static void testSkippingUsersWithOOOMessage() {
        Integer counter = 0;
        Id oooUser;
        Id targetUser;
        List<Lead_Assignment_Tracking__c> lister = [Select Id, user_Id__c from lead_assignment_tracking__c];
        for (Lead_Assignment_Tracking__c lat : [SELECT Id, User_Id__c FROM Lead_Assignment_Tracking__c ORDER BY Most_Recent_Assignment__c ASC]) {
            if (counter == 0) {
                oooUser = lat.User_Id__c;
            }
            else if(counter == 1) {
                targetUser = lat.User_Id__c;
            }
            counter ++;
        }
        
        //if we modify a users ooo message in a test will it modify actual data -no
        Date todayDay = System.today();
        Date nextWeek = System.today().addDays(7);
        OutOfOffice ooo = new OutOfOffice(UserId = oooUser, Message = 'TEST', StartDate = todayDay, EndDate = nextWeek);
        upsert ooo;
        //create a lead
        //check that it is assigned to the targetUser
        Test.startTest();
            Lead newLead = TestUtility.createLead();
            newLead.RecordTypeId = orgLeadId;
            newLead.Language_Preference__c = 'English';
            newLead.State = 'Ak';
            insert newLead;
        Test.stopTest();
        //system.asserts
        Lead checkLead = [SELECT Id, OwnerId FROM Lead];
        System.assertEquals(targetUser, checkLead.OwnerId);
    }

    //test basic function of skipping users who have no calendly link
    @isTest
    public static void testSkippingUsersWithoutCalendlyLink() {
        Integer counter = 0;
        Id noCalLink;
        Id targetUser;
        for (Lead_Assignment_Tracking__c lat : [SELECT Id, User_Id__c FROM Lead_Assignment_Tracking__c ORDER BY Most_Recent_Assignment__c ASC LIMIT 2]) {
            if (counter == 0) {
                noCalLink = lat.User_Id__c;
                counter ++;
            }
            else {
                targetUser = lat.User_Id__c;
            }
        }
        
        //query for noCalLink user and set their Calendly_Link__c to null
        User noCalLinkUser = [SELECT Id, Calendly_Link__c FROM User WHERE Id = :noCalLink];
        noCalLinkUser.Calendly_Link__c = null;
        update noCalLinkUser;
        //create a lead
        //check that it is assigned to the targetUser
        Test.startTest();
            Lead newLead = TestUtility.createLead();
            newLead.RecordTypeId = orgLeadId;
            newLead.Language_Preference__c = 'English';
            newLead.State = 'Ak';
            insert newLead;
        Test.stopTest();

        //system.asserts
        Lead checkLead = [SELECT Id, OwnerId FROM Lead];
        System.assertEquals(targetUser, checkLead.OwnerId);
    }

    //test assignment to default queue if no BDR's available
    // @isTest
    // public static void testDefaultQueueAssignment() {
    //     Date todayDay = System.today();
    //     Date nextWeek = System.today().addDays(7);
    //     List<OutOfOffice> oooList = new List<OutOfOffice>();
    //     for (GroupMember gm : [SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE Group.DeveloperName = 'BDR_Rebuild_AM_team_Spanish']) {
    //         //set ooo message(s) for any users
    //         OutOfOffice ooo = new OutOfOffice(UserId = gm.UserOrGroupID, Message = 'TEST', StartDate = todayDay, EndDate = nextWeek);
    //         oooList.add(ooo);
    //     }
    //     upsert oooList;

    //     Test.startTest();
    //         Lead newLead = TestUtility.createLead();
    //         newLead.RecordTypeId = orgLeadId;
    //         newLead.Language_Preference__c = 'Spanish';
    //         insert newLead;
    //     Test.stopTest();

    //     Group defaultLeadQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'BDR_Organization_Lead_Queue'];
    //     Lead checkLead = [SELECT Id, OwnerId FROM Lead];
    //     System.assertEquals(defaultLeadQueue.Id, checkLead.OwnerId);
    // }

    //test bulk insert of leads (English) - more than 1, less than number of BDR's
    @isTest
    public static void testBulkInsertOfLeadsEnglish() {
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 3; i++) {
            Lead newLead = TestUtility.createLead();
            newLead.RecordTypeId = orgLeadId;
            newLead.Language_Preference__c = 'English';
            newLead.State = 'Ak';
            leadlist.add(newLead);
        }
        Test.startTest();
            insert leadlist;
        Test.stopTest();

        //test that each lead has been assigned to a different person
        List<Lead> checkLeadList = [SELECT Id, OwnerId FROM Lead];
        System.assertNotEquals(checkLeadList[1].OwnerId, checkLeadList[0].OwnerId); //1 vs 2
        System.assertNotEquals(checkLeadList[2].OwnerId, checkLeadList[0].OwnerId); //1 vs 3
        System.assertNotEquals(checkLeadList[2].OwnerId, checkLeadList[1].OwnerId); //2 vs 3
    }

    //testing inserting a variety of English and Spanish leads (more than 1 record for each language)
    /**
     * Test that the assignment of a BDR to a User with a Calendly link works
     */
    @IsTest
    public static void testBulkInsertOfLeadsBothLanguages(){ //testing inserting a variety of English and Spanish leads
        List<Lead> leadList = new List<Lead>();
        for(Integer i = 0; i < 4; i++) {
            Lead newLead = TestUtility.createLead();
            newLead.RecordTypeId = orgLeadId;
            newLead.Language_Preference__c = 'English';
            newLead.State = 'Ak';
            leadList.add(newLead);
        }
        
        for(Integer i = 0; i < 2; i++) {
            Lead newLead2 = TestUtility.createLead();
            newLead2.RecordTypeId = orgLeadId;
            newLead2.Language_Preference__c = 'Spanish';
            newLead2.State = 'Ak';
            leadList.add(newLead2);
        }

        Test.startTest();
            insert leadList;
        Test.stopTest();

        Set<Id> englishTeamMembers = new Set<Id>();
        Set<Id> spanishTeamMembers = new Set<Id>();
        for (GroupMember gm : [SELECT Id, UserOrGroupID, Group.DeveloperName FROM GroupMember WHERE Group.DeveloperName IN ('BDR_Rebuild_AM_team_Spanish', 'BDR_Rebuild_AM_team_English')]) {
            //create Set<Id> for english group members/OwnerId
            if (gm.Group.DeveloperName == 'BDR_Rebuild_AM_team_English') {
                englishTeamMembers.add(gm.UserOrGroupID);
            }
            //create Set<Id> for spanish group members/OwnerId
            else if (gm.Group.DeveloperName == 'BDR_Rebuild_AM_team_Spanish') {
                spanishTeamMembers.add(gm.UserOrGroupID);
            }
        }

        List<Lead> updatedEnglishLeads = [SELECT ID, OwnerID FROM Lead WHERE Language_Preference__c = 'English'];
        List<Lead> updatedSpanishLeads = [SELECT ID, OwnerID FROM Lead WHERE Language_Preference__c = 'Spanish'];
        System.assertEquals(true, spanishTeamMembers.contains(updatedSpanishLeads[0].OwnerId));
        System.assertEquals(true, spanishTeamMembers.contains(updatedSpanishLeads[1].OwnerId));
        System.assertEquals(true, englishTeamMembers.contains(updatedEnglishLeads[0].OwnerId));
        System.assertEquals(true, englishTeamMembers.contains(updatedEnglishLeads[1].OwnerId));
        System.assertEquals(true, englishTeamMembers.contains(updatedEnglishLeads[2].OwnerId));
        System.assertEquals(true, englishTeamMembers.contains(updatedEnglishLeads[3].OwnerId));
	}
}