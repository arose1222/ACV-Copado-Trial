global class PrescreenServiceHelper {

    @TestVisible
    private static List<CR_Review_Trigger__mdt> mockMetadata;


    public static List<CR_Review_Trigger__mdt> prescreenRuleList {get{
        if(prescreenRuleList == null){
            prescreenRuleList = [SELECT Inspection_Field__c, Prescreen_Reason__c, Trigger_Value__c, Value_Type__c, Class_Name__c, Is_Aux_Reason__c, Is_Advanced_Logic__c, Comma_Seperated_Inspection_Types__c  FROM CR_Review_Trigger__mdt WHERE Active__c = true];
        }
        return prescreenRuleList;
    } set;}

    public static List<PrescreenServiceHelper.InspectionWrapper> prescreensRequired(Map<string, PrescreenServiceHelper.InspectionWrapper> crpIdToWrapperMap){

        Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        Set<String> existingInspectionGUIDSet = new Set<String>();
        Map<String, PrescreenServiceHelper.InspectionWrapper> tempMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        
        for(PrescreenServiceHelper.InspectionWrapper iWrapper : crpIdToWrapperMap.Values()){
            InspectionDefinition idef = iWrapper.idef;
            // not considering prescreen if completedCount is greater than 1 or null
            PrescreenServiceHelper.InspectionWrapper wrapper = new PrescreenServiceHelper.InspectionWrapper(idef, new Set<ReasonWrapper>());
            if (idef.completedCount == null || idef.completedCount <= 1) {
                wrapperMap.put(idef.inspectionID, wrapper);
            }
            else{
                tempMap.put(idef.inspectionId, wrapper);
            }
        }

        //dedupe logic, we remove everything that is already existing and then add it back at the end
        for(Condition_Report_Prescreen__c crp :[SELECT ID, Status__c, Inspection_Id__c FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c in :wrapperMap.keySet()]){

            if (crp.Status__c != 'Closed' ) {
                existingInspectionGUIDSet.add(crp.Inspection_Id__c);
            }
        }
        
        for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
            if(existingInspectionGUIDSet.contains(wrapper.idef.inspectionID)){
                tempMap.put(wrapper.idef.inspectionID, wrapper);
                wrapperMap.remove(wrapper.idef.inspectionID);
            }
        }

        List<CR_Review_Trigger__mdt> crtList;
        if(Test.isRunningTest() && mockMetadata != null){
            crtList = mockMetadata;
        }
        else{
            crtList = prescreenRuleList; 
        }

        List<String> validInspectionTypes = new List<String>();

        for(CR_Review_Trigger__mdt crt : crtList){
            try{
                if(
                !String.isBlank(crt.Inspection_Field__c) && 
                !crt.Is_Advanced_Logic__c
                ){
                    //validInspectionTypes = ;
                    for(String inspectionType : crt.Comma_Seperated_Inspection_Types__c.split(',')){
                        inspectionType = inspectionType.remove(',');
                        inspectionType = inspectionType.trim();
                        inspectionType = inspectionType.toLowerCase();
                        validInspectionTypes.add(inspectionType);
                    }
                        //for each prescreen reason, see if it applies to any idef
                        for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
                            try{

                                if(wrapper.idef.get(crt.Inspection_Field__c) != null ){
                                    for(String type : validInspectionTypes){
                                    }
                                    //check to make sure the inspection type is valid for this review record, then compare the values
                                    if(wrapper.idef.type != null && wrapper.idef.type.type != null && validInspectionTypes.contains(wrapper.idef.type.type.trim().toLowerCase())
                                     && doesValueMatchData(crt.Value_Type__c, crt.Trigger_Value__c, String.valueOf(wrapper.idef.get(crt.Inspection_Field__c)))){
                                        ReasonWrapper rWrapper = new ReasonWrapper(crt.Prescreen_Reason__c, crt.Is_Aux_Reason__c);
                                        wrapper.prescreenReasonWrappers.add(rWrapper);
                                        wrapper.prescreenReasons.add(rWrapper.name);
                                    }
                                }
                                else{
                                    //bad request
                                    PrescreenError e = new PrescreenError();
                                    e.partialException = true;
                                    e.inspectionDefinitionPath = crt.Inspection_Field__c;
                                    e.prescreenReason = crt.Prescreen_Reason__c;
                                    e.status = 400;
                                    wrapper.reasonErrors.add(e);
                                }
                            }
                            catch(Exception e){
                                PrescreenError err = new PrescreenError();
                                err.partialException = true;
                                err.inspectionDefinitionPath = crt.Inspection_Field__c;
                                err.prescreenReason = crt.Prescreen_Reason__c;
                                err.status = 500;
                                wrapper.reasonErrors.add(err);
                            }
                        }
                    
                }
                if(crt.Is_Advanced_Logic__c){
                    
                    handleAdvancedLogic(wrapperMap, crt);
                    
                }
            }
            catch(Exception e){
                for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperMap.values()){
                    PrescreenError err = new PrescreenError();
                    err.partialException = true;
                    err.inspectionDefinitionPath = crt.Inspection_Field__c;
                    err.prescreenReason = crt.Prescreen_Reason__c;
                    err.status = 500;
                    wrapper.reasonErrors.add(err);
                }
            }
        }
        wrapperMap.putAll(tempMap);
        return wrapperMap.values();
    }

    public static void processLog(List<PrescreenServiceInspectionReview.InspectionReviewResults> irrList){
        if(Test.isRunningTest()){
            return;
        }
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.version = 'V1';
        log.location = 'PrescreenServiceHelper: ' + ACVUtility.currentLineNumber();
        log.stackTrace = 'PrescreenServiceHelper: ' + ACVUtility.currentLineNumber();
        log.componentName = 'PrescreenServiceInspectionReview';
        log.sfObject = 'Condition Report Prescreen';
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.INSPECTION_PLATFORM};


        log.logLevel = SplunkHelper.LOGLEVEL.INFO;

        Set<String> insertedIds = new Set<String>();
        List<SplunkHelper.SFErrorRecord> errorRecords = new List<SplunkHelper.SFErrorRecord>();

        for(PrescreenServiceInspectionReview.InspectionReviewResults irr : irrList){
            if(irr.prescreenId != null){
                insertedIds.add(irr.prescreenId);
            }
            else if(irr.status != 200){
                errorRecords.add(new SplunkHelper.SFErrorRecord(irr.originalRequest, irr.message));
            }
        }

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        SplunkHelper.buildAndProcessIntegrationLog(log, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND, errorRecords, insertedIds);
    }

    public static void handleAdvancedLogic(Map<String, PrescreenServiceHelper.InspectionWrapper> wrapperMap, CR_Review_Trigger__mdt crt){

        if(crt.Is_Advanced_Logic__c){

            Type handlerType = Type.forName(crt.Class_Name__c);
            wrapperMap = ((ClassInterface)handlerType.newInstance()).handle(wrapperMap, crt);
            
        }
    }

    public static List<InspectionWrapper> createPrescreen(Map<String, PrescreenServiceHelper.InspectionWrapper> crpIdToWrapperMap, Map<String, InspectionWrapper> wrapperMap, Map<String, Contact> vciMap, Map<String, Account> dealerMap){


        Id queueId = [select Id from Group where  Type = 'Queue' AND NAME = 'SIA Prescreen' LIMIT 1].id;
        

        


        List<Condition_Report_Prescreen__c> crpInsertList = new List<Condition_Report_Prescreen__c>();

        //check to make sure account and contact were able to be found else throw an error for that record
        //if successful, add them to an insertion map
        for(InspectionWrapper iw : wrapperMap.values()){
            try{
                if(!iw.prescreenReasons.isEmpty()){
                    iw.preScreen = new Condition_Report_Prescreen__c(
                        OwnerId = queueId,
                        VCI__c = vciMap.get(iw.idef.inspectorIdentityId).Id,
                        Inspection_Id__c = iw.idef.inspectionID,
                        Account__c = dealerMap.get(String.valueOf(iw.idef.dealershipId)).Id,
                        Prescreen_GUID__c = ACVUtility.NewGuid(),
                        Inspection_Data_Vehicle_ID__c = iw.idef.inspectedVehicle.vehicleId,
                        Inspection_Data_Year__c = iw.idef.inspectedVehicle.year,
                        Inspection_Data_Make__c = iw.idef.inspectedVehicle.make,
                        Inspection_Data_Model__c = iw.idef.inspectedVehicle.model,
                        Inspection_Data_Trim__c = iw.idef.inspectedVehicle.trim,
                        Inspection_Data_VIN__c = iw.idef.inspectedVehicle.vin,
                        Arb_Risk_Categories__c = (iw.siaCategories != null && !iw.siaCategories.isEmpty()) ? JSON.serialize(iw.siaCategories) : null
                    );
                    crpInsertList.add(iw.preScreen);
                }
            }
            catch(Exception e){
                PrescreenError err = new PrescreenError();
                err.partialException = false;
                err.status = 500;
                iw.reasonErrors.add(err);
            }
        }
        system.debug('insert list' + crpInsertList);

        //use saveresults to determine what records were successfully inserted or not
        if(!crpInsertList.isEmpty()){
            Database.SaveResult[] saveResults = Database.insert(crpInsertList, false);
            //save results are parallel to inserted/updated list

            for(integer i = 0; i < saveResults.size(); i++){
                
                Database.SaveResult sr = saveResults[i];
                Condition_Report_Prescreen__c crp = crpInsertList[i];
                if(!sr.isSuccess()){
                    String msg;
                    //Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        msg += err.getStatusCode();
                        msg += '\n' + err.getMessage();
                        msg += '\nRelevant fields: ' + err.getFields() + '\n';
                    }
                    PrescreenError err = new PrescreenError();
                    err.message ='An error occurred during insertion of the record.';
                    err.status = 500;
                    err.partialException = false;
                    wrapperMap.get(crp.Inspection_Id__c).reasonErrors.add(err);
                }
            }
        }

        List<Prescreen_Reason__c> prList = new List<Prescreen_Reason__c>();

        for(InspectionWrapper iw : wrapperMap.values()){
            system.debug('wrapper: ' + iw);
            system.debug('reasons: ' + iw.prescreenReasonWrappers);
            if(iw.preScreen != null && iw.preScreen.Id != null){
                
                crpIdToWrapperMap.put(iw.preScreen.Id, iw);

                for(ReasonWrapper reason : iw.prescreenReasonWrappers){
                    
                    system.debug('Prescreen Reason being inserted: ' + reason);
                    string name = reason.name;
                    prList.add(new Prescreen_Reason__c(Condition_Report_Prescreen__c = iw.preScreen.Id, Name = reason.name));
                }
            }
        }

        //confirm each reason is successfully added with save results, set to partial success if unsuccessful
        if(!prList.isEmpty()){
            Database.SaveResult[] saveResults = Database.insert(prList, false);
            for(integer i = 0; i < saveResults.size(); i++){
                Database.SaveResult sr = saveResults[i];
                Prescreen_Reason__c pr = prList[i];

                if(!sr.isSuccess()){
                    String msg;
                    //Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        msg += err.getStatusCode();
                        msg += '\n' + err.getMessage();
                        msg += '\nRelevant fields: ' + err.getFields() + '\n';
                    }

                    PrescreenError err = new PrescreenError();
                    System.Debug('Error inserting prescreen reason: ' + pr.name);
                    err.message ='A prescreen record was successfully inserted, but an error occurred during insertion of a prescreen reason.';
                    err.status = 500;
                    err.partialException = true;
                    err.prescreenReason = pr.Name;
                    crpIdToWrapperMap.get(pr.Condition_Report_Prescreen__c).reasonErrors.add(err);
                }
            }
        }

        return wrapperMap.values();
    
    }

    private static boolean doesValueMatchData(String dataType, String knownValue, String checkValue){
        if(dataType == 'Integer'){
            if(Integer.valueOf(checkValue) == Integer.valueOf(knownValue)){
                return true;
            }
        }
        else if(dataType == 'String'){
            if(checkValue == knownValue){
                return true;
            }
        }
        else if(dataType == 'Boolean'){
            if(Boolean.valueOf(checkValue) == Boolean.valueOf(knownValue)){
                return true;
            }
        }
        else if(dataType == 'Double'){
            if(Double.valueOf(checkValue) >= Double.valueOf(knownValue)){
                return true;
            }
        }
        return false;
    }

    public static Boolean isOnlyAuxReasons(InspectionWrapper wrapper){
        boolean onlyAux = true;
        
        if(wrapper.prescreenReasonWrappers.size() > 0){
            for(ReasonWrapper reason : wrapper.prescreenReasonWrappers){
                if(reason.isAux == false){
                    onlyAux = false;
                    break;
                }
        	}
        }
        else{
            onlyAux = false;
        }
        
        
        return onlyAux;
    }

    global class ReasonWrapper{
        global string name;
        global boolean isAux;
        global ReasonWrapper(string name, boolean isAux){
            this.name = name;
            this.isAux = isAux;
        }
    }

    //need virtual lift url
    global class InspectionWrapper{
        global InspectionDefinition idef;
        global Set<String> prescreenReasons;
        global Set<ReasonWrapper> prescreenReasonWrappers;
        global Condition_Report_Prescreen__c preScreen;
        global String virtualLiftURL;
        global list<PrescreenError> reasonErrors;
        global SiaCrEvaluator.SiaCategory[] siaCategories;
		global inspectionWrapper(InspectionDefinition idef, Set<String> reasons){
            this.idef = idef;
            this.preScreen = new Condition_Report_Prescreen__c();
            this.reasonErrors = new List<PrescreenError>();
            this.siaCategories = new List<SiaCrEvaluator.SiaCategory>();
            this.prescreenReasons = new Set<string>();
            this.prescreenReasons.addAll(reasons);
            this.prescreenReasonWrappers = new Set<ReasonWrapper>();
            for(String wrapper : reasons){
                this.prescreenReasonWrappers.add(new ReasonWrapper(wrapper, false));
            }
        }
        global inspectionWrapper(){
            
        }
        
        global inspectionWrapper(InspectionDefinition idef, Set<ReasonWrapper> reasons){
            this.idef = idef;
            this.preScreen = new Condition_Report_Prescreen__c();
            this.reasonErrors = new List<PrescreenError>();
            this.siaCategories = new List<SiaCrEvaluator.SiaCategory>();
            this.prescreenReasonWrappers = new Set<ReasonWrapper>();
            this.prescreenReasonWrappers.addAll(reasons);
            this.prescreenReasons = new Set<String>();
            for(ReasonWrapper wrapper : reasons){
                this.prescreenReasons.add(wrapper.name);
            }
        }
        global inspectionWrapper(InspectionDefinition idef, Set<ReasonWrapper> reasons, Integer statusCode, String message){
            this.idef = idef;
            this.preScreen = new Condition_Report_Prescreen__c();
            this.reasonErrors = new List<PrescreenError>();
            this.siaCategories = new List<SiaCrEvaluator.SiaCategory>();
            this.prescreenReasonWrappers = new Set<ReasonWrapper>();
            this.prescreenReasonWrappers.addAll(reasons);
            this.prescreenReasons = new Set<String>();
            for(ReasonWrapper wrapper : reasons){
                this.prescreenReasons.add(wrapper.name);
            }
        }
    }

    global class PrescreenError{
        global string prescreenReason;
        global string inspectionDefinitionPath;
        global integer status;
        global boolean partialException;
        global string message;
    }

}