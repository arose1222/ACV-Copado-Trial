/*
*
* Adding a comment header for Copado deployment testing
*
*/

public with sharing class DealerDocsS3UploadHandler {
    @TestVisible
    private static List<AWS_Credential__mdt> mockMetadata;
    //This method is used to post file to AWS
    public static Integer uploadFileToAWS(String strFileName, String fileType, String bucket, String folderName, Blob fileContent) {
        S3 s3 = new S3(bucket);
        return s3.createFile(folderName, strFileName, fileType, fileContent);
    }

    @AuraEnabled
    public static Integer getFile(Id documentId, String strFileName, String folderName){
        List<ContentVersion> docList = [SELECT Id, Title, FileType, VersionData FROM ContentVersion WHERE ContentDocumentId = :documentId];
        String fileType = '';
        Blob fileContent;
        if (!docList.isEmpty()) {
            fileType = 'image/' + docList[0].FileType;
            fileContent = docList[0].VersionData;
        }
        
        String bucket = '';
        String bucketKeySearch='dealer-docs';
        Boolean isTest= false;
        if(!ACVUtility.isProd())
        {
            bucketKeySearch= 'dealer-docs-uat';
            isTest = true;
        }

        List<AWS_Credential__mdt> awsCreds = new List<AWS_Credential__mdt>();
        if (Test.isRunningTest() && mockMetadata != null) {
            awsCreds = mockMetadata;
        }
        else {
            awsCreds = [SELECT Bucket_Name__c FROM AWS_Credential__mdt WHERE Bucket_Name__c LIKE : bucketKeySearch+ '%' AND Is_Testing_Bucket_Access__c = :isTest];
        }
        if (!awsCreds.isEmpty()) {
            bucket = awsCreds[0].Bucket_Name__c;
        }

        Integer statusCode = uploadFileToAWS(strFileName, fileType, bucket, folderName, fileContent);
        //don't want to return the status yet, because i need to delete the file first
        if (statusCode == 200) {
            //delete file
            ContentDocument cd = new ContentDocument(Id = documentId);
            delete cd;
            //send out an INFO splunk log
            String logLevel = 'INFO';
            getSplunkLog(documentId, logLevel); //should work
        }
        else {
            //do NOT delete file, and send out an ERROR alert to slack (talk to alex about how to set up the slack alert once in splunk)
            String logLevel = 'ERROR';
            getSplunkLog(documentId, logLevel);
        }
        return statusCode;
    }

    @AuraEnabled
    public static void getSplunkLog(Id documentId, String logLevel) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'Dealer Docs S3 Upload';
        log.sfObject = 'Account -> Content Document';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
        log.logLevel = logLevel == 'INFO' ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR;
        log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log.sfRecordId = documentId;
        log.stackTrace = 'DealerDocsS3UploadHandler: ' + ACVUtility.currentLineNumber();
        log.location = 'DealerDocsS3UploadHandler: ' + ACVUtility.currentLineNumber();
        log.message = logLevel == 'INFO' ? 'Dealer Doc uploaded to S3 successfully.' : 'Error in uploading Dealer Doc to S3, please investigate.';
        SplunkHelper.buildAndProcessLog(log);
    }
}