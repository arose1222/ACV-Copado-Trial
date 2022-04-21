/**
 * Test class for Case48HourLogic
 * @author James Andre LaCour
 */
@isTest
public class Case48HourLogicTest {
    /*********** Context Methods ***********/
    /**
     * Data setup
     * @return void
     */
    @TestSetup
    static void makeData(){
        Auction__c a = new Auction__c();
        a.Name = 'Test Auction';
        a.Payment_Status__c = 'Paid';
        a.End_Time__c = Datetime.now().addDays(-365);
        insert a;

        Case c = new Case();
        c.RecordTypeId = Case48HourLogic.titleInfoRTId;
        c.Status = 'New';
        c.Auction_Number__c = a.Id;
        c.ACV_Titles_External_ID__c = '123';
        insert c;

    }
    /*********** Test Methods ***********/
                    //Test Expectaion chart for Dates
    /*If Buyer Notice Given                --> Then 48 Hour Notice Period Expires
    Monday before 5:00pm EST               --> Wednesday at 5:00pm EST
    Monday at or after 5:00pm EST          --> Thursday at 5:00pm EST
    Tuesday before 5:00pm EST              --> Thursday at 5:00pm EST
    Tuesday at or after after 5:00pm EST   --> Friday at 5:00pm EST
    Wednesday before 5:00pm EST            --> Friday at 5:00pm EST
    Wednesday at or after after 5:00pm EST --> Monday at 5:00pm EST
    Thursday before 5:00pm EST             --> Monday at 5:00pm EST
    Thursday at or after after 5:00pm EST  --> Tuesday at 5:00pm EST
    Friday before 5:00pm EST               --> Tuesday at 5:00pm EST
    Friday at or after after 5:00pm EST    --> Wednesday at 5:00pm EST
    Saturday (anytime) EST                 --> Wednesday at 5:00pm EST
    Sunday (anytime) EST                   --> Wednesday at 5:00pm EST */
    /**
     * Test that a weekday before 5 counts the current day as the start date.
     * Expectaion Result is that day + 2 (weekend and holiday logic as well)
     * @return void
     */
    public testmethod static void weekdayBefore5Test(){
        Case c = [ SELECT Id FROM Case LIMIT 1 ];
        Time before5pm = Time.newInstance(12,0,0,0);
        Date testDate = Date.newInstance(1992, 09, 11); //A Friday
        Test.startTest();
            Case48HourLogic.initialDatetime = Datetime.newInstance(testDate, before5pm);
            c.Status = Case48HourLogic.CASE_STATUS_CHECK;
            update c;
        Test.stopTest();

        c = [ SELECT Id, X48_Hour_Expiration__c FROM Case WHERE Id = :c.Id LIMIT 1 ];
        Datetime expectedDatetime = Datetime.newInstance(testDate.addDays(4), Case48HourLogic.EXPIRATION_TIME);
        System.AssertEquals(expectedDatetime, c.X48_Hour_Expiration__c, 'Incorrect Expiration Date');
    }
    /**
     * Test that a weekend counts the first business day after the weekend as the start date.
     * Expectaion Result is first Business day + 2 (weekend and holiday logic as well)
     * @return void
     */
    public testmethod static void weekendTest(){
        Case c = [ SELECT Id FROM Case LIMIT 1 ];
        Time before5pm = Time.newInstance(12,0,0,0);
        Date testDate = Date.newInstance(1992, 12, 27); //A Sunday
        Test.startTest();
            Case48HourLogic.initialDatetime = Datetime.newInstance(testDate, before5pm);
            c.Status = Case48HourLogic.CASE_STATUS_CHECK;
            update c;
        Test.stopTest();

        c = [ SELECT Id, X48_Hour_Expiration__c FROM Case WHERE Id = :c.Id LIMIT 1 ];
        Datetime expectedDatetime = Datetime.newInstance(testDate.addDays(3), Case48HourLogic.EXPIRATION_TIME);
        System.AssertEquals(expectedDatetime, c.X48_Hour_Expiration__c, 'Incorrect Expiration Date');
    }
    /**
     * Test that a weekday after 5 counts the first business day after this day as the start date.
     * Expectaion Result is first Business day + 2 (weekend and holiday logic as well)
     * @return void
     */
    public testmethod static void weekdayAfter5Test(){
        Case c = [ SELECT Id FROM Case LIMIT 1 ];
        Time after5pm = Time.newInstance(20,0,0,0);
        Date testDate = Date.newInstance(2018, 06, 06); //A Wedneday
        Test.startTest();
            Case48HourLogic.initialDatetime = Datetime.newInstance(testDate, after5pm);
            c.Status = Case48HourLogic.CASE_STATUS_CHECK;
            update c;
        Test.stopTest();

        c = [ SELECT Id, X48_Hour_Expiration__c FROM Case WHERE Id = :c.Id LIMIT 1 ];
        Datetime expectedDatetime = Datetime.newInstance(testDate.addDays(5), Case48HourLogic.EXPIRATION_TIME);
        System.AssertEquals(expectedDatetime, c.X48_Hour_Expiration__c, 'Incorrect Expiration Date');
    }
}