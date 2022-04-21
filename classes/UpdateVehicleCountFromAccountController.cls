public class UpdateVehicleCountFromAccountController {
    @AuraEnabled
    public static List<ServiceAppointment> getEligibleServiceAppointments(Id accountId){
        DateTime startTime = System.now();
        return [SELECT Id, SchedStartTime, Work_Type_Name__c, Work_Order__r.Occurrence__c, (SELECT ServiceResource.Name FROM ServiceResources LIMIT 1)
                FROM ServiceAppointment
                WHERE AccountId = :accountId
                    AND Status IN ('New', 'Scheduled', 'Dispatched', 'Acknowledged')
                    AND WorkType.Work_Type_Unique_ID__c IN ('inspection', 'true360', 'siriusxm')
                    AND DueDate > :startTime
                    AND DueDate <= NEXT_N_DAYS:4
                    ];
    }
}