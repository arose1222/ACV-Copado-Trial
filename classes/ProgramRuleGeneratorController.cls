public with sharing class ProgramRuleGeneratorController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getFieldTypeAndOperatorList(String objectAPIName, String fieldAPIName){
        SObjectType objectType = Schema.getGlobalDescribe().get(objectAPIName);
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        Map<String, List<Map<String, String>>> dependentPicklistValues = DescribeObjectUsingAPIName.getDependentPicklistValues(mfields.get(fieldAPIName));
        return dependentPicklistValues;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, String>>> getObjectFieldsByTypeMap(){
        Map<String,Schema.SObjectType> sObjectGlobalDescribe = Schema.getGlobalDescribe();
        Map<String, List<Map<String, String>>> sObjectDetailsByTypeMap = new Map<String, List<Map<String, String>>>();
        List<Map<String, String>> booleanFieldsByType = new List<Map<String, String>>();
        Map<String,String> booleanFieldMap = new Map<String,String>();
        booleanFieldMap.put('value', 'True');
        booleanFieldMap.put('label', 'True');
        booleanFieldsByType.add(booleanFieldMap);
        booleanFieldMap = new Map<String,String>();
        booleanFieldMap.put('value', 'False');
        booleanFieldMap.put('label', 'False');
        booleanFieldsByType.add(booleanFieldMap);
        sObjectDetailsByTypeMap.put('BOOLEAN', booleanFieldsByType);

        SObjectType accountDescribe = sObjectGlobalDescribe.get('Account');
        SObjectType programDescribe = sObjectGlobalDescribe.get('Program__c');
        DescribeObjectUsingAPIName.getDependentFieldPicklistValuesMap(sObjectDetailsByTypeMap, 'Account', accountDescribe);
        DescribeObjectUsingAPIName.getDependentFieldPicklistValuesMap(sObjectDetailsByTypeMap, 'Program__c', programDescribe);
        return sObjectDetailsByTypeMap;
    }
}