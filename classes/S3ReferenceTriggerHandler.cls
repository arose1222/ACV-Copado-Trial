public class S3ReferenceTriggerHandler extends TriggerInterface{
    public override void beforeInsert(List<SObject> newList){
        List<S3_reference__c> refList = (List<S3_reference__c>)newList;
        generateGUID(refList);
    }
    
    public static void generateGUID(List<S3_Reference__c> s3RefList){
        for(S3_Reference__c ref : s3RefList){
            if(String.isBlank(ref.External_Record_Guid__c)){
                ref.External_Record_Guid__c = ACVUtility.newGuid();
            }
        }
    }
}