public class ConditionReportReviewGeneration extends TriggerInterface{

    @TestVisible
    private static List<CR_Review_Trigger__mdt> mockMetadata;

    public class ClassNotFoundException extends Exception {}

    private Boolean isInsert = false;

    public override void afterInsert(List<SObject> newList){
        isInsert = true;
        List<Condition_Report__c> newCRList = (List<Condition_Report__c>)newList;
        List<CR_Review_Trigger__mdt> criteriaList = new List<CR_Review_Trigger__mdt>();
        if(Test.isRunningTest() && mockMetadata != null){
            criteriaList = mockMetadata;
        }
        else{
            criteriaList = [Select id, Query_Path__c, Value_Type__c, Trigger_Value__c, Class_Name__c, Is_Advanced_Logic__c,Prescreen_Reason__c, Assigned_Queue__c, Assigned_Queue__r.MasterLabel, Assigned_Queue__r.Priority__c  from CR_Review_Trigger__mdt where Active__c = True];
        }
        generateReviewRecords(getvalidCRs(newCRList, new List<Condition_Report__c>(), criteriaList));
    }
    
    public override void afterUpdate(List<SObject> oldList,List<SObject> newList){
        List<Condition_Report__c> newCRList = (List<Condition_Report__c>)newList;
        List<CR_Review_Trigger__mdt> criteriaList = new List<CR_Review_Trigger__mdt>();
        if(Test.isRunningTest() && mockMetadata != null){
            criteriaList = mockMetadata;
        }
        else{
            criteriaList = [Select id, Query_Path__c, NamespacePrefix, Value_Type__c, Trigger_Value__c, Class_Name__c, Is_Advanced_Logic__c,Prescreen_Reason__c, Assigned_Queue__c, Assigned_Queue__r.MasterLabel, Assigned_Queue__r.Priority__c from CR_Review_Trigger__mdt where Active__c = True];
        }
        generateReviewRecords(getvalidCRs(newCRList, (List<Condition_Report__c>)oldList, criteriaList));
    }

    private string getFieldValue(String queryPath, SObject record){
        String[] fields = queryPath.split('\\.');
        SObject tempObject;
        String returnValue;
        if(fields.size() == 1){
            returnValue = String.valueOf(record.get(fields[0]));
        }
        else{
            for(Integer i = 0; i < fields.size(); i++){
                if(returnValue == null){
                    if(i == 0){
                        tempObject = record.getSObject(fields[i]);
                    }
                    else if(tempObject != null && i < fields.size()-1){
                        tempObject = tempObject.getSobject(fields[i]);
                    }
                    else if(tempObject != null){
                        returnValue = String.valueOf(tempObject.get(fields[i]));
                    }
                }
            }
        }
        return returnValue;
    }

    private void generateReviewRecords(List<prescreenReasonWrapper> crList){
        if(crList != null && crList.size() > 0){
            // Gather queues. CR Queue is default queue if we can't find a queue.
            Set<String> queueNameSet = new Set<String>{'CR Queue'};
            for( prescreenReasonWrapper cr : crList ){
                if( String.isNotBlank(cr.queueName) ) queueNameSet.add(cr.queueName);
            }
            Map<String,Group> queueNameToQueueMap = new Map<String,Group>();
            for( Group thisQueue : [ SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN : queueNameSet ] ){
                queueNameToQueueMap.put(thisQueue.Name, thisQueue );
            }
            List<Condition_Report_Prescreen__c> insertList = new List<Condition_Report_Prescreen__c>();
            for(prescreenReasonWrapper cr :crList){
                Id queueId = queueNameToQueueMap.get(cr.queueName) == null ? queueNameToQueueMap.get('CR Queue').Id : queueNameToQueueMap.get(cr.queueName).Id;
                cr.crp = new Condition_Report_Prescreen__c(
                    Condition_Report__c = cr.cr.id, 
                    OwnerId = queueId, 
                    VCI__c = cr.cr.VCI_Creator__c,
                    Seller_Dealership__c = cr.cr.Dealership__c,
                    Vehicle__c = cr.cr.Vehicle__c
                );
                insertList.add(cr.crp);
            }
            if(insertList.size() > 0){
                insert insertList;
            }
            List<Prescreen_Reason__c> prList = new List<Prescreen_Reason__c>();
            for(prescreenReasonWrapper cr :crList){
                for(String reason :cr.reasonList){
                    prList.add(new Prescreen_Reason__c(Condition_Report_Prescreen__c = cr.crp.id, Name = reason));
                }
            }
            if(prList.size() > 0){
                insert prList;
            }
        }
    }

    private List<prescreenReasonWrapper> getValidCRs(List<Condition_Report__c> crList, List<Condition_Report__c> oldCrList, List<CR_Review_Trigger__mdt> criteriaList){
        if(criteriaList.size() > 0){
            String queryString = 'Select Id, ';
            List<Id> crIdList = new List<Id>();
            Map<Id,Condition_Report__c> crOldMap = new Map<Id,Condition_Report__c>();
            Set<String> queryPathSet = new Set<String>();
            //adding values to the set that we will always need
            queryPathSet.add('VCI_Creator__c');
            queryPathSet.add('CR_Doc_Complete__c');
            queryPathSet.add('Floor_Price__c');
            queryPathSet.add('Auto_Sell__c');
            queryPathSet.add('Vehicle__r.Most_Recent_Seller__c');
            queryPathSet.add('Dealership__c');
            queryPathSet.add('Inspection_Guid__c');
            for(CR_Review_Trigger__mdt crt :criteriaList){
                //we will always have floor price based on our logic to tell when a CR is completed
                //so we exclude it from the query string, we still may want to look to this for other logic down the road
                if(!String.isBlank(crt.Query_Path__c) && crt.Query_Path__c != 'Floor_Price__c' && !crt.Is_Advanced_Logic__c){
                    queryPathSet.add(crt.Query_Path__c);
                }
            }

            for(Condition_Report__c cr: crList){
                crIdList.add(cr.id);
            }
            if(isInsert == false){
                for(Condition_Report__c cr :oldCrList){
                    if(crOldMap.get(cr.id) == null){
                        crOldMap.put(cr.id,cr);
                    }
                }
            }
            queryString += String.join(new List<String>(queryPathSet),',')+' ';
            queryString += ', (Select Id from Condition_Report_Review__r) From Condition_Report__c where id in :crIdList';
            List<sObject> queryList = Database.query(queryString);
            List<Condition_Report__c> refinedCRList = (List<Condition_Report__c>)queryList;
            set<Condition_Report__c> returnSet = new set<Condition_Report__c>();
            Map<String, prescreenReasonWrapper> crwMap = new Map<String, prescreenReasonWrapper>();

            for(CR_Review_Trigger__mdt crt :criteriaList){
                if(!crt.Is_Advanced_Logic__c){
                    if(String.isBlank(crt.query_path__c)){
                            continue;
                        }
                    for(Condition_Report__c cr :refinedCRList){
                        if(String.isBlank(cr.Inspection_Guid__c) && cr.Condition_Report_Review__r.size() < 1 && ((cr.Floor_Price__c >= 1 && isInsert) || (cr.Floor_Price__c >= 1 && (crOldMap.get(cr.id).Floor_Price__c == 0 || crOldMap.get(cr.id).Floor_Price__c == null)))){
                            String fieldValue = getFieldValue(crt.query_path__c, (SObject)cr);
                            if(fieldValue != null){
                                if(crt.value_type__c == 'Integer'){
                                    if(Integer.valueOf(fieldValue) == Integer.valueOf(crt.Trigger_Value__c)){
                                        if(crwMap.get(cr.id) == null){
                                            crwMap.put(cr.id, new prescreenReasonWrapper(cr));
                                        }
                                        crwMap.get(cr.id).addReason(crt.Prescreen_Reason__c);
                                        if( (String.isNotBlank(crt.Assigned_Queue__c) || (Test.isRunningTest() && String.isNotBlank(crt.Assigned_Queue__r.MasterLabel))) && crwMap.get(cr.id).checkPriority(Integer.valueOf(crt.Assigned_Queue__r.Priority__c)) ){
                                            crwMap.get(cr.id).setPriority(crt.Assigned_Queue__r.MasterLabel, Integer.valueOf(crt.Assigned_Queue__r.Priority__c) );
                                        }
                                    }
                                }
                                if(crt.value_type__c == 'String'){
                                    if(fieldValue == crt.Trigger_Value__c){
                                        if(crwMap.get(cr.id) == null){
                                            crwMap.put(cr.id, new prescreenReasonWrapper(cr));
                                        }
                                        crwMap.get(cr.id).addReason(crt.Prescreen_Reason__c);
                                        if( (String.isNotBlank(crt.Assigned_Queue__c) || (Test.isRunningTest() && String.isNotBlank(crt.Assigned_Queue__r.MasterLabel))) && crwMap.get(cr.id).checkPriority(Integer.valueOf(crt.Assigned_Queue__r.Priority__c)) ){
                                            crwMap.get(cr.id).setPriority(crt.Assigned_Queue__r.MasterLabel, Integer.valueOf(crt.Assigned_Queue__r.Priority__c) );
                                        }
                                    }
                                }
                                if(crt.value_type__c == 'Boolean'){
                                    if(Boolean.valueOf(fieldValue) == Boolean.valueOf(crt.Trigger_Value__c)){
                                        if(crwMap.get(cr.id) == null){
                                            crwMap.put(cr.id, new prescreenReasonWrapper(cr));
                                        }
                                        crwMap.get(cr.id).addReason(crt.Prescreen_Reason__c);
                                        if( (String.isNotBlank(crt.Assigned_Queue__c) || (Test.isRunningTest() && String.isNotBlank(crt.Assigned_Queue__r.MasterLabel))) && crwMap.get(cr.id).checkPriority(Integer.valueOf(crt.Assigned_Queue__r.Priority__c)) ){
                                            crwMap.get(cr.id).setPriority(crt.Assigned_Queue__r.MasterLabel, Integer.valueOf(crt.Assigned_Queue__r.Priority__c) );
                                        }
                                    }
                                }
                                if(crt.value_type__c == 'Double'){
                                    if(Double.valueOf(fieldValue) >= Double.valueOf(crt.Trigger_Value__c)){
                                        if(crwMap.get(cr.id) == null){
                                            crwMap.put(cr.id, new prescreenReasonWrapper(cr));
                                        }
                                        crwMap.get(cr.id).addReason(crt.Prescreen_Reason__c);
                                        if( (String.isNotBlank(crt.Assigned_Queue__c) || (Test.isRunningTest() && String.isNotBlank(crt.Assigned_Queue__r.MasterLabel))) && crwMap.get(cr.id).checkPriority(Integer.valueOf(crt.Assigned_Queue__r.Priority__c)) ){
                                            crwMap.get(cr.id).setPriority(crt.Assigned_Queue__r.MasterLabel, Integer.valueOf(crt.Assigned_Queue__r.Priority__c) );
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else{
                    Type handlerType = Type.forName(crt.Class_Name__c);
                    if(handlerType == null) {
                        throw new ClassNotFoundException('CR Prscreen Generation: handler class not found for ' + crt.Class_Name__c);
                    }
                    else{
                        List<Condition_Report__c> tempCrList = (List<Condition_Report__c>)((ClassInterface)handlerType.newInstance()).handle(refinedCRList);
                        if(tempCrList.size() > 0){
                            for(Condition_Report__c cr :tempCrList){
                                if(String.isBlank(cr.Inspection_Guid__c) && cr.Condition_Report_Review__r.size() < 1 && ((cr.Floor_Price__c >= 1 && isInsert) || (cr.Floor_Price__c >= 1 && (crOldMap.get(cr.id).Floor_Price__c == 0 || crOldMap.get(cr.id).Floor_Price__c == null)))){
                                    if(crwMap.get(cr.id) == null){
                                        crwMap.put(cr.id, new prescreenReasonWrapper(cr));
                                    }
                                    crwMap.get(cr.id).addReason(crt.Prescreen_Reason__c);
                                    if( (String.isNotBlank(crt.Assigned_Queue__c) || (Test.isRunningTest() && String.isNotBlank(crt.Assigned_Queue__r.MasterLabel))) && crwMap.get(cr.id).checkPriority(Integer.valueOf(crt.Assigned_Queue__r.Priority__c)) ){
                                        crwMap.get(cr.id).setPriority(crt.Assigned_Queue__r.MasterLabel, Integer.valueOf(crt.Assigned_Queue__r.Priority__c) );
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return crwMap.values();
        }
        return null;
    }

    public class prescreenReasonWrapper{
        public Condition_Report__c cr;
        public Condition_Report_Prescreen__c crp;
        public List<String> reasonList;
        public Integer queuePriority;
        public String queueName;

        prescreenReasonWrapper(){
            this.cr = new Condition_Report__c();
            this.crp = new Condition_Report_Prescreen__c();
            this.reasonList = new List<String>();
            this.queuePriority = null;
            this.queueName = '';
        }

        prescreenReasonWrapper(Condition_Report__c c){
            this.cr = c;
            this.crp = new Condition_Report_Prescreen__c();
            this.reasonList = new List<String>();
            this.queuePriority = null;
            this.queueName = '';
        }

        prescreenReasonWrapper(Condition_Report__c c, String r){
            this.cr = c;
            this.crp = new Condition_Report_Prescreen__c();
            this.reasonList = new List<String>();
            this.reasonList.add(r);
            this.queuePriority = null;
            this.queueName = '';
        }

        public void addReason(String r){
            if(r != null){
                this.reasonList.add(r);
            }
        }
        public void setPriority( String name, Integer priority ){
            this.queueName = name;
            this.queuePriority = priority;
        }
        public Boolean checkPriority( Integer prioirty ){
            return this.queuePriority == null || this.queuePriority > prioirty;
        }
    }
}