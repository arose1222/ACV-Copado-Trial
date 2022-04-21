public with sharing class CustomerInquiryReportAProblemHandler extends TriggerInterface {
    public static final Id notesId = Schema.SObjectType.Inquiry_Comment__c.getRecordTypeInfosByDeveloperName().get('Inquiry_Comment').getRecordTypeId();
    public static final Set<String> specialistStatuses = new Set<String>{'Problem', 'Return to Seller', 'Closed Unwound', 'Returned to Seller Unwound', 'Title at ACV Unwound'};
    public static final Set<String> csAdvocateStatuses = new Set<String>{'Working', 'Received', 'New', '48 Hour Notice', 'Sent'};

    public override void beforeInsert(List<sObject> newList) {
        List<Customer_Inquiry__c> newCIList = (List<Customer_Inquiry__c>)newList;
        Map<String, Customer_Inquiry__c> rapCImap = new Map<String, Customer_Inquiry__c>();
        Map<String, Case> caseMap = new Map<String, Case>();
        Map<Id, Auction__c> aucMap = new Map<Id, Auction__c>();
        Set<String> acvAucIdSet = new Set<String>();

        for (Customer_Inquiry__c c : newCIList) {
            if (c.Origin__c == 'Report a Problem') {
                rapCImap.put(c.External_Id__c, c);
                acvAucIdSet.add(c.Auction__c);
            }
        }

        if (rapCImap.size() > 0) { 
            if (!acvAucIdSet.isEmpty()) {
                for (Case ca : [SELECT Id, Status, Auction_Number__c, CreatedDate FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND Auction_Number__c IN :acvAucIdSet]) {
                    if (!caseMap.containsKey(ca.Auction_Number__c)) {
                        caseMap.put(ca.Auction_Number__c, ca);
                    }
                    else if (ca.CreatedDate > caseMap.get(ca.Auction_Number__c).CreatedDate) {
                        caseMap.put(ca.Auction_Number__c, ca);
                    }
                }

                aucMap = new Map<Id, Auction__c>([SELECT Id, Seller_Dealership__r.Title_Specialist__c, Seller_Dealership__r.Customer_Success_Advocate__c FROM Auction__c WHERE Id IN :acvAucIdSet]);
            }

            for (Customer_Inquiry__c ci : rapCImap.values()) {
                Auction__c aucRec = aucMap.get(ci.Auction__c);
                Case caseRec = new Case();
                if (caseMap.containsKey(ci.Auction__c)) {
                    caseRec = caseMap.get(ci.Auction__c);
                }

                ci.Ops_Case__c = caseRec?.Id;

                // if (ci.Call_Type__c == 'Buyer Reported Problem') {
                //     if (aucRec?.Seller_Dealership__r?.Title_Specialist__c != null) {
                //         ci.Assigned_To__c = aucRec.Seller_Dealership__r.Title_Specialist__c;
                //     }
                //     else {
                //         ci.Should_Assign_To__c = 'Specialist';
                //     }
                // }
                // else if (caseMap.containsKey(ci.Auction__c)) {
                //     if (ci.Call_Type__c == 'Buyer Title Status' && specialistStatuses.contains(caseRec?.Status)) {
                //         if (aucRec?.Seller_Dealership__r?.Title_Specialist__c != null) {
                //             ci.Assigned_To__c = aucRec.Seller_Dealership__r.Title_Specialist__c;
                //         }
                //         else {
                //             ci.Should_Assign_To__c = 'Specialist';
                //         }
                //     }
                //     else if (ci.Call_Type__c == 'Buyer Title Status' && csAdvocateStatuses.contains(caseRec?.Status)) {
                //         if (aucRec?.Seller_Dealership__r?.Customer_Success_Advocate__c != null) {
                //             ci.Assigned_To__c = aucRec.Seller_Dealership__r.Customer_Success_Advocate__c;
                //         }
                //         else {
                //             ci.Should_Assign_To__c = 'Consultant';
                //         }
                //     }
                // }
            }
        }
    }

    public override void afterInsert(List<sObject> newList) {
        List<Customer_Inquiry__c> newCIList = (List<Customer_Inquiry__c>)newList;
        List<Inquiry_Comment__c> icList = new List<Inquiry_Comment__c>();
        for (Customer_Inquiry__c ci : newCIList) {
            if (ci.Origin__c == 'Report a Problem') {
                icList.add(new Inquiry_Comment__c(RecordTypeId = notesId, Customer_Inquiry__c = ci.Id, Inquiry_Notes__c = ci.Call_Notes__c));
            }
        }
        if (icList.size() > 0) {
            insert icList;
        }
    }
}