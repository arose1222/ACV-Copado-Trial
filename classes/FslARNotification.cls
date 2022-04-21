//need to do:
//Break out functions into individual components for reusability across different triggers


public with sharing class FslARNotification extends TriggerInterface{




    public override void afterInsert(List<SObject> newList){

        List<AssignedResource> arList = (List<AssignedResource>)newList;
        //FslNotificationBuilder.assignmentMessage(arList);
    }

    public override void afterUpdate(List<SObject> oldList, List<SObject> newList){

        List<AssignedResource> arList = new List<AssignedResource>();
        List<AssignedResource> newArList = (List<AssignedResource>)newList;
        List<AssignedResource> oldArList = (List<AssignedResource>)oldList;
        Map<Id, AssignedResource> oldArMap = new Map<Id, AssignedResource>(oldArList);

        //only include assigned resources whose service resource has changed. Send notification to new resource

        /*for(AssignedResource ar : newArList){
            if(oldArMap.get(ar.Id).ServiceResourceId != ar.ServiceResourceId){
                arList.add(ar);
            }
        }*/

        /*if(!arList.isEmpty()){
            system.debug(arList);
            //FslNotificationBuilder.assignmentMessage(arList);
        }*/

    }


}