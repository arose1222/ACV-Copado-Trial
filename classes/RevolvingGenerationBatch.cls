global class RevolvingGenerationBatch implements Database.Batchable<SObject>, Database.Stateful {

    global List<String> debug = new List<String>();
    global Data_Schedule__c schedule;
    global Integer batchCount = 0;
    global Boolean hasError = false;
    global Date horizon;
    global Boolean manualLaunch = false;
    global Date executeDate;
    String occurrenceQuery;


    global RevolvingGenerationBatch(List<String> debugs, Boolean manual){
        debug.addAll(debugs);
        this.manualLaunch = manual;
        this.executeDate = Date.today().addDays(1);
    }

    global RevolvingGenerationBatch(List<String> debugs, Boolean manual, Date manualStart){
        debug.addAll(debugs);
        this.manualLaunch = manual;
        this.executeDate = manualStart;
    }

    global Database.QueryLocator start (Database.BatchableContext bc) {
        try{
             schedule = [
                    SELECT Id, Horizon_Type__c, Horizon_Length__c, Frequency__c, Send_Email_On_Success__c, Debug_Email__c
                    FROM Data_Schedule__c
                    WHERE Active__c = TRUE
                    LIMIT 1];

            //set query
            if(executeDate == null){
                executeDate = date.today();
            }
            String dateString = String.valueOf(executeDate.year());
            dateString += '-' + (executeDate.month() < 10 ? '0' + executeDate.month() : String.valueOf(executeDate.month()) );
            dateString += '-' + (executeDate.day() < 10 ? '0' + executeDate.day() : String.valueOf(executeDate.day()) );

            occurrenceQuery =   'SELECT ' +
                                'Id, Frequency__c,' +
                                'Week_Number__c,' +
                                'Every__c,' +
                                'Day__c,' +
                                'Is_Active__c,'+
                                'Timeline__c,' +
                                'Timeline__r.Account__c,' +
                                'Timeline__r.City__c,' +
                                'Timeline__r.Country__c,' +
                                'Timeline__r.Postal_Code__c,' +
                                'Timeline__r.State__c,' +
                                'Timeline__r.Street__c,' +
                                'Timeline__r.Account__r.BillingCity,' +
                                'Timeline__r.Account__r.BillingCountry,' +
                                'Timeline__r.Account__r.BillingLatitude,' +
                                'Timeline__r.Account__r.BillingLongitude,' +
                                'Timeline__r.Account__r.BillingPostalCode,' +
                                'Timeline__r.Account__r.BillingState,' +
                                'Timeline__r.Account__r.BillingStreet,' +
                                'Timeline__r.End_Date__c,' +
                                'Timeline__r.Start_Date__c,' +
        						'Timeline__r.Work_Type__c,'+
        						'Timeline__r.Work_Type__r.DurationInMinutes,'+
                                'Timeline__r.Account__r.Service_Territory__c,' +
                                'Timeline__r.Account__r.Service_Territory__r.OperatingHours.TimeZone,' +
                                'Timeline__r.Average_Number_Cars__c,' +
                                'Start_Time__c,End_Time__c,' +
                                'Farthest_Date_Generated__c ' +
                            'FROM Occurrence__c ' +
                            'WHERE Is_Active__c = TRUE ' +
                            'AND Timeline__c != NULL ' +
                            'AND (Timeline__r.Street__c != NULL OR Timeline__r.Account__r.BillingStreet != NULL) ' +
                            'AND (Timeline__r.End_Date__c = NULL OR Timeline__r.End_Date__c >= ' + dateString + ' ) ' +
                            'AND (Farthest_Date_Generated__c < :horizon OR Farthest_Date_Generated__c = null)';

            // stop batch if data schedule record doesnt match with today


            if (!manualLaunch) {
                if (!Test.isRunningTest() && !(RevolvingUtility.isDaily(schedule) || RevolvingUtility.isWeeklyToday(schedule) || RevolvingUtility.isMonthlyToday(schedule))) {
                    return null;
                }
            }

            horizon = RevolvingUtility.horizonDate(executeDate, schedule);
        }
        catch(Exception e){
            debug.addAll(new List<String>{'**EXCEPTION THROWN IN START OF BATCH**', e.getMessage(), e.getStackTraceString()});
            hasError = true;
        }
        return Database.getQueryLocator(occurrenceQuery);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        if (scope == null){
            return;
        }
        List<String> thisDebug = new List<String>();
        thisDebug.add('--------------------------------');
        thisDebug.add('EXECUTING BATCH #' + ++batchCount);
        try {
            thisDebug.addAll(RevolvingGenerator.generate((List<Occurrence__c>)scope,  executeDate, horizon));  // generate data for all future active timeline and occurrences
        }
        catch(Exception e) {
            thisDebug.addAll(new List<String>{'**EXCEPTION THROWN**',e.getMessage(),e.getStackTraceString()});
            hasError = true;
        }
        debug.addAll(thisDebug);
    }

    global void finish(Database.BatchableContext bc) {
        debug.add('------------------------');
        debug.add('PROCESSING COMPLETE' + (hasError?' WITH ERRORS':''));
        if(!Test.isRunningTest() && schedule.Debug_Email__c != null && (schedule.Send_Email_On_Success__c || hasError)) {

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{schedule.Debug_Email__c});
            email.setSubject('Revolving Appointment Batch Debug');
            email.setHtmlBody(String.join(debug, '\n<br>'));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        }
    }

}