//runs in the evening after adjustcpotimelinebatch 10pm before midnight

global class GMBundlerBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private static Date EARLIEST_START_DATE {
        get {
            if ( EARLIEST_START_DATE == null ) {
                Salesforce_Setting__mdt defaultRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Extend_GMFIA_Start_Date' LIMIT 1 ];
                EARLIEST_START_DATE = System.today().addDays(Integer.valueOf( defaultRange.Value__c ));
            }
            return EARLIEST_START_DATE;
        }
        set;
    }

    // State Variable
    global BatchUtilityClass.BatchReturn returnInfo = new BatchUtilityClass.BatchReturn( FALSE );

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Start');

        String query;
        query =  'SELECT Id, EarliestStartTime, DueDate, Account.dealership_id__c, WorkType.Work_Type_Unique_ID__c, Work_Order__c ';
        query += 'FROM ServiceAppointment ';
        query += 'WHERE WorkType.Work_Type_Unique_ID__c = \'gmfia\' ';
        query +=    'AND Status IN (\'New\', \'Scheduled\') ';
        query +=    'AND EarliestStartTime >= :EARLIEST_START_DATE ';
        query +=    'AND work_order__r.lineitemcount = 1 ';
         // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        GMBundlerBatch GMBundlerBatch = new GMBundlerBatch();
        Database.executeBatch(GMBundlerBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        System.debug('execute');

        Map<String,ServiceAppointment> gmfiaDealerIdSAMap = new Map<String,ServiceAppointment>();
        Map<String,WorkOrderLineItem> cpogmDealerIdWOLIMap = new Map<String,WorkOrderLineItem>();

        Map<String, WorkOrderLineItem> dealerIdWoliDeleteMap = new Map<String, WorkOrderLineItem>();
        Map<String, WorkOrderLineItem> dealerIdWoliInsertMap = new Map<String, WorkOrderLineItem>();
        Map<String, Id> dealerIdWorkOrderDeleteMap = new Map<String, Id>();
        Map<String, ServiceAppointment> dealerIdSaUpdateMap = new Map<String, ServiceAppointment>();
        Map<String, Id> dealerIdWoIdUpdateMap = new Map<String, Id>();

        for(ServiceAppointment sa : scope){
            gmfiaDealerIdSAMap.put(sa.Account.dealership_id__c, sa);
        }

        List<ServiceAppointment> cpogmSAList = [SELECT Id, EarliestStartTime, DueDate, Work_Order__c, Account.dealership_id__c
                                                FROM ServiceAppointment
                                                WHERE Account.dealership_id__c IN: gmfiaDealerIdSAMap.keySet()
                                                    AND WorkType.Work_Type_Unique_ID__c = 'cpogm'
                                                    AND Status IN ('New', 'Scheduled')
                                                    AND EarliestStartTime >= :EARLIEST_START_DATE
                                                    AND work_order__r.lineitemcount = 1];

        List<Id> workOrderIdList = new List<Id>();
        for(ServiceAppointment cpogmSA : cpogmSAList){
            workOrderIdList.add(cpogmSA.Work_Order__c);
        }

        //Retrieve all significant fields from WOLI for cloning
        for(WorkOrderLineItem woli : [SELECT Id, Stock_Number__c, Origin__c, Street, City, State, PostalCode, Country, vin__c, year__c, make__c, model__c, color__c, Reserve_Price__c,
        Title_Status__c, Title_with_Dealer__c, Dealer_Contact__c, Residential__c, Add_To_Run_List__c, Floor_Price__c, Date_Inspected__c, WorkTypeId, WorkType.Name, WorkType.Work_Type_Unique_ID__c,
        External_Record_guid__c, WorkOrder.Account.Dealership_ID__c, WorkOrder.Origin__c, Due_Date__c, Status, Transport_Status__c, Description, Dealership_Name__c, Earliest_Start_Date__c,
        External_Invoice_Id__c, WorkOrderId, Inspection_Location__c, Series__c, External_Assignment_Id__c, Inspection_Id__c,
        Is_In_Jeopardy__c, Jeopardy_State__c, Lesse_Name__c, Open_Date__c, Maturity_Date__c, Contact_Name__c, Contact_Phone_Number__c, Contact_Mobile_Number__c, Contact_Email__c,
        Customer_Email__c, Driving_Directions__c, Is_Opportunity__c, Exclude_from_Optimization__c, WorkOrder.Street, WorkOrder.City, WorkOrder.State, WorkOrder.PostalCode, WorkOrder.Country, External_Link__c, External_Link_Code__c
        FROM WorkOrderLineItem WHERE WorkOrderId IN :workOrderIdList AND WorkType.Work_Type_Unique_ID__c = 'cpogm']){
            cpogmDealerIdWOLIMap.put(woli.WorkOrder.Account.Dealership_Id__c, woli);
        }

        for(ServiceAppointment cpogmSA : cpogmSAList){
            String dealerId = cpogmSA.Account.dealership_id__c;

            if(!cpogmDealerIdWOLIMap.containsKey(dealerId)){continue;}

            ServiceAppointment gmfiaSA = gmfiaDealerIdSAMap.get(dealerId);

            Datetime earliestCombinedStartDate = gmfiaSA.EarliestStartTime >= cpogmSA.EarliestStartTime ? gmfiaSA.EarliestStartTime : cpogmSA.EarliestStartTime;
            Datetime latestCombinedDueDate = gmfiaSA.DueDate <= cpogmSA.DueDate ? gmfiaSA.DueDate : cpogmSA.DueDate;

            if(earliestCombinedStartDate.date().daysBetween(latestCombinedDueDate.date()) >= 7){

                //Clone the WOLI and assign the work order
                WorkOrderLineItem cpogmOriginalWOLI = cpogmDealerIdWOLIMap.get(dealerId);
                WorkOrderLineItem cpogmClonedWOLI = cpogmOriginalWOLI.clone(false,false,false,false);
                cpogmClonedWOLI.workorderId = gmfiaSA.Work_Order__c;

                //Build data maps for processing
                dealerIdWoIdUpdateMap.put(dealerId, gmfiaSA.Work_Order__c);
                dealerIdWoliDeleteMap.put(dealerId, cpogmOriginalWOLI);
                dealerIdWoliInsertMap.put(dealerId, cpogmClonedWOLI);
                dealerIdWorkOrderDeleteMap.put(dealerId, cpogmSA.Work_Order__c);

                gmfiaSA.EarliestStartTime = earliestCombinedStartDate;
                gmfiaSA.DueDate = latestCombinedDueDate;
                dealerIdSaUpdateMap.put(dealerId, gmfiaSA);

            }
        }


        //Delete the WOLI prior to inserting its clone
        //If failure, log and remove from processing
        List<Database.DeleteResult> deleteResultList = Database.delete(dealerIdWoliDeleteMap.values(), FALSE);
        for( Integer i=0; i< deleteResultList.size(); i++ ){
            Database.DeleteResult deleteResult = deleteResultList[i];
            if( !deleteResult.isSuccess() ){
                WorkOrderLineItem woliRec = dealerIdWoliDeleteMap.values()[i];

                returnInfo.errorReturnLst.add(woliRec.WorkOrder.Account.Dealership_Id__c);
                returnInfo.errorMessageLst.add('Failure to Delete WOLI');

                dealerIdWoliInsertMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);
                dealerIdWorkOrderDeleteMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);
                dealerIdSaUpdateMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);
                dealerIdWoIdUpdateMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);
            }
        }


        //Insert the cloned woli list
        //If failure, log and remove from processing
            //AND undelete the deleted WOLI
        List<WorkOrderLineItem> woliUndeleteList = new List<WorkOrderLineItem>();

        List<Database.SaveResult> insertResultList = Database.insert( dealerIdWoliInsertMap.values(), FALSE );
        for ( Integer i = 0; i < insertResultList.size(); i++ ) {
            Database.SaveResult insertResult = insertResultList[i];
            if ( !insertResult.isSuccess() ) {
                WorkOrderLineItem woliRec = dealerIdWoliInsertMap.values()[i];

                returnInfo.errorReturnLst.add(woliRec.WorkOrder.Account.Dealership_Id__c);
                returnInfo.errorMessageLst.add('Failure to insert new WOLI');

                dealerIdWorkOrderDeleteMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);
                dealerIdSaUpdateMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);
                dealerIdWoIdUpdateMap.remove(woliRec.WorkOrder.Account.Dealership_Id__c);

                woliUndeleteList.add(dealerIdWoliDeleteMap.get(woliRec.WorkOrder.Account.Dealership_Id__c));
            }
        }

        //Update the SA list
        //If failure, log and remove from processing
            //AND undelete the deleted WOLI
            //AND delete the inserted WOLI
        List<WorkOrderLineItem> woliDeleteList = new List<WorkOrderLineItem>();

        Database.SaveResult[] updateResultList = Database.update(dealerIdSaUpdateMap.values(), false);
        for ( Integer i = 0; i < updateResultList.size(); i++ ) {
            Database.SaveResult updateResult = updateResultList[i];
            ServiceAppointment saRec = dealerIdSaUpdateMap.values()[i];

            if ( !updateResult.isSuccess() ) {

                returnInfo.errorReturnLst.add(saRec.Account.dealership_id__c);
                returnInfo.errorMessageLst.add('Failure to Update Service Appointment');

                dealerIdWorkOrderDeleteMap.remove(saRec.Account.dealership_id__c);
                dealerIdWoIdUpdateMap.remove(saRec.Account.dealership_id__c);

                woliUndeleteList.add(dealerIdWoliDeleteMap.get(saRec.Account.dealership_id__c));
                woliDeleteList.add(dealerIdWoliInsertMap.get(saRec.Account.dealership_id__c));

            } else {
                returnInfo.successfulReturnSet.add( saRec.Account.dealership_id__c );
            }
        }


        //Non-critical: Do not rollback with failure

        //Update the Special Instructions on the work order
        List<WorkOrder> woToUpdateList = new List<WorkOrder>();
        for(WorkOrder wo : [SELECT Id, Special_Instructions__c FROM WorkOrder WHERE Id IN :dealerIdWoIdUpdateMap.values()]){
            wo.Special_Instructions__c = 'This is a CPOGM and GMFIA assignment.';
            woToUpdateList.add(wo);
        }
        Database.SaveResult[] updateWOResultList = Database.update(woToUpdateList, false);


        //Delete the Work Orders that had their WOLI's removed
        List<WorkOrder> woDeleteList = [SELECT Id FROM WorkOrder WHERE Id IN :dealerIdWorkOrderDeleteMap.values()];
        List<Database.DeleteResult> woDeleteResultList = Database.delete(woDeleteList, false);


        //Rollback steps:

        //Undelete the deleted woli's
        List<Database.UndeleteResult> undeleteResultList = Database.undelete(woliUndeleteList, false);
        for ( Integer i = 0; i < undeleteResultList.size(); i++ ) {
            Database.UndeleteResult undeleteResult = undeleteResultList[i];
            WorkOrderLineItem woliRec = woliUndeleteList[i];
            if ( !undeleteResult.isSuccess() ) {
                returnInfo.errorReturnLst.add(woliRec.WorkOrder.Account.Dealership_Id__c);
                returnInfo.errorMessageLst.add('Rollback: Failure to Undelete previously deleted WOLI');
            }
        }

        //Delete the inserted woli's
        List<Database.DeleteResult> woliDeleteResultList = Database.delete(woliDeleteList, false);
        for ( Integer i = 0; i < woliDeleteResultList.size(); i++ ) {
            Database.DeleteResult woliDeleteResult = woliDeleteResultList[i];
            WorkOrderLineItem woliRec = woliDeleteList[i];
            if ( !woliDeleteResult.isSuccess() ) {
                returnInfo.errorReturnLst.add(woliRec.WorkOrder.Account.Dealership_Id__c);
                returnInfo.errorMessageLst.add('Rollback: Failure to delete previously inserted WOLI');
            }
        }

    }


    global void finish(Database.BatchableContext bc) {
        System.debug('finish');
        // Set Error Flag
        returnInfo.hasErrors = !returnInfo.errorReturnLst.isEmpty();

        // Splunk Log
        BatchUtilityClass.createBatchLog(
            returnInfo, BC.getJobId(), 'GMBundlerBatch', ACVUtility.currentLineNumber(),
            'GMBundlerBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Work Order Line Item' }
        );
    }
}