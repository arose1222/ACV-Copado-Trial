global class TimeSheetCreationBatch extends SchedulingInterface implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    private Boolean timeTrackingBetaFlag = [SELECT Code_Flag__c FROM Code_Flag__mdt WHERE DeveloperName = 'Time_Sheet_Tracking_Beta_Restriction' LIMIT 1].Code_Flag__c;
    private Integer batchCount = 1;

    private Date currentDate = Date.today();

    private List<SplunkHelper.SFErrorRecord> splunkErrorRecords = new List<SplunkHelper.SFErrorRecord>();
    private Set<String> splunkSavedIds = new Set<String>();
    

    global Database.QueryLocator start(Database.BatchableContext bc){

        //begin construction of the query, limit by primary territory membership so resources only get 1 time sheet
        String query = 'SELECT Id, ServiceTerritoryId, ServiceResourceId FROM ServiceTerritoryMember WHERE TerritoryType = \'P\'';
        //if time tracking beta is active, then construct a list of territories to include by metadata
        Set<String> territorySet = new Set<String>();

        if(timeTrackingBetaFlag == true){
                query += ' AND ServiceTerritory.Generate_TimeSheets__c = TRUE';
        }

        //create a list of all resources who are excluded from being given timesheets based on metadata
        Set<Id> timeTrackingExcludedResourceIds = excludedIds();
        if(timeTrackingExcludedResourceIds.size() > 0){
            query += ' AND ServiceResourceId not in : timeTrackingExcludedResourceIds';
        }
        
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        TimeSheetCreationBatch batch = new TimeSheetCreationBatch();
        Database.executeBatch(batch, 200);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        //get the service resources from the territory membership records
        List<ServiceTerritoryMember> stmList = (List<ServiceTerritoryMember>) scope;
        Set<Id> resourceIds = new Set<Id>();
        for(ServiceTerritoryMember stm : stmList){
            if(stm.ServiceResourceId != null){
                resourceIds.add(stm.ServiceResourceId);
            }
        }

        //query for the resources and if they have any time sheets for this pay period
        Map<Id, ServiceResource> srMap = new Map<Id, ServiceResource>([SELECT Id, Name, RelatedRecord.ManagerId, (SELECT Id, StartDate, EndDate, Status FROM TimeSheets WHERE StartDate > : currentPayPeriodStart(this.currentDate)) FROM ServiceResource WHERE Id in : resourceIds AND IsActive = TRUE]);
        //if the resource has no active time sheets for the current pay period, then create a new time sheet for them
        List<TimeSheet> tsInsertList = createMissingTimeSheets(srMap.values(), this.currentDate);


        List<Database.SaveResult> tsInsertionResults = Database.insert(tsInsertList, false);
        //add save results to splunk log
        for(Database.SaveResult saveRes : tsInsertionResults){
            if(saveRes.isSuccess()){
                this.splunkSavedIds.add(saveRes.id);
            }
            else{
                this.splunkErrorRecords.add(splunkErrorRecord(saveRes));
            }
        }

        this.BatchCount++;
    }


    global void finish(Database.BatchableContext bc){
        SplunkHelper.Log logInfo = new SplunkHelper.Log();
        logInfo.logLevel =  splunkErrorRecords.size() > 0 ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;
        logInfo.message = '';
        logInfo.sfRecordId = '';
        logInfo.componentName = 'TimeSheetCreationBatch';
        logInfo.sfObject = 'TimeSheet';
        logInfo.domainSet = new Set<SplunkHelper.DOMAIN>();
        logInfo.domainSet.add(SplunkHelper.DOMAIN.SALES);
        logInfo.stackTrace = 'TimeSheetCreationBatch.finish: '+ACVUtility.currentLineNumber()+2;
        logInfo.location = 'TimeSheetCreationBatch.finish: '+ACVUtility.currentLineNumber()+1;
        if(!Test.isRunningTest()){
            SplunkHelper.processBatchLog(logInfo, splunkErrorRecords, splunkSavedIds);
        }
        //use splunk helper to send splunk log
    }

    public SplunkHelper.SFErrorRecord splunkErrorRecord(Database.SaveResult saveRes){
        Id recordId;
        String errorMessage = '';
        if(!saveRes.isSuccess()){
                if(saveRes.getId() != null){
                    recordId = saveRes.getId();
                }
                if(saveRes.getErrors() != null){
                    for(Database.Error err : saveRes.getErrors()){
                        if(err.getFields().size() > 0){
                            errorMessage += 'Fields related to error: ';
                            for(String errField : err.getFields()){
                                errorMessage += errField + ' ';
                            }
                            errorMessage += '. ';
                        }
                        if(err.getMessage() != null){
                            errorMessage += 'Message: ' + err.getMessage() + '. ';
                        }
                        if(err.getStatusCode() != null){
                            errorMessage += 'Status Code: ' + err.getStatusCode() + '.';
                        }
                    }
                }
        }
        return new SplunkHelper.SFErrorRecord(recordId, errorMessage);
    }

    Set<Id> excludedIds(){
        Set<Id> timeTrackingExcludedResourceIds = new Set<Id>();
        for(Time_Tracking_Resource__mdt resource : [SELECT Resource_Id__c FROM Time_Tracking_Resource__mdt WHERE Resource_Action__c = 'Exclude']){
            if(resource.Resource_Id__c != null){
                timeTrackingExcludedResourceIds.add(resource.Resource_Id__c);
            }
        }
        return timeTrackingExcludedResourceIds;
    }

    public List<TimeSheet> createMissingTimeSheets(List<ServiceResource> srList, Date currentDate){
        List<TimeSheet> tsList = new List<TimeSheet>();
        for(ServiceResource sr : srList){
            if(!(sr.TimeSheets.size() > 0)){
                tsList.add(createPayPeriodTimeSheet(sr, currentDate));    
            }
        }
        return tsList;
    }

    public TimeSheet createPayPeriodTimeSheet(ServiceResource sr, Date currentDate){
        return new TimeSheet(
            ServiceResourceId = sr.id, 
            StartDate = currentPayPeriodStart(currentDate), 
            EndDate = currentPayPeriodEnd(currentDate),
            Manager__c = sr.RelatedRecord.ManagerId
        );
    }


    //the pay periods are defined as the 10th - 23rd and the 24th - 9th of every month
    public static Date currentPayPeriodStart(Date currentDate){
        Date currentPayPeriodStart;
        if(currentDate.day() >= 1 && currentDate.day() <= 9){
            //start date is the 24th of previous month
            if(currentDate.month() == 1){
                //special case for January for jumping a month backwards
                currentPayPeriodStart = Date.newInstance(currentDate.year()-1, 12, 24);
            }
            else{
                currentPayPeriodStart = Date.newInstance(currentDate.year(), currentDate.month()-1, 10);
            }
        }
        else if(currentDate.day() >= 10 && currentDate.day() <= 23){
            //start date is the 10th of this month
            currentPayPeriodStart = Date.newInstance(currentDate.year(), currentDate.month(), 10);
        }
        else{
            //start date is the 24th of this month
            currentPayPeriodStart = Date.newInstance(currentDate.year(), currentDate.month(), 24);
        }
        return currentPayPeriodStart;
    }

    public static Date currentPayPeriodEnd(Date currentDate){
        Date currentPayPeriodEnd;
        if(currentDate.day() >= 1 && currentDate.day() <= 9){
            //end date is the 9th of this month
            currentPayPeriodEnd = Date.newInstance(currentDate.year(), currentDate.month(), 9);
        }
        else if(currentDate.day() >= 10 && currentDate.day() <= 23){
            //end date is the 23rd of this month
            currentPayPeriodEnd = Date.newInstance(currentDate.year(), currentDate.month(), 23);
        }
        else{
            //end date is the 9th of next month
            if(currentDate.month() == 12){
                //special case for December for jumping forward a month
                currentPayPeriodEnd = Date.newInstance(currentDate.year()+1, 1, 9);
            }
            else{
                currentPayPeriodEnd = Date.newInstance(currentDate.year(), currentDate.month()+1, 9);
            }
        }
        return currentPayPeriodEnd;
    }
}