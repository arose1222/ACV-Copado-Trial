/*
 Date            Author              Ticket      Description
 ----------------------------------------------------------------------------------------------
 21-04-2021     Nagendra Namburi    SALE-457    Removed the logic to update the "Customer Inquiry" and added logic to
                                                create a new Inquiry Comment whenever a "Log a call" is performed on the case record
*/

public class SetFollowUpDates extends TriggerInterface {
    
    public static final Id inquiryCommentRecId = Schema.SObjectType.Inquiry_Comment__c.getRecordTypeInfosByDeveloperName().get('Inquiry_Comment').getRecordTypeId();
    
    public override void afterInsert(List<sObject> objectList) {
        List<Task> newTasks = (List<Task>) objectList;
        Map<Id,Task> titleCaseIdToTask = new Map<Id,Task>();
        Set<Id> supportCaseIdsWithLoggedCalls = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        Date todaysDate = System.Today();

        // We will only run through portions of this logic if the current user's profile is in the following sets
        Set<String> titleProfiles = new Set<String>();
        Set<String> istProfiles = new Set<String>();
        for(Profile_Group__mdt pg : [SELECT Group_Name__c, Profile_Name__c FROM Profile_Group__mdt WHERE Group_Name__c IN ('IST Profiles','Title Profiles')]){
            if(pg.Group_Name__c == 'IST Profiles'){
                istProfiles.add(pg.Profile_Name__c);
            }
            else {
                titleProfiles.add(pg.Profile_Name__c);
            }
        }
        Boolean titleUser = false;
        Boolean istUser = false;
        if(titleProfiles.contains(ACVUtility.profileNameMap.get(UserInfo.getProfileId()))){
            titleUser = true;
        }
        if(istProfiles.contains(ACVUtility.profileNameMap.get(UserInfo.getProfileId()))){
            istUser = true;
        }
        
        // Check to see if call was logged on a Title Case
        // Call_On_Title_Case__c is set to true when task is created by Log_a_Call_Title_Case Global action
        for(Task t : newTasks){
            if(t.WhatId?.getSObjectType().getDescribe().getName() == 'Case'){ 
                if(t.Call_On_Title_Case__c == true && titleUser){
                    titleCaseIdToTask.put(t.WhatId,t);
                }
                else if(t.Call_On_Title_Case__c != true && istUser){
                    supportCaseIdsWithLoggedCalls.add(t.WhatId);
                }
            }
        }

        // Handle Call Logged on Title Case
        if(titleCaseIdToTask.keySet().size() > 0){
            
            Set<Case> relatedSupportCases = new Set<Case>();
            List<Customer_Inquiry__c> customerInquiries = new List<Customer_Inquiry__c>();
            
            // Confirm that call was logged on title case and then set Next Follow Up date on that title case
            List<Case> casesWithCalls = [SELECT Id, RecordTypeId, Next_Follow_Up__c, Ops_Last_Call_Date__c, 
                                            (SELECT Id, Ops_Case__c, Last_Ops_Call_Comments__c  , Last_Ops_Call_User__c, Last_Ops_Call_Date__c, Ops_Follow_Up_Date__c, Titles_Reason_for_Delay__c FROM Related_Cases1__r WHERE Status__c != 'Closed') 
                                            FROM Case WHERE Id IN :titleCaseIdToTask.keySet() AND RecordType.DeveloperName = 'Title_Information'];

            for(Case c : casesWithCalls){
                c.Ops_Last_Call_Date__c = todaysDate;
                if(titleCaseIdToTask.containsKey(c.Id)){
                    c.Next_Follow_Up__c = titleCaseIdToTask.get(c.Id).Follow_Up_Date__c;
                }
                casesToUpdate.add(c);
                customerInquiries.addAll(c.Related_Cases1__r);
            }

            // If the case has child Customer Inquiries, we will create an Inquiry_Comment__c for each of them
            if(customerInquiries.size() > 0){
                saveInquiryComments(customerInquiries, titleCaseIdToTask);
            }
        }

        // Handle Call logged on Support Case
        if(supportCaseIdsWithLoggedCalls.size() > 0){
            for(Case c : [SELECT Id, IST_Last_Call_Date__c, RecordTypeId FROM Case WHERE Id IN :supportCaseIdsWithLoggedCalls]){
                // Confirm that this call was logged on a support case and then update IST Last Call Date
                if(ACVUtility.recordTypeCheck('Support','Case',c.RecordTypeId)){
                    casesToUpdate.add(new Case(Id = c.Id, IST_Last_Call_Date__c = todaysDate)); 
                }
            }
        }

        if(casesToUpdate.size() > 0){
            update casesToUpdate;
        }
    }
    
    /**
     * Name         - saveInquiryComments
     * Params       - customerInquiries - List of Customer inquiries related to the cases.
     *              - titleCaseIdToTask - Map of CaseId to Task Record
     * Return       - Null
     * Description  - Create Inquiry comments records when a task is created.
     */
    public static void saveInquiryComments(List<Customer_Inquiry__c> customerInquiries, Map<Id,Task> titleCaseIdToTask){
        List<Inquiry_Comment__c> icToInsert = new List<Inquiry_Comment__c>();
        String commentFormat = 'Ops Follow Up Date : {0}\n'  
                            + 'Titles Reason for Delay : {1}\n'
                            + 'Last Ops Call Comments : {2}\n';
        
        for(Customer_Inquiry__c ci : customerInquiries){
            String followUp = 'No Follow Up Selected';
            if (titleCaseIdToTask.get(ci.Ops_Case__c).Follow_Up_Date__c != null) {
                followUp = (titleCaseIdToTask.get(ci.Ops_Case__c).Follow_Up_Date__c).format();
            } 
            List<String> valuesForFormatting = new List<String> 
                {
                    followUp,
                    titleCaseIdToTask.get(ci.Ops_Case__c).Reason_For_Title_Delay__c,
                    titleCaseIdToTask.get(ci.Ops_Case__c).Description
                };

            icToInsert.add(
                new Inquiry_Comment__c(
                    Inquiry_Notes__c = String.format(commentFormat, valuesForFormatting), 
                    RecordTypeId = inquiryCommentRecId, 
                    Customer_Inquiry__c = ci.Id,
                    Feed_Task_Created__c = true
                )
            );

        }
              
        if(!icToInsert.isEmpty()){
            insert icToInsert;
        }        
    }
}