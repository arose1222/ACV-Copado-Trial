@isTest(isParallel=true)
private class SiaCrEvaluatorTest {
    
    @isTest static void handle(){
        InspectionDefinition inspection = new InspectionDefinition();
        inspection.inspectionID = 'testId';

        PrescreenServiceHelper.InspectionWrapper wrapper = new PrescreenServiceHelper.InspectionWrapper(inspection,new Set<String>());
        Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        wrapperMap.put('testId', wrapper);
        
        CR_Review_Trigger__mdt metadata =CR_Review_Trigger__mdt.getInstance('SIA_Review');

        Test.setMock(HttpCalloutMock.class, new SiaCrEvaluatorMock()); 
        SiaCrEvaluator evaluator = new SiaCrEvaluator();

        Test.startTest();
        wrapperMap = evaluator.handle(wrapperMap,metadata);
        Test.stopTest();

        System.assertNotEquals(true, wrapperMap.get('testId').prescreenReasons.isEmpty());
    }

}