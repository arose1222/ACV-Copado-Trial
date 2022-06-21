@isTest
private class DealerApplicationS3UploadHandlerTest {
	private static string mockAWSCreds = '[{"DeveloperName":"testMetadata","NamespacePrefix":"","Access_Key__c":"123456789","Secret_Key__c":"asdfghjknbvcxcvbn","Bucket_Name__c":"dealer-docs-uat"}]';
	
	@TestSetup
	static void makeData(){
		DealerApplicationS3UploadHandler.mockMetadata = (List<AWS_Credential__mdt>)JSON.deserializeStrict(mockAWSCreds, List<AWS_Credential__mdt>.class);
		String baseStr = 'THIS IS A TEST STRING';
		Blob encodedBlob = EncodingUtil.base64Decode(baseStr);
		ContentVersion cv = new ContentVersion(VersionData = encodedBlob, PathOnClient = 'someFile.png', Title = 'someFile', IsMajorVersion = true); //FileType = 'PNG',
        insert cv;
        ContentVersion zipFile = new ContentVersion(VersionData = encodedBlob, PathOnClient = 'someZipFile.zip', Title = 'someZipFile', IsMajorVersion = true); //FileType = 'ZIP',
		insert zipFile;
	}

    @isTest
	static void testCreateFileSucceed() {
		Test.setMock(HttpCalloutMock.class, getCreateFileSuccessRequestMock());

		ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='someZipFile' LIMIT 1];
		
		Test.startTest();
        try {
			DealerApplicationS3UploadHandler.getFile(cv.ContentDocumentId, 'someZipFile.zip', 'someDealerId/someRecordType');
		}
		catch(Exception e) {
            System.debug(e);
		}
		Test.stopTest();
    }

    @isTest
	static void testCreateFileFailed() {
		Test.setMock(HttpCalloutMock.class, getCreateFileFailRequestMock());

		ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title='someFile' LIMIT 1];

		Test.startTest();
        try {
			DealerApplicationS3UploadHandler.getFile(cv.ContentDocumentId, 'someFile.png', 'someDealerId/someRecordType');
		}
		catch(Exception e) {
            System.debug(e);
		}
		Test.stopTest();
    }

	@isTest
    static TestingUtility.SingleRequestMock getCreateFileSuccessRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}

	static TestingUtility.SingleRequestMock getCreateFileFailRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			400, 'Failed', '', responseHeaders
		);

		return mock;
	}
}