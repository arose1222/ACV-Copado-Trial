@IsTest
public class OptimizationRequestFailureTest {
    @isTest
    static void insertFailedRequest(){
        test.startTest();
            FSL__Optimization_Request__c optRequest = new FSL__Optimization_Request__c();
            optRequest.FSL__Status__c = 'Failed';
            optRequest.FSL__Failure_Reason__c = 'Already Running';
            optRequest.FSL__Failure_Details__c = 'Details';
            insert optRequest;
        test.stopTest();

        system.assert([SELECT count() FROM Integration_Result__c] > 0, 'The Splunk Record was not created');
    }

    @isTest
    static void updateFailedRequest(){
        test.startTest();
            FSL__Optimization_Request__c optRequest = new FSL__Optimization_Request__c();
            optRequest.FSL__Status__c = 'In Progress';
            insert optRequest;

            optRequest.FSL__Status__c = 'Failed';
            optRequest.FSL__Failure_Reason__c = 'Already Running';
            optRequest.FSL__Failure_Details__c = 'Details';
            update optRequest;
        test.stopTest();

        system.assert([SELECT count() FROM Integration_Result__c] > 0, 'The Splunk Record was not created');
    }
}