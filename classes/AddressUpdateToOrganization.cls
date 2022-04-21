public with sharing class AddressUpdateToOrganization extends TriggerInterface {

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 

        addressUpdate((Map<Id,Schema.Address>) incomingNewMap, (Map<Id,Schema.Address>) incomingOldMap);

    }
    //big comment block to describe why we are doing this, its to call the OrganizationAddressUpdate class for Assoc
    public void addressUpdate (Map<Id,Schema.Address> newAddMap, Map<Id,Schema.Address> oldAddMap){ 
        Set<Id> IdSet = new Set<Id>();
        // List<AssociatedLocation> updateList = new List<AssociatedLocation>();
        for(Schema.Address a : newAddMap.values()){
            if(a.street != oldAddMap.get(a.id).street ||
            a.street != oldAddMap.get(a.id).City ||
            a.street != oldAddMap.get(a.id).PostalCode ||
            a.street != oldAddMap.get(a.id).State ||
            a.street != oldAddMap.get(a.id).Country){
                IdSet.add(a.Id);
            }
        }
        if(IdSet.size() > 0){
            List<AssociatedLocation> updateList = [Select id From AssociatedLocation Where Location.VisitorAddressId IN :IdSet];
            update updateList;
        }
    }
}