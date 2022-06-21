@isTest
public class DealerApplicationS3ServiceTest {
	public static final String ACCOUNT_NAME = 'S3InsertTest';
	public static final String region = 'us-east-1';
	public static final String bucketName = 'acv-dealer-applications-latest';
	public static final String folderName = 'test';
    private static string mockAWSCreds = '[{"DeveloperName":"testMetadata","NamespacePrefix":"","Access_Key__c":"qwertyuiop","Secret_Key__c":"qwertyuiopasdfghjkl","Bucket_Name__c":"dealer-docs-uat"}]';

	@TestSetup
	static void makeData(){
		DealerApplicationS3Service.mockMetadata = (List<AWS_Credential__mdt>)JSON.deserializeStrict(mockAWSCreds, List<AWS_Credential__mdt>.class);
		insert TestUtility.createAccount(ACCOUNT_NAME);
	}

	static testMethod void testGetFile() {
		Test.setMock(HttpCalloutMock.class, getCreateFileRequestMock());

		DealerApplicationS3Service s3 = new DealerApplicationS3Service(bucketName);
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
		String testReturn = DealerApplicationS3Service.insertS3Objects('TEST', picklistValue, 'https://www.example.com', 'Account__c', testAccount.id);
		DealerApplicationS3Service.S3LWCReturnObject returnObject = (DealerApplicationS3Service.S3LWCReturnObject)JSON.deserialize(testReturn, DealerApplicationS3Service.S3LWCReturnObject.class);
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
		String testReturn = DealerApplicationS3Service.insertS3Objects('TEST', picklistValue, 'https://www.example.com', 'Account__c', 'Bad Id');
		DealerApplicationS3Service.S3LWCReturnObject returnObject = (DealerApplicationS3Service.S3LWCReturnObject)JSON.deserialize(testReturn, DealerApplicationS3Service.S3LWCReturnObject.class);
		
		Test.stopTest();

		System.assert(returnObject.statusCode == 500);
		System.assert([SELECT Id FROM S3_Association__c].size() == 0);
		System.assert([SELECT Id FROM S3_Reference__c].size() == 0);
	}

    @IsTest
	static void s3InsertionFieldValidationException(){

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
        
        String testReturn = DealerApplicationS3Service.insertS3Objects('TEST', picklistValue, 'https://www.example.com', 'Account__c', '');
        DealerApplicationS3Service.S3LWCReturnObject returnObject = (DealerApplicationS3Service.S3LWCReturnObject)JSON.deserialize(testReturn, DealerApplicationS3Service.S3LWCReturnObject.class);	
        System.assert(returnObject.statusCode == 400);
		
		Test.stopTest();
		
	}
    
    @IsTest
	static void testDeleteFile(){
		Test.setMock(HttpCalloutMock.class, deleteFileRequestMock());
		Test.startTest();
        DealerApplicationS3Service s3 = new DealerApplicationS3Service('acv-dealer-applications-latest');
		Integer status = s3.deleteFile('fileName', 'https://test.com');
		Test.stopTest();
        System.assert(status==200, 'status should be 200');
		
	}
    
    static TestingUtility.SingleRequestMock deleteFileRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>{
			'Content-Type' => 'application/x-www-form-urlencoded'
		};

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}
    
    @IsTest
	static void testSaveFile(){
		Test.setMock(HttpCalloutMock.class, getCreateFileSuccessRequestMock());
		Test.startTest();
        DealerApplicationS3Service s3 = new DealerApplicationS3Service('acv-dealer-applications-latest');
		Integer status = s3.createFile('folderName', 'fileName', 'JPG', Blob.valueOf('Unit Test Attachment Body'));
		Test.stopTest();
        System.assert(status==200, 'status should be 200');
		
	}
    
    static TestingUtility.SingleRequestMock getCreateFileSuccessRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}
}