/**
 * @description A controller used by LWC to fetch S3 Title Image History from the Field History object.
 * 
 * @author Manmeet Vaseer
 * @date 05/27/2021
 * 
 * @history
 * 12/07/2021   Manmeet Vaseer  Enabled LWC on QC object.
 * 
 * 
 */
public class CaseTitleS3ImageController {
    /*
     * @description This will only return Image_Location__c field records from the Field History object.
     * 
     * @param recordId Case record id for which the records will be pulled from the Field History object.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getS3ImageLocationHistory(String recordId, Boolean isQualityControl) {
        String IMG_LOC_FIELD_NAME = 'Image_Location__c';
        String STATUS_FIELD_NAME = 'Status';
        
        List<String> payloads = new List<String>();        
        String statusNewVal = null;
        Payload pl = null;

		// Do not load Titles history if caller is Quality Control object.        
        if(isQualityControl) return payloads;

        List<Field_History__c> fhList = [SELECT Id, Field__c, Old_Value__c, New_Value__c,  LastModifiedDate FROM Field_History__c WHERE Case__c = :recordId ORDER BY LastModifiedDate DESC];
        
        for (Field_History__c fh : fhList) {
            if(fh.Field__c == STATUS_FIELD_NAME)	{
                statusNewVal = fh.New_Value__c;
            }
            else if(fh.Field__c == IMG_LOC_FIELD_NAME)	{
                pl = new Payload();
                pl.lastModifiedDate = String.valueOfGMT(fh.LastModifiedDate);
                pl.s3URL = fh.New_Value__c;
                
                if(statusNewVal != null)	{
                    pl.description = 'On ' + statusNewVal + ' status';
                    statusNewVal = null;                    
                }
                /*
				 * This should never happen, unless we rename the IMG_LOC_FIELD_NAME or STATUS_FIELD_NAME fields and change their alphabetical order, and
				 * both fields have same LastModifiedDate i.e both fields are updated in the same transaction.
				 */
                else {
                    pl.description = 'Unknown Status';
                }
                payloads.add(JSON.serialize(pl));
            }
        }
        
        return payloads;
    }
    
    public class Payload {
        public String lastModifiedDate;
        public String s3URL;
        public String description;
    }
}