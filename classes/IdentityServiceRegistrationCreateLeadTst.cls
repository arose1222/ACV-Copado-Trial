@isTest
public class IdentityServiceRegistrationCreateLeadTst {
    
    //Registration Create Lead
    @isTest
    public static void testCreateLead(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
       
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'SK` Company';
        data.DealerShip_DBAName = 'KS` Dealers';
        data.UserName= 'joepel@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'AK';
        data.Zipcode= '14203';
        data.ContactPreference='Text';
        data.ReferralType='Search engines';
        data.ReferralCode='Google';
        data.SMSOptIn= 'true';
        data.Website='www.testsk.com';
        data.CarsInstock= 100;
        data.DealersInterest= 'both';
        data.EulaId='35a6aca0-3b2f-4eec-a202-0669a93379f2';
        data.EulaTosAcceptedDate='2020-01-18 06:23:29';
        data.CellPhone= '9876543210';
        data.LanguagePreference= 'English';
        data.UtmSource= 'anim';
        data.UtmMedium= 'incididunt';
        data.UtmCampaign= 'duis';
        data.GoogleClickId= '1ba02580-db12-4fa2-85d9-cfe7d154379a';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Lead Where FirstName='Joe' and LastName='Pel' and Company='SK\' Company' 
        and Dealership_DBA_Name__c= 'KS\' Dealers' and Email='joepel@test.com' and  Dealer_Type__c='Franchise' and Phone='1234567890;123'
         and LeadSource='Online Registration' and Street='640 Ellicott St #321' and City='Buffalo' and State='AK' and PostalCode='14203'
        and Referral__c='Search engines' and Referral_Code__c='Google' and SMS_Opt_In__c= true and Website='www.testsk.com'
        and How_many_cars_do_you_stock__c= 100 and Interested_in_Buying__c= true and Interested_In_Selling__c= true
        and Language_Preference__c='English' and MobilePhone='9876543210' and utm_source__c= 'anim' and  
        utm_medium__c= 'incididunt' and utm_campaign__c= 'duis' and GCLID__c ='1ba02580-db12-4fa2-85d9-cfe7d154379a'] == 1, 'Incorrect number of leads');
        Datetime dt =Datetime.valueOfGmt(data.EulaTosAcceptedDate);
        System.Assert([Select Count() from Eula_Tos__c Where Accepted_Date__c= :dt and Eula_Id__c='35a6aca0-3b2f-4eec-a202-0669a93379f2'] == 1, 
                        'Incorrect number of Eula/TOS record');
    }


    //Registration Create Lead For BlitzTeam
    @isTest
    public static void testCreateLeadBlitzTeam(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
       
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'SK Company';
        data.DealerShip_DBAName = 'KS Dealers';
        data.UserName= 'joepel@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.ContactPreference='Text';
        data.ReferralType='Search engines';
        data.ReferralCode='blitzteam';
        data.SMSOptIn= 'true';
        data.Website='www.testsk.com';
        data.CarsInstock= 100;
        data.DealersInterest= 'both';
        data.EulaId='35a6aca0-3b2f-4eec-a202-0669a93379f2';
        data.EulaTosAcceptedDate='2020-01-18 06:23:29';
        data.CellPhone= '9876543210';
        data.LanguagePreference= 'English';
        data.UtmSource= 'anim';
        data.UtmMedium= 'incididunt';
        data.UtmCampaign= 'duis';
        data.GoogleClickId= '1ba02580-db12-4fa2-85d9-cfe7d154379a';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        IdentityServiceRegistrationCreateLead.createLead(data);
        Test.stopTest();

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode + RestContext.response);
        System.Assert([Select Count() from Lead Where FirstName='Joe' and LastName='Pel' and Company='SK Company' 
        and Dealership_DBA_Name__c= 'KS Dealers' and Email='joepel@test.com' and  Dealer_Type__c='Franchise' and Phone='1234567890;123'
         and LeadSource='Online Registration' and Street='640 Ellicott St #321' and City='Buffalo' and State='NY' and PostalCode='14203'
        and Referral__c='Search engines' and Referral_Code__c='blitzteam' and SMS_Opt_In__c= true and Website='www.testsk.com'
        and How_many_cars_do_you_stock__c= 100 and Interested_in_Buying__c= true and Interested_In_Selling__c= true
        and Language_Preference__c='English' and MobilePhone='9876543210' and utm_source__c= 'anim' and  
        utm_medium__c= 'incididunt' and utm_campaign__c= 'duis' and GCLID__c ='1ba02580-db12-4fa2-85d9-cfe7d154379a'] == 1, 'Incorrect number of leads');
        System.Assert([Select Count() from Contact Where  FirstName='Joe' and LastName='Pel'] == 1, 'Incorrect number of Contacts');
        System.Assert([Select Count() from Account Where  Name='SK Company'] == 1, 'Incorrect number of Accounts');
        Datetime dt =Datetime.valueOfGmt(data.EulaTosAcceptedDate);
        System.Assert([Select Count() from Eula_Tos__c Where Accepted_Date__c= :dt and Eula_Id__c='35a6aca0-3b2f-4eec-a202-0669a93379f2'] == 1, 
                        'Incorrect number of Eula/TOS record');
    }


    //Registration Create Lead For Market Place Report User
    // @isTest
    // public static void testCreateLeadMarketPlaceReportUser(){
        
    //     String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
       
    //     IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
    //     data.FirstName= 'Joe';
    //     data.LastName= 'Pel';
    //     data.CompanyName= 'SK Company';
    //     data.DealerShip_DBAName = 'KS Dealers';
    //     data.UserName= 'joepel@test.com'; 
    //     data.Dealer_Type= 'Franchise';
    //     data.Phone= '1234567890';
    //     data.PhoneExt= '123';
    //     data.Street= '640 Ellicott St #321';
    //     data.City= 'Buffalo';
    //     data.State= 'AK';
    //     data.Zipcode= '14203';
    //     data.ContactPreference='Text';
    //     data.ReferralType='Search engines';
    //     data.ReferralCode='Google';
    //     data.SMSOptIn= 'true';
    //     data.Website='www.testsk.com';
    //     data.CarsInstock= 100;
    //     data.DealersInterest= 'both';
    //     data.EulaId='35a6aca0-3b2f-4eec-a202-0669a93379f2';
    //     data.EulaTosAcceptedDate='2020-01-18 06:23:29';
    //     data.CellPhone= '9876543210';
    //     data.LanguagePreference= 'English';
    //     data.UtmSource= 'anim';
    //     data.UtmMedium= 'incididunt';
    //     data.UtmCampaign= 'duis';
    //     data.GoogleClickId= '1ba02580-db12-4fa2-85d9-cfe7d154379a';
    //     data.MarketPlaceReportUser='true';
    //     RestRequest req = new RestRequest();
    //     RestResponse res = new RestResponse();
    //     req.httpMethod = 'POST';
    //     RestContext.request = req;
    //     RestContext.response = res;

    //     Test.startTest();
    //     SalesforceGatewayUserCreateLogic.disableGatewayLogic();
    //     IdentityServiceRegistrationCreateLead.createLead(data);
    //     Test.stopTest();

    //     System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode + RestContext.response);
    //     System.Assert([Select Count() from Lead Where FirstName='Joe' and LastName='Pel' and Company='SK Company' 
    //     and Dealership_DBA_Name__c= 'KS Dealers' and Email='joepel@test.com' and  Dealer_Type__c='Franchise' and Phone='1234567890;123'
    //      and LeadSource='Online Registration' and Street='640 Ellicott St #321' and City='Buffalo' and State='AK' and PostalCode='14203'
    //     and Referral__c='Search engines' and Referral_Code__c='Google' and SMS_Opt_In__c= true and Website='www.testsk.com'
    //     and How_many_cars_do_you_stock__c= 100 and Interested_in_Buying__c= true and Interested_In_Selling__c= true
    //     and Language_Preference__c='English' and MobilePhone='9876543210' and utm_source__c= 'anim' and  
    //     utm_medium__c= 'incididunt' and utm_campaign__c= 'duis' and GCLID__c ='1ba02580-db12-4fa2-85d9-cfe7d154379a'] == 1, 'Incorrect number of leads');
    //     System.Assert([Select Count() from Contact Where  FirstName='Joe' and LastName='Pel'] == 1, 'Incorrect number of Contacts');
    //     System.Assert([Select Count() from Account Where  Name='SK Company'] == 1, 'Incorrect number of Accounts');
    //     Datetime dt =Datetime.valueOfGmt(data.EulaTosAcceptedDate);
    //     System.Assert([Select Count() from Eula_Tos__c Where Accepted_Date__c= :dt and Eula_Id__c='35a6aca0-3b2f-4eec-a202-0669a93379f2'] == 1, 
    //                     'Incorrect number of Eula/TOS record');
    // }


    //Registration Create Lead For BlitzTeam - Duplicate Account
    @isTest
    public static void testCreateLeadBlitzTeamDuplicateAccount(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
       
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'SK Company';
        data.DealerShip_DBAName = 'KS Dealers';
        data.UserName= 'joepel@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.ContactPreference='Text';
        data.ReferralType='Search engines';
        data.ReferralCode='blitzteam';
        data.SMSOptIn= 'true';
        data.Website='www.testsk.com';
        data.CarsInstock= 100;
        data.DealersInterest= 'both';
        data.EulaId='35a6aca0-3b2f-4eec-a202-0669a93379f2';
        data.EulaTosAcceptedDate='2020-01-18 06:23:29';
        data.CellPhone= '9876543210';
        data.LanguagePreference= 'English';
        data.UtmSource= 'anim';
        data.UtmMedium= 'incididunt';
        data.UtmCampaign= 'duis';
        data.GoogleClickId= '1ba02580-db12-4fa2-85d9-cfe7d154379a';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Account acc= TestUtility.createAccount(data.CompanyName);
        acc.BillingStreet= data.Street;
        acc.BillingCity= data.City;
        acc.BillingState= data.State;
        acc.BillingPostalCode= data.Zipcode;
        insert acc;

        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        IdentityServiceRegistrationCreateLead.createLead(data);

        //System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode + RestContext.response);
        System.Assert([Select Count() from Lead] == 0, 'Incorrect number of Leads');
        System.Assert([Select Count() from Contact] == 0, 'Incorrect number of Contacts');
        
    }

    //Registration Create Lead - Bad Phone number
    @isTest
    public static void testCreateLeadBadPhone(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Invalid Phone Format';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'SK Company';
        data.UserName= 'joepel@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '12345';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.LanguagePreference= 'English';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }


    //Registration Create Lead - Blank Last Name
    @isTest
    public static void testCreateLeadBadLastName(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='LastName cannot be blank';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= ' ';
        data.CompanyName= 'SK Company';
        data.UserName= 'joepel@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.LanguagePreference= 'English';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }

    //Registration Create Lead - Blank UserName/Email
    @isTest
    public static void testCreateLeadBadUserName(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Username/Email cannot be blank';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'SK Company';
        data.UserName= ' '; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.LanguagePreference= 'English';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }

    //Registration Create Lead - Blank Dealership Legal Name
    @isTest
    public static void testCreateLeadBadDealershipLegalName(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Company name cannot be blank';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= '';
        data.UserName= 'test@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.LanguagePreference= 'English';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }

    //Registration Create Lead - Blank Dealership Legal Name
    @isTest
    public static void testCreateLeadBadDealershipType(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Invalid dealer type';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'Test Company';
        data.UserName= 'test@test.com'; 
        data.Dealer_Type= 'Random Dealer Type';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.LanguagePreference= 'English';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }
    //Registration Create Lead - Duplicate Lead
    @isTest
    public static void testCreateLeadDuplicateLead(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Duplicate lead found';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'Test';
        data.UserName= 'test@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'AK';
        data.Zipcode= '14203';
        data.ContactPreference='Text';
        data.ReferralType='Search engines';
        data.ReferralCode='Google';
        data.SMSOptIn= 'true';
        data.Website='www.testsk.com';
        data.CarsInstock= 100;
        data.DealersInterest= 'both';
        data.LanguagePreference= 'English';
        data.EulaTosAcceptedDate='2020-01-18 06:23:29';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceRegistrationCreateLead.createLead(data);
        Test.stopTest();
        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        
    }

    //Registration Create Lead - Invalid Address
    @isTest
    public static void testCreateLeadBadAddress(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Address is not valid. Please check Street, City, State and Zipcode';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'Test';
        data.UserName= 'test@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '';
        data.LanguagePreference= 'English';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }

    //Registration Create Lead - Invalid language preference
    @isTest
    public static void testCreateLeadBadLanguagePreference(){
        
        String contactRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        String errorMessage='Invalid Language Preference';
        IdentityServiceRegistrationCreateLead.LeadCreateRequest data = new IdentityServiceRegistrationCreateLead.LeadCreateRequest();
        data.FirstName= 'Joe';
        data.LastName= 'Pel';
        data.CompanyName= 'SK Company';
        data.UserName= 'joepel@test.com'; 
        data.Dealer_Type= 'Franchise';
        data.Phone= '1234567890';
        data.PhoneExt= '123';
        data.Street= '640 Ellicott St #321';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zipcode= '14203';
        data.ContactPreference='Text';
        data.ReferralType='Search engines';
        data.ReferralCode='Google';
        data.SMSOptIn= 'true';
        data.Website='www.testsk.com';
        data.CarsInstock= 100;
        data.DealersInterest= 'both';
        data.EulaId='35a6aca0-3b2f-4eec-a202-0669a93379f2';
        data.EulaTosAcceptedDate='2020-01-18 06:23:29';
        data.CellPhone= '9876543210';
        data.LanguagePreference= '';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateLead.createLead(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.assert(RestContext.response.responseBody.toString().contains( errorMessage ), 'The expected error was not provided (Expected: ' + errorMessage + '). The provided error is as followed: ' + RestContext.response.responseBody.toString() );
        System.Assert([Select Count() from Lead Where FirstName='Joe'] == 0, 'Incorrect number of leads by firstname');

    }

}