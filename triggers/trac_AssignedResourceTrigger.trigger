trigger trac_AssignedResourceTrigger on AssignedResource (before insert, after insert, before delete ) {
    if ( Trigger.isInsert) {
        //if(isBeta(Trigger.New)){
            if(Trigger.isBefore) {
                new trac_AssignedResourceValidationHelper().ValidateAssignResource(Trigger.New);
                new trac_AssignedResourceStatusOwnerHelper().updateWorkOrderStatusOwner(Trigger.New);
            }

            if(Trigger.isAfter) {
                trac_AssignedResourceTriggerHandler.createEntitySubscriptionForResource(Trigger.new);
            }
        //}
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        //if(isBeta(Trigger.old)){
            trac_AssignedResourceTriggerHandler.deleteEntitySubscriptionForResource(Trigger.old);
        //}
    }
    
}