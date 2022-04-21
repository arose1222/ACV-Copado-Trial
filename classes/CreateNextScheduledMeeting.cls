public class CreateNextScheduledMeeting extends TriggerInterface {
   
    /** 
     * On creation of Events, if the Event Next_Scheduled_Meeting__c is not empty
     * create a future event with start date = Next_Scheduled_Meeting__c and end date = Next_Scheduled_Meeting__c + 1 hour.
     * @param newList - List of Event records in Trigger
     * @return void
     */
    public override void afterInsert(List<SObject> newList){
        List<Event> eventsToInsert = new List<Event>();
        for(Event e : (List<Event>) newList){
            if(e.Next_Scheduled_Meeting__c != null){
                Event futureEvent = new Event(
                    StartDateTime = e.Next_Scheduled_Meeting__c,
                    EndDateTime = e.Next_Scheduled_Meeting__c.addHours(1),
                    Type = 'Meeting',
                    WhatId = e.WhatId,
                    OwnerId = e.OwnerId,
                    Subject = 'Meeting'
                );
                eventsToInsert.add(futureEvent);
            }
        }
        
        if(!eventsToInsert.isEmpty()){
            insert eventsToInsert;
        }
    }
}