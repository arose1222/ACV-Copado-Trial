public with sharing class FslNotificationBuilder {
    /*public FslNotificationBuilder() {
        
    }

    public static void messageAppointedResource(List<AssignedResource> arList, String notification){
        system.debug('message builder entered');
        //Navigate to all the needed objects for their fields
        Set<Id> srIdSet = new Set<Id>();
        Set<Id> saIdSet = new Set<Id>();
        for (AssignedResource ar : arList){
            srIdSet.add(ar.ServiceResourceId);
            saIdSet.add(ar.ServiceAppointmentId);
        }
        
        list<ServiceResource> srList = [SELECT id, RelatedRecordId FROM ServiceResource WHERE id in :srIdSet];
        Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>(srList);

        list<ServiceAppointment> saList = [SELECT id, AccountId, AppointmentNumber, ParentRecordId, DueDate FROM ServiceAppointment WHERE id in : saIdSet];
        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>(saList);

        Set<Id> woIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        for (ServiceAppointment sa : saList){
            woIdSet.add(sa.ParentRecordId);
            accIdSet.add(sa.AccountId);
        }

        List<WorkOrder> woList = [SELECT id, WorkTypeId, WorkOrderNumber, LineItemCount FROM WorkOrder WHERE id in : woIdSet];
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(woList);

        List<Account> accList = [SELECT id, Name FROM Account WHERE id in : accIdSet];
        Map<Id, Account> accMap = new Map<Id, Account>(accList);

        

        Map<Id, Id> srToUserMap = new Map<Id, Id>();
        for(ServiceResource sr : srList){
            srToUserMap.put(sr.id, sr.RelatedRecordId);
        }

        Id user;
        Id sa;
        String message;

        for (AssignedResource ar : arList){
            if(saMap.get(ar.ServiceAppointmentId) != null && accMap.get(saMap.get(ar.ServiceAppointmentId).AccountId) != null && woMap.get(saMap.get(ar.ServiceAppointmentId).ParentRecordId) != null){
                user = srToUserMap.get(ar.ServiceResourceId);
                sa = ar.ServiceAppointmentId;
                message = ' '+ notification + '\nAccount: ' + accMap.get(saMap.get(ar.ServiceAppointmentId).AccountId).Name + '\nLine Items: ' + woMap.get(saMap.get(ar.ServiceAppointmentId).ParentRecordId).LineItemCount + '\nDue Date: ' + samap.get(ar.ServiceAppointmentId).DueDate; 
                System.debug(message);
                //account name: accMap.get(saMap.get(ar.ServiceAppointmentId).AccountId).Name
                //line item count: woMap.get(saMap.get(ar.ServiceAppointmentId).ParentRecordId).LineItemCount
                //due date: samap.get(ar.ServiceAppointmentId).DueDate 
                chatterUtility.mentionTextRecordPost(user, sa, message);
            }
        } 

    }


    public static void messageAppointedResource(List<ServiceAppointment> saList, String notification){


        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>(saList);
        system.debug('saMap: ' + saMap);
        List<AssignedResource> arList = [SELECT id, ServiceResourceId, ServiceAppointmentId FROM AssignedResource WHERE ServiceAppointmentId in : saMap.keySet()];
        system.debug('arList: ' + arList);

        messageAppointedResource(arList, notification);
        
        // //Navigate to all the needed objects for their fields
        // Set<Id> srIdSet = new Set<Id>();
        // for (AssignedResource ar : arList){
        //     srIdSet.add(ar.ServiceResourceId);
        // }
        
        // list<ServiceResource> srList = [SELECT id, RelatedRecordId, CreatedDate FROM ServiceResource WHERE id in :srIdSet];
        // Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>(srList);


        // Set<Id> woIdSet = new Set<Id>();
        // Set<Id> accIdSet = new Set<Id>();
        // for (ServiceAppointment sa : saList){
        //     woIdSet.add(sa.ParentRecordId);
        //     accIdSet.add(sa.AccountId);
        // }

        // List<WorkOrder> woList = [SELECT id, WorkTypeId, WorkOrderNumber, LineItemCount FROM WorkOrder WHERE id in : woIdSet];
        // Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(woList);

        // List<Account> accList = [SELECT id, Name FROM Account WHERE id in : accIdSet];
        // Map<Id, Account> accMap = new Map<Id, Account>(accList);


        // Map<Id, Id> srToUserMap = new Map<Id, Id>();
        // for(ServiceResource sr : srList){
        //     srToUserMap.put(sr.id, sr.RelatedRecordId);
        // }

        // Id user;
        // Id sa;
        // String message;
        // system.debug('arList: ' + arList);
        // system.debug('srMap: ' + srMap);
        // system.debug('woMap: ' + woMap);
        // system.debug('accMap: ' + accMap);
        // system.debug('srToUserMap: ' + srToUserMap);

        // for (AssignedResource ar : arList){

        //     user = srToUserMap.get(ar.ServiceResourceId);
        //     sa = ar.ServiceAppointmentId;
        //     message = ' '+ notification + '\nAccount: ' + accMap.get(saMap.get(ar.ServiceAppointmentId).AccountId).Name + '\nLine Items: ' + woMap.get(saMap.get(ar.ServiceAppointmentId).ParentRecordId).LineItemCount + '\nDue Date: ' + samap.get(ar.ServiceAppointmentId).DueDate; 
        //     //account name: accMap.get(saMap.get(ar.ServiceAppointmentId).AccountId).Name
        //     //line item count: woMap.get(saMap.get(ar.ServiceAppointmentId).ParentRecordId).LineItemCount
        //     //created date: 

        //     system.debug(message);

        //     chatterUtility.mentionTextRecordPost(user, sa, message);
        // } 

    }*/

    // This is the negative of the FSL Beta class, it will return true if you should use old logic
    /*public static Boolean betaCheck(List<AssignedResource> arList){
        if( userBetaCheck ) {
            return false;
        } else if(!betaCodeFlag()){
            return true;
        }else{
            return isNotBeta(arList);
        }
    }
    // This is the negative of the FSL Beta class, it will return true if you should use old logic
    public static Boolean betaCheck(List<ServiceAppointment> saList){
        if( userBetaCheck ) {
            return false;
        } else if(!betaCodeFlag()){
            return true;
        }else{
            return isNotBeta(saList);
        }
    }*/

    /*public static void assignmentMessage(List<AssignedResource> arList){
        String message ='You are the assigned resource for a service appointment. ';
        if(betaCheck(arList)){
            messageAppointedResource(arList, message);
        }
    }*/
    /*public static void assignmentMessage(List<ServiceAppointment> saList){
        String message ='You are the assigned resource for a service appointment. ';
        if(betaCheck(saList)){
            messageAppointedResource(saList, message);
        }
    }*/


    // public static void canceledMessage(List<AssignedResource> arList){
    //     String message = 'Your service appointment has been canceled.';
    //     if(betaCheck(arList)){
    //         messageAppointedResource(arList, message);
    //     }
    // }
    // public static void canceledMessage(List<ServiceAppointment> saList){
    //     String message = 'Your service appointment has been canceled.';
    //     if(betaCheck(saList)){
    //         messageAppointedResource(saList, message);
    //     }
    // }


    // public static void onHoldMessge(List<AssignedResource> arList){
    //     String message = 'Your service appointment is on hold.';
    //     if(betaCheck(arList)){
    //         messageAppointedResource(arList, message);
    //     }       
    // }
    // public static void onHoldMessge(List<ServiceAppointment> saList){
    //     String message = 'Your service appointment is on hold.';
    //     if(betaCheck(saList)){
    //         messageAppointedResource(saList, message);
    //     }
    // }


    // public static void unOnHoldMessage(List<AssignedResource> arList){
    //     String message = 'Your service appointment is no longer on hold.';
    //     if(betaCheck(arList)){
    //         messageAppointedResource(arList, message);
    //     }        
    // }
    // public static void unOnHoldMessage(List<ServiceAppointment> saList){
    //     String message = 'Your service appointment is no longer on hold.';
    //     if(betaCheck(saList)){
    //         messageAppointedResource(saList, message);
    //     }
    // }

}