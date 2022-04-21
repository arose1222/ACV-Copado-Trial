/**
 * @description ${DESCRIPTION}
 * @name tracConstantsTest
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-10-28
 */

@IsTest
private class tracConstantsTest {
    @IsTest
    static void testConstants() {
        System.assertEquals('Daily',tracConstants.DATA_FREQUENCY_DAILY);
        System.assertEquals('Weekly',tracConstants.DATA_FREQUENCY_WEEKLY);
        System.assertEquals('Monthly',tracConstants.DATA_FREQUENCY_MONTHLY);
        System.assertEquals('Days',tracConstants.DATA_HORIZON_DAYS);
        System.assertEquals('Weeks',tracConstants.DATA_HORIZON_WEEKS);
        System.assertEquals('Months',tracConstants.DATA_HORIZON_MONTHS);
        System.assertEquals('Daily',tracConstants.FREQUENCY_DAILY);
        System.assertEquals('Weekly',tracConstants.FREQUENCY_WEEKLY);
        System.assertEquals('Monthly',tracConstants.FREQUENCY_MONTHLY);
        System.assertEquals('Yearly',tracConstants.FREQUENCY_YEARLY);
        System.assertEquals('Internal Review',tracConstants.WOLI_STATUS_INTERNAL_REVIEW);
        System.assertEquals('Prescreen ',tracConstants.PRESCREEN);
        System.assertEquals('Closed',tracConstants.PRESCREEN_CLOSED_STATUS);
        System.assertEquals('Prescreen Submitted',tracConstants.PRESCREEN_SUBMITTED);
        System.assertEquals('Prescreen Pass',tracConstants.PRESCREEN_PASS);
        System.assertEquals('Prescreen Fail',tracConstants.PRESCREEN_FAIL);
        System.assertEquals('Line Item Number: ',tracConstants.WOLI_NUMBER);

    }
}