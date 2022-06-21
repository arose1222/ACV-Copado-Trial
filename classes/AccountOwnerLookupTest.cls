@isTest
public class AccountOwnerLookupTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount('Bill Test');
        insert a;
        Contact c = TestUtility.createContact(a);
        c.phone = '5555555555';
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c ac = TestUtility.createAuction(a,c,v);
        insert ac;
    }

    @isTest
    static void testPhoneSearch(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','5555555555');
        req.params.put('type', 'phoneSearch'); 
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'OK','Non-OK Status returned');
    }

    @isTest
    static void testAuctionSellerSearch(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','123456');
        req.params.put('type', 'auctionsearch');
        req.params.put('callerType','seller');
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'OK','Non-OK Status returned');
    }

    @isTest
    static void testAuctionBuyerSearch(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','123456');
        req.params.put('type', 'auctionsearch');
        req.params.put('callerType','Buyer');
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'OK','Non-OK Status returned');
    }

    @isTest
    static void testPhoneSearchNotFound(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','5555555455');
        req.params.put('type', 'phoneSearch');
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'Account Not Found','Improper Error Message Returned');
    }

    @isTest
    static void testAuctionSearchNotFound(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','126');
        req.params.put('type', 'auctionsearch');
        req.params.put('callerType','Buyer');
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'Account Not Found','Improper Error Message Returned');
    }

    @isTest
    static void testBadType(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','5555555555');
        req.params.put('type', 'badType'); 
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'Incorrect Request Type Provided','Improper Error Message Returned');
    }

    @isTest
    static void testBadCallerType(){
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        RestRequest req = new RestRequest();
        req.addHeader('Content-Type', 'application/json');
        req.httpMethod = 'Get';
        req.requestURI = '/services/apexrest/AccountOwnerLookup';
        req.params.put('input','123456');
        req.params.put('type', 'auctionsearch');
        req.params.put('callerType','er');
        RestContext.request = req;
        RestContext.response = res;
        AccountOwnerLookup.returnStructure rs = AccountOwnerLookup.getAccountOwner();
        system.assert(rs.Status == 'Account Not Found','Improper Error Message Returned');
    }
}