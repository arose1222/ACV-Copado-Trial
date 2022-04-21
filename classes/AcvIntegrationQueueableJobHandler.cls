public class AcvIntegrationQueueableJobHandler {
    
    public static String createRequestBody(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, Integer >> mapAcvPickListValues = New Map < id, Map < String, Integer >> ();
        Map < String, Set < id >> newMapReferenceFieldIdsMap = New Map < String, Set < id >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        For(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (Integer)acvPickListObj.Picklist_Value_Integer__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, Integer > {
                    acvPickListObj.MasterLabel => (Integer)acvPickListObj.Picklist_Value_Integer__c
                        });
            }
        }
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
        /* 
            If there are reference fields in Custom Metadata Then below codes will use to reduce the count of SOQL
            for Every Row. For Each Coloum declared as reference 1 Soql will run and a map of Sfapi name and a map of 
            id and value will be formed to fetech Exact value for inner Loop.
        */
        
        for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
            If(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                for (sobject obj: recordList) {
                    if (newMapReferenceFieldIdsMap.containskey(sfApiName)) {
                        newMapReferenceFieldIdsMap.get(sfApiName).add((String) obj.get(sfApiName));
                    } else {
                        newMapReferenceFieldIdsMap.put(sfApiName, New Set < id > { (String) obj.get(sfApiName) });
                    }
                }
            }
        }
        
        for (String sfApiName: newMapReferenceFieldIdsMap.keyset()) {
            Set < id > idSet = newMapReferenceFieldIdsMap.get(sfApiName);
            String query = String.format('Select id,{0} from {1}  where id in:idSet', new String[] {
                mapSFfieldAcvMapping.get(sfApiName).SF_Api_Name_When_Reference__c, mapSFfieldAcvMapping.get(sfApiName).Reference_Object_Api_Name__c });
            System.debug('Query String' + query);
            List < Sobject > sobjectList = Database.query(query);
            if (sobjectList.size() > 0) {
                for (sobject sobj: sobjectList) {
                    if (mapSfkeyRefenceIdAndValue.containskey(sfApiName)) {
                        mapSfkeyRefenceIdAndValue.get(sfApiName).put(sobj.id, sobj.get(mapSFfieldAcvMapping.get(sfApiName).SF_Api_Name_When_Reference__c));
                    } else {
                        mapSfkeyRefenceIdAndValue.put(sfApiName, New Map < id, Object > {
                            sobj.id => sobj.get(mapSFfieldAcvMapping.get(sfApiName).SF_Api_Name_When_Reference__c)
                                });
                    }
                }
            }
        }

              
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        for (sobject obj: recordList) {
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                IF(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes') {
                        mapFieldsMapping.put(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, 1);
                    } else {
                        mapFieldsMapping.put(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, 0);
                    }
                }
                else IF(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList') {
                    String pickListValue = (String) obj.get(sfApiName);
                    mapFieldsMapping.put(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue));
                }
                else If(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                    mapFieldsMapping.put(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName)));
                }
                else If(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    mapFieldsMapping.put(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, ((DateTime) obj.get(sfApiName)).format('dd/M/yyyy HH:mm:ss'));
                }
                else {
                    mapFieldsMapping.put(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, obj.get(sfApiName));
                    // mapFieldsMapping.put('insurance','0');
                }
            }
            ListOfToSerialized.add(mapFieldsMapping);
        }
        
        String requstbody = json.serialize(ListOfToSerialized);
        return json.serialize(ListOfToSerialized.get(0));
    }

    public static String createRequestBody_Pricing(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, Integer >> mapAcvPickListValues = New Map < id, Map < String, Integer >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        For(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (Integer)acvPickListObj.Picklist_Value_Integer__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, Integer > {
                    acvPickListObj.MasterLabel => (Integer)acvPickListObj.Picklist_Value_Integer__c
                        });
            }
        }
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
              
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        //Start array of objects
        gen.writeFieldName('pricing_recommendations');
        gen.writeStartArray();
        for (sobject obj: recordList) {
            system.debug('PR Record:'+obj);
            //for each record create an object containing each field
            gen.writeStartObject();
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes' || obj.get(sfApiName) == 'Active') {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, true);
                    } else {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, false);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Integer'){
                    gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Integer.valueOf((obj.get(sfApiName))));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList') {
                    String pickListValue = (String) obj.get(sfApiName);
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, String.valueOf(mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue)));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, ((String) mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName))));
                    
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    gen.writeDateTimeField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, DateTime.valueOf(DateTime.valueOf(obj.get(sfApiName)).format('YYYY-MM-dd HH:mm:ss.000000')));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Date'){
                    if(obj.get(sfApiName) != null){
                        gen.writeDateField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Date.valueOf(Date.valueOf(obj.get(sfApiName))));
                    }
                    else{
                        gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, '');
                    }
                    
                }
                else {
                    String val = String.valueOf(obj.get(sfApiName)) == null ? '' : String.valueOf(obj.get(sfApiName));
		            gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, val);
                }
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        System.debug('PR_Body:'+jsonBody);
        return jsonBody;
    }

    public static String createRequestBody_Titles(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, String >> mapAcvPickListValues = New Map < id, Map < String, String >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        for(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, Picklist_Value_Text__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (String)acvPickListObj.Picklist_Value_Text__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, String > {
                    acvPickListObj.MasterLabel => (String)acvPickListObj.Picklist_Value_Text__c
                        });
            }
        } 
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
              
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        //Start array of objects
        gen.writeFieldName('title_status_updates');
        gen.writeStartArray();
        for (sobject obj: recordList) {
            system.debug('Titles Record:'+obj);
            //for each record create an object containing each field
            gen.writeStartObject();
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes' || obj.get(sfApiName) == 'Active') {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, true);
                    } else {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, false);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Integer'){
                    gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Integer.valueOf((obj.get(sfApiName))));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList') {
                    String pickListValue = (String) obj.get(sfApiName);
                    System.debug('plv:'+pickListValue);
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, String.valueOf(mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue)));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, ((String) mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName))));
                    
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    gen.writeDateTimeField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, DateTime.valueOf(DateTime.valueOf(obj.get(sfApiName)).format('dd/M/yyyy HH:mm:ss')));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Date'){
                    if(obj.get(sfApiName) != null){
                        gen.writeDateField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Date.valueOf(Date.valueOf(obj.get(sfApiName))));
                    }
                    else{
                        gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, '');
                    }
                    
                }
                else {
                    String val = String.valueOf(obj.get(sfApiName)) == null ? '' : String.valueOf(obj.get(sfApiName));
		            gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, val);
                }
            }
            gen.writeEndObject();
        }
        gen.writeEndArray(); 
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        System.debug('Titles_Body:'+jsonBody);
        return jsonBody;
    }

    public static String createRequestBody_TransReq(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, String >> mapAcvPickListValues = New Map < id, Map < String, String >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        for(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, Picklist_Value_Text__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (String)acvPickListObj.Picklist_Value_Text__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, String > {
                    acvPickListObj.MasterLabel => (String)acvPickListObj.Picklist_Value_Text__c
                        });
            }
        } 
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
               
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        //Start array of objects 
        if(acvIntegrationObj.DeveloperName == 'Create_Transportation_Request'){
            gen.writeFieldName('transportation_request_create_params');
        }else{
            gen.writeFieldName('transportation_request_updates');
        }
        gen.writeStartArray();
        for (sobject obj: recordList) {
            system.debug('Trans Record:'+obj);
            
            //for each record create an object containing each field
            gen.writeStartObject();
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes' || obj.get(sfApiName) == 'Active') {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, true);
                    } else {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, false);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Integer'){
                    if(obj.get(sfApiName) != null){
                        gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Integer.valueOf((obj.get(sfApiName))));
                    }
                    else{
                        gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, 0);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Decimal') {
                    if(obj.get(sfApiName) != null){
                        gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, (Decimal) obj.get(sfApiName));
                    }
                    else{
                        gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, 0.00);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList' && obj.get(sfApiName) != null) {
                    String pickListValue = (String) obj.get(sfApiName);
                    System.debug('plv:'+pickListValue);
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, String.valueOf(mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue)));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference' && obj.get(sfApiName) != null) {
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, ((String) mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName))));
                    
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    if(obj.get(sfApiName) != null){
						DateTime dateval = (DateTime) obj.get(sfApiName);
                    		gen.writeDateTimeField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, DateTime.valueOf(DateTime.valueOf(dateval.format('YYYY-MM-dd HH:mm:ss'))));
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Date'){
                    if(obj.get(sfApiName) != null){
                        gen.writeDateField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Date.valueOf(Date.valueOf(obj.get(sfApiName))));
                    }
                    
                }
                else {
                    String val = String.valueOf(obj.get(sfApiName)) == null ? '' : String.valueOf(obj.get(sfApiName));
		            gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, val);
                }
            }
            gen.writeEndObject();
        }
        gen.writeEndArray(); 
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        System.debug('Trans_Body:'+jsonBody);
        return jsonBody;
    }

    public static String createRequestBody_SADelete(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, String >> mapAcvPickListValues = New Map < id, Map < String, String >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        for(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, Picklist_Value_Text__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (String)acvPickListObj.Picklist_Value_Text__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, String > {
                    acvPickListObj.MasterLabel => (String)acvPickListObj.Picklist_Value_Text__c
                        });
            }
        } 
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
              
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        //Start array of objects
        gen.writeFieldName('saved_auction_ids');
        gen.writeStartArray();
        for (sobject obj: recordList) {
            system.debug('SADelete Record:'+obj);
            //for each record create an object containing each field
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes' || obj.get(sfApiName) == 'Active') {
                        gen.writeBoolean(true);
                    } else {
                        gen.writeBoolean(false);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Integer'){
                    gen.writeNumber( Integer.valueOf((obj.get(sfApiName))));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList') {
                    String pickListValue = (String) obj.get(sfApiName);
                    System.debug('plv:'+pickListValue);
                    gen.writeString(String.valueOf(mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue)));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                    gen.writeString(((String) mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName))));
                    
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    gen.writeDateTime(DateTime.valueOf(DateTime.valueOf(obj.get(sfApiName)).format('dd/M/yyyy HH:mm:ss')));
                }
                else {
                    String val = String.valueOf(obj.get(sfApiName)) == null ? '' : String.valueOf(obj.get(sfApiName));
		            gen.writeString(val);
                }
            }
        }
        gen.writeEndArray(); 
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        System.debug('SADelete_Body:'+jsonBody);
        return jsonBody;
    }

    public static String createRequestBody_SADealer(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, String >> mapAcvPickListValues = New Map < id, Map < String, String >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        for(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, Picklist_Value_Text__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (String)acvPickListObj.Picklist_Value_Text__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, String > {
                    acvPickListObj.MasterLabel => (String)acvPickListObj.Picklist_Value_Text__c
                        });
            }
        } 
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
              
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        //Start array of objects
        gen.writeFieldName('saved_auction_dealer_updates');
        gen.writeStartArray();
        for (sobject obj: recordList) {
            system.debug('SADealer Record:'+obj);
            //for each record create an object containing each field
            gen.writeStartObject();
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes' || obj.get(sfApiName) == 'Active') {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, true);
                    } else {
                        gen.writeBooleanField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, false);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Integer'){
                    gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Integer.valueOf((obj.get(sfApiName))));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Static'){
                    gen.writeNumberField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, Integer.valueOf(sfApiName));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList') {
                    String pickListValue = (String) obj.get(sfApiName);
                    System.debug('plv:'+pickListValue);
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, String.valueOf(mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue)));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, ((String) mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName))));
                    
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    gen.writeDateTimeField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, DateTime.valueOf(DateTime.valueOf(obj.get(sfApiName)).format('dd/M/yyyy HH:mm:ss')));
                }
                else {
                    String val = String.valueOf(obj.get(sfApiName)) == null ? '' : String.valueOf(obj.get(sfApiName));
                    gen.writeStringField(mapSFfieldAcvMapping.get(sfApiName).MasterLabel, val);
                }
            }
            gen.writeEndObject();
        }
        gen.writeEndArray(); 
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        System.debug('SADealer_Body:'+jsonBody);
        return jsonBody;
    }

    public static String createRequestBody_UnwindAuction(List < sobject > recordList, Acv_integration__mdt acvIntegrationObj) {
        List < Map < String, object >> ListOfToSerialized = New List < Map < String, object >> ();
        Map < string, ACV_Field_Mapping__mdt > mapSFfieldAcvMapping = new Map < string, ACV_Field_Mapping__mdt > ();
        Map < id, Map < String, String >> mapAcvPickListValues = New Map < id, Map < String, String >> ();
        Map < String, Map < id, object >> mapSfkeyRefenceIdAndValue = New Map < String, Map < id, object >> ();
        
        for(Acv_Picklist_Values__mdt acvPickListObj: [select id, DeveloperName, MasterLabel, Picklist_Value_Integer__c, Picklist_Value_Text__c, ACV_Field_Mapping__c from Acv_Picklist_Values__mdt]) {
            if (mapAcvPickListValues.containskey(acvPickListObj.ACV_Field_Mapping__c)) {
                mapAcvPickListValues.get(acvPickListObj.ACV_Field_Mapping__c).put(acvPickListObj.MasterLabel, (String)acvPickListObj.Picklist_Value_Text__c);
            } else {
                mapAcvPickListValues.put(acvPickListObj.ACV_Field_Mapping__c, New Map < String, String > {
                    acvPickListObj.MasterLabel => (String)acvPickListObj.Picklist_Value_Text__c
                        });
            }
        } 
        System.debug('mapAcvPickListValues' + mapAcvPickListValues);
        if (acvIntegrationObj.ACV_Field_Mapping__r.size() > 0) {
            for (ACV_Field_Mapping__mdt acvMetadataObj: acvIntegrationObj.ACV_Field_Mapping__r) {
                mapSFfieldAcvMapping.put(acvMetadataObj.Salesforce_Api_Name__c, acvMetadataObj);
            }
        }
              
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        //Start array of objects
        gen.writeFieldName('auction_ids');
        gen.writeStartArray();
        for (sobject obj: recordList) {
            system.debug('UnwindAuc Record:'+obj);
            //for each record create an object containing each field
            for (String sfApiName: mapSFfieldAcvMapping.keyset()) {
                if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Boolean') {
                    if (obj.get(sfApiName) == True || obj.get(sfApiName) == 'Yes' || obj.get(sfApiName) == 'Active') {
                        gen.writeBoolean(true);
                    } else {
                        gen.writeBoolean(false);
                    }
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Integer'){
                    gen.writeNumber(Integer.valueOf((obj.get(sfApiName))));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'PickList') {
                    String pickListValue = (String) obj.get(sfApiName);
                    System.debug('plv:'+pickListValue);
                    gen.writeString(String.valueOf(mapAcvPickListValues.get(mapSFfieldAcvMapping.get(sfApiName).id).get(pickListValue)));
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'Reference') {
                    gen.writeString(((String) mapSfkeyRefenceIdAndValue.get(sfApiName).get((ID) obj.get(sfApiName))));
                    
                }
                else if(mapSFfieldAcvMapping.get(sfApiName).Field_Type__c == 'DateTime') {
                    gen.writeDateTime(DateTime.valueOf(DateTime.valueOf(obj.get(sfApiName)).format('dd/M/yyyy HH:mm:ss')));
                }
                else {
                    String val = String.valueOf(obj.get(sfApiName)) == null ? '' : String.valueOf(obj.get(sfApiName));
		            gen.writeString(val);
                }
            }
        }
        gen.writeEndArray(); 
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        System.debug('UnwindAuc_Body:'+jsonBody);
        return jsonBody;
    }
    
    public static String createAuthRequestBody(){
        Map < String, object > mapFieldsMapping = New Map < String, object > ();
        mapFieldsMapping.put('email','{!$Credential.Username}');
        mapFieldsMapping.put('password','{!$Credential.Password}');
        mapFieldsMapping.put('web',true);
        return json.serialize(mapFieldsMapping);
    }

    public static String createLogoutRequestBody(Map < String, object > mapFieldsMapping){
        return json.serialize(mapFieldsMapping);
    }

    public static String createEndPointURL(String Endpoint,sobject sobj, String UrlParameters){
        if(UrlParameters != null){
            String UpdatedEndpoint = '';
            List<String> parameterList = UrlParameters.split(',');
            for(String param:parameterList){
                List<String> paramList = param.split('=');
                if(Endpoint.containsIgnoreCase(paramList.get(0))){
                    UpdatedEndpoint=Endpoint.replace(paramList.get(0), (String)sobj.get(paramList.get(1)));
                    Endpoint = UpdatedEndpoint;
                }
            }
            return UpdatedEndpoint;
        }else{
            return Endpoint;
        }
    }
}