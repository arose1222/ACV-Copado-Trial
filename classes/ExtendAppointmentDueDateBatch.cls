global class ExtendAppointmentDueDateBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    // Query related variables
    public static final Date REASSIGN_DUE_DATE {
        get {
            if ( REASSIGN_DUE_DATE == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Service Appointment ReAssign Date' LIMIT 1 ];
                REASSIGN_DUE_DATE = system.Today().addDays(Integer.valueOf( dateRange.Value__c ));
            }
            return REASSIGN_DUE_DATE;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query;
        DateTime currentTime = System.now();
        query =  'SELECT Id, DueDate, FSL__InJeopardy__c, FSL__InJeopardyReason__c ';
        query += 'FROM ServiceAppointment ';
        query += 'WHERE WorkType.Work_Type_Unique_ID__c IN (\'auction site\', \'dealer\', \'auction off-lease\') ';
        query +=    'AND Status = \'New\' ';
        query +=    'AND Original_Due_Date__c <= :currentTime';
        // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        ExtendAppointmentDueDateBatch ExtendAppointmentDueDateBatch = new ExtendAppointmentDueDateBatch();
        Database.executeBatch(ExtendAppointmentDueDateBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        for (ServiceAppointment sa : scope) {

            sa.DueDate = REASSIGN_DUE_DATE;

            if(!sa.FSL__InJeopardy__c){
                sa.FSL__InJeopardy__c = true;
                sa.FSL__InJeopardyReason__c = 'Due Date Approaching';
            }

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
            returnInfo, BC.getJobId(), 'ExtendAppointmentDueDateBatch', ACVUtility.currentLineNumber(),
            'ExtendAppointmentDueDateBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment' }
        );
    }
}