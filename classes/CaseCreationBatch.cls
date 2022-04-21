public class CaseCreationBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful {
    
    //get cases made since batch launched

    public Map<String, Integer> recordTypeCountMap;
    dateTime previoustimeStamp;
    dateTime currentTimeStamp;
    public Integer totalCaseCount;


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

    public void addCasesToMap(Map<String, Integer> caseMap, List<Case> caseList){
        for (Case c : caseList){
            if(c.recordType != null && c.recordType.developerName != null){
                    
                    String recordTypeDeveloperName = c.recordType.developerName;

                    if(caseMap.containsKey(recordTypeDeveloperName)){
                        caseMap.put(recordTypeDeveloperName, caseMap.get(recordTypeDeveloperName) + 1);
                    }
                    else{
                        caseMap.put(recordTypeDeveloperName, 1);
                    }
                }
                else{
                    if(caseMap.containsKey('Null')){
                        caseMap.put('Null', caseMap.get('Null') + 1);
                    }
                    else{
                        caseMap.put('Null', 1);
                    }
                }
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){

        //Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();

        
        if(scope != null && scope.size() > 0 ){
            //increase total count of all cases
            totalCaseCount += scope.size();
            addCasesToMap(recordTypeCountMap, scope);
        }

    }

    public void finish(Database.BatchableContext BC){
        //send log
        //loop through record types. log per type
		List<SplunkHelper.logWrapper> lwList = caseLog(recordTypeCountMap, BC);
        
        if(lwlist.size() > 0 && !Test.isRunningTest()){
            SplunkHelper.processBulkLog(lwList);
        }

        
    }
    public List<SplunkHelper.logWrapper> caseLog(Map<String, Integer> caseMap){
    	return caseLog(caseMap, null);
    }
    
    public List<SplunkHelper.logWrapper> caseLog(Map<String, Integer> caseMap, Database.BatchableContext BC){
        List<SplunkHelper.logWrapper> lwList = new List<SplunkHelper.logWrapper>();
        for(String recordTypeString : caseMap.keyset()){
            
            SplunkHelper.LogWrapper lw = new SplunkHelper.logWrapper();

            SplunkHelper.Log log = new SplunkHelper.Log();
            log.componentName = 'CaseCreationBatch';
            log.sfObject = 'Case';
            log.domainSet = new Set<SplunkHelper.DOMAIN>();
            log.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);
            log.logLevel = SplunkHelper.LOGLEVEL.PERFORMANCE;
            log.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
            if(BC != null){
             	log.sfRecordId = bc.getJobId();   
            }
            log.stackTrace = 'CaseCreationBatch: '+ACVUtility.currentLineNumber()+1;
            log.location = 'CaseCreationBatch: '+ACVUtility.currentLineNumber();
            log.message = 'Case creation count for ' + recordTypeString + ' cases: ' + caseMap.get(recordTypeString);

            SplunkEngine.LogData logData = new SplunkEngine.LogData();
            logData.type = 'Case Creation Log';
            logData.name = recordTypeString;
            logData.currentValue = String.valueOf(caseMap.get(recordTypeString));
            
            logData.maximumValue = String.valueOf(totalCaseCount);

            lw.logData = logData;
            
            lw.l = log;

            lwList.add(lw);
        }
        return lwList;
    }

    public override void executeScheduledLogic() {
        //schedule
        Database.executeBatch(new CaseCreationBatch());
    }
}