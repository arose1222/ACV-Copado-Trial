/**
 * @description Handler class for WOLI
 * @author Isaiah Cummins, Traction on Demand
 * @date 9/19/2019
 *
 */

public class trac_WorkOrderLineItemHandler extends TriggerInterface{
    private static final String STATUS_NEW = 'New';
    private static final String DURATION_TYPE_MINUTES = 'Minutes';
    private static final String TYPE_ASSET_VERIFICATION = 'Asset Verification';
    private static final String TYPE_INSPECTION = 'Standard Inspection';

    public override void afterInsert(Map<Id, SObject> newMap){
        filterAndUpdateRollupDurations((List<WorkOrderLineItem>)newMap.values());
    }

    public override void afterDelete(List<SObject> oldList){
        filterAndUpdateRollupDurations((List<WorkOrderLineItem>)oldList);
    }

    // if new/deleted line items have a duration > 0, need to recalculate Work Order and Service Appointment durations
    public static void filterAndUpdateRollupDurations(List<WorkOrderLineItem> workOrderLineItems) {
        Set<Id> workOrderIds = new Set<Id>();
        for(WorkOrderLineItem lineItem : workOrderLineItems) {
            if(lineItem.DurationInMinutes != 0 && FSLWorkProcessUtility.workTypeIdMap.get( lineItem.WorkTypeId ).Work_Type_Unique_ID__c != 'promo work' ) { // Cannot run on Promo Work Line items due to work type = 30 minutes per line item, but each line item is only a 5 minute activity
                workOrderIds.add(lineItem.WorkOrderId);
            }
        }
        if(!workOrderIds.isEmpty()) {
            recalculateWorkOrderAppointmentDuration(getWorkOrderMap(workOrderIds));
        }
    }

    /**
 * @description Set WOLI info for WO's and Service appointments
 * @author Isaiah Cummins
 * @date 9/19/2019
 *
 */
    private static void recalculateWorkOrderAppointmentDuration(Map<Id, WorkOrder> workOrderMap) {
        Map<Id, Set<ServiceAppointment>> serviceAppointmentMap = mapWorkOrdersToServiceAppointments(workOrderMap.keySet());
        Map<Id, WorkOrderInfo> workOrderInfoMap = setDurationsAndWorkTypeCounts(workOrderMap.keySet());
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();

        for (WorkOrder workOrder : workOrderMap.values()) {
            // if there are currently line items
            if(workOrderInfoMap.containsKey(workOrder.Id)) {
                WorkOrderInfo workOrderInfo = workOrderInfoMap.get(workOrder.Id);
                workOrder.Duration = workOrderInfo.duration;
                workOrder.DurationType = DURATION_TYPE_MINUTES;
                // loop through service appointments and stamp duration
                if(serviceAppointmentMap.containsKey(workOrder.Id)) {
                    for(ServiceAppointment serviceAppointment : serviceAppointmentMap.get(workOrder.Id)) {
                        serviceAppointment.Duration = workOrderInfo.duration;
                        serviceAppointment.DurationType = DURATION_TYPE_MINUTES;
                        appointmentsToUpdate.add(serviceAppointment);
                    }
                }
                // Set number of vehicles with WorkType.Name = Asset Verification
                workOrder.Asset_Verification_Number_of_Vehicles__c = workOrderInfo.assetCount;

                // Set number of vehicles with WorkType.Name = Standard Inspection
                    workOrder.Inspection_Number_of_Vehicles__c = workOrderInfo.inspectionCount;
                //if there are no line items
            } else {
                workOrder.Duration = workOrder.WorkType.EstimatedDuration;
                workOrder.DurationType = workOrder.WorkType.DurationType;
                workOrder.Asset_Verification_Number_of_Vehicles__c = 0;
                workOrder.Inspection_Number_of_Vehicles__c = 0;
                if(serviceAppointmentMap.containsKey(workOrder.Id)) {
                    for(ServiceAppointment serviceAppointment : serviceAppointmentMap.get(workOrder.Id)) {
                        serviceAppointment.Duration = 0;
                        appointmentsToUpdate.add(serviceAppointment);
                    }
                }
            }
        }
        // update work orders
        update workOrderMap.values();
        // update Service appointments
        if(!appointmentsToUpdate.isEmpty()) {
            update appointmentsToUpdate;
        }
    }

    private static Map<Id, Set<ServiceAppointment>> mapWorkOrdersToServiceAppointments(Set<Id> workOrderIds) {
        // get service appointments
        List<ServiceAppointment> serviceAppointments = [
                SELECT Id, Work_Order__c, Duration, DurationType
                FROM ServiceAppointment
                WHERE Work_Order__c IN :workOrderIds AND Status = :STATUS_NEW AND Work_Order__c != NULL
        ];

        // possibility of multiple 'New' Appointments, so need to add it to a set
        Map<Id, Set<ServiceAppointment>> workOrderIdToAppointments = new Map<Id, Set<ServiceAppointment>>();
        for (ServiceAppointment serviceAppointment : serviceAppointments) {
            if(!workOrderIdToAppointments.containsKey(serviceAppointment.Work_Order__c)) {
                workOrderIdToAppointments.put(serviceAppointment.Work_Order__c, new Set<ServiceAppointment>());
            }
            workOrderIdToAppointments.get(serviceAppointment.Work_Order__c).add(serviceAppointment);
        }

        return workOrderIdToAppointments;
    }

    /**
     * @description Get and sum/count WOLI info
     * @author Isaiah Cummins
     * @date 9/19/2019
     *
     */

    private static Map<Id, WorkOrderInfo> setDurationsAndWorkTypeCounts(Set<Id> workOrderIds) {
        Map<Id, WorkOrderInfo> workOrderInfoMap = new Map<Id, WorkOrderInfo>();

        List<WorkOrderLineItem> workOrderLineItems = [
                SELECT Id, WorkType.Name, WorkOrderId, DurationInMinutes, WorkTypeId
                FROM WorkOrderLineItem
                WHERE WorkOrderId IN :workOrderIds
        ];
        Map<Id, List<WorkOrderLineItem>> workOrderIdToLineItems = new Map<Id, List<WorkOrderLineItem>>();

        for (WorkOrderLineItem workOrderLineItem: workOrderLineItems) {
            Id workOrderId = workOrderLineItem.WorkOrderId;
            if(!workOrderIdToLineItems.containsKey(workOrderId)) {
                workOrderIdToLineItems.put(workOrderId, new List<WorkOrderLineItem>());
            }
            workOrderIdToLineItems.get(workOrderId).add(workOrderLineItem);
        }

        for(Id workOrderId : workOrderIdToLineItems.keySet()) {
            Double duration = 0;
            Integer assetCount = 0;
            Integer inspectionCount = 0;
            List<WorkOrderLineItem> lineItems = workOrderIdToLineItems.get(workOrderId);

            for(WorkOrderLineItem lineItem : lineItems) {
                duration += lineItem.DurationInMinutes;
                if(lineItem.WorkTypeId != null) {
                    if (lineItem.WorkType.Name == TYPE_ASSET_VERIFICATION) {
                        assetCount++;
                    } else if (lineItem.WorkType.Name == TYPE_INSPECTION) {
                        inspectionCount++;
                    }
                }
            }
            
            WorkOrderInfo workOrderInfo = new WorkOrderInfo();
            workOrderInfo.duration = duration;
            workOrderInfo.assetCount = assetCount;
            workOrderInfo.inspectionCount = inspectionCount;

            workOrderInfoMap.put(workOrderId, workOrderInfo);
        }
        return workOrderInfoMap;

    }
    // get associated work orders to WOLIs
    private static Map<Id, WorkOrder> getWorkOrderMap(Set<Id> workOrderIds) {
        return new Map<Id, WorkOrder>([
                SELECT Id, Duration, DurationType, WorkType.EstimatedDuration , WorkType.DurationType
                FROM WorkOrder
                WHERE Id IN :workOrderIds AND Status = :STATUS_NEW

        ]);
    }
    public class WorkOrderInfo {
        public Double duration{get; set;}
        public Integer assetCount{get; set;}
        public Integer inspectionCount{get; set;}
    }
}