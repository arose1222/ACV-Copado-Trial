public class MapsLeadAddressClearProcessing extends TriggerInterface {
    public override void beforeUpdate( List<sObject> oldList, List<sObject> newList ) {
        clearLeads( (List<Lead>) oldList, (List<Lead>) newList );
    }

    public static void clearLeads( List<Lead> oldLst, List<Lead> newLst ) {
        for ( Integer index = 0; index < oldLst.size(); index++ ) {
            Lead oldAcctRec = oldLst[index];
            Lead newAcctRec = newLst[index];

            if ( oldAcctRec.PostalCode != newAcctRec.PostalCode ) {
                newAcctRec.maps__AssignmentRule__c = null;
            }
        }
    }
}