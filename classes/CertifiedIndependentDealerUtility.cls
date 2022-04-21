public with sharing class CertifiedIndependentDealerUtility {
    public static Map<String,Schema.SObjectField> getSobjectFieldMap(String objectName){
        Schema.SObjectType programObjectDescribe = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> fields = null;
        if(programObjectDescribe != null){
            Schema.DescribeSObjectResult programFieldDescribe = programObjectDescribe.getDescribe();
            fields = programFieldDescribe.fields.getMap() ;
        }
        return fields;
    }

    public static Schema.DescribeFieldResult getSobjectFieldResult(String objectName, String fieldName){
        Map<String,Schema.SObjectField> sobjectFields = getSobjectFieldMap(objectName);
        Schema.DescribeFieldResult sobjectFieldResult = null;
        if(sobjectFields != null && sobjectFields.containsKey(fieldName)){
            sobjectFieldResult = sobjectFields.get(fieldName).getDescribe();
        }
        return sobjectFieldResult;
    }

    public static String getSalesContactUserLookupFields(String fieldPrefix){
        Schema.DescribeFieldResult salesContactFieldResult = getSobjectFieldResult('Program__c','Sales_Contact__c');
        String userLookupFieldNamesOnAccount = '';
        if(salesContactFieldResult != null){
            List<Schema.PicklistEntry> ple = salesContactFieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                userLookupFieldNamesOnAccount += ', '+fieldPrefix+pickListVal.getValue();
            }
        }
        return userLookupFieldNamesOnAccount;
    }
}