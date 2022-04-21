public class AddAddressToAccountController {
    
    @AuraEnabled
    public static void GenerateAddress(String inputAddy, String accountId){
        AddressHelper.AddressWrapper aw = (AddressHelper.AddressWrapper)JSON.deserialize(inputAddy, AddressHelper.AddressWrapper.class);
        Savepoint sp = Database.setSavepoint();
        try {
            insert AddressHelper.generateAddressStack(aw, accountId);
        } catch (Exception e) {
            Database.rollback( sp );
            throw new AuraHandledException(e.getMessage());
        }
    }
}