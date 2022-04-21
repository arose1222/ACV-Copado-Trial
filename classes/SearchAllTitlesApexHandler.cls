public with sharing class SearchAllTitlesApexHandler {
    @AuraEnabled(cacheable=true)
    public static List<Case> getTitles(String searchTerm){
        if (String.isNotEmpty(searchTerm) && searchTerm.length() > 1) {
            searchTerm += '*';

            List<List<sObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING 
                                                Case (Id, Title_Attached__c, Status, CaseNumber, Auction_Number_Case__c, Auction_Number__r.Name, Auction_Number__c, Vehicle__c, Vehicle__r.Name, Vehicle_Make__c, Vehicle_Model__c, Vehicle_Year__c, Seller_Name__c, Buyer_Name__c, Age_in_Days__c, Payment_Method__c, Payment_Status__c
                                                WHERE Status IN ('New', '48 Hour Notice', 'Problem') AND RecordType.Name = 'Title Information' AND Age_in_Days__c < 50.0 ORDER BY Age_in_Days__c DESC)];

            List<Case> results = new List<Case>();
            Case [] titles = ((List<Case>) searchResults[0]);
            return titles;
        } 
        else {
            return [SELECT Id, Title_Attached__c, Status, CaseNumber, Auction_Number_Case__c, Auction_Number__r.Name, Auction_Number__c, Vehicle__c, Vehicle__r.Name, Vehicle_Make__c, Vehicle_Model__c, Vehicle_Year__c, Seller_Name__c, Buyer_Name__c, Age_in_Days__c, Payment_Method__c, Payment_Status__c
                FROM Case
                WHERE Status IN ('New', '48 Hour Notice', 'Problem')
                AND RecordType.Name = 'Title Information'
                AND Age_in_Days__c < 50.0
                ORDER BY Age_in_Days__c DESC LIMIT 100];
        }
    }
}
//AND Age_in_Days__c > 3.0
//AND Age_in_Days__c < 30.0