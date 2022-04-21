public without sharing class DemoRequestReminder extends TriggerInterface {
    public override void afterInsert(List<sObject> objectList) {
        List<Lead> leadList = (List<Lead>)objectList;
        Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        List<Lead> leadsToUpdate = new LIst<Lead>();
        
        for (Lead l : leadList) {
            if (l.RecordTypeId == recordTypeId) {
                DateTime newDate = l.CreatedDate;
                do {
                    newDate = newDate.addDays(1);
                } while (ACVUtility.isStandardHoliday(newDate) == true || ACVUtility.isWeekend(newDate) == true);
                leadsToUpdate.add(new Lead(Id = l.Id, Reminder_Email_Timer__c = newDate));
            }
        }
        update leadsToUpdate;
    }
    
    /*
     * Description - Method will be executed on after update of the Lead records 
     * Params - Old and New Instances of Trigger.Maps
     * Return - null
	*/
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        LeadTriggerUtility.setLeadAndAccountCount(oldMap, newMap);
    }
    
    /*
     * Description - Method will be executed on after delete of the Lead records 
     * Params - Old Instance of Trigger.Map
     * Return - null
	
    public override void afterDelete(Map<Id,SObject> oldMap){
        LeadTriggerUtility.setLeadAndAccountCount(oldMap);
    }
	*/
}