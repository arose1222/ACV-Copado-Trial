public with sharing class RescheduleServiceAppointmentController {
    
    private static BusinessHours acvBusinessHours{
        get{
            if ( acvBusinessHours == null ) {
                acvBusinessHours = [ SELECT Id FROM BusinessHours WHERE Name = '48 Hour Expiration Date Hours' LIMIT 1 ];
            }
            return acvBusinessHours;
        }
        set;
    }
    
    @AuraEnabled
    public static List<WorkOrderLineItem> getWOLIsForServiceAppointment(String searchId){
        
        List<WorkOrderLineItem> wolis = [SELECT Id, LineItemNumber, Status, Description, Year_and_Make_and_Model__c, External_Record_guid__c 
                                            FROM WorkOrderLineItem WHERE WorkOrderId = :searchId ORDER BY LineItemNumber ASC];
        if(!wolis.isEmpty()) {
            return wolis;
        }
        else {
            return null;
        }
    }

    @AuraEnabled
    public static Response rescheduleAppointment(String serApptJSON, List<WorkOrderLineItem> woliList){

        /*-------------------------------   Splunk Logging -------------------------------*/

        PreventWOLIFieldUpdates.skipTrigger = true;
        Savepoint sp = Database.setSavepoint();
        List<Database.SaveResult> srs;
        Database.SaveResult sr;
        string logMessage = 'Service Appointment Reschedule Submission: ' + serApptJSON + '\n';
        Set<string> successfulIds = new Set<string>();
        List<SplunkHelper.SFErrorRecord> errorRecords = new List<SplunkHelper.SFErrorRecord>();
        Response res = new Response();
        SplunkHelper.LOGLEVEL logLevel;
        Exception ex;

        try {

            /*-------------------------------   Pull Info From JSON -------------------------------*/

            Map<String, Object> saInfo = new Map<String,Object>();
            saInfo = (Map<String,Object>)JSON.deserializeUntyped(serApptJSON);
            Id saID = (Id)saInfo.get('Id');
            Id woID = (Id)saInfo.get('Work_Order__c');
            Id workTypeId = (Id)saInfo.get('WorkTypeId');
            Id reschedule = (Id)saInfo.get('Reschedule__c');
            Id currSerRes = (Id)saInfo.get('Current_Service_Resource__c');
            Boolean rescheduled = (Boolean)saInfo.get('Has_Been_Rescheduled__c');
            String cannotCompleteReason = (String)saInfo.get('Cannot_Complete_Reason__c');
            String ganttColor = (String)saInfo.get('FSL__GanttColor__c');

            DateTime schedStartTime;
            List<String> dateStrings = ((String)saInfo.get('SchedStartTime')).split('T');
            if(dateStrings.size() > 0) {
                Date schedStartDate = convertDate(dateStrings[0]);
                Integer hour = Integer.valueOf(dateStrings[1].left(2));
                Integer minute = Integer.valueOf(dateStrings[1].substringBetween(':',':'));
                schedStartTime = DateTime.newInstanceGMT(schedStartDate, Time.newInstance(hour, minute, 0, 0));
            }
            else {
                schedStartTime = null;
            }
            
            DateTime originalDueDate;
            dateStrings = ((String)saInfo.get('Original_Due_Date__c')).split('T');
            if(dateStrings.size() > 0) {
                Date origDueDate = convertDate(dateStrings[0]);
                Integer hour = Integer.valueOf(dateStrings[1].left(2));
                Integer minute = Integer.valueOf(dateStrings[1].substringBetween(':',':'));
                originalDueDate = DateTime.newInstanceGMT(origDueDate, Time.newInstance(hour, minute, 0, 0));
            }
            
            /*-------------------------------   Update Service Appointment -------------------------------*/

            ServiceAppointment serAppt = new ServiceAppointment(Id=saID, Work_Order__c=woID, Has_Been_Rescheduled__c=rescheduled, Reschedule__c=reschedule, FSL__GanttColor__c=ganttColor, 
                                                            SchedStartTime=schedStartTime, Cannot_Complete_Reason__c=cannotCompleteReason, Current_Service_Resource__c=currSerRes);
            List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();

            if(serAppt.Reschedule__c == null) {
                Reschedule__c newResched = new Reschedule__c();

                sr = Database.Insert(newResched);
                logmessage += genericDatabaseLog(new List<Database.SaveResult>{sr}, 'Reschedule', 'insert');
                successfulIds.addAll(getSuccessfulIds(new List<Database.SaveResult>{ sr }));
                errorRecords.addAll(getErrorRecords(new List<Database.SaveResult>{ sr }));
                if(errorRecords.size() > 0) {
                    throw new DMLErrorException('Error while inserting Reschedule record. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
                }
                
                serAppt.Reschedule__c=newResched.Id;
            }

            

            serAppt.Has_Been_Rescheduled__c = true;
            Map<String, String> resourceMap = ACVUtility.getStaticResourceURLByName(new List<String>{'FSLRescheduled'});
            saToUpdate.add(serAppt);

            srs = Database.Update(saToUpdate);
            logmessage += genericDatabaseLog(srs, 'Service Appointment', 'update');
            successfulIds.addAll(getSuccessfulIds(srs));
            errorRecords.addAll(getErrorRecords(srs));
            if(errorRecords.size() > 0) {
                throw new DMLErrorException('Error while updating Service Appointments. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
            }

            /*-------------------------------   Clone Work Order -------------------------------*/

            WorkOrder origWO = [SELECT Id, (SELECT Id, ServiceResourceId, RelatedRecordId FROM ResourcePreferences), (SELECT Id, Work_Order__c FROM Email_Notification_Subscriptions__r) 
                            FROM WorkOrder WHERE Id = :serAppt.Work_Order__c LIMIT 1];

            sObject origSObject = (sObject) origWO;
            List<sObject> origSObjects = new List<sObject> {origSObject};
            List<sObject> clonedSObjects = cloneObjects(origSObjects, origSObject.getsObjectType());
            WorkOrder rescheduleWO = (WorkOrder)clonedSObjects[0];

            rescheduleWO.Status = 'New';
            rescheduleWO.Assigned_Date_Time__c = null;
            rescheduleWO.Completed_Date_Time__c = null;
            rescheduleWO.Occurrence__c = null;
            rescheduleWO.OwnerId = UserInfo.getUserId();

            origWO.External_Record_guid__c = null;

            sr = Database.Update(origWO);
            logmessage += genericDatabaseLog(new List<Database.SaveResult>{sr}, 'Work Order', 'update');
            successfulIds.addAll(getSuccessfulIds(new List<Database.SaveResult>{ sr }));
            errorRecords.addAll(getErrorRecords(new List<Database.SaveResult>{ sr }));
            if(errorRecords.size() > 0) {
                throw new DMLErrorException('Error while updating original Work Order. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
            }

            ServiceAppointment rescheduleSA = new ServiceAppointment();
            DateTime endTime = ACVUtility.addBusinessDays(DateTime.now(), 2, acvBusinessHours);
            rescheduleSA.Is_Reschedule__c = true;
            rescheduleSA.EarliestStartTime = DateTime.now();
            rescheduleSA.DueDate = endTime;
            rescheduleSA.Reschedule__c = serAppt.Reschedule__c;
            rescheduleSA.Original_Due_Date__c = originalDueDate;
            rescheduleSA.FSL__GanttColor__c = serAppt.FSL__GanttColor__c;

            rescheduleWO.Service_Appt_Map_Id__c = CreateServiceAppointment.getUniqueId();
            CreateServiceAppointment.SAOverrideMap.put(rescheduleWO.Service_Appt_Map_Id__c,rescheduleSA);

            sr = Database.Insert(rescheduleWO);
            logmessage += genericDatabaseLog(new List<Database.SaveResult>{sr}, 'Work Order', 'insert');
            successfulIds.addAll(getSuccessfulIds(new List<Database.SaveResult>{ sr }));
            errorRecords.addAll(getErrorRecords(new List<Database.SaveResult>{ sr }));
            if(errorRecords.size() > 0) {
                throw new DMLErrorException('Error while inserting rescheduled Work Order. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
            }

            /*-------------------------------   Clone Work Order Line Items -------------------------------*/
            
            List<WorkOrderLineItem> wolisToInsert = new List<WorkOrderLineItem>();
            List<WorkOrderLineItem> wolisToUpdate = new List<WorkOrderLineItem>();
            List<Id> woliIdList = new List<Id>();
            if(woliList != null) {
                for(WorkOrderLineItem woli : woliList) {
                    woliIdList.add(woli.Id);
                }
            }
            
            if(!woliIdList.isEmpty()) {
                List<String> workOrderLineItemFields = new List<String>{};
                workOrderLineItemFields.addAll(woliList[0].getsObjectType().getDescribe().fields.getMap().keySet());
                String allFieldsQuery = 'SELECT ' + workOrderLineItemFields.get(0);     
                for (Integer i=1 ; i < workOrderLineItemFields.size() ; i++){
                    allFieldsQuery += ', ' + workOrderLineItemFields.get(i);
                }    
                allFieldsQuery+=' FROM WorkOrderLineItem WHERE ID IN (\''+woliIdList.get(0)+ 
                                        '\'';
                for (Integer i=1 ; i < woliIdList.size() ; i++){
                    allFieldsQuery += ', \'' + woliIdList.get(i) + '\'';
                }    
                allFieldsQuery += ')';

                List<WorkOrderLineItem> completeWOLIsList = Database.query(allFieldsQuery);
                for(WorkOrderLineItem woli : completeWOLIsList) {
                    WorkOrderLineItem clonedWOLI = woli.clone(false, true, false, false);
                    clonedWOLI.WorkOrderId = rescheduleWO.Id;
                    clonedWOLI.Status = 'New';
                    wolisToInsert.add(clonedWOLI);
                    if(woli.External_Record_guid__c != null) {
                        woli.External_Record_guid__c = null;
                        woli.Status = 'Rescheduled';
                        wolisToUpdate.add(woli);
                    }
                }

                srs = Database.Update(wolisToUpdate);
                logmessage += genericDatabaseLog(srs, 'Work Order Line Item', 'update');
                successfulIds.addAll(getSuccessfulIds(srs));
                errorRecords.addAll(getErrorRecords(srs));
                if(errorRecords.size() > 0) {
                    throw new DMLErrorException('Error while updating original Work Order Line Items. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
                }

                srs = Database.Insert(wolisToInsert);
                logmessage += genericDatabaseLog(srs, 'Work Order Line Item', 'insert');
                successfulIds.addAll(getSuccessfulIds(srs));
                errorRecords.addAll(getErrorRecords(srs));
                if(errorRecords.size() > 0) {
                    throw new DMLErrorException('Error while inserting Work Order Line Items for the rescheduled Work Order. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
                }
            }
            else {
                logMessage += 'No Work Order Line Items to Insert or Update.\n';
            }

            /*-------------------------------   Clone Resource Preferences -------------------------------*/

            Map<Id, ResourcePreference> resPrefMap = new Map<Id, ResourcePreference>();
            List<ResourcePreference> existingResPrefs = [SELECT Id, RelatedRecordId, ServiceResourceId FROM ResourcePreference WHERE RelatedRecordId=:rescheduleWO.Id];
            for(ResourcePreference resPref : existingResPrefs) {
                resPrefMap.put(resPref.ServiceResourceId, resPref);
            }

            origSObjects.clear();
            clonedSObjects.clear();
            for(ResourcePreference resPref : origWO.ResourcePreferences) {
                if(!resPrefMap.containsKey(resPref.ServiceResourceId)) {
                    origSObject = (sObject) resPref;
                    origSObjects.add(origSObject);
                }
            }

            if(!origSObjects.isEmpty()) {
                clonedSObjects = cloneObjects(origSObjects, origSObject.getsObjectType()); 
            }
            if(!clonedSObjects.isEmpty()) {
                List<ResourcePreference> clonedResourcePreferences = (List<ResourcePreference>)clonedSObjects;
                for(ResourcePreference resPref : clonedResourcePreferences) {
                    resPref.RelatedRecordId = rescheduleWO.Id;
                }

                srs = Database.Insert(clonedResourcePreferences);
                logmessage += genericDatabaseLog(srs, 'Resource Preference', 'insert');
                successfulIds.addAll(getSuccessfulIds(srs));
                errorRecords.addAll(getErrorRecords(srs));
                if(errorRecords.size() > 0) {
                    throw new DMLErrorException('Error while inserting Resource Preferences for the rescheduled Work Order. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
                }
            }
            else {
                logMessage += 'No Resource Preferences to Insert.\n';
            }

            /*-------------------------------   Clone Email Notification Subscriptions -------------------------------*/

            rescheduleSA = [SELECT Id, AppointmentNumber, Has_Been_Rescheduled__c, Is_Reschedule__c FROM ServiceAppointment WHERE Work_Order__c = :rescheduleWO.Id LIMIT 1];
            List<Email_Notification_Subscription__c> serviceAppEmailNotifSubs = [SELECT Id, Service_Appointment__c FROM Email_Notification_Subscription__c WHERE Service_Appointment__c = :serAppt.Id];

            List<Email_Notification_Subscription__c> emailNotifSubsToUpdate = new List<Email_Notification_Subscription__c>();
            for(Email_Notification_Subscription__c emailNotifSub : origWO.Email_Notification_Subscriptions__r) {
                emailNotifSub.Work_Order__c = rescheduleWO.Id;
                emailNotifSubsToUpdate.add(emailNotifSub);
            }

            for(Email_Notification_Subscription__c emailNotifSub : serviceAppEmailNotifSubs) {
                emailNotifSub.Service_Appointment__c = rescheduleSA.Id;
                emailNotifSubsToUpdate.add(emailNotifSub);
            }

            if(!emailNotifSubsToUpdate.isEmpty()) {
                srs = Database.Update(emailNotifSubsToUpdate);
                logmessage += genericDatabaseLog(srs, 'Email Notification Subscription', 'update');
                successfulIds.addAll(getSuccessfulIds(srs));
                errorRecords.addAll(getErrorRecords(srs));
                if(errorRecords.size() > 0) {
                    throw new DMLErrorException('Error while updating Email Notification Subscriptions to the rescheduled Work Order/Service Appointments. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
                }
            }
            else {
                logMessage += 'No Email Notification Subscriptions to Update.\n';
            }

            /*-------------------------------   Create Reschedule History -------------------------------*/

            Reschedule_History__c newRescheduleHistory = new Reschedule_History__c(Reschedule__c=serAppt.Reschedule__c, Rescheduled_By__c=UserInfo.getUserId(), Rescheduled_Datetime__c=DateTime.now(), 
                                                                                Rescheduled_From__c=serAppt.Id, Rescheduled_To__c=rescheduleSA.Id, Service_Resource__c=serAppt.Current_Service_Resource__c, 
                                                                                Original_Scheduled_Start_Time__c=serAppt.SchedStartTime, Reason_for_Reschedule__c=serAppt.Cannot_Complete_Reason__c);

            sr = Database.Insert(newRescheduleHistory);
            logmessage += genericDatabaseLog(new List<Database.SaveResult>{sr}, 'Reschedule History', 'insert');
            successfulIds.addAll(getSuccessfulIds(new List<Database.SaveResult>{ sr }));
            errorRecords.addAll(getErrorRecords(new List<Database.SaveResult>{ sr }));
            if(errorRecords.size() > 0) {
                throw new DMLErrorException('Error while inserting rescheduled History. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
            }

            String fullRecordURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + rescheduleSA.Id;
            List<String> returnString= new List<String>();
            returnString.add(rescheduleSA.AppointmentNumber);
            returnString.add(fullRecordURL);
            res.status = 'Success';
            res.recordURL = fullRecordURL;
            res.newSANumber = rescheduleSA.AppointmentNumber;

            logLevel = (errorRecords.size() > 0) ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;

        }
        catch(Exception e) {
            res.status = 'Failure';
            res.message = e.getMessage();
            logLevel = SplunkHelper.LOGLEVEL.FATAL;
            ex = e;
            Database.RollBack(sp);
        }

        makeLog(logMessage, logLevel, errorRecords, successfulIds, ex);
        return res;
    }


    public static List<sObject> cloneObjects(List<sObject> sObjects,
                                        Schema.SObjectType objectType){    
        List<Id> sObjectIds = new List<Id>{};
        List<String> sObjectFields = new List<String>{};
        List<sObject> clonedSObjects = new List<sObject>{};    

        // Get all the fields from the selected object type using 
        // the get describe method on the object type.
        if(objectType != null){
            sObjectFields.addAll(
            objectType.getDescribe().fields.getMap().keySet());
        }    

        // If there are no objects sent into the method, 
        // then return an empty list
        if (sObjects != null && !sObjects.isEmpty() && !sObjectFields.isEmpty()){    
            
            for (sObject objectInstance: sObjects){
                sObjectIds.add(objectInstance.Id);
            }

            String allSObjectFieldsQuery = 'SELECT ' + sObjectFields.get(0);     
            for (Integer i=1 ; i < sObjectFields.size() ; i++){
                allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
            }    
            allSObjectFieldsQuery+=' FROM '+objectType.getDescribe().getName()+ 
                               ' WHERE ID IN (\''+sObjectIds.get(0)+ 
                               '\'';
            for (Integer i=1 ; i < sObjectIds.size() ; i++){
                allSObjectFieldsQuery += ', \'' + sObjectIds.get(i) + '\'';
            }    
            allSObjectFieldsQuery += ')';    

            try{
                for (SObject sObjectFromDatabase : Database.query(allSObjectFieldsQuery)){
                    clonedSObjects.add(sObjectFromDatabase.clone(false,true,false,false));  
                }
            } catch (exception e){
                throw new DMLErrorException('Error while retieving/cloning records. Trying to process: ' + objectType.getDescribe().getName() + '. All records have been rolled back to their original state, and no rescheduled Work Order/Service Appointment will exist.');
            }
        }      
        
        return clonedSObjects;
    }

    //include info about work created, who made it and info on the job (json passed in)
    public static void makeLog(string logMessage, SplunkHelper.LOGLEVEL logLvl, List<SplunkHelper.SFErrorRecord> failedSfIdLst, Set<String> savedSFIdSet, Exception e) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.version = 'v1'; // We don't have versions yet
        log.logLevel = logLvl;
        log.location = 'RescheduleServiceAppointmentController: ' + ACVUtility.currentLineNumber();
        log.message = logMessage;
        log.stackTrace = 'RescheduleServiceAppointmentController: ' + ACVUtility.currentLineNumber();
        log.sfRecordId = UserInfo.getUserId();
        log.componentName = 'RescheduleServiceAppointmentController';
        log.sfObject = 'ServiceAppointment, WorkOrder';
        log.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTOR_DISPATCH };

        if(e != null){
            log.location += ': ' + e.getLineNumber();
            log.stackTrace = e.getStackTraceString();
            log.message += '\n' + e.getMessage();
        }

        SplunkHelper.buildandProcessLog( log, failedSfIdLst, savedSFIdSet );
    }

    public static String genericDatabaseLog(List<Database.SaveResult> results, String objectName, String operation){
        String logMessage = '';
        
        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                //add success log message
                logMessage += objectName + ' ' + sr.getId() + ' successful ' + operation + '.\n';
            }
            else{
                for(Database.Error err : sr.getErrors()){
                    logMessage += 'Error on ' + objectName + ' ' + operation + ': ' + sr.getId() + ': ' + err.getMessage() + '\nStatus Code: ' + err.getStatusCode() + '\nFields:';
                    for(string field : err.getFields()){
                    logMessage += ' ' + field;
                    }
                    logMessage += '\n';
                }
            }

        }
        return logMessage;
    }

    public static Set<string> getSuccessfulIds(Database.SaveResult[] results){
        Set<string> ids = new Set<string>();
        for(Database.SaveResult sr : results){
            if(sr.isSuccess()){
                ids.add(sr.getId());
            }
        }
        return ids;
    }

    public static List<SplunkHelper.SFErrorRecord> getErrorRecords(Database.SaveResult[] results){
        List<SplunkHelper.SFErrorRecord> errors = new List<SplunkHelper.SFErrorRecord>();
        for(Database.SaveResult sr : results){

            for(Database.Error err : sr.getErrors()){
                string errorString;

                errorString += '{\n';
                errorString += '"Status Code" : "' + err.getStatusCode() + '",\n';
                errorString += '"Message" : "' + err.getMessage() + '",\n';
                errorString += '"Fields" : [';
                boolean first = true;
                for(string field : err.getFields()){
                    if(!first){
                        errorString += ', ';
                    }
                    errorString += '"' + field + '"';
                    first = false;
                }
                errorString += ']\n}';

                string recordId = '';
                if(sr.getId() != null){
                    recordId = sr.getId();
                }
                errors.add(new SplunkHelper.SFErrorRecord(recordId, errorString));
            }
        }
        return errors;
    }

    public static Date convertDate(string dateString){
        final Integer DASH_INT_VALUE = 45;

        integer firstDash = dateString.indexOfChar(DASH_INT_VALUE);
        integer secondDash = dateString.indexOfChar(DASH_INT_VALUE, firstDash+1);
        string year = dateString.substring(0,4);
        string month = dateString.substring(firstDash+1, secondDash);
        string day = dateString.substring(secondDash+1, dateString.length());
        return Date.newInstance(Integer.valueOf(year), Integer.valueOf(month), Integer.valueOf(day));
    }
    
    public class Response{
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public String recordURL;
        @AuraEnabled public String newSANumber;
    }

    public class DMLErrorException extends Exception {}

}