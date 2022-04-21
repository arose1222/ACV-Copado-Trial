public class ConvertVehicleColorSyntax extends TriggerInterface {
    private final Set<String> WORKTYPE_CHECK_SET = new Set<String>{ 'arbitration inspection', 'unwind inspection' };
    private final Map<String, String> COLOR_VEHICLE_CONVERT_MAP = ACVUtility.getPicklistValues( 'Vehicle__c', 'basic_color__c', FALSE );
        
	public override void beforeInsert( List<SObject> newList ) {
        for ( WorkOrderLineItem woli : (List<WorkOrderLineItem>) newList ) {
            if ( woli.WorkTypeId != null && WORKTYPE_CHECK_SET.contains( FSLWorkProcessUtility.workTypeIdMap.get( woli.WorkTypeId ).Work_Type_Unique_ID__c ) ) {
                woli.Color__c = COLOR_VEHICLE_CONVERT_MAP.get( woli.Color__c );
            }
        }
    }

}