public class FilterManagerSidebarController {
    public static final String FM_TABLE_COMPONENT_NAME = 'Inventory Life Cycle Table';
    public static final Id FILTER_RT_ID = Schema.SObjectType.Filter_Manager__c.getRecordTypeInfosByDeveloperName().get('Filter').getRecordTypeId();
    public static final Id ASSIGNMENT_RT_ID = Schema.SObjectType.Filter_Manager__c.getRecordTypeInfosByDeveloperName().get('Assignment').getRecordTypeId();
    @AuraEnabled
    public static string getAllFiltersAndSets(){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            rw.allFiltersAndSetsList = queryAllAvailableFilters( UserInfo.getUserId() );
        }catch(Exception ex){
            // Needs Splunk Logs
            rw.hasError = true;
            rw.message = ex.getMessage();
            rw.messageTitle = 'Please contact a Salesforce Admin in ACV';
        }
        return JSON.serialize(rw);
    }
    @AuraEnabled
    public static string modifyFilterPinnedFlag( String filtersToUpdate ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            List<Filter_Manager__c> assigmentsToUpdate = new List<Filter_Manager__c>();
            List<FilterWrapper> fws = (List<FilterWrapper>)JSON.deserialize(filtersToUpdate, List<FilterWrapper>.class);
            for( FilterWrapper fw : fws ){
                assigmentsToUpdate.add(fw.assignmentFilter);
            }
            update assigmentsToUpdate;
            rw.allFiltersAndSetsList = queryAllAvailableFilters( UserInfo.getUserId() );
        }catch(Exception ex){
            // needs Splunk Logs
            rw.hasError = true;
            rw.message = ex.getMessage();
            rw.messageTitle = 'Please contact a Salesforce Admin in ACV';
        }
        return JSON.serialize(rw);
    }
    @AuraEnabled
    public static string createUpdateFilter( String filterCreateUpdate ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            FilterWrapper fw = (FilterWrapper)JSON.deserialize(filterCreateUpdate, FilterWrapper.class);
            fw.filter.Table_Component_Name__c = FM_TABLE_COMPONENT_NAME;
            FilterSetWrapper fsw = String.isBlank(fw.filter.Filter_Items_JSON__c) ? new FilterSetWrapper() : (FilterSetWrapper)JSON.deserialize(fw.filter.Filter_Items_JSON__c, FilterSetWrapper.class);
            // Creating New Filter
            if( String.isBlank(fw.filter.Id) ){
                JSONGenerator columnsGen = JSON.createGenerator(false);
                columnsGen.writeStartObject();
                columnsGen.writeEndObject();
                fw.filter.Columns_JSON__c = columnsGen.getAsString();
                fw.filter.Filter_Items_JSON__c = JSON.serialize(fsw);
                fw.filter.RecordTypeId = FILTER_RT_ID;
                insert fw.filter;
                if( fw.filter.Visibility__c == 'Private' ){
                    Filter_Manager__c assignment = createAssignment( fw.filter );
                    insert assignment;
                }
            }else{
                // Updating Filter
                update fw.filter;
                List<Filter_Manager__c> checkForAssignment = [ SELECT Id, Name FROM Filter_Manager__c WHERE Filter__c = :fw.filter.Id AND RecordTypeId = :ASSIGNMENT_RT_ID AND OwnerId = :UserInfo.getUserId() ];
                if( checkForAssignment.size() == 0 && fw.filter.Visibility__c == 'Private'){
                    Filter_Manager__c assignment = createAssignment( fw.filter );
                    insert assignment;
                }
            }
            rw.allFiltersAndSetsList = queryAllAvailableFilters( UserInfo.getUserId() );
        }catch(Exception ex){
            // Needs Splunk Logs
            rw.hasError = true;
            if( ex.getMessage().contains('DUPLICATE_VALUE') ){
                rw.message = 'Please name the Filter Group something different.';
                rw.messageTitle = 'This Filter Group already exists.';
            }else{
                rw.message = ex.getMessage();
                rw.messageTitle = 'Please contact a Salesforce Admin in ACV';
            }
        }
        return JSON.serialize(rw);
    }
    @AuraEnabled
    public static String createUpdateFilterSet( String filterIdJson, String fitlerItemsJson ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            String filterId = (String)JSON.deserializeUntyped(filterIdJson);
            Filter_Manager__c fw = [ SELECT Id, Filter_Items_JSON__c FROM Filter_Manager__c WHERE Id = :filterId LIMIT 1 ];
            fw.Filter_Items_JSON__C = fitlerItemsJson;
            update fw;
            rw.allFiltersAndSetsList = queryAllAvailableFilters( UserInfo.getUserId() );
        }catch(Exception ex){
            rw.hasError = true;
            rw.message = ex.getMessage();
            rw.messageTitle = 'Please contact a Salesforce Admin in ACV';
        }
        return JSON.serialize(rw);
    }
    @AuraEnabled
    public static string deleteFilter( String filterIdJson ){
        ReturnWrapper rw = new ReturnWrapper();
        try{
            Id filterId = Id.valueOf( (String)JSON.deserializeUntyped(filterIdJson) );
            List<Filter_Manager__c> filtersToDeleteList = [ SELECT Id FROM Filter_Manager__c WHERE Id = :filterId OR Filter__c = :filterId ];
            delete filtersToDeleteList;
            rw.allFiltersAndSetsList = queryAllAvailableFilters( UserInfo.getUserId() );
        }catch(Exception ex){
            rw.hasError = true;
            rw.message = ex.getMessage();
            rw.messageTitle = 'Please contact a Salesforce Admin in ACV';
        }
        return JSON.serialize(rw);
    }
    private static List<FilterWrapper> queryAllAvailableFilters( Id userId ){
        Set<Id> filterIds = new Set<Id>();
        List<FilterWrapper> fwList = new List<FilterWrapper>();
        for( Filter_Manager__c assignment : [ SELECT Id, Pinned__c, Filter__c, Filter__r.Name, Filter__r.Visibility__c, Filter__r.Filter_Items_JSON__c FROM Filter_Manager__c WHERE RecordTypeId = :ASSIGNMENT_RT_ID AND OwnerId = :userId ]){
            Filter_Manager__c tempFilter = new Filter_Manager__c();
            tempFilter.Id = assignment.Filter__c;
            tempFilter.Name = assignment.Filter__r.Name;
            tempFilter.Visibility__c = assignment.Filter__r.Visibility__c;
            tempFilter.Filter_Items_JSON__c = assignment.Filter__r.Filter_Items_JSON__c;
            fwList.add( new FilterWrapper( tempFilter, assignment ) );
        }
        return fwList;
    }
    private static Filter_Manager__c createAssignment( Filter_Manager__c filter ){
        Filter_Manager__c assignment = new Filter_Manager__c();
        assignment.RecordTypeId = ASSIGNMENT_RT_ID;
        assignment.OwnerId = UserInfo.getUserId();
        assignment.Filter__c = filter.Id;
        assignment.Name = UserInfo.getName() + ' - ' + filter.Name; 
        return assignment;
    }
    public class ReturnWrapper{
        public List<FilterWrapper> allFiltersAndSetsList;
        public Boolean hasError;
        public String message;
        public String messageTitle;
        public ReturnWrapper(){
            allFiltersAndSetsList = new List<FilterWrapper>();
            message = '';
            messageTitle = '';
            hasError = false;
        }
    }
    public class FilterWrapper{
        public Filter_Manager__c assignmentFilter;
        public Filter_Manager__c filter;
        public FilterWrapper( Filter_Manager__c filter, Filter_Manager__c assignmentFilter ){
            this.assignmentFilter = assignmentFilter;
            this.filter = filter;
        }
    }
    public class FilterSet{
        public String label;
        public String key;
        public String field;
        public String operator;
        public String value;
        public Boolean canDelete;
        public Boolean isActive;
    }
    public class FilterSetWrapper{
        public List<FilterSet> objectFields;
        public List<FilterSet> logicFields;
        public FilterSetWrapper(){
            String showArchivedDefault = '{"field":"Archived__c","operator":"Equals","value":"False","isActive":true,"label":"Archived","key":"Archived__cEqualsfalse","canDelete":false}';
            String myCarsDefault = '{"field":"AllOrMyCars","operator":"Equals","value":"My","isActive":true,"label":"Cars to Show","key":"AllOrMyCarsequalsMy","canDelete":false}';
            objectFields = new List<FilterSet>{(FilterSet)JSON.deserialize(showArchivedDefault,FilterSet.class)};
            logicFields = new List<FilterSet>{(FilterSet)JSON.deserialize(myCarsDefault,FilterSet.class)};
        }
    }
}