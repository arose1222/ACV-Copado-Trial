public class HandleAccountTeamChanges extends TriggerInterface{    
    /**
     * Looks for change on Title Specialist or Title Consultant and updates Customer Inquiries from that account that were assigned to the old value
     * @param incomingOldMap    oldMap of Accounts
     * @param incomingNewMap    newMap of Accounts
     */
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){
        List<Customer_Inquiry__c> inqsToUpdate = new List<Customer_Inquiry__c>();
        Map<Id,Account> newAccMap = (Map<Id,Account>) incomingNewMap;
        Map<Id,Account> oldAccMap = (Map<Id,Account>) incomingOldMap;
        Map<Id, Account> userChangeUpdate = new Map<Id, Account>();

        for(Account acc : newAccMap.values()) {
            if (acc.Title_Specialist__c != oldAccMap.get(acc.Id).Title_Specialist__c || acc.Customer_Success_Advocate__c != oldAccMap.get(acc.Id).Customer_Success_Advocate__c) {
                userChangeUpdate.put(acc.Id, acc);
            }
        }

        if (userChangeUpdate.size() > 0) {
            User doNotCall = [SELECT Id FROM User WHERE FirstName = 'Do' AND LastName = 'Not Call'];
            Set<String> specialistStatusSet = new Set<String>{'Problem', 'Return To Seller', 'Closed Unwound', 'Returned to Seller Unwound', 'Title at ACV Unwound'};
            Set<String> otherStatusSet = new Set<String>{'Working', 'Received', 'New', '48 Hour Notice', 'Sent'};

            for(Customer_Inquiry__c ci : [SELECT Id, CreatedById, CreatedBy.IsActive, Call_Bucket__c, Call_Type__c, Assigned_To__c, Ops_Case__r.Status, Status__c, Account__c, Account__r.IST_Account_Owner__c, Ops_Case__r.Seller_Dealership__r.Title_Specialist__c, Ops_Case__r.Seller_Dealership__r.Customer_Success_Advocate__c, Ops_Case__r.Account.IST_Account_Owner__c FROM Customer_Inquiry__c WHERE Status__c != 'Closed' AND Ops_Case__r.Seller_Dealership__c IN :userChangeUpdate.keySet()]){
                
                Boolean ciNeedsUpdate = false;
                if ((ci.Assigned_To__c == oldAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Title_Specialist__c || oldAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Title_Specialist__c == null) && newAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Title_Specialist__c != oldAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Title_Specialist__c) {
                    ciNeedsUpdate = true;
                }
                else if ((ci.Assigned_To__c == oldAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Customer_Success_Advocate__c || oldAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Title_Specialist__c == null) && newAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Customer_Success_Advocate__c != oldAccMap.get(ci.Ops_Case__r.Seller_Dealership__c).Customer_Success_Advocate__c) {
                    ciNeedsUpdate = true;
                }

                if (ciNeedsUpdate) {
                    if ( (((ci.Call_Type__c == 'Buyer Title Status' || ci.Call_Type__c == 'Seller Title Status') && specialistStatusSet.contains(ci.Ops_Case__r.Status) ) || ci.Call_Type__c == 'Buyer Reported Problem') && (ci.Assigned_To__c != ci.Ops_Case__r.Seller_Dealership__r.Title_Specialist__c && ci.Ops_Case__r.Seller_Dealership__r.Title_Specialist__c != null)) {
                        ci.Assigned_To__c = ci.Ops_Case__r.Seller_Dealership__r.Title_Specialist__c;
                        inqsToUpdate.add(ci);
                    }
                    else if ( ((ci.Call_Type__c == 'Buyer Title Status' && otherStatusSet.contains(ci.Ops_Case__r.Status) ) || (ci.Call_Bucket__c == 'Title_Information' && ci.Call_Type__c == 'Other')) && (ci.Assigned_To__c != ci.Ops_Case__r.Seller_Dealership__r.Customer_Success_Advocate__c && ci.Ops_Case__r.Seller_Dealership__r.Customer_Success_Advocate__c != null)) { //ci.Call_Type__c == '48 Hour Notice Request' || ci.Call_Type__c == '48 Hour Notice Update' ||
                        ci.Assigned_To__c = ci.Ops_Case__r.Seller_Dealership__r.Customer_Success_Advocate__c;
                        inqsToUpdate.add(ci);
                    }
                    // assigning to buyer IST account owner
                    else if ((otherStatusSet.contains(ci.Ops_Case__r.Status) && ci.Call_Type__c == 'Seller Title Status') && (ci.Ops_Case__r.Account.IST_Account_Owner__c != null && ci.Ops_Case__r.Account.IST_Account_Owner__c != doNotCall.Id && ci.Assigned_To__c != ci.Ops_Case__r.Account.IST_Account_Owner__c)) {
                        ci.Assigned_To__c = ci.Ops_Case__r.Account.IST_Account_Owner__c;
                        inqsToUpdate.add(ci);
                    }
                    else if (ci.Account__r.IST_Account_Owner__c != null && ci.Assigned_To__c != ci.Account__r.IST_Account_Owner__c) {
                        ci.Assigned_To__c = ci.Account__r.IST_Account_Owner__c;
                        inqsToUpdate.add(ci);
                    }
                    else if (ci.Ops_Case__r.Account.IST_Account_Owner__c != null && ci.Ops_Case__r.Account.IST_Account_Owner__c != doNotCall.Id && ci.Assigned_To__c != ci.Ops_Case__r.Account.IST_Account_Owner__c) {
                        ci.Assigned_To__c = ci.Ops_Case__r.Account.IST_Account_Owner__c;
                        inqsToUpdate.add(ci);
                    }
                    else if(ci.CreatedBy.IsActive == true && ci.Assigned_To__c != ci.CreatedById){
                        ci.Assigned_To__c = ci.CreatedById;
                        inqsToUpdate.add(ci);
                    }
                }
            }

            if (inqsToUpdate.size() > 0) {
                update inqsToUpdate;
            }
        }
    }
}