@isTest
public class DemoRequestReminderTest {
    @TestSetup
    static void makeData() {
        //set up a few test holidays
        Date saturdayHoliday = Date.newInstance(2019, 09, 07);
        Date sundayHoliday = Date.newInstance(2019, 09, 15);
        Date thursdayHoliday = Date.newInstance(2019, 09, 12);
        Date mondayHoliday = Date.newInstance(2019, 09, 02);
        Date fridayHoliday = Date.newInstance(2019, 08, 23);
        List<Holiday> holidayList = new List<Holiday>();
        holidayList.add(new Holiday(ActivityDate = saturdayHoliday, Name = 'saturdayTest'));
        holidayList.add(new Holiday(ActivityDate = sundayHoliday, Name = 'sundayTest'));
        holidayList.add(new Holiday(ActivityDate = thursdayHoliday, Name = 'thursdayTest'));
        holidayList.add(new Holiday(ActivityDate = mondayHoliday, Name = 'mondayTest'));
        holidayList.add(new Holiday(ActivityDate = fridayHoliday, Name = 'fridayTest'));
        insert holidayList;
        
        
        
        
    }
    
    @isTest
    static void insertLead() {
        //need a couple of dates around the above holidays or known weekends
        DateTime saturdayCheck = DateTime.newInstance(2019, 09, 05, 0, 0, 0); //this should result in a timer for 2019-09-09 (because friday the 6th would be off)
        DateTime sundayCheck = DateTime.newInstance(2019, 09, 13, 00, 00, 00); //this should result in a timer for 2019-09-17 (because monday the 16th would be off)
        DateTime thursdayCheck = DateTime.newInstance(2019, 09, 11, 00, 00, 00); //this should result in a timer for 2019-09-13 
        DateTime mondayCheck = DateTime.newInstance(2019, 08, 30, 00, 00, 00); //this should result in a timer for 2019-09-03
        DateTime fridayCheck = DateTime.newInstance(2019, 08, 22, 00, 00, 00); //this should result in a timer for 2019-08-26
        DateTime weekendCheck = DateTime.newInstance(2019, 09, 20, 00, 00, 00); //this should result in a timer for 2019-09-23
        DateTime normalCheck = DateTime.newInstance(2019, 09, 17, 00, 00, 00); //this should redult in a timer for 2019-09-18
        //need to grab the demo request queue id
        //List<Group> queueId = [SELECT Id FROM Group WHERE Name = 'Demo Request Queue'];
        //need a couple of leads where the createdDates are the dates above
        //OwnerId = queueId[0].Id
        List<Lead> leadList = new List<Lead>();
        leadList.add(new Lead(CreatedDate = saturdayCheck, Company = 'Company Co', LastName = 'Name Name 1', Status = 'Untouched', Document_Status__c = 'Not Received'));
        leadList.add(new Lead(CreatedDate = sundayCheck, Company = 'Company Co', LastName = 'Name Name 2', Status = 'Untouched', Document_Status__c = 'Not Received'));
        leadList.add(new Lead(CreatedDate = thursdayCheck, Company = 'Company Co', LastName = 'Name Name 3', Status = 'Untouched', Document_Status__c = 'Not Received'));
        leadList.add(new Lead(CreatedDate = mondayCheck, Company = 'Company Co', LastName = 'Name Name 4', Status = 'Untouched', Document_Status__c = 'Not Received'));
        leadList.add(new Lead(CreatedDate = fridayCheck, Company = 'Company Co', LastName = 'Name Name 5', Status = 'Untouched', Document_Status__c = 'Not Received'));
        leadList.add(new Lead(CreatedDate = weekendCheck, Company = 'Company Co', LastName = 'Name Name 6', Status = 'Untouched', Document_Status__c = 'Not Received'));
        leadList.add(new Lead(CreatedDate = normalCheck, Company = 'Company Co', LastName = 'Name Name 6', Status = 'Untouched', Document_Status__c = 'Not Received'));
        //required fields: company, last name, (lead owner), lead status, document status
        //insert leads
        insert leadList;
        //query to get lead info
        List<Lead> newLeadInfo = [SELECT Id, Reminder_Email_Timer__c FROM Lead ORDER BY LastName ASC];
        //system.asserts to check the reminder_email_timer field
        System.assert( newLeadInfo[0].Reminder_Email_Timer__c != null );
        /*System.assertEquals(DateTime.valueOf('2019-09-09 00:00:00'), newLeadInfo[0].Reminder_Email_Timer__c);
System.assertEquals(DateTime.valueOf('2019-09-17 00:00:00'), newLeadInfo[1].Reminder_Email_Timer__c);
System.assertEquals(DateTime.valueOf('2019-09-13 00:00:00'), newLeadInfo[2].Reminder_Email_Timer__c);
System.assertEquals(DateTime.valueOf('2019-09-03 00:00:00'), newLeadInfo[3].Reminder_Email_Timer__c);
System.assertEquals(DateTime.valueOf('2019-08-26 00:00:00'), newLeadInfo[4].Reminder_Email_Timer__c);
System.assertEquals(DateTime.valueOf('2019-09-23 00:00:00'), newLeadInfo[5].Reminder_Email_Timer__c);
System.assertEquals(DateTime.valueOf('2019-09-18 00:00:00'), newLeadInfo[6].Reminder_Email_Timer__c);*/
    }
    
    /*
     * Description - Method to test the Lead count on the associated Org. group on the lead.
     *              Whenever a lead is associated with an Org. group, a new group affiliation is created from trigger
     *              and it updates the Total Leads(Total_Leads_new__c) field on the Org. group
     * Params - null
     * Return - null
    */
    @isTest
    static void setLeadCountTest(){
        Group__c oGroup = TestUtility.createGroup('Test_Group');
        insert oGroup;
        
        Lead oLead = TestUtility.createLead();
        insert oLead;
        
        Test.startTest();
        oLead.Organization_Group__c = oGroup.Id;
        update oLead;
        Test.stopTest();
        
        List<Group__c> lGroupListNew = [Select Id, Name, Total_Leads_new__c  FROM Group__c where Name = 'Test_Group'];
        System.assertEquals(1, lGroupListNew[0].Total_Leads_new__c);
        
    }
    
    /*
     * Description - Method to test the Account count on the associated Org. group on the lead.
     *              Whenever a lead is converted, the existing group affiliation is updated with the convertedAccountId
     *              and it updates the Total Accounts(Total_Accounts__c) field on the Org. group
     * Params - null
     * Return - null
    */
    @isTest 
    static void setAccountCount(){
        Account oAccount = TestUtility.createAccount('Test_Account_1');
        insert oAccount;
        
        Group__c oGroup = TestUtility.createGroup('Test_Group');
        insert oGroup;
        
        Lead oLead = TestUtility.createLead();
        insert oLead;
        
        
        oLead.Organization_Group__c = oGroup.Id;
        update oLead;
        
        List<Group__c> lGroupListNew = [Select Id, Name, Total_Leads_new__c  FROM Group__c where Name = 'Test_Group'];
        System.assertEquals(1, lGroupListNew[0].Total_Leads_new__c);
        Test.startTest();
        database.leadConvert lc = new database.leadConvert();
        lc.setLeadId(oLead.id);
        lc.setAccountId(oAccount.Id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Test.stopTest();
        
        List<Group__c> lGroupListNewPostUpdate = [Select Id, Name, Total_Accounts__c  FROM Group__c where Name = 'Test_Group'];
        System.assertEquals(1, lGroupListNewPostUpdate[0].Total_Accounts__c);
        
        
        
        
    }
}