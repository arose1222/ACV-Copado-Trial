/**
 * 'Trigger' on Map (FSL) Polygons to create sharing records to allow certain users to see them
 * @author Gerald McEvoy
 * @since 2/25/21
 */
public class ShareFSLPolygons extends TriggerInterface {

    /**
     * Calls the Generic Apex Sharing Engine functionality to generate and create sharing records for the Map (FSL) Polygon object
     * @param newList - List of FSL_Polygon__c (Map Polygons) objects from a trigger context, in new trigger context
     */
    public override void afterInsert( List<SObject> newList ) {
        insert ApexSharingEngine.identifyRules( newList );
    }
    
    /**
     * Calls the Generic Apex Sharing Engine functionality to generate and create sharing records for the Map (FSL) Polygon object
     * @param oldMap - Mao of FSL_Polygon__c (Map Polygons) objects, with Id of said objects as the key, from a trigger context, in old trigger context
     * @param newMap - Mao of FSL_Polygon__c (Map Polygons) objects, with Id of said objects as the key, from a trigger context, in new trigger context
     */
    public override void afterUpdate( Map<Id, SObject> oldMap, Map<Id, SObject> newMap ) {
        insert ApexSharingEngine.identifyRules( newMap.values() );
    }
}