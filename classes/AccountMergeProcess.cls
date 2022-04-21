public class AccountMergeProcess extends TriggerInterface {

    public override void beforeDelete(Map<Id,SObject> incomingMap){ 
        

        Map<Id, Affiliation__c> deletedAffiliation = new Map<Id, Affiliation__c>([Select id, id__c, Account__c, Account__r.Dealership_Id__c, 
        Contact__c, Contact__r.id__c, Contact__r.RecordTypeId, LastModifiedBy.Email From Affiliation__c Where Account__c IN: incomingMap.keyset()]);

        List<Affiliation__c> deletedAffiliationList = new List<Affiliation__c>();

        if(deletedAffiliation.size() > 0){
            for(Affiliation__c aff : deletedAffiliation.values()){
                deletedAffiliationList.add(aff);
            }
        }
        if(deletedAffiliationList.size() > 0){
            // Line below is used to turn off validation rule that does not allow Affiliation to be deleted in a beforeDelete
            AffiliationPrimaryorAdminChangeCheck.validationEnabled = false;
            delete deletedAffiliationList;
            // Line below is used to turn the validation rule back on that does not allow Affiliation to be deleted in a beforeDelete
            AffiliationPrimaryorAdminChangeCheck.validationEnabled = true;
        }

        Map<Id, Contact> deletedContact = new Map<Id, Contact>([Select id, AccountId, Account.Dealership_Id__c, LastModifiedBy.Email, RecordTypeId, Contact_Guid__c, Dealership_Contact_Id__c
        From Contact Where AccountId IN: incomingMap.keyset()]);

        List<Contact> deletedContactList = new List<Contact>();

        if(deletedContact.size() > 0){
            for(Contact con : deletedContact.values()){
                deletedContactList.add(con);
            }
        }
        if(deletedContactList.size() > 0){
            // Line below is used to turn off validation rule that does not allow Contact to be deleted in a beforeDelete
            AffiliationPrimaryorAdminChangeCheck.validationEnabled = false;
            delete deletedContactList;
            // Line below is used to turn the validation rule back on that does not allow Contact to be deleted in a beforeDelete
            AffiliationPrimaryorAdminChangeCheck.validationEnabled = true;
        }

        Map<Id, AssociatedLocation> deletedAddress = new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, Organization_Address_Id__c, Inherited_Address_Id__c, ActiveTo,
        Organization_Address_Guid__c, LocationId, Location.VisitorAddressId, Location.VisitorAddress.Street, Location.VisitorAddress.City, Alternate_Address_Name__c,  
        Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, Location.VisitorAddress.Address_Guid__c, ParentRecord.Dealership_Id__c,
        LastModifiedBy.Email            
        From AssociatedLocation Where ParentRecordId IN: incomingMap.keyset()]);

        List<AssociatedLocation> deletedAddressList = new List<AssociatedLocation>();

        if(deletedAddress.size() > 0){
            for(AssociatedLocation ass : deletedAddress.values()){
                deletedAddressList.add(ass);
            }
        }
        if(deletedAddressList.size() > 0){
            delete deletedAddressList;
        }



    }

}