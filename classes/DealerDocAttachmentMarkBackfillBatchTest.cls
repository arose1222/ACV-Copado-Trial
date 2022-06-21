@isTest
public class DealerDocAttachmentMarkBackfillBatchTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        String disableTrigger = '[{"DeveloperName": "TestHandler", "NamespacePrefix": "","After_Delete__c": "true","sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"}]';
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(disableTrigger, List<TriggerHandler__mdt>.class);
        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        Profile p = [SELECT Id FROM Profile WHERE Name='Vehicle Condition Inspector'];
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u1;
        Account a = new Account(); 
        a.Name = 'Smith Dealerships';
        a.IST_Account_Owner__c = u1.Id;
        a.legal_name__c = 'Smotj Dealerships';
        a.dealer_type__c = '1';
        insert a;
        Dealer_Docs__c resaleDoc = new Dealer_Docs__c();
        resaleDoc.Account__c = a.Id;
        resaleDoc.RecordTypeId = resaleId;
        resaleDoc.Document_State__c = 'AL';
        resaleDoc.No_Expiration__c = TRUE;
        resaleDoc.Permit_Resale_Number__c = '1';
        resaleDoc.Review_Status__c = 'Complete';
        resaleDoc.Compliant__c = TRUE;
        insert resaleDoc;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = resaleDoc.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    }

    @istest
    static void testRunningTheBatch(){
        Test.startTest();
            SchedulableContext sc = null;
            DealerDocAttachmentMarkBackfillBatch batch = new DealerDocAttachmentMarkBackfillBatch();
            Batch.execute(sc);
        Test.stopTest();

        Dealer_Docs__c doc = [select id, file_attached__c from Dealer_Docs__c limit 1];
        system.assertEquals(TRUE, doc.file_attached__c, 'File Attached is false when it should be true');
    }
}