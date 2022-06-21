public with sharing class workOrderIngestController {

    public static final Id WHOLESALE_INSPECTION = [SELECT id FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1].id;
    public static final Id TRUE_360 = [SELECT id FROM WorkType WHERE name = 'True 360' LIMIT 1].id;
    public static final Id SIRIUS_XM = [SELECT id FROM WorkType WHERE name = 'Sirius XM' LIMIT 1].id;
    public static final Id BUYER_SIGNUP = [SELECT id FROM WorkType WHERE name = 'Buyer Signup' LIMIT 1].id;
    public static final Id AUCTION_SITE = [SELECT id FROM WorkType WHERE name = 'Auction Site' LIMIT 1].id;

    private final static Integer MAX_RESULTS = 5;

    private final static Set<String> PROFILE_NAMES_TO_AVOID_REV_APPTS_SET {
        get {
            if ( PROFILE_NAMES_TO_AVOID_REV_APPTS_SET == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Profile Names to not display Rev Appts' LIMIT 1 ];
                PROFILE_NAMES_TO_AVOID_REV_APPTS_SET = new Set<String>( setting.Value__c.split( ',' ) );
            }
            return PROFILE_NAMES_TO_AVOID_REV_APPTS_SET;
        }
        set;
    }

    @AuraEnabled(Cacheable=true)
    public static Boolean checkToDisplayRevolving() {
        Profile userProfile = [ SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1 ];
        Boolean displayRevolvingAppt = TRUE;
        for ( String checkProfileStr : PROFILE_NAMES_TO_AVOID_REV_APPTS_SET ) {
            if ( userProfile.Name.contains( checkProfileStr ) ) {
                displayRevolvingAppt = FALSE;
                break;
            }
        }

        return displayRevolvingAppt;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getContacts(String searchTerm, List<String> selectedIds){
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING contact (Id, Name WHERE id NOT IN :selectedIds LIMIT :MAX_RESULTS)];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:avatar';
        Contact [] contacts = ((List<Contact>) searchResults[0]);
        for (Contact c : contacts) {
            results.add(new LookupSearchResult(c.Id, 'Contact', accountIcon, c.Name, ''));
        }

        return results;
    }

    @AuraEnabled
    public static string getContactName(id cId){
        Contact c = [SELECT Name FROM Contact WHERE id = :cId LIMIT 1];
        if(c.Name != null){
            return c.Name;
        }
        else{
            return 'Default Contact';
        }

    }

    @AuraEnabled
    public static Response submitWorkOrders(String woInfoJSON, Boolean isProcessingOffers){

        string logMessage = 'Work Order Submission: ' + woInfoJson + '\n';
        Set<string> successfulIds = new Set<string>();
        List<SplunkHelper.SFErrorRecord> errorRecords = new List<SplunkHelper.SFErrorRecord>();
        Response res = new Response();
        SplunkHelper.LOGLEVEL logLevel;
        Exception ex;

        try{
           //convert all needed work order info from the json object
            Map<String, Object> woInfo = new Map<String,Object>();
            woInfo = (Map<String,Object>)JSON.deserializeUntyped(woInfoJSON);
            id account = (id)woInfo.get('accountId');



            string specialInstructions = (string)woInfo.get('notes');
            string city = (string)woInfo.get('city');
            string state = (string)woInfo.get('state');
            string country = (string)woInfo.get('country');
            string zip = (string)woInfo.get('zip');
            string street = (string)woINfo.get('street');
            string timeSelection = (string)woInfo.get('timeSelection');
            boolean notificationRequest = Boolean.valueOf(woInfo.get('NotificationRequest'));

            Id userId = (Id)woInfo.get('userId');
            Id srId = null;
            if(userId != null && timeSelection == 'Now'){
                List<ServiceResource> srList = new List<ServiceResource>([SELECT id FROM ServiceResource WHERE relatedRecordId =: userId LIMIT 1]);
                if(srList.size()>0){
                    srId = srList[0].id;
                }
                else{
                    throw new CustomException('Service Resource record not found for user.');
                }
            }


            id contact;

            Date woDate;
            if(woInfo.get('date') != null){
                woDate = convertDate((string)woInfo.get('date'));
            }

            if(woInfo.get('contact') != null){
            contact = (id)woInfo.get('contact');
            }

            string origin = 'Ingest2';

            id stId;
            if(woInfo.get('serviceTerritory') != null){
                stId = (id)woInfo.get('serviceTerritory');
            }

            DateTime earliestStart;
            DateTime due;

            Map<Id, Integer> vehicleCountMap = new Map<Id, Integer>();
            //check against null value for vehicle count
            vehicleCountMap.put(WHOLESALE_INSPECTION, Integer.valueOf(woInfo.get('WSCount')));
            vehicleCountMap.put(TRUE_360, Integer.valueOf(woInfo.get('T360Count')));
            vehicleCountMap.put(SIRIUS_XM, Integer.valueOf(woInfo.get('SXMCount')));

      final Boolean BUYER_SIGN_UP = Boolean.valueOf(woInfo.get('BSUCheck'));
            if ( BUYER_SIGN_UP ) { vehicleCountMap.put(BUYER_SIGNUP, 0 ); }
            /* Buyer Sign-up doesn't need a Vehicle Count
            integer buyerSignupCount = 0;
            if(Boolean.valueOf(woInfo.get('BSUCheck')) == true ){
                buyerSignupCount = 1;
            }
            vehicleCountMap.put(BUYER_SIGNUP, buyerSignupCount);*/

            //get start and due date information based on work types


            Map<Id, DateTime> dueDateMap = new Map<Id, DateTime>();
            Map<Id, DateTime> startDateMap = new Map<Id, DateTime>();

            List<WorkOrder> woInsertList = new List<WorkOrder>();

            Id inspectionReqId = InspectionRequest.createInspectionRequest(account, vehicleCountMap, timeSelection);

            for(Id wtId : vehicleCountMap.keySet()){
                if( vehicleCountMap.get(wtId) > 0 || ( wtId == BUYER_SIGNUP && BUYER_SIGN_UP ) ){
                    earliestStart = (woDate != null && woDate > Date.today()) ? DateTime.newInstance(woDate, Time.newInstance(0, 0, 0, 0)) : DateTime.now();
                    due = getDueDate(earliestStart, wtId, timeSelection);
                    startDateMap.put(wtId, earliestStart);
                    dueDateMap.put(wtId, due);
                    WorkOrder wo = new WorkOrder(
                        accountId = account,
                        contactId = contact,
                        ServiceTerritoryId = stId,
                        Origin__c = origin,
                        StartDate = earliestStart,
                        Inspection_Number_of_Vehicles__c = vehicleCountMap.get(wtId),
                        Special_Instructions__c = specialInstructions,
                        WorkTypeId = wtId,
                        City = city,
                        Street = street,
                        PostalCode = zip,
                        Country = country,
                        State = state,
                        Created_Without_Line_Items__c = TRUE,
                        Inspection_Request__c = inspectionReqId,
                        DueDate_Adjustment_Engine_Bypass__c = TRUE
                    );

                    if(isProcessingOffers == true && wtId != BUYER_SIGNUP){
                        wo.Processing_Offers__c = true;
                        wo.Subject = 'DISREGARD ---- Processing Offers';
                    }

                    woInsertList.add(wo);
                }
            }

            Database.SaveResult[] woInsertionResults = Database.insert(woInsertList);
            logMessage += workOrderInsertionLog(woInsertionResults);
            successfulIds.addAll(getSuccessfulIds(woInsertionResults));
            errorRecords.addAll(getErrorRecords(woInsertionResults));

            //track successfully inserted wo's
            Set<Id> insertedWos = new Set<Id>();
            for(Database.SaveResult sr : woInsertionResults){
                if(sr.isSuccess()){
                    insertedWos.add(sr.getId());
                }
            }

            Map<Id, ServiceAppointment> saMap = new Map<id, ServiceAppointment>([SELECT id, WorkTypeId, ServiceTerritoryId, parentRecordId, Duration, Account__c FROM ServiceAppointment WHERE parentRecordId in :insertedWos ]);

            //get and update service appointment start time based on work type

            Boolean addSA = false;
            List<ServiceAppointment> saUpdateList = new List<ServiceAppointment>();

            List<ServiceAppointment> selfAssignAppointments = new List<ServiceAppointment>();
            List<ServiceAppointment> createSubscriptionAppointments = new List<ServiceAppointment>();

            for(serviceAppointment sa : saMap.values()){

                if(sa.workTypeId == WHOLESALE_INSPECTION){
                    res.inspectionWOId = sa.parentRecordId;
                    res.inspectionDuration = sa.Duration;
                }
                else if(sa.workTypeId == TRUE_360){
                    res.true360WOId = sa.parentRecordId;
                    res.true360Duration = sa.Duration;
                }
                else if(sa.workTypeId == SIRIUS_XM){
                    res.siriusXMWOId = sa.parentRecordId;
                    res.siriusXMDuration = sa.Duration;
                }

                if(isProcessingOffers == true && sa.workTypeId != BUYER_SIGNUP){
                    sa.Exclude_from_Optimization__c = true;
                    sa.Subject = 'DISREGARD ---- Processing Offers';
                }


                //update earliest start and due date based on map created from work order info
                if(vehicleCountMap.containsKey(sa.workTypeId) && (vehicleCountMap.get(sa.workTypeId) > 0 || ( sa.workTypeId == BUYER_SIGNUP && BUYER_SIGN_UP ))){
                    if(startDateMap.containsKey(sa.workTypeId)){
                        sa.earliestStartTime = startDateMap.get(sa.workTypeId);
                        addSA = true;
                        if(timeSelection == 'Now' && srId != null){
                            sa.SchedStartTime = startDateMap.get(sa.workTypeId);

                            if(vehicleCountMap.get(sa.workTypeId) > 0){
                                sa.SchedEndTime = sa.SchedStartTime.addMinutes(30*vehicleCountMap.get(sa.WorkTypeId));
                            } else {
                                sa.SchedEndTime = sa.SchedStartTime.addMinutes(30);
                            }

                            sa.Status = 'Dispatched';
                            selfAssignAppointments.add(sa);
                        }
                    }
                    if(dueDateMap.containsKey(sa.workTypeId)){
                        sa.dueDate = dueDateMap.get(sa.workTypeId);
                        addSA = true;

                    }
                }

                if(notificationRequest){
                    createSubscriptionAppointments.add(sa);
                }

                //if any info was updated, then add the sa to the list of sa's to be updated
                if(addSA){
                    saUpdateList.add(sa);
                }

                addSA = false;
            }
            Database.SaveResult[] saUpdateResults = Database.update(saUpdateList);
            logMessage += serviceAppointmentUpdateLog(saUpdateResults);
            successfulIds.addAll(getSuccessfulIds(saUpdateResults));
            errorRecords.addAll(getErrorRecords(saUpdateResults));

            List<AssignedResource> arInsertionList = new List<AssignedResource>();

            if(selfAssignAppointments.size() > 0){
                for(ServiceAppointment sa : selfAssignAppointments){
                    arInsertionList.add(new AssignedResource(ServiceResourceId = srId, ServiceAppointmentId = sa.Id));
                }
            }

            Database.SaveResult[] arInsertionResults = Database.Insert(arInsertionList);
            logMessage += assignedResourceInsertionLog(arInsertionResults);
            successfulIds.addAll(getSuccessfulIds(arInsertionResults));
            errorRecords.addAll(getErrorRecords(arInsertionResults));


            List<Email_Notification_Subscription__c> subscriptionInsertList = new List<Email_Notification_Subscription__c>();

            if(createSubscriptionAppointments.size() > 0){
                for(ServiceAppointment sa : createSubscriptionAppointments){
                    subscriptionInsertList.add(new Email_Notification_Subscription__c(
                        Email_on_Request_Inspection_Fulfillment__c = true,
                        Service_Appointment__c = sa.Id,
                        User__c = UserInfo.getUserId(),
                        Account__c = sa.Account__c
                    ));
                }
            }

            Database.SaveResult[] subscriptionInsertionResults = Database.Insert(subscriptionInsertList);
            logMessage += subscriptionInsertionLog(subscriptionInsertionResults);
            successfulIds.addAll(getSuccessfulIds(subscriptionInsertionResults));
            errorRecords.addAll(getErrorRecords(subscriptionInsertionResults));


            res.status = 'Success';

            logLevel = (errorRecords.size() > 0) ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;
        }

        catch(DmlException e){
            res.status = 'Failure';
            res.message = e.getMessage();
            logLevel = SplunkHelper.LOGLEVEL.FATAL;
            ex = e;
        }

        makeLog(logMessage, logLevel, errorRecords, successfulIds, ex);
        return res;
    }

    private static DateTime getDueDate(DateTime earliestStart, Id workTypeId, string timeSelection){
        DateTime due;
        if (timeSelection == 'ASAP'){
            if(workTypeId == WHOLESALE_INSPECTION){
                due = earliestStart.addDays(1);
            }
            else if(workTypeId == TRUE_360){
                due = earliestStart.addDays(3);
            }
            else if(workTypeId == SIRIUS_XM){
                due = earliestStart.addDays(3);
            }
            else if(workTypeId == BUYER_SIGNUP){
                due = earliestStart.addDays(3);
            }
        }
        else{
            due = DateTime.newInstance(earliestStart.year(), earliestStart.month(), earliestStart.day(), 23, 59, 0);
        }
        return due;
    }

    private static Date convertDate(string dateString){
        final Integer DASH_INT_VALUE = 45;

        integer firstDash = dateString.indexOfChar(DASH_INT_VALUE);
        integer secondDash = dateString.indexOfChar(DASH_INT_VALUE, firstDash+1);
        string year = dateString.substring(0,4);
        string month = dateString.substring(firstDash+1, secondDash);
        string day = dateString.substring(secondDash+1, dateString.length());
        return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
    }


    //include info about work created, who made it and info on the job (json passed in)
    public static void makeLog(string logMessage, SplunkHelper.LOGLEVEL logLvl, List<SplunkHelper.SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet, Exception e) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.version = 'v1'; // We don't have versions yet
        log.logLevel = logLvl;
        log.location = 'WorkOrderIngestController: ' + ACVUtility.currentLineNumber();
        log.message = logMessage;
        log.stackTrace = 'WorkOrderIngestController: ' + ACVUtility.currentLineNumber();
        log.sfRecordId = UserInfo.getUserId();
        log.componentName = 'WorkOrderIngestController';
        log.sfObject = 'WorkOrder, ServiceAppointment';
        log.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTOR_DISPATCH };

        if(e != null){
            log.location += ': ' + e.getLineNumber();
            log.stackTrace = e.getStackTraceString();
            log.message += '\n' + e.getMessage();
        }

        SplunkHelper.buildandProcessLog( log, failedSfIdLst, savedSFIdSet );
    }

    public static string workOrderInsertionLog(Database.SaveResult[] results){
        string logMessage;

        for(Database.SaveResult sr : results){

            if(sr.isSuccess()){
                logMessage += 'Work Order ' + sr.getId() + ' successfully inserted.\n';
            }
            else{
                for(Database.Error err : sr.getErrors()){
                    logMessage += 'Error on Work Order insertion: ' + err.getMessage() + '\nStatus Code: ' + err.getStatusCode() + '\nFields:';
                    for(string field : err.getFields()){
                    logMessage += ' ' + field;
                    }
                    logMessage += '\n';
                }
            }
        }


        return logMessage;
    }

    public static string serviceAppointmentUpdateLog(Database.SaveResult[] results){
        string logMessage;

        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                //add success log message
                logMessage += 'ServiceAppointment ' + sr.getId() + ' successfully updated.\n';
            }
            else{
                for(Database.Error err : sr.getErrors()){
                    logMessage += 'Error on Service Appointment ' + sr.getId() + ': ' + err.getMessage() + '\nStatus Code: ' + err.getStatusCode() + '\nFields:';
                    for(string field : err.getFields()){
                    logMessage += ' ' + field;
                    }
                    logMessage += '\n';
                }
            }
        }

        return logMessage;
    }

    public static string assignedResourceInsertionLog(Database.SaveResult[] results){
        string logMessage;

        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                //add success log message
                logMessage += 'Assigned Resource ' + sr.getId() + ' successfully inserted.\n';
            }
            else{
                for(Database.Error err : sr.getErrors()){
                    logMessage += 'Error on Assigned Resource Insertion: ' + err.getMessage() + '\nStatus Code: ' + err.getStatusCode() + '\nFields:';
                    for(string field : err.getFields()){
                    logMessage += ' ' + field;
                    }
                    logMessage += '\n';
                }
            }

        }

        return logMessage;
    }

    public static string subscriptionInsertionLog(Database.SaveResult[] results){
        string logMessage;

        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                //add success log message
                logMessage += 'Email Notification Subscription ' + sr.getId() + ' successfully inserted.\n';
            }
            else{
                for(Database.Error err : sr.getErrors()){
                    logMessage += 'Error on Email Notification Subscription Insertion: ' + err.getMessage() + '\nStatus Code: ' + err.getStatusCode() + '\nFields:';
                    for(string field : err.getFields()){
                    logMessage += ' ' + field;
                    }
                    logMessage += '\n';
                }
            }

        }

        return logMessage;
    }

    public static Set<string> getSuccessfulIds(Database.SaveResult[] results){
        Set<string> ids = new Set<string>();
        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                ids.add(sr.getId());
            }
        }
        return ids;
    }

    public static List<SplunkHelper.SFErrorRecord> getErrorRecords(Database.SaveResult[] results){
        List<SplunkHelper.SFErrorRecord> errors = new List<SplunkHelper.SFErrorRecord>();
        for(Database.SaveResult sr : results){

            for(Database.Error err : sr.getErrors()){
                string errorString;

                errorString += '{\n';
                errorString += '"Status Code" : "' + err.getStatusCode() + '",\n';
                errorString += '"Message" : "' + err.getMessage() + '",\n';
                errorString += '"Fields" : [';
                boolean first = true;
                for(string field : err.getFields()){
                    if(!first){
                        errorString += ', ';
                    }
                    errorString += '"' + field + '"';
                    first = false;
                }
                errorString += ']\n}';

                string recordId = '';
                if(sr.getId() != null){
                    recordId = sr.getId();
                }
                errors.add(new SplunkHelper.SFErrorRecord(recordId, errorString));
            }
        }
        return errors;
    }

    @AuraEnabled
    public static String saveOffer(Id apptOfferId){
        String statusMsg;
        Appointment_Offer__c aoRec = new Appointment_Offer__c();

        List<Appointment_Offer__c> aoRecList = [SELECT Id, Service_Appointment__c, Service_Resource__c, Start_Time__c, End_Time__c, Scheduled_Start__c  FROM Appointment_Offer__c WHERE Id = :apptOfferId LIMIT 1];


        if(aoRecList.size() == 0){
            statusMsg = 'That offer is no longer available';
            return statusMsg;
        } else {
            aoRec = aoRecList[0];
        }

        ServiceAppointment saRec = [ SELECT Id, ServiceTerritory.OperatingHoursId, ServiceTerritoryId, WorkType.EstimatedDuration,
                                                    ServiceTerritory.OperatingHours.TimeZone, WorkTypeId, WorkType.Work_Type_Unique_ID__c, Account.Dealership_ID__c, ParentRecordId
                                                    FROM ServiceAppointment WHERE Id = :aoRec.Service_Appointment__c LIMIT 1 ];


        if ( saRec.ServiceTerritoryId != null ) {
            //Get Work Type Filters
            Set<Date> skipDaySet = OffersAPI.getDownDays( saRec.WorkTypeId );

            if ( !skipDaySet.contains( aoRec.Start_Time__c?.date() ) ) {
                // Restrict dates to ensure appointment happens when promised to customers
                saRec.EarliestStartTime = aoRec.Start_Time__c;
                saRec.DueDate = aoRec.End_Time__c;
                saRec.ArrivalWindowStartTime = aoRec.Start_Time__c;
                saRec.ArrivalWindowEndTime = aoRec.End_Time__c;
                saRec.Duration = saRec.WorkType.EstimatedDuration;
                saRec.DurationType = 'Minutes';
                saRec.Selected_Offer__c = aoRec.Id;
                saRec.SchedStartTime = aoRec.Scheduled_Start__c;
                saRec.SchedEndTime = aoRec.Scheduled_Start__c.addMinutes( Integer.valueOf( saRec.WorkType.EstimatedDuration ) );
                saRec.Exclude_from_Optimization__c = false;
                saRec.Subject = '';
                update saRec;

                AssignedResource ar = new AssignedResource(
                    ServiceAppointmentId = saRec.Id,
                    ServiceResourceId = aoRec.Service_Resource__c
                );
                insert ar;

                WorkOrder woRec = [SELECT Id, Subject, Processing_Offers__c FROM WorkOrder WHERE Id = :saRec.ParentRecordId LIMIT 1];
                woRec.Processing_Offers__c = false;
                woRec.Subject = '';
                update woRec;

                statusMsg = 'Success';
            } else {
                statusMsg = 'Skip Day fail';
            }


        } else {
            statusMsg = 'Service territory fail';
        }
        return statusMsg;
    }

    @AuraEnabled
    public static void saveOfferNoAvailability(Id workOrderId){
        WorkOrder woRec = [SELECT Id, Subject, Processing_Offers__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
        ServiceAppointment saRec = [SELECT Id, Subject, Exclude_from_Optimization__c FROM ServiceAppointment WHERE Work_Order__c = :workOrderId LIMIT 1];

        woRec.Processing_Offers__c = false;
        woRec.Subject = '';
        update woRec;

        saRec.Exclude_from_Optimization__c = false;
        saRec.Subject = '';
        update saRec;


    }

    public class Response{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public Id inspectionWOId;
        @AuraEnabled public Id true360WOId;
        @AuraEnabled public Id siriusXMWOId;
        @AuraEnabled public Decimal inspectionDuration;
        @AuraEnabled public Decimal true360Duration;
        @AuraEnabled public Decimal siriusXMDuration;

    }

}