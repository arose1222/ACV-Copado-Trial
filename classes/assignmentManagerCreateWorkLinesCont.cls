public class assignmentManagerCreateWorkLinesCont {

    public static Map<String, WorkType> availableWorkTypes {
        get {
            if ( availableWorkTypes == null ) {
                availableWorkTypes = FSLWorkProcessUtility.availableWTMap;
            }
            return availableWorkTypes;
        }
        set;
    }

    public static Map<Id, String> errorWorkTypeRefs {
        get {
            if ( errorWorkTypeRefs == null ) {
                errorWorkTypeRefs = new Map<Id, String>();
                for(WorkType wt: FSLWorkProcessUtility.workTypeIdMap.values() ){
                    errorWorkTypeRefs.put( wt.Id, wt.Name );
                }
            }
            return errorWorkTypeRefs;
        }
        set;
    }

    private final static Integer MAX_RESULTS = 5;

    private static Integer IMPORT_BATCH_SIZE {
        get {
            if ( IMPORT_BATCH_SIZE == null ) {
                Salesforce_Setting__mdt batchSize = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Import_Manager_Batch_Size' LIMIT 1 ];
                IMPORT_BATCH_SIZE = Integer.valueOf( batchSize.Value__c );
            }
            return IMPORT_BATCH_SIZE;
        }
        set;
    }

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getAccounts(String searchTerm, List<String> selectedIds){
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
        Account (Id, Name, BillingCity, Dealership_ID__c WHERE id NOT IN :selectedIds)
        LIMIT :MAX_RESULTS];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String accountIcon = 'standard:account';
        Account [] accounts = ((List<Account>) searchResults[0]);
        for (Account account : accounts) {
            results.add(new LookupSearchResult(account.Id, 'Account', accountIcon, account.Name, 'Account • '+ account.BillingCity + ', Dealer Id • ' + account.Dealership_ID__c ));
        }

      return results;
    }


    /**
     * the Title of the Import Manager template ContentDocument
     */
    public static final String IMPORT_MANAGER_TEMPLATE_TITLE = 'Import Manager Template';
    /**
     * Gets the downloadable link for the template used in the Import Manager
     * @return  `String` url for the downloadable link
     */
    @AuraEnabled
    public static String getTemplateDownloadLink(){
        List<ContentVersion> cvList = [ SELECT Id FROM ContentVersion WHERE isLatest = true AND ContentDocument.Title = :IMPORT_MANAGER_TEMPLATE_TITLE LIMIT 1 ];
        if( cvList.size() == 0 ) return null;
        return ACVUtility.getContentVersionDownloadableLink( cvList[0].Id );
    }

    @AuraEnabled
    public static boolean createWorkOrders(String inboundJSON){
        system.debug(inboundJSON);
        list<jsonVin> workLineList = (list<jsonVin>)JSON.deserialize(inboundJSON, List<jsonVin>.class);

        Map<Id,List<WorkOrderLineItem>> workOrderLineMap = new Map<Id, List<WorkOrderLineItem>>();
        for(jsonVin o: workLineList){
            WorkOrderLineItem lineItem = new WorkOrderLineItem(VIN__c = o.vin, WorkTypeId = availableWorkTypes.get(o.inspectiontype).id, Status = 'New');
            if(o.year != null){
                lineItem.Year__c = o.year;
            }
            if(o.make != null){
                lineItem.Make__c = o.make;
            }
            if(o.model != null){
                lineItem.Model__c = o.model;
            }
            if(!String.isBlank( o.reservePrice ) ){
                lineItem.Reserve_Price__c = Decimal.valueOf(o.reservePrice);
            }
            if(o.color != null){
                lineItem.Color__c = o.color;
            }
            if(o.stockNumber != null){
                lineItem.Stock_Number__c = o.stockNumber;
            }
            if(o.lineNote != null){
                lineItem.Description = o.lineNote;
            }
            if(workOrderLineMap.get(o.lotId) != null){
                workOrderLineMap.get(o.lotId).add(lineItem);
            }
            else{
                workOrderLineMap.put(o.lotId, new List<WorkOrderLineItem>());
                workOrderLineMap.get(o.lotId).add(lineItem);
            }
        }

        return processWorkOrders( workOrderLineMap );
    }

    public static boolean processWorkOrders( Map<Id, List<WorkOrderLineItem>> workOrderLineMap ) {
        Id assetId = availableWorkTypes.get( 'verification' ).Id;
        Id remoteId = availableWorkTypes.get( 'Remote Inspection' ).Id;
        // Exclude Remote Inspection Work Orders from being attached to existing, open Work Orders
        Set<Id> excludeWTIdSet = new Set<Id>{ availableWorkTypes.get( 'Remote Inspection' ).Id };

        //throw an error incase we didn't set up our enviorment correctly
        system.assert(availableWorkTypes.values().size()>0,'No Valid Work Types Found');

        //attach new work order lines to existing work orders that have not been assigned out yet
        Map<Id, WorkOrder> existingOrderMap = new Map<Id, WorkOrder>([Select Id, AccountId, WorkTypeId, (SELECT Id, WorkTypeId FROM WorkOrderLineItems) from WorkOrder where accountId in :workOrderLineMap.keyset() AND isclosed = false AND status = 'New']);
        List<WorkOrderLineItem> addToExistingWorkOrderList = new List<WorkOrderLineItem>();
        Map<Id, Id> workOrderToTypeIdMap = new Map<Id, Id>();
        if(existingOrderMap.size() > 0){
        //do stuff to attach new lines to existing work order
            for(WorkOrder wo :existingOrderMap.values()){
                for ( WorkOrderLineItem woliRecord : wo.WorkOrderLineItems ) {
                    // Asset & Remote needs to be seperated out and not grouped with non-types
                    if ( assetId != null && woliRecord.WorkTypeId == assetId ) {
                        workOrderToTypeIdMap.put( wo.Id, woliRecord.WorkTypeId );
                        break;
                    } else if ( remoteId != null && woliRecord.WorkTypeId == remoteId ) {
                        workOrderToTypeIdMap.put( wo.Id, woliRecord.WorkTypeId );
                        break;
                    }
                }
            }

            for(WorkOrder wo :existingOrderMap.values()){
                if(workOrderLineMap.get(wo.accountId) != null){
                    for( Integer index = 0; index < workOrderLineMap.get( wo.AccountId ).size(); index++ ) {
                        WorkOrderLineItem li = workOrderLineMap.get( wo.AccountId )[index];
                        // First check that Remote Inspections are being excluded from grouping
                        // If RemoteId is not set, don't stop functionality
                        if ( !excludeWTIdSet.contains( li.WorkTypeId ) && ( ( remoteId == null ) || ( remoteId != null && workOrderToTypeIdMap.get( wo.Id ) != remoteId ) ) ) {
                            // Then verify that Asset Verification is only grouped with Asset Verification
                            // If AssetId is not set, don't stop functionality
                            if ( ( assetId == null ) || ( assetId != null && ( ( workOrderToTypeIdMap.get( wo.Id ) == assetId && li.WorkTypeId == assetId ) || ( workOrderToTypeIdMap.get( wo.Id ) != assetId && li.WorkTypeId != assetId ) ) ) ) {
                                li.workOrderId = wo.id;
                                addToExistingWorkOrderList.add(li);
                                workOrderLineMap.get( wo.accountId ).remove( index );
                            }
                        }
                    }
                    //after we have found all the items that need to be added, remove the key from the map
                    if ( workOrderLineMap.get( wo.accountId ).size() == 0 ) {
                        workOrderLineMap.remove(wo.accountId);
                    }
                }
            }
        }

        //create new work orders
        Map<String,workorderWrapper> workOrderInsertMap = new Map<String,workorderWrapper>();
        List<WorkOrder> woInsertList = new List<WorkOrder>();
        Map<String,Account> workOrderAccountMap = new Map<String,Account>([Select Id,OwnerId from Account where id in :workOrderLineMap.keyset()]);
        Boolean assetVerificationFlag = false;
        for(String wi :workOrderLineMap.keyset()){
            List<WorkOrderLineItem> betaWoliList = new List<WorkOrderLineItem>();
            //check if any of the line items are of type asset verification
            for(WorkOrderLineItem woli : workOrderLineMap.get(wi)){
                if (woli.WorkTypeId == availableWorkTypes.get('verification').Id){
                    assetVerificationFlag = true;
                    break;
                }
                betaWoliList.add(woli);
            }
            //determine new owner based on if the wo is asset verification
            //insert Service Territory here
            WorkOrder wo = new WorkOrder(AccountId = wi, status = 'New');
            if (assetVerificationFlag){
                wo.OwnerId = AssignmentManagerOwnerSelection.assetVerificationOwner();
            } /*else if (betaCheck(betaWoliList)){
                List<WorkOrder> woList = new List<WorkOrder>();
                woList.add(wo);
                trac_WorkOrderTriggerHandler.assignWorkOrderToQueue(woList);
            }*/else{
                //wo.OwnerId = workOrderAccountMap.get(wi).OwnerId;
                List<WorkOrder> woList = new List<WorkOrder>();
                woList.add(wo);
                trac_WorkOrderTriggerHandler.assignWorkOrderToQueue(woList);
            }


            workorderWrapper wow = new workorderWrapper(wo,workOrderLineMap.get(wi));
            woInsertList.add(wow.order);
            workOrderInsertMap.put(wi, wow);
            assetVerificationFlag = false;
        }
        insert woInsertList;
        List<WorkOrderLineItem> woliInsertList = new List<WorkOrderLineItem>();
        for(String wo :workOrderInsertMap.keyset()){
            for(WorkOrderLineItem wli:workOrderInsertMap.get(wo).lines){
                wli.workOrderId = workOrderInsertMap.get(wo).order.id;
                woliInsertList.add(wli);
            }
        }
        woliInsertList.addAll(addToExistingWorkOrderList);
        insert woliInsertList;

        return true;
    }

    // public static Id getServiceTerritory(String accountId){
    //     Account acc = [SELECT id, ownerId, Service_Territory__c FROM Account WHERE Id =: accountId];
    //     if(acc.getPopulatedFieldsAsMap().containsKey('Service_Territory__c')){
    //         return acc.Service_Territory__c;
    //     }
    //     else return null;
    // }

    public class workorderWrapper{
        public WorkOrder order {get;set;}
        public List<WorkOrderLineItem> lines {get;set;}

        public workorderWrapper(){
            this.order = new workOrder();
            this.lines = new List<WorkOrderLineItem>();
        }

        public workorderWrapper(WorkOrder iwo, List<WorkOrderLineItem> woliList){
            this.order = iwo;
            this.lines = woliList;
        }

    }

    public class jsonVin{
        public String uuid;
        public String vin;
        public String make;
        public String model;
        public String color;
        public String acctId;
        public String lotId;
        public String stockNumber;
        public String lineNote;
        public String inspectiontype;
        public String year;
        public String address; // For Mass Uploader Only
        // New Mass Uploader Fields
        public String reservePrice;
        public String titleStatus;
        public String titleWithDealer;
        public String dealerContact;
        public String residential;
        public String addToRunList;
        public String floorPrice;
        public String dateInspected;
        // New Fields
        public String transportStatus;
        public String inspectionNotes;
        public String dealershipName;
        // New, 'Secret' Fields
        public String earlyStartDate;
        public String dueDate;

        public jsonVin(){
            this.uuid = '';
            this.vin = '';
            this.make = '';
            this.model = '';
            this.color = '';
            this.acctId = '';
            this.lotId = '';
            this.stockNumber = '';
            this.lineNote = '';
            this.inspectiontype = '';
            this.year = '';
            this.address = '';
            // New Mass Uploader Fields
            this.reservePrice = '';
            this.titleStatus = '';
            this.titleWithDealer = '';
            this.dealerContact = '';
            this.residential = '';
            this.addToRunList = '';
            this.floorPrice = '';
            this.dateInspected = '';
            this.transportStatus = '';
            this.inspectionNotes = '';
            this.dealershipName = '';
            // 'Secret' Fields
            this.earlyStartDate = '';
            this.dueDate = '';
        }
    }

    @AuraEnabled
    public static String getInspectionNotesFromAccount(String accountId) {
        //Id accountId = [SELECT Id, AccountId FROM Case WHERE Id = :caseId].AccountId;
        String accountNotes = [SELECT Id, Inspection_Notes__c FROM Account WHERE Id = :accountId].Inspection_Notes__c;
        return accountNotes;
    }

    @AuraEnabled
    public static Id processMassRows( String successRows ) {

        // Convert Raw Information
        List<jsonVin> successfulRowLst = (List<jsonVin>) JSON.deserialize( successRows, List<jsonVIN>.class );

        // Return Information
        Id importJobId;

        // Reference Map to link back via uuid
        Map<String, jsonVin> rowRefMap = new Map<String, jsonVin>();

        // Convert to Structure for FSL Work Engine
        List<WorkObject> workToProcessLst = new List<WorkObject>();
        Map<WorkObject,String> workWithBadAddressMap = new Map<WorkObject,String>();
        Map<WorkObject,String> workWithBadStartDateMap = new Map<WorkObject,String>();
        Map<WorkObject,String> workWithBadDueDateMap = new Map<WorkObject,String>();

        Boolean showHiddenFields = UserInfo.getUserId() == AssignmentManagerOwnerSelection.assetVerificationOwner();
        Integer recsToProcess = 0;

        for ( jsonVin row : successfulRowLst ) {
            List<String> addSplit = row.address.split( ',' );

            String recordUuid;

            // Only certain Users can set Earlist Start & Due Date, for now that is just the 'Asset Verification' rep
            if ( UserInfo.getUserId() == AssignmentManagerOwnerSelection.assetVerificationOwner() && !String.isBlank( row.uuid ) && ACVUtility.validV4UUID( row.uuid ) ) { recordUuid = row.uuid; }
            else {
                recordUuid = ACVUtility.NewGuid();
            }

            // Reference Map population for linking processed records to user input
            rowRefMap.put( recordUuid, row );

            // Basic Structure
            WorkObject newWorkRec = new WorkObject();
            newWorkRec.uuid = recordUuid;
            newWorkRec.origin = 'Import Manager';
            newWorkRec.address = new AddressObject();
            newWorkRec.vehicle = new VehicleObject();
            newWorkRec.workDetail = new InspectionDetails();

            newWorkRec.vehicle.vin = row.vin;
            newWorkRec.vehicle.year = row.year;
            newWorkRec.vehicle.make = row.make;
            newWorkRec.vehicle.model = row.model;
            newWorkRec.vehicle.color = row.color;

            newWorkRec.workDetail.stockNumber = row.stockNumber;
            newWorkRec.workDetail.titleStatus = row.titleStatus;
            newWorkRec.workDetail.isTitleWithDealer = makeBool( row.titleWithDealer );
            newWorkRec.workDetail.dealerContactName = row.dealerContact;
            newWorkRec.workDetail.isResidential = makeBool( row.residential );
            newWorkRec.workDetail.addToRunList = makeBool( row.addToRunList );
            newWorkRec.workDetail.floorPrice = row.floorPrice;
            newWorkRec.workDetail.dateInspected = row.dateInspected;
            newWorkRec.workDetail.dealerId = row.acctId;
            newWorkRec.workDetail.type = row.inspectionType;
            newWorkRec.workDetail.status = 'New';
            newWorkRec.workDetail.transportStatus = row.transportStatus;
            newWorkRec.workDetail.inspectionNotes = row.inspectionNotes;
            newWorkRec.workDetail.dealershipName = row.dealershipName;

            // Only certain Users can set Earlist Start & Due Date, for now that is just the 'Asset Verification' rep
            boolean recCounted = false;
            if ( showHiddenFields ) {
                System.debug('MGF processMassRows row.earlyStartDate='+row.earlyStartDate+' row.dueDate='+ row.dueDate);
                if(dateIsCorrectFormat(row.earlyStartDate)) {
                    newWorkRec.workDetail.earliestStartDate = row.earlyStartDate;
                }
                else {
                    workWithBadStartDateMap.put(newWorkRec, row.earlyStartDate);
                    recsToProcess++;
                    recCounted = true;
                }

                if(dateIsCorrectFormat(row.dueDate)) {
                    newWorkRec.workDetail.dueDate = row.dueDate;
                }
                else {
                    workWithBadDueDateMap.put(newWorkRec, row.dueDate);
                    if(!recCounted) {
                        recsToProcess++;
                        recCounted = true;
                    }
                }
            }
            
            if ( addSplit.size() == 4 ) {
                // Address Fields
                newWorkRec.address.street = addSplit[0].trim();
                newWorkRec.address.city = addSplit[1].trim();
                newWorkRec.address.state = addSplit[2].trim();
                newWorkRec.address.postalCode = addSplit[3].trim();
                newWorkRec.address.country = 'US';
                
                if(!recCounted) {
                    workToProcessLst.add( newWorkRec );
                    recsToProcess++;
                    recCounted = true;
                }
            } else {
                workWithBadAddressMap.put(newWorkRec, row.address);
                if(!recCounted) {
                    recsToProcess++;
                    recCounted = true;
                }
            }

        }

        if ( recsToProcess > 0 ) {

            WorkType wt = new WorkType(Work_Type_Unique_ID__c = successfulRowLst[0].inspectionType);

            Import_Manager_Job__c importJob = new Import_Manager_Job__c();
            importJob.Import_Status__c = 'Preparing File';
            importJob.Import_Request_Total__c = recsToProcess;
            importJob.Work_Type__r = wt;
            insert importJob;

            Database.executeBatch(new ImportManagerBatch(workToProcessLst, workWithBadAddressMap, workWithBadStartDateMap, workWithBadDueDateMap, importJob.Id, showHiddenFields), IMPORT_BATCH_SIZE);

            importJobId = importJob.Id;
        }

        return importJobId;
    }

    //Checks to see if the row has a valid format for the date. Prevents an entire batch from failing for a single bad date field.
    public static boolean dateIsCorrectFormat( String incomingDate ) {
        System.debug('MGF dateIsCorrectFormat incomingDate='+incomingDate);
        Pattern validDatePatternWithSlashes = Pattern.compile('[0-1]?[0-9]/[0-3]?[0-9]/[0-9]?[0-9]?[0-9]{2}');
        Pattern validDatePatternWithDashes = Pattern.compile('[0-9]{1,4}-[0-1]?[0-9]-[0-3]?[0-9]');

        if(String.isNotBlank(incomingDate)) {
            Matcher matchSlashDate = validDatePatternWithSlashes.matcher(incomingDate);
            Matcher matchDashDate = validDatePatternWithDashes.matcher(incomingDate);
            if(!matchSlashDate.matches() && !matchDashDate.matches()) {
                System.debug('MGF dateIsCorrectFormat returning false date');
                return false;
            }
        }
        System.debug('MGF dateIsCorrectFormat returning true');
        return true;
    }

    public class MassReturn {
        public Integer successRows;
        public List<ErrorRow> errorRowLst;

        public MassReturn() {
            this.successRows = 0;
            errorRowLst = new List<ErrorRow>();
        }
    }

    public class ErrorRow {
        public jsonVin row;
        public String errorMsg;

        public ErrorRow( jsonVin row, String errorMsg ) {
            this.row = row;
            this.errorMsg = errorMsg;
        }
    }

    public static String makeBool( String val ) {
        if ( val.toLowerCase() == 'yes' || val.toLowerCase() == 'yes' ) {
            return String.valueOf( TRUE );
        }
        return String.valueOf( FALSE );
    }
}