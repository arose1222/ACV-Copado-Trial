/**
 * Test class for SendDelayedPolicyEmailSchedulable
 * @author Jyothsna P
 * @since 09/24/21
 */


 @isTest
 public class SendDelayedPolicyEmailSchedulableTest {

    private static final Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
  
     // Schedule the policy email after 2 days.
     @isTest
     public static void UpdateSendPolicyEmailFlag(){
 
         // org lead converted account
         Account a1 = TestUtility.createAccount('Account 1');
         a1.Lead_Convert_Status__c ='Complete';
         
         // non org lead converted account 
         Account a2 = TestUtility.createAccount('Account 2');
         
         List<Account> acclist= new List<Account>();
         acclist.add(a1);
         acclist.add(a2);
         insert acclist;
         
         // org lead converted acv user
         Contact c1 = TestUtility.createContact(a1);
         c1.FirstName= 'orgleadconvertedacvuser';
         c1.Lead_Created_Contact__c= true;
         c1.Policy_Email_Status__c= 'Policy Email Not Sent';
         c1.RecordTypeid= acvuserRecordTypeId;

         // non org lead converted standard contact
         Contact c2 = TestUtility.createContact(a2);
         c2.Lead_Created_Contact__c= true;
         
         // non org lead converted standard contact
         Contact c3 = TestUtility.createContact(a2);
          
         List<Contact> conList= new List<Contact>();
         conList.add(c1);
         conList.add(c2);
         conList.add(c3);
         insert conList;
      
         /*
         // Scheduling the job
         Datetime runtime= Datetime.now().addDays(1);
         String hour = String.valueOf(runtime.hour());
         String min = String.valueOf(runTime.minute());
         String second = String.valueOf(runTime.second());
         String day = String.valueOf(runTime.day());
         String month = String.valueOf(runTime.month());
         String year = String.valueOf(runTime.year());
         String cronExp = second+' '+min+' '+hour+' '+day+' '+month+' ? '+year;
         */

         Test.startTest();
         SendDelayedPolicyEmailSchedulable s = new SendDelayedPolicyEmailSchedulable();
         s.executeScheduledLogic();
        /*
         String jobId = System.schedule('SendPolicyEmailSchedulable: Job Started At ' + String.valueOf(Datetime.now()), cronExp, s);
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
         System.assertEquals(cronExp, ct.CronExpression);
         System.assertEquals(0, ct.TimesTriggered);
         System.assertEquals(string.valueOf(runtime), String.valueOf(ct.NextFireTime));
         */
         Test.stopTest();

         /*
            Assert to check the flag is set. If the workflow rule is enabled, then Policy_Email_Status__c will be set to 'Policy Email Sent'
         */
         System.Assert([Select Count() from Contact Where Policy_Email_Status__c= 'Send Policy Email' or Policy_Email_Status__c= 'Policy Email Sent'] == 1, 'Incorrect number of users by Policy Email Status field.');
         System.Assert([Select Count() from Contact Where (Policy_Email_Status__c= 'Send Policy Email' or Policy_Email_Status__c= 'Policy Email Sent') and Firstname='orgleadconvertedacvuser'] == 1, 'Incorrect user by Policy Email Status field.');

        
     }
 
    
 }