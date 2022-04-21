public with sharing class liveAppraisalController {

    public static final Id WHOLESALE_INSPECTION = [SELECT id FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1].id;

    @AuraEnabled
    public static List<LookupSearchResult> getServiceResources(String searchTerm, List<String> selectedIds) {
        searchTerm += '*';
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING ServiceResource (Id, Name WHERE id NOT IN :selectedIds) LIMIT 10];
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        ServiceResource [] serviceResourceList = ((List<ServiceResource>) searchResults[0]);
        for (ServiceResource serviceResource : serviceResourceList) {
            results.add(new LookupSearchResult(serviceResource.Id, 'ServiceResource', 'standard:service_resource', serviceResource.Name, null));
        }
        return results;
    }

    @AuraEnabled
    public static Response submitWorkOrders(String woInfoJSON, List<String> serviceResourceIds){

        string logMessage = 'Work Order Submission: ' + woInfoJson + '\n';
        Set<string> successfulIds = new Set<string>();
        List<SplunkHelper.SFErrorRecord> errorRecords = new List<SplunkHelper.SFErrorRecord>();
        Response res = new Response();
        SplunkHelper.LOGLEVEL logLevel;
        Exception ex;

        try{
           //convert all needed work order info from the json object
            Map<String, Object> woInfo = new Map<String,Object>();
            woInfo = (Map<String,Object>)JSON.deserializeUntyped(woInfoJSON);
            id account = (id)woInfo.get('accountId');
            
            string city = (string)woInfo.get('city');
            string state = (string)woInfo.get('state');
            string country = (string)woInfo.get('country');
            string zip = (string)woInfo.get('zip');
            string street = (string)woINfo.get('street');
            string timeSelection = (string)woInfo.get('timeSelection');

            //boolean notificationRequest = Boolean.valueOf(woInfo.get('NotificationRequest'));

            id contact;

            Date woDate;
            if(woInfo.get('date') != null){
                woDate = WorkOrderIngestController.convertDate((string)woInfo.get('date'));
            }

            Time scheduledStartTime = Time.newInstance(9, 0, 0, 0);
            if(woInfo.get('startTime') != null){
                scheduledStartTime = convertTime((string)woInfo.get('startTime'));
            }

            Time scheduledEndTime = Time.newInstance(17, 0, 0, 0);
            if(woInfo.get('endTime') != null){
                scheduledEndTime = convertTime((string)woInfo.get('endTime'));
            }

            DateTime earliestStart = (woDate != null && scheduledStartTime != null) ? DateTime.newInstance(woDate, scheduledStartTime) : DateTime.now();
            DateTime due = (woDate != null && scheduledEndTime != null) ? DateTime.newInstance(woDate, scheduledEndTime) : DateTime.now();

            if(woInfo.get('contact') != null){
                contact = (id)woInfo.get('contact');
            }

            string origin = 'Ingest2';

            id stId;
            if(woInfo.get('serviceTerritory') != null){
                stId = (id)woInfo.get('serviceTerritory');
            }

            Map<Id, Integer> vehicleCountMap = new Map<Id, Integer>();
            List<WorkOrder> woInsertList = new List<WorkOrder>();

            Id inspectionReqId = InspectionRequest.createInspectionRequest(account, vehicleCountMap, timeSelection);
             
            for(Id servResourceId : serviceResourceIds) {

                WorkOrder wo = new WorkOrder(
                        accountId = account,
                        contactId = contact,
                        ServiceTerritoryId = stId,
                        Origin__c = origin,
                        StartDate = earliestStart,
                        Special_Instructions__c = 'Live Appraisal Event',
                        WorkTypeId = WHOLESALE_INSPECTION,
                        City = city,
                        Street = street,
                        PostalCode = zip,
                        Country = country,
                        State = state,
                        Created_Without_Line_Items__c = TRUE,
                        Inspection_Request__c = inspectionReqId,
                        DueDate_Adjustment_Engine_Bypass__c = TRUE
                    );
                woInsertList.add(wo);
            }

            Database.SaveResult[] woInsertionResults = Database.insert(woInsertList);
            logMessage += WorkOrderIngestController.workOrderInsertionLog(woInsertionResults);
            successfulIds.addAll(WorkOrderIngestController.getSuccessfulIds(woInsertionResults));
            errorRecords.addAll(WorkOrderIngestController.getErrorRecords(woInsertionResults));

            //track successfully inserted wo's
            Set<Id> insertedWos = new Set<Id>();
            for(Database.SaveResult sr : woInsertionResults){
                if(sr.isSuccess()){
                    insertedWos.add(sr.getId());
                }
            }

            Map<Id, ServiceAppointment> saMap = new Map<id, ServiceAppointment>([SELECT id, WorkTypeId, ServiceTerritoryId, parentRecordId, Duration, Account__c FROM ServiceAppointment WHERE parentRecordId in :insertedWos ]);

            //get and update service appointment start time
            List<ServiceAppointment> saUpdateList = new List<ServiceAppointment>();

            List<ServiceAppointment> selfAssignAppointments = new List<ServiceAppointment>();
            List<ServiceAppointment> createSubscriptionAppointments = new List<ServiceAppointment>();

            for(serviceAppointment sa : saMap.values()){

                res.inspectionWOId = sa.parentRecordId;
                res.inspectionDuration = sa.Duration;

                sa.earliestStartTime = earliestStart;
                sa.dueDate = due;
                sa.SchedStartTime = earliestStart;
                sa.SchedEndTime = due;
                sa.Status = 'Scheduled';
                sa.Live_Appraisal_Event__c = true;
                sa.Committed__c = true;
                sa.Exclude_from_Optimization__c = true;
                saUpdateList.add(sa);
            }

            Database.SaveResult[] saUpdateResults = Database.update(saUpdateList);
            logMessage += WorkOrderIngestController.serviceAppointmentUpdateLog(saUpdateResults);
            successfulIds.addAll(WorkOrderIngestController.getSuccessfulIds(saUpdateResults));
            errorRecords.addAll(WorkOrderIngestController.getErrorRecords(saUpdateResults));

            List<AssignedResource> arInsertionList = new List<AssignedResource>();
            if(serviceResourceIds.size()  == saMap.size()){
                Integer position = 0;
                for(ServiceAppointment sa : saMap.values()){
                    arInsertionList.add(new AssignedResource(ServiceResourceId = serviceResourceIds[position], ServiceAppointmentId = sa.Id));
                    position++;
                }
            }

            Database.SaveResult[] arInsertionResults = Database.Insert(arInsertionList);
            logMessage += WorkOrderIngestController.assignedResourceInsertionLog(arInsertionResults);
            successfulIds.addAll(WorkOrderIngestController.getSuccessfulIds(arInsertionResults));
            errorRecords.addAll(WorkOrderIngestController.getErrorRecords(arInsertionResults));

            res.status = 'Success';

            logLevel = (errorRecords.size() > 0) ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;
        }

        catch(DmlException e){
            res.status = 'Failure';
            res.message = e.getMessage();
            logLevel = SplunkHelper.LOGLEVEL.FATAL;
            ex = e;
        }

        WorkOrderIngestController.makeLog(logMessage, logLevel, errorRecords, successfulIds, ex);
        return res;
    }

    public static Time convertTime(String timeString) {
        List<String> timeValues = timeString.split(':');
        return Time.newInstance(Integer.valueOf(timeValues[0]), Integer.valueOf(timeValues[1]), 0, 0);
    }

    public class Response{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public Id inspectionWOId;
        @AuraEnabled public Decimal inspectionDuration;
    }
}