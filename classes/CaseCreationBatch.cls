public class CaseCreationBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful {
    
    //get cases made since batch launched

    public static Map<String, Integer> recordTypeCountMap;
    dateTime previoustimeStamp;
    dateTime currentTimeStamp;
    public static Integer totalCaseCount;


    public CaseCreationBatch(){
        
    }

    public CaseCreationBatch(DateTime createdDateTimeStamp){
        previoustimeStamp = createdDateTimeStamp;
    }




    public Database.QueryLocator start(Database.BatchableContext BC){
        currentTimeStamp = dateTime.now();
        if(previoustimeStamp == null){
            previoustimeStamp = currentTimeStamp.addHours(-1);
        }

        String query = 'SELECT Id, recordType.DeveloperName FROM Case WHERE createdDate > :previousTimeStamp';

        recordTypeCountMap = new Map<String, Integer>();
        totalCaseCount = 0;
        //get all cases created since the batch last ran
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Case> scope){

        //Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();

        if(scope != null && scope.size() > 0 ){
            //increase total count of all cases
            totalCaseCount += scope.size();


            //add to count for specific record type, if the record type has not been encountered yet, add it to the map
            for(Case c : scope){
                //get the developer name of the record type, use it as a key for the map of counts
                if(c.recordType != null && c.recordType.developerName != null){
                    
                    String recordTypeDeveloperName = c.recordType.developerName;

                    if(recordTypeCountMap.containsKey(recordTypeDeveloperName)){
                        recordTypeCountMap.put(recordTypeDeveloperName, recordTypeCountMap.get(recordTypeDeveloperName) + 1);
                    }
                    else{
                        recordTypeCountMap.put(recordTypeDeveloperName, 1);
                    }
                }
                else{
                    if(recordTypeCountMap.containsKey('Null')){
                        recordTypeCountMap.put('Null', recordTypeCountMap.get('Null') + 1);
                    }
                    else{
                        recordTypeCountMap.put('Null', 1);
                    }
                }
            }
        }

    }

    public void finish(Database.BatchableContext BC){
        //send log
        //loop through record types. log per type

        List<SplunkHelper.logWrapper> lwList = new List<SplunkHelper.logWrapper>();

        for(String recordTypeString : recordTypeCountMap.keyset()){
            
            SplunkHelper.LogWrapper lw = new SplunkHelper.logWrapper();

            SplunkHelper.Log log = new SplunkHelper.Log();
            log.componentName = 'CaseCreationBatch';
            log.sfObject = 'Case';
            log.domainSet = new Set<SplunkHelper.DOMAIN>();
            log.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
            log.logLevel = SplunkHelper.LOGLEVEL.INFO;
            log.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
            log.sfRecordId = bc.getJobId();
            log.stackTrace = 'CaseCreationBatch: '+ACVUtility.currentLineNumber()+1;
            log.location = 'CaseCreationBatch: '+ACVUtility.currentLineNumber();
            log.message = 'Case creation count for ' + recordTypeString + ' cases: ' + recordTypeCountMap.get(recordTypeString);

            SplunkEngine.LogData logData = new SplunkEngine.LogData();
            logData.type = 'Case Creation Log';
            logData.name = recordTypeString;
            logData.currentValue = String.valueOf(recordTypeCountMap.get(recordTypeString));
            
            logData.maximumValue = String.valueOf(totalCaseCount);

            lw.logData = logData;
            
            lw.l = log;

            lwList.add(lw);
        }

        if(lwlist.size() > 0){
            SplunkHelper.processBulkLog(lwList);
        }

        
    }

    public override void executeScheduledLogic() {
        //schedule
        Database.executeBatch(new CaseCreationBatch());
    }
}