public class PreventDuplicateEmailsForACVContacts extends TriggerInterface{

    public override void beforeInsert(List<sObject> newList){
        List<Contact> emailContactList = new List<Contact>();
        Set<String> emailSet = new Set<String>();
        for(Contact c :(List<Contact>)newList){
            if(ACVUtility.recordTypeCheck('ACV_User', 'Contact', c.RecordTypeID) && c.Email != null){
                emailContactList.add(c);
                emailSet.add(c.Email);
            }
        }
        checkForDuplicateEmail(emailContactList, new Map<Id,Contact>([SELECT Id, Email FROM Contact WHERE Email in :emailSet AND RecordType.DeveloperName = 'ACV_User']));
    }
    
    public override void beforeUpdate(Map<id,SObject> oldMap, Map<Id,SObject> newMap){
        Map<String, Contact> emailContactMap = new Map<String ,Contact>();
        Map<Id, Contact> newConMap = (Map<Id, Contact>)newMap;
        Map<Id, Set<String>> changeMap = ACVUtility.getChangedFields(newMap, oldMap, 'Contact');
        for(Contact c :newConMap.values()){
            if(ACVUtility.recordTypeCheck('ACV_User', 'Contact', c.RecordTypeID) && changeMap.get(c.Id) != null && changeMap.get(c.Id).contains('email') && c.Email != null){
                emailContactMap.put(c.Email, c);
            }
        }
        checkForDuplicateEmail(newConMap.values(), new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Email in :emailContactMap.keySet() AND Id NOT IN :newConMap.keySet() AND RecordType.DeveloperName = 'ACV_User']));
    }


    public void checkForDuplicateEmail(List<Contact> newContactMap, Map<Id,Contact> existingEmailContactMap){
        Map<String, Contact> conEmailMap = new Map<String, Contact>();
        for(Contact c: existingEmailContactMap.values()){
            conEmailMap.put(c.Email,c);
        }
        for(Contact c :newContactMap){
            if(conEmailMap.get(c.Email) != null){
                c.addError('Duplicate Email Address Found for ACV User');
            }
        }
    }
}