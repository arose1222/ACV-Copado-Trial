global class ClearEntitySubscriptionsBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

        // Query related variables
        String query;
        final String FIELD_LIST = 'Id';
        public static final Integer DEFAULT_DAY_RANGE {
            get {
                if ( DEFAULT_DAY_RANGE == null ) {
                    Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Clear Entity Subscriptions Batch Range' LIMIT 1 ];
                    DEFAULT_DAY_RANGE = -1 * Integer.valueOf( dateRange.Value__c );
                }
                return DEFAULT_DAY_RANGE;
            }
            set;
        }
    
        // State Variable
        global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );
        
        global ClearEntitySubscriptionsBatch() {
            String lastMonth = Datetime.now().addDays( DEFAULT_DAY_RANGE ).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
            query = 'SELECT ' + FIELD_LIST + ' FROM EntitySubscription WHERE CreatedDate <= ' + lastMonth;
        }
    
        global ClearEntitySubscriptionsBatch( DateTime givenTime ) {
            String givenTimeStr = givenTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\''); 
            query = 'SELECT ' + FIELD_LIST + ' FROM EntitySubscription WHERE CreatedDate <= ' + givenTimeStr;
        }
        
        global Database.QueryLocator start( Database.BatchableContext BC ) {
            return Database.getQueryLocator( query );
        }
    
        public override void executeScheduledLogic() {
            ClearEntitySubscriptionsBatch batchClass = new ClearEntitySubscriptionsBatch();
            database.executebatch( batchClass, 200 );
        }
    
        global void execute( Database.BatchableContext BC, List<sObject> scope ) {           
            List<EntitySubscription> scopeLst = (List<EntitySubscription>) scope;
            Database.DeleteResult[] deleteResultLst = Database.delete( scopeLst, FALSE );
            for ( Integer position = 0; position < deleteResultLst.size(); position++ ) {
                Database.DeleteResult deleteRecord = deleteResultLst[position];
                EntitySubscription deletedRec = scopeLst[position];
    
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
                returnInfo, BC.getJobId(), 'ClearEntitySubscriptionsBatch', ACVUtility.currentLineNumber(), 
                'ClearEntitySubscriptionsBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Entity Subscription' }
            );
        }
        
    }