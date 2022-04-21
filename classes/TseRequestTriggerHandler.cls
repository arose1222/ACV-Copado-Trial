public class TseRequestTriggerHandler extends TriggerInterface{

    Date DATE_TODAY = Date.today();
    DateTime DT_NOW = Datetime.now();

    public override void beforeInsert(List<SObject> oldList){
        List<TSE_Request__c> tserList = (List<TSE_Request__c>)oldList;
        for(TSE_Request__c tser : tserList){
            if (tser.Immediate_Action__c != null){
                    if (tser.Immediate_Action__c == 'Break'){
                        tser.Type__c = 'Break';
                    }
                    else if(tser.Immediate_Action__c == 'End of Day Travel'){
                        tser.Type__c = 'End of Day Travel';

                    }
                    else if(tser.Immediate_Action__c == 'Other Work'){
                        tser.Type__c = 'Additional Work';

                }
            }
        }
    }

    public override void afterInsert(Map<Id, SObject> newMap){
        Map<Id, TSE_Request__c> tserMap = (Map<Id, TSE_Request__c>)newMap;
        //check action

        Map<Id,TSE_Request__c> breakReqs = new Map<Id, TSE_Request__c>();
        Map<Id,TSE_Request__c> clockInReqs = new Map<Id, TSE_Request__c>();
        Map<Id,TSE_Request__c> clockOutReqs = new Map<Id, TSE_Request__c>();
        Map<Id,TSE_Request__c> interruptReqs = new Map<Id, TSE_Request__c>();
        Map<Id,TSE_Request__c> resumeReqs = new Map<Id, TSE_Request__c>();
        Map<Id,TSE_Request__c> workEntries = new Map<Id, TSE_Request__c>();

        for(TSE_Request__c tser :tserMap.values()){
            if(tser.action__c != null){
                if(tser.action__c == 'Schedule Break'){
                    //create a time sheet entry on the requester's active time sheet for the specified times
                    //go from user id to resource id and use that to find the user's active timesheet then  make the break
                    breakReqs.put(tser.Id, tser);
                }
                else if (tser.action__c == 'Clock In'){
                    //create a tse on the requester's active time sheet of idle (if there is no active entry)
                    clockInReqs.put(tser.Id, tser);
                }
                else if (tser.action__c == 'Clock Out'){
                    //close out all open entries for the requester
                    clockOutReqs.put(tser.Id, tser);
                }
                else if (tser.action__c == 'Interrupt Activity'){
                    interruptReqs.put(tser.Id, tser);
                }
                else if (tser.action__c == 'Resume Activity'){
                    resumeReqs.put(tser.Id, tser);
                }
                else if (tser.action__c == 'Work Entry'){
                    workEntries.put(tser.Id, tser);
                }
            }
            else if (tser.Immediate_Action__c != null){
                if (tser.Immediate_Action__c == 'Break'){
                    interruptReqs.put(tser.Id, tser);
                }
                else if(tser.Immediate_Action__c == 'Resume Previous Work'){
                    resumeReqs.put(tser.Id, tser);
                }
                else if(tser.Immediate_Action__c == 'End of Day Travel'){
                    workEntries.put(tser.Id, tser);
                }
                else if(tser.Immediate_Action__c == 'Clock Out'){
                    clockOutReqs.put(tser.Id, tser);
                }
                else if(tser.Immediate_Action__c == 'Other Work'){
                    workEntries.put(tser.id, tser);
                }
            }
        }

        List<TimeSheetEntry> tseUpsertList = new List<TimeSheetEntry>();
        tseUpsertList.addAll(scheduleBreaks(breakReqs));
        tseUpsertList.addAll(clockIn(clockInReqs));
        tseUpsertList.addAll(clockOut(clockOutReqs));
        tseUpsertList.addAll(interrupt(interruptReqs));
        tseUpsertList.addAll(resume(resumeReqs));
        tseUpsertList.addAll(workEntry(workEntries));
        upsert tseUpsertList;

    }

    public List<TimeSheetEntry> workEntry(Map<Id, TSE_Request__c> reqs){
        set<Id> requesterIds = new SEt<Id>();
        for(TSE_Request__c tsereq: reqs.values()){
            requesterIds.add(tsereq.CreatedById);
        }

        Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId in : requesterIds]);
        Map<Id, TimeSheet> tsMap = new Map<Id, TimeSheet>([SELECT Id, ServiceResourceId FROM TimeSheet WHERE Status != 'Approved' AND ServiceResourceId in: resourceMap.keyset() AND (EndDate = null OR EndDate >= :DATE_TODAY)]);

        //get and close all open tse's from the found ts's

        Map<Id, TimeSheetEntry> tseMap = new Map<Id, TimeSheetEntry>([SELECT id, EndTime FROM TimeSheetEntry WHERE EndTime = null AND TimeSheetId in :tsMap.keyset()]);

        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();

        for(TimesheetEntry tse : tseMap.values()){
            tse.EndTime = DT_NOW;
            tseList.add(tse);
        }

        //construct user to ts map
        Map<Id, TimeSheet> userToTimesheet = new Map<id, Timesheet>();

        for(TimeSheet ts : tsMap.values()){
            Id userId = resourceMap.get(ts.ServiceResourceId).RelatedRecordId;
            userToTimesheet.put(userId, ts);
        }

        for(TSE_Request__c tser: reqs.values()){
            if(userToTimesheet.get(tser.CreatedById) != null && tser.Type__c != null){
                //make new timesheet entry
                TimeSheetEntry tse = new TimeSheetEntry();
                tse.Status = 'New';
                tse.StartTime = DT_NOW;
                tse.Type = tser.Type__c;
                tse.TimeSheetId = userToTimesheet.get(tser.CreatedById).id;
                if(tser.Work_Order__c != null){
                    tse.WorkOrderId	 = tser.Work_Order__c;
                }
                if(tser.Work_Order_Line_Item__c != null){
                    tse.WorkOrderLineItemId = tser.Work_Order_Line_Item__c;
                }
                if(tser.Service_Appointment__c != null){
                    tse.Service_Appointment__c = tser.Service_Appointment__c;
                }

                tseList.add(tse);
            }
        }

        return tseList;

    }

    public List<TimeSheetEntry> scheduleBreaks(Map<Id,TSE_Request__c> reqs){

        set<Id> requesterIds = new SEt<Id>();
        for(TSE_Request__c tsereq: reqs.values()){
            requesterIds.add(tsereq.CreatedById);
        }

        Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId in : requesterIds]);
        Map<Id, TimeSheet> tsMap = new Map<Id, TimeSheet>([SELECT Id, ServiceResourceId FROM TimeSheet WHERE Status != 'Approved' AND ServiceResourceId in: resourceMap.keyset() AND (EndDate = null OR EndDate >= :DATE_TODAY)]);



        //construct user to ts map
        Map<Id, TimeSheet> userToTimesheet = new Map<id, Timesheet>();

        for(TimeSheet ts : tsMap.values()){
            Id userId = resourceMap.get(ts.ServiceResourceId).RelatedRecordId;
            userToTimesheet.put(userId, ts);
        }

        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();

        for(TSE_Request__c tser: reqs.values()){
            if(userToTimesheet.get(tser.CreatedById) != null){
                //make new timesheet entry
                TimeSheetEntry tse = new TimeSheetEntry();
                tse.StartTime = tser.Start_Time__c;
                tse.EndTime = tser.End_Time__c;
                tse.Type = tser.Break_Type__c;
                tse.TimeSheetId = userToTimesheet.get(tser.CreatedById).id;
                tse.Status = 'New';
                if(tser.Service_Appointment__c != null){
                    tse.Service_Appointment__c = tser.Service_Appointment__c;
                }
                tseList.add(tse);
            }
        }

        return tseList;

    }
    public List<TimeSheetEntry> clockIn(Map<Id,TSE_Request__c> reqs){

        set<Id> requesterIds = new SEt<Id>();
        for(TSE_Request__c tsereq: reqs.values()){
            requesterIds.add(tsereq.CreatedById);
        }

        Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId in : requesterIds]);
        Map<Id, TimeSheet> tsMap = new Map<Id, TimeSheet>([SELECT Id, ServiceResourceId FROM TimeSheet WHERE Status != 'Approved' AND ServiceResourceId in: resourceMap.keyset() AND (EndDate = null OR EndDate >= :DATE_TODAY)]);


        //construct user to ts map
        Map<Id, TimeSheet> userToTimesheet = new Map<id, Timesheet>();

        for(TimeSheet ts : tsMap.values()){
            Id userId = resourceMap.get(ts.ServiceResourceId).RelatedRecordId;
            userToTimesheet.put(userId, ts);
        }

        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();

        for(TSE_Request__c tser: reqs.values()){
            if(userToTimesheet.get(tser.CreatedById) != null){
                //make new timesheet entry
                TimeSheetEntry tse = new TimeSheetEntry();
                tse.Status = 'New';
                tse.StartTime = DT_NOW;
                tse.Type = 'Idle';
                tse.TimeSheetId = userToTimesheet.get(tser.CreatedById).id;
                if(tser.Service_Appointment__c != null){
                    tse.Service_Appointment__c = tser.Service_Appointment__c;
                }
                tseList.add(tse);
            }
        }

        return tseList;

    }
    public List<TimeSheetEntry> clockOut(Map<Id,TSE_Request__c> reqs){
        set<Id> requesterIds = new SEt<Id>();
        for(TSE_Request__c tsereq: reqs.values()){
            requesterIds.add(tsereq.CreatedById);
        }

        Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId in : requesterIds]);
        Map<Id, TimeSheet> tsMap = new Map<Id, TimeSheet>([SELECT Id, ServiceResourceId FROM TimeSheet WHERE Status != 'Approved' AND ServiceResourceId in: resourceMap.keyset() AND (EndDate = null OR EndDate >= :DATE_TODAY)]);


        //construct user to ts map
        Map<Id, TimeSheet> userToTimesheet = new Map<id, Timesheet>();

        for(TimeSheet ts : tsMap.values()){
            Id userId = resourceMap.get(ts.ServiceResourceId).RelatedRecordId;
            userToTimesheet.put(userId, ts);
        }

        //get and close all open tse's from the found ts's

        Map<Id, TimeSheetEntry> tseMap = new Map<Id, TimeSheetEntry>([SELECT id, EndTime FROM TimeSheetEntry WHERE EndTime = null AND TimeSheetId in :tsMap.keyset()]);

        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();

        for(TimesheetEntry tse : tseMap.values()){
            tse.EndTime = DT_NOW;
            tseList.add(tse);
        }


        return tseList;
    }
    public List<TimeSheetEntry> interrupt(Map<Id,TSE_Request__c> reqs){
        set<Id> requesterIds = new SEt<Id>();
        for(TSE_Request__c tsereq: reqs.values()){
            requesterIds.add(tsereq.CreatedById);
        }

        Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId in : requesterIds]);
        Map<Id, TimeSheet> tsMap = new Map<Id, TimeSheet>([SELECT Id, ServiceResourceId FROM TimeSheet WHERE Status != 'Approved' AND ServiceResourceId in: resourceMap.keyset() AND (EndDate = null OR EndDate >= :DATE_TODAY)]);


        //construct user to ts map
        Map<Id, TimeSheet> userToTimesheet = new Map<id, Timesheet>();

        for(TimeSheet ts : tsMap.values()){
            Id userId = resourceMap.get(ts.ServiceResourceId).RelatedRecordId;
            userToTimesheet.put(userId, ts);
        }

        //get and close all open tse's from the found ts's

        Map<Id, TimeSheetEntry> tseMap = new Map<Id, TimeSheetEntry>([SELECT id, EndTime, TimeSheetId FROM TimeSheetEntry WHERE EndTime = null AND TimeSheetId in :tsMap.keyset()]);

        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();
        Map<Id, TimeSheetEntry> tsToTse = new Map<Id, TimeSheetEntry>();

        for(TimesheetEntry tse : tseMap.values()){
            tse.EndTime = DT_NOW;
            tseList.add(tse);
            tsToTse.put(tse.TimeSheetId, tse);
        }

        for(TSE_Request__c tser: reqs.values()){
            if(userToTimesheet.get(tser.CreatedById) != null){
                //make new timesheet entry
                TimeSheetEntry tse = new TimeSheetEntry();
                tse.Status = 'New';
                tse.StartTime = DT_NOW;
                tse.Type = 'Break';
                tse.TimeSheetId = userToTimesheet.get(tser.CreatedById).id;
                if(tsToTse.containsKey(tse.TimeSheetId)){
                    tse.Interrupted_Entry__c = tsToTse.get(tse.TimeSheetId).id;
                }
                if(tser.Service_Appointment__c != null){
                    tse.Service_Appointment__c = tser.Service_Appointment__c;
                }
                tseList.add(tse);
            }
        }


        return tseList;
    }

    public List<TimeSheetEntry> resume(Map<Id,TSE_Request__c> reqs){
        set<Id> requesterIds = new SEt<Id>();
        for(TSE_Request__c tsereq: reqs.values()){
            requesterIds.add(tsereq.CreatedById);
        }

        Map<Id, ServiceResource> resourceMap = new Map<Id, ServiceResource>([SELECT Id, RelatedRecordId FROM ServiceResource WHERE RelatedRecordId in : requesterIds]);
        Map<Id, TimeSheet> tsMap = new Map<Id, TimeSheet>([SELECT Id, ServiceResourceId FROM TimeSheet WHERE Status != 'Approved' AND ServiceResourceId in: resourceMap.keyset() AND (EndDate = null OR EndDate >= :DATE_TODAY)]);


        //construct user to ts map
        Map<Id, TimeSheet> userToTimesheet = new Map<id, Timesheet>();

        for(TimeSheet ts : tsMap.values()){
            Id userId = resourceMap.get(ts.ServiceResourceId).RelatedRecordId;
            userToTimesheet.put(userId, ts);
        }

        //get and close all open tse's from the found ts's, note if they have an interrupted tse, if they do, resume that entry

        Map<Id, TimeSheetEntry> tseMap = new Map<Id, TimeSheetEntry>([SELECT id, EndTime, WorkOrderId	, Interrupted_Entry__c, WorkOrderLineItemId, Type, TimeSheetId FROM TimeSheetEntry WHERE EndTime = null AND TimeSheetId in :tsMap.keyset()]);

        List<TimeSheetEntry> tseList = new List<TimeSheetEntry>();
        Map<id, id> tsToInterruptedTse = new Map<id,id>();

        for(TimesheetEntry tse : tseMap.values()){
            if(tse.TimeSheetId != null && tse.Interrupted_Entry__c != null){
                tsToInterruptedTse.put(tse.TimeSheetId, tse.Interrupted_Entry__c);
                tse.EndTime = DT_NOW;
                tseList.add(tse);
            }
        }

        Map<Id, TimeSheetEntry> interruptedTses = new Map<Id, TimeSheetEntry>([SELECT Id, WorkOrderId	, WorkOrderLineItemId, Type, TimeSheetId FROM TimeSheetEntry WHERE Id in : tsToInterruptedTse.values()]);

        for(TSE_Request__c tser: reqs.values()){
            //if the user can be found
            if(userToTimesheet.get(tser.CreatedById) != null){
                Id tsId = userToTimesheet.get(tser.CreatedById).id;
                //if the time sheet has an open entry that was interrupted
                if(tsToInterruptedTse.containsKey(tsId)){
                    Id tseId = tsToInterruptedTse.get(tsId);
                    //if the interrupted tse was found and queried
                    if(interruptedTses.containsKey(tseId)){
                        //get the interrupted tse and resume it in a new tse
                        TimeSheetEntry tseToResume = interruptedTses.get(tseId);
                        TimeSheetEntry tse = new TimeSheetEntry();
                        tse.TimeSheetId = tseToResume.TimeSheetId;
                        tse.Status = 'New';
                        tse.StartTime = DT_NOW;
                        if(tseToResume.Type != null){
                            tse.Type = tseToResume.Type;
                        }
                        if(tseToResume.WorkOrderId	!= null){
                            tse.WorkOrderId	 = tseToResume.WorkOrderId	;
                        }
                        if(tseToResume.WorkOrderLineItemId!= null){
                            tse.WorkOrderLineItemId = tseToResume.WorkOrderLineItemId;
                        }
                        if(tser.Service_Appointment__c != null){
                            tse.Service_Appointment__c = tser.Service_Appointment__c;
                        }
                        tseList.add(tse);
                    }
                }
            }
        }


        return tseList;
    }

}