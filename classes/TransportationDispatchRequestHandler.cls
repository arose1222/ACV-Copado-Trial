// This Class works dynamically with most field mappings created as long as the Source_Object__C and Target_Object__C are consistant 
// in the field mapping. The first value in the field map is used to create maps in the code that give information about the object and 
// its fields.

public class TransportationDispatchRequestHandler {
    private static boolean recursion = false; 

    public static void run(Map<Id, sObject> triggerData) {

        //Record Type of case should be Transportation
        //Status should be 'Ready-to-Post'

        if(TransportationDispatchRequestHandler.recursion == true){
            System.debug('Infinite Recursive Loop Stopped');
            return;
        }
        else{
            TransportationDispatchRequestHandler.recursion = true;
            processData(triggerData);
        }
    }


    public static void processData(Map<Id, sObject> triggerData) {
        system.debug('Entering ProcessData code');
        List<Transportation_Board_Field_Mapping__mdt> fieldMapping = [SELECT Source_Object__c,Target_Object__c,Source_Field__c, Target_Field__c, Key_Field__c from Transportation_Board_Field_Mapping__mdt];
        set<String> fieldIdSet = new set<String>();
        for(Transportation_Board_Field_Mapping__mdt fm :fieldMapping){
            fieldIdSet.add(fm.Source_Field__c);
            fieldIdSet.add(fm.Target_Field__c);
        }
        Map<String, EntityParticle> particleMap = new Map<String, EntityParticle>();
        for(EntityParticle ep :[SELECT DurableId, QualifiedApiName, EntityDefinition.QualifiedApiName FROM EntityParticle WHERE DurableId IN :fieldIdSet]){
            if(particleMap.get(ep.DurableId) == null){
                particleMap.put(ep.DurableID, ep);
            }
        }
        List<fieldMapWrapper> fieldWrapperList = new List<fieldMapWrapper>();
        String sourceFieldList = '';
        String targetStringList = '';
        String sourceKey;
        String targetKey;
        for(Transportation_Board_Field_Mapping__mdt fm :fieldMapping){
            fieldMapWrapper fmw = new fieldMapWrapper();
            fmw.sourceObject = particleMap.get(fm.Source_Field__c).EntityDefinition.QualifiedApiName;
            fmw.sourceField = particleMap.get(fm.Source_Field__c).QualifiedAPIName;
            fmw.targetObject = particleMap.get(fm.Target_Field__c).EntityDefinition.QualifiedAPIName;
            fmw.targetField = particleMap.get(fm.Target_Field__c).QualifiedAPIName;
            fmw.isKeyfield = fm.Key_Field__c;
            sourceFieldList += fmw.sourceField + ', ';
            targetStringList += fmw.targetField + ', ';
            if(fmw.isKeyfield){
                sourceKey = fmw.sourceField;
                targetKey = fmw.targetField;
            }
            fieldWrapperList.add(fmw);
        }

        //Get the schema of the Target Object, used later to check if a field is updateable
        Map<String, Schema.SObjectField> objfields = new Map<String, Schema.SObjectField>();
        if(String.ValueOf(triggerData.values()[0].id.getSobjectType()) == fieldWrapperList[0].sourceObject){
            objfields.putAll(Schema.getGlobalDescribe().get(fieldWrapperList[0].targetObject).getDescribe().fields.getMap());
        }
        else if(String.ValueOf(triggerData.values()[0].id.getSobjectType()) == fieldWrapperList[0].targetObject){
            objfields.putAll(Schema.getGlobalDescribe().get(fieldWrapperList[0].sourceObject).getDescribe().fields.getMap());
        }
        else{
            return;
        }
        //Create an Sobject list containing all the related target objects
        List<Id> triggerIdList = New List<Id>();
        Map<String,SObject> triggerMap = New Map<String,SObject>();
        For(sobject s :triggerData.values()){
            if(String.ValueOf(triggerData.values()[0].id.getSobjectType()) == fieldWrapperList[0].sourceObject){
                triggerIdList.add(String.valueOf(s.get(sourceKey)));
                triggerMap.put(String.valueOf(s.get(sourceKey)), s);
            }
            else if(String.ValueOf(triggerData.values()[0].id.getSobjectType()) == fieldWrapperList[0].targetObject){
                triggerIdList.add(String.valueOf(s.get(targetKey)));
                triggerMap.put(String.valueOf(s.get(targetKey)), s);
            }
        }
        String selectQuery = 'SELECT ';
        if(String.ValueOf(triggerData.values()[0].id.getSobjectType()) == fieldWrapperList[0].sourceObject){
            targetStringList = targetStringList.subString(0,targetStringList.length() - 2);
            selectQuery += targetStringList +' FROM '+ fieldWrapperList[0].targetObject + ' WHERE '+targetKey+' IN :triggerIdList AND isDeleted = false';
        }
        else if(String.ValueOf(triggerData.values()[0].id.getSobjectType()) == fieldWrapperList[0].targetObject){
            sourceFieldList = sourceFieldList.subString(0,sourceFieldList.length() - 2);
            selectQuery += sourceFieldList +' FROM '+ fieldWrapperList[0].sourceObject + ' WHERE '+sourceKey+' IN :triggerIdList AND isDeleted = false';
        }
        else{
            return;
        }
        Map<Id, sobject> objMap = New Map<Id, sobject>(Database.query(selectQuery));
        system.debug(objMap);

        //If there are no related Cases then exit
        if(objMap.keySet().size() == 0){
            System.debug('No Related records');
            return;
        }

        //update the target obj using all the maps we made
        List<sObject> updateList = new List<sObject>();
        for(Sobject s :objMap.values()){
            boolean isRecordUpdated = false;
            system.debug(s);
            for(fieldMapWrapper fmw :fieldWrapperList){
                if(String.ValueOf(s.id.getSobjectType()) == fmw.sourceObject){
                    if(objfields.get(fmw.sourceField.toLowerCase()).getDescribe().isupdateable() && s.get(fmw.sourceField) != triggerMap.get(String.ValueOf(s.get(sourceKey))).get(fmw.targetField)){
                        s.put(fmw.sourceField, triggerMap.get(String.ValueOf(s.get(sourceKey))).get(fmw.targetField));
                        isRecordUpdated = true;
                    }
                    
                }
                else if(String.ValueOf(s.id.getSobjectType()) == fmw.targetObject){
                    if(objfields.get(fmw.targetField.toLowerCase()).getDescribe().isupdateable() && s.get(fmw.targetField) != triggerMap.get(String.ValueOf(s.get(targetKey))).get(fmw.sourceField)){
                        s.put(fmw.targetField, triggerMap.get(String.ValueOf(s.get(targetKey))).get(fmw.sourceField));
                        isRecordUpdated = true;
                    }
                }
                else{
                    continue;
                }
            }
            if(isRecordUpdated){
                system.debug(s);
                updateList.add(s);
            }
        }

        CaseUtility.toggleAlreadyProcessed();

        Database.SaveResult[] resultList = Database.update(updateList);

        List<Integration_Result__C> integrationResultList = new List<Integration_Result__c>();
        
        // Output any errors with update to the Integration Results table
        for ( Integer i = 0; i < resultList.size(); i++ ) {
            Database.SaveResult result = resultList[i];
            Integration_Result__c integrationResult = new Integration_Result__c(); 

            if ( !result.isSuccess() ) {
                Database.Error errors = result.getErrors()[0];
                integrationResult.Integration_Name__c = 'Heroku Connect';
                integrationResult.Request_Message__c = String.valueOf(updateList[i]);
                integrationResult.Response_Message__c = errors.getMessage();
                integrationResult.Status_Code__c = 500;
                integrationResult.Status_Message__c = 'Heroku Connect Error';
                integrationResult.recordId__c = String.valueOf(result.getId());
                integrationResultList.add(integrationResult);
            }
        }

        if (integrationResultList.size() > 0) {
            insert integrationResultList;
        }

        CaseUtility.toggleAlreadyProcessed();
    }

    public class fieldMapWrapper{
        public String sourceObject;
        public String targetObject;
        public String sourceField;
        public String targetField;
        public boolean isKeyfield;

        public fieldMapWrapper(){
            this.sourceObject = '';
            this.targetObject = '';
            this.sourceField = '';
            this.targetField = '';
            this.isKeyfield = false;
        } 
    }
    
    public static void setRecursion(Boolean foo){
        recursion = foo;
    }

}