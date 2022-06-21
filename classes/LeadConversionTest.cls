@isTest
public class LeadConversionTest {
 
    static String leadRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
    
    @TestSetup
    static void makeData(){
        Lead leadRec = TestUtility.createLead();
        leadRec.EIN_Number__c= '456123';
        leadRec.RecordTypeId = leadRTID;
        leadRec.Dealer_Type__c='Franchise';
        leadRec.Street = '1318 Plumgrove Rd';
        leadRec.City = 'Schaumburg';
        leadRec.State = 'IL';
        leadRec.PostalCode = '60173';

        insert leadRec;
    }

    
    public static LeadConversion.AddressWrapper getAddress(){
        List<lead> leadRecLst = [SELECT Id FROM Lead WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];
        return LeadConversion.getLeadAddress(leadRecLst[0].Id);
    }


    @isTest
    public static void ConvertLeadForDuplicateContact(){

        List<lead> leadRecLst = [SELECT Id, Email FROM LEad WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];
        
        Account acct1 = TestUtility.createAccount('Account 1');
        insert acct1;

        Contact ctct1 = TestUtility.createContact(acct1);
        ctct1.Email= leadRecLst[0].Email;
        insert ctct1;

        String expectedErrorMessage='Duplicate ACV User found. Lead conversion process aborted.';
        String actualErrorMessage;
        Test.startTest();
        LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecLst[0].Id, LeadConversionTest.getAddress());
        Test.stopTest();
        System.assert(expectedErrorMessage == rw.message, 'Different Exception is thrown. Actual:'+rw.message);
        System.assert(true == rw.hasError, 'Did not result in the error as expected.');
    }
     
    @isTest
    public static void ConvertLeadForDuplicateAccount(){

        List<lead> leadRecLst = [SELECT Id, Company, Street, City, State, PostalCode FROM Lead
                                 WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];

        
        Account acct1 = TestUtility.createAccount('Account 1');
        acct1.Legal_Name__c= leadRecLst[0].Company;
        acct1.BillingStreet= leadRecLst[0].Street;
        acct1.BillingCity= leadRecLst[0].City;
        acct1.BillingState= leadRecLst[0].State;
        acct1.BillingPostalCode= leadRecLst[0].PostalCode;
        insert acct1;

        String expectedErrorMessage='Dealer already exists. Lead conversion process aborted.';
        String actualErrorMessage;
        Test.startTest();
        LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecLst[0].Id, LeadConversionTest.getAddress());
        Test.stopTest();
        System.assert(expectedErrorMessage == rw.message, 'Different Exception is thrown. Actual:'+rw.message);
        System.assert(true == rw.hasError, 'Did not result in the error as expected.');

    }
   
    @isTest
    public static void ConvertLead(){

        List<lead> leadRecLst = [SELECT Id, Email, Company FROM LEad WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];
        Eula_Tos__C eulaTosRec = new Eula_Tos__c(Lead__c = leadRecLst[0].Id);
        insert eulaTosRec;

        insert TestUtility.createAccount();
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;

       /*  TestingUtility.SingleRequestMock eulaMockRes = new TestingUtility.SingleRequestMock(200,'OK','{"success": true}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user/welcome',eulaMockRes); */

        Test.startTest();
            SalesforceGatewayUserCreateLogic.disableGatewayLogic();
            LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecLst[0].Id, LeadConversionTest.getAddress());
        Test.stopTest();

        System.assert('Lead Conversion successful.' == rw.message, 'Resulted in an error. Error Message:'+ rw.message);
        System.assert(false == rw.hasError, 'Resulted in an error.');

        List<Account> accList = [SELECT Id FROM Account WHERE Legal_Name__c =:leadRecLst[0].Company];
        System.assert(accList.size() == 1, 'Account is not generated');

        List<Contact> conList = [SELECT Id FROM Contact WHERE Email =:leadRecLst[0].Email];
        System.assert(conList.size() == 1, 'Contact is not generated');

        System.assert([SELECT COUNT() FROM Affiliation__c WHERE type__c = 'admin' AND Active__c = TRUE AND primary_contact__c= TRUE] == 1, 'Affiliation is not generated');
        System.assert([SELECT COUNT() from AssociatedLocation WHERE ParentRecordId = :accList[0].Id AND ActiveTo = null] == 1, 'Associated Location is not generated');
        System.assert([SELECT COUNT() FROM Eula_Tos__c WHERE Contact__c =: conList[0].Id] == 1, 'Contact is not updated on Eula Tos Object');
    }

    
    @isTest
    public static void ConvertLeadBlitzTeam(){

        List<lead> leadRecLst = [SELECT Id, Email, Company, Referral_Code__c FROM LEad WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];
        leadRecLst[0].Referral_Code__c='blitzteam';
        leadRecLst[0].Market_Place_Report_User__c= false;
        update leadRecLst;

        Eula_Tos__C eulaTosRec = new Eula_Tos__c(Lead__c = leadRecLst[0].Id);
        insert eulaTosRec;

        insert TestUtility.createAccount();
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;

        Test.startTest();
            SalesforceGatewayUserCreateLogic.disableGatewayLogic();
            LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecLst[0].Id, LeadConversionTest.getAddress());
        Test.stopTest();

        System.assert('Lead Conversion successful.' == rw.message, 'Resulted in an error. Error Message:'+ rw.message);
        System.assert(false == rw.hasError, 'Resulted in an error.');

        List<Account> accList = [SELECT Id FROM Account WHERE Legal_Name__c =:leadRecLst[0].Company and Active__c=true]; // Account should be active.
        System.assert(accList.size() == 1, 'Account is not generated');

        List<Contact> conList = [SELECT Id FROM Contact WHERE Email =:leadRecLst[0].Email];
        System.assert(conList.size() == 1, 'Contact is not generated');

        System.assert([SELECT COUNT() FROM Affiliation__c WHERE type__c = 'admin' AND Active__c = TRUE AND primary_contact__c= TRUE] == 1, 'Affiliation is not generated');
        System.assert([SELECT COUNT() from AssociatedLocation WHERE ParentRecordId = :accList[0].Id AND ActiveTo = null] == 1, 'Associated Location is not generated');
        System.assert([SELECT COUNT() FROM Eula_Tos__c WHERE Contact__c =: conList[0].Id] == 1, 'Contact is not updated on Eula Tos Object');
    }


    @isTest
    public static void ConvertLeadMarketPlaceReportUser(){

        List<lead> leadRecLst = [SELECT Id, Email, Company, Referral_Code__c FROM LEad WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];
        leadRecLst[0].Market_Place_Report_User__c= true;
        update leadRecLst;

        Eula_Tos__C eulaTosRec = new Eula_Tos__c(Lead__c = leadRecLst[0].Id);
        insert eulaTosRec;

        insert TestUtility.createAccount();
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;

        Test.startTest();
            SalesforceGatewayUserCreateLogic.disableGatewayLogic();
            LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecLst[0].Id, LeadConversionTest.getAddress());
        Test.stopTest();

        System.assert('Lead Conversion successful.' == rw.message, 'Resulted in an error. Error Message:'+ rw.message);
        System.assert(false == rw.hasError, 'Resulted in an error.');

        List<Account> accList = [SELECT Id FROM Account WHERE Legal_Name__c =:leadRecLst[0].Company]; // Account should be active.
        System.assert(accList.size() == 1, 'Account is not generated');

        List<Contact> conList = [SELECT Id FROM Contact WHERE Email =:leadRecLst[0].Email and Role__c= 'readonly'];
        System.assert(conList.size() == 1, 'Contact is not generated');

        System.assert([SELECT COUNT() FROM Affiliation__c WHERE type__c = 'admin' AND Active__c = TRUE AND primary_contact__c= TRUE] == 1, 'Affiliation is not generated');
        System.assert([SELECT COUNT() from AssociatedLocation WHERE ParentRecordId = :accList[0].Id AND ActiveTo = null] == 1, 'Associated Location is not generated');
        System.assert([SELECT COUNT() FROM Eula_Tos__c WHERE Contact__c =: conList[0].Id] == 1, 'Contact is not updated on Eula Tos Object');
    }

    // This unit test validates the scenario when system finds a duplicate using the matching rules
    @isTest
    public static void ConvertLeadForDuplicateAccountMatchingRules(){

       
        Test.startTest();
        List<lead> leadRecLst = [SELECT Id, Company, Street, City, State, PostalCode FROM Lead
        WHERE EIN_Number__c= '456123' AND  State = 'IL' LIMIT 1];


        Account acct1 = TestUtility.createAccount(leadRecLst[0].Company);
        acct1.Legal_Name__c= leadRecLst[0].Company;
        acct1.BillingStreet= '1318 Plumgrove Road';
        acct1.BillingCity= leadRecLst[0].City;
        acct1.BillingState= leadRecLst[0].State;
        acct1.BillingPostalCode= leadRecLst[0].PostalCode;
        insert acct1;

        String expectedErrorMessage='Lead Conversion Failed. There is already duplicate accounts matching this record.';
        String actualErrorMessage;
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecLst[0].Id, LeadConversionTest.getAddress());
        Test.stopTest();
        System.assert(expectedErrorMessage == rw.message, 'Different Exception is thrown. Actual:'+rw.message);
        System.assert(true == rw.hasError, 'Did not result in the error as expected.');

    }


}