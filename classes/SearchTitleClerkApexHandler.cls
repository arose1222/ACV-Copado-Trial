public with sharing class SearchTitleClerkApexHandler {
    @AuraEnabled(cacheable=true)
    public static String getTitleClerkBuyerInfo(String caseId) {
        // Id accountId = [SELECT Id, AccountId FROM Case WHERE Id = :caseId].AccountId;
        // return [SELECT Id, Name, Phone FROM Contact WHERE Title = 'Title Clerk' AND AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];
        Id accountId = [SELECT Id, AccountId FROM Case WHERE Id = :caseId].AccountId;
        List<Contact> titleClerk =  [SELECT Id, Name, Phone FROM Contact WHERE Title = 'Title Clerk' AND Active__c = true AND Id__c != null AND Phone != null AND AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];
        if (titleClerk.size() < 1) {
            titleClerk = [SELECT Id, Name, Phone FROM Contact WHERE Title = 'Title Clerk' AND Active__c = true AND AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];
        }
        String namePhone = '';
        if (accountId != null && titleClerk.size() > 0) {
            if (titleClerk[0].Name != null) {
                namePhone = titleClerk[0].Name;
                if (titleClerk[0].Phone != null) {
                    namePhone = namePhone + ' - ' +titleClerk[0].Phone;
                } else {
                    namePhone = namePhone + ' - no phone number';
                }
            }
            else if (titleClerk[0].Phone != null) {
                namePhone = titleClerk[0].Phone;
            }
        }
        return namePhone;
    }

    @AuraEnabled(cacheable=true)
    public static String getTitleClerkSellerInfo(String caseId) {
        Id accountId = [SELECT Id, Seller_Dealership__c FROM Case WHERE Id = :caseId].Seller_Dealership__c;
        List<Contact> titleClerk =  [SELECT Id, Name, Phone FROM Contact WHERE Title = 'Title Clerk' AND Active__c = true AND Id__c != null AND Phone != null AND AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];
        if (titleClerk.size() < 1) {
            titleClerk = [SELECT Id, Name, Phone FROM Contact WHERE Title = 'Title Clerk' AND Active__c = true AND AccountId = :accountId ORDER BY CreatedDate DESC LIMIT 1];
        }
        String namePhone = '';
        if (accountId != null && titleClerk.size() > 0) {
            if (titleClerk[0].Name != null) {
                namePhone = titleClerk[0].Name;
                if (titleClerk[0].Phone != null) {
                    namePhone = namePhone + ' - ' +titleClerk[0].Phone;
                } else {
                    namePhone = namePhone + ' - no phone number';
                }
            }
            else if (titleClerk[0].Phone != null) {
                namePhone = titleClerk[0].Phone;
            }
        }
        return namePhone;
    }
}