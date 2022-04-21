public class CheckForInProgressWork extends TriggerInterface {

    public final static String IN_PROGRESS = 'InProgress';
    public final static Date TODAY = system.today();

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){

        Set<Id> serviceResourceIdSet = new Set<Id>();
        Set<Id> removeWipSAIdList = new Set<Id>();

        for (ServiceAppointment sa : (List<ServiceAppointment>) newMap.values()){
            ServiceAppointment oldSA = (ServiceAppointment) oldMap.get(sa.Id);

            //We dont need to worry about SA's that are not changing sched time to or from today, and not changing statuscategory to or from 'In Progress'
            if(sa.SchedStartTime?.date() != TODAY && oldSA.SchedStartTime?.date() != TODAY && sa.StatusCategory != IN_PROGRESS && oldSA.StatusCategory != IN_PROGRESS){continue;}

            //If the StatusCategory, Current_Service_Resource__c or , SchedStartTime  have been changed, we need to evaluate assigned resource for 'In Progress' work
            if(sa.StatusCategory != oldSA.StatusCategory ||
               sa.Current_Service_Resource__c != oldSA.Current_Service_Resource__c ||
               sa.SchedStartTime?.date() != oldSA.SchedStartTime?.date()){

                if(sa.Current_Service_Resource__c != null){
                    serviceResourceIdSet.add(sa.Current_Service_Resource__c);
                }

                if(oldSA.Current_Service_Resource__c != null){
                    serviceResourceIdSet.add(oldSA.Current_Service_Resource__c);
                }

                //Ensure that triggering SA's that will not be picked up in query below, have their WIP removed
                if(sa.SchedStartTime?.date() != TODAY || sa.Current_Service_Resource__c == null){
                    removeWipSAIdList.add(sa.Id);
                }
            }
        }

        List<ServiceAppointment> saUpdateList = new List<ServiceAppointment>();
        if(serviceResourceIdSet.size() > 0 ){
            //get a list of updated but not committed SA's by resource Id
            saUpdateList = checkForInProgressServiceAppointments(serviceResourceIdSet);
        }

        //Add triggering SA to update if needed
        for(ServiceAppointment sa : [SELECT Id, Assigned_Resource_Has_In_Progress_Work__c FROM ServiceAppointment WHERE Id IN: removeWipSAIdList]){
            if(!saUpdateList.contains(sa)){
                sa.Assigned_Resource_Has_In_Progress_Work__c = false;
                saUpdateList.add(sa);
            }
        }

        update saUpdateList;


    }


    public override void afterInsert(Map<Id,SObject> newMap){

        Set<Id> serviceResourceIdSet = new Set<Id>();

        for (ServiceAppointment sa : (List<ServiceAppointment>) newMap.values()){
            if(sa.SchedStartTime?.date() != TODAY){continue;}

            if(sa.Current_Service_Resource__c != null){
                serviceResourceIdSet.add(sa.Current_Service_Resource__c);
            }
        }

        if(serviceResourceIdSet.size() > 0){
            update checkForInProgressServiceAppointments(serviceResourceIdSet);
        }
    }


    public override void afterDelete(Map<Id,SObject> oldMap){

        Set<Id> serviceResourceIdSet = new Set<Id>();

        for (ServiceAppointment sa : (List<ServiceAppointment>) oldMap.values()){
            if(sa.SchedStartTime?.date() != TODAY){continue;}

            if(sa.Current_Service_Resource__c != null && sa.StatusCategory == IN_PROGRESS){
                serviceResourceIdSet.add(sa.Current_Service_Resource__c);
            }
        }

        if(serviceResourceIdSet.size() > 0){
            update checkForInProgressServiceAppointments(serviceResourceIdSet);
        }
    }


    public static List<ServiceAppointment> checkForInProgressServiceAppointments(Set<Id> serviceResourceIdSet){

        List<ServiceAppointment> saProcessList = [SELECT Id, Current_Service_Resource__c, Assigned_Resource_Has_In_Progress_Work__c, StatusCategory
                                                  FROM ServiceAppointment
                                                  WHERE Current_Service_Resource__c IN :serviceResourceIdSet
                                                    AND SchedStartTime = TODAY];

        //Build a map Key = Resource Id and Value = Boolean (has in progress work)
        Map<Id, Boolean> srIdIsInProgressMap = new Map<Id, Boolean>();
        for(ServiceAppointment sa : saProcessList){
            //if we already have work in progress for this resource, move on
            if(srIdIsInProgressMap.get(sa.Current_Service_Resource__c) == true){
                continue;
            } else {
                srIdIsInProgressMap.put(sa.Current_Service_Resource__c, sa.StatusCategory == IN_PROGRESS);
            }
        }

        //Update the service appointments to the appropriate WIP
        List<ServiceAppointment> saUpdateList = new List<ServiceAppointment>();
        for(ServiceAppointment sa : saProcessList){
            if(sa.Assigned_Resource_Has_In_Progress_Work__c != srIdIsInProgressMap.get(sa.Current_Service_Resource__c)){
                sa.Assigned_Resource_Has_In_Progress_Work__c = srIdIsInProgressMap.get(sa.Current_Service_Resource__c);
                saUpdateList.add(sa);
            }
        }

        return saUpdateList;
    }
}