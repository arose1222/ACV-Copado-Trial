public without sharing class PrescreenEmailsScheduler extends SchedulingInterface{
    
    private static final String PRESCREEN_STATUS_NEW = 'New';
    private static final String PRESCREEN_STATUS_UNDER_REVIEW = 'Under Review';
    private static final String PRESCREEN_STATUS_CLOSED = 'Closed'; 
    private static final String PRESCREEN_UPDATED_BY_SCREENER_YES = 'Yes'; 

    public override void executeScheduledLogic(){
        System.enqueueJob(new PrescreenEmailsSchedulerQueuable());
    }

    public class PrescreenEmailsSchedulerQueuable implements Queueable{
		
		public void execute(QueueableContext context) {
            List<Prescreen_Reasons__mdt> allowedReasons = [SELECT MasterLabel FROM Prescreen_Reasons__mdt WHERE Include_For_Email_Notifications__c = TRUE];
            
            Set<String> reasonNames = new Set<String>();
            for(Prescreen_Reasons__mdt reason : allowedReasons){ reasonNames.add(reason.MasterLabel); }

            Datetime twoHoursEarlier = Datetime.now().addHours(-2);

            List<Condition_Report_Prescreen__c> prescreens = [SELECT Id, OwnerId, Aux_Prescreen_Status__c, Status__c, CR_Update_by_pre_Screener__c, 
                                                                      CR_Review_Timeout__c, Sent_To_Prescreen_Email__c, Time_Out_Email__c, Under_Review_Email__c, Completed_Reviewed_No_Changes_Email__c,
                                                                      Completed_Review_Changes_Email__c,  VCI_Creator_Email__c, VCI__r.Email, Owner.Name, Owner.Email,    
                                                                      (select Id, Name from Prescreen_Reasons__r where Name IN: reasonNames),
                                                                      (select Id, Location__c, Question_Notes_Photos__c, Question_Sub_Type__c, Question_Type__c, CreatedBy.Name from CR_Questions__r ) 
                                                                      FROM  Condition_Report_Prescreen__c 
                                                                      WHERE CreatedDate >=: twoHoursEarlier
                                                                      AND ( VCI__r.Email  != NULL OR VCI_Creator_Email__c != NULL) 
                                                                      FOR UPDATE];

			List<Condition_Report_Prescreen__c> prescreensToUpdate = new List<Condition_Report_Prescreen__c>();
            
            for(Condition_Report_Prescreen__c pre : prescreens){

                if(pre.Prescreen_Reasons__r.isEmpty()){ continue;}

                pre.Prescreen_Email_Target__c = (pre.VCI_Creator_Email__c != null) ? pre.VCI_Creator_Email__c : pre.VCI__r.Email;

                List<String> reasons = new List<String>();

                for(Prescreen_Reason__c reason : pre.Prescreen_Reasons__r){ reasons.add(reason.name);  }
                pre.Prescreen_Email_Reasons__c = String.join(reasons,',');
                pre.Prescreen_Associate_Email__c = pre.Owner.Email;
                pre.Prescreen_Associante_Name__c = pre.Owner.Name;

                //SEND TO PRESCREEN EMAIL
                if(!pre.Sent_To_Prescreen_Email__c && pre.Status__c == PRESCREEN_STATUS_NEW){ 
                    pre.Sent_To_Prescreen_Email__c = true; 
                }

                //TIME OUT EMAIL
                else if(!pre.Time_Out_Email__c && pre.CR_Review_Timeout__c){ 
                    pre.Time_Out_Email__c = true;
                }

                //UNDER REVIEW EMAIL
                else if(!pre.Under_Review_Email__c && pre.Status__c == PRESCREEN_STATUS_UNDER_REVIEW){ 
                    pre.Under_Review_Email__c = true;
                }

                //COMPLETED - NO CHANGES EMAILS
                else if(!pre.Completed_Reviewed_No_Changes_Email__c && pre.Status__c == PRESCREEN_STATUS_CLOSED && 
                        pre.CR_Update_by_pre_Screener__c != PRESCREEN_UPDATED_BY_SCREENER_YES && pre.CR_Questions__r.isEmpty()){ 
                        pre.Completed_Reviewed_No_Changes_Email__c = true;
                }

                //COMPLETED - CHANGES
                else if(!pre.Completed_Review_Changes_Email__c && pre.Status__c == PRESCREEN_STATUS_CLOSED && 
                        (pre.CR_Update_by_pre_Screener__c == PRESCREEN_UPDATED_BY_SCREENER_YES || !pre.CR_Questions__r.isEmpty())){ 
                            pre.Completed_Review_Changes_Email__c = true;

                            if(!pre.CR_Questions__r.isEmpty()){
                                String notes = '<b>Changes and Notes from Prescreen Associate '+pre.Owner.Name+': </b><br/>';
                            
                                for(CR_Question__c question : pre.CR_Questions__r){
                                    notes += '<ul>';
                                    notes +=  (question.Question_Type__c != null ) ? '<li>' + question.Question_Type__c + '</li>' : '';
                                    notes +=  (question.Question_Sub_Type__c != null ) ? '<ul><li>' + question.Question_Sub_Type__c + ((question.Location__c != null) ? ' | ' +  question.Location__c : '') + '</li></ul>' : '';
                                    notes +=  (question.Question_Notes_Photos__c != null ) ? '<ul><ul><li>' + question.Question_Notes_Photos__c + '</li></ul></ul>' : '';
                                    notes += '</ul><br/>';
                                }
    
                                pre.Prescreen_Email_Changes_Notes__c = notes;
                            }
                }
                prescreensToUpdate.add(pre);
            }

            if(prescreensToUpdate.size() > 0){ Database.update(prescreensToUpdate,false); }	
		}
		
	}
}