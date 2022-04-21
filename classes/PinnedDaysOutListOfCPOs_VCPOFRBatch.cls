global class PinnedDaysOutListOfCPOs_VCPOFRBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {

    // Query related variables
    public static final Integer DEFAULT_DAY_RANGE {
        get {
            if ( DEFAULT_DAY_RANGE == null ) {
                Salesforce_Setting__mdt dateRange = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE Label = 'SA Pinned Days Not CPOGM CPOHNICE CPOJLR' LIMIT 1 ];
                DEFAULT_DAY_RANGE = Integer.valueOf( dateRange.Value__c );
            }
            return DEFAULT_DAY_RANGE;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date Date_NumDaysOut = System.Today().addDays(DEFAULT_DAY_RANGE);
        String query = 'select Id, DueDate, FSL__Pinned__c, Subject from serviceappointment WHERE WorkType.Work_Type_Unique_ID__c IN (\'cpobd\', \'cpobm\', \'cpofr\', \'cpohn04\', \'cpohn06\', \'cpohn08\', \'cpohn10\', \'cpohn12\', \'cpohn14\', \'cpohn16\', \'cpohn18\', \'cpohn20\', \'cpopo\', \'cpo90\', \'cpo120\', \'cpo150\', \'cpo180\', \'cpo240\', \'cpo270\', \'cpo300\') AND DueDate = :Date_NumDaysOut';
        // return
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        // scheduling
        PinnedDaysOutListOfCPOs_VCPOFRBatch pdoacvb = new PinnedDaysOutListOfCPOs_VCPOFRBatch();
        Database.executeBatch(pdoacvb, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        // batch process
        for (ServiceAppointment sa : scope) {
            // Because DueDate was # days out, Set the Pinned Checkbox = TRUE
            sa.FSL__Pinned__c = true;
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
            returnInfo, BC.getJobId(), 'PinnedDaysOutListOfCPOs_VCPOFRBatch', ACVUtility.currentLineNumber(), 
            'PinnedDaysOutListOfCPOs_VCPOFRBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment' }
        );
    }
}