global class SchedulingFramework implements Schedulable {

    @TestVisible private static final string EVERY_5_MINUTES = 'Every 5 Minutes';
    @TestVisible private static final string EVERY_10_MINUTES = 'Every 10 Minutes';
    @TestVisible private static final string EVERY_15_MINUTES = 'Every 15 Minutes';
    @TestVisible private static final string EVERY_30_MINUTES = 'Every 30 Minutes';
    @TestVisible private static final string EVERY_HOUR = 'Every Hour';
    @TestVisible private static final string SPECIFIC_TIME = 'Specific Time';

    @TestVisible private static final integer MINUTE_ADJUSTMENT_RANGE = 2;
    @TestVisible private static final set<integer> TEN_MINUTE_CHECK_SET = new set<integer>{ 0, 10, 20, 30, 40, 50, 60 };
    @TestVisible private static final set<integer> FIFTEEN_MINUTE_CHECK_SET = new set<integer>{ 0, 15, 30, 45, 60 };
    @TestVisible private static final set<integer> THIRTY_MINUTE_CHECK_SET = new set<integer>{ 0, 30, 60 };
    @TestVisible private static final set<integer> SIXTY_MINUTE_CHECK_SET = new set<integer>{ 0, 60 };

    // This is for Test Specific Scenarios
    @TestVisible private static DateTime now;
    // For Logging
    private static final string CLASS_NAME = 'SchedulingFramework';
    
    /**
     * Main framework method that runs through with this logic:
     * WHEN there are active Scheduled Entries, with a set interval
     * IF That interval is a specific time within the next or past MINUTE_ADJUSTMENT_RANGE minutes, select to run
     * OR
     * IF The current run time is within an interval of one or maybe of the possible Interval options (see top level variables)
     * THEN the framework will call the instances of SchedulingInterface on each class (per Scheduled Entry) to run
     * @param sc Standard Schedulable Apex parameter, not used in our functionality
     */
    global void execute(SchedulableContext sc) {
        DateTime currentTime = now == null ? DateTime.now() : now;

        // Schedule itself to run in next interval to ensure no errors below will stop the rescheduling process
        DateTime nextScheduleTime = getNext5MinuteInterval( currentTime );
        ACVUtility.scheduleJob( nextScheduleTime, CLASS_NAME );

        // Temporary Lists for sorting
        List<Scheduled_Entry__c> fiveMinuteLst = new List<Scheduled_Entry__c>();
        List<Scheduled_Entry__c> tenMinuteLst = new List<Scheduled_Entry__c>();
        List<Scheduled_Entry__c> fifteenMinuteLst = new List<Scheduled_Entry__c>();
        List<Scheduled_Entry__c> thiryMinuteLst = new List<Scheduled_Entry__c>();
        List<Scheduled_Entry__c> hourMinuteLst = new List<Scheduled_Entry__c>();

        // Main List to process
        List<Scheduled_Entry__c> processEntryLst = new List<Scheduled_Entry__c>();

        // Get Interval Range of Specific Time for the sake of filtering Specific Time records out
        time lowerTimeRange = Time.newinstance( currentTime.hour(), processMinuteMath( currentTime.minute(), MINUTE_ADJUSTMENT_RANGE, FALSE ), 0, 0 );
        time upperTimeRange = Time.newinstance( currentTime.hour(), processMinuteMath( currentTime.minute(), MINUTE_ADJUSTMENT_RANGE, TRUE ), 0, 0 );
        for ( Scheduled_Entry__c scheduleEntryRec : [ SELECT Id, Class_Name__c, Namespace_Prefix__c, Interval__c, Specific_Time__c FROM Scheduled_Entry__c 
            WHERE Is_Active__c = TRUE AND
            ( Interval__c != :SPECIFIC_TIME 
            OR ( 
                Interval__c = :SPECIFIC_TIME AND 
                Specific_Time__c != null AND 
                Specific_Time__c >= :lowerTimeRange AND 
                Specific_Time__c <= :upperTimeRange
        ) ) ] ) { // Organize Data into Interval Lists to be easily added later
            if ( scheduleEntryRec.Interval__c == EVERY_5_MINUTES ) {
                fiveMinuteLst.add( scheduleEntryRec );
            } else if ( scheduleEntryRec.Interval__c == EVERY_10_MINUTES ) {
                tenMinuteLst.add( scheduleEntryRec );
            } else if ( scheduleEntryRec.Interval__c == EVERY_15_MINUTES ) {
                fifteenMinuteLst.add( scheduleEntryRec );
            } else if ( scheduleEntryRec.Interval__c == EVERY_30_MINUTES ) {
                thiryMinuteLst.add( scheduleEntryRec );
            } else if ( scheduleEntryRec.Interval__c == EVERY_HOUR ) {
                hourMinuteLst.add( scheduleEntryRec );
            } else if ( scheduleEntryRec.Interval__c == SPECIFIC_TIME ) { // Due to query already filtering out the 'bad' specific time records, just auto-add any Specific Time Records
                processEntryLst.add( scheduleEntryRec );
            }
        }

        // Get Proper Intervals to process from current Time and add the right schedulable entries to the process List
        for ( String interval : determineInterval( currentTime ) ) {
            if ( interval == EVERY_5_MINUTES ) {
                processEntryLst.addAll( fiveMinuteLst );
            } else if ( interval == EVERY_10_MINUTES ) {
                processEntryLst.addAll( tenMinuteLst );
            } else if ( interval == EVERY_15_MINUTES ) {
                processEntryLst.addAll( fifteenMinuteLst );
            } else if ( interval == EVERY_30_MINUTES ) {
                processEntryLst.addAll( thiryMinuteLst );
            } else if ( interval == EVERY_HOUR ) {
                processEntryLst.addAll( hourMinuteLst );
            }
        }

        // Execute each Entry
        for ( Scheduled_Entry__c entryToRun : processEntryLst ) {
            try {
                Type classEntryType = Type.forName( entryToRun.Namespace_Prefix__c, entryToRun.Class_Name__c );
                ((SchedulingInterface)classEntryType.newInstance()).executeScheduledLogic();
            } catch ( exception e ) {
                // Alert Splunk Alert
                logToSplunk( entryToRun.Class_Name__c, SplunkHelper.LOGLEVEL.FATAL, CLASS_NAME + ':96', 'Failure to properly run Schedulable Job: ' + e.getMessage(), e.getStackTraceString(), entryToRun.Id );
            }
        }

        // Fire Alert to say job ran
        String location = CLASS_NAME + ':101';
        logToSplunk( CLASS_NAME, SplunkHelper.LOGLEVEL.INFO, location, 'Schedulable Framwork ran', location, UserInfo.getUserId() );
    }

    /**
     * Using the provided DateTime, logic determines what intervals match and should be processed by Framework
     * @param providedDateTime A provided Datetime to check against for interval matching
     * @return  `Set<String>` Set that contains the specific, picklist-matching Intervals that should be ran at the current moment
     */
    private static Set<String> determineInterval( DateTime providedDateTime ) {
        Set<String> returnIntervalDefinitions = new Set<String>();

        // Will 5 minutes ever not run? - Currently, the answer is no.
        // If more granular time options are developed, logic to determine every 5 minutes would be necessary
        returnIntervalDefinitions.add( EVERY_5_MINUTES );

        // Process Check on Each possible Interval
        if ( checkInterval( providedDateTime.time(), TEN_MINUTE_CHECK_SET ) ) { returnIntervalDefinitions.add( EVERY_10_MINUTES ); }
        if ( checkInterval( providedDateTime.time(), FIFTEEN_MINUTE_CHECK_SET ) ) { returnIntervalDefinitions.add( EVERY_15_MINUTES ); }
        if ( checkInterval( providedDateTime.time(), THIRTY_MINUTE_CHECK_SET ) ) { returnIntervalDefinitions.add( EVERY_30_MINUTES ); }
        if ( checkInterval( providedDateTime.time(), SIXTY_MINUTE_CHECK_SET ) ) { returnIntervalDefinitions.add( EVERY_HOUR ); }

        return returnIntervalDefinitions;
    }

    /**
     * If the provided time matches an interval range, based on MINUTE_ADJUSTMENT_RANGE minutes, return true
     * @param providedtime A time to check against the various set of minute intervals
     * @param minuteIntervalSet A set of integers to represent central points of an interval
     * @return  `boolean` Confirmation that the provided time falls within at least one of the provided integer ranges from the interval set
     */
    private static boolean checkInterval( time providedtime, Set<integer> minuteIntervalSet ) {
        boolean foundIntervalMatch = false;
        for ( integer minuteCheck : minuteIntervalSet ) {
            if ( withinInterval( 
                providedtime, 
                processMinuteMath( minuteCheck, MINUTE_ADJUSTMENT_RANGE, false ),
                processMinuteMath( minuteCheck, MINUTE_ADJUSTMENT_RANGE, true ) ) ) 
            {
                foundIntervalMatch = true;
                break;
            }
        }
        return foundIntervalMatch;
    }

    /**
     * If the provided time's minute falls within the range of minutes provided, return true
     * @param timeCheck A specific time, which minute value will be checked against the range of minutes provided
     * @param startingRange The lower end of the minute range
     * @param endingRange The upper end of the minute range
     * @return  `boolean` Confirmation that the provided time's minute falls within the provided minute range
     */
    private static boolean withinInterval( time timeCheck, integer startingRange, integer endingRange ) {
        integer timeCheckMinute = timeCheck.minute();
        return ( timeCheckMinute >= startingRange && timeCheckMinute <= endingRange );
    }

    /**
     * Given a number, adjust it by a pre-determined range (positively or negatively) and return the new number
     * @param currentMinute A provided minute that needs to be adjusted in a direction
     * @param adjustmentRange The range in which the provided minute needs to be adjusted
     * @param isAddition Indicates if the operation to the provided minute should be addition or subtraction
     * @return  `integer` The adjusted minute based off the operation and adjustment range
     */
    private static integer processMinuteMath( integer currentMinute, integer adjustmentRange, boolean isAddition ) {
        integer adjustedMinuteReturn;
        if ( isAddition ) {
            adjustedMinuteReturn = currentMinute + adjustmentRange;
        } else {
            adjustedMinuteReturn = currentMinute - adjustmentRange;
        }
        return adjustedMinuteReturn;
    }

    /**
     * Given a time, take that time's minute number and return the very last digit
     * @param providedTime A given time in which we want to narrow down information
     * @return  `integer` The last digit of the time's minute compoment
     */
    private static integer getLastDigit( time providedTime ) {
        return Integer.valueOf( String.valueOf( providedTime.minute() ).right(1) );
    }

    /**
     * Given a DateTime, calculate the next, rounded 5 minute interval and return it
     * @param providedDT A provided DateTime that we wish to use to find the next, rounded 5 minute interval from
     * @return  `DateTime` The next, rounded 5 minute interval as a date time
     */
    private static DateTime getNext5MinuteInterval( DateTime providedDT ) {
        // Get the last digit of the current time range
        integer minuteCheck = getLastDigit( providedDT.time() );
        integer nextMinuteDigit = 10; // For Cases of 5-9, go to next 0 ending minute interval
        if ( minuteCheck < 5 ) { // For Cases of 0-4, go to next 5 ending minute interval
            nextMinuteDigit = 5;
        }
        // First Step - Remove Seconds
        DateTime nextRunDT = providedDT.addSeconds((-1)*providedDT.second());
        // Second Step - Remove Minutes to go down to nearest 10 Minute Interval
        nextRunDT = nextRunDT.addMinutes((-1)*minuteCheck);
        // Third Step - Add 5 or 10 Minutes (from above calculation) to get result
        nextRunDT = nextRunDT.addMinutes(nextMinuteDigit);

        return nextRunDT;
    }

    /**
     * A standardized logging method to Splunk
     * @param entityName The name of the class to log information about
     * @param logLevel Whether the level of the log is about an error or just informational
     * @param location A very basic string to locate where the log came from
     * @param message A detailed message to further explain the log's intention
     * @param stackTrace A varied level of detail to further explain the log's cause
     */
    private static void logToSplunk( string entityName, SplunkHelper.LOGLEVEL logLevel, string location, string message, string stackTrace, Id providedId ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = logLevel;
        infoLog.location = location;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.componentName = entityName;
        infoLog.sfObject = 'Scheduled Entry';
        infoLog.sfRecordId = providedId;
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS };

        SplunkHelper.buildAndProcessLog( infoLog );
    }
}