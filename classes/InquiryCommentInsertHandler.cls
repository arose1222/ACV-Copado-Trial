public class InquiryCommentInsertHandler extends TriggerInterface {
    // when inquiry comment is created, creating a matching task on the related ops case (if populated)
    // wanted this to be handled here in case someone hits the Log Comment button and doesn't use the log an interaction process
    public override void afterInsert(Map<Id,SObject> incomingMap) {
        Map<Id,Inquiry_Comment__c> newCommentsMap = (Map<Id,Inquiry_Comment__c>) incomingMap;
        Map<Id,Inquiry_Comment__c> commentsNeedingTasks = new Map<Id,Inquiry_Comment__c>();

        for(Inquiry_Comment__c ic : newCommentsMap.values()){
            commentsNeedingTasks.put(ic.Customer_Inquiry__c,ic);
        }

        if(!commentsNeedingTasks.isEmpty()){
            insertFeedTask(commentsNeedingTasks);
        }
    }

	private static void insertFeedTask(Map<Id,Inquiry_Comment__c> commentsNeedingTasks){
        List<Task> feedTasks = new List<Task>();
        
        Map<Id,Customer_Inquiry__c> inquiryMap = new Map<Id,Customer_Inquiry__c>([SELECT Id, Ops_Case__c, Call_Bucket__c, Status__c, Call_Type__c, Support_Case__r.ContactId, Initial_Inquiry_Comment__c, Most_Recent_Inquiry_Comment__c, Origin__c, Contact__c 
                                                                                    FROM Customer_Inquiry__c WHERE Id IN :commentsNeedingTasks.keySet()]);
        for(Inquiry_Comment__c ic : commentsNeedingTasks.values()){
            Customer_Inquiry__c ci = inquiryMap.get(ic.Customer_Inquiry__c);
            // only create a task if Feed_Task_Created__c is false.  It would be true if it was created from the "Log A Call" button on a title case
            if(ci.Ops_Case__c != null && ic.Feed_Task_Created__c == false){
                Task t = new Task(Subject = 'Customer Inquiry - ' + ci.Call_Type__c, WhatId = ci.Ops_Case__c, Description = ic.Inquiry_Notes__c, Status = 'Completed', Priority = 'Normal', From_Inquiry_Comment__c = true, Inquiry_Status__c = ci.Status__c, Inquiry_Call_Type__c = ci.Call_Type__c, Inquiry_Call_Bucket__c = ci.Call_Bucket__c);
                if (ci.Support_Case__c != null) {
                    t.WhoId = ci.Support_Case__r?.ContactId;
                }
                else if (ci.Origin__c == 'Report a Problem') {
                    t.whoId = ci.Contact__c;
                }
                //feedTasks.add(new Task(Subject = 'Customer Inquiry - ' + ci.Call_Type__c, WhatId = ci.Ops_Case__c, WhoId = ci.Support_Case__r?.ContactId, Description = ic.Inquiry_Notes__c, Status = 'Completed', Priority = 'Normal', From_Inquiry_Comment__c = true, Inquiry_Status__c = ci.Status__c, Inquiry_Call_Type__c = ci.Call_Type__c, Inquiry_Call_Bucket__c = ci.Call_Bucket__c ));
                feedTasks.add(t);
            }
            if (ic.Inquiry_Notes__c != null && ic.Inquiry_Notes__c != '') { //if there are no notes, no need to do anything else
                // Log inquiry notes to customer inquiry initial or most recent field
                if(ci.Initial_Inquiry_Comment__c == null){
                    ci.Initial_Inquiry_Comment__c = ic.Inquiry_Notes__c;
                }
                else {
                    ci.Most_Recent_Inquiry_Comment__c = ic.Inquiry_Notes__c;
                }
            }
        }
        insert feedTasks;
        update inquiryMap.values();
    }

}