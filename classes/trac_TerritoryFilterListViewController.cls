/**
 * @description ${DESCRIPTION}
 * @name trac_TerritoryFilterListViewController
 * @author Daniel Labonte, Traction on Demand
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-12
 */

public with sharing class trac_TerritoryFilterListViewController {

    @TestVisible static final String SERVICE_APPOINTMENT = 'ServiceAppointment';
    @TestVisible static final String SOBJECT_TYPE_ERROR = 'Only Service Appointments supported. Specified sobject not supported: ';
    @TestVisible static final String ADDITIONAL_STATUS_FILTER_PERMISSION = 'WO_Queue_LWC_Addtional_Default_Statuses'; //this typo appears to be intentional
    @TestVisible static final List<String> BASE_STATUS_FILTERS = new List<String>{'New'};
    @TestVisible static final List<String> BASE_PRIORITIES_FILTERS = new List<String>{'Low','Medium','High','Critical','Opportunity'};
    @TestVisible static final List<String> ADDITIONAL_STATUS_FILTERS = new List<String>{'New','Assigned','On Hold'};
    @TestVisible static final List<String> BASE_DATE_FILTERS = new List<String>{'Today','Tomorrow','This week', 'All dates'};
    
    public static User currUser = [SELECT Id,Default_Revolving__c,Default_Status_Values__c,Default_Service_Territories__c,Default_Work_Types__c,Default_Priorities__c FROM User WHERE Id = :UserInfo.getUserId()];
    
    /**
     * @description raises an exception for the case an unsupported SObject type is specified
     * @param sobjectType string specifying the sobject
     */
    private static AuraHandledException raiseSObjectException(String sobjectType) {
        String errorString = SOBJECT_TYPE_ERROR + (String.isBlank(sobjectType) ? '' : sobjectType);

        AuraHandledException ex = new AuraHandledException(errorString);
        ex.setMessage(errorString); //access to string via apex

        throw ex;
    }


    /**
     * @description gets number of relevant work order records beyond the limit of whats shown in the list
     * @param sobjectType string specifying the sobject
     * @param statuses string csv of statuses
     * @param includeStatus boolean flag whether to include or exclude the statuses
     * @param territories string csv of territory ides
     * @param includeTerritory boolean flag whether to include or exclude the territories
     * @param workTypes string csv of work type ids
     * @param includeWorkType boolean flag whether to include or exclude the work types
     * @return integer of the count of records
     */
    @AuraEnabled
    public static Integer getRecordCountApex(String sobjectType, String statuses, Boolean includeStatus, String territories,
            Boolean includeTerritory, String workTypes,Boolean includeWorkType, String priorities, Boolean includePriorities, 
            String origin, String dates) {

        if (sobjectType != SERVICE_APPOINTMENT) {
            raiseSObjectException(sobjectType);
        }

        return (Integer)getAllWorkOrdersQuery(	statuses, includeStatus, territories,includeTerritory,
                priorities, includePriorities, workTypes, includeWorkType,
                origin, dates, null, true);
    }


    /**
     * @description query for all the work orders for the current user's territories
     * @param sobjectType string specifying the sobject
     * @param statuses string csv of statuses
     * @param includeStatus boolean flag whether to include or exclude the statuses
     * @param territories string csv of territory ides
     * @param includeTerritory boolean flag whether to include or exclude the territories
     * @param workTypes string csv of work type ids
     * @param includeWorkType boolean flag whether to include or exclude the work types
     * @param recordLimit integer of limit of records to query
     * @param priorities String csv of priorities
     * @param includePriorities boolean flag whether to include or exclude the Priorities
     * @return list of records that meet the criteria
     */
    @AuraEnabled
    public static List<SObject> getAllSObjectsApex( String sobjectType, String statuses, Boolean includeStatus,
                                                    String territories, Boolean includeTerritory, String workTypes,
                                                    Boolean includeWorkType, String priorities,Boolean includePriorities,
                                                     String origin, String dates, Integer recordLimit
                                                    ) {
        if (sobjectType != SERVICE_APPOINTMENT) {
            raiseSObjectException(sobjectType);
        }

        
        List<ServiceAppointment> serviceAppointments = (List<ServiceAppointment>)getAllWorkOrdersQuery( statuses, includeStatus, territories, includeTerritory,
                                                                                                        priorities, includePriorities, workTypes, includeWorkType, 
                                                                                                        origin, dates, recordLimit,false);
        Map<Id,ServiceAppointment> workOrderIdToServiceAppointment = new Map<Id, ServiceAppointment>();
        for (ServiceAppointment serviceAppointment : serviceAppointments){
            workOrderIdToServiceAppointment.put(serviceAppointment.Work_Order__c, serviceAppointment);
        }
      
        return workOrderIdToServiceAppointment.values();
    }


    /**
     * @description query for all the work orders for the current user's territories
     * @param statuses string csv of statuses
     * @param includeStatus boolean flag whether to include or exclude the statuses
     * @param territories string csv of territory ids
     * @param includeTerritory boolean flag whether to include or exclude the territories
     * @param priorities string csv of Priority 
     * @param includePriorities boolean flag whether to include or exclude the Priority
     * @param workTypes string csv of work type ids
     * @param includeWorkType boolean flag whether to include or exclude the work types
     * @param recordLimit integer of limit of records to query
     * @return string to use to query for records
     */
    public static Object getAllWorkOrdersQuery( String statuses, Boolean includeStatus, String territories,
                                                Boolean includeTerritory, String priorities, Boolean includePriorities,
                                                String workTypes, Boolean includeWorkType, String origin,
                                                String dates, Integer recordLimit, Boolean isCount ) {
        TLQueryBuilder query = new TLQueryBuilder();
        Set<String> fieldSet = new Set<String>{'Work_Order__r.Id','Work_Order__r.List_View_Display__c', 'EarliestStartTime', 'Delinquent_Assignment__c'};
        query.setFields(fieldSet);
        query.setObject(SERVICE_APPOINTMENT);
        query.setLimit(recordLimit);

        if (String.isNotBlank(statuses)) {
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
            query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Work_Order__r.Status',
                    includeStatus ? TLQueryBuilder.IN_OPERATOR : TLQueryBuilder.NOT_IN_OPERATOR,
                    statuses.split(';'),
                    TLQueryBuilder.STRING_TYPE));
        }
        if (String.isNotBlank(priorities)) {
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
            query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Work_Order__r.Priority',
                    includePriorities ? TLQueryBuilder.IN_OPERATOR : TLQueryBuilder.NOT_IN_OPERATOR,
                    priorities.split(';'),
                    TLQueryBuilder.STRING_TYPE));
        }
        if (String.isNotBlank(territories)) {
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
            query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Work_Order__r.ServiceTerritoryId',
                    includeTerritory ? TLQueryBuilder.IN_OPERATOR : TLQueryBuilder.NOT_IN_OPERATOR,
                    territories.split(';'),
                    TLQueryBuilder.STRING_TYPE));
        }
        if (String.isNotBlank(origin)){
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
            if (origin == 'Exclude'){
                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Work_Order__r.Origin__c',
                    TLQueryBuilder.NOT_EQUALS_OPERATOR,
                    'Revolving Term',
                    TLQueryBuilder.STRING_TYPE));
            }
            else if (origin == 'Filter'){
                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Work_Order__r.Origin__c',
                    TLQueryBuilder.EQUALS_OPERATOR,
                    'Revolving Term',
                    TLQueryBuilder.STRING_TYPE));
            }
        }
        if(dates == 'Overdue'){
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Delinquent_Assignment__c',
                    TLQueryBuilder.EQUALS_OPERATOR,
                    'TRUE',
                    TLQueryBuilder.STRING_TYPE));
        }

        if (String.isNotBlank(workTypes)) {
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
            query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                    'Work_Order__r.WorkTypeId',
                    includeTerritory ? TLQueryBuilder.IN_OPERATOR : TLQueryBuilder.NOT_IN_OPERATOR,
                    workTypes.split(';'),
                    TLQueryBuilder.STRING_TYPE));
        }

        if (String.isNotBlank(dates) && (dates != 'Overdue' || dates != 'All dates')) {
            query.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
            Date today = Date.today();
            Date tomorrow = Date.today().addDays(1);
            Date thisWeek = Date.today().addDays(7);
            if (dates == 'Today'){
                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                        'EarliestStartTime',
                        TLQueryBuilder.GREATER_THAN_OR_EQUAL_OPERATOR,
                        ':today',
                        TLQueryBuilder.STRING_TYPE));

                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                        'EarliestStartTime',
                        TLQueryBuilder.LESS_THAN_OPERATOR,
                        ':tomorrow',
                        TLQueryBuilder.STRING_TYPE));
            } else if (dates == 'Tomorrow'){
                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                        'EarliestStartTime',
                        TLQueryBuilder.GREATER_THAN_OR_EQUAL_OPERATOR,
                        ':tomorrow',
                        TLQueryBuilder.STRING_TYPE));

                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                        'EarliestStartTime',
                        TLQueryBuilder.LESS_THAN_OR_EQUAL_OPERATOR,
                        ':tomorrow',
                        TLQueryBuilder.STRING_TYPE));
            } else if (dates == 'This week'){
                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                        'EarliestStartTime',
                        TLQueryBuilder.GREATER_THAN_OR_EQUAL_OPERATOR,
                        ':today',
                        TLQueryBuilder.STRING_TYPE));

                query.baseOperator.addCondition(new TLQueryBuilder.Condition(
                        'EarliestStartTime',
                        TLQueryBuilder.LESS_THAN_OR_EQUAL_OPERATOR,
                        ':thisWeek',
                        TLQueryBuilder.STRING_TYPE));
            }
        }

        String qString = query.build();
        qString = qString.replaceAll('\':today\'',':today');
        qString = qString.replaceAll('\':tomorrow\'',':tomorrow');
        qString = qString.replaceAll('\':thisWeek\'',':thisWeek');
        qString = qString.replaceAll('\'TRUE\'','TRUE');
        qString = qString.replaceAll('\'FALSE\'','FALSE');
        System.debug(qString);
        if (isCount){
            qString = qString.replaceFirst('SELECT.*FROM','SELECT COUNT() FROM');
            return Database.countQuery(qString);
        }else{
            return Database.query(qString);
        }

    }

	/**
     * @description queries for list of service territories
     * @return list of territories, with one-level of child territories
     */

    public class TerritoryWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public List<TerritoryWrapper> items;

        public TerritoryWrapper ( ServiceTerritory st ) {
            this.id = st.Id;
            this.name = st.Name;
        }
    }

    public static List<TerritoryWrapper> getTerritories() {

        Map<Id, TerritoryWrapper> territoriesMap = new Map<Id, TerritoryWrapper>();
        List<TerritoryWrapper> twReturnLst = new List<TerritoryWrapper>();
        Map<Id, ServiceTerritory> parentTerritoriesMap = new Map<Id, ServiceTerritory>( [ SELECT Id, Name FROM ServiceTerritory WHERE ParentTerritoryId = NULL AND IsActive = TRUE ] );
        for ( ServiceTerritory parentRec : parentTerritoriesMap.values() ) {
            TerritoryWrapper parentTWRec = new TerritoryWrapper( parentRec );
            territoriesMap.put( parentTWRec.id, parentTWRec );
            twReturnLst.add( parentTWRec );
        }

        Boolean hasResults = ( parentTerritoriesMap != null && parentTerritoriesMap.isEmpty() );
        do {
            Map<Id, ServiceTerritory> childrenTerritoriesMap = new Map<Id, ServiceTerritory>( [ SELECT Id, Name, ParentTerritoryId FROM ServiceTerritory 
                                                                                                WHERE ParentTerritoryId IN :parentTerritoriesMap.keyset() AND IsActive = TRUE ] );
            hasResults = ( childrenTerritoriesMap != null && !childrenTerritoriesMap.isEmpty() );
            for ( ServiceTerritory stRec : childrenTerritoriesMap.values() ) {
                if ( territoriesMap.get( stRec.ParentTerritoryId ) != null ) {
                    if ( territoriesMap.get( stRec.ParentTerritoryId ).items == null ) {
                        territoriesMap.get( stRec.ParentTerritoryId ).items = new List<TerritoryWrapper>();
                    }
                    TerritoryWrapper twRec = new TerritoryWrapper( stRec );
                    territoriesMap.get( stRec.ParentTerritoryId ).items.add( twRec );
                    territoriesMap.put( twRec.Id, twRec );              
                }
            }  
            parentTerritoriesMap = childrenTerritoriesMap; // Switch for next loop iteration's query to get next level down
        } while ( hasResults );

        return twReturnLst;
    }

	 /**
     * @description queries for list of work types with auto-create service appointments enabled
     * @return list of work types
     */
    public static List<WorkType> getWorkTypes() {
        List<WorkType> workTypes = new List<WorkType>([SELECT Id, Name FROM WorkType WHERE Should_Appear_in_Legacy_Queue__c = TRUE]);
        return workTypes;
    }

    /**
     * @description queries for list of Priority Values
     * @return list of Priority Picklist Values
     */
	public static List<String> getPriorityValues() {
        //passing Sobject Name and Field value
        return getPicklistValues('WorkOrder','Priority');
    }

    /**
     * @description Standard method to fetch picklist values
     * @param ObjectApi_name string sobject name
     * @param Field_name string api name of field
     * @return list of picklist Values
     */
    @AuraEnabled
    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return lstPickvals;
    }

    /**
     * @description retrieves a list of default priorities
     * @return list of priorities
     */
    public static List<String> getDefaultPriorities() {
        List<String> defaultPriorities = BASE_PRIORITIES_FILTERS;
        return defaultPriorities;
    }
    
    /**
     * @description retrieves the work order status picklist values
     * @return list of status picklist values
     */
    public static List<String> getStatuses() {
        List<String> valueList = new List<String>();
        Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            valueList.add(picklistEntry.getLabel());
        }
        return valueList;
    }


    /**
     * @description retrieves a list of default work order statuses based on a custom permission to enable additional default selections
     * @return list of work order statuses
     */
    public static List<String> getDefaultStatuses () {
        List<String> defaultStatuses = BASE_STATUS_FILTERS;
        if (FeatureManagement.checkPermission(ADDITIONAL_STATUS_FILTER_PERMISSION)) {
            defaultStatuses = ADDITIONAL_STATUS_FILTERS;
        }
        return defaultStatuses;
    }


    /**
     * @description retrieves a list of default territories
     * @return list of all service territory IDs
     */
    public static List<String> getDefaultTerritories (List<TerritoryWrapper> territories) {
        List<String> defaultTerritories = new List<String>();

        for (TerritoryWrapper territory : territories) {
            defaultTerritories.add(territory.Id);

            if ( territory.items != null ) {
                for (TerritoryWrapper childTerritory : territory.items) {
                    defaultTerritories.add(childTerritory.Id);

                    if ( childTerritory.items != null ) {
                        for ( TerritoryWrapper grandchildTerritory : childTerritory.items ) {
                            defaultTerritories.add( grandchildTerritory.Id );
                        }
                    }
                }
            }
        }
        return defaultTerritories;
    }


    /**
     * @description retrieves a list of default work types
      * @return list of all work type IDs
     */
    public static List<String> getDefaultWorkTypes (List<WorkType> workTypes) {
        List<String> defaultWorkTypes = new List<String>();

        for (WorkType workType : workTypes) {
            defaultWorkTypes.add(workType.Id);
        }
        return defaultWorkTypes;
    }


    /**
     * @description record to return all the filter data in one call
     */
    public class trac_FilterData {
        @AuraEnabled public List<String> dateValues = new List<String>();
        @AuraEnabled public List<String> defaultTerritories = new List<String>();
        @AuraEnabled public List<String> defaultStatuses = new List<String>();
        @AuraEnabled public List<String> defaultWorkTypes = new List<String>();
        @AuraEnabled public List<String> statuses = new List<String>();
        @AuraEnabled public List<WorkType> workTypes = new List<WorkType>();
        @AuraEnabled public List<String> priorityValues = new List<String>();
        @AuraEnabled public List<String>defaultPriorities = new List<String>();
        @AuraEnabled public List<TerritoryWrapper> territories = new List<TerritoryWrapper>();
    }


    /**
     * @description retrieves the filter data for use by a component
     * @return default work order status list, default territory list, work order status list, territory  list, and work type list
     */
    @AuraEnabled
    public static trac_FilterData getFilterDataApex() {
        trac_FilterData filterData = new trac_FilterData();
        filterData.dateValues = BASE_DATE_FILTERS;
        filterData.statuses = getStatuses();
        filterData.workTypes = getWorkTypes();
        filterData.territories = getTerritories();
        filterData.priorityValues = getPriorityValues();
        filterData.defaultPriorities = getDefaultPriorities();
        filterData.defaultStatuses = getDefaultStatuses();
        filterData.defaultTerritories = getDefaultTerritories(filterData.territories);
        filterData.defaultWorkTypes = getDefaultWorkTypes(filterData.workTypes);

        return filterData;
    }


    /**
     * @description load user preferences into a map to return to the front end
     * @return map of default values
     */
    @AuraEnabled
    public static Map<String,String> getDefaultPreferenceVal(){
        Map<String,String> defaultMap = new Map<String, String>();
		defaultMap.put('Default_Status_Values__c', currUser.Default_Status_Values__c);
        defaultMap.put('Default_Service_Territories__c', currUser.Default_Service_Territories__c);
        defaultMap.put('Default_Work_Types__c', currUser.Default_Work_Types__c);
        defaultMap.put('Default_Priorities__c', currUser.Default_Priorities__c);
        defaultMap.put('Default_Date', BASE_DATE_FILTERS[0]);
        defaultMap.put('Default_Revolving__c', currUser.Default_Revolving__c);
        return defaultMap;
    }
    
    /**
    * @description update user set Default Priority if changed
    * @param statusFilter,territoryFilter,workTypeFilter,priorityFilter
    */
    @AuraEnabled
    public static void updateDefaultFiltersOnUsers( List<String> statusFilter,List<String> territoryFilter,
                                                    List<String> workTypeFilter,List<String> priorityFilter,
                                                    String revolvingFilter){
       	Boolean flagToUpdateContact = false;
        if(statusFilter != NULL){
            String defStatusFilter = convertListToString(statusFilter);
            if (currUser.Default_Status_Values__c != defStatusFilter){
                currUser.Default_Status_Values__c = defStatusFilter;
                flagToUpdateContact = true;
            }
        }    
        if(territoryFilter != NULL){
            String defterritoryFilter = convertListToString(territoryFilter);
            if (currUser.Default_Service_Territories__c != defterritoryFilter){
                currUser.Default_Service_Territories__c = defterritoryFilter;
                flagToUpdateContact = true;
            }
        }
        if(workTypeFilter != NULL){
             String defworkTypeFilter = convertListToString(workTypeFilter);
            if (currUser.Default_Work_Types__c != defworkTypeFilter){
                currUser.Default_Work_Types__c = defworkTypeFilter;
                flagToUpdateContact = true;
            }
        }
        if(priorityFilter != NULL){
            String defpriorityFilter = convertListToString(priorityFilter);
            if (currUser.Default_Priorities__c != defpriorityFilter){
                currUser.Default_Priorities__c = defpriorityFilter;
                flagToUpdateContact = true;
            }
        }
        if(revolvingFilter != NULL){
            if (currUser.Default_Revolving__c != revolvingFilter){
                currUser.Default_Revolving__c = revolvingFilter;
                flagToUpdateContact = true;
            }
        }
        
        if(flagToUpdateContact){
            UPDATE currUser;                                          
        }
    }
    
    /**
    * @description utility method to convert List to String
    * @param defVal
    */
    public static String convertListToString(List<String> inputListString){
        STRING joinedString = STRING.join(inputListString,';');
        return joinedString;
    }
}