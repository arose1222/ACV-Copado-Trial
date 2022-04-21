public class VendorEngagementTriggerHandler extends TriggerInterface{
    
    /* This method is used to assign Vendor Engagement Owner with the Sr_Title_Specialist__c field value from the its associated Case record */
    public override void beforeInsert(List<SObject> newList){
        
        List<Vendor_Engagement__c> vendorRecs = (List<Vendor_Engagement__c>)newList;
        Map<Id, Vendor_Engagement__c> caseIdToVendorRec = new Map<Id, Vendor_Engagement__c>();
        Map<Id, Id> caseIdToSpecialistId = new Map<Id, Id>();
        
        for(Vendor_Engagement__c vendorRec :vendorRecs){
            if(vendorRec.Ops_Case__c != NULL){
                caseIdToVendorRec.put(vendorRec.Ops_Case__c,vendorRec);
            }
        }
        if(!caseIdToVendorRec.isEmpty()){
            for(Case caseRec : [Select Id, 
                                Seller_Dealership__c,
                                Seller_Dealership__r.Sr_Title_Specialist__c 
                                FROM Case 
                                WHERE ID IN :caseIdToVendorRec.keySet()]){
                if(caseRec.Seller_Dealership__c != NULL 
                   && caseRec.Seller_Dealership__r.Sr_Title_Specialist__c != NULL){
                       caseIdToSpecialistId.put(caseRec.Id, caseRec.Seller_Dealership__r.Sr_Title_Specialist__c);
                   }
            }
        }
        if(!caseIdToSpecialistId.isEmpty()){
            for(Vendor_Engagement__c vendorRec :caseIdToVendorRec.values()){
                if(caseIdToSpecialistId.containsKey(vendorRec.Ops_Case__c)){
                    vendorRec.OwnerId = caseIdToSpecialistId.get(vendorRec.Ops_Case__c);
                }
            }
        }
    }
    
    /* This method is used to update Status related Date/Time fields when the Status is changed. */
    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        
        Map<Id,Vendor_Engagement__c> vendorIdToVendorRec = (Map<Id,Vendor_Engagement__c>)newMap;
        Map<Id,Vendor_Engagement__c> vendorIdToOldVendorRec = (Map<Id,Vendor_Engagement__c>)oldMap;
        
        for(Vendor_Engagement__c vendorRec :vendorIdToVendorRec.values()){
            if(vendorRec.Status__c != NULL && vendorRec.Status__c != vendorIdToOldVendorRec.get(vendorRec.id).Status__c){
                if(vendorRec.Status__c == 'Working'){
                    vendorRec.Date_Time_of_Working_Status__c = System.now();
                }
                else if(vendorRec.Status__c == 'Received'){
                    vendorRec.Date_Time_of_Received_Status__c = System.now();
                }
                else if((vendorRec.Status__c == 'Approved' || vendorRec.Status__c == 'Denied')){
                    vendorRec.Date_Time_of_Approved_Denied_Status__c = System.now();
                }
            }
        }
    }
}