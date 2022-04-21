/**
 * @description Trigger utility class for assigning status and ownership of work orders based on service appointments.
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-13
 */
public with sharing class trac_AssignedResourceStatusOwnerHelper {

    @TestVisible public static final List<String> CLOSED_STATUSES = new List<String>{'Completed','Cannot Complete','Canceled','New','None'};
    @TestVisible public static final String ASSIGNED_STATUS = 'Assigned';

    /**
     * @description  Indicates if the work order includes any open service appointments besides the new ones.
     * @param serviceAppointList list of all open service appointments for a particular work order.
     * @param newServiceAppointmentIds set of all new service appointment ids.
     * @returns true if the work order has existing open service appointments.
     */
    private static Boolean allServiceAppointmentsNew (List<ServiceAppointment> serviceAppointmentList, Set<Id> newServiceAppointmentIds) {
        Boolean isNew = true;

        for (ServiceAppointment serviceAppointment : serviceAppointmentList) {
            if (!newServiceAppointmentIds.contains(serviceAppointment.Id)) {
                isNew = false;
                break;
            }
        }

        return isNew;
    }

    /**
     * @description  Updates the owner and status of new assigned resource work orders based on the status of existing service appointments.
     * If all existing (non-new) service appointments are closed or there are none, then the status is set to the assigned status.
     * Ownership is updated to the user that created the latest assignedResources, which is this running user.
     * @param assignedResources set of all new service appointments
     */
    public void updateWorkOrderStatusOwner(List<AssignedResource> assignedResources) {
        Set<Id> serviceAppointmentIds = new Set<Id>();
        List<WorkOrder> modifiedWorkOrders = new List<WorkOrder>();
        Id runningUserId = UserInfo.getUserId(); //user that is creating these latest assigned resources

        //If assigned resources is null, then do not update any work orders.
        //Note: an exception will be raised below if only isEmpty is checked.
        if ((assignedResources == null) || assignedResources.isEmpty()){
            return;
        }

        //Get a map of ServiceAppointments.
        //This is used to get the work order and its open assigned resources because this data is not available in a trigger directly.
        for (AssignedResource assignedResource : assignedResources) {
            if (assignedResource.ServiceAppointmentId != null) {
                serviceAppointmentIds.add(assignedResource.ServiceAppointmentId);
            }
        }

        //If there are no service appointments for the given assigned resources, then do not update any work orders.
        //The query below will return all work orders with no service appointment in that particular case, which should not be updated.
        if (serviceAppointmentIds.isEmpty()) {
            return;
        }

        //Get the work order list for the given assigned resources (via the service appointment), include a sub-list of all service appointments that are not closed.
        //This sub-list will contain the newly assigned service appointment (if after trigger) and any other existing ones that are not closed.
        //The sub-list is ordered so that the latest
        List<WorkOrder> workOrders = new List<WorkOrder>(
            [SELECT Id,Status,OwnerId,( SELECT Id,ParentRecordId,Status,OwnerId
                                        FROM ServiceAppointments
                                        WHERE Status NOT IN :CLOSED_STATUSES)
            FROM WorkOrder
            WHERE Id IN ( SELECT ParentRecordId
                          FROM ServiceAppointment
                          WHERE Id IN :serviceAppointmentIds)]);

        //Update work owner and status (if newly assigned service appointment(s) are the only open ones for the work order).
        //The work order owner is always updated to the user that created the latest assigned resource, which is the current running user.
        for (WorkOrder workOrder : workOrders) {
            WorkOrder modifiedWorkOrder = new WorkOrder(Id = workOrder.Id, ownerId = runningUserId);
            if ((workOrder.ServiceAppointments.isEmpty()) || (allServiceAppointmentsNew(workOrder.ServiceAppointments, serviceAppointmentIds))) {
                    modifiedWorkOrder.Status = ASSIGNED_STATUS;
            }
            if ((workOrder.OwnerId != modifiedWorkOrder.OwnerId) || (workOrder.Status != modifiedWorkOrder.Status)) {
                modifiedWorkOrders.add(modifiedWorkOrder);
            }
        }
        update modifiedWorkOrders;
    }

//    public static void deleteEntitySubscriptionForResource(List<AssignedResource> oldAssignedResources) {
//        List<AssignedResource> assignedResources = getAssignmentRecords(oldAssignedResources);
//
//        Set<Id> workOrderToResource = new Set<Id>();
//        for (AssignedResource assignedResource : assignedResources) {
//            if(assignedResource.ServiceResource.RelatedRecordId != null && assignedResource.ServiceAppointment.Work_Order__c != null) {
//                //workOrderToResource.put(assignedResource.ServiceAppointment.Work_Order__c, assignedResource.ServiceResource.RelatedRecordId);
//                workOrderToResource.add(assignedResource.ServiceAppointment.Work_Order__c);
//            }
//        }
//
//        Map<String ,EntitySubscription> entityExtIdMap = mapEntitySubscriptionsByExternalIds(workOrderToResource);
//        List<EntitySubscription> subscriptionsToDelete = new List<EntitySubscription>();
//
//        for(AssignedResource assignedResource : assignedResources) {
//            String extId = (String) assignedResource.ServiceAppointment.Work_Order__c + assignedResource.ServiceResource.RelatedRecordId;
//            if(entityExtIdMap.containsKey(extId)) {
//                subscriptionsToDelete.add(entityExtIdMap.get(extId));
//            }
//        }
//
//        if(!subscriptionsToDelete.isEmpty()) {
//            delete subscriptionsToDelete;
//        }
//    }

//    public static void createEntitySubscriptionForResource(List<AssignedResource> newAssignedResources) {
//        List<AssignedResource> assignedResources = getAssignmentRecords(newAssignedResources);
//
//        Set<Id> workOrderToResource = new Set<Id>();
//        for (AssignedResource assignedResource : assignedResources) {
//
//            if(assignedResource.ServiceResource.RelatedRecordId != null && assignedResource.ServiceAppointment.Work_Order__c != null) {
//                //workOrderToResource.put(assignedResource.ServiceAppointment.Work_Order__c, assignedResource.ServiceResource.RelatedRecordId);
//                workOrderToResource.add(assignedResource.ServiceAppointment.Work_Order__c);
//            }
//        }
//
//        Set<String> entityExtIds = getEntitySubscriptionExternalKeys(workOrderToResource);
//        List<EntitySubscription> subscriptionsToInsert = new List<EntitySubscription>();
//
//        for(AssignedResource assignedResource : assignedResources) {
//            String extId = (String) assignedResource.ServiceAppointment.Work_Order__c + assignedResource.ServiceResource.RelatedRecordId;
//
//            if(!entityExtIds.contains(extId)) {
//                EntitySubscription entitySubscription = new EntitySubscription(
//                        ParentId = assignedResource.ServiceAppointment.Work_Order__c,
//                        SubscriberId = assignedResource.ServiceResource.RelatedRecordId
//                );
//                subscriptionsToInsert.add(entitySubscription);
//            }
//        }
//        if(!subscriptionsToInsert.isEmpty()) {
//            insert subscriptionsToInsert;
//        }
//    }

//    private static List<AssignedResource> getAssignmentRecords(List<AssignedResource> newAssignedResources) {
//        return [
//                SELECT Id, ServiceResource.RelatedRecordId, ServiceAppointment.Work_Order__c
//                FROM AssignedResource
//                WHERE Id IN :newAssignedResources AND ServiceResource.RelatedRecordId != null
//                AND ServiceAppointment.Work_Order__c != null
//        ];
//    }
//
//    private static Set<String> getEntitySubscriptionExternalKeys(Set<Id> workOrder) {
//        List<EntitySubscription> allEntitySubscriptionsForWO = [
//                SELECT Id,ParentId,SubscriberId
//                FROM EntitySubscription
//                WHERE ParentId IN :workOrder //AND SubscriberId IN :workOrderToResource.values()
//        ];
//
//        Set<String> extIds = new Set<String>();
//        for(EntitySubscription ent : allEntitySubscriptionsForWO) {
//            String extId = (String) ent.ParentId + ent.SubscriberId;
//            extIds.add(extId);
//        }
//        return extIds;
//    }
//
//    private static Map<String, EntitySubscription> mapEntitySubscriptionsByExternalIds(Set<Id> workOrder) {
//        List<EntitySubscription> allEntitySubscriptionsForWO = [
//                SELECT Id,ParentId,SubscriberId
//                FROM EntitySubscription
//                WHERE ParentId IN :workOrder //AND SubscriberId IN :workOrderToResource.values()
//        ];
//
//        Map<String, EntitySubscription> extIdToSubscription = new Map<String, EntitySubscription>();
//        for(EntitySubscription ent : allEntitySubscriptionsForWO) {
//            String extId = (String) ent.ParentId + ent.SubscriberId;
//            extIdToSubscription.put(extId, ent);
//        }
//
//        return extIdToSubscription;
//    }
}