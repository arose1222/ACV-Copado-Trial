global class IdentifyGoodAddressServiceApptBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    public static final Integer RESCHEDULE_TIME {
        get {
            if ( RESCHEDULE_TIME == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Identify_Good_Address_Reschedule_Range' LIMIT 1 ];
                RESCHEDULE_TIME = Integer.valueOf( dateRange.Value__c );
            }
            return RESCHEDULE_TIME;
        }
        set;
    }

    global Database.QueryLocator start( Database.BatchableContext BC ) {      
        String query = 'SELECT Id, AppointmentNumber, Street, City, PostalCode, State, Country, Longitude, Latitude, CreatedById';
        query += ' FROM ServiceAppointment WHERE Longitude != null AND Latitude != null AND Exclude_from_Optimization__c = TRUE';
        return Database.getQueryLocator( query );
    }

    global void execute( SchedulableContext sc ) {
        IdentifyGoodAddressServiceApptBatch batchClass = new IdentifyGoodAddressServiceApptBatch();
        database.executebatch( batchClass, 200 );
    }

    global void execute( Database.BatchableContext BC, List<ServiceAppointment> scope ) { 
        Set<String> jsonObjSet = new Set<String>();
        for ( ServiceAppointment saRec : scope ) {
            if ( saRec.Longitude != null && saRec.Latitude != null && FSLWorkProcessUtility.determineSystemOrigin( saRec.CreatedById ) != FSLWorkProcessUtility.LEGACY_INSPECTION_SOURCE ) {
                saRec.Exclude_From_Optimization__c = FALSE; // Removes the exclude from Optimization
                jsonObjSet.add( JSON.serialize( saRec ) );
            }
        }

        // Send Information to Splunk
        SplunkHelper.processBatchLog( createLog( 'IdentifyGoodAddressServiceApptBatch', 'There is instances of ServiceAppointments marked bad, but having Geocode data!', 'IdentifyGoodAddressServiceApptBatch:20', BC.getJobId(), SplunkHelper.LOGLEVEL.INFO ), new List<SplunkHelper.SFErrorRecord>(), jsonObjSet );

        update scope;
    }

    global void finish( Database.BatchableContext BC ) {
        AsyncApexJob a = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob WHERE Id = :BC.getJobId() ];
        if ( a.NumberOfErrors > 0 ) { SplunkHelper.processLog( createLog( 'IdentifyGoodAddressServiceApptBatch', 'There was an issue with some of the batches!', 'IdentifyGoodAddressServiceApptBatch:47', BC.getJobId(), SplunkHelper.LOGLEVEL.FATAL ) ); }
        ACVUtility.scheduleJob( DateTime.now().addMinutes(RESCHEDULE_TIME), 'IdentifyGoodAddressServiceApptBatch' );
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