/**
 * @description       : Batch to schedule the noted ids on the metaadat
 * @author            : v-dchaves@acvauctions.com
 * @group             : Scheduling
 * @last modified on  : 05-20-2022
 * @last modified by  : v-dchaves@acvauctions.com
 * @test              : IdentifyDuplicatedRevolvingAppointTest
**/
// Job is scheduled to run before optimization, on the current day - As in, scheduled to run in the late evening
global class IdentifyDuplicatedRevolvingAppointments extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( false );

    // fields to query and compare uniqueness
    List<String> uniqueFields = new List<String>{'Work_Order__r.Occurrence__c',
                                                 'EarliestStartTime',
                                                 'DueDate'};

    //
    @TestVisible 
    public static BatchUtilityClass.BatchReturn batchReturn;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query  = ' SELECT ' + String.join(uniqueFields, ', ');
               query += ' FROM ServiceAppointment '; 
               query += ' WHERE Work_Order__c != null AND ';
               query += ' Work_Order__r.Occurrence__c != null AND ';
               query += ' EarliestStartTime != null AND ';
               query += ' DueDate != null AND ';
               query += ' CreatedDate = TODAY ';

        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        // scheduling
        IdentifyDuplicatedRevolvingAppointments job = new IdentifyDuplicatedRevolvingAppointments();
        //batch size of 100
        Database.executeBatch(job, 100);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        // we will map the service appointment by their "must" unique fields {Ocurrence Record ID, EarliestStartTime, DueDate}
        Map<String, ServiceAppointment> uniqueMap = new Map<String, ServiceAppointment>();

        for (ServiceAppointment srvcAppointment : scope){
            String key = '';

            key  = String.valueOf(srvcAppointment.Work_Order__r.Occurrence__c) + '/';
            key += String.valueOf(srvcAppointment.EarliestStartTime) + '/';
            key += String.valueOf(srvcAppointment.DueDate);

            // first occurrence
            if (uniqueMap.get(key) == null){
                uniqueMap.put(key, srvcAppointment);
            }
            // more than one ocurrence
            else {
                ServiceAppointment existentOcurrence = uniqueMap.get(key);

                String msg  = ' Duplicated record ' + String.valueOf(srvcAppointment.Id);
                       msg  = ' with ' + String.valueOf(existentOcurrence.Id);

                this.returnInfo.errorMessageLst.add(msg);
                this.returnInfo.errorReturnLst.add(String.valueOf(srvcAppointment.Id));
            }
        }
    }  

    global void finish(Database.BatchableContext bc) {
        IdentifyDuplicatedRevolvingAppointments.batchReturn = returnInfo;

        // Splunk Log
        BatchUtilityClass.createBatchLog(this.returnInfo, 
                                         BC.getJobId(), 
                                         'IdentifyDuplicatedRevolvingAppointments', 
                                         ACVUtility.currentLineNumber(),
                                         'IdentifyDuplicatedRevolvingAppointments:' + ACVUtility.currentLineNumber(), 
                                         new Set<String>{ 'Service Appointment' });
    }
}