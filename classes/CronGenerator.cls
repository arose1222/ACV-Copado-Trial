/**
 * CronGenerator is a Helper Class that takes in parameters and returns
 * a Cron expression in the Quartz style
 * @author James Andre LaCour
 */
public class CronGenerator {
    /****************Class Variables**********************/
    public enum CRON_PARAMETER_SIZE { SIX, SEVEN } // 1.second 2.minute 3.hour 4.dayOfMonth 5.month 6.dayOfWeek 7.year
    /****************Helper Methods***********************/
    // Perpetual Methods - Perpetual frequency runs every day, every minute, every second
    /**
     * Returns a Perpetual Cron Expression - Quartz framework
     * @param paramSize - whether we will return SIX or SEVEN parameter CronExpression
     * @return String - Perpetual CronExpression
     */
    public static String createPerpetualExpression( CRON_PARAMETER_SIZE paramSize ){
        String cronExpression = '* * * * * *';
        if( paramSize == CRON_PARAMETER_SIZE.SEVEN ) cronExpression = cronExpression + ' *';
        return cronExpression;
    }
    // One Time Methods - One-Time Frequency runs at a specific Date and time
    /**
     * Returns a One Tiem Cron Expression - GMT TimeZone - Quartz framework
     * @param paramSize - whether we will return SIX or SEVEN parameter CronExpression
     * @param thisDateTime - The DateTime value to get the Time and Day values out of
     * @return String - OneTime CronExpression
     */
    public static String createOneTimeExpression( CRON_PARAMETER_SIZE paramSize, Datetime thisDateTime ){
        String secondGmt = String.valueOf(thisDateTime.secondGmt());
        String minuteGmt = String.valueOf(thisDateTime.minuteGmt());
        String hourGmt = String.valueOf(thisDateTime.hourGmt());
        String dayGmt = String.valueOf(thisDateTime.dayGmt());
        String monthGmt = String.valueOf(thisDateTime.monthGmt());
        String dayOfWeek = '*';
        String yearGmt = String.valueOf(thisDateTime.yearGmt());
        List<String> cronParamList = new List<String>{ secondGmt, minuteGmt, hourGmt, dayGmt, monthGmt, dayOfWeek };
        if( paramSize == CRON_PARAMETER_SIZE.SEVEN ) cronParamList.add( yearGmt );
        return String.join( cronParamList, ' ' );
    }
    // Recurring Methods - Recurring Frequencies run at a specific time over various time frames
    /**
     * Returns a Daily Cron Expression - GMT TimeZone - Quartz framework
     * @param paramSize - whether we will return SIX or SEVEN parameter CronExpression
     * @param thisDateTime - The DateTime value to get the Time values out of. Date value is Date.Today()
     * @return String - Daily CronExpression
     */
    public static String createDailyExpression( CRON_PARAMETER_SIZE paramSize, Datetime thisDateTime ){
        String secondGmt = String.valueOf( thisDateTime.secondGmt() );
        String minuteGmt = String.valueOf( thisDateTime.minuteGmt() );
        String hourGmt = String.valueOf( thisDateTime.hourGmt() );
        String dayOfMonth = '*';
        String month = '*';
        String dayOfWeek = '*';
        String year = '*';
        List<String> cronParamList = new List<String>{ secondGmt, minuteGmt, hourGmt, dayOfMonth, month, dayOfWeek };
        if( paramSize == CRON_PARAMETER_SIZE.SEVEN ) cronParamList.add( year );
        return String.join( cronParamList, ' ' );
    }
    /**
     * Returns a Weekly Cron Expression - GMT TimeZone - Quartz framework
     * @param paramSize - whether we will return SIX or SEVEN parameter CronExpression
     * @param thisDateTime - The DateTime value to get the Time values out of. Date value is Date.Today()
     * @param daysList - A List of Days that the expression will run on. Day values are numerical: ie, Sunday =1, Monday=2, etc...
     * @return String - Weekly CronExpression
     */
    public static String createWeeklyExpression( CRON_PARAMETER_SIZE paramSize, Datetime thisDateTime, List<String> daysList ){
        String secondGmt = String.valueOf( thisDateTime.secondGmt() );
        String minuteGmt = String.valueOf( thisDateTime.minuteGmt() );
        String hourGmt = String.valueOf( thisDateTime.hourGmt() );
        String dayOfMonth = '*';
        String month = '*';
        String daysOfWeek = String.join( daysList, ',' );
        String year = '*';
        List<String> cronParamList = new List<String>{ secondGmt, minuteGmt, hourGmt, dayOfMonth, month, daysOfWeek };
        if( paramSize == CRON_PARAMETER_SIZE.SEVEN ) cronParamList.add( year );
        return String.join( cronParamList, ' ' );
    }
}