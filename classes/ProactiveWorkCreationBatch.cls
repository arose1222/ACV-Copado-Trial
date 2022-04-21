global class ProactiveWorkCreationBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public static final FSL_Proactive_Work__mdt PROACTIVE_WORK_SETTINGS {
        get {
            if ( PROACTIVE_WORK_SETTINGS == null ) {
                FSL_Proactive_Work__mdt proactiveWorkSetting = [ SELECT Id, Days_Since_Last_Listing__c, Days_Since_Last_Service__c, Days_Until_Next_Service__c,
                                                                        Dealer_Id__c, Dealer_Type__c, Appointment_Days_Until_Due__c, Appointment_Duration_Minutes__c,
                                                                        Inspection_Type_Unique_Id__c, Appointment_Special_Instructions__c
                                                                 FROM FSL_Proactive_Work__mdt
                                                                 WHERE Label = 'Franchise' LIMIT 1 ];
                PROACTIVE_WORK_SETTINGS = proactiveWorkSetting;
            }
            return PROACTIVE_WORK_SETTINGS;
        }
        set;
    }

    public static final Id WORK_TYPE_ID {
        get {
            if(WORK_TYPE_ID == null) {
                WORK_TYPE_ID = [SELECT id FROM WorkType WHERE Work_Type_Unique_ID__c = :PROACTIVE_WORK_SETTINGS.Inspection_Type_Unique_Id__c LIMIT 1]?.id;
            }
            return WORK_TYPE_ID;
        }
        set;
    }

    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String Dealer_type = PROACTIVE_WORK_SETTINGS.Dealer_type__c;

        String query = 'SELECT Id, Service_Territory__c ' +
                       'FROM Account ' +
                       'WHERE Dealer_Type__c = :Dealer_type ' +
                            'AND Active__c = true ' +
                            'AND Proactive_Work_Opt_Out__c = false ' +
                            'AND  FSL_Proactive_Work_Beta__c = true';

        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        ProactiveWorkCreationBatch ProactiveWorkCreationBatch = new ProactiveWorkCreationBatch();
        Database.executeBatch(ProactiveWorkCreationBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){

        Datetime Date_Since_Last_Service = System.Now().addDays(-Integer.valueOf(PROACTIVE_WORK_SETTINGS.Days_Since_Last_Service__c));
        Datetime Date_Until_Next_Service = System.Now().addDays(Integer.valueOf(PROACTIVE_WORK_SETTINGS.Days_Until_Next_Service__c));
        Datetime Date_Since_Last_Listing = System.Now().addDays(-Integer.valueOf(PROACTIVE_WORK_SETTINGS.Days_Since_Last_Listing__c));

        Map<Id,Account> accountIdaccountMap = new Map<Id, Account>(scope);

        //Add Account Ids from scope to accountIdsToCreateWork if they have listed a vehicle in the given range
        Set<Id> accountIdsToCreateWork = new Set<Id>();
        for(Auction__c auctionRec : [SELECT Id, Seller_Dealership__c FROM Auction__c WHERE Seller_Dealership__c IN :scope AND start_time__c > :Date_Since_Last_Listing]){
            accountIdsToCreateWork.add(auctionRec.Seller_Dealership__c);
        }

        //Remove Account Ids from accountIdsToCreateWork if they had work completed in the given range, or have work scheduled in the given range
        for(ServiceAppointment saRec : [SELECT Id, Account__c FROM ServiceAppointment WHERE Account__c IN :accountIdsToCreateWork AND (ActualEndTime > :Date_Since_Last_Service OR (DueDate < :Date_Until_Next_Service AND DueDate >= TODAY))]){
            accountIdsToCreateWork.remove(saRec.Account__c);
        }

        //Create a work order for each account in accountIdsToCreateWork
        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
        for(Id accId : accountIdsToCreateWork){

            WorkOrder newWorkOrder = new WorkOrder(
                AccountId = accId,
                ServiceTerritoryId = accountIdaccountMap.get(accId).Service_Territory__c,
                WorkTypeId = WORK_TYPE_ID,
                Status = 'New',
                Special_Instructions__c = PROACTIVE_WORK_SETTINGS.Appointment_Special_Instructions__c,
                Proactive_Work__c = true
            );
            workOrdersToInsert.add(newWorkOrder);
        }

        Database.SaveResult[] workOrderMesgList = Database.insert(workOrdersToInsert, false);

        for ( Integer position = 0; position < workOrderMesgList.size(); position++ ) {
            Database.SaveResult saveRecord = workOrderMesgList[position];
            WorkOrder workOrderRec = workOrdersToInsert[position];

            if ( !saveRecord.isSuccess() || ( Test.isRunningTest() && BatchUtilityClass.testingFlag ) ) {
                returnInfo.errorReturnLst.add( JSON.serialize(workOrderRec ) );
                if ( !saveRecord.getErrors().isEmpty() ) { returnInfo.errorMessageLst.add( saveRecord.getErrors()[0].message ); }
            } else {
                returnInfo.successfulReturnSet.add( workOrderRec.Id );
            }
        }

        //Retreive the new Service Appointments related to the new Work Orders and update them
        List<ServiceAppointment> saList = [SELECT Id, Duration, DurationType, DueDate FROM ServiceAppointment WHERE Work_Order__c IN :workOrdersToInsert];

        for(ServiceAppointment saRec : saList){
            saRec.Duration = PROACTIVE_WORK_SETTINGS.Appointment_Duration_Minutes__c;
            saRec.DurationType = 'Minutes';
            saRec.DueDate = System.Now().addDays(Integer.valueOf(PROACTIVE_WORK_SETTINGS.Appointment_Days_Until_Due__c));
        }

        Database.SaveResult[] serviceApptMesgList = Database.update(saList, false);

        for ( Integer position = 0; position < serviceApptMesgList.size(); position++ ) {
            Database.SaveResult saveRecord = serviceApptMesgList[position];
            ServiceAppointment serviceAppointmentRec = saList[position];

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
            returnInfo, BC.getJobId(), 'ProactiveWorkCreationBatch', ACVUtility.currentLineNumber(),
            'ProactiveWorkCreationBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Service Appointment', 'Work Order' }
        );
    }

}