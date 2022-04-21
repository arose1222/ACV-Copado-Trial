public without sharing class AssignedResourceCheckAbsence extends TriggerInterface {

    public final static String ERROR_MSG = 'This Service Resource has a scheduled absence and is NOT available for this Service Appointment.';

    public override void beforeInsert(List<sObject> newList) {

        List<AssignedResource> newAssignedResourceList = (List<AssignedResource>)newList;
        
        Set<Id> serviceAppointmentSetId = new Set<Id> ();
        Set<Id> serviceResourceSetId = new Set<Id> ();

        // Map will store a unique key (SvcApptId + SvcRsrcId) and AssignedResource records
        Map<String,AssignedResource> assignedResourceMap = new Map<String,AssignedResource>();

        // Grab ServiceAppointmentId, ServiceResourceId, & (Unique Key + newAssignedResourceList)
        for (AssignedResource arLoop1 : newAssignedResourceList) {
            serviceAppointmentSetId.add(arLoop1.ServiceAppointmentId);
            serviceResourceSetId.add(arLoop1.ServiceResourceId);
            assignedResourceMap.put(CreateKey(arLoop1.ServiceAppointmentId, arLoop1.ServiceResourceId), arLoop1);
        }

        // Query ServiceAppointment for SchedStartTime, SchedEndTime WHERE Id = newAssignedResourceList.ServiceAppointmentId
        Map<Id,ServiceAppointment> svcApptMap = new Map <Id,ServiceAppointment>([ SELECT Id, SchedStartTime, SchedEndTime 
                                                    FROM ServiceAppointment WHERE Id IN :serviceAppointmentSetId ]); 

        Map<Id,List<ServiceAppointment>> svcApptMapList = new Map<Id,List<ServiceAppointment>>();

        for (AssignedResource arLoop2 : newAssignedResourceList) {
            if (svcApptMap.get(arLoop2.ServiceAppointmentId) != NULL) {
                if (svcApptMapList.get(arLoop2.ServiceResourceId) == NULL) {
                    svcApptMapList.put(arLoop2.ServiceResourceId, new List<ServiceAppointment>());
                }
                svcApptMapList.get(arLoop2.ServiceResourceId).add(svcApptMap.get(arLoop2.ServiceAppointmentId));
            }
        }

        // Query ResourceAbsence for Start, End WHERE ResourceId = newAssignedResourceList.ServiceResourceId
        List<ResourceAbsence> resourceAbsenceList = [ SELECT Id, ResourceId, Start, End 
                                                    FROM ResourceAbsence 
                                                   WHERE ResourceId IN :serviceResourceSetId ];

        for (ResourceAbsence raLoop : resourceAbsenceList) {
            if (svcApptMapList.get(raLoop.ResourceId) != NULL) {
                for (ServiceAppointment saLoop : svcApptMapList.get(raLoop.ResourceId)) {
                    // if ((ra.Start <= sa.SchedStartTime && ra.End >= sa.SchedStartTime) 
                    //     || (ra.Start <= sa.SchedEndTime && ra.End >= sa.SchedEndTime) ) {
                    if ( !((saLoop.SchedStartTime > raLoop.End && saLoop.SchedEndTime > raLoop.End)
                        ||
                        (saLoop.SchedStartTime < raLoop.Start && saLoop.SchedEndTime < raLoop.Start)) ) {
                            // Found a ResourceAbsence conflict with Service Apppointment
                            assignedResourceMap.get(CreateKey(saLoop.Id, raLoop.ResourceId)).addError( ERROR_MSG);
                    }
                }
            }
        }
    }


    Public Static String CreateKey(Id SvcApptId, Id SvcRsrcId) {
        Return '' + SvcApptId + SvcRsrcId;
    }
}