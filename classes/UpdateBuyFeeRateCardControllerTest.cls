/** 
 * Test class for UpdateBuyFeeRateCardController class
 **/
@isTest
public class UpdateBuyFeeRateCardControllerTest {
    
    @TestSetup
    static void makeData(){
        // Create 2 rate cards. one published and one draft
        List<Rate_Card__c> ratecards= new List<Rate_Card__c>();
        Rate_Card__c rc = TestUtility.createRateCard();
        rc.Approval_Status__c = 'Published';
        Rate_Card__c rc1 = TestUtility.createRateCard();
        ratecards.add(rc);
        ratecards.add(rc1);
        insert ratecards;

        // Create ratecard fees for the above created rate cards
        List<Rate_Card_Fee__c> ratecardfees= new List<Rate_Card_Fee__c>();
        Rate_Card_Fee__c rcf = TestUtility.createRateCardFee(rc, 1, 100);
        Rate_Card_Fee__c rcf1 = TestUtility.createRateCardFee(rc1, 1, 100);
        ratecardfees.add(rcf);
        ratecardfees.add(rcf1);
        insert ratecardfees;

        // Create 2 users. 1 user with ACV user Id and another without ACV user id. User with ACV User Id can only update the rate card
        User testUser = TestUtility.createUser();
        testUser.email = 'testingonetwothree@test.test';
        User testUser2 = TestUtility.createUser();
        testUser2.Email = 'noPermissionUser@test.test';
        insert new List<User>{testUser, testUser2};

        // Creating ACV User record for one of the user created above
        Account acct = TestUtility.createAccount();
        insert acct;
        Contact c = TestUtility.createContact(acct);
        c.Email = 'testingonetwothree@test.test';
        c.Id__c = '1234';
        insert c;
 
    }

    /** 
     * Test to check if only published rate cards are shown in the LWC
     **/  
    @isTest
    public static void GetRateCardsTest(){
        Test.startTest();
        List<Rate_Card__c> rateCards= UpdateBuyFeeRateCardController.GetRateCards();
        Test.stopTest();
        System.assert(rateCards.size()==1, 'Incorrect Number of RateCards');
    }
    

    /** 
     * Test to check that an error is thrown when the running user does not have a ACV User record.
     **/
    public static testMethod void UpdateBuyFeeRateCardBadACVUserId(){
        
        Test.setMock( HttpCalloutMock.class, new MockCallOutSuccess() );
       
        Test.startTest();
        User testUser = [ SELECT Id FROM User WHERE Email = 'noPermissionUser@test.test' LIMIT 1 ];
        List<Account> accList= [Select Id From Account LIMIT 1];
        
        // Update rate card to have a ACV User Id
        List<Rate_Card__c> ratecards= [Select Id From Rate_Card__c Where Approval_Status__c='Published'];
        ratecards[0].ACV_Id__c= '1';
        update ratecards;
       
        // Update the buy fee rate card
        String jsonReponse;
        System.runAs(testUser){
            jsonReponse=  UpdateBuyFeeRateCardController.UpdateBuyFeeRateCard(accList[0].Id, ratecards[0].Id);
        }
        Test.stopTest();
        Type resultType = Type.forName('UpdateBuyFeeRateCardController.ReturnWrapper');
        UpdateBuyFeeRateCardController.ReturnWrapper rw= (UpdateBuyFeeRateCardController.ReturnWrapper)JSON.deserialize(jsonReponse, resultType);
        System.assert(rw.hasError== true, 'Incorrect error flag');
        System.assert(rw.message== 'ACV User Id is missing for the User. Please contact a System Admin', 'Incorrect error message');
    }

    /** 
     * Test to check that an error is thrown when account does not have valid(numeric) dealership Id
     **/
    public static testMethod void UpdateBuyFeeRateCardBadDealershipId(){
        
        Test.setMock( HttpCalloutMock.class, new MockCallOutSuccess() );
        
        Test.startTest();
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        List<Account> accList= [Select Id From Account LIMIT 1]; // This account has a non-numeric(invalid) dealership Id
        
        // Update rate card to have a ACV Id
        List<Rate_Card__c> ratecards= [Select Id From Rate_Card__c Where Approval_Status__c='Published'];
        ratecards[0].ACV_Id__c= '1';
        update ratecards;

        // Update the buy fee rate card
        String jsonReponse;
        System.runAs(testUser){
            jsonReponse=  UpdateBuyFeeRateCardController.UpdateBuyFeeRateCard(accList[0].Id, ratecards[0].Id);
        }
        Test.stopTest();

        Type resultType = Type.forName('UpdateBuyFeeRateCardController.ReturnWrapper');
        UpdateBuyFeeRateCardController.ReturnWrapper rw= (UpdateBuyFeeRateCardController.ReturnWrapper)JSON.deserialize(jsonReponse, resultType);
        System.assert(rw.hasError== true, 'Incorrect error flag');
        System.assert(rw.message== 'Dealership ID missing on the Account Record. Please contact a System Admin', 'Incorrect error message');
    }
    

    /** 
     * Test to check that an error is thrown when rate card does not have a ACV Id
     **/
    public static testMethod void UpdateBuyFeeRateCardBadRateCard(){
        
        Test.setMock( HttpCalloutMock.class, new MockCallOutSuccess() );
        Test.startTest();

        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        
        // Update the account to have a valid dealer ship Id
        List<Account> accList= [Select Id From Account LIMIT 1];
        accList[0].Dealership_ID__c= '12';
        update accList;

        // The rate card does not have ACV Id
        List<Rate_Card__c> ratecards= [SELECT Id FROM Rate_Card__c where Approval_Status__c = 'Published' LIMIT 1];
        
        // Update the buy fee rate card
        String jsonReponse;
        System.runAs(testUser){
            jsonReponse=  UpdateBuyFeeRateCardController.UpdateBuyFeeRateCard(accList[0].Id, ratecards[0].Id);
        }
        Test.stopTest();
        Type resultType = Type.forName('UpdateBuyFeeRateCardController.ReturnWrapper');
        UpdateBuyFeeRateCardController.ReturnWrapper rw= (UpdateBuyFeeRateCardController.ReturnWrapper)JSON.deserialize(jsonReponse, resultType);
        System.assert(rw.hasError== true, 'Incorrect error flag');
        System.assert(rw.message== 'Rate Card Does not have ACV ID assigned. Please contact a System Admin', 'Incorrect error message');
    } 
   
    /** 
     * Successful test to update the rate card
     **/    
    public static testMethod void UpdateBuyFeeRateCardSuccess(){
        
        Test.setMock( HttpCalloutMock.class, new MockCallOutSuccess() );
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
        
        // Update the account to have a valid dealer ship Id 
        List<Account> accList= [Select Id From Account LIMIT 1];
        accList[0].Dealership_ID__c= '12';
        update accList;

        // Update rate card to have a ACV Id
        List<Rate_Card__c> ratecards= [SELECT Id FROM Rate_Card__c where Approval_Status__c = 'Published' LIMIT 1];
        ratecards[0].ACV_Id__c= '1';
        update ratecards;
        
        // Update the buy fee rate card
        Test.startTest();
        String jsonReponse;
        System.runAs(testUser){
            jsonReponse=  UpdateBuyFeeRateCardController.UpdateBuyFeeRateCard(accList[0].Id, ratecards[0].Id);
        }
        Test.stopTest();
        Type resultType = Type.forName('UpdateBuyFeeRateCardController.ReturnWrapper');
        UpdateBuyFeeRateCardController.ReturnWrapper rw= (UpdateBuyFeeRateCardController.ReturnWrapper)JSON.deserialize(jsonReponse, resultType);
        System.assert(rw.hasError== false, 'Incorrect error flag');
        System.assert(rw.message== 'Successfully update the Rate Card', 'Incorrect error message');
        System.Assert([Select Count() from Account Where Buy_Fee_Rate_Card__c= :ratecards[0].Id] == 1, 'Buy Fee Ratecard is not updated');
    }
  
 
    /** 
     * Unsuccessful (callout) test to update the rate card
     **/  
    public static testMethod void UpdateBuyFeeRateCardError(){
        
        Test.setMock( HttpCalloutMock.class, new MockCallOutError()); // Mock class with unsuccessful response
        
        User testUser = [ SELECT Id FROM User WHERE Email = 'testingonetwothree@test.test' LIMIT 1 ];
       
        // Update the account to have a valid dealer ship Id 
        List<Account> accList= [Select Id From Account LIMIT 1];
        accList[0].Dealership_ID__c= '12';
        update accList;
        
        // Update rate card to have a ACV Id
        List<Rate_Card__c> ratecards= [SELECT Id FROM Rate_Card__c where Approval_Status__c = 'Published' LIMIT 1];
        ratecards[0].ACV_Id__c= '1';
        update ratecards;

        // Update the buy fee rate card
        Test.startTest();
        String jsonReponse;
        System.runAs(testUser){
            jsonReponse=  UpdateBuyFeeRateCardController.UpdateBuyFeeRateCard(accList[0].Id, ratecards[0].Id);
        }
        Test.stopTest();
        Type resultType = Type.forName('UpdateBuyFeeRateCardController.ReturnWrapper');
        UpdateBuyFeeRateCardController.ReturnWrapper rw= (UpdateBuyFeeRateCardController.ReturnWrapper)JSON.deserialize(jsonReponse, resultType);
        System.assert(rw.hasError== true, 'Incorrect error flag');
        System.assert(rw.message== 'Attempt to update the buy fee rate card failed with an exception in the gateway. Please contact a system administrator.', 'Incorrect error message');
        System.Assert([Select Count() from Account Where Buy_Fee_Rate_Card__c= :ratecards[0].Id] == 0, 'Buy Fee Ratecard is not updated');
    }
    
    /** 
     * Mock class to return successful (callout) response
     **/ 
    private class MockCallOutSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            if( req.getEndpoint().contains(UpdateBuyFeeRateCardController.PUBLISH_RATE_CARD_ENDPOINT_SUFFIX) ){
                res.setStatusCode(200);
                res.setStatus('OK');
            }else if( req.getEndpoint().contains('Splunk') ){
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            return res;
        }  
    }
 
    /** 
     * Mock class to return unsuccessful (callout) response
     **/ 
    private class MockCallOutError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            if( req.getEndpoint().contains(UpdateBuyFeeRateCardController.PUBLISH_RATE_CARD_ENDPOINT_SUFFIX) ){
                res.setStatusCode(403);
                res.setStatus('Error');
            }else if( req.getEndpoint().contains('Splunk') ){
                res.setStatusCode(200);
                res.setStatus('OK');
            }
            return res;
        }  
    }
   
}