public class RelatedListController {  

    /**
     * Builds a query based on details provided in the LWC setup
     * @param jsonString        json details from LWC to populate query
     * @return  `List<sObject>`
     */
    @AuraEnabled 
    public static List<sObject> fetchRecords(String jsonString) {
        lwcProperties properties = (lwcProperties) System.JSON.deserialize(jsonString, lwcProperties.class); 

        // Get child records on the parent page
        String strSOQL = 'SELECT Id FROM ' + properties.objectName + ' WHERE ' + properties.parentFieldAPIName + ' = \'' + properties.recordId + '\'';

        /*
         * Get child records on a sibling page.
         * If the Sibling properties are specified in the LWC component then use them to find out parent record id.
         */
        if(!String.isBlank(properties.siblingObjName) && !String.isBlank(properties.siblingObjParentFieldName)) {
            String recIdQuery = 'SELECT ' + properties.siblingObjParentFieldName + ' FROM ' + properties.siblingObjName + ' WHERE Id = \'' + properties.recordId + '\''; 
            List<SObject> objs = Database.query(recIdQuery);
            if(objs != null && objs.size() > 0) {
                String siblingParentRecId = String.valueOf(objs[0].get(properties.siblingObjParentFieldName));
                if(!String.isBlank(siblingParentRecId))   strSOQL = 'SELECT Id FROM ' + properties.objectName + ' WHERE ' + properties.parentFieldAPIName + ' = \'' + siblingParentRecId + '\'';  
            }
        }

        if(properties.fieldName1 != null) {
            strSOQL += addFilter(properties.fieldName1, properties.fieldValue1, properties.filterType1, properties.operator1);
        }
        if(properties.fieldName2 != null) {
            strSOQL += addFilter(properties.fieldName2, properties.fieldValue2, properties.filterType2, properties.operator2);
        }
        if(properties.fieldName3 != null) {
            strSOQL += addFilter(properties.fieldName3, properties.fieldValue3, properties.filterType3, properties.operator3);
        }

        if(properties.orderField != null) {
            strSOQL += ' ORDER BY ' + properties.orderField + ' ' + properties.orderDirection;      
        }
        return Database.query(strSOQL);
    }

    /**
     * adds a filter string to query
     * @param field         field to filter on
     * @param value         value for field filter
     * @param type          type of field being filtered
     * @param operator      = or != or > ...etc
     * @return  `String`
     */
    private static String addFilter(String field, String value, String type, String operator) {
        String filter;
        if (type == 'String') {
            filter = ' AND ' + field + ' ' + operator + ' \'' + value + '\'';  
        }          
        else {
            filter = ' AND ' + field + ' ' + operator + ' ' + value;  
        }
        return filter;
    }

    //object for inbound data
    public class lwcProperties{
        public String recordId;
        public String objectName;
        public String parentFieldAPIName;
        public String fieldName1;
        public String fieldValue1;
        public String filterType1;
        public String operator1;
        public String fieldName2;
        public String fieldValue2;
        public String filterType2;
        public String operator2;
        public String fieldName3;
        public String fieldValue3;
        public String filterType3;
        public String operator3;
        public String orderField;
        public String orderDirection;
        public String siblingObjName;
        public String siblingObjParentFieldName;
    }
}