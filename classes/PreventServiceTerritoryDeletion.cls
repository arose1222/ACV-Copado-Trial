/**
 * Trigger Interface class to just call the PreventDeletion service
 * @author Gerald McEvoy
 * @since 3/3/21
 */
public class PreventServiceTerritoryDeletion extends TriggerInterface {
    
    /**
     * Takes Service Territory records and passes to PreventDeletion class
     * @param oldList Standard list of Trigger.old context records for the Service Territory object
     */
    public override void beforeDelete( List<SObject> oldList ) {    
        PreventDeletion.deletionError( oldList );
    }
}