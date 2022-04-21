public class WorkOrderLineItemUtility {
    /*
    *  Process Parent Status Method Fields
    */
    private static final String IN_PROGRESS_STATUS = 'InProgress';
    private static final String NEW_STATUS = 'New';
    private static final String COMPLETE_STATUS = 'Completed';
    private static final String ON_HOLD_STATUS = 'On Hold';
    private static final String CANCELED_STATUS = 'Canceled';
    private static final String CANNOT_COMPLETE_STATUS = 'Cannot Complete';

    private static final String CANNOT_COMPLETE_STATUS_CATEGORY = 'CannotComplete';
    private static final String ON_HOLD_STATUS_CATEGORY = 'OnHold';
    private static final String IN_PROGRESS = 'In Progress'; // Needed because the Status is not the same as the Status Category

     public static Map<String, WorkType> availableWorkTypes {
        get {
            if ( availableWorkTypes == null ) {
                availableWorkTypes = FSLWorkProcessUtility.availableWTMap;
            }
            return availableWorkTypes;
        }
        set;
    }

    private static Boolean checkWorkType( Id recordWorkTypeId, String workTypeUniqueName ) {
        return availableWorkTypes.get( workTypeUniqueName ) != null && recordWorkTypeId == availableWorkTypes.get( workTypeUniqueName ).Id;
    }

    private static Boolean checkWorkTypeId( Id workTypeId ) {
        if( workTypeId != null){
            if ( checkWorkType( workTypeId, 'verification' ) ) {
                return true;
            }
            if ( checkWorkType( workTypeId, 'promo work' ) ) {
                return true;
            }
            if ( FSLWorkProcessUtility.availableWTGMap != null && FSLWorkProcessUtility.availableWTGMap.get( 'asi' ) != null ) {
                for ( String workTypeUniqueName : FSLWorkProcessUtility.availableWTGMap.get( 'asi' ) ) {
                    if ( checkWorkType( workTypeId, workTypeUniqueName) ) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private static Boolean containsProperWorkTypes(List<WorkOrder> woList){
        for(WorkOrder wo : woList){
            return checkWorkTypeId( wo.WorkTypeId );
        }
        return false;
    }

    private static Boolean containsProperWorkTypes(List<ServiceAppointment> saList){
        for(ServiceAppointment sa : saList){
            return checkWorkTypeId( sa.WorkTypeId );
        }
        return false;
    }

    /**
     * processParentStatus
     *  GIVEN a set of Work Order Ids
     *  WHEN one or more work order items are updated
     *  THEN identify and roll-up a status update to the Work Order
     *
     * @param  workOrderIdSet - A set of Salesforce Ids that belong to modified Work Order Line Items
     */
    public static void processParentStatus( Set<Id> workOrderIdSet ) {
        if ( !workOrderIdSet.isEmpty() ) {
            List<WorkOrder> workOrderLst = [ SELECT Id, StatusCategory, ServiceTerritoryId, Status, WorkTypeId, (SELECT Id, Bundled__c FROM ServiceAppointments LIMIT 1), (SELECT Id, StatusCategory FROM WorkOrderLineItems) FROM WorkOrder WHERE Id IN :workOrderIdSet ];

            if( containsProperWorkTypes(workOrderLst) ) {
                List<WorkOrder> workOrderUpdateLst = new List<WorkOrder>();
                Boolean newFlag;
                Boolean completedFlag;
                Boolean onHoldFlag;
                Boolean canceledFlag;
                Boolean inProgressFlag;
                Boolean cannotCompleteFlag;

                //workOrder status map for service appointment update
                Map<Id, String> workOrderStatusMap = new Map<Id, String>();
                for ( WorkOrder workRecord : workOrderLst ) {
                    newFlag = FALSE;
                    completedFlag = FALSE;
                    onHoldFlag = FALSE;
                    inProgressFlag = FALSE;
                    canceledFlag = FALSE;
                    cannotCompleteFlag = FALSE;

                    if (workRecord.ServiceAppointments[0]?.Bundled__c == true) {
                        continue;
                    }

                    for ( WorkOrderLineItem workItemRecord : workRecord.WorkOrderLineItems ) {
                        /* Flag Logic:
                        *   If any Line Item status is on hold, the work order is on hold (on hold is higher priority than in progress)
                        *   If Line Items have a mixture of New and Completed then the work order is in progress
                        *   If any Line Item status is In Progress, then the work order is in progress
                        *   If all Line Items have a status of new, then the Work Order is new
                        *   If all Lne Items have a status of complete, then the Work Order is complete
                        *   If all Line Items have a status of canceled then the work order is canceled
                        *   If one or multiple line items (but not all) have a canceled status, the canceled status should be ignored
                        */
                        if ( workItemRecord.StatusCategory == ON_HOLD_STATUS_CATEGORY){
                            onHoldFlag = TRUE;
                        } else if ( workItemRecord.StatusCategory == IN_PROGRESS_STATUS) {
                            inProgressFlag = TRUE;
                        } else if ( workItemRecord.StatusCategory == COMPLETE_STATUS) {
                            completedFlag = TRUE;
                        } else if ( workItemRecord.StatusCategory == NEW_STATUS) {
                            newFlag = TRUE;
                        } else if ( workItemRecord.StatusCategory == CANCELED_STATUS){
                            canceledFlag = TRUE;
                        } else if ( workItemRecord.StatusCategory == CANNOT_COMPLETE_STATUS_CATEGORY ) {
                            cannotCompleteFlag = TRUE;
                        }
                    }
                    //Only push the status to service appointment if the status is canceled
                    if (onHoldFlag){
                        workRecord.Status = ON_HOLD_STATUS;
                        workOrderUpdateLst.add(workRecord);

                    }
                    else if(inProgressFlag){
                        workRecord.status = IN_PROGRESS;
                        workOrderUpdateLst.add(workRecord);

                    }
                    else if(newFlag && ( completedFlag || cannotCompleteFlag ) ){
                        workRecord.status = IN_PROGRESS;
                        workOrderUpdateLst.add(workRecord);
                    }
                    else if(newFlag){
                        // workRecord.status = NEW_STATUS;
                        // workOrderUpdateLst.add(workRecord);
                        // workOrderStatusMap.put(workRecord.id, workRecord.status);
                    }
                    else if(completedFlag){
                        workRecord.status = COMPLETE_STATUS;
                        workOrderUpdateLst.add(workRecord);
                        workOrderStatusMap.put( workRecord.Id, workRecord.status );
                    }
                    else if(canceledFlag){
                        workRecord.status = CANCELED_STATUS;
                        workOrderUpdateLst.add(workRecord);
                        workOrderStatusMap.put(workRecord.id, workRecord.status);
                    } else if ( cannotCompleteFlag ) {
                        workRecord.status = CANNOT_COMPLETE_STATUS;
                        workOrderUpdateLst.add(workRecord);
                        workOrderStatusMap.put(workRecord.id, workRecord.status);
                    }
                }
                if ( !workOrderUpdateLst.isEmpty() ) {
                    processServiceAppointmentStatus(workOrderStatusMap);
                    update workOrderUpdateLst;
                }
            }
        }
    }

    private static void processServiceAppointmentStatus(Map<Id, String> woStatusMap){
        //construct map in above for loop
        //build a map of work order ids to statuses
        //build a list of service appointments that have parents in the map above
        List<ServiceAppointment> saList = new list<ServiceAppointment>();
        saList = [SELECT Id, ActualStartTime, ActualEndTime, SchedEndTime, SchedStartTime, WorkType.EstimatedDuration, Status, ParentRecordId, WorkTypeId, Allow_Change_From_Flow__c FROM ServiceAppointment WHERE ParentRecordId IN : woStatusMap.keySet()];
        if(containsProperWorkTypes(saList)){
            // assign mmatching statuses for every service appointment that was in the list

            for (ServiceAppointment sa : saList){

                if (sa.Allow_Change_From_Flow__c == TRUE) {
                    sa.Allow_Change_From_Flow__c = FALSE;
                } else {
                    sa.Allow_Change_From_Flow__c = TRUE;
                }

                //No need to go further if the status is not changed.
                if(sa.Status == woStatusMap.get(sa.ParentRecordId)){continue;}

                sa.Status = woStatusMap.get(sa.ParentRecordId);

                if ( woStatusMap.get(sa.ParentRecordId) == CANCELED_STATUS ) {
                    sa.Completed_Canceled_Notes__c = 'All Work Order Line Items were cancelled for this appointment, so it has been automatically updated to reflect this';
                } else if ( woStatusMap.get(sa.ParentRecordId) == CANNOT_COMPLETE_STATUS ) {
                    sa.Completed_Canceled_Notes__c = 'All Work Order Line Items were marked as cannot complete for this appointment, so it has been automatically updated to reflect this';
                    sa.Cannot_Complete_Reason__c = 'Other';
                } else if ( woStatusMap.get(sa.ParentRecordId) == COMPLETE_STATUS ) {
                    DateTime now = DateTime.now();
                    if ( sa.ActualStartTime == null ) { sa.ActualStartTime = now.addMinutes( Integer.valueOf( ( (-1) * sa.WorkType.EstimatedDuration ) ) ); }
                    if ( sa.ActualEndTime == null ) { sa.ActualEndTime = now; }

                    // if ( sa.SchedStartTime == null ) { sa.SchedStartTime = now.addMinutes( Integer.valueOf( ( (-1) * sa.WorkType.EstimatedDuration ) ) ); }
                    // if ( sa.SchedEndTime == null ) { sa.SchedEndTime = now; }
                    sa.SchedStartTime = sa.ActualStartTime;
                    sa.SchedEndTime   = sa.ActualEndTime;
                }

            }

            update saList;
        }
    }
}