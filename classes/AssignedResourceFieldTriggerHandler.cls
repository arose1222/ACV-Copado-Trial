public class AssignedResourceFieldTriggerHandler extends TriggerInterface{
    public override void afterInsert(Map<Id, SObject> newMap){
        Map<Id, AssignedResource> newARMap = (Map<Id, AssignedResource>)newMap;
        assignMostRecentResource(newARMap);
    }
    public override void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        //only update the most recent resource field if ServiceResourceId or ServiceAppointmentId have changed
        Map<Id, AssignedResource> oldARMap = (Map<Id, AssignedResource>)oldMap;
        Map<Id, AssignedResource> newARMap = (Map<Id, AssignedResource>)newMap;
        assignMostRecentResource(resourceMapWithChangedFields(oldARMap, newARMap));
    }

    public void assignMostRecentResource(Map<Id, AssignedResource> arMap){
        Set<Id> appointmentIdSet = new Set<Id>();
        for(Id arId : arMap.keySet()){
            Id appointmentId = arMap.get(arId)?.ServiceAppointmentId;
            appointmentIdSet.add(appointmentId);
        }
        appointmentIdSet.remove(null);

        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>([SELECT Id, Most_Recent_Service_Resource__c, Current_Service_Resource__c FROM ServiceAppointment WHERE Id in : appointmentIdSet]);
        Map<Id, ServiceAppointment> saUpdateMap = new Map<Id, ServiceAppointment>();

        for(Id arId : arMap.keySet()){
            Id appointmentId = arMap.get(arId)?.ServiceAppointmentId;
            Id resourceId = arMap.get(arId)?.ServiceResourceId;
            Id recentResourceId = saMap.get(appointmentId)?.Most_Recent_Service_Resource__c;

            saUpdateMap.put(appointmentId, saMap.get(appointmentId));

            if(resourceId != null && recentResourceId != resourceId){
                saUpdateMap.get(appointmentId).Most_Recent_Service_Resource__c = resourceId;
            }
            saUpdateMap.get(appointmentId).Current_Service_Resource__c = resourceId;
        }
        Database.update(saUpdateMap.values());
    }

    public Map<Id, AssignedResource> resourceMapWithChangedFields(Map<Id, AssignedResource> oldArMap, Map<Id, AssignedResource> newArMap){
        Map<Id, AssignedResource> arMap = new Map<Id, AssignedResource>();
        for(Id arId : newArMap.keySet()){
            Id newResourceId = newArMap.get(arId)?.ServiceResourceId;
            Id newAppointmentId = newArMap.get(arId)?.ServiceAppointmentId;
            Id oldResourceId = oldArMap.get(arId)?.ServiceResourceId;
            Id oldAppointmentId = oldArMap.get(arId)?.ServiceAppointmentId;
            //continue if appointment and resource are not null and one of them has been changed
            if(newResourceId != null && newResourceId != null && (newResourceId != oldResourceId || newAppointmentId != oldAppointmentId)){
                arMap.put(arId, newArMap.get(arId));
            }
        }
        return arMap;
    }
}