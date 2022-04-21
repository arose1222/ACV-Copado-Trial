/**
 * @description Batch class that purges Honda work orders, service appointments, and work order line items
 * @author Adam Richbart
 * @since 02/24/2022
 * @group Inspector Dispatch
 */
global class HondaPurgeBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public static final String HONDA_DEALER_ID {
        get {
            if ( HONDA_DEALER_ID == null ) {
                Salesforce_Setting__mdt dealerId = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Honda Dealer Id' LIMIT 1 ];
                HONDA_DEALER_ID = dealerId.Value__c;
            }
            return HONDA_DEALER_ID;
        }
        set;
    }

    public static final Integer PURGE_RANGE {
        get {
            if ( PURGE_RANGE == null ) {
                Salesforce_Setting__mdt range = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Honda Purge Range' LIMIT 1 ];
                PURGE_RANGE = Integer.valueOf( range.Value__c );
            }
            return PURGE_RANGE;
        }
        set;
    }

    public static final Date DATE_NUMDAYSOUT {
        get {
            return System.Today().addDays(-PURGE_RANGE);
        }
        set;
    }
    
    public static final String QUERY {
        get {
            return 'SELECT Id, Status, ' +
            '(SELECT Id, Status FROM ServiceAppointments), ' +
            '(SELECT Id, Status FROM WorkOrderLineItems WHERE Status != \'Canceled\') ' +
            'FROM WorkOrder ' +
            'WHERE Account.Dealership_Id__c =: HONDA_DEALER_ID ' +
            'AND WorkType.Work_Type_Unique_ID__c = \'dealer\' ' +
            'AND Id IN (SELECT Work_Order__c FROM ServiceAppointment WHERE EarliestStartTime <=: DATE_NUMDAYSOUT AND Status NOT IN (\'Canceled\', \'Completed\', \'Expired\' ))';
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY);
    }

    public override void executeScheduledLogic() {
        // scheduling
        HondaPurgeBatch HondaPurgeBatch = new HondaPurgeBatch();
        Database.executeBatch(HondaPurgeBatch, 200);
    }

    //This method will move all the children service appointments and work order line items from the work order
    //list into the passed in service appointment and woli lists. Additionally this method sets all records to a canceled status
    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-541
     */
    public static void cancelAndSeparateAllRecords(List<ServiceAppointment> serviceAppointmentList, List<WorkOrderLineItem> woliList, List<WorkOrder> workOrderList){
        for(WorkOrder workOrder : workOrderList){
            workOrder.Status = 'Canceled';
            for(ServiceAppointment serviceAppt: workOrder.ServiceAppointments){
                serviceAppt.Status = 'Canceled';
                serviceAppointmentList.add(serviceAppt);
            }
            for(WorkOrderLineItem woli : workOrder.WorkOrderLineItems){
                woli.Status = 'Canceled';
                woliList.add(woli);
            }
        }
    }

    // take a Batch return object and a list of save results and load up the batch return with the results
    // if there is a save result that failed, serialize the record and later in the class, send it to splunk
    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-541
     */
    public static void storeSaveResults(BatchUtilityClass.BatchReturn batchReturn, Database.SaveResult[] sObjectUpdateResultList, List<SObject> sObjectList){
        for ( Integer position = 0; position < sObjectUpdateResultList.size(); position++ ) {
            Database.SaveResult saveRecord = sObjectUpdateResultList[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                batchReturn.errorReturnLst.add( JSON.serialize(sObjectList[position] ) );
                if ( !saveRecord.getErrors().isEmpty() ) { batchReturn.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                batchReturn.successfulReturnSet.add( sObjectList[position].Id );
            }
        }
    }

    /**
     * @see https://acvauctions.atlassian.net/jira/software/projects/SI/boards/299?selectedIssue=SI-541
     */
    global void execute(Database.BatchableContext bc, List<WorkOrder> scope){
        List<ServiceAppointment> serviceAppointmentsToUpdate = new List<ServiceAppointment>();
        List<WorkOrderLineItem> workOrderLineItemsToUpdate = new List<WorkOrderLineItem>();

        cancelAndSeparateAllRecords(serviceAppointmentsToUpdate, workOrderLineItemsToUpdate, scope);

        // Update Service Appointments
        storeSaveResults(returnInfo, Database.update(serviceAppointmentsToUpdate), serviceAppointmentsToUpdate);

        // Update Work Orders
        storeSaveResults(returnInfo, Database.update(scope), scope);

        // Update Work Order Line Items
        storeSaveResults(returnInfo, Database.update(workOrderLineItemsToUpdate), workOrderLineItemsToUpdate);
    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'HondaPurgeBatch', ACVUtility.currentLineNumber(),
            'HondaPurgeBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment', 'Work Order', 'Work Order Line Item' }
        );
    }
}