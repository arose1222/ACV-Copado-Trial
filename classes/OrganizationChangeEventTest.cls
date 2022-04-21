@istest
public class OrganizationChangeEventTest {
    @TestSetup
    static void makeData(){

        Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        List<Account> accountList = new List<Account>();
        Account a = new Account(Dealership_ID__c = '4568777', phone='1234567890', Name='sellerr',legal_Name__c='sellerr', active__c = false, dealer_type__c='2',BillingStreet='159 main st', BillingState='NY', BillingCity='Rochester', BillingPostalCode='15555', BillingCountry='US', RecordTypeId = orgRecordTypeId);
        accountList.add(a);
        Account a1 = new Account(Dealership_ID__c = '456', phone='1234567890',Name='sellerName',legal_Name__c='sellerName', active__c = false,  Inactive_Sub_Status__c = '1', dealer_type__c='2',BillingStreet='159 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='10245', BillingCountry='US', RecordTypeId = orgRecordTypeId);
        accountList.add(a1);

        Account a3 = TestUtility.createAccount('ParkingAccount');
        a3.OwnerId = UserInfo.getUserId();
        a3.Dealership_Id__c = '1';
        accountList.add(a3);

        insert accountList;


    }
    @istest
    static void UpdateOrgActivationEventTest()  {
        //Update Active flag
        Account newOrg = new Account();
        newOrg = [SELECT ID, Dealership_ID__c, Active__c FROM Account Where Dealership_ID__c = '4568777'];
        Contact c = TestUtility.createContact(newOrg);
        insert c;
        Affiliation__c aff = TestUtility.createAffiliation( newOrg, c );
        insert aff;
        newOrg.Active__c = true;
        update newOrg;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newOrg.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'organization-activated'
        System.assert(integrationTest.Request_Message__c.contains('organization-activated'), 'Changing Active flag does not generate organization-activated Platform Event');
        delete integrationTest;

    }
    @isTest
    public static void testFinalizeAccountGood(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='159 main st', BillingState='NY', BillingCity='Rochester', BillingPostalCode='15555', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationFinalDealer.dealerInput data = new IdentityServiceRegistrationFinalDealer.dealerInput();
        data.userId = '123';
        data.orgId = '111';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationFinalDealer.finalizeDealer(data);

        // System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        // System.Assert([Select Count() from Account Where Status__c ='4'] == 1, 'Too many Accounts');

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:a.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'Registration-complete'
        System.assert(integrationTest.Request_Message__c.contains('registration-complete'), 'Completing activation and finalizing Org does not fire Reg Complete event');
        delete integrationTest;
    }
}