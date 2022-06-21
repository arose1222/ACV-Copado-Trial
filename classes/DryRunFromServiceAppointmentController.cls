/**
 * @description       : Controller class for Dry Run button from de Service Appointment record
 * @author            : v-dchaves@acvauctions.com
 * @group             : Scheduling
 * @last modified on  : 05-13-2022
 * @last modified by  : v-dchaves@acvauctions.com
 * @Test              : DryRunFromServiceAppointmentCtlrTest
**/
public with sharing class DryRunFromServiceAppointmentController {
    /**
     * Method to get the service appointment information to display on the component
     * @param String id of the record to ge the serviceAppointment
     * @returns serialized Response
     */
    @AuraEnabled(cacheable=true)
    public static String getServiceAppointment(String recordId){
        Map<String, String> response = new Map<String, String>();
        response.put('Status', 'SUCCESS');

        try {
            response.put('CannotCompleteValues', JSON.serialize(getCannotCompleteReasonValues()));

            String escapedId = String.escapeSingleQuotes(recordId);

            ServiceAppointmentWrapper objWrapper = new ServiceAppointmentWrapper(escapedId);
            
            response.put('Record', JSON.serialize(objWrapper));
        } catch (Exception e) {
            response.put('Status', 'ERROR');
            response.put('Message', e.getMessage());
            
            makeLog(recordId, e);
        }

        String jsonObj = JSON.serialize(response);

        return jsonObj;
    }

    /**
     * Method to get all picklist values that began with Dry Run sufix
     * ! DO NOT USE IN A LOOP
     */
    private static Map<String, String> getCannotCompleteReasonValues(){
        Map<String, String> picklistValues = new Map<String, String>();

        Schema.DescribeFieldResult fieldResult = ServiceAppointment.Cannot_Complete_Reason__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
            String valueLabel = pickListVal.getLabel();
            if (valueLabel.startsWithIgnoreCase('Dry Run')){
                picklistValues.put(pickListVal.getValue(), valueLabel);
            }
		}  
        
        return picklistValues;
    }
    
    /**
     * Method to marked a service appointment as Dry Run
     * @param String serialized object with the dry run information
     * @returns serialized response
     */
    @AuraEnabled
    public static String markAsDryRun(String serializedWrapper){
        Map<String, String> response = new Map<String, String>();
        response.put('Status', 'SUCCESS');

        try {
            ServiceAppointmentWrapper wrapperObj = (ServiceAppointmentWrapper) JSON.deserialize(serializedWrapper, ServiceAppointmentWrapper.class);

            wrapperObj.updateServiceAppointmentWithDryRun();
        } catch (Exception e) {
            response.put('Status', 'ERROR');
            response.put('Message', e.getMessage());

            makeLog(serializedWrapper, e);
        }

        return JSON.serialize(response);
    }
    
    /**
     * Mehtod to create log
     */
    private static Void makeLog(String failedStructure, Exception e) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.version = 'v1'; // We don't have versions yet
        log.logLevel = SplunkHelper.LOGLEVEL.ERROR;
        log.sfRecordId = UserInfo.getUserId();
        log.componentName = 'DryRunFromServiceAppointmentController';
        log.sfObject = 'ServiceAppointment';
        log.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTOR_DISPATCH };

        if(e != null){
            log.location += ': ' + e.getLineNumber();
            log.stackTrace = e.getStackTraceString();
            log.message += '\n' + e.getMessage();
        }

        SplunkHelper.buildandProcessLog( log, new List<SplunkHelper.SFErrorRecord>{new SplunkHelper.SFErrorRecord(failedStructure, e.getMessage())}, new Set<String>());
    }

    /**
     * Wrapper class for updating the record
     */
    public with sharing class ServiceAppointmentWrapper {
        /**
         * id of the service appointment
         */
        @TestVisible
        Id recordId;
        /**
         * ActualStartTime field from record
         */
        Datetime actualStart;
        /**
         * ActualEndTime field from record
         */
        Datetime actualEnd;
        /**
         * Cannot_Complete_Reason__c field from record
         */
        @TestVisible
        String cannotCompleteReason;
        /**
         * Dry_Run__c field from record
         */
        @TestVisible
        Boolean dryRun;

        /**
         * Constructor method 
         * ! DO NOT USE IN A LOOP
         * @param String id of the Service Appointment to create the object
         */
        ServiceAppointmentWrapper(String recordId){
            this.recordId = recordId;

            List<String> selectedFields = new List<String>{'Cannot_Complete_Reason__c',
                                                           'Dry_Run__c',
                                                           'ActualStartTime',
                                                           'ActualEndTime'};

            String query  = ' SELECT Id, ' + String.join(selectedFields, ', ');
                   query += ' FROM ServiceAppointment ';
                   query += ' WHERE Id = :this.recordId ';

            ServiceAppointment serviceAppointmentRcrd = Database.query(query);

            this.dryRun = serviceAppointmentRcrd.Dry_Run__c;
            this.cannotCompleteReason = serviceAppointmentRcrd.Cannot_Complete_Reason__c;
            this.actualStart = serviceAppointmentRcrd.ActualStartTime;
            this.actualEnd = serviceAppointmentRcrd.ActualEndTime;
        }

        /**
         * Method to update the Service Appointment with the wrapper information
         * ! DO NOT USE IN A LOOP
         */
        public Void updateServiceAppointmentWithDryRun(){
            ServiceAppointment serviceAppointment = new ServiceAppointment();
            serviceAppointment.Id = this.recordId;
            serviceAppointment.ActualStartTime = this.actualStart;
            serviceAppointment.ActualEndTime = this.actualEnd;
            serviceAppointment.Cannot_Complete_Reason__c = this.cannotCompleteReason;
            serviceAppointment.Status = 'Completed';
            serviceAppointment.Dry_Run__c = true;

            // updates the work order
            Id workOrderId = [SELECT Work_Order__c FROM ServiceAppointment WHERE Id = :serviceAppointment.Id].Work_Order__c;

            WorkOrder wrkOrder = new WorkOrder(Id = workOrderId);
            wrkOrder.Status = 'Completed';

            List<SObject> updateList = new List<SObject>{serviceAppointment, wrkOrder};
            update updateList;
        }
    }
}