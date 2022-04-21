/**
 * @description Trigger utility class for validating permission to assign resources to a service appointment.
 * @author Karen Reardon, Traction on Demand
 * @date 2019-08-30
 */
public with sharing class trac_AssignedResourceValidationHelper {
    @TestVisible static final String SCHEDULE_OTHER_RESOURCES_PERMISSION = 'Schedule_Other_Resources';
    @TestVisible static final String VEHICLE_CONDITION_INSPECTOR_PROFILE = 'Vehicle Condition Inspector';
    @TestVisible static final String VEHICLE_CONDITION_INSPECTOR_PROFILE_BETA = 'Vehicle Condition Inspector';
    @TestVisible static final Set<String> VEHICLE_PROFILE_SET = new Set<String>{ VEHICLE_CONDITION_INSPECTOR_PROFILE, VEHICLE_CONDITION_INSPECTOR_PROFILE_BETA };
    @TestVisible static final String ASSIGN_RESOURCE_PERMISSION_VALIDATION_ERROR = 'You have attempted to assign a different resource than yourself to this Service Appointment. Please select yourself as the assignee or contact your administrator.';


    /**
     * @description Indicates if the current user has permission to assign other resources to a service appointment.
     * Permission is granted at this level, if either:
     * User has a profile that is not Vehicle Condition Inspector, including if this profile is not configured
     * User has been granted the Schedule_Other_Resources permission
     * @returns true if permission is granted.
     */
    public Boolean assignOtherResourcesAllowed() {
        Boolean isAllowed = true;

        if (!FeatureManagement.checkPermission(SCHEDULE_OTHER_RESOURCES_PERMISSION)) {
            for ( Profile p : [SELECT Id FROM Profile WHERE Name IN :VEHICLE_PROFILE_SET] ) {
                isAllowed = (p.Id != UserInfo.getProfileId());
                if ( !isAllowed ) { break; }
            }
        }
        return isAllowed;
    }


    /**
     * @description Reports an error if the running user attempts to assign another resource besides themselves and does not have permission to do this.
     * Only senior Vehicle Condition Inspectors with the Schedule_Other_Resources permission can assign other resources.
     * @param assignedResources list of assigned resources
     */
    public void validateAssignResource(List<AssignedResource> assignedResources) {
        if (!assignOtherResourcesAllowed()) {
            Id runningUserId = UserInfo.getUserId();

            //Get a map of ServiceResources and the assigned users because this data is not available in a trigger directly
            Set<Id> serviceResourceIds = new Set<Id>();
            for (AssignedResource assignedResource : assignedResources) {
                if (assignedResource.ServiceResourceId != null) {
                    serviceResourceIds.add(assignedResource.ServiceResourceId);
                }
            }

            Map<Id,ServiceResource> serviceResources = new Map<Id,ServiceResource>(
                [SELECT Id, RelatedRecordId FROM ServiceResource WHERE Id IN :serviceResourceIds]);

            for (AssignedResource assignedResource : assignedResources) {
                ServiceResource serviceResource = serviceResources.get(assignedResource.ServiceResourceId);
                String resourceUserId = (serviceResource != null) ? serviceResource.RelatedRecordId : '';

                if (runningUserId != resourceUserId) {
                    assignedResource.addError(ASSIGN_RESOURCE_PERMISSION_VALIDATION_ERROR);
                }
            }
        }
    }
}