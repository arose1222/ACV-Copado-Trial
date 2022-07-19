/**
 * Utility Class for ACV with methods for frequent use cases.
 *
 * @author Gerald McEvoy
 * @since 2019 * @group Starting Out
 */
public class ACVUtility {

    /**
     *  GIVEN A set of updated records and an object name
     *  WHEN at least one field on a record changes, excluding formula fields
     *  THEN return a map identifying records to their fields changed
     *
     * @param  newMap - A map of Ids to new object records
     * @param  oldMap - A map of Ids to old object records
     * @param  objectName - A string name of an object that represents the SObjects passed in
     *
     * @return Map<Id, Set<String>> - Returns a Map with Record Ids related to a set of changed fields, excluding formula fields
     */
    public static Map<Id, Set<String>> getChangedFields( Map<Id, SObject> newMap, Map<Id, SObject> oldMap, String objectName ) {

        Map<Id, Set<String>> modifiedFieldNameMap = new Map<Id, Set<String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap();

        for ( SObject newRecord : newMap.values() ) {
            SObject oldRecord = oldMap.get( newRecord.Id );

            for ( String fieldName : fieldMap.keyset() ) {
                if ( !fieldMap.get( fieldName ).getDescribe().isCalculated() ) { // Ignore Formula Fields
                    if ( newRecord.get( fieldName ) != oldRecord.get( fieldName ) ) {
                        if ( modifiedFieldNameMap.get( newRecord.Id ) == null ) {
                            modifiedFieldNameMap.put( newRecord.Id, new Set<String>() );
                        }
                        modifiedFieldNameMap.get( newRecord.Id).add( fieldName );
                    }
                }
            }
        }

        return modifiedFieldNameMap;
    }

    public static Map<String, String> preventExternalIdModificationFieldMap {
        get {
            if ( preventExternalIdModificationFieldMap == null ) {     
                preventExternalIdModificationFieldMap = new Map<String, String>();
                for( Prevent_Field_Update__mdt pfuRec : [ SELECT Field_Name__c, Object_Name__c
                                    FROM Prevent_Field_Update__mdt WHERE Active__c = TRUE ] ) {
                    preventExternalIdModificationFieldMap.put( pfuRec.Object_Name__c, pfuRec.Field_Name__c );
                }
            }
            return preventExternalIdModificationFieldMap;
        }
        set;
    }

    @TestVisible private static final String MODIFIED_LOCKED_FIELD_ERROR = 'You cannot modify this field. If this is an issue, please open an R&I ticket to request help';

    /**
     *  GIVEN A set of updated records and an object name
     *  WHEN a predetermined, via Custom Metadata, external id field changes
     *  THEN throw an error to prevent this change
     *
     * @param  newMap - A map of Ids to new object records
     * @param  oldMap - A map of Ids to old object records
     * @param  objectName - A string name of an object that represents the SObjects passed in
     */
    public static void identifyAndFlagChangedFields( Map<Id, SObject> newMap, Map<Id, SObject> oldMap, String objectName ) {

        Map<Id, Set<String>> returnFieldChangeMap = getChangedFields( newMap, oldMap, objectName );
        for ( Id recordId : returnFieldChangeMap.keySet() ) {
            for ( String changedFieldName : returnFieldChangeMap.get( recordId ) ) {
                if ( preventExternalIdModificationFieldMap.get( objectName ) != null && preventExternalIdModificationFieldMap.get( objectName ).contains( changedFieldName ) ) {
                    newMap.get( recordId ).addError( MODIFIED_LOCKED_FIELD_ERROR );
                    break;
                }
            }
        }
    }

    /**
     *  getSObjectName
     *  GIVEN a Record in the system
     *  WHEN the record exists within the system
     *  THEN return the name of the specific object of that record
     *
     * @param  record - An SObject record in the system
     *
     * @return String - Returns a String label name of the SObject as a reference point
     */
    public static String getSObjectName( SObject record ) {
        return record.getSObjectType().getDescribe().getName();
    }

    /**
     * A Map of Salesforce Profile Names to Ids
     */
    public static Map<String, Id> profileIdMap{
        get{
            if ( profileIdMap == null ) {
                profileIdMap = new Map<String, Id>();
                for ( Profile profileRecord : [ SELECT Id, Name FROM Profile ] ) {
                    profileIdMap.put( profileRecord.Name, profileRecord.Id );
                }
            }
            return profileIdMap;
        }
        set;
    }

     /**
      * Map of Profile Ids to Names
      */
     public static Map<Id, String> profileNameMap {
        get {
            if ( profileNameMap == null ) {
                profileNameMap = new Map<Id, String>();
                for ( Profile pRec : [ SELECT Id, Name FROM Profile ] ) {
                    profileNameMap.put( pRec.Id, pRec.Name );
                }
            }
            return profileNameMap;
        }
        set;
    }

    /**
     * A Set of UserNames to be excluded from Integration processes based off Custom Metadata
     */
    public static Set<String> userNameSet {
        get {
            if ( userNameSet == null ) {
                userNameSet = new Set<String>();
                for( Integration_User_Name__mdt obj :  [SELECT MasterLabel FROM Integration_User_Name__mdt ] ){
                    userNameSet.add( obj.MasterLabel );
                }
            }
            return userNameSet;
        }
        set;
    }

    /**
     * A Map of Work Type Names to Salesforce Work Type Ids
     */
    public static Map<String, Id> workTypeMap {
        get {
            if ( workTypeMap == null ) {
                workTypeMap = new Map<String, Id>();
                for ( WorkType wtRecord : [ SELECT Name, Id FROM WorkType ] ) {
                    workTypeMap.put( wtRecord.Name, wtRecord.Id );
                }
            }
            return workTypeMap;
        }
        set;
    }


    /**
     * This will take an sObject record and string to get the field value dynamically from a record.
     * The use case for this is you have a string query and need to get the values dynamically
     * @param queryPath Repersents the path to the feild you want the value of
     * @param record    The record you are trying to get a value out of 
     * @return  The value of the field as a String, will return null if bad query path provided
     */
    public static string getFieldValue( String queryPath, SObject record ) {
        String[] fields = queryPath.split('\\.');
        SObject tempObject;
        String returnValue;
        if(fields.size() == 1){
            returnValue = String.valueOf(record.get(fields[0]));
        }
        for(Integer i = 0; i < fields.size(); i++){
            if(returnValue == null){
                if(i == 0){
                    tempObject = record.getSObject(fields[i]);
                }
                else if(tempObject != null && i < fields.size()-1){
                    tempObject = tempObject.getSobject(fields[i]);
                }
                else if(tempObject != null){
                    system.debug(tempObject.get(fields[i]));
                    returnValue = String.valueOf(tempObject.get(fields[i]));
                }
            }
        }
        return returnValue;
    }

    /**
     *  GIVEN an object name
     *  WHEN the object name is valid in the system
     *  THEN return a set of fields for that object
     *
     * @param  objectName - A string name of an object
     *
     * @return Set<String> - Returns a set of field API Names for the given object
     */
    public static Set<String> getFieldList( String objectName ) {
        Map<Id, Set<String>> modifiedFieldNameMap = new Map<Id, Set<String>>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get( objectName ).getDescribe().fields.getMap();

        return fieldMap.keySet();
    }

    /**
     * Next set of variables & methods for UUID Generation to meet v4 Standards
     */
    static List<String> hexMap = new List<String> {
        '0', '1', '2', '3', '4', '5', '6', '7', 
        '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
    };
    /**
     * Generates a V4 GUID
     * @return  V4 GUID String
     */
    public static String NewGuid() {        
        String randomStringAsHex = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));

        String versionHexBits = randomStringAsHex.SubString(14,16); // 7th bit 
        String variantHexBits = randomStringAsHex.SubString(18,20); // 9th bit

        Integer versionIntBits = convertHexToInt(versionHexBits);
        Integer variantIntBits = convertHexToInt(variantHexBits);

        Integer versionShiftedIntBits = versionIntBits & 15 | 64;  // (i & 0x0f) | 0x40
        Integer variantShiftedIntBits = variantIntBits & 63 | 128; // (i & 0x3f) | 0x80

        String versionShiftedHexBits = convertIntToHex(versionShiftedIntBits); // Always begins with 4
        String variantShiftedHexBits = convertIntToHex(variantShiftedIntBits); // Always begins with one of 8,9,a,b

        String guid = randomStringAsHex.SubString(0,8) + '-' + randomStringAsHex.SubString(8,12) + '-' + versionShiftedHexBits + randomStringAsHex.SubString(14,16) + '-' + variantShiftedHexBits + randomStringAsHex.SubString(18,20) + '-' + randomStringAsHex.substring(20);        

        return guid;
    }

    /**
     * Takes the Hexdecimal Values and converts it to an Integer
     * @param hex String that represents a Hexdecimal Value
     * @return  Integer value of the Hex Value
     */
    static Integer convertHexToInt(String hex) {        
        Integer d0 = hexMap.IndexOf(hex.Substring(1,2));
        Integer d1 = hexMap.IndexOf(hex.Substring(0,1));

        Integer intval = d0 + (d1*16);
        return intval;
    }
    /**
     * Takes the Integer Values and converts it to an Hex string
     * @param intval Integer you wish to convert
     * @return  String Hex of the Integer
     */
    static String convertIntToHex(Integer intval) {
        String hs0 = hexMap.Get(intval & 15); // i & 0x0f
        String hs1 = hexMap.Get(((intval >> 4) & 15)); //(i >> 4) & 0x0f        
        return hs1+hs0;
    }

    private static final Integer UUID_V4_LENGTH = 36;
    private static final String UUID_V4_REGEX = '[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}';

    /*
     * Takes the provided String and verifies if it is a valid agaisnt the UUID v4 Standard
     * @param uuidValue Provided String to verify if it is matches the UUID v4 Standard
     * @return Boolean that represents if it matches against the UUID v4 Standard
     */
    public static Boolean validV4UUID( String uuidValue ) {
        if(String.isBlank(uuidValue)) return false;
        if(uuidValue.length() != UUID_V4_LENGTH) return false;

        Pattern uuidPattern = Pattern.compile( UUID_V4_REGEX.toLowerCase() );
        Matcher uuidMatcher = uuidPattern.matcher( uuidValue.toLowerCase() );

        return uuidMatcher.matches();
    }

    /**
     * A method to make the process of scheduling a job easier
     * 
     * @param runTime Datetime you want your job to run
     * @param className Name of the class you want to run
     * @return  Id of your Scheduled Job
     */
    public static String scheduleJob(DateTime runTime, String className){
        return scheduleJob(runTime, className, TIME_LEVEL.SECOND);
    }
    
    public enum TIME_LEVEL {DAY, HOUR, MINUTE, SECOND}
    /**
     * A method to make the process of scheduling a job easier
     * 
     * @param runTime Datetime you want your job to run
     * @param className Name of the class you want to run
     * @param timeLevel sets the timestamp in the name only to the specified level, or as far as possible (to seconds) by default
     * @return  Id of your Scheduled Job
     */
    public static String scheduleJob(DateTime runTime, String className, TIME_LEVEL timeLevel){
        String JobId = '';
        //time components
        String hour = String.valueOf(runtime.hour());
        String min = String.valueOf(runTime.minute());
        String second = String.valueOf(runTime.second());
        //Date Components
        String day = String.valueOf(runTime.day());
        String month = String.valueOf(runTime.month());
        String year = String.valueOf(runTime.year());
        //Cron Expression Generation
        String cronExpression = second+' '+min+' '+hour+' '+day+' '+month+' ? '+year;

        String scheduledNameTimestamp = String.valueOf(DateTime.Now());
        switch on timeLevel{
            when DAY{
                Integer firstSpaceIndex = scheduledNameTimestamp.indexOf(' ');
                scheduledNameTimestamp = scheduledNameTimestamp.remove(scheduledNameTimestamp.substring(firstSpaceIndex));
            }
            when HOUR{
                Integer firstColonIndex = scheduledNameTimestamp.indexOf(':');
                scheduledNameTimestamp = scheduledNameTimestamp.remove(scheduledNameTimestamp.substring(firstColonIndex));
            }
            when MINUTE{
                Integer lastColonIndex = scheduledNameTimestamp.lastIndexOf(':');
                scheduledNameTimestamp = scheduledNameTimestamp.remove(scheduledNameTimestamp.substring(lastColonIndex));
            }
        }

        try{
            //do some voodoo magic to instantiate the class out of a string
            Type dynamicClass = Type.forName(className);
            JobId = System.schedule(className +' Scheduled At: ' + scheduledNameTimestamp, cronExpression, (Schedulable)dynamicClass.newInstance());
        }
        catch(Exception e){
            sendLog(new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS}, className, '', SplunkHelper.LOGLEVEL.FATAL, currentLineNumber(), e.getMessage(), e.getStackTraceString(), 'BatchRecords');
            JobId = 'ERROR';
        }
        return JobId;
    }

    public static void sendLog(Set<SplunkHelper.DOMAIN> doaminSet, String className, String recordId, SplunkHelper.LOGLEVEL logLevel, Integer lineNumber, String Message, String StackTrace, String sObjectName){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'ACVUtility:' + lineNumber;
        infoLog.message = Message;
        infoLog.stackTrace = StackTrace+ ' '+lineNumber;
        infoLog.sfRecordId = String.isBlank(recordId) ? UserInfo.getUserId() : recordId;
        infoLog.componentName = className;
        infoLog.sfObject = sObjectName;
        infoLog.domainSet = doaminSet;
        SplunkHelper.buildAndProcessLog( infoLog );
    }

    /**
     * Returns the line number the method was called from
     * @return An Integer represnting the line this was called from
     */
    public static Integer currentLineNumber() {
        try {
            Integer x = 0 / 0;
        } catch(Exception e) {
            String line2 = e.getStackTraceString().split('\n')[1];
            Pattern patt = Pattern.compile('([A-Za-z0-9_.]+): line (\\d+)');
            Matcher match = patt.matcher(line2);
            match.find();
            return Integer.valueOf(match.group(2));
        }
        return null;
    }

    /**
     * Get's all the holidays for the next 12 months
     */
    private static Map<Date,Holiday> holidayStorageMap{
        get{
            if ( holidayStorageMap == null ) {
                holidayStorageMap = HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
            }
            return holidayStorageMap;
        }
        set;
    }

    /**
     * Finds if the date provided is a business holiday
     * @param theDate The Date we are checking
     * @param holidayMap The Holidays we get from the HolidayStorageMap
     * @return  Returns true if the Date Provided was a Holiday
     */
    private static boolean findHolidayOnDate( dateTime theDate, Map<Date, Holiday> holidayMap ) {
        if(getDayShortName(theDate) == 'Fri'){
            Date tempDate = Date.valueOf(theDate).addDays(1);
            for(Date dToCheck : holidayMap.keySet()){
                if(tempDate.day() == dToCheck.day() && tempDate.month() == dToCheck.month() && tempDate.year() == dToCheck.year()){
                    return true;
                }
            }
        }
        else if(getDayShortName(theDate) == 'Mon'){
            Date tempDate = Date.valueOf(theDate).addDays(-1);
            for(Date dToCheck : holidayMap.keySet()){
                if(tempDate.day() == dToCheck.day() && tempDate.month() == dToCheck.month() && tempDate.year() == dToCheck.year()){
                    return true;
                }
            }
        }

        if(theDate != null) {
            for(Date dToCheck : holidayMap.keySet()){
                if(theDate.day() == dToCheck.day() && theDate.month() == dToCheck.month() && theDate.year() == dToCheck.year()){
                    return true;
                }
            }
        }
        return false;
    }

    //deprecated as of Nov 2021
    // /**
    //  * Internal method to Check if the date provided is a Field Holiday, these are different than Business Holidays, mainly Christmans and New Years
    //  * @param theDate The Date we are checking
    //  * @param holidayMap The Holidays we get from the HolidayStorageMap
    //  * @return  Returns true if the Date Provided was a Holiday
    //  */
    // private static boolean findFieldHoliday(dateTime theDate, Map<Date, Holiday> holidayMap ) {
    //     Date tempDate = Date.valueOf(theDate);
    //     for(Date dToCheck : holidayMap.keySet()){
    //         if(holidayMap.get(dToCheck).Name == 'Christmas' || holidayMap.get(dToCheck).Name == 'New Years'){
    //             if(tempDate.day() == dToCheck.day() && tempDate.month() == dToCheck.month() && tempDate.year() == dToCheck.year()){
    //                 return true;
    //             }
    //         }
    //     }
    //     return false;
    // }

    // /**
    //  * Checks if the date provided is a Field Holiday
    //  * @param theDate The Date we are checking 
    //  * @return  Returns true if the Date Provided was a Holiday
    //  */
    // public static boolean isFieldHoliday(dateTime theDate){
    //     return findFieldHoliday( theDate, holidayStorageMap );
    // }

    // /**
    //  * Checks if the proided date falls on a field holliday in a given date range, this is good for checking dates more than a year out
    //  * @param theDate The Date we are checking 
    //  * @param startDate The Date we are starting with
    //  * @param endDate The Date we are ending with
    //  * @return  Returns true if the Date Provided was a Holiday in the given range
    //  */
    // public static boolean isFieldHolidayWithinRange( dateTime theDate, date startDate, date endDate ){
    //     return findFieldHoliday( theDate, HolidayUtility.getHolidaysForDates( startDate, endDate ) );
    // }

    /**
     * Checks if the proided date falls on a holliday in a given date range, this is good for checking dates more than a year out
     * @param theDate The Date we are checking 
     * @param startDate The Date we are starting with
     * @param endDate The Date we are ending with
     * @return  Returns true if the Date Provided was a Holiday in the given range
     */
    public static boolean isStandardHolidayWithinRange( dateTime theDate, date startDate, date endDate ) {
        return findHolidayOnDate( theDate, HolidayUtility.getHolidaysForDates( startDate, endDate ) );
    }

    /**
     * Checks if the date provided is a Holiday
     * @param theDate The Date we are checking 
     * @return  Returns true if the Date Provided was a Holiday
     */
    public static boolean isStandardHoliday(dateTime theDate){
        return findHolidayOnDate( theDate, holidayStorageMap );
    }

    /**
     * Retuns true if the date provided is a Saturday or Sunday
     * @param theDate The Date we are Checking
     * @return  Returns True if the date is a Saturday or Sunday
     */
    public static boolean isWeekend(dateTime theDate){
        set<String> listOfWeekendDays = new set<String>{'saturday','sunday'};
        return listOfWeekendDays.contains(getDayName(theDate).toLowerCase());
    }

    /**
     * Determins if the date provided is a week day
     * @param theDate The Date we are Checking
     * @return  Returns True if the date is Monday thru Friday
     */
    public static boolean isWeekday(dateTime theDate){
        return !isWeekend(theDate);
    }

    /**
     * Returns the Long name of the day the date falls on Monday, Tuesday, Friday, ect...
     * @param theDate The Date we are checking
     * @return  The Date Long Name; Monday, Tuesday, ect...
     */
    public static string getDayName(dateTime theDate){
        return theDate.format('EEEE');
    }

    /**
     * Retuns the short name of the day the Date falls on Mon, Tue, Wed, ect
     * @param theDate The Date we are checking
     * @return  The Date Short Name; Mon, Tue, Wed, ect...
     */
    public static string getDayShortName(dateTime theDate){
        return theDate.format('EEE');
    }

    /**
     * Provides the EST version of the date provided
     * @param theDate The Date we are converting
     * @return  The Date provided but in EST
     */
    public static Date newESTInstance( Date theDate ) {
        return DateTime.newInstance( theDate.year(), theDate.month(), theDate.day(), 12, 0, 0).date();
    }

    /**
     * Provides the EST version of the datetime provided
     * @param theDate The DateTime we are converting
     * @return  The Date provided but in EST
     */
    public static Date newESTInstance( DateTime theDateTime ) {
        return DateTime.newInstance( theDateTime.year(), theDateTime.month(), theDateTime.day(), 12, 0, 0).date();
    }

    // public static String getEndpoint( String calloutLabel ) {
    //     Named_Cred__mdt namedCred = [ SELECT Label FROM Named_Cred__mdt WHERE Label = :calloutLabel ];
    //     return namedCred != null ? namedCred.Label : 'https://acvauctions.my.salesforce.com';
    // }

    /**
     * Provides the Type of the Object provided, if no match, object is the type returned
     * @param o The Object we are trying to check
     * @return  The String name of the object type
     */
    public static string getType(Object o) {
        if(o==null) return '';              
        if(o instanceof SObject)            return ((SObject)o).getSObjectType().getDescribe().getName()+''; 
        if(o instanceof Boolean)            return 'Boolean';
        if(o instanceof Id)                 return 'Id';
        if(o instanceof String)             return 'String';
        if(o instanceof Blob)               return 'Blob';
        if(o instanceof Date)               return 'Date';
        if(o instanceof Datetime)           return 'Datetime';
        if(o instanceof Time)               return 'Time';
        if(o instanceof String)             return 'String';
        if(o instanceof Integer)            return 'Integer';
        if(o instanceof Long)               return 'Long';
        if(o instanceof Decimal)            return 'Decimal';  
        return 'Object';                    
    }

    /**
     * Basic method of make slack call out requests, does not make the call out
     * @param webhook The Webhook URL we are trying to send to (Generate this in slack)
     * @param body The Message we are defining
     * @return  an HTTP Request with the provided values for the webhook
     */
    public static HttpRequest createSlackPost( String webhook, String body ){
        HTTPRequest request = new HTTPRequest();
        request.setMethod( 'POST' );
        request.setEndpoint( webhook ); 
        request.setBody( body );
        request.setHeader( 'Content-Type', 'application/json' );
        return request;
    }

    /**
     * A check to see if we are in Production
     * @return  if null there was a bad issue, but True means we are in prod
     */
    @AuraEnabled
    public static Boolean isProd() {
       return isProd;
    }

    // Static variable to hold IsProd value. This avoids additional SOQL
    private static Boolean isProd {
        get {
            if(isProd == null){
                List<Organization> orgLst = [ SELECT IsSandbox, InstanceName, Name FROM Organization WHERE Id = :UserInfo.getOrganizationId() ];
                if ( !orgLst.isEmpty() && orgLst.size() == 1 ) {
                    isProd= !orgLst[0].IsSandbox; // Variable is true if a sandbox, so reversing it
                }
                else{
                    isProd=  null; // If can't figure out, return null
                }
            }
            return isProd;
        }set;
    }

    /**
     * The Base ACV Auctions My Sites url
     */
    private static final String ENV_CONFIG_NAME = 'acvauctions--';
    /**
     * The Base URL for Salesforce
     */
    private static final String SF_DOMAIN = '.my.salesforce.com';
    /**
     * Gets the local running enviorment
     * @return  A String uppercase of the Enviorment name; Example PROD or UAT
     */
    public static String getEnvironmentName() {
        Boolean isProd = ACVUtility.isProd();
        if ( isProd != null ) {
            if ( !isProd ) {
                // Get base URL
                String urlStr = URL.getSalesforceBaseUrl().toExternalForm();
                // Cut off the beginning of the URL, universeal across sandboxes
                Integer indexNum = urlStr.indexOf( ENV_CONFIG_NAME ) + ENV_CONFIG_NAME.length();
                urlStr = urlStr.subString( indexNum, urlStr.length() );
                // Cut off the end of the URL to get the specific sandbox name
                Integer indexNum2 = urlStr.indexOf( SF_DOMAIN );
                urlStr = urlStr.subString( 0, indexNum2 );
                // Return as caps, cause it's cool
                return urlStr.toUpperCase();
            } else {
                return 'PROD';
            }
        } else {
            return null; // Didn't get if it was a sandbox or prod from other method, handles null case
        }
    }

    /**
     * Accepts a String that represents a phone number, if length is not 10 the orginal number will be added to the set 
     * Formats Returned: 555-555-5555; 555 555 555; (555) 555-5555
     * @param inputString The Phone number we are formatting
     * @return  a Set of Strings represnenting the provided phone number in 3 different formats
     */
    public static Set<String> generatePhoneFormatSet(String inputString){
        Set<String> searchSet = new Set<String>();
        if(!String.isBlank(inputString)){
            String searchStringTrimmed = inputString.trim();
            if(!String.isBlank(searchStringTrimmed) && searchStringTrimmed.length() ==10){
                searchSet.add(searchStringTrimmed.substring(0,3)+'-'+searchStringTrimmed.substring(3,6)+'-'+searchStringTrimmed.substring(6,10));
                searchSet.add(searchStringTrimmed.substring(0,3)+' '+searchStringTrimmed.substring(3,6)+' '+searchStringTrimmed.substring(6,10));
                searchSet.add('('+searchStringTrimmed.substring(0,3)+') '+searchStringTrimmed.substring(3,6)+'-'+searchStringTrimmed.substring(6,10));
            }
            if(!String.isBlank(searchStringTrimmed)){
                searchSet.add(searchStringTrimmed);
            }
        }
        return searchSet;
    }

    /**
     * Checks if we provided a valid phone number
     * @param phone The Phone Number we are Checking
     * @return  True if the phone is in a valid format
     */
    public static Boolean isValidPhone(String phone) {
        return Pattern.matches('([0-9-)( ]{14}|[0-9]{10})', phone);
    }

    /**
     * Compares the record type Name to the Record Type Id provided for the SOBject Type
     * @param recordTypeDeveloperName Devloper Name of the record Type, it will be something like new_recordType
     * @param SObjectType API Name of the SObject
     * @param RecordTypeId The Record ID from the Record ptovided
     * @return  Returns true if the Record Type ID Matches the Developer Name and SObject Type Combo
     */
    public static boolean recordTypeCheck(String recordTypeDeveloperName, String SObjectType, String RecordTypeId){
        if(rTMap != null && rtMap.get(sObjectType) != null){
            return rtMap.get(sObjectType).get(recordTypeDeveloperName) == RecordTypeId;
        }
        else{
            return false;
        }
    }

    /**
     * Stored as Object Name, to a map of Developer Name to RT ID
     */
    private static Map<String, Map<String,String>> rTMap { get {
        if(rTMap == null){
            Map<String, Map<String, String>> returnMap = new Map<String, Map<String, String>>();
            for(RecordType rt :[SELECT ID, DeveloperName,SobjectType From RecordType WHERE IsActive = True]){
                if(returnMap.get(rt.SobjectType) == null){
                    returnMap.put(rt.SobjectType, new Map<String, String>());
                    returnMap.get(rt.SobjectType).put(rt.DeveloperName,rt.Id);
                }
                else{
                    returnMap.get(rt.SobjectType).put(rt.DeveloperName,rt.Id);
                }
            }
            rTMap = returnMap;
        }
        return rTMap;
    } set;}


    /**
     * Converts a String Time to a Time Object. Minimum required is hh:mm
     * @param thisTime - The string value of a time in the hh:mm:ss.SSSZ format
     * @return Time object of the string passed in
     */
    public static Time createTimeFromString( String thisTime ){
        if( String.isBlank(thisTime) ){
            throw new CustomException('Null or Blank is not a valid option');
        }
        List<String> timeSplits = thisTime.split('Z|:|\\.');
        // 2 Parameter minimum
        if(timeSplits.size() < 2 ){
            throw new CustomException('At least hour and minutes are required');
        }
        // Integer check
        Integer hour, minute, second, milliSecond;
        try{
            hour = Integer.valueOf( timeSplits[0] );
            minute = Integer.valueOf( timeSplits[1] );
            second = timeSplits.size() > 2 ? Integer.valueOf( timeSplits[2] ) : 0;
            milliSecond = timeSplits.size() > 3 ? Integer.valueOf( timeSplits[3] ) : 0;
        }catch( Exception ex ){
            throw new CustomException('All parameters should be valid integer values');
        }
        return Time.newInstance( hour, minute, second, milliSecond );
    }
    /**
     * Gives the Picklist options of a Custom field on an object. Map is values => label
     * Returns Null if invalid values
     * @param objectApiName - the API name the object the custom field is on
     * @param fieldApiName - the API name of the Custom field 
     * @param getActiveOnly - boolean indicating to get Active picklist values only or all picklist values
     * @return a map of the options Values => Label. Returns Null if invalid values
     */
    public static Map<String, String> getPicklistValues( String objectApiName, String fieldApiName, Boolean getActiveOnly ){
        if( String.isBlank(objectApiName) || String.isBlank(fieldApiName) ) return null;
        Map<String, String> valuesMap = new Map<String, String>{};
        List<Schema.DescribeSobjectResult> resultsList = Schema.describeSObjects( new List<String>{ objectApiName } );
        if( resultsList.isEmpty() || resultsList.size() == 0 ) return null;
        for( Schema.DescribeSobjectResult res : resultsList ) {
            for( Schema.PicklistEntry entry : res.fields.getMap().get(fieldApiName).getDescribe().getPicklistValues() ){
                if( (getActiveOnly && entry.isActive()) || !getActiveOnly ){
                    valuesMap.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        return valuesMap;
    }


    private static Map<String, StaticResource> staticResourceMap {get{
        if(staticResourceMap == null){
            system.debug('loading static resource map');
            Map<String, StaticResource> returnMap = new Map<String, StaticResource>();
            for(StaticResource sr : [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource]){
                returnMap.put(sr.Name, sr);
            }
            staticResourceMap = returnMap;
        }
        system.debug('returning static resource map of size: ' + staticResourcemap.size());
        return staticResourceMap;
    } set;}
    

    /**
     * Gives the URL's of the Static Resources provided
     * Returns Blank Map if Not Found
     * @param resourceNames - the List of the Static Resource Names
     * @return a Map representing the URL's of the Static Resources by Name
    */

    public static Map<String, String> getStaticResourceURLByName(List<String> resourceNames){
        system.debug('getStaticResourceURL method entered');
        Map<String, String> returnmap = new Map<String, String>();
        Map<String, StaticResource> srMap = staticResourceMap;
        for (String name : resourceNames) {
            if(srMap.containsKey(name)){
                StaticResource sr = srMap.get(name);
                String namespace = srMap.get(name).NamespacePrefix;
                returnmap.put(sr.name, '/resource/' + sr.SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + sr.Name + '?');
            }
        }
        return returnmap;
    }

    /**
     * Method takes a string and converts it to 'Title Case' (Camel Case, split by existing spaces, with common words such as of/the/for not capitalized)
     * @param phrase The string title that is to be converted to 'Title Case'
     * @return The provided string transformed into 'Title Case'
     */
    public static String toTitleCase( String phrase ) {
        String titlePhrase = '';
        Set<String> forceLower = new Set<String>{'of', 'the', 'for', 'and', 'a', 'to', 'at' ,'an', 'but', 'if', 'or', 'nor'};

        if( phrase != null && phrase.length() > 0 ) {
            String[] splitPhrase = phrase.trim().split(' ');

            for( integer i = 0; i < splitPhrase.size(); i++ ) {
                if( !forceLower.contains( splitPhrase[i].toLowerCase() ) || i == 0 || i == ( splitPhrase.size() - 1 ) ) {
                    titlePhrase += ( splitPhrase[i].substring(0,1).toUpperCase() )+( splitPhrase[i].substring(1).toLowerCase() )+' ';
                } else {
                    titlePhrase += splitPhrase[i].toLowerCase()+' ';
                }
            }
        }
        return titlePhrase.trim();
    }

    /**
     * Method to easily get SObjectType (Generic Object Data) from just an API Name
     * @param objName The API Name of an Object in the system
     * @return The SObjectType of the provided API Name
     */
    public static SObjectType getSObjectTypeForObjectByName( String objName ) {
        return ( (SObject) Type.forName( 'Schema', objName ).newInstance() ).getSObjectType();
    }

    /**
     * base URL needed for downloading a Content Document in Apex
     */
    public static final String CONTENT_DOCUMENT_BASE_URL = '/sfc/servlet.shepherd/version/download/';
    /**
     * Returns a String which is a downloadable URL of the Content Version sent in
     * @param contentVersionId the Id of the ContentVesion you wish to Download
     * @return  `String` URL to download the ContentVersion sent in
     */
    public static String getContentVersionDownloadableLink( Id contentVersionId ){
        if( contentVersionId == null || contentVersionId.getSobjectType() != Schema.ContentVersion.getSObjectType() ) return null;
        return URL.getSalesforceBaseUrl().toExternalForm() + CONTENT_DOCUMENT_BASE_URL + contentVersionId;
    }

    /**
     * Return if Daylights Savings Time is ongoing in Easter Standard Time
     *
     * @param Datetime dt - the datetime to check if EST is active
     * @return Boolean representing whether DST is in effect
     */
    public static Boolean isDSTActiveInEST(Datetime dt) {
        Timezone tz = Timezone.getTimeZone('America/New_York');

        // Adjust for Daylight Savings time by comparing current EST timezone offset
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_methods_system_timezone.htm
        if (tz.getOffset(dt) == -18000000) {
            return true;
        }

        return false;
    }
    /**
     * Returns a Map of DeveloperName to Salesforce Setting based on the Salesforce Setting Dev Names passed in
     * @param salesforceSettingDeveloperNames - Set of Salesforce Setting API Names
     * @return  `Map<String,Salesforce_Setting__mdt>`
     */
    public static Map<String,Salesforce_Setting__mdt> getSalesforceSettings( Set<String> salesforceSettingDeveloperNames ){
        Map<String, Salesforce_Setting__mdt> devNameToSfSettingMap = new Map<String, Salesforce_Setting__mdt>();
        List<Salesforce_Setting__mdt> sfSettingList = new List<Salesforce_Setting__mdt>();
        if( Test.isRunningTest() ) sfSettingList.add( new Salesforce_Setting__mdt() );
        sfSettingList.addAll( [ SELECT Id, DeveloperName, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName IN :salesforceSettingDeveloperNames ] );
        for( Salesforce_Setting__mdt sfsetting : sfSettingList ){
            devNameToSfSettingMap.put( sfsetting.DeveloperName, sfsetting );
        }
        return devNameToSfSettingMap;
    }
    /**
     * Gets the ACV User Id and the Identity Id for a user based on their email
     * @param emailSet set of emails for the users we want to grab the id for
     * @return  `Map<String,Contact>` Map of Email to Contact record
     */
    public static Map<String,Contact> getAcvUserId( Set<String> emailSet ){
        Map<String,Contact> emailToContactMap = new Map<String,Contact>();
        // Filtered Email is to account for Sandboxes where .invalid breaks stuff
        Map<String,String> filteredEmailToRunningUserEmailMap = new Map<String,String>();
        for( String thisEmail : emailSet ){
            filteredEmailToRunningUserEmailMap.put( thisEmail.removeEndIgnoreCase('.invalid'), thisEmail );
        }
        Id acvUserRtId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        for( Contact c : [ SELECT Id, Email, Id__c, Identity_Id__c FROM Contact WHERE Email IN :filteredEmailToRunningUserEmailMap.keySet() AND RecordTypeId = :acvUserRtId AND Active__c = True ] ){
            emailToContactMap.put( filteredEmailToRunningUserEmailMap.get(c.Email), c );
        }
        return emailToContactMap;
    }
    
    /**
     * Accepts an integer and delays your context in as many seconds as the integer value
     */
    public static void delay(Integer seconds) {
        if (!test.isRunningTest()) {
            DateTime start = System.Now().addSeconds(seconds); 
            while(System.Now().getTime() < start.getTime()){}
        }
    }
}