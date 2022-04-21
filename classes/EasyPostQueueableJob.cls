public class EasyPostQueueableJob implements Queueable, Database.AllowsCallouts {
	
	String integrationAction;
    List < sobject > recordList = New List < sobject > ();
    Map<String,object>  mBodyValues = new Map<String,object>();
    public static String service {get;set;}

	public EasyPostQueueableJob(String integrationAction, List<sobject> recordList, Map<String,object> mBodyValues) {
        this.integrationAction = integrationAction;
        this.recordList = recordList;
        this.mBodyValues = mBodyValues;
    }

	public void execute(QueueableContext context) {
        List <Integration_Result__c> integrationList = new List<Integration_Result__c>();

        EasyPost_Integration__mdt easyPostIntegrationObj = new EasyPost_Integration__mdt();
        easyPostIntegrationObj = [SELECT id, DeveloperName, MasterLabel, Write_Back_Field__c, EndPoint_URL__c, URL_Parameters__c, Integration_Method__c,
                (SELECT id, DeveloperName, MasterLabel, Parent_Object__c, Field_Type__c, Salesforce_Api_Name__c, SF_API_Name_When_Referenced__c, Reference_Object_Api_Name__c FROM EasyPost_Integration_Field_Mappings__r)
                FROM EasyPost_Integration__mdt WHERE MasterLabel =: integrationAction];
        
		String reqBody; 
		if(integrationAction == 'Buy Shipment'){
			reqBody = EasyPostQueueableJobHandler.createBuyShipmentRequestBody(recordList, easyPostIntegrationObj, mBodyValues);
		}else if(integrationAction == 'Create Shipment Unwind'){
			reqBody = EasyPostQueueableJobHandler.createUnwindShipmentRequestBody(recordList, easyPostIntegrationObj);
		}else{
			reqBody = EasyPostQueueableJobHandler.createShipmentRequestBody(recordList, easyPostIntegrationObj);
		}
		System.debug(reqBody);
		try {
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod(easyPostIntegrationObj.Integration_Method__c);
            String endPointAddress;
            if(integrationAction == 'Buy Shipment'){
            	endPointAddress = EasyPostQueueableJobHandler.createBuyEndPointURL(easyPostIntegrationObj.EndPoint_URL__c,mBodyValues,easyPostIntegrationObj.URL_Parameters__c);
            }else{
            	endPointAddress = EasyPostQueueableJobHandler.createEndPointURL(easyPostIntegrationObj.EndPoint_URL__c,recordList.get(0),easyPostIntegrationObj.URL_Parameters__c);
            }
            request.setEndpoint('callout:EasyPost' + endPointAddress.split('easypost.com').get(1));
            request.setHeader('Authorization', '{!$Credential.Password}');
            System.debug('reqBody  ' + reqBody);
            request.setBody(reqBody);
            request.setTimeout(60000);
            request.setHeader('Content-Type', 'application/json');
            System.debug('request:'+request);
            HttpResponse response = h.send(request);
            
            // Parsing responce for a single record as only single record id along with status is returned.Code below 
            // needs to be updated to capture bulkified responce json.
            System.debug('Final Response Message'+response);
            for (Sobject sobj: recordList) {
                //Get the EasyPost Shipping Service from the record
                service = (String)sobj.get('EasyPost_Shipping_Service__c');
                System.debug('get Service:'+service);
                //Build the Integration Result
                Integration_Result__c intGrationObj = new Integration_Result__c();
                intGrationObj.Integration_Type__c = easyPostIntegrationObj.Integration_Method__c;
                intGrationObj.Sobject_name__c = !Test.isRunningTest()?recordList.get(0).id.getSObjectType().getDescribe().getName():'Sobject';
                intGrationObj.recordId__c = sobj.id;
                intGrationObj.Request_Message__c = reqBody;
                intGrationObj.Integration_Name__c = easyPostIntegrationObj.MasterLabel;
                intGrationObj.Status_Message__c = response.getStatus();
                intGrationObj.Status_Code__c = response.getStatusCode();
                intGrationObj.response_message__c = response.getBody();
                integrationList.add(intGrationObj);
            }
            if (integrationList.size() > 0)
                insert integrationList;
                
            // Write Back Logic When responce is success i.e status code 200
            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                System.debug('status code:'+response.getStatusCode());
                Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
                System.debug('responseMap:'+responseMap);
                if(integrationAction.contains('Create Shipment') && responseMap.size() > 0 && responseMap.get('rates') != null){
                	List<Object> responseRatesList = (List<Object>)responseMap.get('rates');
                	System.debug('responseMapRates:'+responseRatesList);
                	//EasyPostQueueableJobHandler.getCheapestRate(recordList, responseRatesList);
                    if(service == 'CHEAPEST'){
                        EasyPostQueueableJobHandler.getCheapestRate(recordList, responseRatesList);
                    }else{
                        EasyPostQueueableJobHandler.getServiceRate(recordList, responseRatesList, service);
                    }
                }
                if (responseMap.size() > 0 && easyPostIntegrationObj.Write_Back_Field__c != Null) {
                	System.debug('perform write back:'+integrationAction);
                    EasyPostWriteBackData.dataWriteBackToSobject(easyPostIntegrationObj.Write_Back_Field__c, recordList, responseMap);
                }
            }
        } catch (Exception e) {
            Integration_Result__c intGrationObj = New Integration_Result__c();
            intGrationObj.Integration_Type__c = easyPostIntegrationObj.Integration_Method__c;
            intGrationObj.Sobject_name__c = !Test.isRunningTest()?recordList.get(0).id.getSObjectType().getDescribe().getName():'Sobject';
            intGrationObj.recordId__c = recordList.get(0).id;
            intGrationObj.Status_Message__c = String.valueOf(e.getStackTraceString());
            intGrationObj.response_message__c = e.getMessage();
            intGrationObj.Request_Message__c = reqBody;
            intGrationObj.Integration_Name__c = easyPostIntegrationObj.MasterLabel;
            insert intGrationObj; 
        }


	}

}