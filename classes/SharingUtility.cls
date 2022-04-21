/**
 * Generic Sharing Utility that can take data on the type of object to share with and a map of SF sObject Id to List of SharingDefinition (Wrapper class) records to make Sharing Records, ready for insert
 * @author Gerald McEvoy
 * @since 2/25/21
 */
public class SharingUtility {
    private final static String USERORGROUPID_FIELDNAME = 'UserOrGroupId';
    private final static String ROWCAUSE_FIELDNAME = 'RowCause';

    /**
     * Enum to represent the two levels of Access a Sharing Record can give
     */
    public enum AccessLevel { EDIT, READ }
    /**
     * Map that takes a normalized string (camel case) and returns an Enum of AccessLevel, if one exists
     */
    private static Map<String, AccessLevel> convertAccessEnumMap {
        get {
            if ( convertAccessEnumMap == null ) {
                convertAccessEnumMap = new Map<String, AccessLevel>();
                for ( AccessLevel accessEnum : AccessLevel.values() ) {
                    convertAccessEnumMap.put(
                        String.valueOf( accessEnum ).toLowerCase(),
                        accessEnum
                    );
                }
            }
            return convertAccessEnumMap;
        }
        set;
    }

    /**
     * Wrapper class designed to represent the data associated with all Sharing Records, regardless of Object
     */
    public class SharingDefinition {
        public Id userOrGroupId; // Must be a User or Group Id
        public String rowCause; // See Object Sharing Row Definitions on Custom Objects - Only set if defined
        private AccessLevel accessLevel;

        /**
         * Construction for the SharingDefinition Wrapper class, sets up all the data for Sharing Record generation
         * @param providedRec Id of a User or Group that should be shared with
         * @param accessLevel Based off the Enum, the proper Access Level associated with the sharing record
         * @param cause The reason as to why this sharing is happening. By default, and in most cases, it is 'Manual'
         */
        public SharingDefinition( Id providedRec, String accessLevel, String cause ) {
            this.userOrGroupId = providedRec;
            this.accessLevel = convertAccessLevel( accessLevel );
            this.rowCause = !String.isBlank( cause ) ? cause : 'Manual';
        }

        /**
         * Returns this SharingDefinition's Access level in a consumable manner from the Enum data
         * @return  `String` A camel-case proper String of this SharingDefinition's Access Level
         */
        public String getAccessLevel() {
            return ACVUtility.toTitleCase( this.accessLevel.name() );
        }

        /**
         * Converts a user-defined Sharing Access Level to the system Enum
         * @param level The provided level of access for this SharingDefinition
         * @return  `AccessLevel` A Enum, if the provided input matches
         */
        private AccessLevel convertAccessLevel( String level ) {
            return convertAccessEnumMap.get( level.toLowerCase() );
        }
    }

    /**
     * Standard Method to take sharing data and convert into individual sharing records, per SharingDefinition record per sObject Id in the provided map. 
     * Records are returned without being committed to the database
     * @param objectType Generic SObject Data associated with the type of record you wish to make Sharing Records for
     * @param mapObjectIdUserIds Map of SObject Ids to the list of associated SharingDefinition records to be made into Sharing Records
     * @return A list of defined Sharing Records, the type dependes on the provided SObjectType data, that are ready to be saved, but not committed to the database
     */
    public static List<SObject> createSharingRecords( SObjectType objectType, Map<Id, List<SharingDefinition>> mapObjectIdUserIds ) {
        SharingSettings sharingData = getSharingSettings( objectType );
        return createSharingRecords( sharingData.parentFieldName, mapObjectIdUserIds, sharingData.accessLevelFieldName, sharingData.sharingObjectType );
    }

    /**
     * Alternative Method to take sharing data and convert into individual sharing records, per SharingDefinition record per sObject Id in the provided map. 
     * Records are returned without being committed to the database, after being filtered to avoid conflicts with existing matches in the database
     * @param objectType Generic SObject Data associated with the type of record you wish to make Sharing Records for
     * @param mapObjectIdUserIds Map of SObject Ids to the list of associated SharingDefinition records to be made into Sharing Records
     * @return A list of defined, unique Sharing Records, the type dependes on the provided SObjectType data, that are ready to be saved, but not committed to the database
     */
    public static List<SObject> createAndCompareSharingRecords( SObjectType objectType, Map<Id, List<SharingDefinition>> mapObjectIdUserIds ) {
        // Normal Sharing Processing
        SharingSettings sharingFields = getSharingSettings( objectType );
        List<SObject> sharingRuleLst = createSharingRecords( objectType, mapObjectIdUserIds );

        // Loop over records to make sets for query filter
        Set<Id> parentRecordIdSet = new Set<Id>();
        Set<Id> userOrGroupIdSet = new Set<Id>();
        for ( SObject sharingRuleRec : sharingRuleLst ) {
            parentRecordIdSet.add( (Id) sharingRuleRec.get( sharingFields.parentFieldName ) );
            userOrGroupIdSet.add( (Id) sharingRuleRec.get( USERORGROUPID_FIELDNAME ) );
        }

        // Make the Query to get existing Sharing Reccords
        String query = 'SELECT Id, ';        
        query += sharingFields.parentFieldName + ', ';
        query += sharingFields.accessLevelFieldName + ', ';
        query += ROWCAUSE_FIELDNAME + ', ';
        query += USERORGROUPID_FIELDNAME + ' ';
        query += ' FROM ' + sharingFields.sharingObjectType.getDescribe().getName() + ' ';
        query += ' WHERE ' + sharingFields.parentFieldName + ' IN :parentRecordIdSet ';
        query += 'AND ' + USERORGROUPID_FIELDNAME + ' IN :userOrGroupIdSet';

        // Loop over the Query Results, of existing Sharing Records, to make unique key maps for the sake of easy comparison
        Map<String, SObject> existingSharingIdMap = new Map<String, SObject>();
        for ( SObject existingSharingObj : Database.query( query ) ) {
            existingSharingIdMap.put( 
                makeSharingKey( 
                    existingSharingObj, 
                    sharingFields.parentFieldName,
                    USERORGROUPID_FIELDNAME
                ), 
                existingSharingObj 
            );
        }

        // Filter out results by existing Records
        for ( Integer i = 0; i < sharingRuleLst.size(); i++ ) {
            SObject newSharingRec = sharingRuleLst[i];
            String key = makeSharingKey(
                newSharingRec, 
                sharingFields.parentFieldName, 
                USERORGROUPID_FIELDNAME
            );
            SObject existingRec = existingSharingIdMap.get( key );
            if ( existingRec != null ) {
                sharingRuleLst.remove(i);
                i--;
            }
        }

        // Return results, with duplicates from existing records, filtered out
        return sharingRuleLst;
    }

    /**
     * Makes a unique key amongst a single Object's sharing records for the sake of duplication checking
     * @param obj The Sharing Object that a key should be generated for
     * @param parentFieldName The name of the Sharing Object's Parent Field Name (Differs amongst all Standard Objects and from Custom)
     * @param userOrGroupFieldName The name of the Sharing Object's User/Group associated Field (Differs amongst all Standard Objects and from Custom)
     * @return A unique key among a single Object's Sharing Records
     */
    private static String makeSharingKey( SObject obj, String parentFieldName, String userOrGroupFieldName ) {
        return '' + obj.get( parentFieldName ) + ':' + obj.get( userOrGroupFieldName );
    }

    /**
     * Wrapper class designed to identify the unique field names and properties of the Sharing Records for the provided type of object
     */
    private class SharingSettings {
        public String parentFieldName;
        public String accessLevelFieldName;
        public SObjectType sharingObjectType;

        /**
         * Taking generic SObjectType data, the construction pulls out and makes all the specific field names and SObjectType data for the Sharing Records
         * @param objectData The generic, SObject Data of the original records provided, that you wish to create Sharing Records for
         */
        public SharingSettings( SObjectType objectData ) {
            if ( objectData.getDescribe().isCustom() ) {
                this.parentFieldName = 'ParentId';
                this.accessLevelFieldName = 'AccessLevel';
                sharingObjectType = ACVUtility.getSObjectTypeForObjectByName( objectData.getDescribe().getName().removeEnd( '__c' ) + '__Share' );
            } else {
                String objectName = objectData.getDescribe().getName();
                this.parentFieldName = objectName + 'Id';
                this.accessLevelFieldName = objectName + 'AccessLevel';
                sharingObjectType = ACVUtility.getSObjectTypeForObjectByName( objectName + 'Share' );
            }
        }
    }

    private static SharingSettings sharingData;

    /**
     * A static SharingSetting accessor to get the generic, SObject data used for the definition of Sharing Records on the provided SObjectType
     * @param objectType Takes the provided SObjectType and extracts generic, SObject data for the sake of creating Sharing Records
     * @return A set of generic properties to help define the right Sharing Record setup (Differs amongst all Standard Objects and from Custom)
     */
    private static SharingSettings getSharingSettings( SObjectType objectType ) {
        if ( sharingData == null ) {
            sharingData = new SharingSettings( objectType );
        }
        return sharingData;
    }

    /**
     * Method takes the Generic Sharing information to structure any type of Sharing Record, utilizing the map of data to define what to fill in on those Sharing Records
     * @param strParentField The Name of the Parent Field on the Sharing Record (Differs amongst all Standard Objects and from Custom)
     * @param mapObjectIdUserIds Organized list of SharingDefinition records per provided SObject Id
     * @param strAccessLevelFieldName The name of the AccessLevel Field on the Sharing Record (Differs amongst all Standard Objects and from Custom)
     * @param objectType The data definition to determine what Sharing Record type to make
     * @return A list of defined Sharing Records, the type dependes on the provided SObjectType data, that are ready to be saved, but not committed to the database
     */
    private static list<SObject> createSharingRecords( String strParentField, Map<Id, List<SharingDefinition>> mapObjectIdUserIds, String strAccessLevelFieldName, SObjectType objectType ) {
        List<SObject> lstObjects = new List<SObject>();
        
        for( Id objectId : mapObjectIdUserIds.keySet() ) {
            for( SharingDefinition sdRec : mapObjectIdUserIds.get( objectId ) ) {
                SObject shareRecord = objectType.newsObject();
                shareRecord.put( strParentField, objectId );
                shareRecord.put( USERORGROUPID_FIELDNAME, sdRec.userOrGroupId );
                shareRecord.put( strAccessLevelFieldName, sdRec.getAccessLevel() );
                shareRecord.put( ROWCAUSE_FIELDNAME, sdRec.rowCause );            
                lstObjects.add( shareRecord );
            }
        }
        return lstObjects;
    }
}