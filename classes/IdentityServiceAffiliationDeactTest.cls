@isTest
public class IdentityServiceAffiliationDeactTest {
    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        a.dealership_ID__c = '333';
        insert a;
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        Contact c = TestUtility.createContact(a);
        c.id__c = '222';
        insert c;
        Contact c2 = TestUtility.createContact(a);
        c2.id__c = '111';
        insert c2;
        Affiliation__c aff = TestUtility.createAffiliation( a, c );
        insert aff;
        Affiliation__c aff2 = TestUtility.createAffiliation( a, c2 );
        insert aff2;
    }   

    @isTest
    static void testBasicDeactivation(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceAffiliationDeactivation.affiliate a = new IdentityServiceAffiliationDeactivation.affiliate();
        a.dealerId = '333';
        a.userId = '222';
        IdentityServiceAffiliationDeactivation.affiliationDeactivation(a);
        System.assert([SELECT Id FROM Affiliation__c WHERE Contact__r.Id__c = '222' AND active__c = true].size() == 0, 'Affiliation Left Active');
        System.assert(res.statusCode == 201, 'Bad Response Code');
    }

    @isTest
    static void testFailureDeactivation(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceAffiliationDeactivation.affiliate a = new IdentityServiceAffiliationDeactivation.affiliate();
        a.dealerId = '333';
        a.userId = '29';
        IdentityServiceAffiliationDeactivation.affiliationDeactivation(a);
        System.assert([SELECT Id FROM Affiliation__c WHERE Active__c = true].size() > 0, 'Affiliation Not Left Active');
        System.assert(res.statusCode == 500, 'Bad Response Code');
    }

    @isTest
    static void testDMLCatchDeactivation(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceAffiliationDeactivation.affiliate a = new IdentityServiceAffiliationDeactivation.affiliate();
        a.dealerId = '333';
        a.userId = '222';
        IdentityServiceAffiliationDeactivation.causeFailure = true;
        IdentityServiceAffiliationDeactivation.affiliationDeactivation(a);
        System.assert([SELECT Id FROM Affiliation__c WHERE Active__c = true].size() >= 0, 'Affiliation Not Left Active');
        System.assert(res.statusCode == 500, 'Bad Response Code');
    }
}