global class RequestInspectionCleanupBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public static final DateTime DateTime_NumMinutesOld = System.Now().addMinutes(-5);

    public static final List<String> workTypeCleanUpList = new List<String>{ 'inspection', 'true360', 'siriusxm' };

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id ' +
                       'FROM WorkOrder ' +
                       'WHERE Processing_Offers__c = true ' +
                            'AND CreatedDate <= :DateTime_NumMinutesOld ' +
                            'AND WorkType.Work_Type_Unique_ID__c IN :workTypeCleanUpList';

        // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        RequestInspectionCleanupBatch RequestInspectionCleanupBatch = new RequestInspectionCleanupBatch();
        Database.executeBatch(RequestInspectionCleanupBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<WorkOrder> scope){

        Database.DeleteResult[] deleteResults = Database.delete(scope,false);

        for ( Integer position = 0; position < deleteResults.size(); position++ ) {
            Database.DeleteResult deletedRecord = deleteResults[position];
            WorkOrder woRec = scope[position];

            if ( !deletedRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(woRec ) );
                if ( !deletedRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( deletedRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( woRec.Id );
            }
        }

    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'RequestInspectionCleanupBatch', ACVUtility.currentLineNumber(),
            'RequestInspectionCleanupBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Work Order' }
        );
    }
}