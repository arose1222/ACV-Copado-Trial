global class ClearIntegrationResultsBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    // Query related variables
	String query;
    final String FIELD_LIST = 'Id, Status_Code__c';
    public static final Integer DEFAULT_DAY_RANGE {
        get {
            if ( DEFAULT_DAY_RANGE == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Clear Integration Results Batch Range' LIMIT 1 ];
                DEFAULT_DAY_RANGE = -1 * Integer.valueOf( dateRange.Value__c );
            }
            return DEFAULT_DAY_RANGE;
        }
        set;
    }

    public override void executeScheduledLogic() {
        ClearIntegrationResultsBatch batchClass = new ClearIntegrationResultsBatch();
		database.executebatch( batchClass, 200 );
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );
	
    global ClearIntegrationResultsBatch() {
        String lastMonth = Datetime.now().addDays( DEFAULT_DAY_RANGE ).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
		query = 'SELECT ' + FIELD_LIST + ' FROM Integration_Result__c WHERE CreatedDate <= ' + lastMonth;
	}

	global ClearIntegrationResultsBatch( DateTime givenTime ) {
        String givenTimeStr = givenTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\''); 
		query = 'SELECT ' + FIELD_LIST + ' FROM Integration_Result__c WHERE CreatedDate <= ' + givenTimeStr;
	}
	
	global Database.QueryLocator start( Database.BatchableContext BC ) {
		return Database.getQueryLocator( query );
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {           
        List<Integration_Result__c> scopeLst = (List<Integration_Result__c>) scope;
        Database.DeleteResult[] deleteResultLst = Database.delete( scopeLst, FALSE );
        for ( Integer position = 0; position < deleteResultLst.size(); position++ ) {
            Database.DeleteResult deleteRecord = deleteResultLst[position];
            Integration_Result__c deletedRec = scopeLst[position];

            if ( !deleteRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize( deletedRec ) ); // Since it failed deletion, the Id will be safe
                returnInfo.errorMessageLst.add( deleteRecord.getErrors()[0].message );
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
            returnInfo, BC.getJobId(), 'ClearIntegrationResultsBatch', ACVUtility.currentLineNumber(), 
            'ClearIntegrationResultsBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Integration Result' }
        );
    }
	
}