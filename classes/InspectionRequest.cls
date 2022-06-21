public with sharing class InspectionRequest {

    public static Id createInspectionRequest(Id accountId, Map<Id, Integer> vehicleCountMap, String timeSelection){

        Map<String,String> timeSelectionMap = new Map<String,String>{'Later' => 'A specific date in the future', 'ASAP' => 'As soon as possible', 'Now' => 'Self assign now', 'Revolving Appointment' => 'Revolving Appointment'};

        Inspection_Request__c inspecReq = new Inspection_Request__c(
            Account__c = accountId,
            Request_Type__c = timeSelectionMap.get(timeSelection),
            Number_of_Standard_Inspection__c = vehicleCountMap.containsKey(workOrderIngestController.WHOLESALE_INSPECTION) ? vehicleCountMap.get(workOrderIngestController.WHOLESALE_INSPECTION) : 0,
            Number_of_SiriusXM__c = vehicleCountMap.containsKey(workOrderIngestController.SIRIUS_XM) ? vehicleCountMap.get(workOrderIngestController.SIRIUS_XM) : 0,
            Number_of_True360__c = vehicleCountMap.containsKey(workOrderIngestController.TRUE_360) ? vehicleCountMap.get(workOrderIngestController.TRUE_360) : 0,
            Number_of_Auction_Site__c = vehicleCountMap.containsKey(workOrderIngestController.AUCTION_SITE) ? vehicleCountMap.get(workOrderIngestController.AUCTION_SITE) : 0,
            Buyer_Signup__c = vehicleCountMap.containsKey(workOrderIngestController.BUYER_SIGNUP) ? true : false
        );

        insert inspecReq;

        return inspecReq.Id;

    }

    @AuraEnabled
    public static Id createRevolvingInspectionRequest( Id accountId, Integer numberOfVehicles, Id workTypeId ){

        Map<Id, Integer> vehicleCountMap = new Map<Id, Integer>{
            workTypeId  => numberOfVehicles
        };

        String timeSelection = 'Revolving Appointment';


        return createInspectionRequest(accountId, vehicleCountMap, timeSelection);
    }

}