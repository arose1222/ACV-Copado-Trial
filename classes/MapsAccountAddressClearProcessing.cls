public class MapsAccountAddressClearProcessing extends TriggerInterface {
    public override void beforeUpdate( List<sObject> oldList, List<sObject> newList ) {
        clearAccounts( (List<Account>) oldList, (List<Account>) newList );
    }

    public static void clearAccounts( List<Account> oldLst, List<Account> newLst ) {
        for ( Integer index = 0; index < oldLst.size(); index++ ) {
            Account oldAcctRec = oldLst[index];
            Account newAcctRec = newLst[index];

            if ( oldAcctRec.BillingPostalCode != newAcctRec.BillingPostalCode ) {
                newAcctRec.Maps_TM_Assignment_Rule__c = null;
                newAcctRec.maps__AssignmentRule__c = null;
                newAcctRec.Maps_Title_Admin_Assignment_Rule__c = null;
                newAcctRec.Maps_Title_Consultant_Assignment_Rule__c = null;
                newAcctRec.Maps_Title_Specialist_Assignment_Rule__c = null;
            }
        }
    }
}