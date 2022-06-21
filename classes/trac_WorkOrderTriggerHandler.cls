/**
 *  * Created by zdeng on 10/2/2019.
  *  */
public class trac_WorkOrderTriggerHandler extends TriggerInterface{
    private final static String QUEUE = 'Queue';
    private final static String STATUS_COMPLETED = 'Completed';
    private final static String STATUS_ASSIGNED = 'Assigned';

    public override void beforeInsert(List<SObject> newList){
        assignWorkOrderToQueue((List<WorkOrder>)newList);
        //assignWorkTypeFromQuickction((List<WorkOrder>)newList);
        fillDurationFromWorkType((List<WorkOrder>)newList);
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        getWorkOrdersWithChangedVehicleNumbers((Map<Id,WorkOrder>)oldMap, (Map<Id,WorkOrder>)newMap);
        filterAndUpdateTimeStamps((Map<Id,WorkOrder>)oldMap, (Map<Id,WorkOrder>)newMap);
    }

    public static void getWorkOrdersWithChangedVehicleNumbers(Map<Id, WorkOrder> oldMap, Map<Id, WorkOrder> newMap){
        Set<Id> changedNewWorkOrdersWithVehicles = new Set<Id>();
        Set<Id> changedNewWorkOrdersWithNullVehicle = new Set<Id>();

        for(Id newWorkOrderId : newMap.keySet()) {
            WorkOrder newWorkOrder = newMap.get(newWorkOrderId);
            if (newWorkOrder.Inspection_Number_of_Vehicles__c != oldMap.get(newWorkOrderId).Inspection_Number_of_Vehicles__c &&
                FSLWorkProcessUtility.workTypeIdMap.get( newWorkOrder.WorkTypeId ) != null && 
                FSLWorkProcessUtility.workTypeIdMap.get( newWorkOrder.WorkTypeId ).Respects_Number_of_Vehicles__c ) {
                if (newWorkOrder.Inspection_Number_of_Vehicles__c != null &&
                newWorkOrder.Inspection_Number_of_Vehicles__c != 0){
                    changedNewWorkOrdersWithVehicles.add(newWorkOrderId);
                } else {
                    changedNewWorkOrdersWithNullVehicle.add(newWorkOrderId);
                }
            }
        }

        if ( !changedNewWorkOrdersWithVehicles.isEmpty() || !changedNewWorkOrdersWithNullVehicle.isEmpty() ) {
            List<ServiceAppointment> ServiceAppWithVehicles = new List<ServiceAppointment>();
            List<ServiceAppointment> ServiceAppWithNullVehicle = new List<ServiceAppointment>();
            
            if ( !changedNewWorkOrdersWithVehicles.isEmpty() ) {
                ServiceAppWithVehicles =
                                        [SELECT Id, DurationType, Duration, Work_Order__c,
                                        Work_Order__r.WorkTypeId
                                        FROM ServiceAppointment
                                        WHERE Work_Order__c IN: changedNewWorkOrdersWithVehicles ];
            }
            if ( !changedNewWorkOrdersWithNullVehicle.isEmpty() ) {
                ServiceAppWithNullVehicle =
                                            [SELECT Id, DurationType, Duration,
                                                    Work_Order__r.WorkType.DurationType,
                                                    Work_Order__r.WorkType.EstimatedDuration
                                            FROM ServiceAppointment
                                            WHERE Work_Order__c IN: changedNewWorkOrdersWithNullVehicle ];
            }

            List<ServiceAppointment> serviceAppointmentsForUpdate = new List<ServiceAppointment>();
            for (ServiceAppointment sa : ServiceAppWithVehicles){
                sa.DurationType = 'Minutes';
                sa.Duration = FSLWorkProcessUtility.workTypeIdMap.get( sa.Work_Order__r.WorkTypeId ).DurationInMinutes * newMap.get(sa.Work_Order__c).Inspection_Number_of_Vehicles__c;
                serviceAppointmentsForUpdate.add(sa);
            }

            for (ServiceAppointment sa : ServiceAppWithNullVehicle){
                sa.DurationType = sa.Work_Order__r.WorkType.DurationType;
                sa.Duration = sa.Work_Order__r.WorkType.EstimatedDuration;
                serviceAppointmentsForUpdate.add(sa);

            }

            update serviceAppointmentsForUpdate;
        }
    }

    public static void fillDurationFromWorkType(List<WorkOrder> workOrders){
        //get work type list with default duration
        Map<Id, WorkType> workTypeMap = FSLWorkProcessUtility.workTypeIdMap;
        //convert all durations to minutes
        Map<Id, Decimal> workTypeDurations = new Map<Id, Decimal>();
        for(WorkType wt : workTypeMap.values()){
            if ( wt.durationType != null && wt.EstimatedDuration != null ) {
                if(wt.durationType == 'Hours'){
                    workTypeDurations.put(wt.id, wt.EstimatedDuration*60);
                }
                else{
                    workTypeDurations.put(wt.id, wt.EstimatedDuration);
                }
            }
        }

        for(WorkOrder wo : workOrders){
            if(wo.WorkTypeId != null && wo.Inspection_Number_of_Vehicles__c != null && workTypeDurations.get(wo.WorkTypeId) != null ){
                wo.durationType = 'Minutes';
                wo.duration = (workTypeDurations.get(wo.WorkTypeId) * wo.Inspection_Number_of_Vehicles__c);
            }
        }
    }

    public static void filterAndUpdateTimeStamps(Map<Id, WorkOrder> oldMap, Map<Id, WorkOrder> newMap) {
        List<WorkOrder> completedWorkOrdersToUpdate = new List<WorkOrder>();
        List<WorkOrder> assignedWorkOrdersToUpdate = new List<WorkOrder>();
        for(Id newWorkOrderId : newMap.keySet()) {
            if(newMap.get(newWorkOrderId).Status == STATUS_ASSIGNED && newMap.get(newWorkOrderId).Status != oldMap.get(newWorkOrderId).Status) {
                assignedWorkOrdersToUpdate.add(newMap.get(newWorkOrderId));
            }
            else if(newMap.get(newWorkOrderId).Status == STATUS_COMPLETED && newMap.get(newWorkOrderId).Status != oldMap.get(newWorkOrderId).Status) {
                completedWorkOrdersToUpdate.add(newMap.get(newWorkOrderId));
            }
        }
        if(!assignedWorkOrdersToUpdate.isEmpty()) {
            updateAssignedTimeStamp(assignedWorkOrdersToUpdate);
        }
        if(!completedWorkOrdersToUpdate.isEmpty()) {
            updateCompletedTimeStamp(completedWorkOrdersToUpdate);
        }
    }


    /*public static void assignWorkTypeFromQuickction(List<WorkOrder> wos) {
        try {
            WorkType FIELD_INSPECTION_WORKTYPE = [SELECT Id FROM WorkType WHERE Name = :tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION LIMIT 1];
            for (WorkOrder wo : wos) {
                if (wo.Created_From_Quick_Action__c && (wo.WorkTypeId == NULL || String.isBlank(wo.WorkTypeId))) {
                    wo.WorkTypeId = FIELD_INSPECTION_WORKTYPE.Id;
                }
            }
        }
        catch (Exception e) {}
    }*/


    public static void assignWorkOrderToQueue(List<WorkOrder> newWorkOrders) {
        Set<Id> serviceTerritoryIds = new Set<Id>();
        /* get service order Ids from trigger values */
        for(WorkOrder workOrder : newWorkOrders) {
            serviceTerritoryIds.add(workOrder.ServiceTerritoryId);
        }
        /* Get service orders and associated queues */
        Map<Id, ServiceTerritory> serviceTerritoryMap = getServiceTerritoryMap(serviceTerritoryIds);
        Set<String> serviceTerritoryNames = getServiceTerritoryNames(serviceTerritoryMap);
        Map<String, Id> queueNameToId = mapQueueNameToId(serviceTerritoryNames);
        /* assign owner if queue exists */
        for(WorkOrder workOrder : newWorkOrders) {
            if (serviceTerritoryMap.containsKey(workOrder.ServiceTerritoryId)) {
                if (queueNameToId.containsKey(serviceTerritoryMap.get(workOrder.ServiceTerritoryId).Name)) {
                    workOrder.OwnerId = queueNameToId.get(serviceTerritoryMap.get(workOrder.ServiceTerritoryId).Name);
                }
            }
        }
    }


    private static void updateAssignedTimeStamp(List<WorkOrder> workOrders) {
        for (WorkOrder workOrder : workOrders) {
            workOrder.Assigned_Date_Time__c = System.now();
        }
    }


    private static void updateCompletedTimeStamp(List<WorkOrder> workOrders) {
        for (WorkOrder workOrder : workOrders) {
            workOrder.Completed_Date_Time__c = System.now();
        }
    }


    private static Map<Id, ServiceTerritory> getServiceTerritoryMap(Set<Id> serviceIds) {
        return new Map<Id, ServiceTerritory>([
                SELECT Id, Name
                FROM ServiceTerritory
                WHERE Id IN :serviceIds
        ]);
    }


    private static Set<String> getServiceTerritoryNames(Map<Id, ServiceTerritory> serviceTerritoryMap) {
        Set<String> names = new Set<String>();
        for(ServiceTerritory serviceTerritory : serviceTerritoryMap.values()) {
            names.add(serviceTerritory.Name);
        }
        return names;
    }


    private static Map<String, Id> mapQueueNameToId(Set<String> serviceTerritoryNames) {
        List<Group> queues = [
                SELECT Id, Name
                FROM Group
                WHERE Name IN :serviceTerritoryNames AND Type = :QUEUE
        ];
        Map<String, Id> queueNameToId = new Map<String, Id>();
        for(Group queue : queues) {
            queueNameToId.put(queue.Name, queue.Id);
        }
        return queueNameToId;
    }
}