/**
 * Test class for SendPolicyEmailOnLeadConvertSchedulable
 * @author Jyothsna P
 * @since 4/16/21
 */

@isTest
public class SendPolicyEmailLeadConvertSchedulableTst {
 
    // Schedule the policy email after 2 days.
    @isTest
    public static void SendPolicyEmail(){

        Account a = TestUtility.createAccount('Account 1');
        insert a;
        
        Contact c = TestUtility.createContact(a);
        insert c;

        Datetime runtime= Datetime.now().addDays(1);
        String hour = String.valueOf(runtime.hour());
        String min = String.valueOf(runTime.minute());
        String second = String.valueOf(runTime.second());
        String day = String.valueOf(runTime.day());
        String month = String.valueOf(runTime.month());
        String year = String.valueOf(runTime.year());
        String cronExp = second+' '+min+' '+hour+' '+day+' '+month+' ? '+year;

        Test.startTest();
        SendPolicyEmailOnLeadConvertSchedulable s = new SendPolicyEmailOnLeadConvertSchedulable(new List<Id>{c.Id});
        String jobId = System.schedule('SendPolicyEmailSchedulable: Job Started At ' + String.valueOf(Datetime.now()), cronExp, s);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals(string.valueOf(runtime), String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

   
}