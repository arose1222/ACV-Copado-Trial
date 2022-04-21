global class BatchTemplateBatch implements Database.Batchable<sObject>,Database.Stateful{
    
    String query;
    String contextType;
    String jobName;
    String SObjectType;
    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global BatchTemplateBatch(String queryString, String context, String name) {
        query = queryString;
        contextType = context;
        jobName = name;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        SObjectType = scope[0].Id.getSobjectType().getDescribe().getName();
        if(contextType == 'Blank Update'){
            Database.SaveResult[] saveResultList = Database.update(scope, FALSE);
            for ( Integer position = 0; position < saveResultList.size(); position++ ) {
                Database.SaveResult saveRecord = saveResultList[position];
                SObject saverec = scope[position];
    
                if ( !saveRecord?.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                    returnInfo.errorReturnLst.add( JSON.serialize( saverec ) ); // Since it failed deletion, the Id will be safe
                    if( !saveRecord?.getErrors()?.isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord?.getErrors()[0]?.message ); } 
                } else {
                    returnInfo.successfulReturnSet.add( saverec?.Id ); // Not sure if Id will save or not
                }
            }
        }
        else if( contextType == 'Delete'){
            Database.DeleteResult[] deleteResultLst = Database.delete( scope, FALSE );
            for ( Integer position = 0; position < deleteResultLst.size(); position++ ) {
                Database.DeleteResult deleteRecord = deleteResultLst[position];
                SObject deletedRec = scope[position];
    
                if ( !deleteRecord?.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                    returnInfo.errorReturnLst.add( JSON.serialize( deletedRec ) ); // Since it failed deletion, the Id will be safe
                    if( !deleteRecord?.getErrors()?.isEmpty() ) { returnInfo.errorMessageLst.add( deleteRecord?.getErrors()[0]?.message ); } 
                } else {
                    returnInfo.successfulReturnSet.add( deletedRec?.Id ); // Not sure if Id will save or not
                }
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog( 
            returnInfo, BC.getJobId(), 'BatchTemplateBatch', ACVUtility.currentLineNumber(), 
            'BatchTemplateBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ SObjectType }
        );
  }
}