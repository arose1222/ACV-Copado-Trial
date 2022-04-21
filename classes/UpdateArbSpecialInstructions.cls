public class UpdateArbSpecialInstructions extends TriggerInterface {

    private static List<String> userIdList {
        get {
            if ( userIdList == null ) {
                userIdList = new List<String>();
                for ( FSL_Import_Manager_Special_Instructions__mdt imsiRec : [ SELECT Label, User_Id__c FROM FSL_Import_Manager_Special_Instructions__mdt WHERE Active__c = true ] ) {
                    userIdList.add(imsiRec.User_Id__c);
                }
            }
            return userIdList;
        }
        set;
    }

    public override void afterInsert( List<SObject> newList ) {

        Map<Id,WorkOrderLineItem> workOrderIdToWoliMap = new Map<Id,WorkOrderLineItem>();

        for (WorkOrderLineItem woli : (List<WorkOrderLineItem>) newList) {
            if(userIdList.contains(woli.createdbyId) && !String.isBlank(woli.Description)){
                workOrderIdToWoliMap.put(woli.workOrderId, woli);
            }
        }

        List<WorkOrder> workOrderUpdateList = new List<WorkOrder>();
        for(WorkOrder wo : [SELECT Id, Special_Instructions__c, createdbyId FROM WorkOrder WHERE Id IN :workOrderIdToWoliMap.keySet()]){
            if(userIdList.contains(wo.createdbyId) && String.isBlank(wo.Special_Instructions__c)){
                wo.Special_Instructions__c = workOrderIdToWoliMap.get(wo.Id)?.Description;
                workOrderUpdateList.add(wo);
            }
        }

        update workOrderUpdateList;

    }
}