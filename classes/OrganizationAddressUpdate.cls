public class OrganizationAddressUpdate extends TriggerInterface {

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void afterInsert(Map<Id,SObject> incomingMap){ 
    
        addressUpdate((Map<Id,AssociatedLocation>) incomingMap);

    }
    public override void afterUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){ 

        addressUpdate((Map<Id,AssociatedLocation>) incomingNewMap);

    }
    public override void BeforeDelete(Map<Id,SObject> oldMap){ 

        addressDelete((Map<Id,AssociatedLocation>) oldMap);

    }
    public override void afterUndelete(Map<Id,SObject> incomingMap){ 
    
        addressUpdate((Map<Id,AssociatedLocation>) incomingMap);

    }
    public void addressUpdate (Map<Id,AssociatedLocation> newAddMap){ 
    
        Map<Id,Account> newAccounts = new Map<Id,Account>();

        Map<id,AssociatedLocation> newAdd = new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, LocationId, Location.VisitorAddressId,
        Location.VisitorAddress.Street, Location.VisitorAddress.City, Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, 
        ParentRecord.BillingStreet, ParentRecord.BillingCity, ParentRecord.BillingPostalCode, ParentRecord.BillingState, ParentRecord.BillingCountry, ParentRecord.Pickup_Notes__c,
        ParentRecord.Legal_Street__c, ParentRecord.Legal_City__c, ParentRecord.Legal_State__c, ParentRecord.Legal_Country__c, ParentRecord.Legal_Zip_Code__c, ParentRecord.Legal_Address_Note__c,        
        ParentRecord.Title_Mailing_Street__c, ParentRecord.Title_Mailing_City__c, ParentRecord.Title_Mailing_State__c, ParentRecord.Title_Mailing_Country__c, ParentRecord.Title_Mailing_Zip_Code__c, ParentRecord.Title_Mailing_Address_Note__c                
        From AssociatedLocation Where id IN: newAddMap.keyset()]);

            for ( AssociatedLocation Add : newAdd.values() ) {
                if(newAccounts.get(Add.ParentRecordId) == null && (Add.type == 'billing' ||Add.type == 'legal' || Add.type == 'title_mailing')){
                    newAccounts.put(Add.ParentRecordId,new Account(id = Add.ParentRecordId));
                }
                if(Add.Type == 'billing'){
                //Upon Update of Address Record, Update Associated Account
                    newAccounts.get(Add.ParentRecordId).BillingStreet = Add.Location.VisitorAddress.Street;
                    newAccounts.get(Add.ParentRecordId).BillingCity = Add.Location.VisitorAddress.City;
                    newAccounts.get(Add.ParentRecordId).BillingPostalCode = Add.Location.VisitorAddress.PostalCode;
                    newAccounts.get(Add.ParentRecordId).BillingState = Add.Location.VisitorAddress.State;
                    newAccounts.get(Add.ParentRecordId).BillingCountry = Add.Location.VisitorAddress.Country;
                    newAccounts.get(Add.ParentRecordId).Pickup_Notes__c = Add.Notes__c;
                }
                if(Add.Type == 'title_mailing'){
                    //Upon Update of Address Record, Update Associated Account
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Street__c = Add.Location.VisitorAddress.Street;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_City__c = Add.Location.VisitorAddress.City;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Zip_Code__c = Add.Location.VisitorAddress.PostalCode;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_State__c = Add.Location.VisitorAddress.State;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Country__c = Add.Location.VisitorAddress.Country;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Address_Note__c = Add.Notes__c;
                }
                if(Add.Type == 'legal'){
                    //Upon Update of Address Record, Update Associated Account
                        newAccounts.get(Add.ParentRecordId).Legal_Street__c = Add.Location.VisitorAddress.Street;
                        newAccounts.get(Add.ParentRecordId).Legal_City__c = Add.Location.VisitorAddress.City;
                        newAccounts.get(Add.ParentRecordId).Legal_Zip_Code__c = Add.Location.VisitorAddress.PostalCode;
                        newAccounts.get(Add.ParentRecordId).Legal_State__c = Add.Location.VisitorAddress.State;
                        newAccounts.get(Add.ParentRecordId).Legal_Country__c = Add.Location.VisitorAddress.Country;
                        newAccounts.get(Add.ParentRecordId).Legal_Address_Note__c = Add.Notes__c;
                }
            }
            if (newAccounts.size() > 0){
                update newAccounts.values();     
            }
    }
    public void addressDelete (Map<Id,AssociatedLocation> newAddMap){ 
    
        Map<Id,Account> newAccounts = new Map<Id,Account>();

        Map<id,AssociatedLocation> newAdd = new Map<Id, AssociatedLocation>([Select id, Type, Notes__c, LocationId, Location.VisitorAddressId,
        Location.VisitorAddress.Street, Location.VisitorAddress.City, Location.VisitorAddress.PostalCode, Location.VisitorAddress.State, Location.VisitorAddress.Country, 
        ParentRecord.BillingStreet, ParentRecord.BillingCity, ParentRecord.BillingPostalCode, ParentRecord.BillingState, ParentRecord.BillingCountry, ParentRecord.Pickup_Notes__c,
        ParentRecord.Legal_Street__c, ParentRecord.Legal_City__c, ParentRecord.Legal_State__c, ParentRecord.Legal_Country__c, ParentRecord.Legal_Zip_Code__c, ParentRecord.Legal_Address_Note__c,        
        ParentRecord.Title_Mailing_Street__c, ParentRecord.Title_Mailing_City__c, ParentRecord.Title_Mailing_State__c, ParentRecord.Title_Mailing_Country__c, ParentRecord.Title_Mailing_Zip_Code__c, ParentRecord.Title_Mailing_Address_Note__c                
        From AssociatedLocation Where id IN: newAddMap.keyset()]);

            for ( AssociatedLocation Add : newAdd.values() ) {
                if(newAccounts.get(Add.ParentRecordId) == null && (Add.type == 'billing' ||Add.type == 'legal' || Add.type == 'title_mailing')){
                    newAccounts.put(Add.ParentRecordId,new Account(id = Add.ParentRecordId));
                }
                if(Add.Type == 'billing'){
                //Upon Update of Address Record, Update Associated Account
                    newAccounts.get(Add.ParentRecordId).BillingStreet = null;
                    newAccounts.get(Add.ParentRecordId).BillingCity = null;
                    newAccounts.get(Add.ParentRecordId).BillingPostalCode = null;
                    newAccounts.get(Add.ParentRecordId).BillingState = null;
                    newAccounts.get(Add.ParentRecordId).BillingCountry = null;
                    newAccounts.get(Add.ParentRecordId).Pickup_Notes__c = null;
                }
                if(Add.Type == 'title_mailing'){
                    //Upon Update of Address Record, Update Associated Account
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Street__c = null;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_City__c = null;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Zip_Code__c = null;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_State__c = null;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Country__c = null;
                        newAccounts.get(Add.ParentRecordId).Title_Mailing_Address_Note__c = null;
                }
                if(Add.Type == 'legal'){
                    //Upon Update of Address Record, Update Associated Account
                        newAccounts.get(Add.ParentRecordId).Legal_Street__c = null;
                        newAccounts.get(Add.ParentRecordId).Legal_City__c = null;
                        newAccounts.get(Add.ParentRecordId).Legal_Zip_Code__c = null;
                        newAccounts.get(Add.ParentRecordId).Legal_State__c = null;
                        newAccounts.get(Add.ParentRecordId).Legal_Country__c = null;
                        newAccounts.get(Add.ParentRecordId).Legal_Address_Note__c = null;
                }
            }
            if (newAccounts.size() > 0){
                update newAccounts.values();     
            }
    }
}