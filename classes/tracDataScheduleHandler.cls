/**
 * @description trigger handler for the Data Schedule object
 * @name tracDataScheduleHandler
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-05
 */

public class tracDataScheduleHandler extends TriggerInterface{

    public override void beforeInsert(List<Sobject> newList){
        handleValidateInsert((List<Data_Schedule__c>)newList);
        handleBeforeInsert((List<Data_Schedule__c>)newList);
    }

    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        handleBeforeUpdate((List<Data_Schedule__c>)newMap.values(),(Map<Id,Data_Schedule__c>)oldMap);
    }

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        handleAfterUpdate((List<Data_Schedule__c>)newMap.values(),(Map<Id,Data_Schedule__c>)oldMap);
    }

    public override void afterUndelete(List<Sobject> newList){
        handleAfterUndelete((List<Data_Schedule__c>)newList);
    }

    public static void handleValidateInsert(List<Data_Schedule__c> records) {
        if(records.size() > 1) {
            records[0].addError('Only one data generation record can be created at a time');
        }
    }


    public static void handleBeforeInsert(List<Data_Schedule__c> records) {
        for(Data_Schedule__c record : records) {
            record.Run_Batch__c = false;
        }
    }


    public static void handleAfterInsert(List<Data_Schedule__c> records) {
        if(records[0].Active__c) {
            deactivateAllJobs(records[0].Id);
            createNewJob(records[0]);
        }
    }


    public static void handleBeforeUpdate(List<Data_Schedule__c> records,Map<Id,Data_Schedule__c> oldMap) {
        if(records[0].Run_Clean_Up__c && records[0].Run_Generation__c) {
            RevolvingBatchManual.runCleanUpBatch(records[0].Clean_Up_Batch_Size__c.intValue(), records[0].Generation_Batch_Size__c.intValue(), true);
            records[0].Run_Clean_Up__c = false;
            records[0].Run_Generation__c = false;
        }
        else if(records[0].Run_Clean_Up__c ) {
            RevolvingBatchManual.runCleanUpBatch(records[0].Clean_Up_Batch_Size__c.intValue());
            records[0].Run_Clean_Up__c = false;
        }
        else if(records[0].Run_Generation__c) {
            RevolvingBatchManual.runGenerationBatch(records[0].Generation_Batch_Size__c.intValue());
            records[0].Run_Generation__c = false;
        }

    }


    public static void handleAfterUpdate(List<Data_Schedule__c> records,Map<Id,Data_Schedule__c> oldMap) {
        String newActiveId;
        for (Data_Schedule__c ds : records) {
            if (ds.Active__c == true && oldMap.get(ds.Id).Active__c == false) {
                newActiveId = ds.Id;
            }
        }
        if(newActiveId != null) {
            deactivateAllJobs(newActiveId);
        }
    }


    public static void handleBeforeDelete(List<Data_Schedule__c> records) {

    }


    public static void handleAfterDelete(List<Data_Schedule__c> records) {

    }


    public static void handleAfterUndelete(List<Data_Schedule__c> records) {
        List<Data_Schedule__c> dsDeactivate = new List<Data_Schedule__c>();
        for(Data_Schedule__c ds : records) {
            if(ds.Active__c) {
                dsDeactivate.add(new Data_Schedule__c(Id=ds.Id,Active__c=false));
            }
        }
        update dsDeactivate;
    }





    private static void createNewJob(Data_Schedule__c job) {
//        # Use the hash sign to prefix a comment
//        # +---------------- minute (0 - 59)
//        # |  +------------- hour (0 - 23)
//        # |  |  +---------- day of month (1 - 31)
//        # |  |  |  +------- month (1 - 12)
//        # |  |  |  |  +---- day of week (0 - 7) (Sunday=0 or 7)
//        # |  |  |  |  |
//        # *  *  *  *  *  command to be executed
//        #--------------------------------------------------------------------------

        System.debug(job);

        String cronString;
        Integer minute = 0,
                hour = 0;

//        minute = job.Time__c.minute();
//        hour = job.Time__c.hour();

        if(job.Frequency__c == tracConstants.DATA_FREQUENCY_DAILY) {
            cronString = String.valueOf(minute) + ' ' + String.valueOf(hour) + ' * * *';
        } else if(job.Frequency__c == tracConstants.DATA_FREQUENCY_WEEKLY) {
            String day = job.Day__c.substring(0,3).toUpperCase();
            cronString = String.valueOf(minute) + ' ' + String.valueOf(hour) + ' * * ' + day;
        } else if(job.Frequency__c == tracConstants.DATA_FREQUENCY_MONTHLY) {
            String dayNum = job.Day__c;
            cronString = String.valueOf(minute) + ' ' + String.valueOf(hour) + ' ' + dayNum + ' * *';
        }

        System.debug(cronString);


        Long now = Datetime.now().getTime();
//        System.schedule('Recurring Data Generation'+String.valueOf(now),);
    }



    private static void deactivateAllJobs(String activeRecordId) {
        List<Data_Schedule__c> dataSchedules = [SELECT Id FROM Data_Schedule__c WHERE Active__c = TRUE AND Id != :activeRecordId];
        for(Data_Schedule__c ds : dataSchedules) {
            ds.Active__c = false;
        }
        update dataSchedules;

//        List<CronTrigger> cronsJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Recurring Data Generation%'];
//        for(CronTrigger cron : cronsJobs) {
//            try{
//                System.abortJob(cron.Id);
//            } catch (Exception e) {}
//        }
    }

}