public class AcvIntegrationQueueableJob implements Queueable, Database.AllowsCallouts {
    public static String user_id {get;set;}
    public static String session_token {get;set;}
    String integrationAction;
    List < sobject > recordList = New List < sobject > ();
    Map<String,object>  mBodyValues = new Map<String,object>();
    //public static Map<String,object>  mBodyValues {get;set;}
    //public static List < sobject > recordList {get;set;}
    public AcvIntegrationQueueableJob(String integrationAction, List < sobject > recordList, Map<String,object> mBodyValues) {
        this.integrationAction = integrationAction;
        this.recordList = recordList;
        this.mBodyValues = mBodyValues;
    }
 
    public void execute(QueueableContext context) {
        Acv_integration__mdt acvIntegrationObj = new Acv_integration__mdt();
        System.debug('int obj: ' + acvIntegrationObj);
        if(integrationAction != 'Logout'){
            acvIntegrationObj = [select id, DeveloperName, MasterLabel, Write_Back_Field__c, OAuth__c, Bulk__c, EndPoint_URL__c, URL_Parameters__c, Integration_Method__c,
                (Select id, DeveloperName, MasterLabel, Field_Type__c, Salesforce_Api_Name__c, SF_Api_Name_When_Reference__c, Reference_Object_Api_Name__c from ACV_Field_Mapping__r)
                from Acv_integration__mdt where MasterLabel =: integrationAction];
        } 
        System.debug('Start:'+integrationAction+', user_id:'+user_id+', session_token:'+session_token);
        List < Integration_Result__c > integrationList = New List < Integration_Result__c > ();     
        String reqBody;
        if(integrationAction == 'Logout' && mBodyValues != null){
            logout();
            return;
        }else if(acvIntegrationObj.OAuth__c == true){
            authenticate();
            String tempReqBody;
            if(integrationAction.contains('Complaint')){
                 tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody(recordList, acvIntegrationObj);
            }else if(integrationAction.contains('Pricing')){
                tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody_Pricing(recordList, acvIntegrationObj);
            }else if(integrationAction.contains('Title')){
                this.recordList = requeryRecordList(recordList, acvIntegrationObj, 'Case');
                tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody_Titles(recordList, acvIntegrationObj);
            }else if(integrationAction.contains('Transportation Request')){
                //this.recordList = requeryRecordList(recordList, acvIntegrationObj, 'Case'); //Commented out due to a duplicate value in the metadata and a hard coded query value
                tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody_TransReq(recordList, acvIntegrationObj);
            }else if(integrationAction.contains('Unwind Auction')){
                tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody_UnwindAuction(recordList, acvIntegrationObj);
            }else if(integrationAction.contains('Saved Auction Dealer')){
                tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody_SADealer(recordList, acvIntegrationObj);
            }else if(integrationAction.contains('Saved Auction Delete')){
                tempReqBody = AcvIntegrationQueueableJobHandler.createRequestBody_SADelete(recordList, acvIntegrationObj);
            }
            //Add user_id and session_token to body for OAuth
            Map < String, Object > requestMap = (Map < String, Object > ) JSON.deserializeUntyped(tempReqBody);
            if(user_id != null){
                requestMap.put('user_id',Integer.valueOf(user_id));
            }else{
                requestMap.put('user_id',user_id);
            }
            requestMap.put('session_token',session_token);
            reqBody = json.serialize(requestMap);
        }else{
            reqBody = AcvIntegrationQueueableJobHandler.createRequestBody(recordList, acvIntegrationObj);
        }
        System.debug('reqBody:'+reqBody);
        
        Http h = new Http();
        HttpRequest request = new HttpRequest();
        
        try {
            request.setMethod(acvIntegrationObj.Integration_Method__c);
            if(acvIntegrationObj.OAuth__c == true){
                String endPointAddress = AcvIntegrationQueueableJobHandler.createEndPointURL(acvIntegrationObj.EndPoint_URL__c,recordList.get(0),acvIntegrationObj.URL_Parameters__c);
                request.setEndpoint(endPointAddress);
            }else{
                String endPointAddress = AcvIntegrationQueueableJobHandler.createEndPointURL(acvIntegrationObj.EndPoint_URL__c,recordList.get(0),acvIntegrationObj.URL_Parameters__c);
                request.setEndpoint('callout:ACVAuctions' + endPointAddress.split('acvauctions.com').get(1));
                request.setHeader('Authorization', '{!$Credential.Password}');
            }
            
            request.setBody(reqBody);
            request.setTimeout(60000);
            request.setHeader('Content-Type', 'application/json');
            System.debug('request:'+request);
            
            HttpResponse response = h.send(request);
            System.debug('Final Responce Message'+response);
            if(session_token != null && user_id != null){
                Map<String,object> mAuthValues = new Map<String,object>();
                mAuthValues.put('session_token',session_token);
                mAuthValues.put('user_id', user_id);
                //System.enqueueJob(new AcvIntegrationQueueableJob('Logout',null,mAuthValues));
                System.debug('LogoutJobQueued:'+mAuthValues);
                this.mBodyValues = mAuthValues;
                logout();
            }
            // Parsing responce for a single record as only single record id along with status is returned.Code below 
            // needs to be updated to capture bulkified responce json.
            // Actually check the data to verify an error or not
            Integer statusCode = 200;
            Map < String, Object > responseErrorMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
            Map < String, Object > dataErrorMap = (Map < String, Object > )responseErrorMap.get('data');
            if( dataErrorMap != null && dataErrorMap.containsKey('errors') ) {
                List<Object> errorsList = (List<Object>) dataErrorMap.get('errors');
                if( errorsList.size() > 0 ) {
                    statusCode = 400;
                }
            }
            if(acvIntegrationObj.Bulk__c == true){
                Integration_Result__c intGrationObj = New Integration_Result__c();
                intGrationObj.Integration_Type__c = acvIntegrationObj.Integration_Method__c;
                intGrationObj.Sobject_name__c = !Test.isRunningTest()?recordList.get(0).id.getSObjectType().getDescribe().getName():'Sobject';
                //intGrationObj.recordId__c = sobj.id;
                intGrationObj.Request_Message__c = reqBody;
                intGrationObj.Integration_Name__c = acvIntegrationObj.MasterLabel;
                intGrationObj.Status_Message__c = statusCode == 200 ? 'OK' : 'ERROR';
                intGrationObj.Status_Code__c = statusCode;
                intGrationObj.response_message__c = response.getBody();
                integrationList.add(intGrationObj);
            }else{
                for (Sobject sobj: recordList) {
                    Integration_Result__c intGrationObj = New Integration_Result__c();
                    intGrationObj.Integration_Type__c = acvIntegrationObj.Integration_Method__c;
                    intGrationObj.Sobject_name__c = !Test.isRunningTest()?recordList.get(0).id.getSObjectType().getDescribe().getName():'Sobject';
                    intGrationObj.recordId__c = sobj.id;
                    intGrationObj.Request_Message__c = reqBody;
                    intGrationObj.Integration_Name__c = acvIntegrationObj.MasterLabel;
                    intGrationObj.Status_Message__c = statusCode == 200 ? 'OK' : 'ERROR';
                    intGrationObj.Status_Code__c = statusCode;
                    intGrationObj.response_message__c = response.getBody();
                    integrationList.add(intGrationObj);
                }
            }
            if (integrationList.size() > 0)
                insert integrationList; 
                
            // Write Back Logic When responce is success i.e status code 200
            // - This is flawed logic. 200 status code returns anytime a response is consumed, errors are included as part of status 200 returns
            if (response.getStatusCode() == 200) { 
                Map < String, Object > responseMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody()); 
                System.debug('responseMap:'+responseMap);
                if (responseMap.size() > 0 && acvIntegrationObj.Write_Back_Field__c != Null) {
                //Perform Writeback logic
                    if(integrationAction.contains('Complaint') || integrationAction.contains('Pricing') || integrationAction.contains('Title') || integrationAction.contains('Transportation Request') || integrationAction.contains('Saved Auction Delete')){
                        if(responseMap.containsKey('data')){
                            System.debug('responseData:'+responseMap.get('data'));
                            if(integrationAction.contains('Pricing')){
                                System.debug('WB Pricing');
                                AcvIntegrationWriteBackData.dataWriteBackToSobjectRP(acvIntegrationObj.Write_Back_Field__c, recordList, (Map < String, Object > )responseMap.get('data'));    
                            }else if(integrationAction.contains('Title') || integrationAction.contains('Transportation Request') || integrationAction.contains('Saved Auction Delete')){
                                System.debug('WB Data Succ/Error');
                                Map < String, Object > dataMap = (Map < String, Object > )responseMap.get('data');
                                if(dataMap.containsKey('errors')){
                                    List<Object> errorsList = (List<Object>) dataMap.get('errors');
                                    System.debug('Errors:'+errorsList);
                                    if(errorsList.size()>0){
                                        //Errors -- Create Error Integration Result
                                        
                                        Integration_Result__c intGrationObj = New Integration_Result__c();
                                        intGrationObj.Integration_Type__c = acvIntegrationObj.Integration_Method__c;
                                        intGrationObj.Sobject_name__c = !Test.isRunningTest()?recordList.get(0).id.getSObjectType().getDescribe().getName():'Sobject';
                                        intGrationObj.recordId__c = 'See Errors';
                                        intGrationObj.Status_Message__c = integrationAction+' Errors';
                                        intGrationObj.response_message__c = String.valueOf(errorsList);
                                        intGrationObj.Request_Message__c = reqBody;
                                        intGrationObj.Integration_Name__c = acvIntegrationObj.MasterLabel;
                                        insert intGrationObj;
                                    }
                                }
                                if(integrationAction.contains('Title')){
                                    AcvIntegrationWriteBackData.dataWriteBackToSobjectTitle(acvIntegrationObj.Write_Back_Field__c, recordList, (Map < String, Object > )responseMap.get('data'));
                                }else if(integrationAction.contains('Transportation Request')){
                                    AcvIntegrationWriteBackData.dataWriteBackToSobjectTrans(acvIntegrationObj.Write_Back_Field__c, recordList, (Map < String, Object > )responseMap.get('data'), integrationAction);
                                }else if(integrationAction.contains('Saved Auction Delete')){
                                    AcvIntegrationWriteBackData.dataWriteBackToSobjectSADelete(acvIntegrationObj.Write_Back_Field__c, recordList, (Map < String, Object > )responseMap.get('data'));
                                }
                            }else{
                                System.debug('WB Data Other');
                                AcvIntegrationWriteBackData.dataWriteBackToSobject(acvIntegrationObj.Write_Back_Field__c, recordList, (Map < String, Object > )responseMap.get('data'));
                            }
                        }
                    }else if(integrationAction.contains('Arb')){
                        AcvIntegrationWriteBackData.dataWriteBackToSobjectARB(acvIntegrationObj.Write_Back_Field__c, recordList);
                    }
                    else{
                        System.debug('WB Other');
                        AcvIntegrationWriteBackData.dataWriteBackToSobject(acvIntegrationObj.Write_Back_Field__c, recordList, responseMap);
                    } 
                }else if(integrationAction.contains('Unwind Auction') && !Test.isRunningTest()){
                    System.enqueueJob(New AcvIntegrationQueueableJob('Update Saved Auction Dealer',recordList,null));
                    System.debug('Update Saved Auction Dealer Queued');
                }else if(integrationAction.contains('Saved Auction Dealer') && !Test.isRunningTest()){
                    System.enqueueJob(New AcvIntegrationQueueableJob('Update Saved Auction Delete',recordList,null));
                    System.debug('Update Saved Auction Delete Queued');
                }
            }
        } catch (Exception e) { 
            Integration_Result__c intGrationObj = New Integration_Result__c();
            intGrationObj.Integration_Type__c = acvIntegrationObj.Integration_Method__c;
            intGrationObj.Sobject_name__c = !Test.isRunningTest()?recordList.get(0).id.getSObjectType().getDescribe().getName():'Sobject';
            intGrationObj.recordId__c = recordList.get(0).id;
            intGrationObj.Status_Message__c = String.valueOf(e.getStackTraceString());
            intGrationObj.response_message__c = e.getMessage();
            intGrationObj.Request_Message__c = reqBody;
            intGrationObj.Integration_Name__c = acvIntegrationObj.MasterLabel;
            // If the endpoint is blank, there was an issue creating it - Let's recreate it
            if ( String.isBlank( request.getEndpoint() ) ) {
                String url = acvIntegrationObj.EndPoint_URL__c;
                for ( String param : acvIntegrationObj.URL_Parameters__c.split(',') ) {
                    List<String> paramLst = param.split('=');
                    if ( acvIntegrationObj.EndPoint_URL__c.containsIgnoreCase( paramLst[0] ) ) {
                        try {
                            url = acvIntegrationObj.EndPoint_URL__c.replace( paramLst[0], (String) recordList[0].get( paramLst[0]) );
                        } catch ( exception exc ) {
                            // If we can't replace the endpoint properly, continue making the string for error tracking. Leaving the blank 
                        }
                    }
                }
                intGrationObj.Endpoint_URL__c = url;
            } else {
                intGrationObj.Endpoint_URL__c = request.getEndpoint();
            }
            insert intGrationObj; 
        }        
    }
    public void authenticate(){
        String reqBody = AcvIntegrationQueueableJobHandler.createAuthRequestBody();
            try {
                System.debug('reqBody:'+reqBody);
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');
                //String endPointAddress = AcvIntegrationQueueableJobHandler.createEndPointURL(acvIntegrationObj.EndPoint_URL__c,recordList.get(0),acvIntegrationObj.URL_Parameters__c);
                request.setEndpoint('callout:ACVAuth');
                request.setTimeout(60000);
                request.setBody(reqBody);
                request.setHeader('Content-Type', 'application/json');
                System.debug('authRequest:'+request);
                HttpResponse response = h.send(request);
                System.debug('authResp:'+response.getBody());
                // Parsing responce for a single record as only single record id along with status is returned.Code below 
                // needs to be updated to capture bulkified responce json.
                System.debug('Final Responce Message'+response);
                    
                // Write Back Logic When responce is success i.e status code 200
                if (response.getStatusCode() == 200) {
                    //Get user_id and session_token
                    Map < String, Object > responseMap = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                    System.debug('authRespMap:'+responseMap);
                    if (responseMap.size() > 0) {
                        user_id = responseMap.containsKey('user_id') ? String.valueOf(responseMap.get('user_id')) : null;
                        session_token = responseMap.containsKey('session_token') ? String.valueOf(responseMap.get('session_token')) : null;
                        System.debug('Auth user_id:'+user_id+', session_token:'+session_token);
                    }
                }
            } catch (Exception e) { 
                Integration_Result__c intGrationObj = New Integration_Result__c();
                intGrationObj.Integration_Type__c = 'POST';
                intGrationObj.Sobject_name__c = !Test.isRunningTest() ? 'Authentication' : 'Sobject';
                //intGrationObj.recordId__c = recordList.get(0).id;
                intGrationObj.Status_Message__c = String.valueOf(e.getStackTraceString());
                intGrationObj.response_message__c = e.getMessage();
                intGrationObj.Request_Message__c = reqBody;
                intGrationObj.Integration_Name__c = 'Authentication';
                insert intGrationObj; 
            }
    }
    public void logout(){
        String reqBody = AcvIntegrationQueueableJobHandler.createLogoutRequestBody(mBodyValues);
            try {
                System.debug('reqBody:'+reqBody);
                Http h = new Http();
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');
                //String endPointAddress = AcvIntegrationQueueableJobHandler.createEndPointURL(acvIntegrationObj.EndPoint_URL__c,recordList.get(0),acvIntegrationObj.URL_Parameters__c);
                request.setEndpoint('callout:ACVLogout');
                request.setTimeout(60000);
                request.setBody(reqBody);
                request.setHeader('Content-Type', 'application/json');
                System.debug('logoutRequest:'+request);
                HttpResponse logOutresponse = h.send(request);
                System.debug('logoutResp:'+logOutresponse.getBody());
                // Parsing responce for a single record as only single record id along with status is returned.Code below 
                // needs to be updated to capture bulkified responce json.
                System.debug('Final Responce Message'+logOutresponse);
                    
                // Write Back Logic When responce is success i.e status code 200
                if (logOutresponse.getStatusCode() == 200) {
                    System.debug('Logout Success');
                }
            } catch (Exception e) {
                Integration_Result__c intGrationObj = New Integration_Result__c();
                intGrationObj.Integration_Type__c = 'POST';
                intGrationObj.Sobject_name__c = !Test.isRunningTest() ? 'Logout' : 'Sobject';
                //intGrationObj.recordId__c = recordList.get(0).id;
                intGrationObj.Status_Message__c = String.valueOf(e.getStackTraceString());
                intGrationObj.response_message__c = e.getMessage();
                intGrationObj.Request_Message__c = reqBody;
                intGrationObj.Integration_Name__c = 'Logout';
                insert intGrationObj; 
            }
    }
    public List<SObject> requeryRecordList(List<SObject> recordList, Acv_integration__mdt acvIntegrationObj, String sobjectType){
        //Using the custom metadata for this job, create a comma delimited string including each field
        String selectFields;
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                selectFields = String.isEmpty(selectFields) ? acvMetadataObj.Salesforce_Api_Name__c : selectFields + ', '+ acvMetadataObj.Salesforce_Api_Name__c;
            }
        
            //Using the initial recordList, create a set of ids
            Set<String> recordListIds = new Set<String>();
            for(SObject sobj : recordList){
                recordListIds.add((String)sobj.get('Id'));
            }
            //Create a query string using the selectFields string and the recordListIds set built previously
            String query = 'SELECT Auction_Number_Case__c,'+selectFields+' FROM '+sobjectType+' WHERE Id IN :recordListIds';
            List<SObject> updatedRecordList = Database.query(query);
            
            return updatedRecordList;
        }else{
            return recordList;
        }
    }
}