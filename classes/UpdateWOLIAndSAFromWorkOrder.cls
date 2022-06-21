public without sharing class UpdateWOLIAndSAFromWorkOrder extends TriggerInterface {
    
    public override void afterUpdate(Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Map<Id, WorkOrder> oldWOMap = (Map<Id, WorkOrder>)oldMap;
        Map<Id, WorkOrder> newWOMap = (Map<Id, WorkOrder>)newMap;
        List<Id> canceledWorkOrderIds = new List<Id>();
        List<ServiceAppointment> serviceApptsToCancel = new List<ServiceAppointment>();
        List<WorkOrderLineItem> workOrderLineItemsToCancel = new List<WorkOrderLineItem>();

        for (WorkOrder wo : newWOMap.values()) {
            if(wo.Status != oldWOMap.get(wo.Id).Status && wo.Status == 'Canceled') {
                canceledWorkOrderIds.add(wo.Id);
            }
        }
        if(!canceledWorkOrderIds.isEmpty()) {
            serviceApptsToCancel = [SELECT Id, Status, Completed_Canceled_Notes__c, When_to_Return__c FROM ServiceAppointment WHERE ParentRecordId IN :canceledWorkOrderIds AND Status != 'Canceled'];
            for(ServiceAppointment sa : serviceApptsToCancel) {
                sa.Status = 'Canceled';
                sa.Completed_Canceled_Notes__c = 'The Work Order was canceled for this appointment, so the status of the appointment and all Work Order Line Items have been automatically updated to reflect this.';
                sa.When_to_Return__c = 'Never (Cancel the Work Order)';
            }

            if(!serviceApptsToCancel.isEmpty()) {
                update serviceApptsToCancel;
            }

            workOrderLineItemsToCancel = [SELECT Id, Status FROM WorkOrderLineItem WHERE WorkOrderId IN :canceledWorkOrderIds AND Status != 'Canceled'];
            for(WorkOrderLineItem woli : workOrderLineItemsToCancel) {
                woli.Status = 'Canceled';
            }

            if(!workOrderLineItemsToCancel.isEmpty()) {
                update workOrderLineItemsToCancel;
            }
        }
    }
}