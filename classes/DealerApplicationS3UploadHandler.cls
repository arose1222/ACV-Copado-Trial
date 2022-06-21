public with sharing class DealerApplicationS3UploadHandler {
    @TestVisible
    private static List<AWS_Credential__mdt> mockMetadata;
    //This method is used to post file to AWS
    public static Integer uploadFileToAWS(String strFileName, String fileType, String bucket, String folderName, Blob fileContent) {
        DealerApplicationS3Service s3 = new DealerApplicationS3Service(bucket);
        return s3.createFile(folderName, strFileName, fileType, fileContent);
    }

    @future(callout=true)
    public static void getFile(Id documentId, String strFileName, String folderName){
        List<ContentVersion> docList = [SELECT Id, Title, FileType, VersionData FROM ContentVersion WHERE ContentDocumentId = :documentId];
        String fileType = '';
        Blob fileContent;
        if (!docList.isEmpty()) {
            fileType = getMIMETypes(docList[0].FileType);
            fileContent = docList[0].VersionData;
        }
        
        String bucket = '';
        String bucketKeySearch='acv-dealer-applications';
        Boolean isTest= false;
        if(!ACVUtility.isProd())
        {
            bucketKeySearch= 'acv-dealer-applications-latest';
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

    }

    @AuraEnabled
    public static String getMIMETypes(String fileType){
        if (fileType == 'PDF' || fileType == 'ZIP' ) {
            return 'application/'+fileType;
        } else {
            return 'image/'+fileType;
        }
    }

    @AuraEnabled
    public static void getSplunkLog(Id documentId, String logLevel) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SALES};
        log.sfObject = 'Application__c';
        log.version = 'v1';
        log.componentName = 'DealerApplicationS3Upload';
        log.location = 'DealerApplicationS3UploadHandler: ' + ACVUtility.currentLineNumber();
        log.message = logLevel == 'INFO' ? 'Dealer Application file uploaded to S3 successfully.' : 'Error in uploading Dealer Application file to S3, please investigate.';
		log.stackTrace = 'DealerApplicationS3UploadHandler: ' + ACVUtility.currentLineNumber();
        log.logLevel = logLevel == 'INFO' ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR;
        log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log.sfRecordId = documentId;
        SplunkHelper.processLog(log);
    }
}