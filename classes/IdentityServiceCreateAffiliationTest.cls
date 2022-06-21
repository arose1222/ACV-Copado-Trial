@isTest
public class IdentityServiceCreateAffiliationTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
    }

    @isTest
    static void testGoodCreate(){
        List<Account> aList = [SELECT Id, dealership_id__c FROM Account];
        List<Contact> cList = [SELECT Id, Id__c FROM Contact];
        IdentityServiceCreateAffiliation.affiliate a = new IdentityServiceCreateAffiliation.affiliate();
        a.dealerId = aList[0].Dealership_ID__c;
        a.userId = cList[0].ID__c;
        a.type = 'rep';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceCreateAffiliation.createAffiliation(a);
        Test.stopTest();
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        String affId = IdentityHelper.createAffiliationId(aList[0].Dealership_ID__c, cList[0].ID__c);
        System.Assert([SELECT Count() FROM Affiliation__c WHERE Id__c = :affId] == 1, 'WRONG Number of Affiliations created');
    }

    @isTest
    static void testNoDealer(){
        List<Account> aList = [SELECT Id, dealership_id__c FROM Account];
        List<Contact> cList = [SELECT Id, Id__c FROM Contact];
        IdentityServiceCreateAffiliation.affiliate a = new IdentityServiceCreateAffiliation.affiliate();
        a.dealerId = '111111111111';
        a.userId = cList[0].ID__c;
        a.type = 'rep';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceCreateAffiliation.createAffiliation(a);
        Test.stopTest();
        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        String affId = cList[0].ID__c+aList[0].Dealership_ID__c;
        System.Assert([SELECT Count() FROM Affiliation__c WHERE Id__c = :affId] == 0, 'WRONG Number of Affiliations created');
    }

    @isTest
    static void testNoContact(){
        List<Account> aList = [SELECT Id, dealership_id__c FROM Account];
        List<Contact> cList = [SELECT Id, Id__c FROM Contact];
        IdentityServiceCreateAffiliation.affiliate a = new IdentityServiceCreateAffiliation.affiliate();
        a.dealerId = aList[0].Dealership_ID__c;
        a.userId = '11111111111111';
        a.type = 'rep';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceCreateAffiliation.createAffiliation(a);
        Test.stopTest();
        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        String affId = cList[0].ID__c+aList[0].Dealership_ID__c;
        System.Assert([SELECT Count() FROM Affiliation__c WHERE Id__c = :affId] == 0, 'WRONG Number of Affiliations created');
    }

    @isTest
    static void testBadType(){
        List<Account> aList = [SELECT Id, dealership_id__c FROM Account];
        List<Contact> cList = [SELECT Id, Id__c FROM Contact];
        IdentityServiceCreateAffiliation.affiliate a = new IdentityServiceCreateAffiliation.affiliate();
        a.dealerId = aList[0].Dealership_ID__c;
        a.userId = cList[0].ID__c;
        a.type = 'Jeff';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceCreateAffiliation.createAffiliation(a);
        Test.stopTest();
        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        String affId = cList[0].ID__c+aList[0].Dealership_ID__c;
        System.Assert([SELECT Count() FROM Affiliation__c WHERE Id__c = :affId] == 0, 'WRONG Number of Affiliations created');
    }

    @isTest
    static void testMultipleRecords(){
        List<Account> aList = [SELECT Id, dealership_id__c FROM Account];
        List<Contact> cList = [SELECT Id, Id__c FROM Contact];
        String affId = IdentityHelper.createAffiliationId(aList[0].Dealership_ID__c, cList[0].ID__c);
        insert new Affiliation__c(type__c = 'admin', Account__c = aList[0].id, Contact__c = cList[0].id, Active__c = true, Start_Date__c = System.Today());
        //insert new Affiliation__c(type__c = 'admin', id__c = affID, Account__c = aList[0].id, Contact__c = cList[0].id, Active__c = true, Start_Date__c = System.Today());
        IdentityServiceCreateAffiliation.affiliate a = new IdentityServiceCreateAffiliation.affiliate();

        a.dealerId = aList[0].Dealership_ID__c;
        a.userId = cList[0].ID__c;
        a.type = 'admin';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceCreateAffiliation.createAffiliation(a);
        Test.stopTest();
        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        
        System.Assert([SELECT Count() FROM Affiliation__c WHERE Id__c = :affId] == 1, 'WRONG Number of Affiliations created');
    }

    @isTest
    static void testForUsersMakingDuplicateRecords(){
        List<Account> aList = [SELECT Id, dealership_id__c FROM Account];
        List<Contact> cList = [SELECT Id, Id__c FROM Contact];
        //String affId = cList[0].ID__c+aList[0].Dealership_ID__c;
        //insert new Affiliation__c(type__c = 'admin', id__c = affID, Account__c = aList[0].id, Contact__c = cList[0].id, Active__c = true, Start_Date__c = System.Today());
        List<User> testUserList = [SELECT ID FROM User WHERE Profile.Name LIKE '%IST%' AND isActive = TRUE];
        IdentityServiceCreateAffiliation.affiliate a = new IdentityServiceCreateAffiliation.affiliate();
        a.dealerId = aList[0].Dealership_ID__c;
        a.userId = cList[0].ID__c;
        a.type = 'admin';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Boolean userError = false;

        Test.startTest();
        IdentityServiceCreateAffiliation.createAffiliation(a);
        System.runAs(testUserList[0]){
            try{
                insert new Affiliation__c(type__c = 'admin', Account__c = aList[0].id, Contact__c = cList[0].id, Active__c = true, Start_Date__c = System.Today());
            }
            catch(Exception e){
                System.debug(e.getMessage());
                userError = true;
            }
        }
        Test.stopTest();
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(userError, 'No Error was thrown for the user when it should have');
        System.Assert([SELECT Count() FROM Affiliation__c] == 1, 'WRONG Number of Affiliations created');
    }
}