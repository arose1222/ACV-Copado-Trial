@isTest
private class S3Test {
	public static final String ACCOUNT_NAME = 'S3InsertTest';
	public static final String region = 'us-east-1';
	public static final String bucketName = 'dealer-docs-uat';
	public static final String folderName = 'test';
    private static string mockAWSCreds = '[{"DeveloperName":"testMetadata","NamespacePrefix":"","Access_Key__c":"qwertyuiop","Secret_Key__c":"qwertyuiopasdfghjkl","Bucket_Name__c":"dealer-docs-uat"}]';

	    @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
		S3.mockMetadata = (List<AWS_Credential__mdt>)JSON.deserializeStrict(mockAWSCreds, List<AWS_Credential__mdt>.class);
		insert TestUtility.createAccount(ACCOUNT_NAME);
	}

	static testMethod void testGetFile() {
		Test.setMock(HttpCalloutMock.class, getCreateFileRequestMock());

		S3 s3 = new S3(bucketName);
        s3.generatePreSignedFileUrl('https://somepath.com/path/file');
        try{
            s3.getFileList('/somepath/file');
        } catch(Exception e) {
        }
	}

	static TestingUtility.SingleRequestMock getFileListRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>{
			'Content-Type' => 'application/x-www-form-urlencoded'
		};

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '{"content": "Hello, world"}', responseHeaders
		);

		return mock;
	}

	static TestingUtility.SingleRequestMock getFileUrlRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>{
			'Content-Type' => 'application/x-www-form-urlencoded'
		};

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '{"content": "Hello, world"}', responseHeaders
		);

		return mock;
	}

	static TestingUtility.SingleRequestMock getCreateFileRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}

	@IsTest
	static void s3InsertionPositive(){

		TestingUtility.SingleRequestMock splunkRes = new TestingUtility.SingleRequestMock(200,'OK','{ success }',null);
		Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
		multiCall.put('callout:Splunk/services/collector/event',splunkRes);
        Test.setMock(HttpCalloutMock.class, splunkRes);

		Test.startTest();
		Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME ];
		String picklistValue;
		for(String value : ACVUtility.getPicklistValues('S3_Reference__c', 'Type__c', true).values()){
			picklistValue = value;
		}
		String testReturn = S3.insertS3Objects('TEST', picklistValue, 'https://www.example.com', 'Account__c', testAccount.id);
		S3.S3LWCReturnObject returnObject = (S3.S3LWCReturnObject)JSON.deserialize(testReturn, S3.S3LWCReturnObject.class);
		Test.stopTest();
		
		System.assert(returnObject.statusCode == 200);
		System.assert([SELECT Id FROM S3_Association__c].size() == 1);
		System.assert([SELECT Id FROM S3_Reference__c].size() == 1);
		
	}

	@IsTest
	static void s3InsertionNegative(){


		TestingUtility.SingleRequestMock splunkRes = new TestingUtility.SingleRequestMock(200,'OK','{ success }',null);
		Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
		multiCall.put('callout:Splunk/services/collector/event',splunkRes);
		Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));

		Test.startTest();

		String picklistValue;
		for(String value : ACVUtility.getPicklistValues('S3_Reference__c', 'Type__c', true).values()){
			picklistValue = value;
		}
		String testReturn = S3.insertS3Objects('TEST', picklistValue, 'https://www.example.com', 'Account__c', 'Bad Id');
		S3.S3LWCReturnObject returnObject = (S3.S3LWCReturnObject)JSON.deserialize(testReturn, S3.S3LWCReturnObject.class);
		
		Test.stopTest();

		System.assert(returnObject.statusCode == 500);
		System.assert([SELECT Id FROM S3_Association__c].size() == 0);
		System.assert([SELECT Id FROM S3_Reference__c].size() == 0);
	}
}