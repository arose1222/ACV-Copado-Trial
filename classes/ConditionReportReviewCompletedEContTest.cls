@isTest
public class ConditionReportReviewCompletedEContTest {
    
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
        Condition_Report_Prescreen__c crp = new Condition_Report_Prescreen__c();
        insert crp;
   
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = crp.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        insert cdl;
    }

    @isTest
    static void testConditionReportReviewCompletedECont(){
        Condition_Report_Prescreen__c crp = [select id from Condition_Report_Prescreen__c limit 1];
        ConditionReportReviewCompletedECont crr = new ConditionReportReviewCompletedECont();
        crr.parentId = crp.id;
        crr.runContentDocLogic();
        system.assert(crr.getRelatedData().size() == 1, 'Too many or not enough Images were found');
    }
}