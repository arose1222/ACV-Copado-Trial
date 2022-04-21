/**
 * @description ${DESCRIPTION}
 * @name tracGenerate
 * @author Daniel Labonte, Zhouyuan Deng Traction on Demand
 * @date 2019-09-05
 */

public with sharing class tracGenerate {
    public static final Date today = Date.today();
    public static final Datetime NOW = System.now();
    public static WorkType currentWorkType = [SELECT Id FROM WorkType WHERE Name = :tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION LIMIT 1];
    public static Decimal durationMin = [SELECT DurationInMinutes FROM WorkType WHERE Name = :tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION].DurationInMinutes;

    public static Time defaultStartTime = Time.newInstance(0,0,0,0);
    public static Time defaultEndTime = Time.newInstance(23,59,59,999);

    class BatchException extends Exception {}

    public static List<String> generate(List<Occurrence__c> occs, Date endDate) {


        List<String> returnDebug = new List<String>();
        //only generate for occurrence that has not yet finished and is active , and doesn't have the modified flag on


        Set<Id> timelineIds = new Set<Id>();

        List<WorkOrder> wos = new List<WorkOrder>();
        for (Occurrence__c occ: occs){
            if(occ.Date_of_Last_Generation__c == null) {
                occ.Date_of_Last_Generation__c = occ.Timeline__r.Start_Date__c;
            }
            wos.addAll(createData(occ,getDatesFromOccurence(occ,endDate)));
            occ.Date_of_Last_Generation__c = endDate;//it is generated up to end date
            timelineIds.add(occ.Timeline__c);
        }

        List<Timeline__c> timelinesToUpdate = new List<Timeline__c>();
        for(Id timelineId : timelineIds) {
            timelinesToUpdate.add(new Timeline__c(Id=timelineId,Run_Date_of_Previous_Batch__c=System.now()));
        }
        
        
        List<String> occErrors = processSaveResults(Database.update(occs, false));
        returnDebug.add((occs.size() - occErrors.size()) + ' Occurrences successfully updated');
        returnDebug.addAll(occErrors);



        List<String> tlErrors = processSaveResults(Database.update(timelinesToUpdate, false));
        returnDebug.add((timelinesToUpdate.size() - tlErrors.size()) + ' Timelines successfully updated');
        returnDebug.addAll(tlErrors);


        List<String> woErrors = processSaveResults(Database.insert(wos, false));
        returnDebug.add((wos.size() - woErrors.size()) + ' Work Orders successfully inserted');
        returnDebug.addAll(woErrors);

        List<ServiceAppointment> sas = [
                SELECT  Id,
                        Work_Order__r.StartDate,
                        Work_Order__r.EndDate,
                        Work_Order__r.Occurrence__r.Start_Time__c,
                        Work_Order__r.Occurrence__r.End_Time__c,
                        Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__r.Id,
                        Work_Order__r.Duration
                FROM ServiceAppointment
                WHERE Work_Order__c IN :wos];

        List<ResourcePreference> rps = new List<ResourcePreference>();
        for (ServiceAppointment sa : sas){
            if(sa.Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__c != null) {
                rps.add(new ResourcePreference(RelatedRecordId = sa.Work_Order__c, PreferenceType = 'Required', ServiceResourceId = sa.Work_Order__r.Occurrence__r.Timeline__r.Service_Resource__r.Id));
            }
            sa.Duration = sa.Work_Order__r.Duration;
            sa.EarliestStartTime = Datetime.newInstance(sa.Work_Order__r.StartDate.date(), (sa.Work_Order__r.Occurrence__r.Start_Time__c != null ? sa.Work_Order__r.Occurrence__r.Start_Time__c : defaultStartTime));
            sa.DueDate = Datetime.newInstance(sa.Work_Order__r.EndDate.date(), (sa.Work_Order__r.Occurrence__r.End_Time__c != null ? sa.Work_Order__r.Occurrence__r.End_Time__c : defaultEndTime));
        }

        List<String> saErrors = processSaveResults(Database.update(sas, false));
        returnDebug.add((sas.size() - saErrors.size()) + ' Service Appointments successfully updated');
        returnDebug.addAll(saErrors);


        List<String> rpsErrors = processSaveResults(Database.insert(rps, false));
        returnDebug.add((rps.size() - rpsErrors.size()) + ' Resource Preferrences successfully Inserted');
        returnDebug.addAll(rpsErrors);
        
        return returnDebug;
    }

    public static List<String> removeInactiveRecords(){
        List<String> returnDebug = new List<String>();
        List<Occurrence__c> occs = [
                SELECT  Id,
                        Frequency__c,
                        Week_Number__c,
                        Every__c,
                        Day__c,
                        Timeline__c,
                        Start_Time__c,
                        End_Time__c,
                        Date_of_Last_Generation__c
                FROM Occurrence__c
                WHERE Is_Active__c = FALSE
                OR Timeline__c = NULL];

        //remove all inactive Occurrences or orphaned Occurrences
        List<String> occErrors = processDeleteResults(Database.delete(occs, false));
        returnDebug.add((occs.size() - occErrors.size()) + ' Occurrences successfully deleted');
        returnDebug.addAll(occErrors);
        return returnDebug;
    }


    public static List<String> deleteChangedRecords() {
        List<String> returnDebug = new List<String>();
        List<Occurrence__c> occs = [
                SELECT  Id,
                        Frequency__c,
                        Week_Number__c,
                        Every__c,
                        Day__c,
                        Timeline__c,
                        Start_Time__c,
                        End_Time__c,
                        Date_of_Last_Generation__c
                FROM Occurrence__c
                WHERE Modified_Since_Last_Batch__c = TRUE
                OR Timeline__r.Modified_Since_Last_Batch__c = TRUE
                OR Timeline__c = NULL];

        //all the occurrences that have been modified, including all active and inactive ones
        Set<Occurrence__c> occSet = new Set<Occurrence__c>(occs);

        //Query for all Work-Order generated for this Occurrence and delete all the ones after this day.
        List<WorkOrder> wos = [
                SELECT Id
                FROM WorkOrder
                WHERE Occurrence__c IN :occSet
                AND StartDate >= TODAY];

        Set<Id> woIds = new Set<Id>();
        for(WorkOrder wo : wos) {
            woIds.add(wo.Id);
        }

        List<ServiceAppointment> serviceAppointments = [SELECT Id
                                                        FROM ServiceAppointment
                                                        WHERE Work_Order__c IN :woIds];

        List<String> saErrors = processDeleteResults(Database.delete(serviceAppointments, false));
        returnDebug.add((serviceAppointments.size() - saErrors.size()) + ' Service Appointments successfully deleted');
        returnDebug.addAll(saErrors);


        List<String> woErrors = processDeleteResults(Database.delete(wos, false));
        returnDebug.add((wos.Size() - woErrors.size()) + ' Work Orders successfully deleted');
        returnDebug.addAll(woErrors);

        for (Occurrence__c occ : occs){
            occ.Date_of_Last_Generation__c = NOW; //Change current data generation day to today
        }

        List<String> occErrors = processSaveResults(Database.update(occs, false));
        returnDebug.add((occs.size() - occErrors.size()) + ' Occurrences successfully updated after deleting related Work Orders and Service Appointments');
        returnDebug.addAll(occErrors);

        return returnDebug;
    }


    public static List<Date> getDatesFromOccurence(Occurrence__c occ, Date endDate){
        //endDate being how far into the future we are generating data for, will be determined by the batch
        List<Date> generationDates = new List<Date>();
        Date actualGenerationEndDate = (occ.Timeline__r.End_Date__c != null && occ.Timeline__r.End_Date__c < endDate) ? occ.Timeline__r.End_Date__c : endDate;
        Date startDate = (occ.Timeline__r.Start_Date__c > occ.Date_of_Last_Generation__c.date()) ? occ.Timeline__r.Start_Date__c : occ.Date_of_Last_Generation__c.date();
        if (occ.Frequency__c == tracConstants.FREQUENCY_WEEKLY){
            //do weekly generation
            String days = occ.Day__c;
            for (String day : days.split(';')){
                generationDates.addAll(tracDateUtils.getWeeklyEveryDayBetween(day, (Integer)occ.Every__c,startDate,actualGenerationEndDate));
            }
        }else if (occ.Frequency__c == tracConstants.FREQUENCY_MONTHLY){
            String days = occ.Day__c;
            if (occ.Week_Number__c == null){
                for (String day : days.split(';')){
                    generationDates.addAll(tracDateUtils.getMonthlyOnDay(Integer.valueOf(day) ,(Integer)occ.Every__c,startDate,actualGenerationEndDate));
                }
            }else{
                generationDates.addAll(tracDateUtils.getMonthlyEach(occ.Week_Number__c ,days,(Integer)occ.Every__c,startDate,actualGenerationEndDate));
            }
        }else if (occ.Frequency__c == tracConstants.FREQUENCY_DAILY){
            generationDates.addAll(tracDateUtils.getDailyEveryDayBetween((Integer) occ.Every__c,startDate,actualGenerationEndDate));
        }
        return generationDates;
    }

    public static List<String> processSaveResults(List<Database.SaveResult> results){
        List<String> errorMessages = new List<String>();
        if(results.size() > 0){

            Id resultId = results[0].getId();
            String sObjName;
            if(resultId != null){
                sObjName = resultId.getSObjectType().getDescribe().getName();
            }
    
            for(Database.SaveResult result : results) {
                if(result.getErrors().size() > 0) {
                    String error = 'Error(s) ';
                    if(sObjName != null){
                        error += 'from ' + sObjName + ': ' + result.getId();
                    }
                    for(Database.Error err : result.getErrors()){
                        if(err.getMessage() != null){
                            error += '\n<br>    --Error Message: ' + err.getMessage();
                        }
                        if(err.getStatusCode() != null){
                            error += '\n<br>    ----Status Code: ' + err.getStatusCode();
                        }
                        if(err.getFields() != null){
                            error += '\n<br>    -Related Fields: ' + err.getFields();
                        }
                    }
                    errorMessages.add(error);
                }
            }
        }
        return errorMessages;
    }
    public static List<String> processDeleteResults(List<Database.DeleteResult> results){
        List<String> errorMessages = new List<String>();
        if(results.size() > 0){
            Id resultId = results[0].getId();
            String sObjName;
            if(resultId != null){
                sObjName = resultId.getSObjectType().getDescribe().getName();
            }
    
            for(Database.DeleteResult result : results) {
                if(result.getErrors().size() > 0) {
                    String error = 'Error(s) ';
                    if(sObjName != null){
                        error += 'from ' + sObjName + ': ' + result.getId();
                    }
                    for(Database.Error err : result.getErrors()){
                        if(err.getMessage() != null){
                            error += '\n<br>    --Error Message: ' + err.getMessage();
                        }
                        if(err.getStatusCode() != null){
                            error += '\n<br>    ----Status Code: ' + err.getStatusCode();
                        }
                        if(err.getFields() != null){
                            error += '\n<br>    -Related Fields: ' + err.getFields();
                        }
                    }
                    errorMessages.add(error);
                }
            }
        }
        return errorMessages;
    }

    public static List<WorkOrder> createData(Occurrence__c occ, List<Date> dates) {
        List<WorkOrder> wos = new List<WorkOrder>();
        for(Date d : dates) {
            wos.add(new WorkOrder(
                        StartDate = Datetime.newInstance(d,(occ.Start_Time__c!=null?occ.Start_Time__c:defaultStartTime)),
                        EndDate = Datetime.newInstance(d,(occ.End_Time__c!=null?occ.End_Time__c:defaultEndTime)),
                        AccountId = occ.Timeline__r.Account__c,
                        ServiceTerritoryId = occ.Timeline__r.Account__r.Service_Territory__c,
                        Priority = 'Low',
                        Duration = (occ.Timeline__r.Average_Number_Cars__c == null) ? 2 : occ.Timeline__r.Average_Number_Cars__c * durationMin,
                        DurationType = 'Minutes',
                        Occurrence__c = occ.Id,
                        WorkTypeId = currentWorkType.Id,
                        Origin__c = 'Revolving Term'
            ));
        }
        return wos;
    }

}