public with sharing class CustomerInquiryUpdateHandler extends TriggerInterface {   
    
    static final String newStatus = 'New';
    static final String working = 'Working';
    static final String amFollowUp = 'AM Follow Up';
    static final String closed = 'Closed';

    public override void beforeUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, Customer_Inquiry__c> oldCIMap = (Map<Id, Customer_Inquiry__c>)oldMap;
        Map<Id, Customer_Inquiry__c> newCIMap = (Map<Id, Customer_Inquiry__c>)newMap;
        Set<String> resolvedProfiles = new Set<String>{'Titles', 'Title Manager', 'Customer Success Team'};
    
        for (Customer_Inquiry__c c : newCIMap.values()) { 
            // If status changes from closed to anything, Priority is set to high
            if (c.Status__c != closed && oldCIMap.get(c.Id).Status__c == closed) {
                c.Priority__c = 'High';
            }
            // If status goes from AM Follow Up to new or working, increase priority one level
            else if ((c.Status__c == newStatus || c.Status__c == working) && oldCIMap.get(c.Id).Status__c == amFollowUp) {
                if(c.Priority__c == 'Low'){
                    c.Priority__c = 'Medium';
                }
                else {
                    c.Priority__c = 'High';
                }
            }
            // If status changes to AM Follow Up by a user who is not the assigned to user and has 'Titles', 'Title Manager', 'Customer Success Team' profile, make the editing user the assigned to
            else if (c.Status__c == amFollowUp && oldCIMap.get(c.Id).Status__c != amFollowUp && c.Assigned_To__c != UserInfo.getUserId()) {
                Id profileId = Userinfo.getProfileId();
                String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId].Name;
                if (resolvedProfiles.contains(profileName)) {
                    c.Assigned_To__c = UserInfo.getUserId();
                }
            }
            // If status changes to Closed by a user who is not the assigned to user and has 'Customer Success Team' profile, make the editing user the assigned to
            else if (c.Status__c == closed && oldCIMap.get(c.Id).Status__c != closed && c.Assigned_To__c != UserInfo.getUserId()) {
                Id profileId = Userinfo.getProfileId();
                String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId].Name;
                if (profileName == 'Customer Success Team') {
                    c.Assigned_To__c = UserInfo.getUserId();
                }
            }

        }
    }

    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, Customer_Inquiry__c> oldCIMap = (Map<Id, Customer_Inquiry__c>)oldMap;
        Map<Id, Customer_Inquiry__c> newCIMap = (Map<Id, Customer_Inquiry__c>)newMap;
        Set<Id> supportCaseIds = new Set<Id>();
        Set<Id> updateToWorkingIds = new Set<Id>();
        Set<Id> parentSupportCaseIds = new Set<Id>();
        Map<Id, Case>  casesWithStatusChange = new Map<Id, Case> ();
        Map<Id, Case> casesWithPriorityUpdates = new Map<Id, Case>();
        List<Case> allUpdates = new List<Case>();
        
        // Look for status or priority changes on Customer Inquiries
        for (Customer_Inquiry__c ci : newCIMap.values()) { 
            if (ci.Support_Case__c != null) { //only execute the following code for those CIs that have a support case
                // if the highest priority CI is closed (or any CI's priority is changed): update the support case to reflect the new highest priority CI
                if(ci.Priority__c != oldCIMap.get(ci.Id).Priority__c || (ci.Status__c == closed && oldCIMap.get(ci.Id).Status__c != closed)) {
                    supportCaseIds.add(ci.Support_Case__c); 
                }

                // Check for status changes
                if (ci.Status__c == working && oldCIMap.get(ci.Id).Status__c != working) {
                    updateToWorkingIds.add(ci.Support_Case__c); // if any CI is changed to working (Working), set the support case status to working
                }
                else if (ci.Status__c == amFollowUp && oldCIMap.get(ci.Id).Status__c != amFollowUp) {
                    parentSupportCaseIds.add(ci.Support_Case__c); // if all CI's related to a support case are in the AM Follow Up (AM Follow Up) status, set support case status to ready for response
                    updateToWorkingIds.add(ci.Support_Case__c); // set support cases to working if they were not already processed by the above line first (above map is processed before this set)
                }
                else if (ci.Status__c == closed && oldCIMap.get(ci.Id).Status__c != closed) {
                    parentSupportCaseIds.add(ci.Support_Case__c); // if all CI's related to a support case are in the Closed (Closed) status, set support case status to closed
                    updateToWorkingIds.add(ci.Support_Case__c); // set support cases to working if they were not already processed by the above line first (above map is also processed before this set)
                }
                else if (ci.Status__c == newStatus && oldCIMap.get(ci.Id).Status__c != newStatus) {
                    parentSupportCaseIds.add(ci.Support_Case__c); // if all CI's related to a support case are in the New (New) status, set support case status to new
                }
            }
        }
        if(!supportCaseIds.isEmpty()){
            casesWithPriorityUpdates = syncPriority(casesWithPriorityUpdates, supportCaseIds);
        }

        if (!parentSupportCaseIds.isEmpty()) {
            casesWithStatusChange = queryForChildInquiries(parentSupportCaseIds);
        }
        
        updateToWorkingIds.removeAll(casesWithStatusChange.keySet()); // if the set still contains the case id after being processed, remove it from the set as nothing else needs to be done

        if (!updateToWorkingIds.isEmpty()) {
            for (Case c : [SELECT Id, Status FROM Case WHERE Id IN :updateToWorkingIds AND Status != :working]) {
                c.Status = working;
                casesWithStatusChange.put(c.Id, c);
            }
        }

        // add all support case changes to a single list to be processed in one DML call 
        allUpdates = getFinalUpdateList(casesWithStatusChange, casesWithPriorityUpdates); 

        if (!allUpdates.isEmpty()) {
            update allUpdates;
        }
    }

    // This will only update Support Case status if all of its child inquiries have the same status
    public static Map<Id,Case> queryForChildInquiries(Set<Id> parentSupportCaseIds) {
        Map<Id,Case> supportCaseStatus = new Map<Id,Case>();
        Set<Id> casesToIgnore = new Set<Id>();

        for (Customer_Inquiry__c ci : [SELECT Id, Status__c, Support_Case__c FROM Customer_Inquiry__c WHERE Support_Case__c IN :parentSupportCaseIds]) {
            // casesToIgnore is populated by support cases that we find have child inquiries with multiple statuses
            if (!casesToIgnore.contains(ci.Support_Case__c)) {
                if(ci.Status__c == amFollowUp) {
                    ci.Status__c = 'Ready for Response'; // changing here bc AM Follow Up on CI maps to Ready for Response on the Support Case
                }
                if (!supportCaseStatus.containsKey(ci.Support_Case__c)) {
                    if (ci.Status__c == closed) {
                        supportCaseStatus.put(ci.Support_Case__c, new Case(Id = ci.Support_Case__c, Status = ci.Status__c, Open_Customer_Inquiry__c = false));
                    } 
                    else {
                        supportCaseStatus.put(ci.Support_Case__c, new Case(Id = ci.Support_Case__c, Status = ci.Status__c));
                    }
                }
                else if (supportCaseStatus.get(ci.Support_Case__c).Status != ci.Status__c) {
                    supportCaseStatus.remove(ci.Support_Case__c);
                    casesToIgnore.add(ci.Support_Case__c);
                }
            }
        }
        return supportCaseStatus;
    }
    
    public static List<Case> getFinalUpdateList(Map<Id,Case> casesWithStatusChange, Map<Id,Case> casesWithPriorityUpdates) {

        // If we have priority changes, merge those with any status changes
        if (!casesWithPriorityUpdates.isEmpty()) {
            for (Case c : casesWithStatusChange.values()) {
                if (casesWithPriorityUpdates.containsKey(c.Id)) {
                    c.Priority = casesWithPriorityUpdates.get(c.Id).Priority;
                    casesWithPriorityUpdates.remove(c.Id);
                }
            }
            if (casesWithPriorityUpdates.isEmpty()) {
                casesWithStatusChange.putAll(casesWithPriorityUpdates.values());
            }
        }

        return casesWithStatusChange.values();
    }

    // Sets support case priority equal to the highest priority of it's active child inquiries
    public static Map<Id,Case> syncPriority(Map<Id,Case> casesWithPriorityUpdates, Set<Id> supportCaseIds) {
        
        for(Customer_Inquiry__c ci : [SELECT Id, Support_Case__c, Support_Case__r.Priority, Priority__c FROM Customer_Inquiry__c WHERE Support_Case__c IN :supportCaseIds AND Status__c != :closed ORDER BY Priority__c DESC]) {
            // Since we are ordering by priority we will hit High, Medium, and then Low
            if(!casesWithPriorityUpdates.containsKey(ci.Support_Case__c)) {
                if(ci.Support_Case__r.Priority != ci.Priority__c) {
                    casesWithPriorityUpdates.put(ci.Support_Case__c, new Case(Id = ci.Support_Case__c, Priority = ci.Priority__c));
                }
            } 
        }

        return casesWithPriorityUpdates;
    }
}