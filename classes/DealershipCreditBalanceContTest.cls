/**
 * The test class for DealershipCreditBalanceCont
 * @author James Andre LaCour
 * @since April 26th, 2021
 */
@isTest
public without sharing class DealershipCreditBalanceContTest {
    /**
     * The Account name for the test account created in TestSetup
     */
    private static final String ACCOUNT_NAME = 'Test Account Name';
    /**
     * The Account Balance for the Dealership created in TestSetup
     */
    private static final Integer ACCOUNT_BALANCE = 123;
    /**
     * Creates the data needed for the test in this class
     */
    @TestSetup
    public static void makeData(){
        Account acct = TestUtility.createAccount( ACCOUNT_NAME );
        acct.Organization_Credit_Id__c = '1234';
        insert acct;
    }
    /**
     * Test the balance returned from the endpoint and displayed on the LWC is ACCOUNT_BALANCE
     */
    public static testMethod void getAccountBalanceTest(){
        List<Account> acct = [ SELECT Id, Organization_Credit_Id__c FROM Account WHERE Name = :ACCOUNT_NAME LIMIT 1 ];
        System.assertEquals( 1, acct.size() );
        Test.setMock( HttpCalloutMock.class, new MockCalloutSuccess() );
        Test.startTest();
            Integer accountBalance = DealershipCreditBalanceCont.getAccountBalance( acct[0].Id );
        Test.stopTest();
        System.assertEquals( ACCOUNT_BALANCE, accountBalance );
    }
     /**
     * Data stucture for mock success callout for getting an Account Balance
     * @Author James Andre LaCour
     */
    private class MockCalloutSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            AccountSummary acctSum = new AccountSummary();
            acctSum.api_version = 2;
            acctSum.data = new AccountSummary.Data();
            acctSum.data.accountTotal = ACCOUNT_BALANCE;
            acctSum.data.id = 123;
            acctSum.data.owner = 123;
            acctSum.data.totalTransactions = 1;
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody( JSON.serialize(acctSum) );
            res.setStatus('OK');
            return res;
        }  
    }
}