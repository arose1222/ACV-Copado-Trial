public class ServiceAppointmentUnpinAndCommit extends TriggerInterface {

    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){
        for (ServiceAppointment sa : (List<ServiceAppointment>) newMap.values()){
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get(sa.Id);
            if (sa.FSL__Pinned__c != oldSA.FSL__Pinned__c && sa.FSL__Pinned__c){
                sa.Committed__c = true;
                sa.FSL__Pinned__c = false;
            }
        }
    }

}