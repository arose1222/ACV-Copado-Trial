public class ServiceAppointmentUtility {

    public static ServiceAppointment createAppointmentFromWorkOrder( WorkOrder woRec, String status, DateTime startDT, DateTime dueDT ) {
        return createAppointmentFromWorkOrder( woRec, status, startDT, dueDT, new Map<String,ServiceAppointment>() );
    }

    public static ServiceAppointment createAppointmentFromWorkOrder( WorkOrder woRec, String status, DateTime startDT, DateTime dueDT, Map<String,ServiceAppointment> saOverrideMap ) {

        ServiceAppointment sa = new ServiceAppointment();

        sa.ServiceTerritoryId = woRec?.ServiceTerritoryId;
        sa.ParentRecordId = woRec?.Id;
        sa.Work_Order__c = woRec?.Id;
        sa.Status = status;
        //Account__c = woRec.AccountId;
        sa.EarliestStartTime = startDT;
        sa.DueDate = dueDT;
        sa.Duration = FSLWorkProcessUtility.getNumberOfMinutes( woRec.WorkTypeId, woRec.Inspection_Number_of_Vehicles__c != null ? Integer.valueOf( woRec.Inspection_Number_of_Vehicles__c ) : null );
        sa.DurationType = woRec?.DurationType;
        sa.FSL__GanttLabel__c = woRec?.Account?.Name;
        sa.OwnerId = woRec?.OwnerId?.getSObjectType() == Schema.User.SObjectType ? woRec?.OwnerId : UserInfo.getUserId();
        sa.Subject = woRec?.Subject;
        sa.Description = woRec?.Description;
        sa.Street = woRec?.Street;
        sa.City = woRec?.City;
        sa.PostalCode = woRec?.PostalCode;
        sa.State = woRec?.State;
        sa.Country = woRec?.Country;


        if( saOverrideMap.containsKey( woRec.Service_Appt_Map_Id__c ) ){
            Map<String, Object> values = saOverrideMap.get( woRec.Service_Appt_Map_Id__c ).getPopulatedFieldsAsMap();
            for(String fieldName : values.keySet() ){
                sa.put(fieldName,values.get(fieldName));
            }
        }
        return sa;
    }
}