public class DealerDocInsertTimeStampForAcct extends TriggerInterface {
    public static final Set<String> specialStates = new Set<String>{'NH', 'DE', 'OR', 'MT', 'AK'};
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    public override void afterInsert(Map<Id, sObject> objectMap) { //has to be after because need the createdDate
        Map<Id, Dealer_Docs__c> docMap = (Map<Id, Dealer_Docs__c>)objectMap;
        Map<Id, Account> acctsToUpdate = new Map<Id, Account>();
        Set<Id> accountIdsLic = new Set<Id>();
        Set<Id> accountIdsRec = new Set<Id>();

        for (Dealer_Docs__c d : docMap.values()) {
            if (d.RecordTypeId == licenseId && d.Account__r.Required_Docs_Uploaded__c == null) {
                accountIdsRec.add(d.Account__c);
            }
            else if (d.RecordTypeId == resaleId && d.Account__r.Required_Docs_Uploaded__c == null) {
                accountIdsLic.add(d.Account__c);
            }
        }

        Map<Id, Account> licenseMap = new Map<Id, Account>([SELECT Id, Required_Docs_Uploaded__c, ( SELECT Id, RecordTypeId, Account__c FROM Dealer_Docs__r WHERE RecordType.DeveloperName = 'Dealer_License' ORDER BY CreatedDate ASC LIMIT 1 ) FROM Account WHERE Id IN :accountIdsLic]);
        Map<Id, Account> resaleMap = new Map<Id, Account>([SELECT Id, Required_Docs_Uploaded__c, ( SELECT Id, RecordTypeId, Account__c FROM Dealer_Docs__r WHERE RecordType.DeveloperName = 'Resale_Certificate' ORDER BY CreatedDate ASC LIMIT 1 ) FROM Account WHERE Id IN :accountIdsRec]);

        for (Dealer_Docs__c dd : docMap.values()) {
            //it's a license in a special state and the field is null
            //OR
            //it's a license, it's not in a special state, there is a resale, and the field is null // && resaleMap.get(dd.Account__c).Dealer_Docs__r != null
            if ((dd.RecordTypeId == licenseId && specialStates.contains(dd.Document_State__c) && resaleMap.get(dd.Account__c).Required_Docs_Uploaded__c == null) || (dd.RecordTypeId == licenseId && resaleMap.get(dd.Account__c).Dealer_Docs__r.size() != 0 && resaleMap.get(dd.Account__c).Required_Docs_Uploaded__c == null)) {
                resaleMap.get(dd.Account__c).Required_Docs_Uploaded__c = utcToEST(dd.CreatedDate); //change from UTC to EST
                acctsToUpdate.put(dd.Account__c, resaleMap.get(dd.Account__c));
            }
            //it's a resale, there is a license, and the field is null // && licenseMap.get(dd.Account__c).Dealer_Docs__r != null
            else if (dd.RecordTypeId == resaleId && licenseMap.get(dd.Account__c).Dealer_Docs__r.size() != 0 && licenseMap.get(dd.Account__c).Required_Docs_Uploaded__c == null) {
                licenseMap.get(dd.Account__c).Required_Docs_Uploaded__c = utcToEST(dd.CreatedDate); //change from UTC to EST
                acctsToUpdate.put(dd.Account__c, licenseMap.get(dd.Account__c));
            }
        }

        if (acctsToUpdate.values().size() > 0) {
            update acctsToUpdate.values();
        }
    }

    public DateTime utcToEST(DateTime utcCreatedDate) {
        Integer Day = utcCreatedDate.Day();
        Integer Month = utcCreatedDate.Month();
        Integer Year = utcCreatedDate.Year();
        Integer Hour = utcCreatedDate.Hour(); //so this is showing up as the EST hour, but the value in the field at the end is UTC still
        Integer estHour = Hour - 5; //i don't know how this works, but it works
        Integer Minute = utcCreatedDate.Minute();
        Integer Second = utcCreatedDate.Second();
        DateTime correctedDateTime = DateTime.newInstance(Year, Month, Day, estHour, Minute, Second); //so when it creates the new instance, it makes it UTC. fun.
        //System.debug(correctedDateTime);
        return correctedDateTime;
    }
}