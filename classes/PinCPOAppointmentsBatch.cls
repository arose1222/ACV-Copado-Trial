global class PinCPOAppointmentsBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        query =  'SELECT Id, Committed__c ';
        query += 'FROM ServiceAppointment ';
        query += 'WHERE WorkType.Work_Type_Unique_ID__c IN ';
        //All CPO work types
        query +=    '(\'cpobd\', \'cpobm\', \'cpofr\', \'cpolnc\',  \'cpogm\', \'cpogmcomp\', \'cpohnice\', \'cpojlr\', \'cpohn04\', \'cpohn06\', \'cpohn08\', \'cpohn10\', \'cpohn12\', ';
        query +=    '\'cpohn14\', \'cpohn16\', \'cpohn18\', \'cpohn20\', \'cpopo\', \'cpo90\', \'cpo120\', \'cpo150\', \'cpo180\', \'cpo240\', \'cpo270\', \'cpo300\', ';
        //All VCPO work types
        query +=    '\'vcpofr\', \'vcpogm\', \'vcpohn\', \'vcpopo\', \'gmfia\') ';
        query +=    'AND Status IN (\'Scheduled\',\'Dispatched\') ';
        query +=    'AND Committed__c = false';
         // return
        return Database.getQueryLocator(query);
    }
    // Low batch size due to current, direct integration not able to properly hande full volumes
    public override void executeScheduledLogic() {
        // scheduling
        PinCPOAppointmentsBatch PinCPOAppointmentsBatch = new PinCPOAppointmentsBatch();
        Database.executeBatch(PinCPOAppointmentsBatch, 50);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        for (ServiceAppointment sa : scope) {
            sa.Committed__c = true;
        }

        // update records
        Database.SaveResult[] mesgList = Database.update(scope, false);
        for ( Integer position = 0; position < mesgList.size(); position++ ) {
            Database.SaveResult saveRecord = mesgList[position];
            ServiceAppointment serviceAppointmentRec = scope[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(serviceAppointmentRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( serviceAppointmentRec.Id );
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'PinCPOAppointmentsBatch', ACVUtility.currentLineNumber(),
            'PinCPOAppointmentsBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment' }
        );
    }
}