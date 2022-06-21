public class DealerApplicationAttachmentHandler extends TriggerInterface {
    
    public override void afterInsert(List<sObject> inputList){
        List<ContentVersion> cvList = (List<ContentVersion>)inputList;
        for (ContentVersion cv : cvList) {
            Id objectId = cv.FirstPublishLocationId;
            if (objectId != null && objectId.getSobjectType().getDescribe().getName() == 'Application__c') {
                if (cv.ContentSize > 2900000) {
                    cv.addError('File cannot larger than 2.9MB!');
                }
                List<String> titleSegments = cv.Title.split('/'); // document_type/document_name
                String folderName = objectId + '/' + titleSegments[0];
                DealerApplicationS3UploadHandler.getFile(cv.ContentDocumentId, titleSegments[1], folderName);
            }
        }
    }
}