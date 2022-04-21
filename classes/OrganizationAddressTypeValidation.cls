public class OrganizationAddressTypeValidation extends TriggerInterface {

    Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

    public override void beforeInsert(List<SObject> newList){ 
    
        addressValidation(newList);
    }
    public override void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap){ 

        List<SObject> processedList = new List<SObject>();
        Map<Id, AssociatedLocation> oldALoc = (Map<Id, AssociatedLocation>) oldMap;
        Map<Id, AssociatedLocation> newALoc = (Map<Id, AssociatedLocation>) newMap;

        for (AssociatedLocation aL : newALoc.values()){
            if(aL.Type != oldALoc.get(aL.id).Type){
                processedList.add((SObject)aL);
            }
        }
        if(processedList.size() > 0){
            addressValidation(processedList);
        }
    }
    public override void afterUndelete(Map<Id,SObject> incomingMap){ 

        Map<Id, AssociatedLocation> newALoc = (Map<Id, AssociatedLocation>) incomingMap;
        List<SObject> processedList = new List<SObject>();

        for(AssociatedLocation aL : newALoc.values()){
            processedList.add((SObject)aL);
        }
        if(processedList.size() > 0){
            addressValidation(processedList);
        }


    }
    public void addressValidation(List<SObject> incomingList){

        Set<String> ruleType = new Set<String>{'legal', 'billing', 'title_mailing'};
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> aLIdSet = new Set<Id>();
        List<AssociatedLocation> typeList = (List<AssociatedLocation>) incomingList;
        Map<Id,Map<string,List<AssociatedLocation>>> accountTypeMap = new Map<Id,Map<string,List<AssociatedLocation>>>();

        for(AssociatedLocation aL : typeList){
            accountIdSet.add(aL.ParentRecordId);
            aLIdSet.add(aL.Id);
        }

        for(AssociatedLocation aL : [Select id, ParentRecordId, Type, isDeleted From AssociatedLocation Where ParentRecordId IN :accountIdSet and isdeleted = false and Organization_Address_Id__c != null and Id NOT IN :aLIdSet]){
            if(accountTypeMap.get(al.ParentRecordId) == null){
                accountTypeMap.put(al.ParentRecordId,new Map<string,List<AssociatedLocation>>());
                accountTypeMap.get(al.ParentRecordId).put(al.Type,new List<AssociatedLocation>{al});
            }
            else if(accountTypeMap.get(al.ParentRecordId).get(al.Type) == null){
                accountTypeMap.get(al.ParentRecordId).put(al.Type, new List<AssociatedLocation>{al});
            }
            else{
                accountTypeMap.get(al.ParentRecordId).get(al.Type).add(al);
            }
        }

        for(AssociatedLocation aL : typeList){
            if(ruleType.contains(al.Type) && (accountTypeMap?.get(al.ParentRecordId)?.get(al.Type) != null)){
                al.adderror('This Account already has a '+al.Type+' Address. Please update this address instead of creating a new one');
            }
        }        
    }
}