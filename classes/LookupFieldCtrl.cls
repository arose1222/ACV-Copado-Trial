/**
 * @description : Controller class for Lookup Field LWC component
 *                Contains method to get the list of filtered records
 * @author      : Ankit Bhatnagar, Traction On Demand
 * @date        : 2020/03/31
 */
public with sharing class LookupFieldCtrl {

    /**
    * @description  Method which return List of ResultWrapper which contains Id and other values to be diplayed
    * @param    sobjectApiName - String
    * @param    fieldsToReturn - String
    * @param    filterValue - String
    * @return   String(JSON)
    */
    @AuraEnabled(cacheable=false)
    public static String getFilteredRecords( String sobjectApiName, String fieldsToReturn, String filterValue, String filterCriteria, String parentObjectId ) {
        // Sanitize the input
        System.debug('sobjectApiName'+sobjectApiName);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sobjectApiName);
        String sanitizedFieldsToReturn = String.escapeSingleQuotes(fieldsToReturn);
        String sanitizedFilterValue = String.escapeSingleQuotes(filterValue);
        List<ResultWrapper> results = new List<ResultWrapper>();

        if( String.isNotBlank( sanitizedSObjectAPIName ) &&
                String.isNotBlank( sanitizedFieldsToReturn ) &&
                String.isNotBlank( sanitizedFilterValue ) ){

                    List<String> listFields = sanitizedFieldsToReturn.split(',');
                    enforceFLS( sanitizedSObjectAPIName,listFields );
                    
                    // Build our SOSL query
                    String searchQuery;
                    if(!String.isEmpty(filterCriteria)){
                        //String sanitizedfilterCriteria = String.escapeSingleQuotes(filterCriteria);
                        searchQuery = 'FIND \'' + sanitizedFilterValue + '*\' ' +
                            'IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(' + sanitizedFieldsToReturn +' '+filterCriteria +') ' +
                            'LIMIT 50';
                    }
                    else{
                        searchQuery = 'FIND \'' + sanitizedFilterValue + '*\' ' +
                            'IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(' + sanitizedFieldsToReturn + ') ' +
                            'LIMIT 50';
                    }
                    
                    
                    // Execute the Query
                    System.debug('searchQuery'+searchQuery); 
                    List<List<SObject>> searchList = Search.query(searchQuery);       
                    if ( searchList != null && !searchList.isEmpty() && !searchList[0].isEmpty() ) {                      
                        Set<Id> recordIdSet = new Set<Id>();
                        if ( searchList[0][0].Id.getSobjectType() == Schema.ServiceResource.SObjectType ) {
                            for ( List<SObject> lst : searchList ) {
                                for ( SObject sObjRec : lst ) {
                                    recordIdSet.add( sObjRec.Id );
                                }
                            }
                        }

                        Set<Id> excludedResource = new Set<Id>();
                        for ( ResourcePreference resPref : [ SELECT Id, ServiceResourceId FROM ResourcePreference WHERE RelatedRecordId = :parentObjectId AND ServiceResourceId IN :recordIdSet AND PreferenceType = 'Excluded' ] ) {
                            excludedResource.add( resPref.ServiceResourceId );
                        }

                        if ( !excludedResource.isEmpty() ) {
                            List<List<SObject>> newSearchLst = new List<List<SObject>>();
                            for ( List<SObject> lst : searchList ) {
                                List<SObject> tempLst = new List<SObject>();
                                for ( SObject sObjRec : lst ) {
                                    if ( !excludedResource.contains( sObjRec.Id ) ) {
                                        tempLst.add( sObjRec );
                                    }
                                }
                                newSearchLst.add( new List<SObject>( tempLst ) );
                            }
                            searchList = newSearchLst;
                        }
                    }

                    results = processSobjectResult( searchList, listFields );
        }
        return JSON.serialize(results);
    }

    /**
    * @description  Method to enforce FLS
    * @author Graeme Ward, Traction on Demand
    * @param    sobjectApiName - String
    * @param    listFields - List<String>
    * @return   void
    * @revised Nitin Chandwani, Traction on Demand 13 March 2020
    */
    private static void enforceFLS(String sObjectAPIName, List<String> listFields){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if( gd.containsKey( sObjectAPIName ) ){
            SObjectType SObjectToken = gd.get(sObjectAPIName);
            Map<String, Schema.SObjectField> fieldMap = SObjectToken.getDescribe().fields.getMap();
            List<String> inaccessibleFields = new List<String>();

            for (String field : listFields){
                SObjectField fieldToTest = fieldMap.get(field);
                if(fieldToTest == null){
                    String message = 'No such field ' + field + ' on Object ' + sObjectAPIName + '. ' +
                            'Please contact your Salesforce Administrator.';
                    throw new AuraHandledException(message);
                }
                if (!fieldToTest.getDescribe().isAccessible()){
                    inaccessibleFields.add(field);
                }
            }

            if(!inaccessibleFields.isEmpty()){
                String message = 'Insufficient privileges to access the following fields on ' + sObjectAPIName + ': ' +
                        String.join(inaccessibleFields,', ') + '. Please contact your Salesforce Administrator.';
                throw new AuraHandledException(message);
            }
        }else{
            String message = 'Insufficient privileges to access the following object ' + sObjectAPIName ;
            throw new AuraHandledException(message);
        }

    }
    /**
    * @description  Method to process Sobject result and return list of
    * @author Graeme Ward, Traction on Demand
    * @param    sobjectApiName - String
    * @param    listFields - List<String>
    * @return   void
    * @revised Nitin Chandwani, Traction on Demand 13 March 2020
    */
    private static List<ResultWrapper> processSobjectResult( List<List<SObject>> searchList, List<String> listFields ){
        List<ResultWrapper> results = new List<ResultWrapper>();
        if( searchList != NULL && !searchList.isEmpty() ){
            if ( !searchList[0].isEmpty() ) {
                for ( SObject so : searchList[0] ) {
                    ResultWrapper r = new ResultWrapper();

                    r.Id = so.Id;

                    for(Integer i = 0; i<listFields.size(); i++){
                        String fieldValue = String.valueOf(so.get(listFields[i].trim()));
                        if(i == 0){
                            r.Description = fieldValue;
                        } else {
                            r.metaDescription.add(fieldValue);
                        }
                    }

                    results.add(r);
                }
            }
        }
        return results;
    }

    /**
    * @description : Wrapper Class for storing lookup record information
    * @author      : Nitin Chandwani, Traction On Demand
    * @date        : 2020/03/12
    */
    @TestVisible
    private class ResultWrapper {
        @TestVisible
        String Id;
        @TestVisible
        String Description;
        List<String> metaDescription = new List<String>();
    }
}