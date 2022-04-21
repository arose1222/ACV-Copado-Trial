@isTest
public class CaseCreationBatchTest {

    @isTest
    static void logGenerationTest(){
        CaseCreationBatch batch = new CaseCreationBatch();
        Map<String, Integer> strIntMap = new Map<String, Integer>{'Test'=>1};
        batch.caseLog(strIntMap);
    }
    
    @isTest
    static void caseMapAdditionTest(){
        CaseCreationBatch batch = new CaseCreationBatch();
        Map<String, Integer> strIntMap = new Map<String, Integer>();
        
        Id masterRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Master').getRecordTypeId();
        
        List<Case> caseList = new List<Case>();
        Case c1 = new Case();
        c1.RecordTypeId = masterRecordTypeId;
        caseList.add(c1);
        
        batch.addCasesToMap(strIntMap, caseList);
        System.assert(strIntMap.size() == 1);
    }
    
    //test log method
    //
    //test addCases method
    
}