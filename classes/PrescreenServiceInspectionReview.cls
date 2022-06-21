@RestResource(urlMapping='/prescreenService/inspectionReview')
global class PrescreenServiceInspectionReview {
    

    @httpPost
    global static InspectionReviewResultsWrapper inspectionReview(List<InspectionDefinition> inspectionList){
            
            List<InspectionReviewResults> returnResults = new List<InspectionReviewResults>();
            Map<String, PrescreenServiceHelper.InspectionWrapper> validPrescreens = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
            List<PrescreenServiceHelper.InspectionWrapper> wrapperList = new List<PrescreenServiceHelper.InspectionWrapper>();


            wrapperList = PrescreenServiceHelper.prescreensRequired(inspectionList);

            for(PrescreenServiceHelper.InspectionWrapper wrapper : wrapperList){
                if(!wrapper.prescreenReasons.isEmpty()){
                    //wrapper has valid prescreen reason and needs prescreen creation
                    validPrescreens.put(wrapper.idef.inspectionID, wrapper);
                }
                else {
                    //no prescreen is needed for this
                    returnResults.add(new InspectionReviewResults(wrapper));
                }
            }

            //This call to the Event class is to signal that we have auto Approved the inspections
            if(!returnResults.isEmpty()){
                List<InspectionDefinition> autoApprovedInspections = new List<InspectionDefinition>();
                for(InspectionReviewResults irr : returnResults){
                    autoApprovedInspections.add(irr.originalRequest);
                }
                PrescreenChangeEvent.prescreenAutoApproveEvent(autoApprovedInspections);
            }



            if(!validPrescreens.isEmpty()){
                for(PrescreenServiceHelper.InspectionWrapper iw : PrescreenServiceHelper.createPrescreen(validPrescreens)){
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
                        message = 'The inspection could not be processed due to an invalid or missing parameter.';
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