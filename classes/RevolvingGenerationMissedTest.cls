@isTest
public class RevolvingGenerationMissedTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        Data_Schedule__c schedule = new Data_Schedule__c();
            schedule.Frequency__c = 'Monthly';
            schedule.Day__c = '5';
            schedule.Active__c = true;
            schedule.Batch_Size__c = 25;
        insert schedule;

        Account acct = TestUtility.createAccount();
        insert acct;

        List<WorkType> workTypeList = FSLTestUtility.createWorkTypes();
        insert workTypeList;

        Timeline__c RevolvingAppointment = new Timeline__c();
            RevolvingAppointment.Account__c = acct.Id;
            RevolvingAppointment.Is_Active__c = TRUE;
            RevolvingAppointment.Start_Date__c = Date.today().addDays(-7);
            RevolvingAppointment.Average_Number_Cars__c = 1;
            RevolvingAppointment.Work_Type__c = workTypeList[0].Id;
        insert RevolvingAppointment;

        Occurrence__c occurrence = new Occurrence__c();
            occurrence.Timeline__c = RevolvingAppointment.Id;
            occurrence.Is_Active__c = true;
            occurrence.Start_Time__c = Time.newInstance(12,0,0,0);
            occurrence.Is_Active__c = true;
            occurrence.Frequency__c = 'Weekly';
            occurrence.Every__c = 1;
            occurrence.Day__c = 'Monday';
        insert occurrence;
    }

    @IsTest
    static void testRevolvingGenerationMissed(){

        Test.startTest();
            RevolvingGenerationMissed rgmClass = new RevolvingGenerationMissed();
            String chron = '0 0 23 * * ?';
            system.schedule('Test Sched', chron, rgmClass);
        Test.stopTest();

        system.assert([SELECT count() FROM Integration_Result__c] > 0, 'The Splunk Record was not created');
    }
}