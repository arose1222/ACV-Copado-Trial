public with sharing class DealerApplicationDocViewerController {
    @AuraEnabled
    public static String getDealerApplicationDoc(String recordId, String documentType){
        String bucket = 'acv-dealer-applications';
        if(!ACVUtility.isProd())
        {
            bucket = 'acv-dealer-applications-latest';
        }
        DealerApplicationS3Service s3 = new DealerApplicationS3Service(bucket);
        String bucketUrl = recordId + '/' + documentType;
        Map<String, String> documentMap = s3.getFileList(bucketUrl);
		return JSON.serialize(documentMap);
    }
    
    @AuraEnabled
    public static Integer deleteDealerApplicationDoc(String fileName, String url){
        String bucket = 'acv-dealer-applications';
        if(!ACVUtility.isProd())
        {
            bucket = 'acv-dealer-applications-latest';
        }
        DealerApplicationS3Service s3 = new DealerApplicationS3Service(bucket);

        Integer statusCode = s3.deleteFile(fileName, url);
		return statusCode;
    }
    
    @AuraEnabled
    public static Integer saveFile(String fileName, String base64Data, String contentType, String recordId, String documentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Blob fileContent = EncodingUtil.base64Decode(base64Data);
        String folderName = recordId + '/' + documentType;
        String bucket = 'acv-dealer-applications';
        if(!ACVUtility.isProd())
        {
            bucket = 'acv-dealer-applications-latest';
        }
        
        Integer statusCode = DealerApplicationS3UploadHandler.uploadFileToAWS(fileName, contentType, bucket, folderName, fileContent);
        
        return statusCode;
    }
}