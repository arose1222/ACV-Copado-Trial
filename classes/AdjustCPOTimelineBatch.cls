//runs in the evening prior to bundler batches

global class AdjustCPOTimelineBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private static Integer CPOExpandDateRange {
        get {
            if ( CPOExpandDateRange == null ) {
                Salesforce_Setting__mdt defaultRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Extend_CPO_Start_Date' LIMIT 1 ];
                CPOExpandDateRange = Integer.valueOf( defaultRange.Value__c );
            }
            return CPOExpandDateRange;
        }
        set;
    }

    private static Integer GMFIAExpandDateRange {
        get {
            if ( GMFIAExpandDateRange == null ) {
                Salesforce_Setting__mdt defaultRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Extend_GMFIA_Start_Date' LIMIT 1 ];
                GMFIAExpandDateRange = Integer.valueOf( defaultRange.Value__c );
            }
            return GMFIAExpandDateRange;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        Date cpoFutureDateRange = Date.today().addDays( CPOExpandDateRange );
        Date gmfiaFutureDateRange = Date.today().addDays( GMFIAExpandDateRange );
        query =  'SELECT Id, EarliestStartTime, DueDate, FSL__InJeopardy__c, WorkType.Work_Type_Unique_ID__c ';
        query += 'FROM ServiceAppointment ';
        query += 'WHERE Status IN ( \'New\',  \'Offer Attempted\') ';
        //All CPO work types
        query +=    'AND ((WorkType.Work_Type_Unique_ID__c IN ';
        query +=        '(\'cpobm\', \'cpofr\', \'cpolnc\', \'cpogm\', \'cpogmcomp\', \'cpohnice\', \'cpohn04\', \'cpohn06\', \'cpohn08\', \'cpohn10\', \'cpohn12\', ';
        query +=        '\'cpohn14\', \'cpohn16\', \'cpohn18\', \'cpohn20\', \'cpopo\', ';
        //All VCPO work types
        query +=        '\'vcpofr\', \'vcpogm\', \'vcpohn\', \'vcpopo\') ';
        query +=        'AND EarliestStartTime < :cpoFutureDateRange) ';

        query +=    'OR (WorkType.Work_Type_Unique_ID__c = \'gmfia\' ';
        query +=        'AND EarliestStartTime < :gmfiaFutureDateRange))';
            // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        AdjustCPOTimelineBatch AdjustCPOTimelineBatchRec = new AdjustCPOTimelineBatch();
        Database.executeBatch(AdjustCPOTimelineBatchRec, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        Map<String, DateTime> WorkTypeAdjustedDateTimeMap = new Map<String, DateTime>{'cpo' => System.today().addDays( CPOExpandDateRange + 1 ), 'gmfia' => System.today().addDays( GMFIAExpandDateRange + 1 )};
        for (ServiceAppointment sa : scope) {
            sa.FSL__InJeopardy__c = TRUE;
            DateTime adjustedDate = sa.WorkType.Work_Type_Unique_ID__c == 'gmfia' ? WorkTypeAdjustedDateTimeMap.get('gmfia') : WorkTypeAdjustedDateTimeMap.get('cpo');
            if ( adjustedDate < sa.DueDate ) { // Only adjust the Earliest Start Time if the Due Date won't be an issue due to Earliest Start Time passing it
                sa.EarliestStartTime = adjustedDate;
            }
        }

        // update records
        Database.SaveResult[] mesgList = Database.update(scope, false);
        for ( Integer position = 0; position < mesgList.size(); position++ ) {
            Database.SaveResult saveRecord = mesgList[position];
            ServiceAppointment serviceAppointmentRec = scope[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(serviceAppointmentRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( serviceAppointmentRec.Id );
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'AdjustCPOTimelineBatch', ACVUtility.currentLineNumber(),
            'AdjustCPOTimelineBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment' }
        );
    }
}