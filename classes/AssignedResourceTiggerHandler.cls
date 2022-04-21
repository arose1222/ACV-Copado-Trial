/**
 * This replaces the Trigger trac_AssignedResourceTrigger and was made due to othe face that the helpers used here in before insert are used in 
 * multiple places and were not good canidates to be put onto the trigger framework.
 * @author Bill Sutton
 * @since March 9th 2021
 * @group FSL
 */
public class AssignedResourceTiggerHandler extends TriggerInterface{
    
    public override void beforeInsert(List<SObject> newList){
        new trac_AssignedResourceValidationHelper().ValidateAssignResource((List<AssignedResource>)newList);
        new trac_AssignedResourceStatusOwnerHelper().updateWorkOrderStatusOwner((List<AssignedResource>)newList);
    }

    public override void afterInsert(List<SObject> newList){
        trac_AssignedResourceTriggerHandler.createEntitySubscriptionForResource((List<AssignedResource>)newList);
    }

    public override void beforeDelete(List<SObject> oldList){
        trac_AssignedResourceTriggerHandler.deleteEntitySubscriptionForResource((List<AssignedResource>)oldList);
    }
}