@RestResource(urlMapping='/PrescreenService/arbGuardRequest')
global class PrescreenServiceMarkForArbGuardPrescreen {
    
    private static final String ARB_GUARD_PRESCREEN_NAME = 'Arb Guard';
    private static final String SPECIALIZED_QUEUE = 'Specialized Prescreen';
    private static final String WARNING_STATUS = 'Warning';
    private static final String OK_STATUS = 'OK';
    private static final String REASONS_ALREADY_EXIST_MESSAGE = 'Arb Guard Prescreen Reason already exists for this request';
    private static final String REASON_ADDED_TO_EXISTING_PRESCREEN_MESSAGE = 'Arb Guard Reason Added to Existing Prescreen: ';
    private static final String REASON_NOT_ADDED_DUE_NO_RISK_CATEGORIES_MESSAGE = 'Arb Guard Reason not added, No Risk Categories: ';
    private static final String PRESCREEN_IS_NOT_IN_NEW_STATUS_MESSAGE = 'Prescreen not in New Status - Added Reason and Risk Categories';
    private static final String PRESCREEN_SENT_TO_SPECIALIZED_QUEUE = 'Prescreen sent to Specialized Queue';
    private static final String PRESCREEN_SENT_TO_SPECIALIZED_QUEUE_AND_RE_OPENED = 'Prescreen sent to Specialized Queue with Status: New';
    private static final String RISK_CATEGORIES_ADDED_TO_CONDITION_REPORT_MESSAGE = 'Risk Categories Added to Condition Report: ';
    private static final String CONDITION_REPORT_SHELL_CREATED_MESSAGE = 'Condition Report Shell Created For SA ID: ';
    private static final String PRESCREEN_STATUS_NEW = 'New';
    private static final String PRESCREEN_STATUS_CLOSED = 'Closed';
    private static final String AUX_PRESCREEN_STATUS_PENDING = 'Pending';
    private static final String AUX_PRESCREEN_STATUS_UNDER_REVIEW = 'Under Review';
    private static final String AUX_PRESCREEN_STATUS_REVIEWED_NO_ISSUES = 'Reviewed - No Issues';
    private static final String PRESCREEN_GENERATED_MESSAGE = 'Prescreen and Reason Generated: ';

    @HTTPPost 
    global static void arbGuardRequest(){
        RestRequest req = RestContext.request;

        List<Group> queueList = [SELECT Id from Group WHERE Type = 'Queue' AND NAME =: SPECIALIZED_QUEUE];

        ArbGuardRequest reqBody = (PrescreenServiceMarkForArbGuardPrescreen.ArbGuardRequest) JSON.deserializeStrict(req.requestBody.toString(), ArbGuardRequest.class);

        //AUCTIONS REQUEST MAP
        Map<String, ArbGuard> auctionRequestsMap = new Map<String, ArbGuard>();
        for(ArbGuard arb : reqBody.arbGuard){ auctionRequestsMap.put(String.valueOf(arb.Saved_Auction_Id), arb); }
        
        //CONDITION REPORTS MAP
        Map<String, Condition_Report__c> conditionReportsMap = new Map<String, Condition_Report__c>();
        for(Condition_Report__c conditionReport : [SELECT Id, Auction__c, Arb_Risk_Categories__c, Dealership__c, Vehicle__c, ACV_Saved_Auction_Id__c,Floor_Price__c,CR_Doc_Complete__c, VCI_Creator__c 
                                                    FROM Condition_Report__c 
                                                    WHERE ACV_Saved_Auction_Id__c IN :auctionRequestsMap.keySet()]){
            conditionReportsMap.put(conditionReport.ACV_Saved_Auction_Id__c,conditionReport);
        }

        //AUCTION PRESCREEN MAP
        Map<String, Condition_Report_Prescreen__c> auctionsPrescreenMap = new Map<String, Condition_Report_Prescreen__c>();

        for(Condition_Report_Prescreen__c reportPrescreen : [SELECT Id, Status__c, Condition_Report__r.ACV_Saved_Auction_Id__c, OwnerId, Owner.Name, Aux_Prescreen_Status__c,
                                                            (select ID FROM Prescreen_Reasons__r where Name LIKE '%Arb Guard%') 
                                                            FROM Condition_Report_Prescreen__c 
                                                            WHERE Condition_Report__r.ACV_Saved_Auction_Id__c in :auctionRequestsMap.keySet()]){
                                                    
            auctionsPrescreenMap.put(reportPrescreen.Condition_Report__r.ACV_Saved_Auction_Id__c, reportPrescreen);
        }

        // MAPS
        Map<String, ArbGuardResponse> responseMap = new Map<String, ArbGuardResponse>();

        Map<String,Prescreen_Reason__c> prescreenReasonsToInsertMap = new Map<String,Prescreen_Reason__c>();
        Map<String,Condition_Report_Prescreen__c> prescreensToInsertMap = new Map<String,Condition_Report_Prescreen__c>();
        List<Condition_Report_Prescreen__c> prescreensToUpdate = new List<Condition_Report_Prescreen__c>();
        List<Condition_Report__c> conditionReportsToInsert = new List<Condition_Report__c>();
        List<Condition_Report__c> conditionReportsToUpdate = new List<Condition_Report__c>();

        //FOR EACH REQUEST RECEIVED
        for(ArbGuard arbGuardRequest : auctionRequestsMap.values()){

            if(conditionReportsMap.containsKey(String.valueOf(arbGuardRequest.Saved_Auction_Id))){//CONDITION REPORT EXIST

                Condition_Report__c cReport = conditionReportsMap.get(String.valueOf(arbGuardRequest.Saved_Auction_Id));

                //PRESCREEN VALIDATIONS
                if(auctionsPrescreenMap.containsKey(cReport.ACV_Saved_Auction_Id__c)){//EXIST ARBGUARD PREESCREEN

                    Condition_Report_Prescreen__c prescreen = auctionsPrescreenMap.get(cReport.ACV_Saved_Auction_Id__c);

                    if(!prescreen.Prescreen_Reasons__r.isEmpty()){//THERE ARE EXISTING REASONS
                        responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest,WARNING_STATUS, REASONS_ALREADY_EXIST_MESSAGE));
                    }

                    else if(prescreen.Status__c == PRESCREEN_STATUS_NEW){//PRESCREEN IS NEW

                        //CATEGORIES INCLUDED ON REQUEST
                        if(arbGuardRequest.categories != null && !arbGuardRequest.categories.isEmpty()){
                                
                            responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest, OK_STATUS, REASON_ADDED_TO_EXISTING_PRESCREEN_MESSAGE+' '+prescreen.Id));
                            prescreenReasonsToInsertMap.put(cReport.ACV_Saved_Auction_Id__c,new Prescreen_Reason__c(Condition_Report_Prescreen__c = prescreen.Id, Name = ARB_GUARD_PRESCREEN_NAME));

                            cReport.Arb_Risk_Categories__c = JSON.serialize(arbGuardRequest.categories);
                            cReport.Arb_Guard_Present__c = true;
                            conditionReportsToUpdate.add(cReport);

                        }
                        
                        //NO CATEGORIES INCLUDED ON REQUEST
                        else{
                            responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest, WARNING_STATUS, REASON_NOT_ADDED_DUE_NO_RISK_CATEGORIES_MESSAGE +prescreen.Id));
                        }
                        
                    }

                    else if(prescreen.Aux_Prescreen_Status__c == AUX_PRESCREEN_STATUS_PENDING || prescreen.Aux_Prescreen_Status__c == AUX_PRESCREEN_STATUS_UNDER_REVIEW){//AUX PRESCREEN IS PENDING / UNDER REVIEW

                        prescreen.OwnerId = queueList[0].Id;
                        prescreensToUpdate.add(prescreen);

                        responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest, OK_STATUS, PRESCREEN_SENT_TO_SPECIALIZED_QUEUE ));
                    }

                    else if(prescreen.Aux_Prescreen_Status__c == AUX_PRESCREEN_STATUS_PENDING && prescreen.Status__c == PRESCREEN_STATUS_CLOSED){//AUX PRESCREEN REVIEWED AND STATUS CLOSED

                        prescreen.OwnerId = queueList[0].Id;
                        prescreen.Status__c = PRESCREEN_STATUS_NEW; 
                        prescreensToUpdate.add(prescreen);

                        responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest, OK_STATUS, PRESCREEN_SENT_TO_SPECIALIZED_QUEUE_AND_RE_OPENED ));
                    }

                    else{//NO EXISTING REASONS AND PRESCREEN IS NOT NEW
                        prescreenReasonsToInsertMap.put(cReport.ACV_Saved_Auction_Id__c,new Prescreen_Reason__c(Condition_Report_Prescreen__c = prescreen.Id, Name = ARB_GUARD_PRESCREEN_NAME));
                        cReport.Arb_Risk_Categories__c = JSON.serialize(arbGuardRequest.categories);
                        cReport.Arb_Guard_Present__c = true;
                        conditionReportsToUpdate.add(cReport);
                        responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest, OK_STATUS, PRESCREEN_IS_NOT_IN_NEW_STATUS_MESSAGE ));
                    }

                }else{//ARBGUARD PRESCREEN DOES NOT EXIST

                    //CONDITION REPORT READY AND HAS CATEGORIES
                    if(cReport.Floor_Price__c >= 1 && cReport.CR_Doc_Complete__c && cReport.Auction__c == null &&
                        arbGuardRequest.categories != null && !arbGuardRequest.categories.isEmpty()){

                        responseMap.put(cReport.Id, new ArbGuardResponse(arbGuardRequest, OK_STATUS, PRESCREEN_GENERATED_MESSAGE +cReport.ACV_Saved_Auction_Id__c));
                        cReport.Arb_Risk_Categories__c = JSON.serialize(arbGuardRequest.categories);
                        cReport.Arb_Guard_Present__c = true;
                        conditionReportsToUpdate.add(cReport);

                        //PRESCREEN AND REASON GENERATION     
                        Condition_Report_Prescreen__c prescreen = new Condition_Report_Prescreen__c(Condition_Report__c = cReport.id, VCI__c = cReport.VCI_Creator__c, Seller_Dealership__c = cReport.Dealership__c, Vehicle__c = cReport.Vehicle__c);

                        prescreensToInsertMap.put(cReport.ACV_Saved_Auction_Id__c,prescreen);
                        prescreenReasonsToInsertMap.put(cReport.ACV_Saved_Auction_Id__c,new Prescreen_Reason__c(Name = ARB_GUARD_PRESCREEN_NAME/*, Condition_Report_Prescreen__c = npw.prescreen.Id*/));
                    }

                    else{//SETTING CATEGORIES ON CONDITION REPORT

                        responseMap.put(cReport.ACV_Saved_Auction_Id__c, new ArbGuardResponse(arbGuardRequest, OK_STATUS, RISK_CATEGORIES_ADDED_TO_CONDITION_REPORT_MESSAGE+cReport.ACV_Saved_Auction_Id__c));
                        cReport.Arb_Risk_Categories__c = (arbGuardRequest.categories != null && !arbGuardRequest.categories.isEmpty()) ? JSON.serialize(arbGuardRequest.categories) : '';
                        cReport.Arb_Guard_Present__c = true;
                        conditionReportsToUpdate.add(cReport);

                    }

                }
            
            }

            else{//CONDITION REPORT DOES NOT EXIST
                responseMap.put(String.valueOf(arbGuardRequest.Saved_Auction_Id), new ArbGuardResponse(arbGuardRequest,OK_STATUS, CONDITION_REPORT_SHELL_CREATED_MESSAGE+String.valueOf(arbGuardRequest.Saved_Auction_Id)));
            
                //CONDITION REPORT GENERATION
                conditionReportsToInsert.add(new Condition_Report__c(Arb_Guard_Present__c = true, ACV_Saved_Auction_Id__c = String.valueOf(arbGuardRequest.Saved_Auction_Id), Arb_Risk_Categories__c = (arbGuardRequest.categories != null && !arbGuardRequest.categories.isEmpty()) ? JSON.serialize(arbGuardRequest.categories) : ''));
            
            }

        }

        //DATA PROCESSING 

        try{

            //INSERT PRESCREENS            
            if(!prescreensToInsertMap.values().isEmpty()){ insert prescreensToInsertMap.values(); }

            //UPDATE PRESCREENS      
            if(!prescreensToUpdate.isEmpty()){ update prescreensToUpdate; }

            //UPDATE CONDITION REPORTS      
            if(!conditionReportsToUpdate.isEmpty()){ update conditionReportsToUpdate; }

            //ASSOCIATE NEW REASONS WITH PRESCREENS

            for(String auctionId : prescreenReasonsToInsertMap.keySet()){
                Prescreen_Reason__c reason = prescreenReasonsToInsertMap.get(auctionId);

                if(reason.Condition_Report_Prescreen__c == null && prescreensToInsertMap.containsKey(auctionId)){
                    reason.Condition_Report_Prescreen__c = prescreensToInsertMap.get(auctionId).Id; 
                    prescreenReasonsToInsertMap.put(auctionId,reason);
                }

            }

            //INSERT NEW PRESCREENS
            if(!prescreenReasonsToInsertMap.values().isEmpty()){ insert prescreenReasonsToInsertMap.values(); }

            //INSERT CONDINTION REPORTS
            if(!conditionReportsToInsert.isEmpty()){ insert conditionReportsToInsert; }

            RestResponse res = RestContext.response;
            res.statusCode = 201;
            res.responseBody = Blob.valueOf(JSON.serialize(responseMap.values()));

        }catch(Exception e){
            RestResponse res = RestContext.response;
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{ "error" : '+e.getMessage()+' }');
        }

    }

    public class ArbGuardRequest{
        public List<ArbGuard> arbGuard;
    }

    public class ArbGuard{
        public Integer Saved_Auction_Id;
        public Decimal totalDollarRisk;
        public Boolean display;
        public List<ArbGuardCategories> categories;
    }

    public class ArbGuardCategories{
        public String category;
        public String odds;
        public String note;
        public Decimal dollarRisk;
    }  

    public class ArbGuardResponse{
        ArbGuard orginalRequest;
        String status;
        String message;

        ArbGuardResponse(ArbGuard orginalRequest, String status, String message){
            this.orginalRequest = orginalRequest;
            this.status = status;
            this.message = message;
        }
    }

    public class NewPrescreenWrapper{
        public Condition_Report_Prescreen__c prescreen;
        public Prescreen_Reason__c reason;
    }
}