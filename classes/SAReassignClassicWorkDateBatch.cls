// Job is scheduled to run before optimization, on the current day
global class SAReassignClassicWorkDateBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    // Query related variables
    public static final Integer DEFAULT_DAY_RANGE {
        get {
            if ( DEFAULT_DAY_RANGE == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Service Appointment Classic ACV ReAssign' LIMIT 1 ];
                DEFAULT_DAY_RANGE = Integer.valueOf( dateRange.Value__c );
            }
            return DEFAULT_DAY_RANGE;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select DueDate from ServiceAppointment WHERE WorkType.Work_Type_Unique_ID__c in (\'inspection\', \'verification\', \'true360\') AND status in (\'New\', \'Scheduled\', \'Cannot Complete\') AND DueDate <= TODAY AND Work_Order__r.Occurrence__c = null';
        // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        SAReassignClassicWorkDateBatch saradb = new SAReassignClassicWorkDateBatch();
        Database.executeBatch(saradb, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        for (ServiceAppointment sa : scope) {
            // Add # days to DueDate.  Stored in Custom Metadata Type → Salesforce Setting → Service Appointment Classic ACV ReAssign
            sa.DueDate = DateTime.newInstance( Date.today().addDays(DEFAULT_DAY_RANGE), Time.newInstance( 21, 0, 0, 0 ) );

            // Because DueDate was extended # days, Set the In Jeopardy Checkbox
            sa.FSL__InJeopardy__c = true;
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
            returnInfo, BC.getJobId(), 'SAReassignClassicWorkDateBatch', ACVUtility.currentLineNumber(), 
            'SAReassignClassicWorkDateBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment' }
        );
    }
}