@IsTest
public with sharing class FileMigrationBatch_Test {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    @TestSetup
    static void makeData(){
        Account acc = TestUtility.createAccount('AccountForFileMigration');
        acc.Active__c = TRUE;
        insert acc;
        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = acc.Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );
        dealerDoc.Review_Status__c = 'Complete';
        dealerDoc.Compliant__c = TRUE;
        dealerDoc.File_Attached__c = TRUE;
        insert dealerDoc;
        ContentVersion cv = new ContentVersion(VersionData = Blob.toPdf('Test Content'), PathOnClient = 'someFile.png', Title = 'someFile', IsMajorVersion = true); 
		insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cv.ContentDocumentId,LinkedEntityId=dealerDoc.Id,shareType = 'V');
        insert cdl;
    }

    @IsTest static void fileMigrationTest(){
        //Create mock response
		Map<String, String> responseHeaders = new Map<String, String>();
		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);
        Test.setMock(HttpCalloutMock.class,mock);
        Test.startTest();
        FileMigrationBatch batch = new FileMigrationBatch();
        Database.executeBatch(batch, 1);
        Test.stopTest();
        Dealer_Docs__c dealerDoc = [SELECT Id,S3_Link__c FROM Dealer_Docs__c LIMIT 1];
        System.assert(dealerDoc.S3_Link__c != NULL, 'S3 Link not updated');
    }

    @IsTest static void fileMigrationTestwithNoFiles(){
        Dealer_Docs__c dealerDoc = new Dealer_Docs__c();
        dealerDoc.Account__c = [SELECT Id FROM Account LIMIT 1].Id;
        dealerDoc.RecordTypeId = licenseId;
        dealerDoc.Document_State__c = 'AL';
        dealerDoc.License_Number__c = '1';
        dealerDoc.Expiration_Date__c = Date.today().addDays( 30 );
        dealerDoc.Review_Status__c = 'Complete';
        dealerDoc.Compliant__c = TRUE;
        dealerDoc.File_Attached__c = TRUE;
        insert dealerDoc;
        //Create mock response
		Map<String, String> responseHeaders = new Map<String, String>();
		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);
        Test.setMock(HttpCalloutMock.class,mock);
        Test.startTest();
        String query = 'SELECT Id,Account__r.Dealership_ID__c,RecordType.Name,S3_Link__c FROM Dealer_Docs__c WHERE Id = \''+dealerDoc.Id+'\'';
        FileMigrationBatch batch = new FileMigrationBatch(query);
        Database.executeBatch(batch, 1);
        Test.stopTest();
        dealerDoc = [SELECT Id,S3_Link__c FROM Dealer_Docs__c WHERE Id=:dealerDoc.Id];
        System.assert(dealerDoc.S3_Link__c == NULL, 'S3 Link not null');
    }
}