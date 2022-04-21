public without sharing class WorkOrderEmailAlerts extends TriggerInterface {
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, WorkOrder> oldWOMap = (Map<Id, WorkOrder>)oldMap;
        Map<Id, WorkOrder> newWOMap = (Map<Id, WorkOrder>)newMap;
        Map<Id, List<WorkOrder>> workOrderMap = new Map<Id, List<WorkOrder>>();
        Map<Id, String> woliVins = new Map<Id, String>();
        List<Email_Notification__c> newNotifs = new List<Email_Notification__c>();
        Set<Id> acctIds = new Set<Id>();
        Set<Id> woIds = new Set<Id>();

        for (WorkOrder w : newWOMap.values()) {
            if ((w.Status != oldWOMap.get(w.Id).Status) && (w.Status == 'Completed')) {
                if(!acctIds.contains(w.AccountId)) {
                    acctIds.add(w.AccountId);
                    workOrderMap.put(w.AccountId, new List<WorkOrder>());
                }
                List<WorkOrder> woListForAcc = workOrderMap.get(w.AccountId);
                woListForAcc.add(w);
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
            List<Email_Notification_Subscription__c> ensList = [SELECT Id, Email_User_on_Work_Order_Completion__c, User__c, Account__c, Account__r.Name, Account__r.Dealership_Id__c, Work_Order__c FROM Email_Notification_Subscription__c WHERE Account__c IN :acctIds AND Email_User_on_Work_Order_Completion__c = true];
            for (Email_Notification_Subscription__c e : ensList) {
                if(e.Work_Order__c == null) {
                    List<WorkOrder> woList = workOrderMap.get(e.Account__c);
                    for(Integer i = 0; I < woList.size(); i++) {
                        WorkOrder wo = woList[i];
                        createEmailNotification(newNotifs, e, wo, woliVins);
                    }
                    woList.clear();
                }
                else {
                    List<WorkOrder> woList = workOrderMap.get(e.Account__c);
                    for(Integer i = 0; I < woList.size(); i++) { 
                        WorkOrder wo = woList[i];
                        if(wo.Id == e.Work_Order__c) {
                            createEmailNotification(newNotifs, e, wo, woliVins);
                            woList.remove(i);
                            break;
                        }
                    }
                }
            }
        }

        if (newNotifs.size() > 0) {
            upsert newNotifs User_WorkOrder_Key__c;
        }
    }

    public void createEmailNotification(List<Email_Notification__c> newNotifs, Email_Notification_Subscription__c e, WorkOrder wo, Map<Id, String> woliVins) {
        newNotifs.add(new Email_Notification__c(Account__c = e.Account__c, Account_Name__c = e.Account__r.Name,
        Dealership_Id__c = e.Account__r.Dealership_Id__c, User__c = e.User__c,
        Send_Work_Order_Completed_Email__c = e.Email_User_on_Work_Order_Completion__c,
        Work_Order_Number__c = wo.WorkOrderNumber, Location__c = wo.LocationId,
        Work_Order_VINs__c = woliVins.get(wo.Id),
        User_WorkOrder_Key__c = e.User__c + '' + wo.Id));
    }

}