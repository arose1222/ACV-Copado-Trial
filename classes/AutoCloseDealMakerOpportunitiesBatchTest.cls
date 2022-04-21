@isTest
public class AutoCloseDealMakerOpportunitiesBatchTest {
    
    @TestSetup
    public static void makeData(){
        List<Opportunity> newOppList = New List<Opportunity>();
        Id DealerMakerOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Maker').getRecordTypeId();
      for(Integer i = 0; i < 100; i++){
          newOppList.add(new Opportunity(recordTypeId=DealerMakerOppRecordType,name='test: '+i,closedate=system.today().addDays(-1), StageName='New'));
      }

      if(newOppList.size() > 0){
          insert newOppList;
      }
    }

    @IsTest
    public static void testBatch(){
      
      test.startTest();
        id batchJob = Database.executeBatch(new AutoCloseDealMakerOpportunitiesBatch(),200);
      test.stopTest();

      System.assert([select id from Opportunity where isclosed = false].size() == 0, 'There should be no opportunities, but some were found');
      
    }

    @IsTest
    public static void testBatchSchedule(){
      test.startTest();
        AutoCloseDealmakerOpportunitiesScheduler batch = new AutoCloseDealmakerOpportunitiesScheduler();
        batch.executeScheduledLogic();
      test.stopTest();
    }
}