global class PrescreenChangeEvent {

    @testvisible
    public static boolean CauseFailure = false;
    global enum eventType{prescreen_approved, prescreen_rejected}
    private static Map<eventType, String> eventTypeMap = new Map<eventType, String>{EventType.prescreen_approved =>'prescreen-approved', EventType.prescreen_rejected =>'prescreen-rejected'};

    global enum subStatus{auto_approved, approved, approved_with_changes, rejected_with_feedback}
    private static Map<subStatus, String> subStatusMap = new Map<subStatus, String>{subStatus.auto_approved =>'Auto-Approved', subStatus.approved =>'Approved', subStatus.approved_with_changes =>'Approved with Changes/Feedback', subStatus.rejected_with_feedback =>'Rejected with Feedback'};
    
    global static void prescreenEvent(List<SObject> incomingList, subStatus ss, eventType et){

        List<Condition_Report_Prescreen__c> prescreenList = (List<Condition_Report_Prescreen__c>) incomingList;
        List<String> idList = New List<String>();
        List<Prescreen_Event__e> PrescreenEvents = New List<Prescreen_Event__e>();
        Boolean ChangesMade;
        User ownerId = new User();
        List<Condition_Report_Prescreen__c> crplist = new List<Condition_Report_Prescreen__c>();
        Set<Id> userIdSet = new Set<Id>();

        for(Condition_Report_Prescreen__c PrescreenRec :[Select id, (Select id, Question_Notes_Photos__c From CR_Questions__r),
        Inspection_Id__c, Prescreen_GUID__c, CR_Update_by_pre_Screener__c, Closed_Date__c,CreatedDate,
       Account__r.Dealership_Id__c,VCI__r.Identity_Id__c,Make__c,Model__c,Status__c,Question_Notes__c,
       Vehicle_ID__c, Vin__c, Year__c, OwnerId From Condition_Report_Prescreen__c Where Id in :prescreenList])
       {
           crplist.add(PrescreenRec);
           userIdSet.add(PrescreenRec.OwnerId);
       }

       Map<Id,User> userMap = new Map<Id,User>([Select id, id__c from User Where id IN :userIdSet]);
        for(Condition_Report_Prescreen__c PrescreenRec : crplist){
            if(!String.isBlank(PrescreenRec.Inspection_Id__c)){
                List<String> cr_questions = New List<String>();
                String cr_questions_string;
                if(PrescreenRec.CR_Questions__r.size() > 0){
                    for(CR_Question__c crq:PrescreenRec.CR_Questions__r){
                        cr_questions.add(crq.Question_Notes_Photos__c);
                    }
                }
                if(!String.isBlank(PrescreenRec.Question_Notes__c)){
                    cr_questions.add(PrescreenRec.Question_Notes__c);
                }
                if(!cr_questions.isEmpty()){
                    cr_questions_string = string.join(cr_questions,'^#');
                }
                if(PrescreenRec.CR_Update_by_pre_Screener__c == 'Yes'){
                    ChangesMade = true;
                }
                // Create an instance of the event and store it in the Organization_Event__e variable 
                PrescreenEvents.add(new Prescreen_Event__e(   
                    Changes_Made__c = ChangesMade,
                    Completion_Date__c = PrescreenRec.Closed_Date__c,
                    Creation_Date__c = PrescreenRec.CreatedDate,
                    Dealership_Id__c = PrescreenRec.Account__r.Dealership_Id__c,
                    Inspection_Id__c = PrescreenRec.Inspection_Id__c,
                    Inspector_Identity_Id__c = PrescreenRec.VCI__r.Identity_Id__c,
                    Make__c = PrescreenRec.Make__c,
                    Model__c = PrescreenRec.Model__c,
                    Prescreen_Comments__c = cr_questions_string,
                    Prescreener_Id__c = userMap.get(prescreenRec.ownerId)?.Id__c,
                    Prescreen_Id__c = PrescreenRec.Prescreen_GUID__c,
                    Prescreen_Status__c = PrescreenRec.Status__c,                        
                    Prescreen_Sub_Status__c = subStatusMap.get(ss),
                    Vehicle_Id__c = PrescreenRec.Vehicle_ID__c,
                    Vin__c = PrescreenRec.Vin__c,
                    Year__c = PrescreenRec.Year__c,
                    event_type__c = eventTypeMap.get(et)));
                    idList.add(PrescreenRec.Id);
            }
              
        }
        //If the Event variable is NOT empty then fire the Publisher 
        if(!PrescreenEvents.isempty()){
            prescreenpublisher(PrescreenEvents, idList);
        }       
    }
    global static void prescreenAutoApproveEvent(List<InspectionDefinition> incomingList){

        List<String> idList = New List<String>();
        List<Prescreen_Event__e> PrescreenEvents = New List<Prescreen_Event__e>();
        for(InspectionDefinition Idef : incomingList ){
            if(!String.isBlank(Idef.InspectionId)){

                // Create an instance of the event and store it in the Organization_Event__e variable 
                PrescreenEvents.add(new Prescreen_Event__e(   
                    Changes_Made__c = false,
                    Completion_Date__c = System.now(),
                    Dealership_Id__c = String.valueof(Idef.dealershipId),
                    Inspection_Id__c = Idef.InspectionId,
                    Inspector_Identity_Id__c = Idef.inspectorIdentityId,
                    Make__c = Idef.inspectedVehicle.make,
                    Model__c = Idef.inspectedVehicle.model,
                    Prescreen_Status__c = 'Closed',                        
                    Prescreen_Sub_Status__c = subStatusMap.get(subStatus.auto_approved),
                    Vehicle_Id__c = Idef.inspectedVehicle.vehicleId,
                    Vin__c = Idef.inspectedVehicle.vin,
                    Year__c = Idef.inspectedVehicle.year,
                    event_type__c = eventTypeMap.get(EventType.prescreen_approved)));
                    idList.add(Idef.InspectionId);
            }
        }
        //If the Event variable is NOT empty then fire the Publisher 
        if(!PrescreenEvents.isempty()){
            prescreenpublisher(PrescreenEvents, idList);
        }       
    }
    public static void prescreenpublisher(List<Prescreen_Event__e> PrescreenEvents, List<String> idList){ 
        // Call method to publish list of Prescreen events       
        List<Database.SaveResult> results = EventBus.publish(PrescreenEvents);
        List<Integration_Result__c> integrationList = new List<Integration_Result__c>();
        //Connecting the Prescreen Record id of the Platform event and Inserting them into the Integration Results table
        for (Integer i=0 ; i < results.size(); i++ ){
            Database.SaveResult Result = results[i];	
            Integration_Result__c integrationObj = New Integration_Result__c();
            integrationObj.Integration_Type__c = 'Platform Event';
            integrationObj.Sobject_name__c = 'Prescreen__e';
            integrationObj.Integration_Name__c = 'PrescreenChangeEvent';
            integrationObj.recordId__c = idlist[i];
            integrationObj.Request_Message__c = String.valueof(PrescreenEvents[i]);

            if (!result.isSuccess() || CauseFailure) {
                if(result.getErrors().size() > 0 || CauseFailure)
                        IdentityHelper.makeApexLog(acvutility.currentLineNumber(), 
                        'PrescreenEvents: Prescreen Event failed to publish to event bus', 
                        SplunkHelper.LOGLEVEL.ERROR, 'PrescreenEvents', 
                        'Prescreen Event failed to publish to event bus', 
                        'Prescreen');
            }
            else{
                integrationObj.Status_Code__c = 200;
                integrationObj.Status_Message__c = String.valueof(result);          
            }
            integrationList.add(integrationObj);
        }   
        if (integrationList.size() > 0){
            insert integrationList;
        }           
    }  
}