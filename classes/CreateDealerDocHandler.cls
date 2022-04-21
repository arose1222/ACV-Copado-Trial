public with sharing class CreateDealerDocHandler {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    private final static Integer MAX_RESULTS = 5;
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getLookupInfo(String searchTerm){ //, List<String> selectedIds - removed because it's not used
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
        Dealer_Docs__c (Id, Account__r.Name, License_Number__c WHERE RecordTypeId = :licenseId) //Id NOT IN :selectedIds AND - removed because it's not used
        LIMIT :MAX_RESULTS];

        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String icon = 'standard:note';
        Dealer_Docs__c [] docList = ((List<Dealer_Docs__c>) searchResults[0]);
        for (Dealer_Docs__c d : docList) {
            results.add(new LookupSearchResult(d.Id, 'Dealer Doc', icon, d.License_Number__c, 'Account • '+ d.Account__r.Name));
        }

        return results;
    }

    @AuraEnabled
    public static String getLicenseNumber(Id relLicId){
        //need to auto-populate the license number
        System.debug(relLicId);
        Dealer_Docs__c licDoc = [SELECT Id, License_Number__c FROM Dealer_Docs__c WHERE Id = :relLicId];
        String licNum = licDoc.License_Number__c;
        return licNum;
    }
}