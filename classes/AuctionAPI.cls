public class AuctionAPI{
    

    public static void authorize(ACVAPIHelper apiHelper, List<Integration_Result__c> resultList){
        Http h = new Http();
        HttpRequest authRequest = new HttpRequest();
        HttpResponse authResponse = new HttpResponse();
        System.debug('Inside authorize');
        authRequest.setMethod('POST');
        authRequest.setEndpoint('callout:ACVAuth2');
        Map <String, object> mapping = New Map<String, object>();
        mapping.put('email', '{!$Credential.Username}');
        mapping.put('password', '{!$Credential.Password}');
        mapping.put('web', true);    
        authRequest.setBody(json.serialize(mapping));
        authRequest.setHeader('Content-Type', 'application/json');
        authResponse = h.send(authRequest);
        
        if(authResponse.getStatusCode() == 200){
            ACVLoginObject loginObj = ACVLoginObject.parse(authResponse.getBody());          
            if(loginObj.data != null && loginObj.data.user_id != null && loginObj.data.session_token != null){
                apiHelper.setCreds(loginObj.data.user_id, loginObj.data.session_token);
            }
            else{
                insert(new ACVAPIHelper.Result(authRequest, authResponse, 'Auction API').toIR());
            }
        }
        else{
                insert(new ACVAPIHelper.Result(authRequest, authResponse, 'Auction API').toIR());
        }
    }

    //this function takes the record Id of an auction and returns the auctionId used by the ACV API
    private static String auctionIdCheck(String stringToCheck){
        if (stringToCheck.length() == 18){
            String auction = [SELECT Auction_Number__c FROM Case WHERE Id =: stringToCheck LIMIT 1].Auction_Number__c;
            String savedAuctionId = [SELECT Name FROM Auction__c WHERE Id =: auction LIMIT 1].Name;
            System.debug('stringToCheck: ' + stringToCheck);
            System.debug('Name: ' + savedAuctionId);
            String stringRet = savedAuctionId;
            return stringRet;
        }
        //checks if you actually inputed a auctionID and if so it doesn't have to do anything besdies return it
        else {
            return stringToCheck;
        }
    }

    public static boolean isTrue(String yes_no){
        if(yes_no == '0'){
            return false;
        }
        if(yes_no == '1'){
            return true;
        }
        else{return false;}
    }

    // this function takes a record id of a case and an image key and returns a url for the appropriate images
    @AuraEnabled
    public static List<String> getSAPUrl(String recordId, List<String> imageSet){

        ACVAPIHelper apiHelper = new ACVAPIHelper();
        List<Integration_Result__c> resultList = new List<Integration_Result__c>();
        Case caseInfo = new Case();
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        List<String> neededUrls = new List<String>();

        authorize(apiHelper, resultList);
        if(apiHelper.getCreds().isValid()){
            String userId = apiHelper.getCreds().userId;
            String sessionToken = apiHelper.getCreds().sessionToken;
            String auctionId;
            auctionId = auctionIdCheck(recordId);
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            request.setEndpoint('callout:ACVAuctionData'+'/v2/auction/'+ auctionId + '?user_id=' + userId + '&session_token='+ sessionToken);
            response = h.send(request);
        }
        if (response.getStatusCode() == 200){
            Boolean isChanged = false;
            AuctionDataParse storingObj = AuctionDataParse.parse(response.getBody());            
            caseInfo = [SELECT Id, Title_Absent__c, Branded_Title__c, True_Mileage__c, Front_Line_Vehicle__c, Off_Lease_Vehicle__c, Repair_Order_Attached__c, Repossesion__c FROM Case WHERE Id=:recordId];            
            for(AuctionDataParse.Sections sec : storingObj.data.condition_report.sections){
                if(sec.title == 'Title & History'){
                    for(AuctionDataParse.Subsections_Z subSec: sec.subsections){
                        for(AuctionDataParse.Questions_Z question : subSec.questions){
                            Boolean ynValue = isTrue(question.yes_no);
                            if(question.title == 'Branded Title' && caseInfo.get('Branded_Title__c') != ynValue){
                                caseInfo.Branded_Title__c = ynValue;
                                isChanged = true;                     
                            }
                            if(question.title == 'True Mileage Unknown' && caseInfo.get('True_Mileage__c') != ynValue){
                                caseInfo.True_Mileage__c = ynValue;
                                isChanged = true;                    
                            }
                            if(question.title == 'Front Line Vehicle' && caseInfo.get('Front_Line_Vehicle__c') != ynValue){
                                caseInfo.Front_Line_Vehicle__c = ynValue;
                                isChanged = true;                            
                            }
                            if(question.title == 'Off Lease Vehicle' && caseInfo.get('Off_Lease_Vehicle__c') != ynValue){
                                caseInfo.Off_Lease_Vehicle__c = ynValue;
                                isChanged = true; 
                            }
                            if(question.title == 'Repair Order Attached' && caseInfo.get('Repair_Order_Attached__c') != ynValue){
                                caseInfo.Repair_Order_Attached__c = ynValue;
                                isChanged = true;    
                            }
                            if(question.title == 'Repossession' && caseInfo.get('Repossesion__c') != ynValue){
                                caseInfo.Repossesion__c = ynValue;
                                isChanged = true;  
                            }                            
                        }
                    }
                }
            }
            if(isChanged == true){
                try{
                    update caseInfo;
                }
                catch(exception e){
                    insert new List<Integration_Result__c>{ new Integration_Result__c(
                        Integration_Name__c = 'Auction API Case Update',
                        Integration_Type__c = 'GET',
                        RecordId__c = caseInfo.Id,
                        Request_Message__c = JSON.serialize(caseInfo),
                        Response_Message__c = e.getStackTraceString(),
                        SObject_Name__c = 'Case',
                        Status_Code__c = 400,
                        Status_Message__c = e.getMessage()
                    )};
                }
            }
            
            for(String imageKey: imageSet){    
                for(AuctionDataParse.Images i: storingObj.data.images){
                    if (i.image_key == imageKey){
                        String neededUrl = i.url;
                        neededUrls.add(neededUrl);
                    }
                }
            }
        }
        else{
            System.debug('Error: Response status code');
            insert(new ACVAPIHelper.Result(request, response, 'Auction API').toIR());
        }
        return neededUrls;        
    }
}