public without sharing class WorkOrderEmailAlerts extends TriggerInterface {
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, WorkOrder> oldWOMap = (Map<Id, WorkOrder>)oldMap;
        Map<Id, WorkOrder> newWOMap = (Map<Id, WorkOrder>)newMap;
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>();
        Map<Id, String> woliVins = new Map<Id, String>();
        List<Email_Notification__c> newNotifs = new List<Email_Notification__c>();
        Set<Id> acctIds = new Set<Id>();
        Set<Id> woIds = new Set<Id>();

        for (WorkOrder w : newWOMap.values()) {
            if ((w.Status != oldWOMap.get(w.Id).Status) && (w.Status == 'Completed')) {
                acctIds.add(w.AccountId);
                workOrderMap.put(w.AccountId, w);
                woIds.add(w.Id);
            }
        }

        if ( !woIds.isEmpty() ) {
            for (WorkOrderLineItem woli : [SELECT Id, WorkOrderId, VIN__c FROM WorkOrderLineItem WHERE WorkOrderId IN :woIds]) {
                if (woliVins.get(woli.WorkOrderId) == null) {
                    woliVins.put(woli.WorkOrderId, (woli.VIN__c + '\n'));
                }
                else {
                    String temp = woliVins.get(woli.WorkOrderId) + (woli.VIN__c + '\n');
                    woliVins.put(woli.WorkOrderId, temp);
                }
            }
        }

        if ( !acctIds.isEmpty() ) {
            List<Email_Notification_Subscription__c> ensList = [SELECT Id, Email_User_on_Work_Order_Completion__c, User__c, Account__c, Account__r.Name, Account__r.Dealership_Id__c FROM Email_Notification_Subscription__c WHERE Account__c IN :acctIds AND Email_User_on_Work_Order_Completion__c = true];
            for (Email_Notification_Subscription__c e : ensList) {
                newNotifs.add(new Email_Notification__c(Account__c = e.Account__c, Account_Name__c = e.Account__r.Name,
                Dealership_Id__c = e.Account__r.Dealership_Id__c, User__c = e.User__c,
                Send_Work_Order_Completed_Email__c = e.Email_User_on_Work_Order_Completion__c,
                Work_Order_Number__c = workOrderMap.get(e.Account__c).WorkOrderNumber, Location__c = workOrderMap.get(e.Account__c).LocationId,
                Work_Order_VINs__c = woliVins.get(workOrderMap.get(e.Account__c).Id),
                User_WorkOrder_Key__c = e.User__c + '' + workOrderMap.get(e.Account__c).Id));
            }
        }

        if (newNotifs.size() > 0) {
            upsert newNotifs User_WorkOrder_Key__c;
        }
    }
}