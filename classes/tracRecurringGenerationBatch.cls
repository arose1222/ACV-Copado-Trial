/**
 * @description ${DESCRIPTION}
 * @name tracRecurringGenerationBatch
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-28
 */

global with sharing class tracRecurringGenerationBatch implements Database.Batchable<SObject>, Database.Stateful  {
    public static final Datetime NOW = (Datetime) System.today();
    public static final String DAY_OF_THE_WEEK = NOW.format('EEEE');
    public static final String DAY_OF_THE_MONTH = NOW.format('d');

    global Data_Schedule__c schedule;

    global List<String> debug = new List<String>{'THIS IS THE DEBUG'};
    global Integer batchCount = 0;
    global Boolean hasError = false;

    global Date future;

    String occurrenceQuery =    'SELECT ' +
                                'Id, Frequency__c,' +
                                'Week_Number__c,' +
                                'Every__c,' +
                                'Day__c,' +
                                'Timeline__c,' +
                                'Timeline__r.Account__c,' +
                                'Timeline__r.Account__r.BillingCity,' +
                                'Timeline__r.Account__r.BillingCountry,' +
                                'Timeline__r.Account__r.BillingLatitude,' +
                                'Timeline__r.Account__r.BillingLongitude,' +
                                'Timeline__r.Account__r.BillingPostalCode,' +
                                'Timeline__r.Account__r.BillingState,' +
                                'Timeline__r.Account__r.BillingStreet,' +
                                'Timeline__r.End_Date__c,' +
                                'Timeline__r.Start_Date__c,' +
                                'Timeline__r.Account__r.Service_Territory__c,' +
                                'Timeline__r.Average_Number_Cars__c,' +
                                'Start_Time__c,End_Time__c,' +
                                'Date_of_Last_Generation__c ' +
                            'FROM Occurrence__c ' +
                            'WHERE Is_Active__c = TRUE ' +
                            'AND Timeline__c != NULL ' +
                            'AND (Timeline__r.End_Date__c = NULL OR Timeline__r.End_Date__c >= TODAY ) ' +
                            'AND (Date_of_Last_Generation__c < :future OR Date_of_Last_Generation__c = NULL)';


    /**
     * @description build query for the active data schedule
     * @param bc batchable context
     * @return query
     */
    global Database.QueryLocator start (Database.BatchableContext bc) {
        try{

            schedule = [
                    SELECT Id, Horizon_Type__c, Horizon_Length__c, Frequency__c, Send_Email_On_Success__c, Debug_Email__c
                    FROM Data_Schedule__c
                    WHERE Active__c = TRUE
                    LIMIT 1];
    
            // stop batch if data schedule record doesnt match with today
            if (!tracRecurringGenerationManual.overrideDataSchedule) {
                if (!Test.isRunningTest() && !(isDaily(schedule) || isWeeklyToday(schedule) || isMonthlyToday(schedule))) {
                    return null;
                }
            }
    
            future = getFutureDate(schedule);
    
            
    
            debug.add('--------------------------------');
            debug.add('PRE-BATCH DATA REMOVAL');
            debug.addAll(tracGenerate.deleteChangedRecords());  // delete generated data for changed or deleted occurrences
            debug.addAll(tracGenerate.removeInactiveRecords());  // delete timelines and occurrences that are inactive or past
        }
        catch(Exception e){
            debug.addAll(new List<String>{'**EXCEPTION THROWN IN START OF BATCH**', e.getMessage(), e.getStackTraceString()});
            hasError = true;
        }
        
        return Database.getQueryLocator(occurrenceQuery);
    }


    /**
     * @description execute the batch
     * @param bc batchable context
     * @param scope list of records from query
     */
    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (scope == null) return;

        List<String> thisDebug = new List<String>();
        thisDebug.add('--------------------------------');
        thisDebug.add('EXECUTING BATCH #' + ++batchCount);
        try {
            thisDebug.addAll(tracGenerate.generate((List<Occurrence__c>)scope,future));  // generate data for all future active timeline and occurrences
        }
        catch(Exception e) {
            thisDebug.addAll(new List<String>{'**EXCEPTION THROWN**',e.getMessage(),e.getStackTraceString()});
            hasError = true;
        }
        debug.addAll(thisDebug);
    }


    /**
     * @description actions to perform on batch completion
     * @param bc batchable context
     */
    global void finish(Database.BatchableContext bc) {
        debug.add('------------------------');
        debug.add('PROCESSING COMPLETE' + (hasError?' WITH ERRORS':''));
        if(!Test.isRunningTest() && schedule.Debug_Email__c != null && (schedule.Send_Email_On_Success__c || hasError)) {
            tracConstants.sendMail(schedule.Debug_Email__c, 'Batch Finish Report', String.join(debug, '\n<br>'));
        }
    }



    /************ HELPER METHODS ************/
    public static Date getFutureDate(Data_Schedule__c thisSchedule) {
        Date today = Date.today();
        Date futureDate;
        if (thisSchedule.Horizon_Type__c == tracConstants.DATA_HORIZON_DAYS) {
            futureDate = today.addDays(Integer.valueOf(thisSchedule.Horizon_Length__c));
        } else if (thisSchedule.Horizon_Type__c == tracConstants.DATA_HORIZON_WEEKS) {
            futureDate = today.addDays(Integer.valueOf(thisSchedule.Horizon_Length__c)*7);
        } else if (thisSchedule.Horizon_Type__c == tracConstants.DATA_HORIZON_MONTHS) {
            futureDate = today.addMonths(Integer.valueOf(thisSchedule.Horizon_Length__c));
        }
        return futureDate;
    }

    public static Boolean isDaily(Data_Schedule__c ds) {
        return ds.Frequency__c == tracConstants.DATA_FREQUENCY_DAILY;
    }

    public static Boolean isWeeklyToday(Data_Schedule__c ds) {
        return ds.Frequency__c == tracConstants.DATA_FREQUENCY_WEEKLY
                && DAY_OF_THE_WEEK == ds.Day__c;
    }

    public static Boolean isMonthlyToday(Data_Schedule__c ds) {
        return ds.Frequency__c == tracConstants.DATA_FREQUENCY_MONTHLY
                && DAY_OF_THE_MONTH == ds.Day__c;
    }

}