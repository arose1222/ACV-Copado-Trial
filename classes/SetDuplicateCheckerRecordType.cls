/**
 * Generic trigger to update "Duplicate Checker Record Type" on the record. A trigger handler(custom metadata type) needs to be created.
 * @author Jyothsna P
 * @since 09/24/21
 */

public class SetDuplicateCheckerRecordType extends TriggerInterface {

    // Generate a record type map(Key: RecordTypeId, Value: DeveloperName)
    private static Map<String, String> rtMap {
        get {
            if(rtMap == null){
                Map<String, String> rtMap1 = new Map<String, String>();
                List<RecordType> rtList= [SELECT Id, DeveloperName From RecordType WHERE IsActive = True];
                for (RecordType rt: rtList)
                {
                    rtMap1.put(rt.id, rt.developername);
                }
                rtMap= rtmap1;
            }
            return rtMap;
        }set;
    }

    // Update Duplicate_Checker_Record_Type__c based on the record type
    public override void beforeInsert(List<sObject> objectList) {
        for (sObject obj : objectList) {
            Id rtId= (Id)obj.get('RecordTypeId');
            obj.put('Duplicate_Checker_Record_Type__c', rtMap.get(rtId));
        }
    }

    // Update Duplicate_Checker_Record_Type__c based on the record type
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist) {
        
        for (sObject obj : newlist) {
            Id rtId= (Id)obj.get('RecordTypeId');
            obj.put('Duplicate_Checker_Record_Type__c', rtMap.get(rtId));
        }
        
    }

    
}