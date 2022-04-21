@RestResource(urlMapping='/PrescreenService/ampRequest')
global class PrescreenServiceMarkForAMPPrescreen {

    @testVisible private static boolean causeInsertFailure = false;

    @HTTPPost
    global static void amprequest(List<ampRequest> amp){
        list<Group> queueList = [select Id from Group where  Type = 'Queue' AND NAME = 'CR Queue'];
        //standard endpoint stuff
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        ACVAPIHelper.SFResponse apiResult = new ACVAPIHelper.SFResponse(amp, '', 200);
        List<ampresponse> apiResponse = new List<ampresponse>();
        apiResult.originalRequest = amp;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/PrescreenService/ampRequest';

        //All the lists I need to keep things straight as far as messages being paired up
        Map<String, ampRequest> savedAuctionToAmpMap = new Map<String, ampRequest>();
        List<Condition_Report__c> updateCRList = new List<Condition_Report__c>();
        List<Condition_Report__c> insertCRList = new List<Condition_Report__c>();
        List<Prescreen_Reason__c> insertReasonList = new List<Prescreen_Reason__c>();
        List<Condition_Report_Prescreen__c> insertPrescreenList = new List<Condition_Report_Prescreen__c>();
        List<Prescreen_Reason__c> insertPrescreenReasonList = new List<Prescreen_Reason__c>();
        Map<String, newPrescreenWrapper> prescreenWrapper = new Map<String, newPrescreenWrapper>();
        Map<String, ampresponse> existingPrescreenReasons = new Map<String, ampresponse>();
        Map<String, ampresponse> newPrescreenReasons = new Map<String, ampresponse>();
        Map<String, ampresponse> mlAddedToCR = new Map<String, ampresponse>();
        Map<String, ampresponse> crShellCreated = new Map<String, ampresponse>();
        Map<String, ampresponse> statusIsNotNew = new Map<String, ampresponse>();
        Map<String, ampresponse> newPrescreen = new Map<String, ampresponse>();

        //Metadata record for the AMP ML Prescreen rule so we can Make records when thresholds are passed;
        List<CR_Review_Trigger__mdt> mtdr = [SELECT Trigger_Value__c, Prescreen_Reason__c FROM CR_Review_Trigger__mdt WHERE Prescreen_Reason__c LIKE '%AMP%'];
        for(ampRequest a :amp){
            savedAuctionToAmpMap.put(String.valueOf(a.Saved_Auction_Id),a);
        }
        system.debug(savedAuctionToAmpMap.keySet());
        Map<Id, Condition_Report__c> crMap = new Map<Id, Condition_Report__c>([SELECT Id, Auction__c, AMP_ML_Score__c, Dealership__c, Vehicle__c, ACV_Saved_Auction_Id__c,Floor_Price__c,CR_Doc_Complete__c, VCI_Creator__c FROM Condition_Report__c WHERE ACV_Saved_Auction_Id__c in :savedAuctionToAmpMap.keySet() AND Inspection_Guid__c = NULL]);
        system.debug(crMap);
        Map<String, Condition_Report_Prescreen__c> crpMap = new Map<String, Condition_Report_Prescreen__c>();
        for(Condition_Report_Prescreen__c crp : [SELECT Id, Status__c, Condition_Report__r.ACV_Saved_Auction_Id__c, (SELECT ID FROM Prescreen_Reasons__r WHERE Name LIKE '%AMP%') FROM Condition_Report_Prescreen__c WHERE Condition_Report__r.ACV_Saved_Auction_Id__c in :savedAuctionToAmpMap.keySet() AND Condition_Report__r.Inspection_Guid__c = NULL]){
            crpMap.put(crp.Condition_Report__r.ACV_Saved_Auction_Id__c, crp);
        }
        for(Condition_Report__c cr :crMap.values()){
           if(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c) != null){
                if(crpMap.get(cr.ACV_Saved_Auction_Id__c) != null){
                    if(crpMap.get(cr.ACV_Saved_Auction_Id__c).Prescreen_Reasons__r.size() > 0){
                        existingPrescreenReasons.put(cr.ACV_Saved_Auction_Id__c, new ampresponse(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c), 'WARNING', 'AMP Prescreen Reason already exists for this request'));
                        savedAuctionToAmpMap.remove(cr.ACV_Saved_Auction_Id__c);
                    }
                    else if(crpMap.get(cr.ACV_Saved_Auction_Id__c).Status__c == 'New'){
                        if(checkModelScore(mtdr,savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c))){
                            newPrescreenReasons.put(crpMap.get(cr.ACV_Saved_Auction_Id__c).Id, new ampresponse(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c), 'OK', 'AMP Prescreen Reason Added to Existing Prescreen: '+crpMap.get(cr.ACV_Saved_Auction_Id__c).Id));
                            String prescreenReasonName = 'AMP ML';
                            if(causeInsertFailure){
                                prescreenReasonName = 'THIS IS GOING TO BE A SUPER LONG NAME TO FORCE AN ERROR SO WE CAN GET THE PROPER COVERAGE, THIS REALLY NEEDS TO BE LONG SO THIS IS GOING OUT HERE A WAYS.';
                            }
                            if(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c).display){
                                insertReasonList.add(new Prescreen_Reason__c(Condition_Report_Prescreen__c = crpMap.get(cr.ACV_Saved_Auction_Id__c).Id, Name = prescreenReasonName));
                            }
                        }
                        else{
                            newPrescreenReasons.put(crpMap.get(cr.ACV_Saved_Auction_Id__c).Id, new ampresponse(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c), 'WARNING', 'AMP Prescreen Reason not added, Model Score too low: '+crpMap.get(cr.ACV_Saved_Auction_Id__c).Id));
                        }
                        savedAuctionToAmpMap.remove(cr.ACV_Saved_Auction_Id__c);
                    }
                    else{
                        statusIsNotNew.put(cr.ACV_Saved_Auction_Id__c, new ampresponse(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c), 'OK', 'Prescreen not in New Status'));
                        savedAuctionToAmpMap.remove(cr.ACV_Saved_Auction_Id__c);
                    }
                }
                else{
                    if(checkIfReady(cr) && checkModelScore(mtdr, savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c))){
                        //Criteria was met to generate the prescreen records
                        newPrescreen.put(cr.Id, new ampresponse(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c), 'OK', 'Prescreen Generated: '+cr.ACV_Saved_Auction_Id__c));
                        newPrescreenWrapper npw = new newPrescreenWrapper();
                        npw.presc = new Condition_Report_Prescreen__c(Condition_Report__c = cr.id, OwnerId = queueList[0].Id, VCI__c = cr.VCI_Creator__c,Seller_Dealership__c = cr.Dealership__c, Vehicle__c = cr.Vehicle__c);
                        npw.preRes = new Prescreen_Reason__c(Name = 'AMP ML', Condition_Report_Prescreen__c = npw.presc.id);
                        prescreenWrapper.put(cr.ACV_Saved_Auction_Id__c, npw);
                        if(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c).display){
                            insertPrescreenList.add(npw.presc);
                            //insertPrescreenReasonList.add(npw.preRes);
                        }
                    }
                    else{
                        //Prescreen will be generated using the framework with this value populated and the metadata in place
                        mlAddedToCR.put(cr.ACV_Saved_Auction_Id__c, new ampresponse(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c), 'OK', 'ML Score Added to Condition Report: '+cr.ACV_Saved_Auction_Id__c));
                        cr.AMP_ML_Score__c = savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c).model_score;
                        if(savedAuctionToAmpMap.get(cr.ACV_Saved_Auction_Id__c).display){
                            updateCRList.add(cr);
                        }
                    }
                    savedAuctionToAmpMap.remove(cr.ACV_Saved_Auction_Id__c);
                }
                
           }
        }
        for(amprequest a :savedAuctionToAmpMap.values()){
            crShellCreated.put(String.valueOf(a.Saved_Auction_Id), new ampresponse(a, 'OK', 'Condition Report Shell Created For SA ID: '+String.valueOf(a.Saved_Auction_Id)));
            if(a.display){
                insertCRList.add(new Condition_Report__c(ACV_Saved_Auction_Id__c = String.valueOf(a.Saved_Auction_Id), AMP_ML_Score__c = a.model_score));
            }
        }

        List<ampresponse> responseList = new List<ampresponse>();
        responseList.addAll(existingPrescreenReasons.values());
        responseList.addAll(statusIsNotNew.values());
        if(!insertPrescreenList.isEmpty()){
            Map<String,ampresponse> tempResponse = new Map<String, ampresponse>();
            Map<String,ampresponse> tempResponse2 = new Map<String, ampresponse>();
            tempResponse = processDBTransactions(insertPrescreenList,newPrescreen,'Condition_Report__c',true);
            for(Condition_Report_Prescreen__c crp:insertPrescreenList){
                tempResponse2.put(crp.id, tempResponse.get(crp.Condition_Report__c));
                insertPrescreenReasonList.add(new Prescreen_Reason__c(Name = 'AMP ML', Condition_Report_Prescreen__c = crp.id));
            }
            responseList.addAll(processDBTransactions(insertPrescreenReasonList,tempResponse2,'Condition_Report_Prescreen__c',true).values());
        }
        if(!insertReasonList.isEmpty()){
            responseList.addAll(processDBTransactions(insertReasonList,newPrescreenReasons,'Condition_Report_Prescreen__c',true).values());
        }

        if(!updateCRList.isEmpty()){
            responseList.addAll(processDBTransactions(updateCRList,mlAddedToCR,'ACV_Saved_Auction_Id__c',false).values());
        }

        if(!insertCRList.isEmpty()){
            responseList.addAll(processDBTransactions(insertCRList,crShellCreated,'ACV_Saved_Auction_Id__c',true).values());
        }

        apiResult.message = 'Request Processed';
        apiResult.statusCode = 201;
        apiResult.apiResponse = responseList;
        makeLog(amp, apiResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'PrescreenService.ampRequest Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        apiResult.generateResponse(headerMap);
    }

    global static Boolean checkIfReady(Condition_Report__c cr){
        return (cr.Floor_Price__c >= 1 && cr.CR_Doc_Complete__c && cr.Auction__c == null);
    }

    global static Boolean checkModelScore(List<CR_Review_Trigger__mdt> mtdr, ampRequest ampreq){
        return (mtdr.size() > 0 && ampreq.model_score >= Decimal.valueOf(mtdr[0].Trigger_Value__c));
    }

    global static Map<string, ampresponse> processDBTransactions(List<SObject> objectList, Map<string, ampresponse> responseMap, String fieldKey, Boolean isInsert){
        List<Database.SaveResult> reasonSR;
        if(isInsert){
            reasonSR = Database.insert(objectList, FALSE);
        }
        else{
            reasonSR = Database.update(objectList, FALSE);
        }
        for ( Integer position = 0; position < reasonSR.size(); position++ ) {
            Database.SaveResult saveRecord = reasonSR[position];
            SObject saverec = objectList[position];

            if ( !saveRecord.isSuccess() && !saveRecord.getErrors().isEmpty()) {
                responseMap.put(String.valueOf(saverec.get(fieldKey)),new ampresponse(responseMap.get(String.valueOF(saverec.get(fieldKey))).orginalRequest, 'ERROR', saveRecord.getErrors()[0].getMessage()));
            }
        }
        return responseMap;
    }

    global class newPrescreenWrapper{
        global Condition_Report_Prescreen__c presc;
        global Prescreen_Reason__c preRes;
    }
    
    global class ampRequest{
        global String VIN;
        global Integer Saved_Auction_Id;
        global Integer model_score;
        //global Boolean was_excluded;
        global Boolean display;
        global String audio_sample_url;
    }

    global class ampresponse{
        ampRequest orginalRequest;
        String status;
        String message;

        ampresponse(ampRequest ampr, String s, String m){
            this.orginalRequest = ampr;
            this.status = s;
            this.message = m;
        }
    }

    public static void makeLog(Object newUser, ACVAPIHelper.SFResponse output, Integer lineNumber, String endpoint, String methodType, String stackTrace, SplunkHelper.LOGLEVEL LogLevel, Integer statusCode){
        HttpRequest req = new HttpRequest();
        req.setBody(JSON.serialize(newUser));
        req.setMethod(methodType);
        req.setEndpoint(endpoint);
        HttpResponse res = new HttpResponse();
        res.setBody(JSON.serialize(output));
        res.setStatus(output.message);
        res.setStatusCode(statusCode);
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'PrescreenService:' + lineNumber;
        infoLog.message = output.message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'PrescreenService';
        infoLog.sfObject = 'Condition Report, Condition Report Prescreen, Prescreen Reason';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }
}