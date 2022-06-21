/**
 * Controller for addAddressToAccount LWC
 * @author Bill Sutton
 * @since 2020
 * @group Identity & Org
 */
public class AddAddressToAccountController {
    
    @AuraEnabled
    public static void GenerateAddress(String inputAddy, String accountId){
        AddressHelper.AddressWrapper aw = (AddressHelper.AddressWrapper)JSON.deserialize(inputAddy, AddressHelper.AddressWrapper.class);
        Savepoint sp = Database.setSavepoint();
        try {
            insert AddressHelper.generateAddressStack(aw, accountId);
        } catch (Exception e) {
            Database.rollback( sp );
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<LocationWrapper> getAddressList(String accountId){

        List<LocationWrapper> wrapperList = new List<LocationWrapper>();
        List<AssociatedLocation> activeLocations = [SELECT Id, Type, Active_Address__c , Notes__c ,Alternate_Address_Name__c , Inherited_Address_Id__c, Organization_Address_Id__c, Location.VisitorAddress.Street, Location.VisitorAddress.City, 
                Location.VisitorAddress.State, Location.VisitorAddress.PostalCode, Location.VisitorAddress.Country FROM AssociatedLocation WHERE ParentRecordId =:accountId and Active_Address__c = true ORDER BY Type ASC]; 
        
        if (!activeLocations.isEmpty()) {
            for (AssociatedLocation al : activeLocations) {
                LocationWrapper lw = new LocationWrapper();
                lw.Location = al;
                if (al.Type == 'billing') {
                   lw.OneBilling = true;
                }
                wrapperList.add(lw);
            }
        }
        system.debug('WrapperList size: '+wrapperList.size());
        return wrapperList;
    }
    
    /**
     * deactivates an address for an account in the app side
     * Organization_Address_Id__c is required to properly go to datahub, only exception is billing address since billing addresses will only update themselves with the existing ids
     * @param addressId 
     * @return  `Boolean`
     */
    @AuraEnabled
    public static Boolean deactivateAddress(String addressId){
        Boolean status = false; 
        List<AssociatedLocation> listAssociateLocation= [SELECT Id, ActiveTo, Organization_Address_Id__c FROM AssociatedLocation WHERE id=:addressId]; 
        if(listAssociateLocation.size()>0){
            listAssociateLocation[0].ActiveTo = System.now();
            //listAssociateLocation[0].Organization_Address_Id__c = null;
            update listAssociateLocation[0];
            status = true;
        }
        return status;
    }

    /**
    * @description It retrives all the fields that UpdateAddressToAccount LWC needs to update an Associated Locations.
    * @author Adrian Butron 04/29/2022
    * @param accountId Current account Id
    * @param addressId Current Address Type Id chosen
    * @return List<AssociatedLocation> 
    **/
    @AuraEnabled
    public static List<AssociatedLocation> retrieveCurrentAddress(String accountId, String addressId) {
        try {
            List<AssociatedLocation> activeLocations = [SELECT Id,Type,Alternate_Address_Name__c,Notes__c,Monday_Friday_Start_Time__c,Monday_Friday_End_Time__c,Saturday_Start_Time__c,Saturday_End_Time__c,Sunday_Start_Time__c,Sunday_End_Time__c,TimeZone__c FROM AssociatedLocation WHERE Id = :addressid AND ParentRecordId = :accountId]; 
            return activeLocations;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    	     
    /**
    * @description This method updates the Associated Locations in the account 
    * @author Adrian Butron 04/29/2022
    * @param accountId Current account Id
    * @param addressId Current Address Type Id chosen
    * @param addressAlternate Used to fill Alternate_Address_Name__c field
    * @param addressNotes Used to fill Notes__c field
    * @param timeZone Used to fill TimeZone__c field
    * @param monFriStartTime Used to fill Monday_Friday_Start_Time__c field
    * @param monFriEndTime Used to fill Monday_Friday_End_Time__c field
    * @param satStartTime Used to fill Saturday_Start_Time__c field
    * @param satEndTime Used to fill Saturday_End_Time__c field
    * @param sunStartTime Used to fill Sunday_Start_Time__c field
    * @param sunEndTime Used to fill Sunday_End_Time__c field
    * @return String 'Success' or 'Error'
    **/
    @AuraEnabled
    public static String updateAddress(String accountId, String addressId, String addressAlternate, String addressNotes, String timeZone, String monFriStartTime, String monFriEndTime,
                                     String satStartTime, String satEndTime, String sunStartTime, String sunEndTime) {

        String returnMessage;
        try {        
            List<AssociatedLocation> activeLocations = [SELECT Id,Alternate_Address_Name__c,Notes__c,Monday_Friday_Start_Time__c,Monday_Friday_End_Time__c,Saturday_Start_Time__c,Saturday_End_Time__c,Sunday_Start_Time__c,Sunday_End_Time__c,TimeZone__c FROM AssociatedLocation WHERE Id = :addressid AND ParentRecordId = :accountId]; 
            
            if(activeLocations.size() > 0) {                    
                for(AssociatedLocation assLoc : activeLocations) {                    
                    assLoc.Alternate_Address_Name__c = addressAlternate;
                    assLoc.Notes__c = addressNotes;
                    assLoc.Monday_Friday_Start_Time__c = monFriStartTime;
                    assLoc.Monday_Friday_End_Time__c = monFriEndTime;
                    assLoc.Saturday_Start_Time__c = satStartTime;
                    assLoc.Saturday_End_Time__c = satEndTime;
                    assLoc.Sunday_Start_Time__c = sunStartTime;
                    assLoc.Sunday_End_Time__c = sunEndTime;
                    assLoc.TimeZone__c = timeZone;
                }                
                update activeLocations;   
                returnMessage = 'Success';
            }     
        } catch (Exception e) {
            returnMessage = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        return returnMessage;   
    }
    
    public class LocationWrapper {
        @AuraEnabled
        public AssociatedLocation Location {get;set;}
        @AuraEnabled
        public Boolean OneBilling {get;set;}
    }      
}