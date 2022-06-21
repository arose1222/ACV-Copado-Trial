public class FSLWorkProcess {

    private static final String DATE_RANGE_DAYS_DEVELOPERNAME = 'WorkAPI_Date_Grouping_Exclusion_Range';
    private static final String SERVICE_APPT_DEFAULT_TIME_DEVELOPERNAME = 'Service_Appointment_Default_Time';


    final private static Integer MAX_LENGTH_IN_MINUTES {
        get {
            if ( MAX_LENGTH_IN_MINUTES == null ) {
                Salesforce_Setting__mdt maxLength = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'FSL_Max_Length_in_Minutes' LIMIT 1 ];
                MAX_LENGTH_IN_MINUTES = Integer.valueOf( maxLength.Value__c );
            }
            return MAX_LENGTH_IN_MINUTES;
        }
        set;
    }


    final private static Set<String> GROUPABLE_WORKTYPES {
        get {
            if ( GROUPABLE_WORKTYPES == null ) {
                Set<String> labelSet = new Set<String>();
                for ( FSL_Groupable_WorkTypes__mdt rec : [ SELECT Label FROM FSL_Groupable_WorkTypes__mdt WHERE Active__c = TRUE ] ) {
                    labelSet.add( rec.Label );
                }
                GROUPABLE_WORKTYPES = labelSet;
            }
            return GROUPABLE_WORKTYPES;
        }
        set;
    }


    public static final Map<String,Integer> WORKTYPE_MAX_WOLI_MAP {
        get {
            if ( WORKTYPE_MAX_WOLI_MAP == null ) {
                WORKTYPE_MAX_WOLI_MAP = new Map<String,Integer>();
                for(WorkType wt : [SELECT Id, EstimatedDuration, durationType, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_ID__c IN :GROUPABLE_WORKTYPES ]){
                    Decimal workTypeDurationInMinutes = wt.durationType == 'Minutes' ? wt.EstimatedDuration : wt.EstimatedDuration * 60;
                    Integer maxWoli = (MAX_LENGTH_IN_MINUTES/workTypeDurationInMinutes).intValue();
                    WORKTYPE_MAX_WOLI_MAP.put(wt.Work_Type_Unique_ID__c, maxWoli);
                }
            }
            return WORKTYPE_MAX_WOLI_MAP;
        }
        set;
    }

    /*
    * groupWork
    *   GIVEN a List of Work-line based structures
    *   AND the required fields are filled out, per structure
    *   WHEN Work needs to be organized for creation against the database
    *   THEN an organized list of Work Structures are returned, but not committed to the DB
    *
    * @param List<WorkObject> - A list of custom WorkObject structures
    *
    * @return List<WorkStruct> - A list of custom WorkStruct that is ready to be inserted in the DB, both Work and Work Order Line Items
    */
    public static List<WorkStruct> groupWork( List<WorkObject> workLst ) {
        List<WorkStruct> resultLst = new List<WorkStruct>();

        // Need to Query DB for existing Work Orders via woli's guid
        Set<String> guidSet = new Set<String>();
        for ( WorkObject workRec : workLst ) {
            if ( workRec.uuid != null ) {
                guidSet.add( workRec.uuid );
            }
        }

        // Query DB for WorkOrder & WorkOrderLineItem records and organize for reference
        Map<String, WorkOrderLineItem> existingWoliMap = new Map<String, WorkOrderLineItem>();
        for ( WorkOrderLineItem existingWoli : [ SELECT Id, Stock_Number__c, Origin__c, Street, City, State, PostalCode, Country, vin__c, year__c, make__c, model__c, color__c, Reserve_Price__c,
        Title_Status__c, Title_with_Dealer__c, Dealer_Contact__c, Residential__c, Add_To_Run_List__c, Floor_Price__c, Date_Inspected__c, WorkTypeId, WorkType.Name, WorkType.Work_Type_Unique_ID__c,
        External_Record_guid__c, WorkOrder.Account.Dealership_ID__c, WorkOrder.Origin__c, Due_Date__c, Status, Transport_Status__c, Description, Dealership_Name__c, Earliest_Start_Date__c, External_Invoice_Id__c, WorkOrderId, Inspection_Location__c, Series__c, External_Assignment_Id__c, Inspection_Id__c,
        Is_In_Jeopardy__c, Jeopardy_State__c, Lesse_Name__c, Open_Date__c, Maturity_Date__c, Contact_Name__c, Contact_Phone_Number__c, Contact_Mobile_Number__c, Contact_Email__c,
        Customer_Email__c, Driving_Directions__c, Is_Opportunity__c, Exclude_from_Optimization__c, WorkOrder.Street, WorkOrder.City, WorkOrder.State, WorkOrder.PostalCode, WorkOrder.Country, External_Link__c, External_Link_Code__c
        FROM WorkOrderLineItem WHERE IsClosed = FALSE AND External_Record_guid__c IN :guidSet ] ) {
            existingWoliMap.put( existingWoli.External_Record_guid__c, existingWoli );
        }

        Set<Id> existingWorkSet = new Set<Id>();
        Map<String, AddressObject> addressChangeMap = new Map<String, AddressObject>();
        Map<String, String> workTypeChangeMap = new Map<String, String>();

        // Need to link existing work orders by Type & Address match key
        for ( WorkObject workRec : workLst ) {
            WorkOrderLineItem woliRec = existingWoliMap.get( workRec.uuid );
            //Trim leading and trailing spaces
            if( workRec != null ){
                if( workRec.address != null ){
                    if( String.isNotBlank(workRec.address.street) ) workRec.address.street = workRec.address.street.trim();
                    if( String.isNotBlank(workRec.address.city) ) workRec.address.city = workRec.address.city.trim();
                    if( String.isNotBlank(workRec.address.country) ) workRec.address.country = workRec.address.country.trim();
                    if( String.isNotBlank(workRec.address.state) ) workRec.address.state = workRec.address.state.trim();
                    if( String.isNotBlank(workRec.address.postalCode) ) workRec.address.postalCode = workRec.address.postalCode.trim();
                }
            }
            //Group existing
            if ( woliRec != null ) {
                existingWorkSet.add( woliRec.WorkOrderId );

                if ( String.isBlank( workRec.origin ) ) { workRec.origin = woliRec.Origin__c; }

                if ( workRec.address == null ) {
                    workRec.address = new AddressObject();
                } else { // Address Exists, we need to see if it has 'changed' and store the old address for future grouping reference
                    if ( workRec.address.street != woliRec.WorkOrder.street || workRec.address.city != woliRec.WorkOrder.City || workRec.address.state != woliRec.WorkOrder.State ||
                        workRec.address.postalCode != woliRec.WorkOrder.PostalCode ) {
                            AddressObject rec = new AddressObject();
                            rec.street = woliRec.WorkOrder.Street;
                            rec.city = woliRec.WorkOrder.City;
                            rec.state = woliRec.WorkOrder.State;
                            rec.postalCode = woliRec.WorkOrder.PostalCode;
                            rec.country = woliRec.WorkOrder.Country;
                            rec.location = woliRec.Inspection_Location__c;
                            addressChangeMap.put( workRec.uuid, rec );
                    }
                }
                if ( String.isBlank( workRec.address.street ) ) { workRec.address.street = woliRec.Street; }
                if ( String.isBlank( workRec.address.city ) ) {  workRec.address.city = woliRec.City; }
                if ( String.isBlank( workRec.address.state ) ) { workRec.address.state = woliRec.State; }
                if ( String.isBlank( workRec.address.postalCode ) ) {  workRec.address.postalCode = woliRec.PostalCode; }
                if ( String.isBlank( workRec.address.country ) ) {  workRec.address.country = woliRec.Country; }
                if ( String.isBlank( workRec.address.location ) ) {  workRec.address.location = woliRec.Inspection_Location__c; }


                if ( workRec.vehicle == null ) { workRec.vehicle = new VehicleObject(); }
                if ( String.isBlank( workRec.vehicle.vin ) ) { workRec.vehicle.vin = woliRec.VIN__c; }
                if ( String.isBlank( workRec.vehicle.year ) ) { workRec.vehicle.year = woliRec.Year__c; }
                if ( String.isBlank( workRec.vehicle.make ) ) { workRec.vehicle.make = woliRec.Make__c; }
                if ( String.isBlank( workRec.vehicle.model ) ) { workRec.vehicle.model = woliRec.Model__c; }
                if ( String.isBlank( workRec.vehicle.color ) ) { workRec.vehicle.color = woliRec.Color__c; }
                if ( String.isBlank( workRec.vehicle.series ) ) { workRec.vehicle.series = woliRec.Series__c; }

                if ( workRec.workDetail == null ) { workRec.workDetail = new InspectionDetails(); }
                if ( String.isBlank( workRec.workDetail.stockNumber ) ) { workRec.workDetail.stockNumber = woliRec.Stock_Number__c; }
                if ( String.isBlank( workRec.workDetail.titleStatus ) ) { workRec.workDetail.titleStatus = woliRec.Title_Status__c; }
                if ( String.isBlank( workRec.workDetail.isTitleWithDealer ) ) { workRec.workDetail.isTitleWithDealer = String.valueOf( woliRec.Title_with_Dealer__c ); }
                if ( String.isBlank( workRec.workDetail.dealerContactName ) ) { workRec.workDetail.dealerContactName = woliRec.Dealer_Contact__c; }
                if ( String.isBlank( workRec.workDetail.isResidential ) ) { workRec.workDetail.isResidential = String.valueOf( woliRec.Residential__c ); }
                if ( String.isBlank( workRec.workDetail.addToRunList ) ) { workRec.workDetail.addToRunList = String.valueOf( woliRec.Add_To_Run_List__c ); }
                if ( String.isBlank( workRec.workDetail.floorPrice ) ) { workRec.workDetail.floorPrice = String.valueOf( woliRec.Floor_Price__c ); }
                if ( String.isBlank( workRec.workDetail.dateInspected ) && woliRec.Date_Inspected__c != null ) {
                    workRec.workDetail.dateInspected = woliRec.Date_Inspected__c.month() + '-' + woliRec.Date_Inspected__c.day() + '-' + woliRec.Date_Inspected__c.year();
                }
                if ( String.isBlank( workRec.workDetail.type ) ) { workRec.workDetail.type = woliRec.WorkType.Work_Type_Unique_ID__c; }
                else {
                    if ( workRec.workDetail.type != woliRec.WorkType.Work_Type_Unique_ID__c ) {
                        workTypeChangeMap.put( workRec.uuid, woliRec.WorkType.Work_Type_Unique_ID__c );
                    }
                }

                if ( String.isBlank( workRec.workDetail.dealerId ) ) { workRec.workDetail.dealerId = woliRec.WorkOrder.Account.Dealership_ID__c; }
                if ( String.isBlank( workRec.workDetail.dueDate ) && woliRec.Due_Date__c != null ) {
                    workRec.workDetail.dueDate = woliRec.Due_Date__c.month() + '-' + woliRec.Due_Date__c.day() + '-' + woliRec.Due_date__c.year();
                }
                if ( String.isBlank( workRec.workDetail.status ) ) { workRec.workDetail.status = woliRec.Status; }
                if ( String.isBlank( workRec.workDetail.transportStatus ) ) { workRec.workDetail.transportStatus = woliRec.Transport_Status__c; }
                if ( String.isBlank( workRec.workDetail.inspectionNotes ) ) { workRec.workDetail.inspectionNotes = woliRec.Description; }
                if ( String.isBlank( workRec.workDetail.dealershipName ) ) { workRec.workDetail.dealershipName = woliRec.Dealership_Name__c; }
                if ( String.isBlank( workRec.workDetail.earliestStartDate ) && woliRec.Earliest_Start_Date__c != null ) {
                    workRec.workDetail.earliestStartDate = woliRec.Earliest_Start_Date__c.month() + '-' + woliRec.Earliest_Start_Date__c.day() + '-' + woliRec.Earliest_Start_Date__c.year();
                }
                if ( String.isBlank( workRec.workDetail.invoiceId ) ) { workRec.workDetail.invoiceId = woliRec.External_Invoice_Id__c; }
                if ( String.isBlank( workRec.workDetail.assignmentId ) ) { workRec.workDetail.assignmentId = woliRec.External_Assignment_Id__c; }
                if ( String.isBlank( workRec.workDetail.acvInspectionId ) ) { workRec.workDetail.acvInspectionId = woliRec.Inspection_Id__c; }
                if ( String.isBlank( workRec.workDetail.isInJeopardy ) ) { workRec.workDetail.isInJeopardy = String.valueOf( woliRec.Is_In_Jeopardy__c ); }
                if ( String.isBlank( workRec.workDetail.jeopardyState ) ) { workRec.workDetail.jeopardyState = woliRec.Jeopardy_State__c; }
                if ( String.isBlank( workRec.workDetail.lesseName ) ) { workRec.workDetail.lesseName = woliRec.Lesse_Name__c; }
                if ( String.isBlank( workRec.workDetail.openDate ) && workRec.workDetail.openDate != null ) {
                    workRec.workDetail.openDate = woliRec.Open_Date__c.month() + '-' + woliRec.Open_Date__c.day() + '-' + woliRec.Open_Date__c.year();
                }
                if ( String.isBlank( workRec.workDetail.maturityDate ) && workRec.workDetail.maturityDate != null ) {
                    workRec.workDetail.maturityDate = woliRec.Maturity_Date__c.month() + '-' + woliRec.Maturity_Date__c.day() + '-' + woliRec.Maturity_Date__c.year();
                }
                if ( String.isBlank( workRec.workDetail.customerEmail ) ) { workRec.workDetail.customerEmail = woliRec.Customer_Email__c; }
                if ( String.isBlank( workRec.workDetail.drivingDirections ) ) { workRec.workDetail.drivingDirections = woliRec.Driving_Directions__c; }
                if ( String.isBlank( workRec.workDetail.opportunityFlag ) ) { workRec.workDetail.opportunityFlag = String.valueOf( woliRec.Is_Opportunity__c ); }
                if ( String.isBlank( workRec.workDetail.excludedFromOptimization ) ) { workRec.workDetail.excludedFromOptimization = String.valueOf( woliRec.Exclude_from_Optimization__c ); }

                if ( workRec.contactInfo == null ) { workRec.contactInfo = new ContactInformationObject(); }
                if ( String.isBlank( workRec.contactInfo.name ) ) { workRec.contactInfo.name = woliRec.Contact_Name__c; }
                if ( String.isBlank( workRec.contactInfo.phoneNumber ) ) { workRec.contactInfo.phoneNumber = woliRec.Contact_Phone_Number__c; }
                if ( String.isBlank( workRec.contactInfo.mobileNumber ) ) { workRec.contactInfo.mobileNumber = woliRec.Contact_Mobile_Number__c; }
                if ( String.isBlank( workRec.contactInfo.email ) ) { workRec.contactInfo.email = woliRec.Contact_Email__c; }
                if ( String.isBlank( workRec.workDetail.externalLink ) ) { workRec.workDetail.externalLink = woliRec.External_Link__c; }
                if ( String.isBlank( workRec.workDetail.externalLinkCode ) ) { workRec.workDetail.externalLinkCode = woliRec.External_Link_Code__c; }
            }
        }

        Map<String, List<WorkStruct>> groupWorkMap = processWork( workLst, existingWorkSet, addressChangeMap, workTypeChangeMap );

        return getAllWorkStructs(groupWorkMap);
    }

    /*
    * processWork
    *   GIVEN a Work and Work Order Line structure
    *   AND the required fields are filled out, per structure
    *   AND records of both objects are ready to be upserted
    *   WHEN work needs to be organized in preparation
    *   THEN an organized Map of Work Structures are returned, ready to be committed work to the DB
    *
    * @param List<WorkObject> - A list of custom WorkStruct structures
    * @param Set<Id> - A Set of the Ids belonging to existing work order records for the sake of easy querying
    * @param Map<String, AddressObject> - If an address has changed, this map stores the previous address in the DB for reference in grouping logic
    * @param Map<String, String> - If a Work Type has changed, this map stores the previous type in the DB for reference in grouping logic
    *
    * @return Map<String, WorkStruct> - A Map of custom WorkStruct that is ready to be inserted in the DB, both Work and Work Order Line Items
    */
    public static Map<String, List<WorkStruct>> processWork( List<WorkObject> lst, Set<Id> existingWorkSet, Map<String, AddressObject> addressChangeMap, Map<String, String> wtChangeMap ) {
        Map<String, List<WorkStruct>> organizedWorkMap = new Map<String, List<WorkStruct>>();

        // Declare Basic Structure
        Set<String> dealerIdSet = new Set<String>();
        Set<String> streetSet = new Set<String>();
        Map<Id,String> workTypeMap = new Map<Id,String>();
        Set<String> fromIntegrationUuid = new Set<String>();
        for ( WorkObject workRec : lst ) {
            WorkObject tempWoRec = new WorkObject();
            tempWoRec.uuid = workRec.uuid;
            tempWoRec.workDetail = new InspectionDetails();
            if ( wtChangeMap.get( workRec.uuid ) != null ) {
                tempWoRec.workDetail.type = wtChangeMap.get( workRec.uuid );
            } else {
                tempWoRec.workDetail.type = workRec.workDetail.type;
            }
            if ( addressChangeMap.get( workRec.uuid ) != null ) {
                tempWoRec.address = addressChangeMap.get( tempWoRec.uuid );
            } else {
                tempWoRec.address = workRec.address;
            }
            String key = createKey( tempWoRec );
            if ( organizedWorkMap.get( key ) == null ) {
                organizedWorkMap.put( key, new List<WorkStruct>() );
            }
            streetSet.add( tempWoRec.address.street );
            fromIntegrationUuid.add( workRec.uuid);
            dealerIdSet.add( workRec.workDetail.dealerId );
            if ( FSLWorkProcessUtility.availableWTMap.get( tempWoRec.workDetail.type.toLowerCase() ) != null ) {
                workTypeMap.put( FSLWorkProcessUtility.availableWTMap.get( tempWoRec.workDetail.type.toLowerCase() ).Id, tempWoRec.workDetail.type.toLowerCase() );
            }
        }

        // Get Primary Contact Information & organize into Map
        Map<String, Account> dealerIdMap = new Map<String, Account>();
        for ( Account acct : [ SELECT Id, Name, Dealership_ID__c, Primary_Contact__c FROM Account WHERE Dealership_ID__c IN :dealerIdSet ] ) {
            dealerIdMap.put( acct.Dealership_ID__c, acct );
        }

        Map<String,WorkStruct> uuidToWSMap = new Map<String,WorkStruct>();
        // Organize Existing Work Order information into Key (Address:WorkType) map for reference

        for(WorkOrder wo : [ SELECT Id, Street, City, State, PostalCode, Country, WorkTypeId, WorkType.Work_Type_Unique_ID__c, WorkType.Name, LineItemCount, CreatedDate, (SELECT Id, DueDate, EarliestStartTime, ParentRecordId FROM ServiceAppointments ORDER BY DueDate DESC), (SELECT Id, WorkOrderId, Earliest_Start_Date__c, Due_Date__c, External_Record_guid__c FROM WorkOrderLineItems) FROM WorkOrder WHERE Street IN :streetSet AND ( isClosed = FALSE OR ( IsClosed = TRUE AND Id IN :existingWorkSet ) ) AND WorkTypeId IN :workTypeMap.keySet() AND LineItemCount > 0 ]){
            WorkObject woRec = new WorkObject();
            woRec.address = new AddressObject();
            woRec.address.street = wo.Street;
            woRec.address.city = wo.City;
            woRec.address.state = wo.State;
            woRec.address.country = wo.Country;
            woRec.address.postalCode = wo.PostalCode;
            woRec.workDetail = new InspectionDetails();
            woRec.workDetail.type = wo.WorkType.Work_Type_Unique_ID__c;
            if ( !GROUPABLE_WORKTYPES.contains( woRec.workDetail.type.toLowerCase() ) ) { // If not grouping, we need UUID for key logic
                if ( !wo.WorkOrderLineItems.isEmpty() ) {
                    woRec.uuid = wo.WorkOrderLineItems[0]?.External_Record_guid__c;
                } else { continue; }
            }
            String key = createKey( woRec );
            if ( organizedWorkMap.get( key ) != null ) {
                //woRec.workDetail.type = translateWorkTypes.get( wo.WorkType.Name );
                //Create Workstruct for existing WorkOrders so we can assign by duedate and EarliestStartDate of Service Appointments
                WorkStruct ws = new WorkStruct();
                ws.isNewWorkOrder = false;
                ws.existingWoId = wo.Id;

                ws.createdDate = wo.CreatedDate.Date();
                ws.workTypeUniqueId = woRec.workDetail.type.toLowerCase();

                if( wo.ServiceAppointments != null && wo.ServiceAppointments.size() > 0 ){
                    ws.serviceAppt = wo.ServiceAppointments[0];
                    ws.DueDate = wo.ServiceAppointments[0].DueDate.Date();
                    ws.earliestStartDate = wo.ServiceAppointments[0].EarliestStartTime.Date();
                }
                if( wo.WorkOrderLineItems != null && wo.WorkOrderLineItems.size() > 0 ){
                    if ( wo.serviceAppointments != null && !wo.serviceAppointments.isEmpty() && wo.serviceAppointments[0] != null ) {
                        if( ws.serviceApptIdToExternalWOLIIdMap.get(wo.serviceAppointments[0].Id) == null ) ws.serviceApptIdToExternalWOLIIdMap.put(wo.serviceAppointments[0].Id, new List<String>() );
                        for( WorkOrderLineItem woli : wo.WorkOrderLineItems ){
                            ws.workLineMap.put(woli.External_Record_guid__c, woli);
                            ws.numberOfLineItems += 1;


                            if( fromIntegrationUuid.contains(woli.External_Record_guid__c) ) ws.serviceApptIdToExternalWOLIIdMap.get(wo.serviceAppointments[0].Id).add(woli.External_Record_guid__c);    //only care to connect the woli's that are being updated from integration
                            uuidToWSMap.put(woli.External_Record_guid__c, ws);
                        }
                    }
                }
                organizedWorkMap.get( key ).add( ws );
                organizedWorkMap.get( key ).sort();
            }
        }
        Integer DATE_RANGE_DAYS = Integer.valueOf([ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = :DATE_RANGE_DAYS_DEVELOPERNAME LIMIT 1 ].value__c);
        List<String> saTimeSplitList = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = :SERVICE_APPT_DEFAULT_TIME_DEVELOPERNAME LIMIT 1 ].value__c.split(':');
        Time SERVICE_APPT_DEFAULT_TIME = Time.newInstance(Integer.valueOf(saTimeSplitList[0]), Integer.valueOf(saTimeSplitList[1]), Integer.valueOf(saTimeSplitList[2]), Integer.valueOf(saTimeSplitList[3]));

        // Finally Organize existing records and new records into return map structure
        for ( WorkObject workRec : lst ) {
            WorkObject tempRec = new WorkObject();
            tempRec.uuid = workRec.uuid;
            tempRec.workDetail = new InspectionDetails();

            if ( wtChangeMap.get( workRec.uuid ) != null ) {
                tempRec.workDetail.type = wtChangeMap.get( workRec.uuid );
            } else {
                tempRec.workDetail.type = workRec.workDetail.type;
            }
            if ( addressChangeMap.get( workRec.uuid ) != null ) {
                tempRec.address = addressChangeMap.get( tempRec.uuid );
            } else {
                tempRec.address = workRec.address;
            }
            String key = createKey( tempRec );

            WorkStruct thisWorkStruct = null;   //null means that we are going to create a new one
            WorkOrderLineItem thisWoli = new WorkOrderLineItem();
            Date woliDueDate = workRec.workDetail.dueDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.dueDate ) : null;
            Date woliEarliestStartDate = workRec.workDetail.earliestStartDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.earliestStartDate ) : null;

            //Assigns which WorkStruct based on DueDate and Earliest Start Date
            /*If Existing WOLI
                Yes --> did dates change?
                    Yes --> Can Dates be Changed
                        Yes --> thisworkStruct = thisOne
                        No  --> delete existing WOLI logic, grouping into new WO logic
                No  --> Group into existing WorkStuct or create a new one
            */
            if( uuidToWSMap.get(workRec.uuid) != null ){
                WorkOrdeRLineItem tempWoli = uuidToWSMap.get(workRec.uuid).workLineMap.get(workRec.uuid);
                if( (workRec.workDetail.dueDate != null && FSLWorkProcess.makeDate( workRec.workDetail.dueDate ) != tempWoli.Due_Date__c) ||
                    (workRec.workDetail.earliestStartDate != null && FSLWorkProcess.makeDate( workRec.workDetail.earliestStartDate ) != tempWoli.Earliest_Start_Date__c)
                ){
                    if( uuidToWSMap.get(workRec.uuid).canEditDates(DATE_RANGE_DAYS) ){
                        thisWorkStruct = uuidToWSMap.get(workRec.uuid);
                        thisWoli = tempWoli;
                    }else{
                        uuidToWSMap.get(workRec.uuid).woliToDeleteList.add(new WorkOrderLineItem(Id = tempWoli.Id, External_Record_guid__c = workRec.uuid));
                        uuidToWSMap.get(workRec.uuid).workLineMap.remove(workRec.uuid);
                        uuidToWSMap.get(workRec.uuid).numberOfLineItems -= 1;
                    }
                }else{
                    thisWorkStruct = uuidToWSMap.get(workRec.uuid);
                    thisWoli = tempWoli;
                }
            }

            if( thisWorkStruct == null ){   //If null, we are creating a new one
                //WorkStructs are sorted with Nulls First in the DueDate field and then in Due Date from earliest to latest
                Date today = system.today();
                for( WorkStruct ws : organizedWorkMap.get( key ) ){

                    //If the workstucture is maxed out, dont group with it.
                    if(ws.isMaxWoliReached()){continue;}

                    //If the workstructure is not asset verification and the workorder was not created today, dont group with it
                    if(ws.workTypeUniqueId != 'verification' && ws.createdDate != null && ws.createdDate != today){continue;}

                    //Grouping Logic
                    if( woliDueDate == null && woliEarliestStartDate == null ){
                        thisWorkStruct = ws;
                        break;
                    }else if( woliDueDate == null && woliEarliestStartDate != null && ws.earliestStartDate <= woliEarliestStartDate && ws.dueDate != null && woliEarliestStartDate.daysBetween(ws.dueDate) >= DATE_RANGE_DAYS ){
                        //ws.earliestStartDate = woliEarliestStartDate; Not needed as when Earliest Start Date is set, it won't be adjusted
                        thisWorkStruct = ws;
                        break;
                    }else if( woliDueDate != null && woliEarliestStartDate == null && ws.DueDate >= woliDueDate && ws.earliestStartDate != null && ws.earliestStartDate.daysBetween(woliDueDate) >= DATE_RANGE_DAYS){
                        ws.dueDate = woliDueDate;
                        thisWorkStruct = ws;
                        break;
                    }else if( woliDueDate != null && woliEarliestStartDate != null && ws.earliestStartDate <= woliEarliestStartDate && woliEarliestStartDate.daysBetween(woliDueDate) >= DATE_RANGE_DAYS ){
                        //ws.earliestStartDate = woliEarliestStartDate; Not needed as when Earliest Start Date is set, it won't be adjusted
                        ws.dueDate = woliDueDate;
                        thisWorkStruct = ws;
                        break;
                    }
                }
            }

            if(thisWorkStruct == null){ //If none found in for loop, new WorkStruct is created and give it a DueDate and EarliestStartDate
                thisWorkStruct = new WorkStruct();
                thisWorkStruct.dueDate = workRec.workDetail.dueDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.dueDate ) : null;
                thisWorkStruct.earliestStartDate = workRec.workDetail.earliestStartDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.earliestStartDate ) : null;
                thisWorkStruct.serviceAppointmentUpdateNeeded = true;
                organizedWorkMap.get( key ).add( thisWorkStruct );
                organizedWorkMap.get( key ).sort();
                thisWorkStruct.workTypeUniqueId = workRec.workDetail.type.toLowerCase();
            }
            //If existing order found, we assign id
            thisWorkStruct.workRec = new WorkOrder(
                Account = new Account( Dealership_ID__c = workRec.workDetail.dealerId ),
                Street = workRec.address.street,
                City = workRec.address.city,
                State = workRec.address.state,
                Country = workRec.address.country,
                PostalCode = workRec.address.postalCode,
                WorkTypeId = FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).Id,
                ContactId = dealerIdMap.get( workRec.workDetail.dealerId ) != null ? dealerIdMap.get( workRec.workDetail.dealerId ).Primary_Contact__c : null,
                Subject = dealerIdMap.get( workRec.workDetail.dealerId ) != null ? dealerIdMap.get( workRec.workDetail.dealerId ).Name + ' ' + FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).Name : FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).Name,
                Id = thisWorkStruct.existingWOId != null ? thisWorkStruct.existingWOId : null //If Existing WorkOrder found, we will upsert on Id. Otherwise this is null
            );
            //Assign Work Order Line Item values
            thisWoli.Make__c = workRec.vehicle.make;
            thisWoli.Model__c = workRec.vehicle.model;
            thisWoli.Year__c = workRec.vehicle.year;
            thisWoli.Stock_Number__c = workRec.workDetail.stockNumber;
            thisWoli.VIN__c = workRec.vehicle.vin;
            thisWoli.WorkTypeId = FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).Id;
            thisWoli.State = workRec.address.state;
            thisWoli.City = workRec.address.city;
            thisWoli.Street = workRec.address.street;
            thisWoli.PostalCode = workRec.address.postalCode;
            thisWoli.Country = workRec.address.country;
            thisWoli.Color__c = workRec.vehicle.color;
            thisWoli.Title_with_Dealer__c = ( workRec.workDetail.isTitleWithDealer != null && !String.isBlank( workRec.workDetail.isTitleWithDealer ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.isTitleWithDealer ) : FALSE;
            thisWoli.Dealer_Contact__c = workRec.workDetail.dealerContactName;
            thisWoli.Residential__c = ( workRec.workDetail.isResidential != null && !String.isBlank( workRec.workDetail.isResidential ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.isResidential ) : FALSE;
            thisWoli.Add_To_Run_List__c = ( workRec.workDetail.addToRunList != null && !String.isBlank( workRec.workDetail.addToRunList ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.addToRunList ) : FALSE;
            thisWoli.Floor_Price__c = ( workRec.workDetail.floorPrice != null && !String.isBlank( workRec.workDetail.floorPrice ) ) ? Decimal.valueOf( workRec.workDetail.floorPrice ) : null;
            thisWoli.Date_Inspected__c = ( workRec.workDetail.dateInspected != null && !String.isBlank( workRec.workDetail.dateInspected ) ) ? FSLWorkProcess.makeDate( workRec.workDetail.dateInspected ) : null;
            thisWoli.Duration = FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).EstimatedDuration;
            thisWoli.DurationType = FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).DurationType;
            thisWoli.External_Record_guid__c = workRec.uuid;
            thisWoli.Due_Date__c = workRec.workDetail.dueDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.dueDate ) : null;
            thisWoli.Status = !String.isBlank( workRec.workDetail.status ) ? workRec.workDetail.status : 'New';
            thisWoli.Transport_Status__c = workRec.workDetail.transportStatus;
            thisWoli.Description = workRec.workDetail.inspectionNotes;
            thisWoli.Dealership_Name__c = workRec.workDetail.dealershipName;
            thisWoli.Earliest_Start_Date__c = workRec.workDetail.earliestStartDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.earliestStartDate ) : null;
            thisWoli.External_Invoice_Id__c = workRec.workDetail.invoiceId;
            thisWoli.Origin__c = workRec.origin;
            thisWoli.Series__c = workRec.vehicle.series;
            thisWoli.External_Assignment_Id__c = workRec.workDetail.assignmentId;
            thisWoli.Inspection_Id__c = workRec.workDetail.acvInspectionId;
            thisWoli.Is_In_Jeopardy__c = ( workRec.workDetail.isInJeopardy != null && !String.isBlank( workRec.workDetail.isInJeopardy ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.isInJeopardy ) : FALSE;
            thisWoli.Jeopardy_State__c = workRec.workDetail.jeopardyState;
            thisWoli.Lesse_Name__c = workRec.workDetail.lesseName;
            thisWoli.Open_Date__c = workRec.workDetail.openDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.openDate ) : null;
            thisWoli.Maturity_Date__c = workRec.workDetail.maturityDate != null ? FSLWorkProcess.makeDate( workRec.workDetail.maturityDate ) : null;
            thisWoli.Customer_Email__c = workRec.workDetail.customerEmail;
            thisWoli.Driving_Directions__c = workRec.workDetail.drivingDirections;
            thisWoli.Contact_Name__c = ( workRec.contactInfo != null ) ? workRec.contactInfo.name : null;
            thisWoli.Contact_Phone_Number__c = ( workRec.contactInfo != null ) ? workRec.contactInfo.phoneNumber : null;
            thisWoli.Contact_Mobile_Number__c = ( workRec.contactInfo != null ) ? workRec.contactInfo.mobileNumber : null;
            thisWoli.Contact_Email__c = ( workRec.contactInfo != null ) ? workRec.contactInfo.email : null;
            thisWoli.Is_Opportunity__c = ( workRec.workDetail.opportunityFlag != null && !String.isBlank( workRec.workDetail.opportunityFlag ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.opportunityFlag ) : FALSE;
            thisWoli.Exclude_From_Optimization__c = ( workRec.workDetail.excludedFromOptimization != null && !String.isBlank( workRec.workDetail.excludedFromOptimization ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.excludedFromOptimization ) : FALSE;
            thisWoli.External_Link__c = workRec.workDetail.externalLink;
            thisWoli.External_Link_Code__c = workRec.workDetail.externalLinkCode;

            if( thisWorkStruct.serviceAppt != null ) {
                thisWorkStruct.serviceAppointmentUpdateNeeded = true;
                thisWorkStruct.serviceAppt.FSL__InJeopardy__c = ( workRec.workDetail.isInJeopardy != null && !String.isBlank( workRec.workDetail.isInJeopardy ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.isInJeopardy ) : FALSE;
                thisWorkStruct.serviceAppt.Exclude_From_Optimization__c = ( workRec.workDetail.excludedFromOptimization != null && !String.isBlank( workRec.workDetail.excludedFromOptimization ) ) ? FSLWorkProcess.makeBool( workRec.workDetail.excludedFromOptimization ) : FALSE;
                thisWorkStruct.serviceAppt.FSL__InJeopardyReason__c = workRec.workDetail.jeopardyState;

                //For Existing WO - If Dates can be changed, we need to update the Service Appointment with the new dates
                if ( thisWorkStruct.canEditDates(DATE_RANGE_DAYS) ) {
                    if(thisWoli.Due_Date__c != null ) thisWorkStruct.serviceAppt.DueDate = DateTime.newInstance(thisWoli.Due_Date__c, SERVICE_APPT_DEFAULT_TIME);
                    if(thisWoli.Earliest_Start_Date__c != null && thisWorkStruct.workLineMap.size() == 1 ) thisWorkStruct.serviceAppt.EarliestStartTime = DateTime.newInstance(thisWoli.Earliest_Start_Date__c, SERVICE_APPT_DEFAULT_TIME);
                }
            }

            thisWorkStruct.workLineMap.put(thisWoli.External_Record_guid__c, thisWoli);

            thisWorkStruct.numberOfLineItems += 1;

            if( fromIntegrationUuid.contains(thisWoli.External_Record_guid__c) ) thisWorkStruct.externalIdsFromIntegration.add(thisWoli.External_Record_guid__c);
        }

        return organizedWorkMap;
    }

    /*
    * commitWork
    *   GIVEN a Work and Work Order Line structure
    *   AND the required fields are filled out, per structure
    *   AND records of both objects are ready to be upserted
    *   WHEN organized work is ready to be upserted into the DB
    *   THEN a list of ProcessedWorkStruct are returned, with committed work to the DB
    *
    * @param List<WorkStruct> - A list of custom WorkStruct structures
    *
    * @return List<ProcessedWorkStruct> - A list of custom ProcessedWorkStruct that has been attempted to be upserted in the DB, both Work and Work Order Line Items, with proper success or error information attached
    */
    public static List<ProcessedWorkStruct> commitWork( List<WorkStruct> workLst ) {
        List<ProcessedWorkStruct> returnLst = new List<ProcessedWorkStruct>();
        Map<String, ProcessedWorkStruct> returnMap = new Map<String, ProcessedWorkStruct>();
        Set<Id> workOrderIdCheckSet = new Set<Id>();
        List<WorkOrder> upsertWorkLst = new List<WorkOrder>();
        List<WorkOrderLineItem> woliToDeleteList = new List<WorkOrderLineItem>();
        List<ServiceAppointment> saToUpdateList = new List<ServiceAppointment>();
        Map<Id, WorkStruct> existingWoIdToWorkStruct = new Map<Id, WorkStruct>();
        Map<Id, List<String> > serviceApptIdToExternalWOLIIdMap = new Map<Id, List<String> >();
        List<String> saTimeSplitList = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = :SERVICE_APPT_DEFAULT_TIME_DEVELOPERNAME LIMIT 1 ].value__c.split(':');
        Time SERVICE_APPT_DEFAULT_TIME = Time.newInstance(Integer.valueOf(saTimeSplitList[0]), Integer.valueOf(saTimeSplitList[1]), Integer.valueOf(saTimeSplitList[2]), Integer.valueOf(saTimeSplitList[3]));

        // Remove any Work Structures that are missing a Work Order definition
        for ( Integer index = 0; index < workLst.size(); index++ ) {
            WorkStruct workStructRec = workLst[index];
            if ( workStructRec.workRec != null ) {
                if ( workStructRec.existingWOId == null || ( workStructRec.existingWOId != null && !workOrderIdCheckSet.contains( workStructRec.existingWOId ) ) ) {
                    upsertWorkLst.add( workStructRec.workRec );
                    if ( workStructRec.existingWOId != null ) { workOrderIdCheckSet.add( workStructRec.existingWOId ); } // Avoid duplicate WOs in List
                    if( workStructRec.woliToDeleteList.size() > 0 ) woliToDeleteList.addAll(workStructRec.woliToDeleteList);    //Woli's To Delete
                    if( workStructRec.serviceAppt != null && workStructRec.serviceAppointmentUpdateNeeded ){ //Service Appointment Dates to update on existing Service Appointments
                        saToUpdateList.add(workStructRec.serviceAppt);
                        serviceApptIdToExternalWOLIIdMap.putAll(workStructRec.serviceApptIdToExternalWOLIIdMap);
                    }
                }
            } else if ( workStructRec.workRec == null ) {
                for ( WorkOrderLineItem woli : workStructRec.workLineMap.values() ) {
                    //returnLst.add( new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ 'A work order was missing from this structure' } ) );
                    returnMap.put( woli.External_Record_guid__c, new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ 'A work order was missing from this structure' } ) );
                }
                // Order needs to be maintained for future reference
                workLst.remove( index );
                index--;
            } else {
                for ( WorkOrderLineItem woli : workStructRec.workLineMap.values() ) {
                    //returnLst.add( new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ 'There was an issue processing this request structure' } ) );
                    returnMap.put( woli.External_Record_guid__c, new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ 'There was an issue processing this request structure' } ) );
                }
                // Order needs to be maintained for future reference
                workLst.remove( index );
                index--;
            }
        }

        if ( !upsertWorkLst.isEmpty() ) {
            List<WorkOrderLineItem> createLineItemLst = new List<WorkOrderLineItem>();

            List<WorkOrder> deleteNewWorkLst = new List<WorkOrder>();
            Set<Id> deleteWOIdCheckSet = new Set<Id>();
            Set<Id> deleteNewWorkIdSet = new Set<Id>();

            // Upsert Work Orders
            try {
                List<Database.UpsertResult> dbResultLst = Database.upsert( upsertWorkLst, FALSE );

                for ( Integer index = 0; index < dbResultLst.size(); index++ ) {
                    Database.UpsertResult dbResultRec = dbResultLst[index];
                    WorkOrder workRec = upsertWorkLst[index];

                    // Remove any unsuccessful records and setup error return records
                    if ( !dbResultRec.isSuccess() ) {
                        WorkOrder badWorkOrder = upsertWorkLst.remove( index );
                        WorkStruct badWorkStruct = workLst.remove( index );
                        index--;

                        List<String> errorMsgLst = new List<String>();
                        for( Database.Error errorRec : dbResultRec.getErrors() ) {
                            errorMsgLst.add( errorRec.getMessage() );
                        }

                        for ( WorkOrderLineItem woli : badWorkStruct.workLineMap.values() ) {
                            //returnLst.add( new ProcessedWorkStruct( woli.External_Record_guid__c, errorMsgLst ) );
                            returnMap.put( woli.External_Record_guid__c, new ProcessedWorkStruct( woli.External_Record_guid__c, errorMsgLst ) );
                        }

                        if ( upsertWorkLst.isEmpty() ) {
                            break;
                        }
                    } else {
                        // Add Work Order Id to Work Order Line Items on success
                        for ( WorkOrderLineItem workItemRec : workLst[index].workLineMap.values() ) {
                            if( workLst[index].externalIdsFromIntegration.contains(workItemRec.External_Record_guid__c) ){
                                if(workItemRec.WorkOrderId == null) workItemRec.WorkOrderId = workRec.Id;
                                createLineItemLst.add( workItemRec );
                            }
                        }
                    }

                    // If created, note so we know to possible delete on Work Order Line Item failure
                    if ( dbResultRec.isCreated() ) {
                        deleteNewWorkIdSet.add( workRec.Id );   //Also used to query Service Appointments of new Work Orders
                        existingWoIdToWorkStruct.put( workRec.Id, workLst[index] );
                    }
                }
            } catch ( exception e ) {
                system.debug( e.getMessage() );
                system.debug( e.getStackTraceString() );

                for ( WorkStruct ws : workLst ) {
                    for ( WorkOrderLineItem woli : ws.workLineMap.values() ) {
                        //returnLst.add( new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ e.getMessage() } ) );
                        returnMap.put( woli.External_Record_guid__c, new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ e.getMessage() } ) );
                    }
                }

                FSLWorkProcess.makeLog( e );

                //return returnLst;
                return returnMap.values();
            }
            // Delete Work Order Line Items
            Map<Id,List<WorkOrderLineItem>> woIdToDeletedWOLIMap = new Map<Id,List<WorkOrderLineItem>>();
            if( woliToDeleteList.size() > 0 ){
                try{
                    List<Database.DeleteResult> deleteResultList = Database.delete(woliToDeleteList, FALSE);
                    for( Integer i=0; i< deleteResultList.size(); i++ ){
                        Database.DeleteResult deleteResult = deleteResultList[i];
                        if( !deleteResult.isSuccess() ){
                            //returnLst.add( new ProcessedWorkStruct(woliToDeleteList[i].External_Record_guid__c, new List<String>{'There were errors with deleting Work Line Items. Please contact your Salesforce Administrator.'}) );
                            returnMap.put( woliToDeleteList[i].External_Record_guid__c, new ProcessedWorkStruct(woliToDeleteList[i].External_Record_guid__c, new List<String>{'There were errors with deleting Work Line Items. Please contact your Salesforce Administrator.'}) );
                        }else{
                            WorkOrderLineItem woli = woliToDeleteList[i];
                            if( woIdToDeletedWOLIMap.get(woli.WorkOrderId) == null ){
                                woIdToDeletedWOLIMap.put(woli.WorkOrderId, new List<WorkOrderLineItem>());
                            }
                            woIdToDeletedWOLIMap.get(woli.WorkOrderId).add(woli);
                        }
                    }
                }catch(Exception e){
                    system.debug( e.getMessage() );
                    system.debug( e.getStackTraceString() );
                    FSLWorkProcess.makeLog(e);
                }
            }
            // Upsert Work Order Line Items
            Set<Id> deleteWorkIdSet = new Set<Id>();
            Set<Id> goodWorkIdSet = new Set<Id>();
            try {
                List<Database.UpsertResult> dbResultLst = Database.upsert( createLineItemLst, WorkOrderLineItem.Fields.External_Record_guid__c, FALSE );

                for ( Integer index = 0; index < dbResultLst.size(); index++ ) {
                    Database.UpsertResult dbResultRec = dbResultLst[index];
                    WorkOrderLineItem woliRec = createLineItemLst[index];

                    // Remove any unsuccessful records and setup error return records
                    if ( !dbResultRec.isSuccess() ) {
                        List<String> errorMsgLst = new List<String>();
                        for( Database.Error errorRec : dbResultRec.getErrors() ) {
                            errorMsgLst.add( errorRec.getMessage() );
                        }
                        //returnLst.add( new ProcessedWorkStruct( woliRec.External_Record_guid__c, errorMsgLst ) );
                        returnMap.put( woliRec.External_Record_guid__c, new ProcessedWorkStruct( woliRec.External_Record_guid__c, errorMsgLst ) );

                        // Ensures any Work Orders are deleted later if the Work Order Line Item has an issue, only if it was a new Work Order
                        if ( deleteNewWorkIdSet.contains( woliRec.WorkOrderId ) ) {
                            if ( !deleteWOIdCheckSet.contains( woliRec.WorkOrderId ) ) {
                                deleteWOIdCheckSet.add( woliRec.WorkOrderId );
                                deleteNewWorkLst.add( new WorkOrder(
                                    Id = woliRec.WorkOrderId
                                ) );
                            }
                        }
                    } else { // Successful Records Processing
                        //returnLst.add( new ProcessedWorkStruct( woliRec.External_Record_guid__c ) );
                        returnMap.put( woliRec.External_Record_guid__c, new ProcessedWorkStruct( woliRec.External_Record_guid__c ) );
                        goodWorkIdSet.add( woliRec.WorkOrderId );
                    }
                }
            } catch ( exception e ) {
                system.debug( e.getMessage() );
                system.debug( e.getStackTraceString() );

                for ( WorkOrderLineItem woli : createLineItemLst ) {
                    //returnLst.add( new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ e.getMessage() } ) );
                    returnMap.put( woli.External_Record_guid__c, new ProcessedWorkStruct( woli.External_Record_guid__c, new List<String>{ e.getMessage() } ) );

                    // Ensures any Work Orders are deleted later if the Work Order Line Item has an issue , only if it was a new Work Order
                    if ( deleteNewWorkIdSet.contains( woli.WorkOrderId ) ) {
                        if ( !deleteWOIdCheckSet.contains( woli.WorkOrderId ) ) {
                            deleteWOIdCheckSet.add( woli.WorkOrderId );
                            deleteNewWorkLst.add( new WorkOrder(
                                Id = woli.WorkOrderId
                            ) );
                        }
                    }
                }

                FSLWorkProcess.makeLog( e );
            }

            // Verify Only Work Orders are deleted that have zero successful line items created
            for ( Integer index = 0; index < deleteNewWorkLst.size(); index++ ) {
                WorkOrder woRec = deleteNewWorkLst[index];

                if ( goodWorkIdSet.contains( woRec.Id ) ) {
                    deleteNewWorkLst.remove( index );
                    index--;
                }
            }

            //Update Service Appointments DueDate and EarliestStartTime
            if( deleteNewWorkIdSet.size() > 0 ){
                for(ServiceAppointment sa : [ SELECT Id, DueDate, EarliestStartTime, ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN :deleteNewWorkIdSet ]){
                    if( existingWoIdToWorkStruct.get(sa.ParentRecordId) != null && existingWoIdToWorkStruct.get(sa.ParentRecordId).dueDate != null ){
                        sa.DueDate = DateTime.newInstance(existingWoIdToWorkStruct.get(sa.ParentRecordId).dueDate, SERVICE_APPT_DEFAULT_TIME);
                        sa.Original_Due_Date__c = sa.DueDate;
                    }
                    if( existingWoIdToWorkStruct.get(sa.ParentRecordId) != null && existingWoIdToWorkStruct.get(sa.ParentRecordId).earliestStartDate != null ){
                        sa.EarliestStartTime = DateTime.newInstance(existingWoIdToWorkStruct.get(sa.ParentRecordId).earliestStartDate, SERVICE_APPT_DEFAULT_TIME);
                    }
                    serviceApptIdToExternalWOLIIdMap.put( sa.Id, new List<String>() );
                    for( WorkOrderLineItem woli : existingWoIdToWorkStruct.get(sa.ParentRecordId).workLineMap.values() ) {
                        serviceApptIdToExternalWOLIIdMap.get(sa.Id).add(woli.External_Record_guid__c);
                    }
                    saToUpdateList.add(sa);
                }
            }
            List<WorkOrderLineItem> wolisToUndelete = new List<WorkOrderLineItem>();
            if( saToUpdateList.size() > 0){
                try{
                    List<Database.SaveResult> updateResultList = Database.update(saToUpdateList, FALSE);
                    for( Integer i=0; i< updateResultList.size(); i++ ){
                        Database.SaveResult updateResult = updateResultList[i];
                        if( !updateResult.isSuccess() ){
                            for( String woliExternalRecordGuid : serviceApptIdToExternalWOLIIdMap.get(saToUpdateList[i].Id) ){
                                returnMap.put( woliExternalRecordGuid, new ProcessedWorkStruct( woliExternalRecordGuid, new List<String>{'There were issues updating the Due Date and Earlist Start Time on Service Appointments. Please contact your Salesforce Administrator with following Error Message: ' + updateResult.getErrors()[0]?.getMessage() }) );
                            }
                            if ( deleteNewWorkIdSet.contains( saToUpdateList[i].ParentRecordId ) ) {
                                WorkOrder tempWO = new WorkOrder( Id = saToUpdateList[i].ParentRecordId );
                                if( !deleteNewWorkLst.contains(tempWO) ){
                                    if ( !deleteWOIdCheckSet.contains( tempWO.Id ) ) {
                                        deleteWOIdCheckSet.add( tempWO.Id );
                                        deleteNewWorkLst.add( tempWO );
                                    }
                                }
                            }
                            if( woIdToDeletedWOLIMap.get(saToUpdateList[i].ParentRecordId) != null && woIdToDeletedWOLIMap.get(saToUpdateList[i].ParentRecordId).size() > 0 ){
                                wolisToUndelete.addAll( woIdToDeletedWOLIMap.get(saToUpdateList[i].ParentRecordId) );
                            }
                            system.debug(updateResult.getErrors());
                        }
                    }
                }catch(Exception e){
                    system.debug( e.getMessage() );
                    system.debug( e.getStackTraceString() );
                    FSLWorkProcess.makeLog(e);
                }
            }
            // Any line items that have errors, ensure no Work Order stays in the system
            if ( !deleteNewWorkLst.isEmpty() ) {
                delete deleteNewWorkLst;
            }
            //Undelete WOLI's if a step in there process failed and we need to restore
            if( !wolisToUndelete.isEmpty() ){
                undelete wolisToUndelete;
            }
        }

        //return returnLst;
        return returnMap.values();
    }

    public class WorkStruct implements Comparable{
        public WorkOrder workRec;
        public Map<String, WorkOrderLineItem> workLineMap;
        public Date dueDate;
        public Date earliestStartDate;
        public Id existingWOId;
        public Boolean serviceAppointmentUpdateNeeded;
        public ServiceAppointment serviceAppt;
        public Boolean isNewWorkOrder;    //If false, this means dates can't be adjusted UNLESSS this has only 1 Work Order Line Item is assigned. Then we can update the serviceAppt's dates
        public List<WorkOrderLineItem>  woliToDeleteList;
        public Map<Id, List<String>> serviceApptIdToExternalWOLIIdMap;
        public Set<String> externalIdsFromIntegration;
        public Boolean addressChange;
        public Integer numberOfLineItems;
        public String workTypeUniqueId;
        public Date createdDate;

        public WorkStruct(){
            externalIdsFromIntegration = new Set<String>();
            workRec = null;
            workLineMap = new Map<String, WorkOrderLineItem>();
            woliToDeleteList = new List<WorkOrderLineItem>();
            dueDate = null;
            existingWOId = null;
            serviceAppt = null;
            isNewWorkOrder = true;
            serviceAppointmentUpdateNeeded = false;
            serviceApptIdToExternalWOLIIdMap = new Map<Id, List<String>>();
            addressChange = FALSE;
            numberOfLineItems = 0;
            workTypeUniqueId = null;
            createdDate = null;
        }
        /*We can edit dates on 3 conditions:
            1. Brand new Work Order
            2. Existing Work Order when there is only 1 Work Order Line Item assigned
            3. Existing Work Order where a new WOLI is getting grouped and will be adjusting the dates AND still passes DATE_RANGE_DAYS condition on adjustment*/
        public Boolean canEditDates( Integer DATE_RANGE_DAYS ){
            return (isNewWorkOrder) ||
                   (!isNewWorkOrder && workLineMap != null && workLineMap.values().size() == 1) ||
                   (!isNewWorkOrder && workLineMap != null && workLineMap.values().size() > 1 && earliestStartDate.daysBetween(dueDate) >= DATE_RANGE_DAYS )
            ? true : false;
        }

        public Integer compareTo(Object objToCompare){
            WorkStruct ws = (WorkStruct)objToCompare;
            if( this.dueDate == ws.dueDate ) return 0;
            //Sort Nulls first
            if( this.dueDate == null ) return -1;
            if( ws.dueDate == null ) return 1;

            return this.dueDate > ws.DueDate ? 1 : -1;
        }

        public Boolean isMaxWoliReached(){
            if(numberOfLineItems < WORKTYPE_MAX_WOLI_MAP.get(workTypeUniqueId)){
                return false;
            } else {
                return true;
            }
        }
    }

    public class ProcessedWorkStruct {
        public String uuid;
        public Boolean hasErrors;
        public List<String> errorMessageLst;

        public ProcessedWorkStruct( String uuid ) {
            this.uuid = uuid;
            this.hasErrors = FALSE;
        }

        public ProcessedWorkStruct( String uuid, List<String> errorMessageLst ) {
            this.uuid = uuid;
            this.hasErrors = TRUE;
            this.errorMessageLst = errorMessageLst;
        }
    }

    /*
    * createKey
    *   GIVEN a WorkObject structure
    *   AND address and WorkType information is defined
    *   WHEN a key needs to be defined around unique Work Order structure
    *   THEN a key is generated, based off Address and WorkType information
    *   UNLESS the given worktype is in the metadata to exclude from grouping
    *
    * @param WorkObject - A custom structure that needs a work order unique key defined
    *
    * @return String - A comma and colon based key, utilitzing Address and WorkType Name
    */
    public static String createKey( WorkObject workRec ) {
        return !GROUPABLE_WORKTYPES.contains( workRec.workDetail.type.toLowerCase() ) ? workRec.uuid : workRec.address.toString().toLowerCase() + ':' + FSLWorkProcessUtility.availableWTMap.get( workRec.workDetail.type.toLowerCase() ).Name;
    }

    /*
    * makeBool
    *   GIVEN a String that (ideally) represents a Boolean
    *   WHEN a String needs to be converted to a Boolean
    *   THEN a Boolean is defined and returned
    *
    * @param String - A String that (ideally) represents a Boolean
    *
    * @return Boolean - A boolean representation of the String provided
    */
    public static Boolean makeBool( String val ) {
        if ( val.toLowerCase() == 'yes' || val.toLowerCase() == 'true' ) {
            return TRUE;
        }
        return FALSE;
    }

    /*
    * makeDate
    *   GIVEN a String that (ideally) represents a Date
    *   WHEN a String needs to be converted to a Date
    *   THEN a Date is defined and returned
    *
    * @param String - A String that (ideally) represents a Date
    *
    * @return Date - A Date representation of the String provided
    */
    public static Date makeDate( String val ) {
        try {
            return Date.valueOf( val );
        } catch ( exception e ) {
            val = val.replaceAll( '-', '/' );
            List<String> dateArray = val.split( '/' );
            Integer year = dateArray[2].length() == 2 ? Integer.valueOf( '20' + dateArray[2] ) : Integer.valueOf( dateArray[2] );
            return Date.newInstance( year, Integer.valueOf( dateArray[0] ), Integer.valueOf( dateArray[1] ) );
        }
    }

    public static void makeLog( Exception e ) {
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        infoLog.location = 'FSLWorkProcess:' + e.getLineNumber();
        infoLog.message = e.getMessage();
        infoLog.stackTrace = e.getStackTraceString();
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'FSLWorkProcess';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.SALES, SplunkHelper.DOMAIN.SUPPLY, SplunkHelper.DOMAIN.CAPITAL };

        SplunkHelper.buildandProcessLog( infoLog );
    }
    /*
    * Given an organized list of AddressKey to A list of the multiple WorkStructs, we will give back all WorkStructs.
    * This will also remove WorkStructs that have an existingWOId but no WorkRec. What this is is that we found a work order for that Key
    * but no new work order line items were grouped with it.
    * @param workStructsList - a map of Key to WorkStructs WHERE Key is the Address and WorkStructs are the multiple orders
    * @return a single list of all the workstructs
    */
    public static List<WorkStruct> getAllWorkStructs(Map<String, List<WorkStruct>> organizedWorkMap){
        List<WorkStruct> allWorkStructsList = new List<WorkStruct>();
        for( String key : organizedWorkMap.keySet() ){
            for( WorkStruct ws : organizedWorkMap.get(key) ){
                if( ws.existingWOId != null && ws.workRec == null ) continue;
                allWorkStructsList.add(ws);
            }
        }
        return allWorkStructsList;
    }
}