public class AssignmentManagerVehicleUpdate extends TriggerInterface{

    private final static String STANDARD_INSPECTION = 'Standard Inspection';

    // public override void afterInsert(Map<Id, SObject> newMap){
    //     System.Debug(Trigger.newMap);
    //     System.debug(Trigger.oldMap);
    //     updateRelatedVehicleAndEvent(newMap.values());
    //     checkForReadyToLaunch(newMap.values(), null, FALSE);//(Map<Id, sObject>)new Map<Id,Condition_Report__c>(), FALSE);
    // }

    // public override void afterUpdate(Map<Id, SObject> newMap, Map<Id, SObject> oldMap){
    //     checkForReadyToLaunch(newMap.values(), oldMap, TRUE);
    // }

    // public static void updateRelatedVehicleAndEvent(List<sObject> triggerNew){
    //     List<Condition_Report__c> crList = (List<Condition_Report__c>)triggerNew;

    //     Map<String,Condition_Report__c> vinIdSet = new Map<String,Condition_Report__c>();
    //     for(Condition_Report__c cr :crList){
    //         system.debug(cr);
    //         if(!String.isBlank(cr.VIN__c)){
    //             vinIdSet.put(cr.VIN__c.toUpperCase(), cr);
    //         }
    //     }

    //     List<WorkOrderLineItem> vinUpdateList = new List<WorkOrderLineItem>();
    //     for(WorkOrderLineItem v :[SELECT Id, Status, VIN__c, Vehicle__c FROM WorkOrderLineItem WHERE VIN__c IN :vinIdSet.keySet() AND Status = 'New' AND WorkType.Name = :STANDARD_INSPECTION]){
    //         if(!String.isBlank(v.VIN__c)){
    //             v.Status = 'In Progress';
    //             v.Vehicle__c = vinIdSet.get(v.VIN__c.toUpperCase()).Vehicle__c;
    //             vinUpdateList.add(v);
    //         }
    //     }

    //     if(vinUpdateList.size() > 0){
    //         update vinUpdateList;
    //     }
    // }

    // public static void checkForReadyToLaunch(List<sObject> newList, Map<Id, sObject> oldMap, Boolean isUpdate){
    //     //List<sObject> triggerNew
    //     List<Condition_Report__c> crList = (List<Condition_Report__c>)newList;
    //     Map<Id, Condition_Report__c> oldCRMap = (Map<Id, Condition_Report__c>)oldMap;

    //     Map<String, Condition_Report__c> vinToCr = new Map<String, Condition_Report__c>();
    //     Map<String, Condition_Report__c> oldVinMap = new Map<String, Condition_Report__c>();
    //     if (isUpdate) {
    //         for(Condition_Report__c cr :crList){
    //             if(!String.isBlank(cr.VIN__c)){
    //                 vinToCr.put(cr.VIN__c.toUpperCase(), cr);
    //                 oldVinMap.put(cr.VIN__c.toUpperCase(), oldCRMap.get(cr.Id)); //???
    //             }
    //         }
    //     }
    //     else {
    //         for (Condition_Report__c cr : crList) {
    //             if(!String.isBlank(cr.VIN__c)){
    //                 vinToCr.put(cr.VIN__c.toUpperCase(), cr);
    //             }
    //         }
    //     }

    //     //Map<Id, Condition_Report__c> newCRMap = (Map<Id, Condition_Report__c>)newMap;
    //     //Map<Id, Condition_Report__c> oldCRMap = (Map<Id, Condition_Report__c>)oldMap;

    //     List<WorkOrderLineItem> vinUpdateList = new List<WorkOrderLineItem>();
    //     for(WorkOrderLineItem v :[SELECT Id, Status, Vin__c FROM WorkOrderLineItem WHERE Vin__c IN :vinToCr.keyset() AND WorkType.Name = :STANDARD_INSPECTION]){
    //         Boolean touched = false;
    //         if(!String.isBlank(v.VIN__c)){
    //             if (isUpdate && oldVinMap.get(v.VIN__c.toUpperCase()) != null) {
    //                 if(oldVinMap.get(v.VIN__c.toUpperCase()).CR_Doc_Complete__c != vinToCr.get(v.VIN__c.toUpperCase()).CR_Doc_Complete__c){
    //                     v.Status = 'Inspected';
    //                     touched = true;
    //                 }
    //                 else if(oldVinMap.get(v.VIN__c.toUpperCase()).CR_in_Review__c != vinToCr.get(v.VIN__c.toUpperCase()).CR_in_Review__c){
    //                     v.Status = 'Internal Review';
    //                     touched = true;
    //                 }
    //                 else if(oldVinMap.get(v.VIN__c.toUpperCase()).Awaiting_Floor_Price__c != vinToCr.get(v.VIN__c.toUpperCase()).Awaiting_Floor_Price__c){
    //                     v.Status = 'Awaiting Floor Price';
    //                     touched = true;
    //                 }
    //                 else if((oldVinMap.get(v.VIN__c.toUpperCase()).Floor_Price__c != vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c) && (vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c > 20 || vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c != 999999)){ //vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c != null &&
    //                     v.Status = 'Ready To Launch';
    //                     touched = true;
    //                 }
    //             }
    //             else if(vinToCr.get(v.VIN__c.toUpperCase()) != null) {
    //                 if (vinToCr.get(v.VIN__c.toUpperCase()).CR_Doc_Complete__c) {
    //                     v.Status = 'Inspected';
    //                     touched = true;
    //                 }
    //                 else if (vinToCr.get(v.VIN__c.toUpperCase()).CR_in_Review__c) {
    //                     v.Status = 'Internal Review';
    //                     touched = true;
    //                 }
    //                 else if (vinToCr.get(v.VIN__c.toUpperCase()).Awaiting_Floor_Price__c) {
    //                     v.Status = 'Awaiting Floor Price';
    //                     touched = true;
    //                 }
    //                 else if (vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c != null && (vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c > 20 || vinToCr.get(v.VIN__c.toUpperCase()).Floor_Price__c != 999999)) {
    //                     v.Status = 'Ready To Launch';
    //                     touched = true;
    //                 }
    //             }
    //         }
    //         if(touched){
    //             vinUpdateList.add(v);
    //         }
    //     }

    //     if(vinUpdateList.size() > 0){
    //         system.debug(vinUpdateList);
    //         update vinUpdateList;
    //     }
    // }


}