global class RevolvingCleanupBatch implements Database.Batchable<SObject>, Database.Stateful {

    String occurrenceQuery =    'SELECT  Id, '+
                                'Frequency__c, '+
                                'Week_Number__c, '+
                                'Every__c, '+
                                'Day__c, '+
                                'Timeline__c, '+
                                'Start_Time__c, '+
                                'End_Time__c, '+
                                'Is_Active__c, '+
                                'Cleanup_Marker__c, '+
                                'Farthest_Date_Generated__c '+
                            'FROM Occurrence__c '+
                            'WHERE Modified_Since_Last_Batch__c = true '+
                            'OR Is_Active__c = false '+
                            'OR Timeline__c = null';

    global Integer batchCount = 0;
    global Boolean hasError = false;
    global List<String> debug = new List<String>();
    global Boolean manualLaunch = false;
    global Boolean launchGeneration = true;
    global Integer generationBatchSize = 35;
    global Data_Schedule__c schedule;

    global RevolvingCleanUpBatch(Boolean runGenerationBatch, Integer generationBatchSize, Boolean manual){
        this.launchGeneration = runGenerationBatch;
        this.generationBatchSize = generationBatchSize;
        this.manualLaunch = manual;
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {
        try{
            schedule = [
                    SELECT Id, Horizon_Type__c, Horizon_Length__c, Frequency__c, Send_Email_On_Success__c, Debug_Email__c
                    FROM Data_Schedule__c
                    WHERE Active__c = TRUE
                    LIMIT 1];

            // stop batch if data schedule record doesnt match with today
            if (!manualLaunch) {
                if (!Test.isRunningTest() && !(RevolvingUtility.isDaily(schedule) || RevolvingUtility.isWeeklyToday(schedule) || RevolvingUtility.isMonthlyToday(schedule))) {
                    return null;
                }
            }
        }
        catch(Exception e){
            debug.addAll(new List<String>{'**EXCEPTION THROWN IN START OF BATCH**', e.getMessage(), e.getStackTraceString()});
            hasError = true;
        }
        return Database.getQueryLocator(occurrenceQuery);
    }


    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (scope == null) return;

        List<String> thisDebug = new List<String>();
        thisDebug.add('--------------------------------');
        thisDebug.add('EXECUTING CLEANUP BATCH #' + ++batchCount);


        try{
            thisDebug.addAll(RevolvingCleaner.deleteChangedRecords((List<Occurrence__c>)scope));  // delete generated data for changed or deleted occurrences
            //thisDebug.addAll(RevolvingCleaner.removeInactiveRecords((List<Occurrence__c>)scope));  // delete timelines and occurrences that are inactive or past
        }
        catch(Exception e) {
            thisDebug.addAll(new List<String>{'**EXCEPTION THROWN**',e.getMessage(),e.getStackTraceString()});
            hasError = true;
        }
        debug.addAll(thisDebug);
    }

    global void finish(Database.BatchableContext bc) {
        debug.add('------------------------');
        debug.add('CLEANUP COMPLETE' + (hasError?' WITH ERRORS':''));

        if(launchGeneration){
            RevolvingGenerationBatch generationBatch = new RevolvingGenerationBatch(debug, manualLaunch);
            Database.executeBatch(generationBatch, generationBatchSize);
        }
        else if(!Test.isRunningTest() && schedule.Debug_Email__c != null && (schedule.Send_Email_On_Success__c || hasError)) {

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{schedule.Debug_Email__c});
            email.setSubject('Revolving Appointment Batch Debug');
            email.setHtmlBody(String.join(debug, '\n<br>'));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        }
    }
}