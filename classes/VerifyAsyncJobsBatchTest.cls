@isTest
public class VerifyAsyncJobsBatchTest {
    
    @IsTest
    static void runBatch(){
        
        Test.startTest();
            SchedulableContext sc = null;
            VerifyAsyncJobsBatch batch = new VerifyAsyncJobsBatch();
            Batch.execute(sc);
        Test.stopTest();
        
    }
}