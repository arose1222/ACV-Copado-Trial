public class ServiceAppointmentUtility {
    
    public static ServiceAppointment createAppointmentFromWorkOrder( WorkOrder woRec, String status, DateTime startDT, DateTime dueDT ) {
        return new ServiceAppointment(
            ServiceTerritoryId = woRec?.ServiceTerritoryId,
            ParentRecordId = woRec?.Id,
            Work_Order__c = woRec?.Id,
            Status = status,
            //Account__c = woRec.AccountId,
            EarliestStartTime = startDT,
            DueDate = dueDT,
            Duration = FSLWorkProcessUtility.getNumberOfMinutes( woRec.WorkTypeId, woRec.Inspection_Number_of_Vehicles__c != null ? Integer.valueOf( woRec.Inspection_Number_of_Vehicles__c ) : null ),
            DurationType = woRec?.DurationType,
            FSL__GanttLabel__c = woRec?.Account?.Name,
            OwnerId = woRec?.OwnerId?.getSObjectType() == Schema.User.SObjectType ? woRec?.OwnerId : UserInfo.getUserId(),
            Subject = woRec?.Subject,
            Description = woRec?.Description,
            Street = woRec?.Street,
            City = woRec?.City,
            PostalCode = woRec?.PostalCode,
            State = woRec?.State,
            Country = woRec?.Country
        );
    }
}