@isTest
public class DealerDocAttachmentAddedTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
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
    }

    @istest
    static void testMultipleAttachmentDeleteOnDealerDocs(){
        Dealer_Docs__c crp = [select id from Dealer_Docs__c limit 1];

        ContentVersion contentVersion1 = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion1; 

        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = crp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdlList.add(cdl);
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = crp.id;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        cdlList.add(cdl1);
        
        Test.startTest();
            insert cdlList;
            update cdlList;
            delete cdlList[0];
        Test.stopTest();
        crp = [select id, file_attached__c from Dealer_Docs__c where id = :crp.id limit 1];
        system.assertEquals(TRUE, crp.file_attached__c, 'File Attached is False When it should be True');
    }

    @istest
    static void testAttachmentInsertOnDealerDocs(){
        Dealer_Docs__c crp = [select id from Dealer_Docs__c limit 1];

        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = crp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        
        Test.startTest();
            insert cdl;
        Test.stopTest();
        crp = [select id, file_attached__c from Dealer_Docs__c where id = :crp.id limit 1];
        system.assertEquals(TRUE, crp.file_attached__c, 'File Attached is False When it should be True');
    }

    @istest
    static void testAttachmentUpdateOnDealerDocs(){
        Dealer_Docs__c crp = [select id from Dealer_Docs__c limit 1];

        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = crp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        
        Test.startTest();
            insert cdl;
            update cdl;
        Test.stopTest();
        crp = [select id, file_attached__c from Dealer_Docs__c where id = :crp.id limit 1];
        system.assertEquals(TRUE, crp.file_attached__c, 'File Attached is False When it should be True');
    }

    @istest
    static void testMultipleAttachmentUpdateOnDealerDocs(){
        Dealer_Docs__c crp = [select id from Dealer_Docs__c limit 1];

        ContentVersion contentVersion1 = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion1; 

        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = crp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdlList.add(cdl);
        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = crp.id;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        cdlList.add(cdl1);
        
        Test.startTest();
            insert cdlList;
            update cdlList;
        Test.stopTest();
        crp = [select id, file_attached__c from Dealer_Docs__c where id = :crp.id limit 1];
        system.assertEquals(TRUE, crp.file_attached__c, 'File Attached is False When it should be True');
    }

    @istest
    static void testAttachmentDeleteOnDealerDocs(){
        Dealer_Docs__c crp = [select id from Dealer_Docs__c limit 1];

        ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = crp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        
        Test.startTest();
            insert cdl;
            delete cdl;
        Test.stopTest();
        crp = [select id, file_attached__c from Dealer_Docs__c where id = :crp.id limit 1];
        system.assertEquals(FALSE, crp.file_attached__c, 'File Attached is True When it should be False');
    }
}