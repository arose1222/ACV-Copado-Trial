/**
 * This class holds the logic for the Inventory Life Cycle View LWC
 * @author James Andre LaCour
 */
public without sharing class InventoryLifeCycleListViewController {
    /****************Inner Classes************************/
    public class Filter{
        public List<FilterSetWrapper> objectFields;
        public List<FilterSetWrapper> logicFields;
    }
    public class FilterSetWrapper{
        public String field;
        public String operator;
        public String value;
        public Boolean isActive;
    }
    public class DataWrapper{
        public List<InventoryRow> allIlcRows;
        public String filterName;
        public String filterId;
        public Boolean hasError;
        public String message;
        public String messageTitle;
        public DataWrapper(){
            allIlcRows = new List<InventoryRow>();
            hasError = false;
            message = '';
            messageTitle = '';
        }
        public void setIlcRows( List<Inventory_Life_Cycle__c> ilcList ){
            for( Inventory_Life_Cycle__c ilc : ilcList ){
                InventoryRow irTemp = new InventoryRow( ilc );
                allIlcRows.add(irTemp);
            }
        }
        // public void setIlcRows( Inventory_Life_Cycle__c ilc, Integer tableSize ){
        //     for( Integer i=0; i<tableSize; i++ ){
        //         InventoryRow irTemp = new InventoryRow( ilc, i );
        //         allIlcRows.add( irTemp );
        //     }
        // }
    }
    public virtual class InventoryRow{
        // Id
        public String Id;
        // Client
        public String clientName;
        public String clientAcctId;
        public String clientURL;
        // Location
        public String locationName;
        public String locationWoliId;
        public String locationURL;
        // Stock Number
        public String stockNumber;
        // VIN
        public String vinName;
        public String vinAuctionId;
        public String vinURL;
        // Status
        public String status;
        // Year Make Model Trim
        public String yearMakeModelTrim;
        public String yearMakeModelTrimCrId;
        public String yearMakeModelTrimURL;
        // Odometer
        public Double odometer;
        // Reserve
        public Double reserve;
        // Lights
        public String lights;
        /****************Constructors*************************/        
        // public InventoryRow( Inventory_Life_Cycle__c ilc, Integer counter ){
            // Id = ilc.Id + String.valueOf(Math.random()*100);
            // // Id = ilc.Id;
            // clientName = ilc.Client__c != null ? ilc.Client__r.Name : null;
            // clientAcctId = ilc.Client__c != null ? ilc.Client__c : null;
            // clientURL = ilc.Client__c != null ? '/' + ilc.Client__c : null;
            // locationName = ilc.Most_Recent_Work_Order_Line_Item__c != null && ilc.Most_Recent_Work_Order_Line_Item__r.WorkOrderId != null ? ilc.Most_Recent_Work_Order_Line_Item__r.WorkOrder.City + ', ' + ilc.Most_Recent_Work_Order_Line_Item__r.WorkOrder.State : null;
            // locationWoliId = ilc.Most_Recent_Work_Order_Line_Item__c != null ? ilc.Most_Recent_Work_Order_Line_Item__c : null;
            // locationURL = ilc.Most_Recent_Work_Order_Line_Item__c != null ? '/' + ilc.Most_Recent_Work_Order_Line_Item__c : null;
            // // stockNumber = ilc.Stock_Number__c;
            // stockNumber = String.valueOf(counter);
            // vinName = ilc.VIN__c;
            // vinAuctionId = ilc.Most_Recent_Auction__c != null ? ilc.Most_Recent_Auction__c : null;
            // vinURL = ilc.Most_Recent_Auction__c != null ? '/' + ilc.Most_Recent_Auction__c : ( ilc.VIN__c != null ? ilc.VIN__c : null );
            // status = ilc.Status__c;
            // yearMakeModelTrim = ilc.Vehicle__c != null ? ilc.Vehicle__r.Year_Make_Model_Trim__c : null;
            // yearMakeModelTrimCrId = ilc.Most_Recent_Condition_Report__c != null ? ilc.Most_Recent_Condition_Report__c : null;
            // yearMakeModelTrimURL = ilc.Most_Recent_Condition_Report__c != null ? '/' + ilc.Most_Recent_Condition_Report__c : null;
            // odometer = ilc.Odometer__c;
            // // reserve = ilc.Reserve__c;
            // reserve = Math.Random() * 100000;
            // lights = ilc.Auction_Lights_Concatenation__c;
        // }
        public InventoryRow( Inventory_Life_Cycle__c ilc ){
            Id = ilc.Id;
            clientName = ilc.Client__c != null ? ilc.Client__r.Name : null;
            clientAcctId = ilc.Client__c != null ? ilc.Client__c : null;
            clientURL = ilc.Client__c != null ? '/' + ilc.Client__c : null;
            locationName = ilc.Most_Recent_Work_Order_Line_Item__c != null && ilc.Most_Recent_Work_Order_Line_Item__r.WorkOrderId != null ? ilc.Most_Recent_Work_Order_Line_Item__r.WorkOrder.City + ', ' + ilc.Most_Recent_Work_Order_Line_Item__r.WorkOrder.State : ' ';
            locationWoliId = ilc.Most_Recent_Work_Order_Line_Item__c != null ? ilc.Most_Recent_Work_Order_Line_Item__c : null;
            locationURL = ilc.Most_Recent_Work_Order_Line_Item__c != null ? '/' + ilc.Most_Recent_Work_Order_Line_Item__c : ' ';
            stockNumber = ilc.Stock_Number__c;
            vinName = String.isNotBlank(ilc.VIN__c) ? ilc.VIN__c : ' ';
            vinAuctionId = ilc.Most_Recent_Auction__c != null ? ilc.Most_Recent_Auction__c : null;
            vinURL = ilc.Most_Recent_Auction__c != null ? '/' + ilc.Most_Recent_Auction__c : ' ';
            status = ilc.Status__c;
            yearMakeModelTrim = ilc.Vehicle__c != null ? ilc.Vehicle__r.Year_Make_Model_Trim__c : ' ';
            yearMakeModelTrimCrId = ilc.Most_Recent_Condition_Report__c != null ? ilc.Most_Recent_Condition_Report__c : null;
            yearMakeModelTrimURL = ilc.Most_Recent_Condition_Report__c != null ? '/' + ilc.Most_Recent_Condition_Report__c : ' ';
            odometer = ilc.Odometer__c;
            reserve = ilc.Reserve__c;
            lights = ilc.Auction_Lights_Concatenation__c;
        }
        public InventoryRow(){/*default constructor*/}
    }
    /****************Helper Methods***********************/
    /**
     * doInit is called on load of Inventory Life Cycle.
     * Since it only gets records, we have made it Cacheable to help with performance
     * @return JsonString of the DataWrapper
     */
    @AuraEnabled
    public static String doInit(){
        Id assignmentRTId = Schema.SObjectType.Filter_Manager__c.getRecordTypeInfosByDeveloperName().get('Assignment').getRecordTypeId();
        DataWrapper dw = new DataWrapper();
        try{
            List<Filter_Manager__c> defaultFilterManager = [ SELECT Id, Filter__c, Filter__r.Name, Filter__r.Filter_Items_JSON__c FROM Filter_Manager__c WHERE RecordTypeId = :assignmentRTId AND Filter__r.Table_Component_Name__c = 'Inventory Life Cycle Table' AND Pinned__c = true AND OwnerId = :UserInfo.getUserId() LIMIT 1]; 
            if( defaultFilterManager.size() == 0 ){
                dw.hasError = true;
                dw.message = 'Navigate to the Filter Manager to create or activate a Filter to see data.';
                dw.messageTitle = 'No Filter Activated';
            }else{
                dw = intializeData( defaultFilterManager[0], dw );
            }
        }catch(Exception ex){
            dw.hasError = true;
            dw.message = 'There was an issue generating the table. Please contact a Salesforce Admin';
            dw.messageTitle = 'Please Contact a Salesforce Admin in ACV';
            //Needs to be replaced with Splunk Logs
            System.debug( ex.getMessage() );
            System.debug( ex.getStackTraceString() );
        }
        return JSON.serialize(dw);
    }
    /**
     * getUpdatedData runs on Refresh of the table
     * Since it only gets records, we have made it Cacheable to help with performance
     * @param filter - the filter currently applied to the page
     * @return Json String of the DataWrapper
     */
    @AuraEnabled
    public static String getUpdatedData( String filterId ){
        Id assignmentRTId = Schema.SObjectType.Filter_Manager__c.getRecordTypeInfosByDeveloperName().get('Assignment').getRecordTypeId();
        DataWrapper dw = new DataWrapper();
        try{
            String filterIdDeserialized = (String)JSON.deserializeUntyped(filterId);
            if( filterIdDeserialized == ''){
                dw.hasError = true;
                dw.message = 'Navigate to the Filter Manager to create or activate a Filter to see data.';
                dw.messageTitle = 'No Filter Activated';
            }else{
                Id filterManagerId = Id.valueOf( filterIdDeserialized );
                List<Filter_Manager__c> ilcFMList = [ SELECT Id, Filter__c, Filter__r.Name, Filter__r.Filter_Items_JSON__c FROM Filter_Manager__c WHERE RecordTypeId = :assignmentRTId AND OwnerId = :UserInfo.getUserId() AND Filter__r.Table_Component_Name__c = 'Inventory Life Cycle Table' AND Filter__c = :filterManagerId LIMIT 1];
                dw = intializeData( ilcFMList[0], dw );
            }
        }catch(Exception ex){
            dw.hasError = true;
            dw.message = 'There was an issue generating the table. Please contact a Salesforce Admin';
            dw.messageTitle = 'Please Contact a Salesforce Admin in ACV';
            // Needs to be replaced with Splunk Logs
            System.debug( ex.getMessage() );
            System.debug( ex.getStackTraceString() );
        }
        return JSON.serialize(dw);
    }
    private static DataWrapper intializeData( Filter_Manager__c fm, DataWrapper dw ){
        try{
            Filter fil = (Filter)JSON.deserialize(fm.Filter__r.Filter_Items_JSON__c, Filter.class);
            dw.setIlcRows( getUpdatedIlcRows(buildQuery(fil)) );
            // dw.setIlcRows( getUpdatedIlcRows(buildQuery(fil))[0], 304 );
            // dw.setIlcRows( getUpdatedIlcRows(buildQuery(fil))[0], 1 );
            dw.filterId = fm.Filter__c;
            dw.filterName = fm.Filter__r.Name;
            if( dw.allIlcRows.size() == 0 ){
                dw.hasError = true;
                dw.message = 'Please adjust your filter criteria or activate a different filter.';
                dw.messageTitle = 'No Inventory Records passed the filter criteria.';
            }else if(dw.allIlcRows.size() > 10000){
                dw.hasError = true;
                dw.message = 'Please adjust your filter criteria or activate a different filter.';
                dw.messageTitle = 'Too many records were found with this filter criteria.';
            }
        }catch(Exception ex){
            dw.hasError = true;
            dw.message = 'There was an issue generating the table. Please contact a Salesforce Admin';
            dw.messageTitle = 'Please Contact a Salesforce Admin in ACV';
            // Needs to be replaced with Splunk Logs
            System.debug( ex.getMessage() );
            System.debug( ex.getStackTraceString() );
        }
        return dw;
    }
    /**
     * getUpdatedIlcsRows runs the query on the database of Inventory Life Cycle values
     * @return a list of Inventory Life Cycle records
     */
    private static List<Inventory_Life_Cycle__c> getUpdatedIlcRows( String query ){
        return (List<Inventory_Life_Cycle__c>)Database.query(query);
    }
    public static String buildQuery( Filter fil ){
        String columns = 'Id, Client__c, Client__r.Name, Lights__c, Most_Recent_Auction__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.City,';
        columns += ' Most_Recent_Work_Order_Line_Item__r.WorkOrderId, Odometer__c, Reserve__c, Status__c, Stock_Number__c, Auction_Lights_Concatenation__c,';
        columns += ' Year_Make_Model_Trim__c, VIN__c, Most_Recent_Work_Order_Line_Item__c, Most_Recent_Work_Order_Line_Item__r.WorkOrder.State,';
        columns += ' Most_Recent_Condition_Report__c, Vehicle__r.Year_Make_Model_Trim__c, Vehicle__c';
        List<String> whereClauseList = new List<String>();
        for( FilterSetWrapper fsw : fil.objectFields ){
            if( fsw.isActive ){
                if( getOperator(fsw.operator) == 'Does Not Contain' ){
                    whereClauseList.add('(NOT ' + fsw.field + ' ' + getOperator(fsw.operator) + ' ' + getValueForQuery(fsw.field, fsw.value, fsw.operator) + ')');
                }else{
                    whereClauseList.add(fsw.field + ' ' + getOperator(fsw.operator) + ' ' + getValueForQuery(fsw.field, fsw.value, fsw.operator));
                }
            }
        }
        for( FilterSetWrapper fsw : fil.logicFields ){
            if( fsw.isActive ){
                switch on fsw.field{
                    when 'AllOrMyCars'{
                        if( fsw.value == 'My' ){
                            whereClauseList.add( 'Client__r.Active__c = True');
                            whereClauseList.add( 'Client__r.IST_Account_Owner__c = \'' + UserInfo.getUserId() + '\'' );
                        }else{
                            // All
                        }
                    }
                    when 'Auction_Lights_Concatenation__c'{
                        if( fsw.value == 'Green'){
                            whereClauseList.add( 'Auction_Lights_Concatenation__c LIKE \'%g%\'');
                        }else if( fsw.value == 'Yellow'){
                            whereClauseList.add( 'Auction_Lights_Concatenation__c LIKE \'%y%\'');
                        }else if( fsw.value == 'Red'){
                            whereClauseList.add( 'Auction_Lights_Concatenation__c LIKE \'%r%\'');
                        }else if( fsw.value == 'Blue'){
                            whereClauseList.add( 'Auction_Lights_Concatenation__c LIKE \'%b%\'');
                        }
                    }
                    when 'LastModifiedDate'{
                        whereClauseList.add( 'LastModifiedDate = ' + fsw.value.replace(' ', '_'));
                    }
                    when 'Auction_Start_Datetime__c'{
                        whereClauseList.add( 'Auction_Start_Datetime__c = ' + fsw.value.replace(' ', '_'));
                    }
                }
            }
        }
        String whereClause = whereClauseList.size() > 0 ? 'WHERE ' + String.join(whereClauseList, ' AND ') : '';
        system.debug(whereClause);
        return 'SELECT ' + columns + ' FROM Inventory_Life_Cycle__c ' + whereClause + ' ORDER By Client__r.Name ASC';
    }
    private static String getOperator( String operator ){
        String valueToReturn = '';
        switch on operator{
            when 'Equals'{
                valueToReturn = 'IN';
            }
            when 'Does Not Equals'{
                valueToReturn = 'NOT IN';
            }
            when 'Contains'{
                valueToReturn = 'LIKE';
            }
            when 'Does Not Contains'{
                valueToReturn = 'LIKE';
            }
        }
        return valueToReturn;
    }
    private static String getValueForQuery( String field, String value, String operator ){
        String valueToReturn = '';
        if( field.contains('__r') ){
            field = field.substringBefore('__r') + '__c';
        }
        Schema.DisplayType dt = Schema.SObjectType.Inventory_Life_Cycle__c.fields.getMap().get(field).getDescribe().getType();
        switch on dt{
            when BOOLEAN{
                valueToReturn = value.split(',').toString();
                // valueToReturn = value;
            }
            when else{
                if( operator == 'Contains' ){
                    valueToReturn = '\'%' + value + '%\'';
                }else{
                    valueToReturn = '(\'' + String.join(value.split(','),'\',\'') + '\')';
                }
                system.debug(valueToReturn);
                // valueToReturn = '\'' + value + '\'';
            }
        }
        return valueToReturn;
    }
}