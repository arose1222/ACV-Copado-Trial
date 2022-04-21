@isTest
public class ChatterUtilityTest {
    
    @IsTest
    static void CreateChatterWrapperTest(){
      
      Lead newLead = new Lead(FirstName = 'Test', LastName ='Test', Company='Test');
      insert newLead;

      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      // User u = new User(Alias = 'standt', Email='standarduser@acv.com', 
      //   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      //   LocaleSidKey='en_US', ProfileId = p.Id, 
      //   TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com');
      User u = TestUtility.createUser();
      insert u;

      ChatterUtility.ChatterWrapper cw = new ChatterUtility.ChatterWrapper();
      ChatterUtility.ChatterWrapper cw1 = new ChatterUtility.ChatterWrapper(newLead.id, 'test Post');
      ChatterUtility.ChatterWrapper cw2 = new ChatterUtility.ChatterWrapper(newLead.id, 'test Post', u.id);
      
    }

    @isTest(seeAllData=true)
    static void CreateSingleChatterMentionPost(){
        Lead newLead = new Lead(FirstName = 'Test', LastName ='Test', Company='Test');
      insert newLead;

      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
      // User u = new User(Alias = 'standt', Email='standarduser@acv.com', 
      //   EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
      //   LocaleSidKey='en_US', ProfileId = p.Id, 
      //   TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com');
        User u = TestUtility.createUser();
        insert u;

      ChatterUtility.ChatterWrapper cw2 = new ChatterUtility.ChatterWrapper(newLead.id, 'test Post', u.id);

//      ChatterUtility.mentionTextRecordPost(cw2);
      ChatterUtility.mentionTextRecordPost(u.id,newLead.id,'testPost');
    }

    @IsTest(SeeAllData=true)
    static void CreateSingleChatterMentionPostNoUser() {
        Lead newLead = new Lead(FirstName = 'Test', LastName ='Test', Company='Test');
        insert newLead;

        ChatterUtility.mentionTextRecordPost(newLead.id,'testPost');
    }

    @isTest(seeAllData=true)
    static void createMultipleMentionPosts(){
        Lead newLead = new Lead(FirstName = 'Test', LastName ='Test', Company='Test');
        insert newLead;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        // User u = new User(Alias = 'standt', Email='standarduser@acv.com', 
        // EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        // LocaleSidKey='en_US', ProfileId = p.Id, 
        // TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com');
        User u = TestUtility.createUser();
      insert u;

        List<ChatterUtility.ChatterWrapper> cwList = new List<ChatterUtility.ChatterWrapper>();
        for(integer i =0; i < 10;i++){
            ChatterUtility.ChatterWrapper cw = new ChatterUtility.ChatterWrapper(newLead.id, 'test post '+i, u.id);
            cwList.add(cw);
        }

        ChatterUtility.mentionTextRecordPostBatch(cwList);
    }

    @isTest(seeAllData=true)
    static void createMultipleMentionPostsWithURL(){
        Lead newLead = new Lead(FirstName = 'Test', LastName ='Test', Company='Test');
        insert newLead;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        // User u = new User(Alias = 'standt', Email='standarduser@acv.com',
        //         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        //         LocaleSidKey='en_US', ProfileId = p.Id,
        //         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com');
        User u = TestUtility.createUser();
      insert u;

        List<ChatterUtility.ChatterWrapper> cwList = new List<ChatterUtility.ChatterWrapper>();
        for(integer i =0; i < 10;i++){
            ChatterUtility.ChatterWrapper cw = new ChatterUtility.ChatterWrapper(newLead.id, 'test post '+i, u.id, 'testlink.com', 'TestLink');
            cwList.add(cw);
        }

        ChatterUtility.mentionTextRecordPostBatch(cwList);
    }

    @IsTest(SeeAllData=true)
    static void CreateSingleChatterMentionPostWithURL() {
        Lead newLead = new Lead(FirstName = 'Test', LastName ='Test', Company='Test');
        insert newLead;

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        // User u = new User(Alias = 'standt', Email='standarduser@acv.com',
        //         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        //         LocaleSidKey='en_US', ProfileId = p.Id,
        //         TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@acv.com');
        User u = TestUtility.createUser();
        insert u;

        ChatterUtility.mentionTextRecordPost(u.id,newLead.id,'testPost', 'testurl.com', 'Test URL Name');
    }
}