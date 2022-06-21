@isTest
public class DealerApplicationAttachmentHandlerTest {
    static testMethod void checkApplicationAttachmentAfterInsert(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, getCreateFileSuccessRequestMock());
        Account testAccount = new Account();
        testAccount.Name='Test Account' ;
        insert testAccount;
        User testUser = [SELECT Id, Email FROM User LIMIT 1];
        Application__c app = new Application__c();
		app.Account__c  = testAccount.Id;
        app.Status__c  = 'Submitted';
        app.OwnerId = testUser.Id;
        insert app;
        ContentVersion cv = new Contentversion(
 			Title = 'ABC',
            PathOnClient = 'ABC.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        //cv.FirstPublishLocationId = 'a5u8G0000004ElqQAE';
        insert cv;
        
        //create ContentDocumentLink record
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId=app.id;
        cdl.ShareType= 'I';
        cdl.ContentDocumentId=[select contentdocumentid from contentversion where id =: cv.id].contentdocumentid;
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
		List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id = :cv.ContentDocumentId];
        system.assertEquals(1, cdList.size());
        test.stopTest();
    }
    
    @isTest
    static TestingUtility.SingleRequestMock getCreateFileSuccessRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}
}