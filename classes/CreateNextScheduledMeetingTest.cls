@isTest
public class CreateNextScheduledMeetingTest {

    @TestSetup
    static void makeData(){
        Account newAccount = TestUtility.createAccount('EventTest');
        insert newAccount;
    }
    
    @isTest
    static void testCreatingEventWithNextScheduleDate(){
        Account newAccount = [SELECT Id FROM Account];

        // Creates futureMeeting to be next year on March 14 @ 3:14pm 
        Datetime futureMeeting = Datetime.newInstance(System.today().year() + 1, 3, 14, 15, 14, 0);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Territory Manager'];
        User u = TestUtility.createUser(p.Id);

        System.runAs(u){
            Event newEvent = TestUtility.createEvent();
            newEvent.WhatId = newAccount.Id;
            newEvent.Next_Scheduled_Meeting__c = futureMeeting;
            
            Test.startTest();
            insert newEvent;
            Test.stopTest();
        }
        
        Event futureEvent = [SELECT Id, OwnerId, WhatId, Type, Subject, StartDateTime, EndDateTime FROM Event WHERE Next_Scheduled_Meeting__c = null];
		System.assertEquals(u.Id, futureEvent.OwnerId);
		System.assertEquals(newAccount.Id, futureEvent.WhatId);
		System.assertEquals('Meeting', futureEvent.Type);
		System.assertEquals('Meeting', futureEvent.Subject);
		System.assertEquals(futureMeeting, futureEvent.StartDateTime);
		System.assertEquals(futureMeeting.addHours(1), futureEvent.EndDateTime);
    }

    @isTest
    static void testDoNotCreateFutureEvent(){
        Account newAccount = [SELECT Id FROM Account];

        Profile p = [SELECT Id FROM Profile WHERE Name='Territory Manager'];
        User u = TestUtility.createUser(p.Id);

        System.runAs(u){
            Event newEvent = TestUtility.createEvent();
            newEvent.WhatId = newAccount.Id;
            
            Test.startTest();
            insert newEvent;
            Test.stopTest();
        }
        
        System.assertEquals(1,[SELECT Count() FROM Event], 'Only the event created in this test should exist in the system.');
    }
}