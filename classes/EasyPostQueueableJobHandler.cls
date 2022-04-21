public class EasyPostQueueableJobHandler {
	
	public static String createShipmentRequestBody(List<sobject> recordList, EasyPost_Integration__mdt easyPostIntegrationObj) {
		List<String> listOfToSerialized = New List<String>();
        Map<String,Map<String,EasyPost_Field_Mapping__mdt>> mapSFfieldEasyPostMapping = new Map<String,Map<String,EasyPost_Field_Mapping__mdt>>();

        //Map<Id,Map<String,Integer>> mapEasyPostPickListValues = new Map<Id,Map<String,Integer>>();
        Map<String,Set<Id>> newMapReferenceFieldIdsMap = new Map<String,Set<Id>>();
        Map<String,Map<Id,object>> mapSfkeyRefenceIdAndValue = new Map<String,Map<Id,object>>();

        //Map of SF API Names, field info
        if (easyPostIntegrationObj.EasyPost_Integration_Field_Mappings__r.size() > 0) {
            for (EasyPost_Field_Mapping__mdt easypostMetadataObj: easyPostIntegrationObj.EasyPost_Integration_Field_Mappings__r) {
            	if(!mapSFfieldEasyPostMapping.containsKey(easypostMetadataObj.Parent_Object__c)){
            		mapSFfieldEasyPostMapping.put(easypostMetadataObj.Parent_Object__c, new Map<String,EasyPost_Field_Mapping__mdt>());
            	}
                mapSFfieldEasyPostMapping.get(easypostMetadataObj.Parent_Object__c).put(easypostMetadataObj.Salesforce_Api_Name__c, easypostMetadataObj);
            }
        }
        System.debug('fieldMapping:'+mapSFfieldEasyPostMapping);

        ACV_Adress_Field__mdt acvAddress = [SELECT Id, Label, Address_Line_1__c, Address_Line_2__c, City__c, Country__c, Phone__c, State__c, Zipcode__c FROM ACV_Adress_Field__mdt WHERE DeveloperName = 'ACV_Auctions_Inc' LIMIT 1];
        System.debug('acvAddress:'+acvAddress);
        //build the JSON string to create a shipment using the dynamic custom metadata type values
        for (sobject obj: recordList) {
        	JSONGenerator gen = JSON.createGenerator(false);
				gen.writeStartObject(); 
				gen.writeFieldName('shipment');
				gen.writeStartObject();

			for(String objectName : mapSFfieldEasyPostMapping.keySet()){
				System.debug('objectNameJSON:'+objectName);
				Map<String,EasyPost_Field_Mapping__mdt> objectFieldMap = mapSFfieldEasyPostMapping.get(objectName);
				gen.writeFieldName(objectName);
				gen.writeStartObject();
				for (String sfApiName: objectFieldMap.keyset()) {
					System.debug('fieldName:'+sfApiName+', fieldType:'+objectFieldMap.get(sfApiName).Field_Type__c);
		            if(objectFieldMap.get(sfApiName).Field_Type__c == 'Boolean') {
		                if(objectName == 'from_address'){
		                	gen.writeBooleanField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, (Boolean)acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c));
		                }else{
			                if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes') {
			                    gen.writeBooleanField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, true);
			                } else {
			                    gen.writeBooleanField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, false);
			                }
			            }
		            }
		            /*else if(objectFieldMap.get(sfApiName).Field_Type__c == 'PickList') {
		                String pickListValue = (String) obj.get(sfApiName);
		                gen.writeStringField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, mapAcvPickListValues.get(objectFieldMap.get(sfApiName).id).get(pickListValue));
		            }*/
		            else if(objectFieldMap.get(sfApiName).Field_Type__c == 'DateTime') {
		            	if(objectName == 'from_address'){
		                	gen.writeDateTimeField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, ((DateTime) acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c)));
		                }else{
		                	gen.writeDateTimeField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, ((DateTime) obj.get(sfApiName)));
		                }
		            }
		            else if(objectFieldMap.get(sfApiName).Field_Type__c == 'Integer') {
		            	if(objectName == 'from_address'){
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Integer.valueOf(acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c)));
		                }else{
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Integer.valueOf((obj.get(sfApiName))));
		                }
		            }
		            else if(objectFieldMap.get(sfApiName).Field_Type__c == 'Phone') {
		            	if(objectName == 'from_address'){
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Long.valueOf(String.valueOf(acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c)).replaceAll('[^0-9]', '')));
		                }else{
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Long.valueOf(String.valueOf(obj.get(sfApiName)).replaceAll('[^0-9]', '')));
		                }
		            }
		            else {
		            	if(objectName == 'from_address'){
		            		String val = (String)acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c) == null ? '' : (String)acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c);
		                	gen.writeStringField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, val);
		                }else{
		                	String val = (String)obj.get(sfApiName) == null ? '' : (String)obj.get(sfApiName);
		                	gen.writeStringField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, val);
		                }
		            }
		        }
		        gen.writeEndObject();
            }

            gen.writeEndObject();
            gen.writeEndObject();
            System.debug('serializeJSON');
            String jsonBody = gen.getAsString();
            listOfToSerialized.add(jsonBody);
            System.debug('serializeJSONComplete');
        }

		String requestbody = listOfToSerialized[0];
		return requestBody;
	}

	public static String createUnwindShipmentRequestBody(List<sobject> recordList, EasyPost_Integration__mdt easyPostIntegrationObj) {
		List<String> listOfToSerialized = New List<String>();
        Map<String,Map<String,EasyPost_Field_Mapping__mdt>> mapSFfieldEasyPostMapping = new Map<String,Map<String,EasyPost_Field_Mapping__mdt>>();

        //Map<Id,Map<String,Integer>> mapEasyPostPickListValues = new Map<Id,Map<String,Integer>>();
        Map<String,Set<Id>> newMapReferenceFieldIdsMap = new Map<String,Set<Id>>();
        Map<String,Map<Id,object>> mapSfkeyRefenceIdAndValue = new Map<String,Map<Id,object>>();

        //Map of SF API Names, field info
        if (easyPostIntegrationObj.EasyPost_Integration_Field_Mappings__r.size() > 0) {
            for (EasyPost_Field_Mapping__mdt easypostMetadataObj: easyPostIntegrationObj.EasyPost_Integration_Field_Mappings__r) {
            	if(!mapSFfieldEasyPostMapping.containsKey(easypostMetadataObj.Parent_Object__c)){
            		mapSFfieldEasyPostMapping.put(easypostMetadataObj.Parent_Object__c, new Map<String,EasyPost_Field_Mapping__mdt>());
            	}
                mapSFfieldEasyPostMapping.get(easypostMetadataObj.Parent_Object__c).put(easypostMetadataObj.Salesforce_Api_Name__c, easypostMetadataObj);
            }
        }
        System.debug('fieldMapping:'+mapSFfieldEasyPostMapping);

        ACV_Adress_Field__mdt acvAddress = [SELECT Id, Label, Address_Line_1__c, Address_Line_2__c, City__c, Country__c, Phone__c, State__c, Zipcode__c FROM ACV_Adress_Field__mdt WHERE DeveloperName = 'ACV_Auctions_Inc' LIMIT 1];
        System.debug('acvAddress:'+acvAddress);
        //build the JSON string to create a shipment using the dynamic custom metadata type values
        for (sobject obj: recordList) {
        	JSONGenerator gen = JSON.createGenerator(false);
				gen.writeStartObject();
				gen.writeFieldName('shipment');
				gen.writeStartObject();

			for(String objectName : mapSFfieldEasyPostMapping.keySet()){
				System.debug('objectNameJSON:'+objectName);
				Map<String,EasyPost_Field_Mapping__mdt> objectFieldMap = mapSFfieldEasyPostMapping.get(objectName);
				gen.writeFieldName(objectName);
				gen.writeStartObject();
				for (String sfApiName: objectFieldMap.keyset()) {
					System.debug('fieldName:'+sfApiName+', fieldType:'+objectFieldMap.get(sfApiName).Field_Type__c);
		            if(objectFieldMap.get(sfApiName).Field_Type__c == 'Boolean') {
		                if(objectName == 'to_address'){
		                	gen.writeBooleanField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, (Boolean)acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c));
		                }else{
			                if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes') {
			                    gen.writeBooleanField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, true);
			                } else {
			                    gen.writeBooleanField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, false);
			                }
			            }
		            }
		            /*else if(objectFieldMap.get(sfApiName).Field_Type__c == 'PickList') {
		                String pickListValue = (String) obj.get(sfApiName);
		                gen.writeStringField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, mapAcvPickListValues.get(objectFieldMap.get(sfApiName).id).get(pickListValue));
		            }*/
		            else if(objectFieldMap.get(sfApiName).Field_Type__c == 'DateTime') {
		            	if(objectName == 'to_address'){
		                	gen.writeDateTimeField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, ((DateTime) acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c)));
		                }else{
		                	gen.writeDateTimeField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, ((DateTime) obj.get(sfApiName)));
		                }
		            }
		            else if(objectFieldMap.get(sfApiName).Field_Type__c == 'Integer') {
		            	if(objectName == 'to_address'){
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Integer.valueOf(acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c)));
		                }else{
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Integer.valueOf((obj.get(sfApiName))));
		                }
		            }
		            else if(objectFieldMap.get(sfApiName).Field_Type__c == 'Phone') {
		            	if(objectName == 'to_address'){
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Long.valueOf(String.valueOf(acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c)).replaceAll('[^0-9]', '')));
		                }else{
		                	gen.writeNumberField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, Long.valueOf(String.valueOf(obj.get(sfApiName)).replaceAll('[^0-9]', '')));
		                }
		            }
		            else {
		            	if(objectName == 'to_address'){
		            		String val = (String)acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c) == null ? '' : (String)acvAddress.get(objectFieldMap.get(sfApiName).Salesforce_Api_Name__c);
		                	gen.writeStringField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, val);
		                }else{
		                	String val = (String)obj.get(sfApiName) == null ? '' : (String)obj.get(sfApiName);
		                	gen.writeStringField(objectFieldMap.get(sfApiName).Reference_Object_API_Name__c, val);
		                }
		            }
		        }
		        gen.writeEndObject();
            }

            gen.writeEndObject();
            gen.writeEndObject();
            System.debug('serializeJSON');
            String jsonBody = gen.getAsString();
            listOfToSerialized.add(jsonBody);
            System.debug('serializeJSONComplete');
        }

		String requestbody = listOfToSerialized[0];
		return requestBody;
	}

	public static String createEndPointURL(String endpoint, sobject sobj, String urlParameters){
        if(urlParameters != null){
	        String updatedEndpoint = '';
	        List<String> parameterList = urlParameters.split(',');
	        for(String param:parameterList){
	            List<String> paramList = param.split('=');
	            if(endpoint.containsIgnoreCase(paramList.get(0))){
	                updatedEndpoint = endpoint.replace(paramList.get(0), (String)sobj.get(paramList.get(1)));
	                endpoint = updatedEndpoint;
	            }
	        }
	        return updatedEndpoint;
        }else{
        	return endpoint;
        }
    }

	public static void getServiceRate(List<sobject> recordList, List<Object> ratesList, String service){
		String shipmentId;
    	String rateId;

		System.debug('Start getServiceRate');
    	Map<String,Object> ratesMap = new Map<String,Object>();
    	for(Object proposedRate :ratesList){
    		Map<String,Object> rateAttributes = (Map<String,Object>)proposedRate;
    		System.debug('rA:'+rateAttributes);
    		String rateService = (String)rateAttributes.get('service');
			System.debug('rateService:'+rateService);
    		if(service != null && rateService != null && rateService == service){
    			rateId = (String)rateAttributes.get('id');
    			shipmentId = (String)rateAttributes.get('shipment_id');
				System.debug('shipmentId:'+shipmentId);
    			System.debug('rateId:'+rateId);
			}
    	}

    	Map<String,object> buyShipmentValues = new Map<String, object>();
		if(shipmentId != null && rateId != null){
			buyShipmentValues.put('rate_id',rateId);
			buyShipmentValues.put('shipment_id',shipmentId);
			System.debug('buyShipmentValues:'+buyShipmentValues);
			System.enqueueJob(new EasyPostQueueableJob('Buy Shipment', recordList, buyShipmentValues));
			System.debug('queueBuyShipment');
		}else{
			List<sobject> sobjectListToBeUpdated = new List<sobject>();
			for(sobject sobj: recordList) {
				Sobject newsobj = sobj.clone(true, false, false, false);
				String noStdOvernightRate = System.Label.EP_Std_Overnight_Not_Found;
				newsobj.put('Easypost_Tracker__c', noStdOvernightRate);
				System.debug('newsobj:'+newsobj);
				sobjectListToBeUpdated.add(newsobj);
			}
            if(sobjectListToBeUpdated.size() > 0) {
                update sobjectListToBeUpdated;
            }
		}

	}

    public static void getCheapestRate(List<sobject> recordList, List<Object> ratesList){
    	Double cheapestRate;
    	String shipmentId;
    	String rateId;

    	System.debug('Start getCheapestRate');
    	Map<String,Object> ratesMap = new Map<String,Object>();
    	for(Object proposedRate :ratesList){
    		Map<String,Object> rateAttributes = (Map<String,Object>)proposedRate;
    		System.debug('rA:'+rateAttributes);
    		Double cost = Double.valueOf(rateAttributes.get('rate'));
    		if(cheapestRate == null){
    			cheapestRate = cost;
    			rateId = (String)rateAttributes.get('id');
    			shipmentId = (String)rateAttributes.get('shipment_id');
    		}else{
    			if(cost < cheapestRate){
    				cheapestRate = cost;
    				rateId = (String)rateAttributes.get('id');
    				shipmentId = (String)rateAttributes.get('shipment_id');
    			}
    		}
    		System.debug('shipmentId:'+shipmentId);
    		System.debug('rateId:'+rateId);
    		System.debug('cheapestRate:'+cheapestRate);
    	}

    	Map<String,object> buyShipmentValues = new Map<String, object>();
		if(shipmentId != null && rateId != null){
			buyShipmentValues.put('rate_id',rateId);
			buyShipmentValues.put('shipment_id',shipmentId);
			System.debug('buyShipmentValues:'+buyShipmentValues);
			System.enqueueJob(new EasyPostQueueableJob('Buy Shipment', recordList, buyShipmentValues));
			System.debug('queueBuyShipment');
		}

    }

    public static String createBuyShipmentRequestBody(List<sobject> recordList, EasyPost_Integration__mdt easyPostIntegrationObj, Map<String,object> mBodyValues){
    	JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		gen.writeFieldName('rate');
		gen.writeStartObject();
		gen.writeStringField('id', String.valueOf(mBodyValues.get('rate_id')));
		gen.writeEndObject();
		gen.writeEndObject();

		String jsonBody = gen.getAsString();
		System.debug('buyBody:'+jsonBody);
		return jsonBody;
    }

    public static String createBuyEndPointURL(String endpoint, Map<String,object> mBodyValues, String urlParameters){
        if(urlParameters != null){
	        String updatedEndpoint = '';
	        List<String> parameterList = urlParameters.split(',');
	        for(String param:parameterList){
	            List<String> paramList = param.split('=');
	            if(endpoint.containsIgnoreCase(paramList.get(0))){
	                updatedEndpoint = endpoint.replace(paramList.get(0), String.valueOf(mBodyValues.get(paramList.get(1))));
	                endpoint = updatedEndpoint;
	            }
	        }
	        return updatedEndpoint;
        }else{
        	return endpoint;
        }
    }

}