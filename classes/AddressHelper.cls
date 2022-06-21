/**
 * Helper class to generate address related records
 * @author Bill Sutton
 * @since 2020
 * @group Identity & Org
 */
public class AddressHelper {

    private static set<String> singleAddressTypeSet = new Set<String>{'billing', 'legal', 'title_mailing'};
    
    public static AssociatedLocation generateAddressStack(AddressWrapper adds, Id AccountID){
        return getAssLocationInfo(getAddressInfo(adds), AccountID, adds.type, adds.note, adds.altName, adds.subType,adds.afterHourDelivery,adds.primaryContact,adds.monfriStartTime,adds.monfriEndTime,adds.satStartTime,adds.satEndTime,adds.sunStartTime,adds.sunEndTime,adds.timeZone);
    }

    public static AssociatedLocation getAssLocationInfo(Schema.Address adds,Id AccountId, String addressType, String note, String altName, String addressSubType, String afterHourDelivery, String primaryContact,String monfriStart,String monfriEnd,String satStart, String satEnd, String sunStart, String sunEnd, String timeZone){
        AssociatedLocation asslocForUpdate = new AssociatedLocation();
        Decimal tempOrgId;
        if(singleAddressTypeSet.contains(addressType)){
            for(AssociatedLocation assl :[SELECT Id, Type, Inherited_Address_Id__c, Organization_Address_Id__c from AssociatedLocation WHERE ParentRecordId = :AccountId AND ActiveTo = null]){
                if(assl.Type == addressType){
                    tempOrgId = assl.Organization_Address_Id__c;
                    assl.Organization_Address_Id__c = null;
                    assl.ActiveTo = System.now();
                    asslocForUpdate = assl;
                    break;
                }
            }
        }
       
        if(tempOrgId != null){
            update asslocForUpdate;
            return new AssociatedLocation(ActiveFrom = System.now(), Inherited_Address_Id__c = true, LocationId = adds.parentId, Notes__c = note, Organization_Address_Id__c = tempOrgId, ParentRecordId = AccountId, Type = addressType, Alternate_Address_Name__c = altName,Address_Subtype__c = addressSubType,After_hour_deliveries_allowed__c = afterHourDelivery,Transportation_Primary_Contact__c = primaryContact,Monday_Friday_Start_Time__c  = monfriStart, Monday_Friday_End_Time__c =monfriEnd,Saturday_Start_Time__c =satStart,Saturday_End_Time__c =satEnd,Sunday_Start_Time__c  = sunStart, Sunday_End_Time__c  =sunEnd,TimeZone__c =timeZone );
        }
        else{
            return new AssociatedLocation(ActiveFrom = System.now(), LocationId = adds.parentId, Notes__c = note, ParentRecordId = AccountId, Type = addressType, Alternate_Address_Name__c = altName,Address_Subtype__c = addressSubType,After_hour_deliveries_allowed__c = afterHourDelivery,Transportation_Primary_Contact__c = primaryContact,Monday_Friday_Start_Time__c  = monfriStart, Monday_Friday_End_Time__c =monfriEnd,Saturday_Start_Time__c =satStart,Saturday_End_Time__c =satEnd,Sunday_Start_Time__c  = sunStart, Sunday_End_Time__c  =sunEnd,TimeZone__c =timeZone );
        }
    }

    public static Schema.Address getAddressInfo(AddressWrapper adds){
        Schema.Address returnAddress = new Schema.Address();
        List<Schema.Address> addressList = [SELECT Id, ParentId FROM Address WHERE Street = :adds.street AND postalCode = :adds.postalCode];
        if(addressList.size() == 1){
            //duplicate address check has found a dupe we return the existing address
            returnAddress = addressList[0];
        }
        else{
            Schema.Location l = generateLocationShell(adds.street, adds.postalCode, adds.country);
            Schema.Address newAddy = new Schema.Address();
            newAddy.parentId = l.id;
            newAddy.Street = adds.street;
            newAddy.City = adds.city;
            newAddy.State = adds.state;
            newAddy.PostalCode = adds.postalCode;
            newAddy.Country = adds.country;
            insert newAddy;
            //updating the location record to no longer be a shell and have the 
            l.VisitorAddressId = newAddy.Id;
            update l;
            returnAddress = newAddy;
        }
        return returnAddress;
    }

    public static Schema.Location generateLocationShell(String Street, String PostalCode, String Country){
        Schema.Location l = new Schema.Location();
        l.Name = Street+' '+PostalCode+' '+Country;
        insert l;
        return l;
    }

    public class AddressWrapper{
        public string street;
        public string city;
        public string state;
        public string postalCode;
        public string country;
        public string type;
        public string note;
        public string altName;
        public string subType;
        public string afterHourDelivery;
        public string primaryContact;
        public string monfriStartTime;
        public string monfriEndTime;
        public string satStartTime;
        public string satEndTime;
        public string sunStartTime;
        public string sunEndTime;
        public string timeZone;
        public AddressWrapper(){
            
        }

        public AddressWrapper(String s, String c, String st, String pc, String cty, String t, String n, string an, String subType, String afterHourDelivery, String primaryContact, String monfriStart, String monfriEnd,String satStart,String satEnd, String sunStart, String sunEnd,String timeZone){
            this.street = s;
            this.city = c;
            this.state = st;
            this.postalCode = pc;
            this.country = cty;
            this.type = t;
            this.note = n;
            this.altName = an;
            this.subType = subType;
            this.afterHourDelivery = afterHourDelivery;
            this.primaryContact = primaryContact;
            this.monfriStartTime = monfriStart;
            this.monfriEndTime = monfriEnd;
            this.satStartTime = satStart;
            this.satEndTime = satEnd;
            this.sunStartTime = sunStart;
            this.sunEndTime = sunEnd;
            this.timeZone = timeZone;
            
        }
    }

}