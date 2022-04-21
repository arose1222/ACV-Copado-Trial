/**
 * Trigger Interface class to just call the PreventDeletion service
 * @author Gerald McEvoy
 * @since 3/3/21
 */
public class PreventFSLPolygonDeletion extends TriggerInterface {

    /**
     * Takes Map (FSL) Polygon records and passes to PreventDeletion class
     * @param oldList Standard list of Trigger.old context records for the Map (FSL) Polygon object
     */
    public override void beforeDelete( List<SObject> oldList ) {    
        PreventDeletion.deletionError( oldList );
    }
}