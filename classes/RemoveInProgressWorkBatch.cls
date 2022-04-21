global class RemoveInProgressWorkBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        query =  'SELECT Id, Assigned_Resource_Has_In_Progress_Work__c  ';
        query += 'FROM ServiceAppointment ';
        query += 'WHERE Assigned_Resource_Has_In_Progress_Work__c = true';
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        RemoveInProgressWorkBatch RemoveInProgressWorkBatch = new RemoveInProgressWorkBatch();
        Database.executeBatch(RemoveInProgressWorkBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        for (ServiceAppointment sa : scope) {
            sa.Assigned_Resource_Has_In_Progress_Work__c = false;
        }

        // update records
        Database.SaveResult[] mesgList = Database.update(scope, false);
        for ( Integer position = 0; position < mesgList.size(); position++ ) {
            Database.SaveResult saveRecord = mesgList[position];
            ServiceAppointment serviceAppointmentRec = scope[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(serviceAppointmentRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( serviceAppointmentRec.Id );
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'RemoveInProgressWorkBatch', ACVUtility.currentLineNumber(),
            'RemoveInProgressWorkBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment' }
        );
    }
}