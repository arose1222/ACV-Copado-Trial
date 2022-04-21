@isTest
public class OverlappingTimeSheetEntryCheckTest {
    private static final String USER_NAME = 'vciUser';

    @TestSetup
    static void makeData(){
        FSLTestUtility.makeResourceData();
    }

    // This test has an overlapping entry start in the middle of an existing entry and end after the existing entry ends. Expected to be marked as a duplicate
    @IsTest
    static void makeMiddleStartAndLaterEndingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );

        TimeSheet ts;
        System.runAs( u2 ) {
            ts = new TimeSheet(
                Status = 'New',
                StartDate = Date.today().toStartOfWeek(),
                EndDate = Date.today().toStartOfWeek().addDays(7),
                ServiceResourceId = sr.Id
            );
            insert ts;
        }

        DateTime nowTime = Datetime.now();

        Test.startTest();
            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }
        

            TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];

            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );

            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -10 ),
                    EndTime = nowTime.addMinutes( 20 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }

        Test.stopTest();

        TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];

        System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

        tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];

        System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

    }

    // This test has an overlapping entry start before an existing entry and end during the middle of the existing entry. Expected to be marked as a duplicate
    @IsTest
    static void makeEarlyStartAndMiddleEndingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );

        TimeSheet ts;
        System.runAs( u2 ) {
            ts = new TimeSheet(
                Status = 'New',
                StartDate = Date.today().toStartOfWeek(),
                EndDate = Date.today().toStartOfWeek().addDays(7),
                ServiceResourceId = sr.Id
            );
            insert ts;
        }

        DateTime nowTime = Datetime.now();

        Test.startTest();
            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }
        

            TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];

            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );

            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -30 ),
                    EndTime = nowTime,
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }

        Test.stopTest();

        TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];

        System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

        tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];

        System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

    }

    // This test has an overlapping entry start in the middle of an existing entry and end during the same existing entry. Expected to be marked as a duplicate
    @IsTest
    static void makeMiddleStartAndMiddleEndingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );

        TimeSheet ts;
        System.runAs( u2 ) {
            ts = new TimeSheet(
                Status = 'New',
                StartDate = Date.today().toStartOfWeek(),
                EndDate = Date.today().toStartOfWeek().addDays(7),
                ServiceResourceId = sr.Id
            );
            insert ts;
        }

        DateTime nowTime = Datetime.now();

        Test.startTest();
            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }
        

            TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];

            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );

            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -10 ),
                    EndTime = nowTime,
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }

        Test.stopTest();

        TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];

        System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

        tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];

        System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

    }

    // This test has an overlapping entry start in the at the same time of an existing entry and end during the existing entry. Expected to be marked as a duplicate
    @IsTest
    static void makeSameStartAndMiddleEndingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );

        TimeSheet ts;
        System.runAs( u2 ) {
            ts = new TimeSheet(
                Status = 'New',
                StartDate = Date.today().toStartOfWeek(),
                EndDate = Date.today().toStartOfWeek().addDays(7),
                ServiceResourceId = sr.Id
            );
            insert ts;
        }

        DateTime nowTime = Datetime.now();

        Test.startTest();
            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }
        

            TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];

            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );

            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime,
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }

        Test.stopTest();

        TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];

        System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

        tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];

        System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

    }

    // This test has an overlapping entry start in the middle of an existing entry and end at the same time as the existing entry ends. Expected to be marked as a duplicate
    @IsTest
    static void makeMiddleStartAndSameEndingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );

        TimeSheet ts;
        System.runAs( u2 ) {
            ts = new TimeSheet(
                Status = 'New',
                StartDate = Date.today().toStartOfWeek(),
                EndDate = Date.today().toStartOfWeek().addDays(7),
                ServiceResourceId = sr.Id
            );
            insert ts;
        }

        DateTime nowTime = Datetime.now();

        Test.startTest();
            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }
        

            TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];

            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );

            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime,
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }

        Test.stopTest();

        TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];

        System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

        tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];

        System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

    }

    // This test has an overlapping entry start at the same time of an existing entry and end at the same time as existing entry ends. Expected to be marked as a duplicate
    @IsTest
    static void makeSameStartAndSameEndingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );

        TimeSheet ts;
        System.runAs( u2 ) {
            ts = new TimeSheet(
                Status = 'New',
                StartDate = Date.today().toStartOfWeek(),
                EndDate = Date.today().toStartOfWeek().addDays(7),
                ServiceResourceId = sr.Id
            );
            insert ts;
        }

        DateTime nowTime = Datetime.now();

        Test.startTest();
            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }
        

            TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];

            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );

            System.runAs( u2 ) {
                insert new TimeSheetEntry(
                    TimeSheetId = ts.Id,
                    StartTime = nowTime.addMinutes( -20 ),
                    EndTime = nowTime.addMinutes( 10 ),
                    Status = 'New',
                    Subject = 'Test Entry',
                    Type = 'Direct'
                );
            }

        Test.stopTest();

        TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];

        System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

        tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];

        System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

    }

     // This test has an overlapping entry start at the same time of an existing entry and end at the same time as existing entry ends. Expected to be marked as a duplicate, then when the update occurs, clear out all duplicate/overlap fields
     @IsTest
     static void clearOverlappingEntry() {
        ServiceResource sr = [ SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1 ];
        User u2 = new User(
            Id = sr.RelatedRecordId
        );
 
         TimeSheet ts;
         System.runAs( u2 ) {
             ts = new TimeSheet(
                 Status = 'New',
                 StartDate = Date.today().toStartOfWeek(),
                 EndDate = Date.today().toStartOfWeek().addDays(7),
                 ServiceResourceId = sr.Id
             );
             insert ts;
         }
 
         DateTime nowTime = Datetime.now();
 
         Test.startTest();
             System.runAs( u2 ) {
                 insert new TimeSheetEntry(
                     TimeSheetId = ts.Id,
                     StartTime = nowTime.addMinutes( -20 ),
                     EndTime = nowTime.addMinutes( 10 ),
                     Status = 'New',
                     Subject = 'Test Entry',
                     Type = 'Direct'
                 );
             }
         
 
             TimeSheetEntry tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id LIMIT 1 ];
 
             System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );
 
             System.runAs( u2 ) {
                 insert new TimeSheetEntry(
                     TimeSheetId = ts.Id,
                     StartTime = nowTime.addMinutes( -20 ),
                     EndTime = nowTime.addMinutes( 10 ),
                     Status = 'New',
                     Subject = 'Test Entry',
                     Type = 'Direct'
                 );
             }
 
             TimeSheetEntry tse2 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id AND Id != :tse1.Id LIMIT 1 ];
 
            System.assertEquals( tse2.Overlapping_Time_Sheet_Entry__c, tse1.Id, 'There was an unexpected issue with an overlapping time sheet entry' );
    
            tse1 = [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE Id = :tse1.Id LIMIT 1 ];
    
            System.assertEquals( tse1.Overlapping_Time_Sheet_Entry__c, tse2.Id, 'There was an unexpected issue with an overlapping time sheet entry' );

            tse2.StartTime = nowTime.addMinutes( 60 );
            tse2.EndTime = nowTime.addMinutes( 120 );
            update tse2;

         Test.stopTest();

         for ( TimeSheetEntry tseRec : [ SELECT Id, Overlapping_Time_Sheet_Entry__c FROM TimeSheetEntry WHERE TimeSheetId = :ts.Id ] ) {
            System.assertEquals( tseRec.Overlapping_Time_Sheet_Entry__c, null, 'There was an unexpected issue with an overlapping time sheet entry' );
         }
     }
}