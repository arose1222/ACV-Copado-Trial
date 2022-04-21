/**
 * This class holds the logic for the old ResolutionTriggerHandler
 * It has been moved to the new Trigger Framework.
 * Originally Created by Huron Admin
 * @author James Andre LaCour
 */
public class VCIAssignmentUpdate extends TriggerInterface{
    /****************Context Methods************************/
    public override void beforeInsert(List<SObject> newList){
        VCIAssignmentUpdate.run( (List<Event>)newList );
    }
    /****************Helper Methods*************************/
    /**
     * On creation of Events, if the Event Type of the What Id is a Vehicle
	 * then we eventList vehicle values
     * @param newMap - List of Event records in Trigger
     * @return void
     */
    public static void run( List<Event> eventList ){
        set<Id> vehicleIdSet = new set<Id>();
        for(Event e :eventList){
            if(e.type == 'Vehicle Inspection' && e.whatId.getSobjectType() == Schema.Vehicle__c.SObjectType){
                vehicleIdSet.add(e.whatId);
            }
        }
        set<Id> sellerIdSet = new set<Id>();
        Map<Id,Vehicle__c> relatedVehicleMap = new Map<Id,Vehicle__c>([Select Id, Vin__c, Most_Recent_Seller__c, Assigned_VCI__c, Inspection_Status__c from Vehicle__c where id in :vehicleIdSet]);
        for(Vehicle__c v :relatedVehicleMap.values()){
            sellerIdSet.add(v.Most_Recent_Seller__c);
        }
        Map<Id,Account> relatedSellerMap = new Map<Id,Account>([Select Id, shippingStreet, shippingCity, shippingState,shippingPostalCode, shippingCountry from Account where id in :sellerIdSet]);
        if(relatedVehicleMap.values().size() > 0){
            for(Event e :eventList){
                e.Subject = 'Inspect Vehicle: '+relatedVehicleMap.get(e.whatId).Vin__c;
                e.Seller_Dealership__c = relatedVehicleMap.get(e.whatId).Most_Recent_Seller__c;
                e.Description = relatedSellerMap.get(relatedVehicleMap.get(e.whatId).Most_Recent_Seller__c).shippingStreet+' '+relatedSellerMap.get(relatedVehicleMap.get(e.whatId).Most_Recent_Seller__c).shippingCity+' '+relatedSellerMap.get(relatedVehicleMap.get(e.whatId).Most_Recent_Seller__c).shippingState+' '+relatedSellerMap.get(relatedVehicleMap.get(e.whatId).Most_Recent_Seller__c).shippingCountry+' '+relatedSellerMap.get(relatedVehicleMap.get(e.whatId).Most_Recent_Seller__c).shippingPostalCode;
                relatedVehicleMap.get(e.whatId).Assigned_VCI__c = e.OwnerId;
                relatedVehicleMap.get(e.whatId).Inspection_Status__c = 'Assigned';
            }
        }
        update relatedVehicleMap.values();
    }
}