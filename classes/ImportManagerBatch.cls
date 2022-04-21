global class ImportManagerBatch implements Database.Batchable<WorkObject>, Database.Stateful {

    List<WorkObject> workObjectList = new List<WorkObject>();
    Map<WorkObject,String> workWithBadAddressMap = new Map<WorkObject,String>();
    Map<WorkObject,String> workWithBadStartDateMap = new Map<WorkObject,String>();
    Map<WorkObject,String> workWithBadDueDateMap = new Map<WorkObject,String>();

    List<String> successRowValues = new List<String>();
    List<String> failureRowValues = new List<String>();

    Boolean SHOWHIDDENFIELDS;
    Id IMPORTJOBID;
    // WorkType WORKTYPE;

    Boolean isProcessingComplete = false;


    global ImportManagerBatch(List<WorkObject> workObjectList, Map<WorkObject,String> workWithBadAddressMap, Map<WorkObject,String> workWithBadStartDateMap, Map<WorkObject,String> workWithBadDueDateMap, Id importJobId, Boolean showHiddenFields){

        this.workObjectList = workObjectList;
        this.workWithBadAddressMap = workWithBadAddressMap;
        this.workWithBadStartDateMap = workWithBadStartDateMap;
        this.workWithBadDueDateMap = workWithBadDueDateMap;
        this.IMPORTJOBID = importJobId;
        this.SHOWHIDDENFIELDS = showHiddenFields;
        // this.WORKTYPE = new WorkType(Work_Type_Unique_ID__c = workObjectList[0]?.workDetail.type);
    }


    global Iterable<WorkObject> start(Database.BatchableContext bc){

        Import_Manager_Job__c ImportJob = new Import_Manager_Job__c();
        ImportJob.Id = IMPORTJOBID;
        ImportJob.Job_Id__c = bc.getJobId();
        ImportJob.Import_Status__c = 'In Progress';
        update ImportJob;

        return this.workObjectList;
    }


    global void execute(Database.BatchableContext bc, List<WorkObject> scope){

        Boolean workProcessFailure = false;
        Exception workProcessFailureDetails;

        Map<String,String> uuidErrorMessageMap = new Map<String,String>();

        try{
            //Group and save work
            for(FSLWorkProcess.ProcessedWorkStruct pws : FSLWorkProcess.commitWork( FSLWorkProcess.groupWork( scope ) )){
                if(pws.hasErrors){
                    uuidErrorMessageMap.put(pws.uuid, String.join(pws.errorMessageLst, ', '));
                }
            }
        } catch(exception e){
            workProcessFailure = true;
            workProcessFailureDetails = e;
        }


        for(WorkObject wo : (List<WorkObject>) scope){

            String rowStr = generateRowStr(wo);

            //If there was an error during processing of this batch, set error message and add to error file.
            System.debug('MGF ImportManagerBatch execute wo.workDetail.dueDate='+wo.workDetail.dueDate+' wo.workDetail.earliestStartDate='+wo.workDetail.earliestStartDate);
            if(workProcessFailure){
                String errorMsg = 'This batch encountered an unexpected error. Please open a Request and Inquiries Ticket in Salesforce and provide the CSV and the following information: ' + workProcessFailureDetails.getMessage() + ' ' + workProcessFailureDetails.getStackTraceString();
                rowStr += ',"' + errorMsg + '"';
                failureRowValues.add(rowStr);
            //If Address, Vin, or DealerId are missing, set error message and add to error file.
            } else if(String.isBlank(wo.vehicle.vin) || String.isBlank(wo.workDetail.dealerId) || String.isBlank(wo.Address.toString())){
                String errorMsg = 'Address, Vin, and Dealership Id are required.';
                rowStr += ',"' + errorMsg + '"';
                failureRowValues.add(rowStr);
            //If any processed records were returned with failures, set error message to the returned error message and add to error file.
            } else if(uuidErrorMessageMap.containsKey(wo.uuid)){
                String errorMsg = uuidErrorMessageMap.get(wo.uuid);
                rowStr += ',"' + errorMsg + '"';
                failureRowValues.add(rowStr);
            //Add to success file
            } else {
                successRowValues.add(rowStr);
            }
        }

        //Update the Import Manager Job record in salesforce with success and failure values
        updateImportJobRecord(successRowValues.size(), failureRowValues.size());
    }


    global void finish(Database.BatchableContext bc) {
        isProcessingComplete = true;

        //Add rows that had bad addresses to the failure file, with an error message
        for(WorkObject wo : workWithBadAddressMap.keySet()){
            String rowStr = generateRowStr(wo);
            rowStr += ',' + 'Invalid Address Format';
            failureRowValues.add(rowStr);
        }

        //Add rows that had bad Start dates to the failure file, with an error message
        for(WorkObject wo : workWithBadStartDateMap.keySet()){
            String rowStr = generateRowStr(wo);
            rowStr += ',' + 'Invalid Start Date Format. Accepted formats are: mm/dd/yyyy or yyyy-mm-dd.';
            failureRowValues.add(rowStr);
        }

        //Add rows that had bad due dates to the failure file, with an error message
        for(WorkObject wo : workWithBadDueDateMap.keySet()){
            String rowStr = generateRowStr(wo);
            rowStr += ',' + 'Invalid Due Date Format. Accepted formats are: mm/dd/yyyy or yyyy-mm-dd.';
            failureRowValues.add(rowStr);
        }

        Integer numberOfSuccesses = successRowValues.size();
        Integer numberOfFailures = failureRowValues.size();

        //Generate the success and error csv's and insert them as attachments to the Import Manager Job record
        List<Attachment> attachmentInsertList = new List<Attachment>();

        if(numberOfSuccesses > 0){

            attachmentInsertList.add(generateCSVAttachment(successRowValues, true));

        }

        if(numberOfFailures > 0){

            attachmentInsertList.add(generateCSVAttachment(failureRowValues, false));

        }


        insert attachmentInsertList;

        //Update the Import Manager Job record in salesforce with final success and failure values
        updateImportJobRecord(numberOfSuccesses, numberOfFailures);


    }

    public Attachment generateCSVAttachment(List<String> csvContent, Boolean isSuccess){

        String columnHeader = 'Stock Number,Address,Vin,Year,Make,Model,Color,Title Status,Title with Dealer?,Dealer Contact,Residential,Add to Run List,Floor Price,Date Inspected,Transport Status,Inspection Notes,Dealer Name,Dealer ID';

        if(SHOWHIDDENFIELDS){
            columnHeader += ',Earliest Start Date,Due Date,UUID';
        }

        if(!isSuccess){
            columnHeader += ',Error';
        }

        csvContent.add(0, columnHeader);

        Attachment attachmentRec = new Attachment();
        attachmentRec.Body = Blob.valueOf(String.join(csvContent,'\n'));
        attachmentRec.Name = isSuccess ? 'success_' + IMPORTJOBID + '.csv' : 'error_' + IMPORTJOBID + '.csv';
        attachmentRec.ParentId = IMPORTJOBID;
        return attachmentRec;
    }


    public void updateImportJobRecord(Integer numberOfSuccesses, Integer numberOfFailures){

        Import_Manager_Job__c ImportJob = new Import_Manager_Job__c();
        ImportJob.Id = IMPORTJOBID;
        ImportJob.Number_of_Successes__c = numberOfSuccesses;
        ImportJob.Number_of_Failures__c = numberOfFailures;
        if(isProcessingComplete){
            ImportJob.Import_Status__c = 'Complete';
            ImportJob.Result__c = setResult(numberOfSuccesses, numberOfFailures);
        }

        update ImportJob;
    }

    public String setResult(Integer numberOfSuccesses, Integer numberOfFailures){
        if(numberOfSuccesses != 0 && numberOfFailures != 0){return 'Partial Success';}
        else if(numberOfSuccesses != 0 && numberOfFailures == 0){return 'Success';}
        else return 'Failure';
    }

    public String generateRowStr(WorkObject wo){
        String stockNumber = wo.workDetail.stockNumber;
        //String address = isProcessingComplete ? workWithBadAddressMap.get(wo) : wo.Address.toString();
        String vin = wo.vehicle.vin;
        String year = wo.vehicle.year;
        String make = wo.vehicle.make;
        String model = wo.vehicle.model;
        String color = wo.vehicle.color;
        String titleStatus = wo.workDetail.titleStatus;
        String isTitleWithDealer = wo.workDetail.isTitleWithDealer;
        String dealerContactName = wo.workDetail.dealerContactName;
        String isResidential = wo.workDetail.isResidential;
        String addToRunList = wo.workDetail.addToRunList;
        String floorPrice = wo.workDetail.floorPrice;
        String dateInspected = wo.workDetail.dateInspected;
        String transportStatus = wo.workDetail.transportStatus;
        String inspectionNotes = wo.workDetail.inspectionNotes;
        String dealershipName = wo.workDetail.dealershipName;
        String dealerId = wo.workDetail.dealerId;

        String address;
        if(isProcessingComplete) {
            if(workWithBadAddressMap.containsKey(wo)) {
                address = workWithBadAddressMap.get(wo);
            }
            else {
                address = wo.Address.toString();
            }
        }
        else {
            address = wo.Address.toString();
        }

        String rowStr = stockNumber + ',"' + address + '",' + vin + ',' + year + ','+ make + ',' + model + ',' + color + ',' + titleStatus + ',' + isTitleWithDealer + ',' + dealerContactName + ',' + isResidential + ',' + addToRunList + ',' + floorPrice + ',' + dateInspected + ',' + transportStatus + ',' + inspectionNotes + ',"' + dealershipName + '",' + dealerId;

        if(SHOWHIDDENFIELDS){
            String earliestStartDate;
            if(isProcessingComplete) {
                if(workWithBadStartDateMap.containsKey(wo)) {
                    earliestStartDate = workWithBadStartDateMap.get(wo);
                }
                else {
                    earliestStartDate = wo.workDetail.earliestStartDate;
                }
            }
            else {
                earliestStartDate = wo.workDetail.earliestStartDate;
            }

            String dueDate;
            if(isProcessingComplete) {
                if(workWithBadDueDateMap.containsKey(wo)) {
                    dueDate = workWithBadDueDateMap.get(wo);
                }
                else {
                    dueDate = wo.workDetail.dueDate;
                }
            }
            else {
                dueDate = wo.workDetail.dueDate;
            }

            rowStr += ',' + dueDate + ',' + dueDate + ',' + wo.uuid;
        }
        workWithBadAddressMap.remove(wo);
        workWithBadStartDateMap.remove(wo);
        workWithBadDueDateMap.remove(wo);
        return rowStr;
    }

}