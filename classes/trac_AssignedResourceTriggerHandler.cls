/**
 * @description Handler class for Assigned Resource Trigger
 * @author Isaiah Cummins, Traction on Demand
 * @date 9/17/2019
 */

public without sharing class trac_AssignedResourceTriggerHandler {

    /**
     * @description Find and delete old enity subscriptions for a deleted assigned resource record
     * @author Isaiah Cummins
     * @date 9/17/2019
     *
     * @param oldAssignedResources Trigger.old assigned resources
     */
    public static void deleteEntitySubscriptionForResource(List<AssignedResource> oldAssignedResources) {
        List<AssignedResource> assignedResources = getAssignmentRecords(oldAssignedResources);

        Set<Id> workOrderToResource = new Set<Id>();
        for (AssignedResource assignedResource : assignedResources) {
            if(assignedResource.ServiceResource.RelatedRecordId != null && assignedResource.ServiceAppointment.Work_Order__c != null) {
                workOrderToResource.add(assignedResource.ServiceAppointment.Work_Order__c);
            }
        }

        Map<String ,EntitySubscription> entityExtIdMap = mapEntitySubscriptionsByPsuedoExternalKeys(workOrderToResource);

        List<EntitySubscription> subscriptionsToDelete = new List<EntitySubscription>();
        for(AssignedResource assignedResource : assignedResources) {
            String extId = (String) assignedResource.ServiceAppointment.Work_Order__c + assignedResource.ServiceResource.RelatedRecordId;
            if(entityExtIdMap.containsKey(extId)) {
                subscriptionsToDelete.add(entityExtIdMap.get(extId));
            }
        }

        if(!subscriptionsToDelete.isEmpty()) {
            delete subscriptionsToDelete;
        }
    }
    /**
     * @description Create Entity Subscriptions for new Assigned Resource Records if they do not already exist
     * @author Isaiah Cummins
     * @date 9/17/2019
     *
     * @param oldAssignedResources Trigger.new assigned resources
     */
    public static void createEntitySubscriptionForResource(List<AssignedResource> newAssignedResources) {
        List<AssignedResource> assignedResources = getAssignmentRecords(newAssignedResources);

        Set<Id> workOrderToResource = new Set<Id>();
        for (AssignedResource assignedResource : assignedResources) {
            if(assignedResource.ServiceResource.RelatedRecordId != null &&
                    assignedResource.ServiceAppointment.Work_Order__c != null) {
                workOrderToResource.add(assignedResource.ServiceAppointment.Work_Order__c);
            }
        }

        Set<String> entityExtIds = getEntitySubscriptionPsuedoExternalKeys(workOrderToResource);
        List<EntitySubscription> subscriptionsToInsert = new List<EntitySubscription>();

        for(AssignedResource assignedResource : assignedResources) {
            String extId = (String) assignedResource.ServiceAppointment.Work_Order__c + assignedResource.ServiceResource.RelatedRecordId;

            if(!entityExtIds.contains(extId)) {
                EntitySubscription entitySubscription = new EntitySubscription(
                        ParentId = assignedResource.ServiceAppointment.Work_Order__c,
                        SubscriberId = assignedResource.ServiceResource.RelatedRecordId
                );
                subscriptionsToInsert.add(entitySubscription);
            }
        }
        if(!subscriptionsToInsert.isEmpty()) {
            insert subscriptionsToInsert;
        }
    }

    private static List<AssignedResource> getAssignmentRecords(List<AssignedResource> newAssignedResources) {
        return [
                SELECT Id, ServiceResource.RelatedRecordId, ServiceAppointment.Work_Order__c
                FROM AssignedResource
                WHERE Id IN :newAssignedResources AND ServiceResource.RelatedRecordId != NULL
                AND ServiceAppointment.Work_Order__c != NULL
        ];
    }
    // Create a set of psuedo-external Id's for existing entity subscriptions
    private static Set<String> getEntitySubscriptionPsuedoExternalKeys(Set<Id> workOrder) {
        List<EntitySubscription> allEntitySubscriptionsForWO = [
                SELECT Id,ParentId,SubscriberId
                FROM EntitySubscription
                WHERE ParentId IN :workOrder
        ];

        Set<String> extKeys = new Set<String>();
        for(EntitySubscription ent : allEntitySubscriptionsForWO) {
            String extKey = (String) ent.ParentId + ent.SubscriberId;
            extKeys.add(extKey);
        }
        return extKeys;
    }
    // Create a map of psuedo-external Id's
    private static Map<String, EntitySubscription> mapEntitySubscriptionsByPsuedoExternalKeys(Set<Id> workOrder) {
        List<EntitySubscription> allEntitySubscriptionsForWO = [
                SELECT Id,ParentId,SubscriberId
                FROM EntitySubscription
                WHERE ParentId IN :workOrder
        ];

        Map<String, EntitySubscription> extKeyToSubscription = new Map<String, EntitySubscription>();
        for(EntitySubscription ent : allEntitySubscriptionsForWO) {
            String extKey = (String) ent.ParentId + ent.SubscriberId;
            extKeyToSubscription.put(extKey, ent);
        }

        return extKeyToSubscription;
    }
}