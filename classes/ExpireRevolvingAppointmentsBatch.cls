// Job is scheduled to run before optimization, on the current day - As in, scheduled to run in the late evening
global class ExpireRevolvingAppointmentsBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    // Query related variables
    public static final String STATUS_CHANGE {
        get {
            if ( STATUS_CHANGE == null ) {
                Salesforce_Setting__mdt var = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Revolving Appointment Expiration' LIMIT 1 ];
                STATUS_CHANGE = var.Value__c;
            }
            return STATUS_CHANGE;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select Status, ParentRecordId from ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c in (\'inspection\', \'verification\', \'true360\') AND status in (\'New\', \'Scheduled\') AND DueDate <= TODAY AND Work_Order__r.Occurrence__c != null';
        // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        ExpireRevolvingAppointmentsBatch saradb = new ExpireRevolvingAppointmentsBatch();
        //batch size of 100
        // Database.executeBatch(saradb, 100);
        //Temporarily setting batch size to 1 as we debug an issue with splunk logging failing
        Database.executeBatch(saradb, 1);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){

        //batch process
        List<Id> workOrderIdLst = new List<Id>();
        for (ServiceAppointment sa : scope) {
            sa.Status = STATUS_CHANGE;
        }

        // update all Service Appointment records
        Database.SaveResult[] mesgList = Database.update(scope, false);
        for ( Integer position = 0; position < mesgList.size(); position++ ) {
            Database.SaveResult saveRecord = mesgList[position];
            ServiceAppointment serviceAppointmentRec = scope[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(serviceAppointmentRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { system.debug( saveRecord.getErrors()[0].message ); returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( serviceAppointmentRec.Id );
                workOrderIdLst.add( serviceAppointmentRec.ParentRecordId );
            }
        }

        // Only touch work orders of Service Appointments without update issues
        if ( !workOrderIdLst.isEmpty() ) {
            List<WorkOrder> woLst = [ SELECT Id, Status FROM WorkOrder WHERE Id IN :workOrderIdLst ];
            for ( WorkOrder woRec : woLst ) {
                woRec.Status = STATUS_CHANGE;
            }

            // update records
            mesgList = Database.update(woLst, false);
            for ( Integer position = 0; position < mesgList.size(); position++ ) {
                Database.SaveResult saveRecord = mesgList[position];
                WorkOrder workRec = woLst[position];

                if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                    returnInfo.errorReturnLst.add( JSON.serialize( workRec ) );
                    if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
                } else {
                    returnInfo.successfulReturnSet.add( workRec.Id );
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'ExpireRevolvingAppointmentsBatch', ACVUtility.currentLineNumber(),
            'ExpireRevolvingAppointmentsBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment, Work Order' }
        );
    }
}