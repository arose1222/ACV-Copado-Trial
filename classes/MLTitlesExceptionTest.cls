@isTest
public class MLTitlesExceptionTest {
    @TestSetup
    static void makeData(){
        // Create 2 users:   testuser1 (Seller) and testuser2 (Buyer)
        String uniqueUserName1 = 'testuser1' + DateTime.now().getTime() + '@testorg.com';
        String uniqueUserName2 = 'testuser2' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Inside Sales - Managers'];
        List<User> newUsers = new List<User>();
        newUsers.add(new User(UserName = uniqueUserName1, LastName = 'test1', Alias = 'test1', Email = 'testuser1@testorg.com', ProfileId = p.Id, CommunityNickname = 'tEsT1', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/New_York'));
        newUsers.add(new User(UserName = uniqueUserName2, LastName = 'test2', Alias = 'test2', Email = 'testuser2@testorg.com', ProfileId = p.Id, CommunityNickname = 'tEsT2', EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/New_York'));
        insert newUsers;
    }
    static testMethod void test_doInvoice(){
        MLExceptionWrapper ml = new MLExceptionWrapper();
        
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        RestContext.response = res;
        RestContext.request = req;
        RestContext.request.requestBody = Blob.valueof(JSON.serialize(ml));
        MLTitlesExceptionAPI.createException();
        ml.Clerk = new MLExceptionWrapper.Clerk();
        ml.Clerk.Email = 'test@test.com';
        RestContext.request.requestBody = Blob.valueof(JSON.serialize(ml));
        MLTitlesExceptionAPI.createException();
        ml.Clerk.Email = 'testuser1@testorg.com';
        ml.Scanner = new MLExceptionWrapper.Scanner();
        ml.Scanner.ModelName = 'lkwer2';
        ml.Email = new MLExceptionWrapper.Email();
        ml.Email.Subject = 'werd';
        ml.Title = new MLExceptionWrapper.Title();
        RestContext.request.requestBody = Blob.valueof(JSON.serialize(ml));
        MLTitlesExceptionAPI.createException();
        // '{"Clerk":{"Email":"ssingh@acvauctions.com","FullName":"Sukh Singh","LoginId":"1018"},"Email":{"Subject":"Send data from MFP13471483 11/26/2019 16:17","Body":"Scanned from MFP13471483\nDate:11/26/2019 16:17\nPages:5\nResolution:300x300 DPI\n----------------------------------------","TimeStamp":"2019-11-26T16:17:00"},"Title":{"State":"NY","AuctionId":"","Vin":"11111111111111111","IsConfident":false},"Scanner":{"ModelName":"MFP13471483"}}')
    }
}