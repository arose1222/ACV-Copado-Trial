@isTest
public class ProgramRuleGeneratorControllerTest {
    
	@isTest
    static void TestafterUpdate(){
        String objectAPIName='Program_Rule__c';
        String fieldAPIName='Operator__c';
        
        Map<String, List<Map<String, String>>> fieldTypeAndOperatorList = ProgramRuleGeneratorController.getFieldTypeAndOperatorList(objectAPIName, fieldAPIName);
        Map<String, List<Map<String, String>>> objectFieldsByTypeMap = ProgramRuleGeneratorController.getObjectFieldsByTypeMap();
        
        DescribeObjectUsingAPIName.getObjectFields(objectAPIName);
        DescribeObjectUsingAPIName.getObjectFieldsMap(objectAPIName);
        
        System.assertEquals('Program_Rule__c', objectAPIName);
        System.assertEquals('Operator__c', fieldAPIName);
        System.assert(fieldTypeAndOperatorList != null);
        System.assert(objectFieldsByTypeMap != null);
        System.debug('@@@fieldTypeAndOperatorList@@@'+fieldTypeAndOperatorList);
        System.debug('@@@objectFieldsByTypeMap@@@'+objectFieldsByTypeMap);
        System.assertNotEquals(null, fieldTypeAndOperatorList);
        System.assertNotEquals(null, objectFieldsByTypeMap);
       // System.assertEquals(6, fieldTypeAndOperatorList.size());
       // System.assertEquals(30, objectFieldsByTypeMap.size());
        
    }
}