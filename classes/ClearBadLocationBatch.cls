global class ClearBadLocationBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {

    // Query related variables
    final String FIELD_LIST = 'id, visitoraddressid';

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {      
        String query = 'SELECT ' + FIELD_LIST + ' FROM Location WHERE VisitorAddressId = null';
        return Database.getQueryLocator( query );
    }

    global void execute( SchedulableContext sc ) {
        ClearBadLocationBatch batchClass = new ClearBadLocationBatch();
        database.executebatch( batchClass, 200 );
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {           
        List<Schema.Location> scopeLst = (List<Schema.Location>) scope;
        Database.DeleteResult[] deleteResultLst = Database.delete( scopeLst, FALSE );

        for ( Integer position = 0; position < deleteResultLst.size(); position++ ) {
            Database.DeleteResult deleteRecord = deleteResultLst[position];
            Schema.Location deletedRec = scopeLst[position];

            if ( !deleteRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize( deletedRec ) ); // Since it failed deletion, the Id will be safe
                if( !deleteRecord?.getErrors()?.isEmpty() ) { returnInfo.errorMessageLst.add( deleteRecord?.getErrors()[0]?.message ); }
            } else {
                returnInfo.successfulReturnSet.add( deletedRec.Id ); // Not sure if Id will save or not
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog( 
            returnInfo, BC.getJobId(), 'ClearBadLocationBatch', ACVUtility.currentLineNumber(), 
            'ClearBadLocationBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Location' }
        );

        ACVUtility.scheduleJob( DateTime.now().addMinutes(2), 'ClearBadLocationBatch' );
    }
    
}