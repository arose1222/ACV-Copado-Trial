/**
 * @description ${DESCRIPTION}
 * @name tracDateUtils
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-09-05
 */

public with sharing class tracDateUtils {
    public static final Date TODAY = Date.today();
    public static final Datetime NOW = Datetime.now();
    public static final Date MONDAY_DATE = Date.newInstance(1900,1,1);

    public static final String SUNDAY = 'Sunday';
    public static final String MONDAY = 'Monday';
    public static final String TUESDAY = 'Tuesday';
    public static final String WEDNESDAY = 'Wednesday';
    public static final String THURSDAY = 'Thursday';
    public static final String FRIDAY = 'Friday';
    public static final String SATURDAY = 'Saturday';

    public static final String FIRST = 'first';
    public static final String SECOND = 'second';
    public static final String THIRD = 'third';
    public static final String FOURTH = 'fourth';
    public static final String FIFTH = 'fifth';
    public static final String LAST = 'last';

    public static final String DAY = 'day';
    public static final String WEEKEND_DAY = 'weekend day';
    public static final String WEEKDAY = 'weekday';




    public static final Map<Integer,String> WEEK_DAY_MAP = new Map<Integer, String>{
            0 => SUNDAY,
            1 => MONDAY,
            2 => TUESDAY,
            3 => WEDNESDAY,
            4 => THURSDAY,
            5 => FRIDAY,
            6 => SATURDAY
    };

    public static final Map<String,Integer> WEEK_DAY_INTEGER_MAP = new Map<String,Integer>{
            SUNDAY => 0,
            MONDAY => 1,
            TUESDAY => 2,
            WEDNESDAY => 3,
            THURSDAY => 4,
            FRIDAY => 5,
            SATURDAY => 6
    };

    public static final Map<String,Integer> NUM_ORDER_MAP = new Map<String, Integer>{
            FIRST => 0,
            SECOND => 1,
            THIRD => 2,
            FOURTH => 3,
            FIFTH => 4
    };


    /**
     * @description helper method that gets all the days from a interval
     *
     * @param every interval between the days, i.e. every 2 days
     * @param startDate
     * @param endDate
     *
     * @return list of dates from startDate to endDate with interval 'every'
     */
    public static List<Date> getDailyEveryDayBetween(Integer every, Date startDate, Date endDate) {
        List<Date> returnDates = new List<Date>();
        while(startDate < endDate) {
            returnDates.add(startDate);
            startDate = startDate.addDays(every);
        }
        return returnDates;
    }

    /**
     * @description method that gets every date between 2 specified dates weekly at a given interval
     * @param weekDay day of the week string
     * @param every the frequency of the weekly occurrence (ie 2 is every other week)
     * @param startDate date that the last data generation run generated
     * @param endDate date to stop generating data
     * @return list of dates
     */
    public static List<Date> getWeeklyEveryDayBetween(String weekDay, Integer every, Date startDate, Date endDate) {
        List<Date> returnDates = new List<Date>();
        Integer dateDiff = getDay(weekDay) - getDay(startDate);
        Date tempDate = startDate.addDays((dateDiff >= 0) ?  dateDiff : dateDiff + 7);

        while(tempDate < endDate) {
            returnDates.add(tempDate);
            tempDate = tempDate.addDays(7*every);
        }

        return returnDates;
    }


    /**
     * @description helper method that retrun list of dates based on a given date in a month
     *
     * @param dayInMonth a date in a month, for example. 28th of a month
     * @param every interval between months
     * @param startDate
     * @param endDate
     *
     * @return
     */
    public static List<Date> getMonthlyOnDay(Integer dayInMonth, Integer every, Date startDate, Date endDate) {
        List<Date> returnDates = new List<Date>();
        Date tempDate = (startDate.day() > dayInMonth) //if the specified date is before
                ? Date.newInstance(startDate.addMonths(1).year(),startDate.addMonths(1).month(),dayInMonth)
                : Date.newInstance(startDate.year(),startDate.month(),dayInMonth);

        while( tempDate < endDate) {
            if (tempDate.day() == dayInMonth) {
                returnDates.add(tempDate);
            } //do not add the day if it doesn't exist
            tempDate = tempDate.addMonths(every);
        }

        return returnDates;
    }


    /**
     *
     *
     * @param whichWeek
     * @param weekDayString
     * @param Every
     * @param startDate
     * @param endDate
     *
     * @return
     */
    public static List<Date> getMonthlyEach(String whichWeek, String weekDayString, Integer Every, Date startDate, Date endDate){
        List<Date> returnDates = new List<Date>();
        Date currentStartDate = startDate;

        if (WEEK_DAY_INTEGER_MAP.containsKey(weekDayString)){
            while (currentStartDate < endDate){
                Date tempDate = getFirstDateInMonth(currentStartDate, weekDayString);

                if (whichWeek != LAST){
                    Integer weekNum = NUM_ORDER_MAP.get(whichWeek);
                    Integer currMonth = tempDate.month();
                    tempDate = tempDate.addDays(7 * weekNum);
                    if (currMonth == tempDate.month() && tempDate > startDate && tempDate <= endDate) {
                       //only add if the date exists and is after the startDate.
                        returnDates.add(tempDate);
                    }
                }else{//LAST WEEK
                    Integer currMonth = tempDate.month();
                    while (tempDate.addDays(7).month() == currMonth){
                        tempDate = tempDate.addDays(7);
                    }
                    if (tempDate > startDate && tempDate <= endDate) {
                        returnDates.add(tempDate);
                    }
                }
                currentStartDate = currentStartDate.addMonths(Every);
            }
        }else{
            while (currentStartDate <= endDate){
                Date tempDate;
                Integer dateOffset;
                if (whichWeek == FIRST){
                    tempDate = currentStartDate.toStartOfMonth();
                    dateOffset = 1;
                }else{
                    tempDate =  currentStartDate.addMonths(1).toStartOfMonth().addDays(-1);
                    dateOffset = -1;
                }

                if (weekDayString == WEEKDAY) {
                    while (getDay(tempDate) == 0 || getDay(tempDate) == 6){
                        tempDate = tempDate.addDays(dateOffset);
                    }
                }else if (weekDayString == WEEKEND_DAY){
                    while (getDay(tempDate) != 0 && getDay(tempDate) != 6){
                        tempDate = tempDate.addDays(dateOffset);
                    }
                }
                if (tempDate > startDate && tempDate <= endDate) {
                    returnDates.add(tempDate);
                }

                currentStartDate = currentStartDate.addMonths(Every);
            }
        }
        return returnDates;

    }

    public static Date getFirstDateInMonth(Date originalDate, String weekdayString){
        Date d = originalDate.toStartOfMonth();
        Integer firstDateInMonth = getDay(d);
        Integer dateDiff = getDay(weekdayString) - firstDateInMonth;
        d = d.addDays((dateDiff >= 0) ?  dateDiff : dateDiff + 7);
        return d;

    }

    /**
     * @description gets the day of the week based on a date value
     * @param day date value
     * @return integer of the week day
     */
    public static Integer getDay(Date day) {
        return Math.mod(MONDAY_DATE.daysBetween(day)+1,7);
    }


    /**
     * @description gets the day of the week based on name of the day of the week
     * @param day string day name value
     * @return integer of the day of the week
     */
    public static Integer getDay(String day) {
        return WEEK_DAY_INTEGER_MAP.get(day);
    }


    /**
     * @description gets the day of the week based on an integer
     * @param day integer value of a week day
     * @return string day name value
     */
    public static String getDay(Integer day) {
        return WEEK_DAY_MAP.get(day);
    }

    /**
 * @description gets the day of the week based on an Date object
 * @param day String value of a week day
 * @return string day name value
 */
    public static String getDayFromDateObject(Date day) {
        return getDay(getDay(day));
    }


}