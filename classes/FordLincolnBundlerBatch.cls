//runs in the evening after adjustcpotimelinebatch 10pm before midnight

global class FordLincolnBundlerBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.AllowsCallouts {

    private static Date EARLIEST_START_DATE {
        get {
            if ( EARLIEST_START_DATE == null ) {
                Salesforce_Setting__mdt defaultRange = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Extend_CPO_Start_Date' LIMIT 1 ];
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
        query =  'SELECT Id, EarliestStartTime, DueDate, Address, WorkType.Work_Type_Unique_ID__c, Work_Order__c, Bundled__c ';
        query += 'FROM ServiceAppointment ';
        query += 'WHERE WorkType.Work_Type_Unique_ID__c = \'cpofr\' ';
        query +=    'AND Status IN (\'New\', \'Scheduled\') ';
        query +=    'AND EarliestStartTime >= :EARLIEST_START_DATE ';
        query +=    'AND work_order__r.lineitemcount = 1 ';
         // return
        return Database.getQueryLocator(query);
    }

    public override void executeScheduledLogic() {
        FordLincolnBundlerBatch FordLincolnBundlerBatch = new FordLincolnBundlerBatch();
        Database.executeBatch(FordLincolnBundlerBatch, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        System.debug('Execute');

        Map<String,ServiceAppointment> cpofrAddressKeySAMap = new Map<String,ServiceAppointment>();
        Map<String,WorkOrderLineItem> cpolncAddressKeyWOLIMap = new Map<String,WorkOrderLineItem>();

        Map<String, WorkOrderLineItem> AddressKeyWoliDeleteMap = new Map<String, WorkOrderLineItem>();
        Map<String, WorkOrderLineItem> AddressKeyWoliInsertMap = new Map<String, WorkOrderLineItem>();
        Map<String, Id> AddressKeyWorkOrderDeleteMap = new Map<String, Id>();
        Map<String, ServiceAppointment> AddressKeySaUpdateMap = new Map<String, ServiceAppointment>();
        Map<String, Id> AddressKeyWoIdUpdateMap = new Map<String, Id>();
        List<String> streetList = new List<String>();

        for(ServiceAppointment sa : scope){
            cpofrAddressKeySAMap.put(createAddressKey(sa.address), sa);
            streetList.add(sa.Address.getStreet());
        }

        List<ServiceAppointment> cpolncSAList = [SELECT Id, EarliestStartTime, DueDate, Work_Order__c, Address
                                                FROM ServiceAppointment
                                                WHERE Street IN: streetList
                                                    AND WorkType.Work_Type_Unique_ID__c = 'cpolnc'
                                                    AND Status IN ('New', 'Scheduled')
                                                    AND EarliestStartTime >= :EARLIEST_START_DATE
                                                    AND work_order__r.lineitemcount = 1];


        List<Id> workOrderIdList = new List<Id>();
        for(ServiceAppointment cpolncSA : cpolncSAList){
            String addressKey = createAddressKey(cpolncSA.Address);

            if(!cpofrAddressKeySAMap.containsKey(addressKey)){continue;}

            if(
                cpofrAddressKeySAMap.get(addressKey).Address.getStreet() == cpolncSA.Address.getStreet() &&
                cpofrAddressKeySAMap.get(addressKey).Address.getCity() == cpolncSA.Address.getCity() &&
                cpofrAddressKeySAMap.get(addressKey).Address.getState() == cpolncSA.Address.getState() &&
                cpofrAddressKeySAMap.get(addressKey).Address.getPostalCode() == cpolncSA.Address.getPostalCode()
            ){
                workOrderIdList.add(cpolncSA.Work_Order__c);
            }
        }

        //Retrieve all significant fields from WOLI for cloning
        for(WorkOrderLineItem woli : [SELECT Id, Stock_Number__c, Origin__c, Address, Street, City, State, PostalCode, Country, vin__c, year__c, make__c, model__c, color__c, Reserve_Price__c,
        Title_Status__c, Title_with_Dealer__c, Dealer_Contact__c, Residential__c, Add_To_Run_List__c, Floor_Price__c, Date_Inspected__c, WorkTypeId, WorkType.Name, WorkType.Work_Type_Unique_ID__c,
        External_Record_guid__c, WorkOrder.Account.Dealership_ID__c, WorkOrder.Origin__c, Due_Date__c, Status, Transport_Status__c, Description, Dealership_Name__c, Earliest_Start_Date__c,
        External_Invoice_Id__c, WorkOrderId, Inspection_Location__c, Series__c, External_Assignment_Id__c, Inspection_Id__c, Cloned_for_Grouping__c,
        Is_In_Jeopardy__c, Jeopardy_State__c, Lesse_Name__c, Open_Date__c, Maturity_Date__c, Contact_Name__c, Contact_Phone_Number__c, Contact_Mobile_Number__c, Contact_Email__c,
        Customer_Email__c, Driving_Directions__c, Is_Opportunity__c, Exclude_from_Optimization__c, WorkOrder.Street, WorkOrder.City, WorkOrder.State, WorkOrder.PostalCode, WorkOrder.Country, WorkOrder.Address, External_Link__c, External_Link_Code__c
        FROM WorkOrderLineItem WHERE WorkOrderId IN :workOrderIdList AND WorkType.Work_Type_Unique_ID__c = 'cpolnc']){
            cpolncAddressKeyWOLIMap.put(createAddressKey(woli.WorkOrder.Address), woli);
        }

        for(ServiceAppointment cpolncSA : cpolncSAList){
            String key = createAddressKey(cpolncSA.Address);

            if(!cpolncAddressKeyWOLIMap.containsKey(key)){continue;}

            ServiceAppointment cpofrSA = cpofrAddressKeySAMap.get(key);

            Datetime earliestCombinedStartDate = cpofrSA.EarliestStartTime >= cpolncSA.EarliestStartTime ? cpofrSA.EarliestStartTime : cpolncSA.EarliestStartTime;
            Datetime latestCombinedDueDate = cpofrSA.DueDate <= cpolncSA.DueDate ? cpofrSA.DueDate : cpolncSA.DueDate;

            if(earliestCombinedStartDate.date().daysBetween(latestCombinedDueDate.date()) >= 7){

                //Clone the WOLI and assign the work order
                WorkOrderLineItem cpolncOriginalWOLI = cpolncAddressKeyWOLIMap.get(key);
                WorkOrderLineItem cpolncClonedWOLI = cpolncOriginalWOLI.clone(false,false,false,false);
                cpolncClonedWOLI.workorderId = cpofrSA.Work_Order__c;
                cpolncClonedWOLI.Cloned_for_Grouping__c = true;

                //Build data maps for processing
                AddressKeyWoIdUpdateMap.put(key, cpofrSA.Work_Order__c);
                AddressKeyWoliDeleteMap.put(key, cpolncOriginalWOLI);
                AddressKeyWoliInsertMap.put(key, cpolncClonedWOLI);
                AddressKeyWorkOrderDeleteMap.put(key, cpolncSA.Work_Order__c);

                cpofrSA.EarliestStartTime = earliestCombinedStartDate;
                cpofrSA.DueDate = latestCombinedDueDate;
                cpofrSA.Bundled__c = true;

                AddressKeySaUpdateMap.put(key, cpofrSA);

            }
        }


        //Delete the WOLI prior to inserting its clone
        //If failure, log and remove from processing
        List<Database.DeleteResult> deleteResultList = Database.delete(AddressKeyWoliDeleteMap.values(), FALSE);
        for( Integer i=0; i< deleteResultList.size(); i++ ){
            Database.DeleteResult deleteResult = deleteResultList[i];
            if( !deleteResult.isSuccess() ){
                WorkOrderLineItem woliRec = AddressKeyWoliDeleteMap.values()[i];
                String addressKey = createAddressKey(woliRec.Address);

                returnInfo.errorReturnLst.add(woliRec.Id);
                returnInfo.errorMessageLst.add('Failure to Delete WOLI');

                AddressKeyWoliInsertMap.remove(addressKey);
                AddressKeyWorkOrderDeleteMap.remove(addressKey);
                AddressKeySaUpdateMap.remove(addressKey);
                AddressKeyWoIdUpdateMap.remove(addressKey);
            }
        }


        //Insert the cloned woli list
        //If failure, log and remove from processing
            //AND undelete the deleted WOLI
        List<WorkOrderLineItem> woliUndeleteList = new List<WorkOrderLineItem>();

        List<Database.SaveResult> insertResultList = Database.insert( AddressKeyWoliInsertMap.values(), FALSE );
        for ( Integer i = 0; i < insertResultList.size(); i++ ) {
            Database.SaveResult insertResult = insertResultList[i];
            if ( !insertResult.isSuccess() ) {
                WorkOrderLineItem woliRec = AddressKeyWoliInsertMap.values()[i];
                String addressKey = createAddressKey(woliRec.Address);

                returnInfo.errorReturnLst.add(woliRec.Id);
                returnInfo.errorMessageLst.add('Failure to insert new WOLI');

                AddressKeyWorkOrderDeleteMap.remove(addressKey);
                AddressKeySaUpdateMap.remove(addressKey);
                AddressKeyWoIdUpdateMap.remove(addressKey);

                woliUndeleteList.add(AddressKeyWoliDeleteMap.get(addressKey));
            }
        }

        //Update the SA list
        //If failure, log and remove from processing
            //AND undelete the deleted WOLI
            //AND delete the inserted WOLI
        List<WorkOrderLineItem> woliDeleteList = new List<WorkOrderLineItem>();

        Database.SaveResult[] updateResultList = Database.update(AddressKeySaUpdateMap.values(), false);
        for ( Integer i = 0; i < updateResultList.size(); i++ ) {
            Database.SaveResult updateResult = updateResultList[i];
            ServiceAppointment saRec = AddressKeySaUpdateMap.values()[i];
            String addressKey = createAddressKey(saRec.Address);

            if ( !updateResult.isSuccess() ) {

                returnInfo.errorReturnLst.add(saRec.Id);
                returnInfo.errorMessageLst.add('Failure to Update Service Appointment');

                AddressKeyWorkOrderDeleteMap.remove(addressKey);
                AddressKeyWoIdUpdateMap.remove(addressKey);

                woliUndeleteList.add(AddressKeyWoliDeleteMap.get(addressKey));
                woliDeleteList.add(AddressKeyWoliInsertMap.get(addressKey));

            } else {
                returnInfo.successfulReturnSet.add( addressKey );
            }
        }


        //Non-critical: Do not rollback with failure

        //Update the the work order
        List<WorkOrder> woToUpdateList = new List<WorkOrder>();
        for(WorkOrder wo : [SELECT Id, Special_Instructions__c FROM WorkOrder WHERE Id IN :AddressKeyWoIdUpdateMap.values()]){
            wo.Special_Instructions__c = 'This is a Ford and a Lincoln assignment.';
            woToUpdateList.add(wo);
        }
        Database.SaveResult[] updateWOResultList = Database.update(woToUpdateList, false);


        //Delete the Work Orders that had their WOLI's removed
        List<WorkOrder> woDeleteList = [SELECT Id FROM WorkOrder WHERE Id IN :AddressKeyWorkOrderDeleteMap.values()];
        List<Database.DeleteResult> woDeleteResultList = Database.delete(woDeleteList, false);


        //Rollback steps:

        //Undelete the deleted woli's
        List<Database.UndeleteResult> undeleteResultList = Database.undelete(woliUndeleteList, false);
        for ( Integer i = 0; i < undeleteResultList.size(); i++ ) {
            Database.UndeleteResult undeleteResult = undeleteResultList[i];
            WorkOrderLineItem woliRec = woliUndeleteList[i];
            if ( !undeleteResult.isSuccess() ) {
                returnInfo.errorReturnLst.add(woliRec.Id);
                returnInfo.errorMessageLst.add('Rollback: Failure to Undelete previously deleted WOLI');
            }
        }

        //Delete the inserted woli's
        List<Database.DeleteResult> woliDeleteResultList = Database.delete(woliDeleteList, false);
        for ( Integer i = 0; i < woliDeleteResultList.size(); i++ ) {
            Database.DeleteResult woliDeleteResult = woliDeleteResultList[i];
            WorkOrderLineItem woliRec = woliDeleteList[i];
            if ( !woliDeleteResult.isSuccess() ) {
                returnInfo.errorReturnLst.add(woliRec.Id);
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
            returnInfo, BC.getJobId(), 'FordLincolnBundlerBatch', ACVUtility.currentLineNumber(),
            'FordLincolnBundlerBatch:' + ACVUtility.currentLineNumber(), new Set<String>{ 'Work Order Line Item' }
        );
    }

    public String createAddressKey(Address address){
        return(address.getStreet() + address.getCity() + address.getPostalCode());
    }

}