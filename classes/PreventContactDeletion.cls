/**
 * Trigger Interface class to just call the PreventContact service
 * @author Jyothsna P
 * @since 4/16/21
 */
public class PreventContactDeletion extends TriggerInterface {

    public final static String ERROR_MSG = 'Contact records cannot be deleted. Please deactivate the contact to remove the affiliation.';
    public override void beforeDelete( List<SObject> oldList ) {    
        

        for(Contact c :(List<Contact>)oldList){
            if(ACVUtility.recordTypeCheck('ACV_User', 'Contact', c.RecordTypeID) && !FeatureManagement.checkPermission('Allow_Contact_Deletion'))
            {
                c.addError(ERROR_MSG);
            }
        }

    }
}