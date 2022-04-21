global class RevolvingGenerationMissed implements Schedulable{

    global void execute(SchedulableContext sc){
        retrieveMissedOccurrences();
    }

    public void retrieveMissedOccurrences(){

        Data_Schedule__c schedule = [SELECT Id, Horizon_Type__c, Horizon_Length__c, Frequency__c, Send_Email_On_Success__c, Debug_Email__c
                                     FROM Data_Schedule__c
                                     WHERE Active__c = TRUE
                                     LIMIT 1];

        Date executeDate = Date.today().addDays(1);
        Date horizon = RevolvingUtility.horizonDate(executeDate, schedule);

        List<Id> missedOccurrenceIdList = new List<Id>();
        for(Occurrence__c occurrence : [SELECT Id
                                        FROM Occurrence__c
                                        WHERE Is_Active__c = TRUE
                                            AND Timeline__c != NULL
                                            AND Timeline__r.Account__r.BillingStreet != NULL
                                            AND (Timeline__r.End_Date__c = NULL OR Timeline__r.End_Date__c >= :executeDate)
                                            AND (Farthest_Date_Generated__c < :horizon OR Farthest_Date_Generated__c = null)])
        {
            missedOccurrenceIdList.add(occurrence.Id);

        }

        if(missedOccurrenceIdList.size() > 0){
            logToSplunk(missedOccurrenceIdList);
        }
    }

    public void logToSplunk(List<Id> missedOccurrenceIdList){
        SplunkHelper.Log log = new SplunkHelper.log();
            log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.INSPECTOR_DISPATCH};
            log.sfObject = 'Occurrence__c';
            log.version = 'v1';
            log.sfRecordId = missedOccurrenceIdList[0];
            log.componentName = 'RevolvingGenerationMissed';
            log.location = 'RevolvingGenerationMissed';
            log.message =  'RevolvingGenerationBatch missed the following Occurrences: ' + String.join(missedOccurrenceIdList,',');
            log.stackTrace = 'RevolvingGenerationMissed';
            log.logLevel = SplunkHelper.LOGLEVEL.ERROR;
            log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
            SplunkHelper.processLog(log);
    }



}