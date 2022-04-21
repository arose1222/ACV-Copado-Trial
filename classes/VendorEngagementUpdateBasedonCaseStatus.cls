public class VendorEngagementUpdateBasedonCaseStatus extends TriggerInterface{
    
    public static Set<String> case_StatusVals = new Set<String>{'Received','Working','Sent'};
    public static Set<String> vendor_StatusVals = new Set<String>{'Submitted','Approved','Working'};
        
        
        public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
            Map<Id,Case> caseIdToNewCase = (Map<Id,Case>)newMap;
            Map<Id,Case> caseIdToOldCase = (Map<Id,Case>)oldMap;
            Set<Id> caseIds = new Set<Id>();
            List<Vendor_Engagement__c> vendorRecs = new List<Vendor_Engagement__c>();
            
            for(Case caseRec : caseIdToNewCase.values()){
                if(case_StatusVals.contains(caseRec.Status)){
                    caseIds.add(caseRec.Id);
                }
            }
            if(!caseIds.isEmpty()){
                for(Vendor_Engagement__c vendorRec : [Select Id, 
                                                      Ops_Case__c,
                                                      Status__c
                                                      FROM Vendor_Engagement__c 
                                                      WHERE Ops_Case__c IN :caseIds]
                   ){
                       if(vendor_StatusVals.contains(vendorRec.Status__c)){
                           vendorRec.Status__c = 'Received';
                           vendorRecs.add(vendorRec);
                       }
                   }
            }
            if(!vendorRecs.isEmpty()){
                update vendorRecs;
            }
        }
}