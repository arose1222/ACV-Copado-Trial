public class TransportationCaseProcesses {

    public static void runBeforeInsert(List<SobJect> incomingList){
        stampAddressInfoOnCase(incomingList);
        setPostedPrice(incomingList);
    }

    public static void runAfterInsert(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        TDRFiltering(Trigger.newMap);
        //CalcDriveDistance.run((List<Case>) incomingNewMap.values());
    }

    public static void runBeforeUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        stampAddressInfoOnCase(incomingNewMap.values());
        updateTransporterInformation(incomingNewMap, incomingOldMap);
        setPostedPrice(incomingNewMap, incomingOldMap);
    }

    public static void runAfterUpdate(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        TDRFiltering(Trigger.newMap);
        //CalcDriveDistance.run(Trigger.newMap, Trigger.oldMap);
    }

    public static void TDRFiltering(Map<Id,SobJect> incomingMap){
        Id TransportationRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        Map<id,sobject> processingMap = new Map<id,sObject>();
        for(sobject s :incomingMap.values()){
            if(s.get('recordTypeId') == TransportationRTID){
                processingMap.put(s.id,s);
            }
        }
        if(processingMap.values().size() > 0){
            CreateRelatedTDR.create((List<Case>) processingMap.values());
            TransportationDispatchRequestHandler.run(processingMap);
        }
    }

    public static void setPostedPrice(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        Map<id,case> newCaseMap = (Map<id,case>)incomingNewMap;
        Map<id,case> oldCaseMap = (Map<id,case>)incomingOldMap;

        Id TransportationRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<Case> changedCases = new List<Case>();
        for(Case c :newCaseMap.values()){
            if(c.RecordTypeId == TransportationRTID && c.Posted_Price__c == null && c.Buyer_Price__c != null){
                changedCases.add(c);
            }
        }

        if(changedCases.size() > 0){
            setPostedPrice((List<sObject>)changedCases);
        }
    }

    public static void setPostedPrice(List<SobJect> incomingList){
        List<Case> caseList = (List<Case>)incomingList;
        Id TransportationRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<Transport_Pricing__mdt> pricingList = [select Percent_Adjustment__c from Transport_Pricing__mdt where MasterLabel = 'First Posted Price'];
        if(pricingList.size() > 0){
            for(Case c :caseList){
                if(c.Buyer_Price__c != null){
                    c.Posted_Price__c = c.Buyer_Price__c * (pricingList[0].Percent_Adjustment__c/100);
                }
            }
        }
    }

    public static void updateTransporterInformation(Map<Id,SobJect> incomingNewMap, Map<Id,SobJect> incomingOldMap){
        Map<id,case> newCaseMap = (Map<id,case>)incomingNewMap;
        Map<id,case> oldCaseMap = (Map<id,case>)incomingOldMap;

        Id TransportationRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<Id> transporterIdList = new List<Id>();
        for(Case c :newCaseMap.values()){
            if(c.recordTypeId == TransportationRTID && c.Transporter_Account__c != null && c.Transporter_Account__c != oldCaseMap.get(c.id).Transporter_Account__c){
                transporterIdList.add(c.Transporter_Account__c);
            }
        }

        Map<Id,Account> transporterMap = new Map<Id,Account>([Select Id, Name, Email__c, Phone from Account Where Id in :transporterIdList]);
        for(Case c :newCaseMap.values()){
            if(c.RecordTypeId == TransportationRTID && c.Transporter_Account__c != null && transporterMap.get(c.Transporter_Account__c) != null && c.Transporter_Account__c != oldCaseMap.get(c.id).Transporter_Account__c){
                c.Transporter_Email__c = transporterMap.get(c.Transporter_Account__c).Email__c;
                c.Transporter_Name__c = transporterMap.get(c.Transporter_Account__c).Name;
                c.Transporter_Phone__c = transporterMap.get(c.Transporter_Account__c).Phone;
            }
        }
    }
    
    public static void stampAddressInfoOnCase(List<SobJect> incomingList){
        List<Case> caseList = (List<Case>)incomingList;
        Id TransportationRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<Id> dealershipIdList = new List<Id>();
        List<Id> parentCaseIdList = new List<Id>();
        for(case c : caseList){
            if(c.RecordTypeId == TransportationRTID && c.AccountId != null && c.Seller_Dealership__c != null){
                dealershipIdList.add(c.AccountId);
                dealershipIdList.add(c.Seller_Dealership__c);
            }
            if(c.RecordTypeId == TransportationRTID && c.ParentId != null){
                parentCaseIdList.add(c.ParentId);
            }
        }
        if(dealershipIdList.size()>0){
            Map<id,Account> dealerMap = new Map<Id, Account>([Select Id, Name, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone from Account where id in :dealershipIdList]);
            Map<id,Case> parentCaseMap = new Map<Id,Case>([Select Id, Vehicle_Location__c from Case where id in :parentCaseIdList]);
            for(case c :caseList){
                if(c.AccountId != null && dealerMap.get(c.AccountId) != null){
                    if(c.Delivery_Address_Name__c == null){
                        c.Delivery_Address_Name__c = dealerMap.get(c.AccountId).Name;
                    }
                    if(c.Default_Delivery_Address__c == null){
                        c.Default_Delivery_Address__c = dealerMap.get(c.AccountId).BillingStreet;
                    }
                    if(c.Default_Delivery_City__c == null){
                        c.Default_Delivery_City__c = dealerMap.get(c.AccountId).BillingCity;
                    }
                    if(c.Default_Delivery_Country__c == null){
                        c.Default_Delivery_Country__c = dealerMap.get(c.AccountId).BillingCountry;
                    }
                    if(c.Default_Delivery_Postal_Code__c == null){
                        c.Default_Delivery_Postal_Code__c = dealerMap.get(c.AccountId).BillingPostalCode;
                    }
                    if(c.Default_Delivery_State__c == null){
                        c.Default_Delivery_State__c = dealerMap.get(c.AccountId).BillingState;
                    }
                }
                if(c.Seller_Dealership__c != null && dealerMap.get(c.Seller_Dealership__c) != null){
                    if(c.Pickup_Address_Name__c == null){
                        c.Pickup_Address_Name__c = dealerMap.get(c.Seller_Dealership__c).Name;
                    }
                    if(c.Pickup_Address__c == null){
                        c.Pickup_Address__c = dealerMap.get(c.Seller_Dealership__c).BillingStreet;
                    }
                    if(c.Default_Pickup_City__c == null){
                        c.Default_Pickup_City__c = dealerMap.get(c.Seller_Dealership__c).BillingCity;
                    }
                    if(c.Default_Pickup_Country__c == null){
                        c.Default_Pickup_Country__c = dealerMap.get(c.Seller_Dealership__c).BillingCountry;
                    }
                    if(c.Default_Pickup_Postal_Code__c == null){
                        c.Default_Pickup_Postal_Code__c = dealerMap.get(c.Seller_Dealership__c).BillingPostalCode;
                    }
                    if(c.Default_Pickup_State__c == null){
                        c.Default_Pickup_State__c = dealerMap.get(c.Seller_Dealership__c).BillingState;
                    }
                }
                if(parentCaseMap.get(c.parentId) != null){
                    if(c.Vehicle_Location__c == null){
                        c.Vehicle_Location__c = parentCaseMap.get(c.ParentId).Vehicle_Location__c;
                    }
                }
            }
        }
    }
}