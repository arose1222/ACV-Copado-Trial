public class HandleWorkAddressChange extends TriggerInterface {

    private final static String STATUS_CATEGORY = 'New';
    public final static String ERROR_MSG = 'You can not change the address of a Work Order Line Item that has left the \'' + STATUS_CATEGORY + '\' Status Category or has a parent Work Order that has left the \'' + STATUS_CATEGORY + '\' Status Category';

     public static Map<String, String> translateWorkTypes {
        get {
            if ( translateWorkTypes == null ) {     
                translateWorkTypes = new Map<String, String>();
                for( WorkType wt: FSLWorkProcessUtility.availableWTMap.values() ){
                    translateWorkTypes.put( wt.Id, wt.Name );
                }
            }
            return translateWorkTypes;
        }
        set;
    }
    
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        Map<Id, WorkOrderLineItem> changedWoliMap = new Map<Id, WorkOrderLineItem>();
        Map<Id, List<WorkOrderLineItem>> parentWoMap = new Map<Id, List<WorkOrderLineItem>>();

        for ( WorkOrderLineItem woli : (List<WorkOrderLineItem>) newMap.values() ) {
            if ( woli.WorkTypeId  != null && FSLWorkProcessUtility.availableWTGMap.get( 'asi' ) != null ) { // If we can't determine if something is ASI or not, should not run logic
                Boolean isASIWork = isASIWork( woli.WorkTypeId );
                WorkOrderLineItem oldWoli = (WorkOrderLineItem) oldMap.get( woli.Id );    

                if ( ( woli.StatusCategory == STATUS_CATEGORY || isASIWork ) && ( woli.Street != oldWoli.Street || woli.City != oldWoli.City || woli.State != oldWoli.State || woli.PostalCode != oldWoli.PostalCode || woli.WorkTypeId != oldWoli.WorkTypeId ) ) {
                    changedWoliMap.put( woli.Id, woli );

                    if ( parentWoMap.get( woli.WorkOrderId ) == null ) {
                        parentWoMap.put( woli.WorkOrderId, new List<WorkOrderLineItem>() );
                    }
                    parentWoMap.get( woli.WorkOrderId ).add( woli );
                } else if ( ( woli.StatusCategory != STATUS_CATEGORY && !isASIWork ) && ( woli.Street != oldWoli.Street || woli.City != oldWoli.City || woli.State != oldWoli.State || woli.PostalCode != oldWoli.PostalCode || woli.WorkTypeId != oldWoli.WorkTypeId ) ) { // Don't throw the error for ASI
                    woli.addError( ERROR_MSG );
                }
            }
        }
        if ( !changedWoliMap.isEmpty() ) {
            processAddressChange( changedWoliMap, parentWoMap );
        }
    }

    public static void processAddressChange( Map<Id, WorkOrderLineItem> woliMap, Map<Id, List<WorkOrderLineItem>> woRelMap ) { 
        List<WorkOrder> keepParentLst = new List<WorkOrder>();
        Map<Id, WorkOrder> parentRecordMap = new Map<Id, WorkOrder>();

        List<WorkOrderLineItem> existingNewParentLineLst = new List<WorkOrderLineItem>();
        Map<String, WorkWrapper> newRecMap = new Map<String, WorkWrapper>();

        for ( WorkOrder wo : [ SELECT Id, AccountId, Status, StatusCategory, Street, City, PostalCode, Country, State, WorkTypeId, Origin__c, Subject, ServiceTerritoryId, OwnerId, ( SELECT Id, StatusCategory, Street, City, PostalCode, Country, State, WorkTypeId FROM WorkOrderLineItems WHERE Id NOT IN :woliMap.keySet() ) FROM WorkOrder WHERE Id IN :woRelMap.keyset() ] ) {
            if ( wo.StatusCategory != STATUS_CATEGORY && !isASIWork( wo.WorkTypeId ) ) { // If The Work Order is not in New Status, throw error, ignore for ASI Work
                for ( WorkOrderLineItem woli : woRelMap.get( wo.Id ) ) {
                    woli.addError( ERROR_MSG );
                }
            } else if ( wo.WorkOrderLineItems.isEmpty() && woRelMap.get( wo.Id ).size() == 1 ) {
                // With no other children, simply update parent record
                wo.Street = woRelMap.get( wo.Id )[0].Street;
                wo.City = woRelMap.get( wo.Id )[0].City;
                wo.State = woRelMap.get( wo.Id )[0].State;
                wo.Country = woRelMap.get( wo.Id )[0].Country;
                wo.PostalCode = woRelMap.get( wo.Id )[0].postalCode;
                wo.WorkTypeId = woRelMap.get( wo.Id )[0].WorkTypeId;
                keepParentLst.add( wo );
                parentRecordMap.put( wo.Id, wo );
            } else if ( !isASIWork( wo.WorkTypeId ) ) { // Never do the 'excess' position for ASI Work
                for ( WorkOrderLineItem woli : woRelMap.get( wo.Id ) ) {
                    String woliKey = createKey( woli );
                    if ( newRecMap.get( woliKey ) == null ) {
                        newRecMap.put( woliKey, new WorkWrapper( wo ) );
                    }
                    newRecMap.get( woliKey ).woliLst.add( woli );
                }
            }
        }
        if ( !keepParentLst.isEmpty() ) {
            update keepParentLst;

            List<ServiceAppointment> updateSALst = [ SELECT Id, ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN :parentRecordMap.keySet() ];
            for ( ServiceAppointment sa : updateSALst ) {
                WorkOrder wo = parentRecordMap.get( sa.ParentRecordId );
                sa.Street = wo.Street;
                sa.City = wo.City;
                sa.State = wo.State;
                sa.Country = wo.Country;
                sa.PostalCode = wo.PostalCode;
            }

            update updateSALst;
        }
        // Records need to be cloned to new structures
        if ( !newRecMap.isEmpty() ) {
            List<WorkOrder> newParentLst = new List<WorkOrder>();
            Map<String, List<WorkOrderLineItem>> newParentLineMap = new Map<String, List<WorkOrderLineItem>>();

            for ( WorkWrapper ww : newRecMap.values() ) {
               newParentLst.add( new WorkOrder(        
                    AccountId = ww.wo.AccountId,
                    Street = woRelMap.get( ww.wo.Id )[0].Street,
                    City = woRelMap.get( ww.wo.Id )[0].City,
                    State = woRelMap.get( ww.wo.Id )[0].State,
                    Country = woRelMap.get( ww.wo.Id )[0].Country,
                    PostalCode = woRelMap.get( ww.wo.Id )[0].postalCode,
                    Origin__c = ww.wo.origin__c,
                    WorkTypeId = ww.wo.WorkTypeId,
                    Subject =  ww.wo.Subject,
                    ServiceTerritoryId = ww.wo.ServiceTerritoryId,
                    OwnerId = ww.wo.OwnerId
                ) );
          
                for ( WorkOrderLineItem woli : ww.woliLst ) {
                    existingNewParentLineLst.add( new WorkOrderLineItem( Id = woli.Id ) ); // Records that should be deleted as part of reparenting

                    String key = createKey( woli );
                    if ( newParentLineMap.get( key ) == null ) {
                        newParentLineMap.put( key, new List<WorkOrderLineItem>() );
                    }

                    newParentLineMap.get( key ).add( new WorkOrderLineItem(
                        Make__c = woli.make__c,
                        Model__c = woli.model__c,
                        Year__c = woli.Year__c,
                        Stock_Number__c = woli.Stock_Number__c,
                        VIN__c = woli.vin__c,
                        WorkTypeId = woli.WorkTypeId,
                        State = woli.State,
                        City = woli.city,
                        Street = woli.street,
                        PostalCode = woli.postalCode,
                        Country = woli.country,
                        Color__c = woli.color__c,
                        Title_with_Dealer__c = woli.Title_With_Dealer__c,
                        Dealer_Contact__c = woli.Dealer_Contact__c,
                        Residential__c = woli.Residential__c,
                        Add_To_Run_List__c = woli.Add_To_Run_List__c,
                        Floor_Price__c = woli.Floor_Price__c,
                        Date_Inspected__c = woli.Date_Inspected__c,
                        Duration = woli.Duration,
                        DurationType = woli.DurationType,
                        External_Record_guid__c = woli.External_Record_guid__c,
                        Due_Date__c = woli.Due_Date__c,
                        Status = woli.status,
                        Transport_Status__c = woli.Transport_Status__c,
                        Job_Notes__c = woli.Job_Notes__c,
                        Dealership_Name__c = woli.Dealership_Name__c,
                        Earliest_Start_Date__c = woli.Earliest_Start_Date__c
                    ) );   
                }
            }
            if ( !newParentLst.isEmpty() ) {
                insert newParentLst;

                List<WorkOrderLineItem> createNewLineLst = new List<WorkOrderLineItem>();
                for ( WorkOrder wo : newParentLst ) {
                    String key = createKey( wo );

                    if ( newParentLineMap != null ) {              
                        for ( WorkOrderLineItem woli : newParentLineMap.get( key ) ) {
                            woli.WorkOrderId = wo.Id;
                            createNewLineLst.add( woli );
                        }
                    }
                }

                delete existingNewParentLineLst; // Delete existing line items, to simulate reparenting
                insert createNewLineLst;
            }
        }
    }

    public class WorkWrapper {
        public WorkOrder wo;
        public List<WorkOrderLineItem> woliLst;

        public WorkWrapper ( WorkOrder wo ) {
            this.wo = wo;
            this.woliLst = new List<WorkOrderLineItem>();
        }
    }

    public static String createKey( WorkOrder wo ) {
        return wo.Street + ', ' + wo.City + ', ' + wo.State + ', ' + wo.PostalCode + ', ' + ':' + translateWorkTypes.get( wo.WorkTypeId );
    }

    public static String createKey( WorkOrderLineItem woli ) {
        return woli.Street + ', ' + woli.City + ', ' + woli.State + ', ' + woli.PostalCode + ', ' + ':' + translateWorkTypes.get( woli.WorkTypeId );
    }

    public static Boolean isASIWork( Id workTypeId ) {
        return FSLWorkProcessUtility.workTypeIdMap.get( workTypeId ) != null && FSLWorkProcessUtility.availableWTGMap.get( 'asi' ).contains( FSLWorkProcessUtility.workTypeIdMap.get( workTypeId ).Work_Type_Unique_ID__c );
    }
}