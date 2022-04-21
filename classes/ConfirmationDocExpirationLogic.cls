public with sharing class ConfirmationDocExpirationLogic {
    public static final Id confirmationId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('License_Renewal_Confirmation').getRecordTypeId();
    
    public static void handleExpiringToday(Set<Id> relAccts, Set<Id> relLics) {
        Date today = System.today();
        for (Dealer_Docs__c d : getDocs(relAccts, relLics, today)) {
            relLics.remove(d.Related_Dealer_License__c);
        }

        if (!relLics.isEmpty()) {
            List<Dealer_Docs__c> licsToUpdate = new List<Dealer_Docs__c>();
            for (Id i : relLics) {
                Dealer_Docs__c lic = new Dealer_Docs__c();
                lic.Id = i;
                lic.Document_Expired__c = true;
                lic.Compliant__c = false;
                lic.Compliance_Issues__c = 'Document expired';
                lic.Review_Status__c = null;

                licsToUpdate.add(lic);
            }
            update licsToUpdate;
        }
    }

    public static void handleExpiringInTwoWeeks(Map<Id, List<Dealer_Docs__c>> docMap, Set<Id> relAccts, Set<Id> relLics) {
        Date twoWeeks = System.today().addDays(14);
        for (Dealer_Docs__c d : getDocs(relAccts, relLics, twoWeeks)) {
            docMap.remove(d.Related_Dealer_License__c);
        }

        if (!docMap.isEmpty()) {
            List<Dealer_Docs__c> cdocsToUpdate = new List<Dealer_Docs__c>();
            for (Id i : docMap.keySet()) {
                for (Dealer_Docs__c d : docMap.get(i)) {
                    d.Reminder_Email_Sent__c = true;

                    cdocsToUpdate.add(d);
                }
            }
            update cdocsToUpdate;
        }
    }

    public static List<Dealer_Docs__c> getDocs(Set<Id> relAccts, Set<Id> relLics, Date theDate) {
        return [SELECT Id, Account__c, Related_Dealer_License__c FROM Dealer_Docs__c WHERE Account__c IN :relAccts AND Related_Dealer_License__c IN :relLics AND Expiration_Date__c > :theDate AND RecordTypeId = :confirmationId];
    }
}