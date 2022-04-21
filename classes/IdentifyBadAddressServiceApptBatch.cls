global class IdentifyBadAddressServiceApptBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    public static final Integer END_TIME {
        get {
            if ( END_TIME == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Identify_Bad_Address_End_Range' LIMIT 1 ];
                END_TIME = -1 * Integer.valueOf( dateRange.Value__c );
            }
            return END_TIME;
        }
        set;
    }

    public static final Integer START_TIME {
        get {
            if ( START_TIME == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Identify_Bad_Address_Start_Range' LIMIT 1 ];
                START_TIME = -1 * Integer.valueOf( dateRange.Value__c );
            }
            return START_TIME;
        }
        set;
    }

    public static final Integer RESCHEDULE_TIME {
        get {
            if ( RESCHEDULE_TIME == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Identify_Bad_Address_Reschedule_Range' LIMIT 1 ];
                RESCHEDULE_TIME = Integer.valueOf( dateRange.Value__c );
            }
            return RESCHEDULE_TIME;
        }
        set;
    }

    global Database.QueryLocator start( Database.BatchableContext BC ) {      
        DateTime timeRangeStart = Datetime.now().addMinutes(START_TIME);
        DateTime timeRangeEnd = Datetime.now().addMinutes(END_TIME);

        String query = 'SELECT Id, AppointmentNumber, Street, City, PostalCode, State, Country';
        query += ' FROM ServiceAppointment WHERE ( Longitude = null OR Latitude = null ) AND Exclude_from_Optimization__c != TRUE AND CreatedDate >= :timeRangeStart AND CreatedDate <= :timeRangeEnd';
        return Database.getQueryLocator( query );
    }

    global void execute( SchedulableContext sc ) {
        IdentifyBadAddressServiceApptBatch batchClass = new IdentifyBadAddressServiceApptBatch();
        database.executebatch( batchClass, 200 );
    }

    global void execute( Database.BatchableContext BC, List<ServiceAppointment> scope ) { 
        Set<String> jsonObjSet = new Set<String>();
        for ( ServiceAppointment saRec : scope ) {
            saRec.Exclude_From_Optimization__c = TRUE; // Excludes from Optimization
            jsonObjSet.add( JSON.serialize( saRec ) );
        }

        // Send Information to Splunk
        SplunkHelper.processBatchLog( createLog( 'IdentifyBadAddressServiceApptBatch', 'There is instances of ServiceAppointments missing Geocode data!', 'IdentifyBadAddressServiceApptBatch:20', BC.getJobId(), SplunkHelper.LOGLEVEL.ERROR ), new List<SplunkHelper.SFErrorRecord>(), jsonObjSet );

        update scope;
    }

    global void finish( Database.BatchableContext BC ) {
        AsyncApexJob a = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id = :BC.getJobId() ];
        if ( a.NumberOfErrors > 0 ) { SplunkHelper.processLog( createLog( 'IdentifyBadAddressServiceApptBatch', 'There was an issue with some of the batches!', 'IdentifyBadAddressServiceApptBatch:67', BC.getJobId(), SplunkHelper.LOGLEVEL.FATAL ) ); }
        ACVUtility.scheduleJob( DateTime.now().addMinutes(RESCHEDULE_TIME), 'IdentifyBadAddressServiceApptBatch' );
    }

    private SplunkHelper.Log createLog( String name, String message, String stackLineMsg, Id recordId, SplunkHelper.LOGLEVEL logLevel ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = logLevel;
        infoLog.location = stackLineMsg;

        infoLog.message = message;
        infoLog.stackTrace = stackLineMsg;
        infoLog.sfRecordId = recordId;
        infoLog.componentName = name;
        infoLog.sfObject = 'ServiceAppointment';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTOR_DISPATCH };

        return infoLog;
    }
}