@isTest
private class DealerDocsS3UploadHandlerTest {
	private static string mockAWSCreds = '[{"DeveloperName":"testMetadata","NamespacePrefix":"","Access_Key__c":"123456789","Secret_Key__c":"asdfghjknbvcxcvbn","Bucket_Name__c":"dealer-docs-uat"}]';
	
	@TestSetup
	static void makeData(){
		DealerDocsS3UploadHandler.mockMetadata = (List<AWS_Credential__mdt>)JSON.deserializeStrict(mockAWSCreds, List<AWS_Credential__mdt>.class);
		String baseStr = 'THIS IS A TEST STRING';
		Blob encodedBlob = EncodingUtil.base64Decode(baseStr);
		ContentVersion cv = new ContentVersion(VersionData = encodedBlob, PathOnClient = 'someFile.png', Title = 'someFile', IsMajorVersion = true); //FileType = 'PNG', 
		insert cv;
	}

    @isTest
	static void testCreateFile() {
		Test.setMock(HttpCalloutMock.class, getCreateFileRequestMock());

		ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

		Test.startTest();
        try {
			DealerDocsS3UploadHandler.getFile(cv.ContentDocumentId, 'someFile.png', 'someDealerId/someRecordType');
		}
		catch(Exception e) {
            System.debug(e);
		}
		Test.stopTest();
    }

    static TestingUtility.SingleRequestMock getCreateFileRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}
}