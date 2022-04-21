/**
* This class is for Round Robin assignment of BDRs to "Organization Leads"
* @author Bhavana Majety
*/
public without sharing class LeadOwnerAssignmentBDR extends TriggerInterface {    
    /**
  * The Record Type Id of Organization Lead on the Lead Object
  */
    public static final Id ORGANIZATION_LEAD_RECORD_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
    public static final Group defaultLeadQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'BDR_Organization_Lead_Queue'];
    public static final Map<String, String> teamsMap = new Map<String, String>{'English' => 'BDR_Rebuild_AM_team_English', 'Spanish' => 'BDR_Rebuild_AM_team_Spanish'};
    /**
  * BeforeInsert for Trigger
  * Will update the field Lead Owner to a BDR, before the Lead is created
  * Order of operations: The before insert here will run, followed by Lead Assignment rules. Even if assignment rules don't make a change to the owner, it will trigger the beforeUpdate and AfterUpdate on BdrAssignmentEmail
  * @param newList new values of Leads
  */
    public override void beforeInsert(List<sObject> newList) {
        List<Lead> newLeads = (List<Lead>) newList;
        List<Lead> organizationLeads = new List<Lead>();

        for (Lead l : newLeads) {
            // The assignment is only for Organization Leads - if it is a marketplace or blitzteam it will get assigned in Lead assignment rules, so ignore here
            if(l.RecordTypeId == ORGANIZATION_LEAD_RECORD_ID && l.Market_Place_Report_User__c == false && l.Referral_Code__c != 'blitzteam') { 
                organizationLeads.add(l);
            }
        }

        if (organizationLeads.size() > 0) {
            Set<Id> allUserIds = new Set<Id>();
            Set<Id> englishTeamIds = new Set<Id>();
            Set<Id> spanishTeamIds = new Set<Id>();
            List<GroupMember> allGroupMembers = [SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE Group.DeveloperName IN :teamsMap.values()];
            for(GroupMember gm: allGroupMembers) {
                allUserIds.add(gm.UserOrGroupId);
            }

            Set<Id> oooUserIds = new Set<Id>();
            for (OutOfOffice ooo : [SELECT Id, UserId FROM OutOfOffice WHERE UserId IN :allUserIds AND (StartDate < TODAY AND EndDate > TODAY)]) {  // Will contain all active OutOfOffice messages
                oooUserIds.add(ooo.UserId);
            }
            Map<Id,User> ineligibleUsers = new Map<Id,User>([SELECT Id FROM User WHERE (Calendly_Link__c = null OR IsActive = false) AND Id IN :allUserIds]); // Will contain all of our group users that are either inactive or have a null Calendly Link

            Map<String,List<Id>> queueMap = new Map<String,List<Id>>(); //language group name , list of ids of people in that group
            for (GroupMember gm : allGroupMembers) {
                if (oooUserIds.contains(gm.UserOrGroupId) || ineligibleUsers.containsKey(gm.UserOrGroupId)) {
                    continue; // skip on to next groupMember
                }

                if(queueMap.get(gm.Group.DeveloperName) != null) {
                    queueMap.get(gm.Group.DeveloperName).add(gm.UserOrGroupId);
                }
                else{
                    queueMap.put(gm.Group.DeveloperName, new List<Id>{gm.UserorGroupId});
                }
            }

            Map<Id,Lead_Assignment_Tracking__c> assignmentMap = new Map<Id,Lead_Assignment_Tracking__c>();
            for (Lead_Assignment_Tracking__c allAssignments : [SELECT Id, Most_Recent_Assignment__c, User_Id__c FROM Lead_Assignment_Tracking__c ORDER BY Most_Recent_Assignment__c ASC]) {
                assignmentMap.put(allAssignments.User_Id__c, allAssignments);
            }

            Map<String, List<Id>> orderedQueueMap = getOrderedGroupMap(queueMap, assignmentMap.keySet());
            Map<String, Id> previousIdMap = new Map<String, Id>(); //long team name, id

            for (Lead orgLead : organizationLeads) {
                previousIdMap.put(teamsMap.get(orgLead.Language_Preference__c), setOwnerId(orderedQueueMap, previousIdMap, orgLead, assignmentMap));
            }
            upsert assignmentMap.values();
        }
    }

    private static Id setOwnerId(Map<String, List<Id>> orderedQueueMap, Map<String, Id> previousIdMap, Lead orgLead, Map<Id,Lead_Assignment_Tracking__c> assignmentMap) {
        if (!orderedQueueMap?.containsKey(teamsMap?.get(orgLead?.Language_Preference__c))) {
            orgLead.OwnerId = defaultLeadQueue.Id;
        }
        else {
            if (previousIdMap.get(teamsMap.get(orgLead.Language_Preference__c)) == null) {
                orgLead.OwnerId = orderedQueueMap.get(teamsMap.get(orgLead.Language_Preference__c))[0];
                orgLead.Assigned_On_Insert__c = true; // since we are assigning directly to user mark this as true.  BdrAssignmentEmail class will look to this value when deciding to send intro email
            }
            else {
                orgLead.OwnerId = findNextOwner(orderedQueueMap.get(teamsMap.get(orgLead.Language_Preference__c)), previousIdMap.get(teamsMap.get(orgLead.Language_Preference__c)));
                orgLead.Assigned_On_Insert__c = true; // since we are assigning directly to user mark this as true.  BdrAssignmentEmail class will look to this value when deciding to send intro email
            }

            if (!assignmentMap.containsKey(orgLead.OwnerId)) {
                Lead_Assignment_Tracking__c newTracker = new Lead_Assignment_Tracking__c(Name = orgLead.OwnerId, User_Id__c = orgLead.OwnerId, Most_Recent_Assignment__c = System.now());
                assignmentMap.put(orgLead.OwnerId, newTracker);
            }
            else {
                assignmentMap.get(orgLead.OwnerId).Most_Recent_Assignment__c = System.now();
            }
        }
        return orgLead.OwnerId;
    }

    private static Map<String, List<Id>> getOrderedGroupMap(Map<String, List<Id>> queueMap, Set<Id> orderedUserIds){ 
        Map<String, List<Id>> orderedQueueMap = new Map<String, List<Id>>();
        Set<Id> orderedIdSet = new Set<Id>();
        for (List<Id> l : queueMap.values()) {
            orderedIdSet.addAll(l);
        }
        orderedIdSet.removeAll(orderedUserIds);
        orderedIdSet.addAll(orderedUserIds);

        for (String team : queueMap.keySet()) {
            orderedQueueMap.put(team, new List<Id>());
            for (Id userId : orderedIdSet) {
                if (queueMap.get(team).contains(userId)) {
                    orderedQueueMap.get(team).add(userId);
                }
            }
        }

        return orderedQueueMap;
    }
    
    private static Id findNextOwner(List<Id> orderedTeamIds, Id previousOwner) {
        Id nextOwner;
        Integer index = orderedTeamIds.indexOf(previousOwner);
        if (orderedTeamIds.size() == (index + 1)) { // are we in the last item in the list
            nextOwner = orderedTeamIds[0];
        } 
        else {
            nextOwner = orderedTeamIds[index + 1];
        }
        return nextOwner;
    }
}