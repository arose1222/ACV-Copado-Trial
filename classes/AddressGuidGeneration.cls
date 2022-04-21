public class AddressGuidGeneration extends TriggerInterface {

    public override void beforeInsert(List<sObject> objectList) {
    
        List<Schema.Address> newAdds = (List<Schema.Address>) objectList;
        
            for ( Schema.Address newAdd : newAdds ) {
                if (string.isBlank(newAdd.Address_Guid__c)) {
                    newAdd.Address_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
    public override void beforeUpdate(List<Sobject> oldList, List<Sobject> newlist){

        List<Schema.Address> newAdds = (List<Schema.Address>) newlist;

            for ( Schema.Address newAdd : newAdds ) {
                if (string.isBlank(newAdd.Address_Guid__c)) {
                    newAdd.Address_Guid__c = ACVUtility.NewGuid();
                }
            }
    }
}