/**
 * Test Class for the CronGenerator Class
 * @author James Andre LaCour
 */
@isTest
public class CronGeneratorTest {
    /**
     * Tests the Perpetual String for Six and Seven Parameter
     * @return void
     */
    public static testMethod void perpetualTest(){
        String perpetualSixExpected = '* * * * * *';
        String perpetualSevenExpected = '* * * * * * *';
        Test.startTest();
            String perpetualSixActual = CronGenerator.createPerpetualExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX );
            String perpetualSevenActual = CronGenerator.createPerpetualExpression( CronGenerator.CRON_PARAMETER_SIZE.SEVEN );
        Test.stopTest();
        System.assertEquals( perpetualSixExpected, perpetualSixActual);
        System.assertEquals( perpetualSevenExpected, perpetualSevenActual);
    }
    /**
     * Tests the One Time String for Six and Seven Parameter
     * @return void
     */
    public static testMethod void oneTimeTest(){
        DateTime thisDateTime = DateTime.newInstanceGmt(2021, 10, 9, 8, 7, 6);
        String oneTimeSixExpected = '6 7 8 9 10 *';
        String oneTimeSevenExpected = '6 7 8 9 10 * 2021';
        Test.startTest();
            String oneTimeSixActual = CronGenerator.createOneTimeExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX, thisDateTime );
            String oneTimeSevenActual = CronGenerator.createOneTimeExpression( CronGenerator.CRON_PARAMETER_SIZE.SEVEN, thisDateTime );
        Test.stopTest();
        System.assertEquals( oneTimeSixExpected, oneTimeSixActual);
        System.assertEquals( oneTimeSevenExpected, oneTimeSevenActual);
    }
    /**
     * Tests the Daily String for Six and Seven Parameter
     * @return void
     */
    public static testMethod void dailyTest(){
        DateTime thisDateTime = DateTime.newInstanceGmt(2021, 10, 9, 8, 7, 6);
        String dailySixExpected = '6 7 8 * * *';
        String dailySevenExpected = '6 7 8 * * * *';
        Test.startTest();
            String dailySixActual = CronGenerator.createDailyExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX, thisDateTime );
            String dailySevenActual = CronGenerator.createDailyExpression( CronGenerator.CRON_PARAMETER_SIZE.SEVEN, thisDateTime );
        Test.stopTest();
        System.assertEquals( dailySixExpected, dailySixActual);
        System.assertEquals( dailySevenExpected, dailySevenActual);
    }
    /**
     * Tests the Weekly String for Six and Seven Parameter
     * @return void
     */
    public static testMethod void weeklyTest(){
        DateTime thisDateTime = DateTime.newInstanceGmt(2021, 10, 9, 8, 7, 6);
        List<String> days = new List<String>{'1','3','5','7'};
        String weeklySixExpected = '6 7 8 * * 1,3,5,7';
        String weeklySevenExpected = '6 7 8 * * 1,3,5,7 *';
        Test.startTest();
            String weeklySixActual = CronGenerator.createWeeklyExpression( CronGenerator.CRON_PARAMETER_SIZE.SIX, thisDateTime, days);
            String weeklySevenActual = CronGenerator.createWeeklyExpression( CronGenerator.CRON_PARAMETER_SIZE.SEVEN, thisDateTime, days );
        Test.stopTest();
        System.assertEquals( weeklySixExpected, weeklySixActual);
        System.assertEquals( weeklySevenExpected, weeklySevenActual);
    }
}