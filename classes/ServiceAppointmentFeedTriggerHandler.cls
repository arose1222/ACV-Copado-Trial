public class ServiceAppointmentFeedTriggerHandler extends TriggerInterface{

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        Map<Id, ServiceAppointment> oldSAMap = (Map<Id, ServiceAppointment>)oldMap;
        Map<Id, ServiceAppointment> newSAMap = (Map<Id, ServiceAppointment>)newMap;

        for(ServiceAppointment serviceAppt : newSAMap.values()){
            String newStatus = serviceAppt.Status;
            String oldStatus = oldSAMap.get(serviceAppt.Id).Status;

            if(oldStatus != newStatus && (newStatus == 'New' || newStatus == 'Canceled' || newStatus == 'Expired')){
                serviceAppt.Current_Service_Resource__c = null;
            }
        }
    }


    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){

        Map<Id, ServiceAppointment> oldSAMap = (Map<Id, ServiceAppointment>)oldMap;
        Map<Id, ServiceAppointment> newSAMap = (Map<Id, ServiceAppointment>)newMap;

        List<ServiceAppointment> saToSubscribeList = new List<ServiceAppointment>();
        List<ServiceAppointment> deleteSubscriptionList = new List<ServiceAppointment>();

        for(ServiceAppointment serviceAppt : newSAMap.values()){
            String newStatus = serviceAppt.Status;
            String oldStatus = oldSAMap.get(serviceAppt.Id).Status;

            String newCurrentResource = serviceAppt.Current_Service_Resource__c;
            String oldCurrentResource = oldSAMap.get(serviceAppt.Id).Current_Service_Resource__c;


            if(newStatus == 'Dispatched' && oldStatus != 'Dispatched'){
                //Create the subscription
                saToSubscribeList.add(serviceAppt);
            } else if(oldStatus == 'Dispatched' && newStatus != 'Dispatched'){
                //Delete the subscription
                deleteSubscriptionList.add(oldSAMap.get(serviceAppt.Id));
            } else if(oldStatus == 'Dispatched' && newStatus == 'Dispatched' && newCurrentResource != oldCurrentResource){
                //Create the subscription
                saToSubscribeList.add(serviceAppt);
                //Delete the subscription
                deleteSubscriptionList.add(oldSAMap.get(serviceAppt.Id));
            }
        }

        if(saToSubscribeList.size()>0){
            createSubscription(saToSubscribeList);
        }
        if(deleteSubscriptionList.size()>0){
            System.enqueueJob(new deleteSubscription(deleteSubscriptionList));
        }

    }


    public void createSubscription(List<ServiceAppointment> saToSubscribeList){

        Map<Id,Id> resourceIdUserIdMap = getResourceIdUserIdMap(saToSubscribeList);
        List<EntitySubscription> subscriptionInsertList = new List<EntitySubscription>();

        for(ServiceAppointment serviceAppt : saToSubscribeList){
            if(serviceAppt.Id != null && resourceIdUserIdMap.containsKey(serviceAppt.Current_Service_Resource__c)){
                EntitySubscription entitySubscription = new EntitySubscription(
                    ParentId = serviceAppt.Id,
                    SubscriberId = resourceIdUserIdMap.get(serviceAppt.Current_Service_Resource__c)
                    );
                subscriptionInsertList.add(entitySubscription);
            }
        }
        insert subscriptionInsertList;
    }


    public class deleteSubscription implements Queueable {
        public final List<ServiceAppointment> saToUnSubscribeList;
        public deleteSubscription(List<ServiceAppointment> input)
        {
            saToUnSubscribeList = input;
        }
        public void execute(QueueableContext context) {

            Map<Id,Id> resourceIdUserIdMap = ServiceAppointmentFeedTriggerHandler.getResourceIdUserIdMap(saToUnSubscribeList);
            Map<Id,Id> saIdUserIdMap = new Map<Id,Id>();

            for(ServiceAppointment serviceAppt : saToUnSubscribeList){
                saIdUserIdMap.put(serviceAppt.Id, resourceIdUserIdMap.get(serviceAppt.Current_Service_Resource__c));
            }

            List<EntitySubscription> entitySubsToDelete = new List<EntitySubscription>();
            for(EntitySubscription entitySub : [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId = :saIdUserIdMap.keySet() AND SubscriberId = :saIdUserIdMap.values()]){
                if(entitySub.SubscriberId == saIdUserIdMap.get(entitySub.ParentId)){
                    entitySubsToDelete.add(entitySub);
                }
            }
            delete entitySubsToDelete;
        }
    }


    public static Map<Id,Id> getResourceIdUserIdMap(List<ServiceAppointment> serviceAppointmentList){
        Set<Id> currentServiceResIdSet = new Set<Id>();
        for(ServiceAppointment serviceAppt : serviceAppointmentList){
            currentServiceResIdSet.add(serviceAppt.Current_Service_Resource__c);
        }

        Map<Id,Id> resourceIdUserIdMap = new Map<Id,Id>();
        for(ServiceResource sr : [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :currentServiceResIdSet]){
            resourceIdUserIdMap.put(sr.Id, sr.RelatedRecordId);
        }
        return resourceIdUserIdMap;

    }
}