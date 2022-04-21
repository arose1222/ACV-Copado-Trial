public class MapsShapeLayerClearProcessing extends TriggerInterface {
    public override void afterUpdate( List<sObject> oldList, List<sObject> newList ) {
        List<maps__ShapeLayerGeometry__c> processOldLst = new List<maps__ShapeLayerGeometry__c>();
        Map<String, maps__ShapeLayerGeometry__c> processNewMap = new Map<String, maps__ShapeLayerGeometry__c>();
        for ( Integer index = 0; index < oldList.size(); index++ ) {
            maps__ShapeLayerGeometry__c oldMapShapeLayerGeoRec = (maps__ShapeLayerGeometry__c) oldList[index];
            maps__ShapeLayerGeometry__c newMapShapeLayerGeoRec = (maps__ShapeLayerGeometry__c) newList[index];

            if ( oldMapShapeLayerGeoRec.maps__Geometry__c != newMapShapeLayerGeoRec.maps__Geometry__c ) {
                processOldLst.add( oldMapShapeLayerGeoRec );
                processNewMap.put( newMapShapeLayerGeoRec.Id, newMapShapeLayerGeoRec );
            }
        }

        if ( !processOldLst.isEmpty() ) {
            MapsCheckZipcodes.checkAndClearZipcodes( processOldLst, processNewMap );
        }
    }

    public override void afterDelete( List<SObject> oldList ) {
        if ( !oldList.isEmpty() ) {
            MapsCheckZipcodes.checkAndClearZipcodes( (List<maps__ShapeLayerGeometry__c>) oldList, new Map<String, maps__ShapeLayerGeometry__c>() );
        }
    }
}