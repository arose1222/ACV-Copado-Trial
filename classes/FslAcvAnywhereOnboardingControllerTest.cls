@isTest
public class FslAcvAnywhereOnboardingControllerTest {

    private class FslAcvAnywhereOnboardingMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {

            HTTPResponse res = new HTTPResponse();
            res.setBody('{"ErrorId": "200", "Message": "Success", "ReturnCode": 0, "ACV_OrgID": "73802", "ASI_Org_Code": "1456", "ASI_Org_ID": "126114", "ASI_Org_Name": "Customer Wow"}');
            res.setStatusCode(200);
            return res;

        }
    }

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account acct = TestUtility.createAccount();
        acct.Active__c = true;
        acct.Dealership_ID__c = '12345';
        insert acct;
    }

    @IsTest
    static void successfulRegistration(){
        Test.setMock(HttpCalloutMock.class, new FslAcvAnywhereOnboardingMock());

        Account acc = [SELECT Id, ACV_Anywhere_Registration_Date__c FROM Account LIMIT 1];
        system.assert(acc.ACV_Anywhere_Registration_Date__c == null);

        test.startTest();
        FslAcvAnywhereOnboardingController.RegistrationResponse res = FslAcvAnywhereOnboardingController.acvAnywhereRegistrationRequest(acc.Id);
        test.stopTest();

        System.assertEquals(200,res.errorId);
        System.assertEquals('Success', res.message);

        Account updatedAccount = [SELECT Id, ACV_Anywhere_Registration_Date__c FROM Account LIMIT 1];
        system.assert(updatedAccount.ACV_Anywhere_Registration_Date__c != null);
    }

    @IsTest
    static void isEligible(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        FslAcvAnywhereOnboardingController.EligibilityResponse res = FslAcvAnywhereOnboardingController.checkEligibility(acc.Id);

        System.assert(res.isAlreadyRegistered == false);
        System.assert(res.isActiveDealer == true);

    }

    @IsTest
    static void isAlreadyRegistered(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.ACV_Anywhere_Registration_Date__c = System.now();
        update acc;

        FslAcvAnywhereOnboardingController.EligibilityResponse res = FslAcvAnywhereOnboardingController.checkEligibility(acc.Id);

        System.assert(res.isAlreadyRegistered == true);
        System.assert(res.isActiveDealer == true);

    }

    @IsTest
    static void noDealerId(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Active__c = false;
        acc.Inactive_Sub_Status__c = '2';
        update acc;

        FslAcvAnywhereOnboardingController.EligibilityResponse res = FslAcvAnywhereOnboardingController.checkEligibility(acc.Id);

        System.assert(res.isAlreadyRegistered == false);
        System.assert(res.isActiveDealer == false);

    }

}