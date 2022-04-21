/**
 * @description Migrate Legacy Dealer doc files to S3 bucket
 * @author Sreedhar
 * @since 02/14/2022
 */
public with sharing class FileMigrationBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    //query provides scope of the records to the batch class
    String query;
    //Used to collect errors and notify users about the failed records
    List<String> errorList;
    //MIME types be used when uploading files to S3
    Map<String,String> mimeTypesMap;
    //There are multiple files attached to Dealer docs records, This contains whether to upload dealer docs with multiple files or not
    public Boolean ignoreMultipleFiles;
    //List of people to whom errors need to be notified
    List<String> peopleToNotifyErrors;
    //File types that are allowed to upload as of now
    List<String> validFileTypes;
    String s3Bucket;
    Map<String,Salesforce_Setting__mdt> sfSettingsMap;

    {
        sfSettingsMap = ACVUtility.getSalesforceSettings(new Set<String>{'S3_Subpath_for_Dealer_Docs','DealerDocsMigrationValidFileTypes'});
        s3Bucket = getS3Bucket();
        ignoreMultipleFiles = TRUE;
        errorList = new List<String>();
        peopleToNotifyErrors = new List<String>{'v-sdaruvappagari@acvauctions.com'};
        mimeTypesMap = new Map<String,String>{
            'bmp' => 'image/bmp',
            'csv' => 'text/csv',
            'doc' => 'application/msword',
            'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'gif' => 'image/gif',
            'html' => 'text/html',
            'jpeg' => 'image/jpeg',
            'jpg' => 'image/jpeg',
            'png' => 'image/png',
            'pdf' => 'application/pdf',
            'svg' => 'image/svg+xml',
            'tif' => 'image/tiff',
            'tiff' => 'image/tiff',
            'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'zip' => 'application/zip'
        };
        validFileTypes = sfSettingsMap.get('DealerDocsMigrationValidFileTypes').Value__c.split(',');
    }

    public FileMigrationBatch(String query){
        this.query = query;
    }

    public FileMigrationBatch(){
        this.query = 'SELECT Id,Account__r.Dealership_ID__c,RecordType.Name,S3_Link__c FROM Dealer_Docs__c WHERE File_Attached__c = TRUE';
        this.query += ' AND S3_Link__c = NULL AND Compliant__c = TRUE AND Account__r.Active__c = TRUE AND Account__r.Dealer_Type__c != \'Commercial\' ORDER BY Id';
    }

    /**
     * @param context 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext context){
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Dealer_Docs__c> dealerDocs){
        System.debug('Current heap size(Bytes): '+Limits.getHeapSize());
        List<ContentDocumentLink> contDocLinks = getContentDocumentLinks(dealerDocs[0].Id);
        if(contDocLinks.isEmpty()){
            updateDealerDoc(dealerDocs[0].Id, null, 'No Files');
            return;
        }
        if(ignoreMultipleFiles && contDocLinks.size()>1){
            updateDealerDoc(dealerDocs[0].Id, null, 'Multiple Files');
            return;
        }
        if(contDocLinks[0].ContentDocument.FileExtension == null || !validFileTypes.contains(contDocLinks[0].ContentDocument.FileExtension)){
            updateDealerDoc(dealerDocs[0].Id, null, 'Invalid File Type');
            return;
        }
        ContentVersion contVersion = getContentVersion(contDocLinks[0].ContentDocumentId);
        //Prepare path of the file in S3 bucket
        String folder = '';
        if(sfSettingsMap.containsKey('S3_Subpath_for_Dealer_Docs') && !String.isBlank(sfSettingsMap.get('S3_Subpath_for_Dealer_Docs').Value__c)){
            folder = sfSettingsMap.get('S3_Subpath_for_Dealer_Docs').Value__c + '/' ;
        }
        folder += dealerDocs[0].Account__r.Dealership_ID__c + '/' + dealerDocs[0].RecordType.Name;
        S3 s3 = new S3(s3Bucket);
        String fileTye = '';
        if(contVersion.FileExtension == null | !mimeTypesMap.containsKey(contVersion.FileExtension)){
            fileTye = 'application/octet-stream';
        }
        else{
            fileTye = mimeTypesMap.get(contVersion.FileExtension);
        }
        Integer statusCode;
        if(contVersion.ContentSize < 10000000){
            statusCode =  s3.createFile(folder, contVersion.PathOnClient, fileTye, contVersion.VersionData);
        }
        if(statusCode==200){
            updateDealerDoc(dealerDocs[0].Id, getS3Link(s3Bucket, folder, contVersion.PathOnClient), 'Migrated');
        }else if(statusCode==null){
            updateDealerDoc(dealerDocs[0].Id, null, 'Bigger File');
        }else{
            updateDealerDoc(dealerDocs[0].Id, null, 'Upload Failed');
        }
    }

    public void finish(Database.BatchableContext context) {
        if(errorList.isEmpty()){
            return;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(peopleToNotifyErrors);
        mail.setSubject('FileMigrationBatch error list '+System.now());
        String body = 'Id|S3 Link|Migration Status|Error<br/>';
        mail.setHtmlBody(body + String.join(errorList, '<br/>'));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private List<ContentDocumentLink> getContentDocumentLinks(Id dealerDocId){
        List<ContentDocumentLink> cdl = [SELECT Id,ContentDocumentId,LinkedEntityId,ContentDocument.Title,ContentDocument.FileExtension FROM ContentDocumentLink WHERE LinkedEntityId = :dealerDocId ORDER BY Id DESC];
        return cdl;
    }

    private ContentVersion getContentVersion(Id documentId){
       return [SELECT Id, Title, FileType, FileExtension,PathOnClient, VersionData, ContentSize FROM ContentVersion WHERE ContentDocumentId = :documentId AND IsLatest = TRUE];
    }

    private String getS3Bucket(){
        return ACVUtility.isProd() ? 'dealer-docs' : 'dealer-docs-uat';
    }

    private String getS3Link(String s3Bucket, String folder, String fileName){
        String host = 'https://' + s3Bucket +'.s3.amazonaws.com';
        String s3Link = host + '/' + folder + '/' + fileName;
        s3Link = s3Link.replace(' ', '+');
        return s3Link;
    }

    private void updateDealerDoc(String dealerDocId, String s3Link, String migrationStatus){
        try{
            update new Dealer_Docs__c(Id = dealerDocId, S3_Link__c = s3Link, S3_Migration_Status__c = migrationStatus);
        }
        catch(Exception ex){
            String errorMessage = dealerDocId + '|' + s3Link + '|' + migrationStatus;
            errorMessage += '|' + ex.getMessage() + ' at line ' + ex.getLineNumber() + ' ' + ex.getStackTraceString();
            errorList.add(errorMessage);
        }
    }
}