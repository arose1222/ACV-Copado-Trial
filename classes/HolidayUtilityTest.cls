@isTest
public class HolidayUtilityTest {
    
    @isTest
    static void makeRecurYearlyNthHoliday() {
        List<Holiday> newTestHolidayLst = new List<Holiday>();
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursYearlyNth',
            isRecurrence = TRUE,
            RecurrenceInstance = 'Last',
            RecurrenceMonthOfYear = 'December',
            IsAllDay = TRUE,
            RecurrenceDayOfWeekMask = 16,
            RecurrenceStartDate = Date.today()
        ) );
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursYearlyNth',
            isRecurrence = TRUE,
            RecurrenceInstance = 'Fourth',
            RecurrenceMonthOfYear = 'November',
            IsAllDay = TRUE,
            RecurrenceDayOfWeekMask = 16,
            RecurrenceStartDate = Date.today()
        ) );
        insert newTestHolidayLst;

        Test.startTest();
            HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
        Test.stopTest();
    }

    @isTest
    static void makeRecursYearlyHoliday() {
        List<Holiday> newTestHolidayLst = new List<Holiday>();
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursYearly',
            isRecurrence = TRUE,
            RecurrenceMonthOfYear = 'December',
            IsAllDay = TRUE,
            RecurrenceDayOfMonth = 15,
            RecurrenceStartDate = Date.today()
        ) );
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursYearly',
            isRecurrence = TRUE,
            RecurrenceMonthOfYear = 'November',
            IsAllDay = TRUE,
            RecurrenceDayOfMonth = 15,
            RecurrenceStartDate = Date.today()
        ) );
        insert newTestHolidayLst;

        Test.startTest();
            HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
        Test.stopTest();
    }

    @isTest
    static void makeRecursMonthlyNthHoliday() {
        List<Holiday> newTestHolidayLst = new List<Holiday>();
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursMonthlyNth',
            isRecurrence = TRUE,
            RecurrenceInstance = 'Last',
            IsAllDay = TRUE,
            RecurrenceDayOfWeekMask = 16,
            RecurrenceInterval = 30,
            RecurrenceStartDate = Date.today()
        ) );
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursMonthlyNth',
            isRecurrence = TRUE,
            RecurrenceInstance = 'Fourth',
            IsAllDay = TRUE,
            RecurrenceDayOfWeekMask = 16,
            RecurrenceInterval = 30,
            RecurrenceStartDate = Date.today()
        ) );
        insert newTestHolidayLst;

        Test.startTest();
            HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
        Test.stopTest();
    }

    @isTest
    static void makeRecursMonthlyHoliday() {
        List<Holiday> newTestHolidayLst = new List<Holiday>();
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursMonthly',
            isRecurrence = TRUE,
            IsAllDay = TRUE,
            RecurrenceInterval = 30,
            RecurrenceDayOfMonth = 15,
            RecurrenceStartDate = Date.today()
        ) );
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursMonthly',
            isRecurrence = TRUE,
            IsAllDay = TRUE,
            RecurrenceInterval = 30,
            RecurrenceDayOfMonth = 15,
            RecurrenceStartDate = Date.today()
        ) );
        insert newTestHolidayLst;

        Test.startTest();
            HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
        Test.stopTest();
    }

    @isTest
    static void makeRecursWeeklyHoliday() {
        List<Holiday> newTestHolidayLst = new List<Holiday>();
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursWeekly',
            isRecurrence = TRUE,
            IsAllDay = TRUE,
            RecurrenceInterval = 30,
            RecurrenceDayOfWeekMask = 16,
            RecurrenceStartDate = Date.today()
        ) );
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursWeekly',
            isRecurrence = TRUE,
            IsAllDay = TRUE,
            RecurrenceInterval = 30,
            RecurrenceDayOfWeekMask = 16,
            RecurrenceStartDate = Date.today()
        ) );
        insert newTestHolidayLst;

        Test.startTest();
            HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
        Test.stopTest();
    }

    @isTest
    static void RecursDailyHoliday() {
        List<Holiday> newTestHolidayLst = new List<Holiday>();
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursDaily',
            isRecurrence = TRUE,
            IsAllDay = TRUE,
            RecurrenceInterval = 30,
            RecurrenceStartDate = Date.today()
        ) );
        newTestHolidayLst.add( new Holiday(
            Name = 'Test Holiday',
            RecurrenceType = 'RecursDaily',
            isRecurrence = TRUE,
            IsAllDay = TRUE,
            RecurrenceInterval = 30,
            RecurrenceStartDate = Date.today()
        ) );
        insert newTestHolidayLst;

        Test.startTest();
            HolidayUtility.getHolidaysForDates( Date.today(), Date.today().addYears(1) );
        Test.stopTest();
    }
}