public without sharing class ISTCaseListController {
    
    @AuraEnabled(cacheable = true)
    public static List<Case> getAllCases(String accountId, Boolean asSeller){
        // if asSeller = true - query seller dealership relationship
        String queryString = 'Select Id, CaseNumber, Status, Age_in_Days__c, RecordType.Name, RecordTypeId, Title_Attached__c, Auction_Number__r.Name, Auction_Start_Time__c, Vehicle__c,Vehicle_VIN__c, isClosed, Vehicle__r.Year_Make_Model_Trim__c FROM Case WHERE ';
        if (asSeller) {
            queryString += 'Seller_Dealership__c = :accountId';
        }
        else {
            queryString += 'AccountId = :accountId';
        }
        return Database.query(queryString);
    }

    @AuraEnabled(cacheable = true)
    public static String getRecordTypeSelectList(){
        List<Schema.RecordTypeInfo> RTList = Schema.SObjectType.Case.getRecordTypeInfos();
        List<LWCUtility.Picklist> returnList = new List<LWCUtility.Picklist>();
        returnList.add(new LWCUtility.Picklist('--None--', 'none'));
        for(Schema.RecordTypeInfo rt :RTList){
            if(rt.isActive()){
                returnList.add(new LWCUtility.Picklist(rt.name, rt.recordtypeid));
            }
        }

        return JSON.serialize(returnList);
    }
    
}