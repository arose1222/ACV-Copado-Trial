@RestResource(urlMapping='/prescreenService/inspectionReview')
global class PrescreenServiceInspectionReview {

    @httpPost
    global static InspectionReviewResultsWrapper inspectionReview(List<InspectionDefinition> inspectionList){
        //check for valid inspector and account at start

        //load inspection definitions into a wrapper class
        Map<String, PrescreenServiceHelper.InspectionWrapper> crpIdToWrapperMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        for(InspectionDefinition idef : inspectionList){
            PrescreenServiceHelper.InspectionWrapper iw = new PrescreenServiceHelper.InspectionWrapper(idef, new Set<PrescreenServiceHelper.ReasonWrapper>());
            crpIdToWrapperMap.Put(idef.inspectionID, iw);
            if(iw.preScreen != null && iw.preScreen.Id != null){
                crpIdToWrapperMap.put(iw.preScreen.Id, iw);
            }
        }
        //put inspection inspectors and dealers into lists
        
        List<String> inspectorIdList = new List<String>();
        List<String> dealerIdList = new List<String>();

        for(PrescreenServiceHelper.InspectionWrapper iw : crpIdToWrapperMap.values()){
            if(iw.idef.inspectorIdentityId != null){
                inspectorIdList.add(iw.idef.inspectorIdentityId);
            }
            if(iw.idef.dealershipId != null){
                dealerIdList.add(String.valueOf(iw.idef.dealershipId));
            }
        }
        
        //query for the associated inspectors and dealerships
        Map<String, Contact> vciMap = new Map<String,Contact>();
        Map<String, Account> dealerMap = new Map<String,Account>();


        for(Contact c : [SELECT Id, Identity_Id__c FROM Contact WHERE Identity_Id__c in :inspectorIdList]){
            vciMap.put(c.Identity_Id__c, c);
        }

        for(Account a :[SELECT Id, Dealership_Id__c, Sales_Region_Formula__c FROM Account WHERE Dealership_Id__c in : dealerIdList]){
            dealerMap.put(a.Dealership_Id__c, a);
        }

        List<InspectionReviewResults> returnResults = new List<InspectionReviewResults>();
        Map<String, PrescreenServiceHelper.InspectionWrapper> validPrescreens = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        List<PrescreenServiceHelper.InspectionWrapper> wrapperList = new List<PrescreenServiceHelper.InspectionWrapper>();

        //if the inspector or dealership is missing, include an error
        for(PrescreenServiceHelper.InspectionWrapper iw : crpIdToWrapperMap.values()){
            if(!vciMap.containsKey(iw.idef.inspectorIdentityId)){

                PrescreenServiceHelper.PrescreenError e = new PrescreenServiceHelper.PrescreenError();
                e.partialException = false;
                e.inspectionDefinitionPath = 'inspectorIdentityId';
                e.status = 400;
                iw.reasonErrors.add(e);

                crpIdToWrapperMap.remove(iw.idef.inspectionID);
                returnResults.add(new InspectionReviewResults(iw));

            }
            else if(!dealerMap.containsKey(String.valueOf(iw.idef.dealershipId))){
                PrescreenServiceHelper.PrescreenError e = new PrescreenServiceHelper.PrescreenError();
                e.partialException = false;
                e.inspectionDefinitionPath = 'dealershipId';
                e.status = 400;
                iw.reasonErrors.add(e);


                crpIdToWrapperMap.remove(iw.idef.inspectionID);
                returnResults.add(new InspectionReviewResults(iw));
            }
            if(dealerMap.containsKey(String.valueOf(iw.idef.dealershipId)) && dealerMap.get(String.valueOf(iw.idef.dealershipId)).Sales_Region_Formula__c != null){
                iw.idef.region = dealerMap.get(String.valueOf(iw.idef.dealershipId)).Sales_Region_Formula__c;
            }
            else{
                iw.idef.region = '';
            }
        }





            wrapperList = PrescreenServiceHelper.prescreensRequired(crpIdToWrapperMap);
        	List<InspectionDefinition> autoApprovedInspections = new List<InspectionDefinition>();

            for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperList){
                if(!wrapper.prescreenReasons.isEmpty()){
                    //wrapper has valid prescreen reason and needs prescreen creation
                    validPrescreens.put(wrapper.idef.inspectionID, wrapper);
                    if(PrescreenServiceHelper.isOnlyAuxReasons(wrapper)){
                    	autoApprovedInspections.add(wrapper.idef);
                    }
                }
                else {
                    //no prescreen is needed for this
                    returnResults.add(new InspectionReviewResults(wrapper));
                    autoApprovedInspections.add(wrapper.idef);
                }
            }
        
        	

            //This call to the Event class is to signal that we have auto Approved the inspections
            if(!autoApprovedInspections.isEmpty()){
                PrescreenChangeEvent.prescreenAutoApproveEvent(autoApprovedInspections);
            }



            if(!validPrescreens.isEmpty()){
                for(PrescreenServiceHelper.InspectionWrapper iw : PrescreenServiceHelper.createPrescreen(crpIdToWrapperMap, validPrescreens, vciMap, dealerMap)){
                    returnResults.add(new InspectionReviewResults(iw));
                }
            }

            PrescreenServiceHelper.processLog(returnResults);


        return new InspectionReviewResultsWrapper(returnResults);
    }



    //look at offersapi message to status map
    global class InspectionReviewResults{
        public Integer status;
        public String message;
        public InspectionDefinition originalRequest;
        public boolean prescreenGenerated;
        public string prescreenId;

        global InspectionReviewResults(){
            this.originalRequest = new InspectionDefinition();
            this.prescreenGenerated = false;
            this.prescreenId = '';
        }

        global InspectionReviewResults(PrescreenServiceHelper.InspectionWrapper wrapper){

            originalRequest = wrapper.idef;
            this.prescreenGenerated = false;

            if(wrapper.preScreen != null && wrapper.preScreen.Id != null){
                //success case, check for missed reason checks and insertions

                prescreenGenerated = true;
                prescreenId = wrapper.preScreen.Id;
                message = 'Prescreen successfully created.';

                if(wrapper.reasonErrors.isEmpty()){
                    status = 200;
                }
                else{
                    status = 207;
                    for(PrescreenServiceHelper.PrescreenError e : wrapper.reasonErrors){
                        if(e.inspectionDefinitionPath != null && e.prescreenReason != null){
                            message += ' Could not check prescreen reason ' + e.prescreenReason;
                            if(e.status == 400){
                                message += ' due to missing parameter ' + e.inspectionDefinitionPath + '.';
                            }
                            else{
                                message += ' due to internal error related to parameter ' + e.inspectionDefinitionPath + '.';
                            } 
                        }
                        else if(e.prescreenReason != null){
                            message += ' Could not insert prescreen reason ' + e.prescreenReason + ' with prescreen.';
                        }
                    }
                }
            }
            else if(!wrapper.reasonErrors.isEmpty()){
                for(PrescreenServiceHelper.PrescreenError e : wrapper.reasonErrors){
                    system.debug(e);
                    this.status = e.status;
                    if(e.message != null){
                        message = e.message;
                    }
                    else if(e.status == 400){
                        message = 'The inspection could not be processed due to invalid or missing parameter';
                        if(e.inspectionDefinitionPath != null){
                            message += ': ' + e.inspectionDefinitionPath;
                        }
                    }
                    else if(e.status == 500){
                        message = 'The inspection could not be processed due to an internal error.';
                    }
                }
            }
            else{
                status = 200;
                message = 'Inspection processed without needing to insert prescreen.';
            }
        }

        global InspectionReviewResults(InspectionDefinition inspect){
            this.originalRequest = inspect;
            this.prescreenGenerated = false;
            this.prescreenId = '';
        }

        global InspectionReviewResults(InspectionDefinition inspect, String generatedId){
            this.originalRequest = inspect;
            this.prescreenGenerated = true;
            this.prescreenId = generatedId;
        }

    }

    global class InspectionReviewResultsWrapper{
        public List<InspectionReviewResults> items;
        public boolean errors;

        global InspectionReviewResultsWrapper(){
            this.errors = false;
            this.items = new List<InspectionReviewResults>();
        }

        global InspectionReviewResultsWrapper(List<InspectionReviewResults> results){
            this.items = results;
            this.errors = containsErrors(this.items);
        }

        private boolean containsErrors(List<InspectionReviewResults> irrList){
            for(InspectionReviewResults irr : irrList){
                if(irr.status != 200){
                    return true;
                }
            }
            return false;
        }
    }
}