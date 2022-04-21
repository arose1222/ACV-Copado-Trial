@isTest
public class S3ReferenceTriggerTest {

    @isTest
    static void generateGuidOnInsert(){
    	S3_Reference__c ref = new S3_reference__c(name = 'No Guid');
        insert ref;
        List<S3_reference__c> refLIst = [SELECT id, name, External_Record_Guid__c FROM S3_reference__c WHERE name = 'No Guid'];
        System.assert(refList[0].External_Record_Guid__c != null, 'a guid was not generated for the s3_reference__c');
    }

    @isTest
    static void maintainGuidOnInsert(){
        String guid = ACVUtility.newGuid();
    	S3_Reference__c ref = new S3_reference__c(name = 'No Guid', External_Record_Guid__c = guid);
        insert ref;
       	List<S3_reference__c> refList = [SELECT id, name, External_Record_Guid__c FROM S3_reference__c WHERE External_Record_Guid__c = :guid];
        System.assert(refList.size() > 0, 'Could not find s3_reference_c with correct guid');
    }
}