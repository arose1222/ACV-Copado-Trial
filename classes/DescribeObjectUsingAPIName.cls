public class DescribeObjectUsingAPIName {
    public static List<String> getObjectFields(String objectAPIName){
        SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        
        List<String> sObjectDetailsList = new List<String>();
        for(String s : mfields.keySet()){
            sObjectDetailsList.add(String.valueOf(mfields.get(s)));
        }
        return sObjectDetailsList;
    }

    public static List<Map<String, String>> getObjectFieldsMap(String objectAPIName){
        SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();

        List<Map<String,String>> sObjectDetailsList = new List<Map<String,String>>();
        for(Schema.SObjectField sobjField : mfields.values()){
            Schema.DescribeFieldResult sobjFieldResult = sobjField.getDescribe();
            Map<String,String> sobjectFieldMap = new Map<String,String>();
            sobjectFieldMap.put('value', objectAPIName+'.'+sobjFieldResult.getName()+'-'+sobjFieldResult.getType());
            sobjectFieldMap.put('label', sobjFieldResult.getLabel());
            sObjectDetailsList.add(sobjectFieldMap);
        }
        return sObjectDetailsList;
    }

    public static void getDependentFieldPicklistValuesMap(Map<String, List<Map<String, String>>> sObjectDetailsByTypeMap, String objectApiName, SObjectType sobjectDescribe){
        Map<String,Schema.SObjectField> programFields = sobjectDescribe.getDescribe().fields.getMap();
        for(Schema.SObjectField sobjField : programFields.values()){
            Schema.DescribeFieldResult sobjFieldResult = sobjField.getDescribe();
            String fieldTypeStr = String.valueOf(sobjFieldResult.getType());
            List<Map<String, String>> accountFieldsAll = sObjectDetailsByTypeMap.get(objectApiName+'ALL');
            if(accountFieldsAll == null){
                accountFieldsAll = new List<Map<String, String>>();
            }

            List<Map<String, String>> accountFieldsByType = sObjectDetailsByTypeMap.get(objectApiName+fieldTypeStr);
            if(accountFieldsByType == null){
                accountFieldsByType = new List<Map<String, String>>();
            }

            Map<String,String> sobjectFieldMap = new Map<String,String>();
            sobjectFieldMap.put('value', objectApiName+'.'+sobjFieldResult.getName()+'-'+fieldTypeStr);
            sobjectFieldMap.put('label', sobjFieldResult.getLabel());
            accountFieldsAll.add(sobjectFieldMap);
            accountFieldsByType.add(sobjectFieldMap);
            sObjectDetailsByTypeMap.put(objectApiName+'ALL', accountFieldsAll);
            sObjectDetailsByTypeMap.put(objectApiName+fieldTypeStr, accountFieldsByType);
        }
    }

    public static Map<String, List<Map<String, String>>> getDependentPicklistValues(Schema.sObjectField dependToken) {
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<Map<String, String>>>();
        }
     
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
     
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String, List<Map<String, String>>> dependentPicklistValues = new Map<String, List<Map<String, String>>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Map<String,String>>());
                    }
                    Map<String,String> picklistValueMap = new Map<String,String>();
                    picklistValueMap.put('value', entry.getValue());
                    picklistValueMap.put('label', entry.getLabel());
                    dependentPicklistValues.get((String) controlValue).add(picklistValueMap);
                }
            }
        }
        return dependentPicklistValues;
    }
}