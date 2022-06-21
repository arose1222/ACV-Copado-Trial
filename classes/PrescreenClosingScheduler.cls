global class PrescreenClosingScheduler extends SchedulingInterface{

    private static final String ARB_GUARD_PRESCREEN_REASON_NAME = 'Arb Guard';
    private static final String AMP_ML_PRESCREEN_REASON_NAME = 'AMP ML';
    private static final String PRESCREEN_STATUS_NEW = 'New';
    private static final String PRESCREEN_STATUS_CLOSED = 'Closed';
    private static final String PRESCREEN_CLOSING_SCHEDULER = 'PrescreenClosingScheduler';

    public override void executeScheduledLogic(){
        System.enqueueJob(new PrescreenClosingSchedulerQueuable());
    }

    public class PrescreenClosingSchedulerQueuable implements Queueable{
		
		public void execute(QueueableContext context) {
            System.debug('PrescreenClosingScheduler start');

            List<Prescreen_Reasons__mdt> allowedReasons = [SELECT MasterLabel FROM Prescreen_Reasons__mdt WHERE Include_For_Time_Out__c = TRUE];
            
            Set<String> reasonNames = new Set<String>();
            for(Prescreen_Reasons__mdt reason : allowedReasons){ reasonNames.add(reason.MasterLabel); }

            List<Condition_Report_Prescreen__c> prescreensToClose = new  List<Condition_Report_Prescreen__c>();

            List<Condition_Report_Prescreen__c> existingPrescreens = [SELECT Id, OwnerId, CreatedDate,
                                                                            (select Id, Name from Prescreen_Reasons__r where Name IN: reasonNames) 
                                                                    FROM  Condition_Report_Prescreen__c 
                                                                    WHERE Status__c =: PRESCREEN_STATUS_NEW
                                                                    FOR UPDATE];

            Datetime now = Datetime.now();

            for(Condition_Report_Prescreen__c prescreen : existingPrescreens){
                Datetime creationDate = prescreen.CreatedDate;

                Decimal minutesBetween = Integer.valueOf((now.getTime() - creationDate.getTime())/(1000*60));

                if(minutesBetween >= 60 || (minutesBetween >= 30 && prescreen.Prescreen_Reasons__r.isEmpty()) ){
                    prescreensToClose.add(prescreen);
                }
            }

            for(Condition_Report_Prescreen__c prescreen: prescreensToClose){ 
                prescreen.Status__c = PRESCREEN_STATUS_CLOSED; 
                prescreen.CR_Update_by_pre_Screener__c = PRESCREEN_CLOSING_SCHEDULER;
                prescreen.CR_Review_Timeout__c = true;
            }
            
            if(!prescreensToClose.isEmpty()){ Database.update(prescreensToClose,false); }
            System.debug('PrescreenClosingScheduler end');
		}
        
        
        
	}
}