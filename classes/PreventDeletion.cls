/**
 * Class designed to take in any SObject, check against Metadata and potentially throw an error to stop deletion of records, defined by Metadata
 * @author Gerald McEvoy
 * @since 3/3/21
 */
public class PreventDeletion {

    /**
     * Set of SObject API Names to check in preparation to throw a prevent deletion error message. 
     * Controlled by Don't Delete Object metadata
     */
    private static Set<String> dontDeleteObjectSet {
        get {
            if ( dontDeleteObjectSet == null ) {
                dontDeleteObjectSet = new Set<String>();
                for ( Don_t_Delete_Object__mdt ddo : [ SELECT Label
                                                        FROM Don_t_Delete_Object__mdt
                                                        WHERE Prevent_Deletion__c = TRUE ] ) 
                {
                    dontDeleteObjectSet.add( ddo.Label );
                }
            }
            return dontDeleteObjectSet;
        }
        set;
    }

    /**
     * The String to throw as an error message to end users if they attempt to delete one of the 'configuration' records. 
     * Controlled by 'Deletion Framework Error' value in Salesforce Settings metadata
     */
    @TestVisible
    private final static String DELETION_ERROR_MESSAGE {
        get {
            if ( DELETION_ERROR_MESSAGE == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Deletion Framework Error' LIMIT 1 ];
                DELETION_ERROR_MESSAGE = setting.Value__c;
            }
            return DELETION_ERROR_MESSAGE;
        }
        set;
    }

    /**
     * Generic method to check against metadata to stop certain object's records from being deleted
     * @param objectLst List of any Object from the "before delete" context
     * @return  Same list of Objects provided, if approved by the metadata, returned with errors attached to them
     */
    public static List<SObject> deletionError( List<SObject> objectLst ) {
        if ( objectLst != null && !objectLst.isEmpty() ) {
            SObjectType objectType = objectLst[0].Id.getSobjectType();
            DescribeSObjectResult objData = objectType.getDescribe();
            if ( dontDeleteObjectSet.contains( objData.getName() ) ) {
                for ( SObject obj : objectLst ) {
                    obj.addError( DELETION_ERROR_MESSAGE );         
                }
            }
        }
        return objectLst;
    }
}