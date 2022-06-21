@isTest
public class CaseCreationBatchTest {



    @TestSetup
    static void makeData() {
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName();
        List<Case> caseInsertList = new List<Case>();

        caseInsertList.add(new Case(status = 'new', origin = 'Collections', RecordTypeId = rtMap.get('Collections').getRecordTypeId()));
        caseInsertList.add(new Case(status = 'new', origin = 'Phone', RecordTypeId = rtMap.get('Support').getRecordTypeId()));

        insert caseInsertList;

    }

    @isTest
    static void countInsertedCases(){
        CaseCreationBatch ccb = new CaseCreationBatch();
        test.startTest();
        Database.executeBatch(ccb);
        test.stopTest();

        System.assert(CaseCreationBatch.recordTypeCountMap.get('Support') == 1, 'The number of created support cases was incorrect');
        System.assert(CaseCreationBatch.recordTypeCountMap.get('Collections') == 1, 'The number of created collections cases was incorrect');
        System.assert(CaseCreationBatch.totalCaseCount == 2, 'The total number of created cases was incorrect');
    
    }

    @isTest
    static void countInsertCasesFromTime(){
        
        CaseCreationBatch ccb = new CaseCreationBatch(Datetime.now().addMinutes(-10));
        test.startTest();
        Database.executeBatch(ccb);
        test.stopTest();

        System.assert(CaseCreationBatch.recordTypeCountMap.get('Support') == 1, 'The number of created support cases was incorrect');
        System.assert(CaseCreationBatch.recordTypeCountMap.get('Collections') == 1, 'The number of created collections cases was incorrect');
        System.assert(CaseCreationBatch.totalCaseCount == 2, 'The total number of created cases was incorrect');
    }
}