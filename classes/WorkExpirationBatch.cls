/**
 * @description       : Batch to schedule the noted ids on the metaadat
 * @author            : v-dchaves@acvauctions.com
 * @group             : Scheduling
 * @last modified on  : 05-12-2022
 * @last modified by  : v-dchaves@acvauctions.com
 * @test              : WorkExpirationBatchTest
**/
// Job is scheduled to run before optimization, on the current day - As in, scheduled to run in the late evening
global class WorkExpirationBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    /**
     * metadata to get the status and the ids to expire appointments without ocurrence
     */
    @TestVisible
    private static List<FSL_Users_to_Expire_Appointment__mdt> USERS_MTDT {
        get {
            if (USERS_MTDT == null){
                USERS_MTDT = [SELECT Id, Label, User_Id__c FROM FSL_Users_to_Expire_Appointment__mdt LIMIT 1000];
            }

            return USERS_MTDT;
        }

        set;
    }

    /**
     * Status to change the service appointments
     */
    @TestVisible
    public static String STATUS_CHANGE {
        get {
            if ( STATUS_CHANGE == null ) {
                Salesforce_Setting__mdt var = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'Revolving Appointment Expiration' LIMIT 1 ];
                STATUS_CHANGE = var.Value__c;
            }
            return STATUS_CHANGE;
        }
        set;
    }

    /**
     * Set of ids to
     */
    public static Set<Id> USER_IDS {
        get {
            if (USER_IDS == null){
                USER_IDS = new Set<Id>();
                
                for (FSL_Users_to_Expire_Appointment__mdt meta : USERS_MTDT){
                    USER_IDS.add(Id.valueOf(meta.User_Id__c));
                }
            }

            return USER_IDS;
        }

        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> statuses = new Set<String>{'New', 'Scheduled'};
        Set<String> workTypes = new Set<String>{'inspection', 'verification', 'true360'};

        String query  = ' SELECT Status, ParentRecordId ';
               query += ' FROM ServiceAppointment '; 
               query += ' WHERE WorkType.Work_Type_Unique_ID__c IN :workTypes AND ';
               query += ' Status IN :statuses AND ';
               query += ' DueDate <= TODAY AND ';
               query += ' Work_Order__r.Occurrence__c = null AND ';
               query += ' CreatedById IN :USER_IDS';
        
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        WorkExpirationBatch job = new WorkExpirationBatch();
        //batch size of 100
        Database.executeBatch(job, 100);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        Set<Id> workOrderIdLst = new Set<Id>();
        for (ServiceAppointment sa : scope) {
            sa.Status = STATUS_CHANGE;
        }

        // update all Service Appointment records
        Database.SaveResult[] mesgList = Database.update(scope, false);
        for ( Integer position = 0; position < mesgList.size(); position++ ) {
            Database.SaveResult saveRecord = mesgList[position];
            ServiceAppointment serviceAppointmentRec = scope[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(serviceAppointmentRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { system.debug( saveRecord.getErrors()[0].message ); returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( serviceAppointmentRec.Id );
                workOrderIdLst.add( serviceAppointmentRec.ParentRecordId );
            }
        }

        List<WorkOrder> woLst = new List<WorkOrder>();

        // Only touch work orders of Service Appointments without update issues
        if ( !workOrderIdLst.isEmpty() ) {
            for (Id uid : workOrderIdLst){
                woLst.add(new WorkOrder(Id = uid, Status = STATUS_CHANGE));
            }

            // update records
            mesgList = Database.update(woLst, false);
            for ( Integer position = 0; position < mesgList.size(); position++ ) {
                Database.SaveResult saveRecord = mesgList[position];
                WorkOrder workRec = woLst[position];

                if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                    returnInfo.errorReturnLst.add( JSON.serialize( workRec ) );
                    if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
                } else {
                    returnInfo.successfulReturnSet.add( workRec.Id );
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'WorkExpirationBatch', ACVUtility.currentLineNumber(),
            'WorkExpirationBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment, Work Order' }
        );
    }
}