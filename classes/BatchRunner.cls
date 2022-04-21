global class BatchRunner implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
   
    String query;
  List<Batch_Definition__mdt> mtdList = new List<Batch_Definition__mdt>();
  global BatchRunner() {
    String enviormentName = '\''+ACVUtility.getEnvironmentName()+'\'';
    if(Test.isRunningTest()){
      enviormentName =  '\'batchrunner test\'';
    }
    query = 'SELECT id, DeveloperName, Operation__c, Query__c FROM Batch_Definition__mdt WHERE Active__c = true AND Environment__c = '+enviormentName+' ORDER BY Order__c';
    system.debug(query);
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(SchedulableContext sc) {
    BatchRunner batchClass = new BatchRunner();
    database.executebatch(batchClass,200);
  }

     global void execute(Database.BatchableContext BC, List<sObject> scope) {
    //had to do this becasue it was super wonky trying to call a batch from a batch
    List<Batch_Definition__mdt> batchList = (List<Batch_Definition__mdt>)scope;
    System.debug(scope);
    mtdList = batchList;
  }
  
  global void finish(Database.BatchableContext BC) {
    for(Batch_Definition__mdt bd :mtdList){
      Database.executeBatch(new BatchTemplateBatch(bd.Query__c, bd.Operation__c, bd.DeveloperName));
        } 
    SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.componentName = 'BatchRunner';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>();
        infoLog.location = 'BatchRunner:'+ACVUtility.currentLineNumber();
        infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
        infoLog.message = 'BatchRunner Finished';
        infoLog.sfObject = 'Batch_Definition__mdt';
        infoLog.sfRecordId = BC.getJobId();
        infoLog.stackTrace = 'BatchRunner.finish:'+ACVUtility.currentLineNumber();
        infoLog.version = '1';
        infoLog.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        SplunkHelper.processLog(infoLog);
        ACVUtility.scheduleJob(System.now().addMinutes(30), 'BatchRunner');
  }
}