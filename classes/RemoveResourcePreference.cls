/**
 * Designed to capture a Service Resource going inactive and removing the, now excessive and problematic, resource preferences associated with it
 * @author Gerald McEvoy
 * @since 3/9/21
 */
public class RemoveResourcePreference extends TriggerInterface {

    /**
     * Override method for After Update Trigger context, looks for any Service Resources being marked inactive (and only inactive)
     * @param oldMap Old Records in the Service Resource's Trigger context
     * @param newMap New Records in the Service Resource's Trigger context
     */
    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ) {
        Set<Id> srToProcessSet = new Set<Id>();
        for ( ServiceResource newSR : (List<ServiceResource>) newMap.values() ) {
            ServiceResource oldSR = (ServiceResource) oldMap.get( newSR.Id );
            if ( oldSR.isActive && !newSR.isActive ) { // Moved from Being Active to being Inactive
                srToProcessSet.add( newSR.Id );
            }
        }

        if ( !srToProcessSet.isEmpty() ) {
            reviewResourcePreferences( srToProcessSet );
        }
    }
    
    /**
     * Utility Method to fetch the statuses stored in Metadata for Work Order's Resource Preference removal
     */
    private final static Set<String> WO_STATUS_CHECK_SET {
        get {
            if ( WO_STATUS_CHECK_SET == null ) {
                Salesforce_Setting__mdt setting = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Delete Resource Preferences By WO Status' LIMIT 1 ];
                WO_STATUS_CHECK_SET = new Set<String>( setting.Value__c.split( ';' ) );          
            }
            return WO_STATUS_CHECK_SET;
        }
        set;
    }

    /**
     * Takes in Service Resouce Id set and grabs all Resource Preferences, sorting the Work Order related ones to just those in 'Open' statuses (and taking all Account ones by default), 
     * then deletes all Resource Preference records associated to the inactive, provided Service Resources
     * @param srIdSet A set of Service Resouce Ids that have turned inactive
     */
    @future
    public static void reviewResourcePreferences( Set<Id> srIdSet ) {
        List<ResourcePreference> rpToDeleteLst = new List<ResourcePreference>();
        Map<Id, List<ResourcePreference>> workIdToRPMap = new Map<Id, List<ResourcePreference>>();
        for ( ResourcePreference rpToProcess : [ SELECT Id, RelatedRecordId FROM ResourcePreference WHERE ServiceResourceId IN :srIdSet ] ) {
            if ( rpToProcess.RelatedRecordId.getSObjectType() == Schema.Account.SObjectType ) { // Always Delete Account Records that match
                rpToDeleteLst.add( rpToProcess );
            } else if ( rpToProcess.RelatedRecordId.getSObjectType() == Schema.WorkOrder.SObjectType ) { // Organize Work Order Records for the sake of further narrowing down
                if ( workIdToRPMap.get( rpToProcess.RelatedRecordId ) == null ) {
                    workIdToRPMap.put( rpToProcess.RelatedRecordId, new List<ResourcePreference>() );
                }
                workIdToRPMap.get( rpToProcess.RelatedRecordId ).add( rpToProcess );
            }
        }

        // Check the Work Orders, if applicable
        if ( !workIdToRPMap.isEmpty() ) {
            for ( WorkOrder wo : [ SELECT Id FROM WorkOrder WHERE Id IN :workIdToRPMap.keyset() AND Status IN :WO_STATUS_CHECK_SET ] ) {
                rpToDeleteLst.addAll( workIdToRPMap.get( wo.Id ) ); // Only add Resource Preferences filtered by our Query
            }
        }

        if ( !rpToDeleteLst.isEmpty() ) { // Delete Resource Preferences organized
            delete rpToDeleteLst;
        }
    }
}