@istest
public class GenerateCRPSImageLinkTest {

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
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        Condition_Report_Prescreen__c crp = new Condition_Report_Prescreen__c();
        insert crp;
    }

    @istest
    static void testAttachmentOnNonCRPreScreenRecord(){
        Account acct = [select id from account limit 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        
        Test.startTest();
            insert cdl;
        Test.stopTest();
        set<id> distroIdSet = new set<id>();
        for(ContentVersion cv :[SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id AND IsLatest = true]){
            distroIdSet.add(cv.id);
        }
        system.assert([Select Id, ContentDownloadUrl from ContentDistribution where ContentVersionId in :distroIdSet].size() == 0, 'A document was found when it shouldnt be');
    }

    @istest
    static void testAttachmentOnCRPreScreenRecord(){
        Condition_Report_Prescreen__c crp = [select id from Condition_Report_Prescreen__c limit 1];

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
        set<id> distroIdSet = new set<id>();
        for(ContentVersion cv :[SELECT Id,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id AND IsLatest = true]){
            distroIdSet.add(cv.id);
        }
        system.assert([Select Id, ContentDownloadUrl from ContentDistribution where ContentVersionId in :distroIdSet].size() == 1, 'A document was not found when it should be');
    }
}