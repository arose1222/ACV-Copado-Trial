/**
 * Created by zdeng on 9/16/2019.
 */

@IsTest
private class tracDateUtils_Test {
    @IsTest
    static void testDailyEveryDayBetween() {
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);
        for (Integer i = 0; i < 100 ; i++){
            test0.add(startDate.addDays(i*10));
        }
        List<Date> returnedDates = tracDateUtils.getDailyEveryDayBetween(10,startDate,test0[99]);

        System.assertEquals(test0[0],returnedDates[0]);
        System.assertEquals(test0[1],returnedDates[1]);
        System.assertEquals(test0[3],returnedDates[3]);

        System.assertEquals(test0[13],returnedDates[13]);
        System.assertEquals(test0[32],returnedDates[32]);
    }

    @IsTest static void testWeeklyEveryDayBetween(){
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);

        test0.add(startDate);
        test0.add(startDate.addDays(21));
        test0.add(startDate.addDays(42));
        test0.add(startDate.addDays(63));

        List<Date> returnedDates = tracDateUtils.getWeeklyEveryDayBetween('Monday',3,startDate,startDate.addMonths(2));

        System.assertEquals(test0[0],returnedDates[0]);
        System.assertEquals(test0[1],returnedDates[1]);
//        System.assertEquals(test0[3],returnedDates[3]);
    }

    @IsTest static void testMonthlyOnDay(){
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);

        List<Date> returnedDates = tracDateUtils.getMonthlyOnDay(13, 2, startDate, startDate.addMonths(6));
        test0.add(startDate.addDays(11));
        test0.add(startDate.addDays(72));
//        test0.add(startDate.addDays(63));
        System.assertEquals(test0[0],returnedDates[0]);
        System.assertEquals(test0[1],returnedDates[1]);
//        System.assert(test0[2] == returnedDates[2]);

    }

    @IsTest static void testMonthlyEach0(){
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);

        List<Date> returnedDates = tracDateUtils.getMonthlyEach(tracDateUtils.THIRD, tracDateUtils.FRIDAY,1, startDate, startDate.addMonths(6));

        test0.add(Date.newInstance(2019,9,20));
        test0.add(Date.newInstance(2019,10,18));

        System.assertEquals(test0[0],returnedDates[0]);
        System.assertEquals(test0[1],returnedDates[1]);

    }

    @IsTest static void testMonthlyEach1(){
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);

        List<Date> returnedDates = tracDateUtils.getMonthlyEach(tracDateUtils.LAST, tracDateUtils.FRIDAY,1, startDate, startDate.addMonths(6));

        test0.add(Date.newInstance(2019,9,27));
        test0.add(Date.newInstance(2019,10,25));

        System.assertEquals(test0[0],returnedDates[0]);
        System.assertEquals(test0[1],returnedDates[1]);

    }


    @IsTest static void testMonthlyEach2(){
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);

        List<Date> returnedDates = tracDateUtils.getMonthlyEach(tracDateUtils.LAST, tracDateUtils.WEEKDAY,1, startDate, startDate.addMonths(6));

        test0.add(Date.newInstance(2019,9,30));
        test0.add(Date.newInstance(2019,10,31));

        System.assertEquals(test0[0],returnedDates[0]);
        System.assertEquals(test0[1],returnedDates[1]);

    }

    @IsTest static void testMonthlyEach3(){
        List<Date> test0 = new List<Date>();
        Date startDate = Date.newInstance(2019,9,2);

        List<Date> returnedDates = tracDateUtils.getMonthlyEach(tracDateUtils.FIRST, tracDateUtils.WEEKEND_DAY,1, startDate, startDate.addMonths(6));

//        test0.add(Date.newInstance(2019,9,6));
        test0.add(Date.newInstance(2019,10,5));

        System.assertEquals(test0[0],returnedDates[0]);
//        System.assertEquals(test0[1],returnedDates[1]);

    }
}