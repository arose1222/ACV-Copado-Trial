public class RevolvingUtility {


    public static final Datetime NOW = (Datetime) System.today();
    public static final String DAY_OF_THE_WEEK = NOW.format('EEEE');
    public static final String DAY_OF_THE_MONTH = NOW.format('d');

    public static final String DATA_FREQUENCY_DAILY   = 'Daily';
    public static final String DATA_FREQUENCY_WEEKLY  = 'Weekly';
    public static final String DATA_FREQUENCY_MONTHLY = 'Monthly';

    public static final String DATA_HORIZON_DAYS   = 'Days';
    public static final String DATA_HORIZON_WEEKS  = 'Weeks';
    public static final String DATA_HORIZON_MONTHS = 'Months';

    public static Boolean isDaily(Data_Schedule__c schedule) {
        if(schedule.Frequency__c != null){
            return (schedule.Frequency__c == DATA_FREQUENCY_DAILY);
        }
        return null;
    }

    public static Boolean isWeeklyToday(Data_Schedule__c schedule) {
        if(schedule.Frequency__c != null && schedule.Day__c != null){
            return ((schedule.Frequency__c == DATA_FREQUENCY_WEEKLY) && (DAY_OF_THE_WEEK == schedule.Day__c));
        }
        return null;
    }

    public static Boolean isMonthlyToday(Data_Schedule__c schedule) {
        if(schedule.Frequency__c != null && schedule.Day__c != null){
            return ((schedule.Frequency__c == DATA_FREQUENCY_MONTHLY) && (DAY_OF_THE_MONTH == schedule.Day__c));
        }
        return null;
    }

    public static Date horizonDate(Date start, Data_Schedule__c schedule){
        Date horizon;
        if(schedule.Horizon_Length__c != null){
            if(schedule.Horizon_Type__c != null && schedule.Horizon_Type__c == DATA_HORIZON_DAYS){
                horizon = start.addDays(Integer.valueOf(schedule.Horizon_Length__c));
            }
            else if(schedule.Horizon_Type__c != null && schedule.Horizon_Type__c == DATA_HORIZON_WEEKS){
                horizon = start.addDays(Integer.valueOf(schedule.Horizon_Length__c)*7);
            }
            else if(schedule.Horizon_Type__c != null && schedule.Horizon_Type__c == DATA_HORIZON_MONTHS){
                horizon = start.addMonths(Integer.valueOf(schedule.Horizon_Length__c));
            }
        }
        return horizon;
    }

    public static List<String> processSaveResults(List<Database.SaveResult> results){
        //Id not accessible when insert fails
        List<String> errorMessages = new List<String>();

        if(results.size() > 0){

            Id resultId;
            String sObjName;
            Boolean recordInfoSet = false;
    
            for(Database.SaveResult result : results) {

                if(!recordInfoSet && result.getId() != null){
                    resultId = result.getId();
                    resultId.getSObjectType().getDescribe().getName();
                    recordInfoSet = true;
                }

                if(result.getErrors().size() > 0) {
                    String error = 'Error(s)';
                    if(recordInfoSet){
                        error += 'from ' + sObjName + ': ' + result.getId();
                    }
                    for(Database.Error err : result.getErrors()){
                        error += '\n<br>    --Error Message: ' + err.getMessage();
                        error += '\n<br>    ----Status Code: ' + err.getStatusCode();
                        error += '\n<br>    -Related Fields: ' + err.getFields();
                    }
                    errorMessages.add(error);
                }
            }
        }
        return errorMessages;
    }
    public static Set<Id> errorIdSet(List<Database.SaveResult> results){
        Set<Id> errorIds = new Set<Id>();
        if(results.size() > 0){
            for(Database.SaveResult result : results){
                if(result.getErrors().size() > 0){
                    errorIds.add(result.getId());
                }
            }
        }
        return errorIds;
    }

    public static List<String> processDeleteResults(List<Database.DeleteResult> results){
        List<String> errorMessages = new List<String>();
        if(results.size() > 0){
            Id resultId = results[0].getId();
            String sObjName = resultId.getSObjectType().getDescribe().getName();
    
            for(Database.DeleteResult result : results) {
                if(result.getErrors().size() > 0) {
                    String error = '<br>Error(s) from ' + sObjName + ': ' + result.getId();
                    for(Database.Error err : result.getErrors()){
                        error += '\n<br>    --Error Message: ' + err.getMessage();
                        error += '\n<br>    ----Status Code: ' + err.getStatusCode();
                        error += '\n<br>    -Related Fields: ' + err.getFields();
                    }
                    errorMessages.add(error);
                }
            }
        }
        return errorMessages;
    }
    public static Set<Id> errorIdSet(List<Database.DeleteResult> results){
        Set<Id> errorIds = new Set<Id>();
        if(results.size() > 0){
            for(Database.DeleteResult result : results){
                if(result.getErrors().size() > 0){
                    errorIds.add(result.getId());
                }
            }
        }
        return errorIds;
    }

    public static List<Date> getDatesFromOccurence(Occurrence__c occ, Date endDate){
        //endDate being how far into the future we are generating data for, will be determined by the batch
        List<Date> generationDates = new List<Date>();
        Date actualGenerationEndDate = (occ.Timeline__r.End_Date__c != null && occ.Timeline__r.End_Date__c < endDate) ? occ.Timeline__r.End_Date__c : endDate;
        Date startDate = (occ.Timeline__r.Start_Date__c > occ.Farthest_Date_Generated__c.date()) ? occ.Timeline__r.Start_Date__c : occ.Farthest_Date_Generated__c.date();
        if (occ.Frequency__c == DATA_FREQUENCY_WEEKLY){
            //do weekly generation
            String days = occ.Day__c;
            for (String day : days.split(';')){
                generationDates.addAll(tracDateUtils.getWeeklyEveryDayBetween(day, (Integer)occ.Every__c,startDate,actualGenerationEndDate));
            }
        }else if (occ.Frequency__c == DATA_FREQUENCY_MONTHLY){
            String days = occ.Day__c;
            if (occ.Week_Number__c == null){
                for (String day : days.split(';')){
                    generationDates.addAll(tracDateUtils.getMonthlyOnDay(Integer.valueOf(day) ,(Integer)occ.Every__c,startDate,actualGenerationEndDate));
                }
            }else{
                generationDates.addAll(tracDateUtils.getMonthlyEach(occ.Week_Number__c ,days,(Integer)occ.Every__c,startDate,actualGenerationEndDate));
            }
        }else if (occ.Frequency__c == DATA_FREQUENCY_DAILY){
            generationDates.addAll(tracDateUtils.getDailyEveryDayBetween((Integer) occ.Every__c,startDate,actualGenerationEndDate));
        }
        return generationDates;
    }
}