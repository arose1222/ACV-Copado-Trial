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

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Date Date_NumDaysOut = System.Today().addDays(-PURGE_RANGE);

        String query = 'SELECT Id, Status, ' +
                            '(SELECT Id, Status FROM ServiceAppointments), ' +
                            '(SELECT Id, Status FROM WorkOrderLineItems WHERE Status != \'Canceled\') ' +
                       'FROM WorkOrder ' +
                       'WHERE Account.Dealership_Id__c = :HONDA_DEALER_ID ' +
                       'AND WorkType.Work_Type_Unique_ID__c = \'dealer\' ' +
                       'AND Id IN (SELECT Work_Order__c FROM ServiceAppointment WHERE EarliestStartTime <= :Date_NumDaysOut AND Status NOT IN (\'Canceled\', \'Completed\', \'Expired\' ))';

        // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        HondaPurgeBatch HondaPurgeBatch = new HondaPurgeBatch();
        Database.executeBatch(HondaPurgeBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<WorkOrder> scope){
        //batch process
        List<ServiceAppointment> serviceAppointmentsToUpdate = new List<ServiceAppointment>();
        List<WorkOrderLineItem> workOrderLineItemsToUpdate = new List<WorkOrderLineItem>();

        for(WorkOrder workOrder : scope){
            workOrder.Status = 'Canceled';
            for(ServiceAppointment serviceAppt: workOrder.ServiceAppointments){
                serviceAppt.Status = 'Canceled';
                serviceAppointmentsToUpdate.add(serviceAppt);
            }
            for(WorkOrderLineItem woli : workOrder.WorkOrderLineItems){
                woli.Status = 'Canceled';
                workOrderLineItemsToUpdate.add(woli);
            }
        }

        // Update Service Appointments
        Database.SaveResult[] serviceApptMesgList = Database.update(serviceAppointmentsToUpdate, false);

        for ( Integer position = 0; position < serviceApptMesgList.size(); position++ ) {
            Database.SaveResult saveRecord = serviceApptMesgList[position];
            ServiceAppointment serviceAppointmentRec = serviceAppointmentsToUpdate[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(serviceAppointmentRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( serviceAppointmentRec.Id );
            }
        }

        // Update Work Orders
        Database.SaveResult[] workOrderMesgList = Database.update(scope, false);

        for ( Integer position = 0; position < workOrderMesgList.size(); position++ ) {
            Database.SaveResult saveRecord = workOrderMesgList[position];
            WorkOrder workOrderRec = scope[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(workOrderRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( workOrderRec.Id );
            }
        }

        // Update Work Order Line Items
        Database.SaveResult[] workOrderLineItemMesgList = Database.update(workOrderLineItemsToUpdate, false);

        for ( Integer position = 0; position < workOrderLineItemMesgList.size(); position++ ) {
            Database.SaveResult saveRecord = workOrderLineItemMesgList[position];
            WorkOrderLineItem workOrderLineItemRec = workOrderLineItemsToUpdate[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(workOrderLineItemRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( workOrderLineItemRec.Id );
            }
        }
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