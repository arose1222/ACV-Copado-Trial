global class ClearCustomFieldHistoryBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    // Query related variables
    String query;
    final String FIELD_LIST = 'Id';
    public static final Integer DEFAULT_DAY_RANGE {
        get {
            if ( DEFAULT_DAY_RANGE == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Clear Custom Field History Batch Range' LIMIT 1 ];
                DEFAULT_DAY_RANGE = -1 * Integer.valueOf( dateRange.Value__c );
            }
            return DEFAULT_DAY_RANGE;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );
    
    global ClearCustomFieldHistoryBatch() {
        String lastMonth = Datetime.now().addDays( DEFAULT_DAY_RANGE ).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
        query = 'SELECT ' + FIELD_LIST + ' FROM Field_History__c WHERE CreatedDate <= ' + lastMonth;
    }

    global ClearCustomFieldHistoryBatch( DateTime givenTime ) {
        String givenTimeStr = givenTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\''); 
        query = 'SELECT ' + FIELD_LIST + ' FROM Field_History__c WHERE CreatedDate <= ' + givenTimeStr;
    }
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        return Database.getQueryLocator( query );
    }

    public override void executeScheduledLogic() {
        ClearCustomFieldHistoryBatch batchClass = new ClearCustomFieldHistoryBatch();
        database.executebatch( batchClass, 200 );
    }

    global void execute( Database.BatchableContext BC, List<sObject> scope ) {
        List<Field_History__c> fieldHistoryScopeLst = (List<Field_History__c>) scope;
        Database.DeleteResult[] deleteResultLst = Database.delete( fieldHistoryScopeLst, FALSE );
        for ( Integer position = 0; position < deleteResultLst.size(); position++ ) {
            Database.DeleteResult deleteRecord = deleteResultLst[position];
            Field_History__c deletedHisRec = fieldHistoryScopeLst[position];

            if ( !deleteRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(deletedHisRec ) ); 
                if ( !deleteRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( deleteRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( deletedHisRec.Id );
            }
        }
    }
    
    global void finish( Database.BatchableContext BC ) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog( 
            returnInfo, BC.getJobId(), 'ClearCustomFieldHistoryBatch', ACVUtility.currentLineNumber(), 
            'ClearCustomFieldHistoryBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Field History' }
        );
    }
}