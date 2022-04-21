public class CreditCallout {

    public static void authorize(ACVAPIHelper apiHelper){
        System.debug('Inside authorize');
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setMethod('POST');
        request.setEndpoint('callout:ACVAuth2');
        Map <String, object> mapping = New Map<String, object>();
        mapping.put('email', '{!$Credential.Username}');
        mapping.put('password', '{!$Credential.Password}');
        mapping.put('web', true);    
        request.setBody(json.serialize(mapping));
        request.setHeader('Content-Type', 'application/json');
        response = h.send(request);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        if(response.getStatusCode() == 200){
            ACVLoginObject loginObj = ACVLoginObject.parse(response.getBody()); 
            if(loginObj.data != null && loginObj.data.user_id != null && loginObj.data.session_token != null){
                apiHelper.setCreds(loginObj.data.user_id, loginObj.data.session_token);
            }
            else{
                insert(new ACVAPIHelper.Result(request, response, 'Credit Auth').toIR());
            }
        }
        else{
            insert(new ACVAPIHelper.Result(request, response, 'Credit Auth').toIR());
        }
    }

    //future annotation must be static methods, and can only return a void type
    @future(callout=true)
    public static void getCredit(List<Id> calloutList) {
        System.debug('getCredit');
        List<Credits_Checks__c> creditList = [SELECT Dealership_ID__c, Amount_Approved__c, ACV_User_Id__c, Reason__c, Organization_Credit_Id__c,
                                                Expiration_Date__c, Id, Explanation__c, Auction__c, Payment_Type__c 
                                                FROM Credits_Checks__c 
                                                WHERE Id IN :calloutList];
        if(creditList.size()>0){
            ACVAPIHelper apiHelper = new ACVAPIHelper();
            authorize(apiHelper);
            System.debug('after authorize');
            Integer accountId;
            Id sfAdjustId;
            CreditPost postObject = new CreditPost();
            postObject.credits = new List<CreditPost.CreditWrap>();
            postObject.user_id = Integer.valueOf(apiHelper.getCreds().userId);
            postObject.session_token = apiHelper.getCreds().sessionToken;
            CreditAdjustment adjustObject = new CreditAdjustment();
            adjustObject.adjustment = new CreditAdjustment.AdjustmentWrap();
            adjustObject.user_id = Integer.valueOf(apiHelper.getCreds().userId);
            adjustObject.session_token = String.valueOf(apiHelper.getCreds().sessionToken);
            List<Integration_Result__c> irsToInsert = new List<Integration_Result__c>();
            for(Credits_Checks__c c : creditList){
                CreditPost.CreditWrap wrappedCred = new CreditPost.CreditWrap();

                if(c.Payment_Type__c == 'ACV Credit Assigned'){   
                    wrappedCred.account_id = Integer.valueOf(c.Organization_Credit_Id__c);
                    wrappedCred.amount = Integer.valueOf(c.Amount_Approved__c);
                    wrappedCred.authorizer = Integer.valueOf(c.ACV_User_Id__c);
                    wrappedCred.credit_cause_type = c.Reason__c;
                    wrappedCred.expires_after = Date.Today().daysBetween(c.Expiration_Date__c);
                    wrappedCred.salesforce_id = String.valueOf(c.Id);            
                    postObject.credits.add(wrappedCred);
                }
                else if(c.Payment_Type__c == 'ACV Credit Deduction'){
                    adjustObject.adjustment.amount = Integer.valueOf(c.Amount_Approved__c);
                    adjustObject.adjustment.authorizer_id = Integer.valueOf(c.ACV_User_Id__c);
                    adjustObject.adjustment.explanation = c.Explanation__c;
                    accountId = Integer.valueOf(c.Organization_Credit_Id__c);
                    sfAdjustId = c.Id;
                }             
            }
            if(postObject.credits.size()>0){
                System.debug('postObject>0');
                String creditJSON = CreditPost.compose(postObject);
                System.debug('creditJSON: ' + creditJSON);
                String creditEndpoint ='/bulk_create';
                HttpResponse response;
                CreditResponse storedResponse;
                if(apiHelper.getCreds().isValid()){
                    response = sendIt(creditJSON, creditEndpoint);  
                    System.debug('sendit response: ' +response);
                    System.debug('sendit code: ' + response.getStatusCode());
                    System.debug('sendit body: ' + response.getBody());   
                    storedResponse = CreditResponse.parse(response.getBody());
                }else{
                    irsToInsert.add( createCreditIntegrationResult('Not Valid Auth Creds', creditEndpoint, null, 'The Auth Creds returned back were not valid from the APIHelper', String.valueOf(apiHelper), 'Auth Creds not valid during CreditAPI Callout'));
                }
                if(response.getStatusCode() == 200){
                    if(storedResponse.data != null){
                        System.debug('lvl 1');
                        Map<Id,String> credMap = new Map<Id,String>();
                        Map<Id,Date> credExpirationMap = new Map<Id,Date>();
                        String status;
                        
                        if(storedResponse.data.successes.size() > 0){
                            System.debug('lvl 2');
                            for(CreditResponse.successes credSuccess : storedResponse.data.successes){
                                credMap.put((Id)credSuccess.salesforce_id, String.valueOf(credSuccess.id));
                                if(credSuccess.expiration != null) credExpirationMap.put((Id)credSuccess.salesforce_id, Date.valueOf(credSuccess.expiration));
                            }
                            status = 'Successful';
                            updateCredits(credMap, status, credExpirationMap);
                        }
                        if(storedResponse.data.errors.size()>0){
                            System.debug('lvl 3');
                            credMap = new Map<Id, String>();
                            for(CreditResponse.errors credErrors : storedResponse.data.errors){
                                credMap.put((Id)credErrors.attempted_create.salesforce_id, credErrors.error.message);
                            }
                            status = 'Failed';
                            updateCredits(credMap, status, credExpirationMap);
                        }
                    }            
                }else{
                    irsToInsert.add( createCreditIntegrationResult('Outbound to CreditAPI', creditEndpoint, response.getStatusCode(), response.getBody(), creditJSON, 'CreditAPI failed'));
                }                
            }
            if(adjustObject.adjustment.amount != null){
                System.debug('adjust !=null');
                Boolean amountExists = checkHasEnoughToRemove(adjustObject.adjustment.amount, accountId);
                if(amountExists == true){
                    String adjustJSON = CreditAdjustment.compose(adjustObject);
                    System.debug('adjustJSON: ' + adjustJSON);
                    String adjustEndpoint = '/organizationcreditaccounts/' + accountId + '/make_adjustment'; 
                    HttpResponse response;
                    AdjustmentResponse storedResponse;
                    if(apiHelper.getCreds().isValid()){
                        response = sendIt(adjustJSON, adjustEndpoint);
                        storedResponse = AdjustmentResponse.parse(response.getBody());
                        System.debug('2sendit response: ' +response);
                        System.debug('2sendit code: ' + response.getStatusCode());
                        System.debug('2sendit body: ' + response.getBody());
                    }
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                        if(storedResponse.data != null){
                            if(storedResponse.data.adjustments != null){
                                Map<Id,String> adjustMap = new Map<Id,String>();
                                String status = 'Successful';
                                for(AdjustmentResponse.Adjustments adjustment : storedResponse.data.adjustments){
                                    adjustMap.put((Id)sfAdjustId,String.valueOf(adjustment.id));
                                }
                                updateCredits(adjustMap,status,null);
                            }                        
                        }            
                    }
                    else if(response.getStatusCode() != 200 && response.getStatusCode() != 201){
                        System.debug('not 200');
                        Credits_Checks__c adjustmentToUpdate = [SELECT Id,Approval_Status__c FROM Credits_Checks__c WHERE Id =:sfAdjustId];
                        adjustmentToUpdate.Approval_Status__c = 'Done Failed';
                        update adjustmentToUpdate;
                    }
                }
                else if(amountExists == false){
                    Map<Id,String> adjustMap = new Map<Id,String>();
                    String status = 'Failed';
                    adjustMap.put((Id)sfAdjustId,null);
                    updateCredits(adjustMap,status, null);
                }
            }
        }
    }
    //***********************************
    public static HttpResponse sendIt(String postJSON, String postEndpoint){
        System.debug('sendIt');
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:CreditAPI' + postEndpoint);
        request.setBody(postJSON);
        request.setTimeout(120000);
        response = h.send(request);
        return response;    
    }
    //***********************************
    public static AccountSummary getAccountTotal( Integer accountId ){
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setEndpoint('callout:CreditAPI' + '/organizationcreditaccounts/' + accountId);
        response = h.send(request);
        AccountSummary accountInfo;
        accountInfo = AccountSummary.parse(response.getBody());
        return accountInfo;
    }
    public static Boolean checkHasEnoughToRemove( Integer adjustAmount, Integer accountId ){
        AccountSummary accountInfo = getAccountTotal( accountId );
        return accountInfo.data.accountTotal>adjustAmount ;
    }
    //***********************************
    
    public static void updateCredits(Map<Id,String> credMap, String status, Map<Id, Date> credExpirationMap){
        List<Integration_Result__c> irsToInsert = new List<Integration_Result__c>();
        System.debug('Update Credits');
        List<Id> credList = new List<Id>();
        Map<Id,List<Integer>> budgetUpdateMap = new Map<Id,List<Integer>>();
        
        List<Budget__c> budgetsToUpdate = new List<Budget__c>();
        for(Id sfId : credMap.keySet()){
            credList.add(sfId);
        }
        List<Credits_Checks__c> creditsToUpdateList = [SELECT Id, Credit_Id__c, Approval_Status__c, Expiration_Date__c,
                                                        Budget_Name__c, Amount_Approved__c, Adjustment__c, Parent_Credit__c, Parent_Credit__r.Expiration_Date__c
                                                        FROM Credits_Checks__c 
                                                        WHERE Id IN :credList];
        for(Credits_Checks__c credToUpdate : creditsToUpdateList){
           
            credToUpdate.Approval_Status__c = 'Done ' + status;
            if(credMap.get(credToUpdate.Id) != null){
                credToUpdate.Credit_Id__c = credMap.get(credToUpdate.Id);
            }
            if(credToUpdate.Adjustment__c == true){
                Integer reverseVal = (Integer)credToUpdate.Amount_Approved__c * -1;
                List<Integer> amountList = new List<Integer>();
                amountList.add(reverseVal);
                if(budgetUpdateMap.get(credToUpdate.Budget_Name__c) == null){
                    budgetUpdateMap.put(credToUpdate.Budget_Name__c, amountList);
                }
                else{
                    budgetUpdateMap.get(credToUpdate.Budget_Name__c).add(reverseVal);
                }
                if( credToUpdate.Parent_Credit__c != null && credToUpdate.Parent_Credit__r.Expiration_Date__c != null ){
                    credToUpdate.Expiration_Date__c = credToUpdate.Parent_Credit__r.Expiration_Date__c;
                }
            }
            else{
                List<Integer> amountList = new List<Integer>();
                amountList.add((Integer)credToUpdate.Amount_Approved__c);
                if(budgetUpdateMap.get(credToUpdate.Budget_Name__c) == null){
                    budgetUpdateMap.put(credToUpdate.Budget_Name__c, amountList);
                }
                else{
                    budgetUpdateMap.get(credToUpdate.Budget_Name__c).add((Integer)credToUpdate.Amount_Approved__c);
                }
                if( credExpirationMap.get(credToUpdate.Id) != null ){
                    credToUpdate.Expiration_Date__c = credExpirationMap.get(credToUpdate.Id);
                }
            }
        }
        try{
            update creditsToUpdateList;
        }
        catch(exception e){
            System.debug('Error: ' + e);
            irsToInsert.add( createCreditIntegrationResult('Internal DML', 'Inteneral DML', null, e.getMessage() + '\n' + e.getStackTraceString(), String.valueOf(creditsToUpdateList), 'Credit Update Failed in UpdateCredits()'));
        }
        for(Budget__c b : [SELECT Id,Current_Balance__c FROM Budget__c WHERE Id IN :budgetUpdateMap.keySet()]){
            for(Integer i : budgetUpdateMap.get(b.Id)){
                b.Current_Balance__c = b.Current_Balance__c - i;
            }
            budgetsToUpdate.add(b);
        }
        try{
            update budgetsToUpdate;
        }
        catch(exception e){
            System.debug('Error: ' + e);
            irsToInsert.add( createCreditIntegrationResult('Internal DML', 'Inteneral DML', null, e.getMessage() + '\n' + e.getStackTraceString(), String.valueOf(budgetsToUpdate), 'Budget Update Failed in UpdateCredits()'));
        }
        if( irsToInsert.size() > 0 ) insert irsToInsert;
    }
    public static Integration_Result__c createCreditIntegrationResult( String integrationType, String endpoint, Double statusCode, String statusMessage, String requestMessage, String integrationName ){
        Integration_Result__c ir = new Integration_Result__c();
        ir.Sobject_name__c = 'Credits & Checks';
        ir.Integration_Type__c = integrationType;
        ir.Endpoint_URL__c = endpoint;
        ir.Status_Code__c = statusCode;
        ir.Status_Message__c = statusMessage;
        ir.Request_Message__c = requestMessage;
        ir.Integration_Name__c = integrationName;
        return ir;
    }
}