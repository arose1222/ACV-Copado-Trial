@isTest
public class IdentityServiceRegistrationTest {
    
    //IdentityHelper Tests
    @isTest
    public static void testGetNextId(){
        Contact c = new Contact( email = 'email@test.com', lastName = 'test', Id__c = '1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        c = [Select Id, Id__c From Contact where Id = :c.Id limit 1];
        Integer i = IdentityHelper.getNextID('Id__c', 'Contact');
        system.assertEquals(c.Id__c, '1', 'Existing Id does not equal 1');
        system.assertEquals(String.valueOf(i), '2', 'New Id does not equal 2');
        system.assertNotEquals(c.Id__c, String.valueOf(i), 'The. Next Id is Equal to the Test Id');
    }
    
    
    @isTest
    public static void testGetNextIdErrorCondition(){
        Contact c = new Contact( email = 'email@test.com', lastName = 'test', Id__c = 'dc__1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        c = [Select Id, Id__c From Contact where Id = :c.Id limit 1];
        Integer i = 0;
        try{
            i = IdentityHelper.getNextID('Id__c', 'Contact');
        }
        catch(Exception e){
            System.assertEquals('Non-Numeric Field Returned', e.getMessage(), 'Bad Error Message');
        }
        
        
    }


    //Registration User Create Tests
    
    @isTest
    public static void testCreateUserGoodCall(){
        contact c = new Contact( email = 'email@test.com', LastName = 'filler', Id__c = '1', Dealership_Contact_Id__c = '1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //use this object to get the JSON we need
        IdentityServiceRegistrationCreateUser.UserCreateRequest data = new IdentityServiceRegistrationCreateUser.UserCreateRequest();
        data.Name = 'Bill Testington';
        data.PromoCode = '4324';
        data.UserName = 'bill@test.com';

        IdentityServiceRegistrationCreateUser.createUser(data);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id from Contact Where Email = 'bill@test.com'].size() == 1, 'Incorrect Number of Contacts Returned');
    }

    @isTest
    public static void testCreateUserGoodCallPhoneAndZipAndExt(){
        contact c = new Contact( email = 'email@test.com', LastName = 'filler', Id__c = '1', Dealership_Contact_Id__c = '1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //use this object to get the JSON we need
        IdentityServiceRegistrationCreateUser.UserCreateRequest data = new IdentityServiceRegistrationCreateUser.UserCreateRequest();
        data.Name = 'Bill Testington';
        data.PromoCode = '4324';
        data.UserName = 'bill@test.com';
        data.phone = '8145744389';
        data.phoneExt = '123';
        data.postalCode = '14033';

        IdentityServiceRegistrationCreateUser.createUser(data);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id from Contact Where Email = 'bill@test.com'].size() == 1, 'Incorrect Number of Contacts Returned');
        System.Assert([Select Id from Contact Where Phone = '8145744389;123'].size() == 1, 'Incorrect Number of Contacts Returned');
        System.Assert([Select Id from Contact Where mailingPostalCode = '14033'].size() == 1, 'Incorrect Number of Contacts Returned');
    }

    @isTest
    public static void testCreateUserGoodCallPhoneAndZip(){
        contact c = new Contact( email = 'email@test.com', LastName = 'filler', Id__c = '1', Dealership_Contact_Id__c = '1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //use this object to get the JSON we need
        IdentityServiceRegistrationCreateUser.UserCreateRequest data = new IdentityServiceRegistrationCreateUser.UserCreateRequest();
        data.Name = 'Bill Testington';
        data.PromoCode = '4324';
        data.UserName = 'bill@test.com';
        data.phone = '8145744389';
        data.postalCode = '14033';

        IdentityServiceRegistrationCreateUser.createUser(data);
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id from Contact Where Email = 'bill@test.com'].size() == 1, 'Incorrect Number of Contacts Returned');
        System.Assert([Select Id from Contact Where Phone = '8145744389'].size() == 1, 'Incorrect Number of Contacts Returned');
        System.Assert([Select Id from Contact Where mailingPostalCode = '14033'].size() == 1, 'Incorrect Number of Contacts Returned');
    }

    @isTest
    public static void testCreateDuplicateUserCall(){
        contact c = new Contact( email = 'email@test.com', LastName = 'filler', Id__c = '1', Dealership_Contact_Id__c = '1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //use this object to get the JSON we need
        IdentityServiceRegistrationCreateUser.UserCreateRequest data = new IdentityServiceRegistrationCreateUser.UserCreateRequest();
        data.Name = 'Bill Testington';
        data.PromoCode = '4324';
        data.UserName = 'bill@test.com';

        IdentityServiceRegistrationCreateUser.createUser(data);

        IdentityServiceRegistrationCreateUser.createUser(data);
        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id from Contact Where Email = 'bill@test.com'].size() == 1, 'Incorrect Number of Contacts Returned');
    }

    @isTest
    public static void testCreateUserInValidPhone(){
      //  contact c = new Contact( email = 'email@test.com', LastName = 'filler', Id__c = '1', Dealership_Contact_Id__c = '1');
      // SalesforceGatewayUserCreateLogic.disableGatewayLogic();
      //  insert c;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //use this object to get the JSON we need
        IdentityServiceRegistrationCreateUser.UserCreateRequest data = new IdentityServiceRegistrationCreateUser.UserCreateRequest();
        data.Name = 'Bill Testington';
        data.PromoCode = '4324';
        data.UserName = 'bill@test.com';
        data.phone='123456789';

        IdentityServiceRegistrationCreateUser.createUser(data);
        System.Assert(RestContext.response.statuscode == 400, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id from Contact Where Email = 'bill@test.com'].size() == 0, 'Incorrect Number of Contacts Returned');
    }

    @isTest
    public static void testCreateUserDMLError(){
        contact c = new Contact( email = 'email@test.com', LastName = 'filler', Id__c = '1', Dealership_Contact_Id__c = '1');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        //use this object to get the JSON we need
        IdentityServiceRegistrationCreateUser.UserCreateRequest data = new IdentityServiceRegistrationCreateUser.UserCreateRequest();
        data.Name = 'Bill Testington';
        data.PromoCode = '4324';
        data.UserName = 'bill.com';

        IdentityServiceRegistrationCreateUser.createUser(data);
        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id from Contact Where Email = 'bill@test.com'].size() == 0, 'Incorrect Number of Contacts Returned');
    }

    //Registration Set User Id
    @isTest
    public static void testSetUserIdNoIdentityId(){
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationSetUserId.userUpdate data = new IdentityServiceRegistrationSetUserId.userUpdate();
        data.userId = '123';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationSetUserId.setUserIdentityId(data);

        System.Assert(RestContext.response.statuscode == 401, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert(String.isBlank([Select Id,Identity_Id__c from Contact Where ID__c = '123'].Identity_Id__c), 'Identity_Id__c is not blank');
    }

    @isTest
    public static void testSetUserIdNoUserId(){
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationSetUserId.userUpdate data = new IdentityServiceRegistrationSetUserId.userUpdate();
        data.identityId = '123';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationSetUserId.setUserIdentityId(data);

        System.Assert(RestContext.response.statuscode == 401, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert(String.isBlank([Select Id,Identity_Id__c from Contact Where ID__c = '123'].Identity_Id__c), 'Identity_Id__c is not blank');
    }

    @isTest
    public static void testSetUserIdNoUserIdFound(){
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationSetUserId.userUpdate data = new IdentityServiceRegistrationSetUserId.userUpdate();
        data.identityId = '123';
        data.userId = '555';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationSetUserId.setUserIdentityId(data);

        System.Assert(RestContext.response.statuscode == 501, 'Bad Status Code: '+RestContext.response.statuscode);
    }

    @isTest
    public static void testSetUserIdDMLError(){
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationSetUserId.userUpdate data = new IdentityServiceRegistrationSetUserId.userUpdate();
        //this string is 256 which is 1 more longer than the field limit we populate with this value
        data.identityId = '1234678954621354675625614684561564564564564151351687484564561564648456456154561321546789786456456489784654561516848978945648756456456415345345341531564164153156456153135153435153135153153151561351231231351531351213543123135153135135131351531351321315153541';
        data.userId = '123';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationSetUserId.setUserIdentityId(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
    }

    @isTest
    public static void testSetUserIdGoodUpdate(){
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationSetUserId.userUpdate data = new IdentityServiceRegistrationSetUserId.userUpdate();
        data.userId = '123';
        data.identityId = '5050';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationSetUserId.setUserIdentityId(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Id,Identity_Id__c from Contact Where ID__c = '123'].Identity_Id__c == '5050', 'Identity_Id__c is incorrect');
    }

    //Registration Create Account
    @isTest
    public static void testCreateAcccount(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        String standardAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer` Name';
        data.Legal_Name = 'New Dealer` Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where Name='New Dealer\' Name'] == 1, 'Backtick not replaced with Apostrophe for Name');
        System.Assert([Select Count() from Account Where dba_trade_name__c='New Dealer\' Name'] == 1, 'Backtick not replaced with Apostrophe for DBA Trade Name');
        System.Assert([Select Count() from Account Where legal_name__c='New Dealer\' Name'] == 1, 'Backtick not replaced with Apostrophe for Legal Name');
        System.Assert([Select Count() from Account] == 1, 'Not Enough Accounts');
        System.Assert([Select Count() from Contact Where AccountID = :c.Id] == 0, 'Contact did not move to the new Account');
        System.Assert([Select Count() from Affiliation__c] == 1, 'Affiliation records was not generated');
        System.Assert([Select Count() from Account where Phone = '8145744389'] == 1, 'improper phone found');
        System.Assert([Select Count() from Account where Phone = '8145744389' AND RecordTypeId = :standardAccountRecordTypeId] == 1, 'Invalid Record Type Created'); //Added as part of IO-1031
    }

    @isTest
    public static void testCreateAcccountPhoneWithExtension(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeID = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.phoneExt = '123';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 1, 'Not Enough Accounts');
        System.Assert([Select Count() from Contact Where AccountID = :c.Id] == 0, 'Contact did not move to the new Account');
        System.Assert([Select Count() from Affiliation__c] == 1, 'Affiliation records was not generated');
        System.Assert([Select Count() from Account where Phone = '8145744389;123'] == 1, 'improper phone found');
    }

    @isTest
    public static void testCreateAcccountContactNotFound(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( RecordTypeID = contactRTID, email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '1234';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountUserAlreadyMoved(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);
        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 1, 'Not Enough Accounts');
        System.Assert([Select Count() from Affiliation__c] == 1, 'Affiliation record was not generated');
    }

    @isTest
    public static void testCreateAcccountBadCell(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeID = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '(721.714.3112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 400, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountBadPhone(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '(814.574.4389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 400, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountBadAccountDML(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = '1234678954621354675625614684561564564564564151351687484564561564648456456154561321546789786456456489784654561516848978945648756456456415345345341531564164153156456153135153435153135153153151561351231231351531351213543123135153135135131351531351321315153541';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountBadAffiliateDML(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( RecordTypeId = contactRTID, email = 'email@test.com', ID__c = '123467895462135467562561468456156456456456415135168748456456156464845645615456132154678978645645648978465456151684897894564875645645641534534534153156416415315645615313515343515313515315315156135123123135153135121354312313515313513513135153135132131515555', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationCreateDealer.DealerCreateRequest data = new IdentityServiceRegistrationCreateDealer.DealerCreateRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123467895462135467562561468456156456456456415135168748456456156464845645615456132154678978645645648978465456151684897894564875645645641534534534153156416415315645615313515343515313515315315156135123123135153135121354312313515313513513135153135132131515555';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationCreateDealer.createDealer(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    //Registration update Account

    @isTest
    public static void testUpdateDealershipGoodRegistration(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', legal_name__c = 'testAccount', Dealer_Type__c = '1');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.legalName= 'test`Account';
        data.dbaName='test`Account';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 1, 'Too many Accounts');
        System.Assert([Select Count() from Account Where dba_trade_name__c='test\'Account'] == 1, 'Backtick not replaced with Apostrophe for DBA Trade Name');
        System.Assert([Select Count() from Account Where legal_name__c='test\'Account'] == 1, 'Backtick not replaced with Apostrophe for Legal Name');
        
    }

    @isTest
    public static void testUpdateDealershipGoodRegistrationDealerTypeChange(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', legal_name__c = 'testAccount', Dealer_Type__c = '1');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.dealership_type = 'independent';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 1, 'Too many Accounts');
        System.Assert([Select Count() from Account Where dealer_type__c ='2'] == 1, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipNoDealerFoundRegistration(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '11122';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 501, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 0, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipBadPhoneRegistration(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '(814.5744389';
        data.state = 'NY';
        data.zip_code = '14033';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 0, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipBadDMLRegistration(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '1234678954621354675625614684561564564564564151351687484564561564648456456154561321546789786456456489784654561516848978945648756456456415345345341531564164153156456153135153435153135153153151561351231231351531351213543123135153135135131351531351321315153541';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 0, 'Too many Accounts');
    }

    //Registration finalize Account

    @isTest
    public static void testFinalizeAccountGood(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
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

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where Status__c ='4'] == 1, 'Too many Accounts');
    }

    @isTest
    public static void testFinalizeAccountBadOrgId(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationFinalDealer.dealerInput data = new IdentityServiceRegistrationFinalDealer.dealerInput();
        data.userId = '6666';
        data.orgId = '1111';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationFinalDealer.finalizeDealer(data);

        System.Assert(RestContext.response.statuscode == 401, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where Status__c ='4'] == 0, 'Too many Accounts');
    }

    @isTest
    public static void testFinalizeAccountNoOrgId(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceRegistrationFinalDealer.dealerInput data = new IdentityServiceRegistrationFinalDealer.dealerInput();
        data.userId = '123';
        data.orgId = '';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceRegistrationFinalDealer.finalizeDealer(data);

        System.Assert(RestContext.response.statuscode == 401, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where Status__c ='4'] == 0, 'Too many Accounts');
    }

    //Identity update Account

    @isTest
    public static void testUpdateDealershipGood(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', legal_name__c = 'testAccount', Dealer_Type__c = '1');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.legalName = 'New Name';
        data.dbaName = 'New Name';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 1, 'Too many Accounts');
        System.Assert([Select Count() from Account Where Name ='New Name'] == 1, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipGoodDealerTypeChange(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', legal_name__c = 'testAccount', Dealer_Type__c = '1');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.legalName = 'New Name';
        data.dbaName = 'New Name';
        data.dealership_type = 'independent';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 1, 'Too many Accounts');
        System.Assert([Select Count() from Account Where Name ='New Name'] == 1, 'Too many Accounts');
        System.Assert([Select Count() from Account Where Dealer_Type__c ='2'] == 1, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipNoDealerFound(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '11122';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.legalName = 'New Name';
        data.dbaName = 'New Name';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 501, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 0, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipBadPhone(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '123456798';
        data.license_number = '45';
        data.phone = '(814.5744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.legalName = 'New Name';
        data.dbaName = 'New Name';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 0, 'Too many Accounts');
    }

    @isTest
    public static void testUpdateDealershipBadDML(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityHelper.dealerRequest data = new IdentityHelper.dealerRequest();
        data.dealer_id = '111';
        data.user_id = '123';
        data.address = '8369 Lower East Hill Rd';
        data.city = 'Colden';
        data.federal_tax_id = '1234678954621354675625614684561564564564564151351687484564561564648456456154561321546789786456456489784654561516848978945648756456456415345345341531564164153156456153135153435153135153153151561351231231351531351213543123135153135135131351531351321315153541';
        data.license_number = '45';
        data.phone = '8145744389';
        data.state = 'NY';
        data.zip_code = '14033';
        data.legalName = 'New Name';
        data.dbaName = 'New Name';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateDealer.updateDealer(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where BillingCity ='Colden'] == 0, 'Too many Accounts');
    }

    //Identity User Update

    @isTest
    public static void testUpdateUserGood(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceUpdateUser.UserUpdateRequest data = new IdentityServiceUpdateUser.UserUpdateRequest();
        data.name = 'Bill Sutton';
        data.phone = '8145744389';
        data.id = '123';
        data.zipCode = '14033';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateUser.updateUser(data);

        System.Assert(RestContext.response.statuscode == 200, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Contact Where MailingPostalCode ='14033'] == 1, 'Inccorect Number Of Contacts');
        System.Assert([Select Count() from Contact Where Name ='Bill Sutton'] == 1, 'Incorrect Number of Contacts returned by Name');
    }

    @isTest
    public static void testUpdateUserGoodPhone(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceUpdateUser.UserUpdateRequest data = new IdentityServiceUpdateUser.UserUpdateRequest();
        data.name = 'Bill Sutton';
        data.phone = '8145744389';
        data.id = '123';
        data.zipCode = '14033';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateUser.updateUser(data);

        System.Assert(RestContext.response.statuscode == 200, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Contact Where MailingPostalCode ='14033'] == 1, 'Inccorect Number Of Contacts');
        System.Assert([Select Count() from Contact Where Phone ='8145744389'] == 1, 'Incorrect Number of Contacts returned by Name');
    }

    @isTest
    public static void testUpdateUserGoodPhoneExt(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceUpdateUser.UserUpdateRequest data = new IdentityServiceUpdateUser.UserUpdateRequest();
        data.name = 'Bill Sutton';
        data.phone = '8145744389';
        data.id = '123';
        data.zipCode = '14033';
        data.phoneExt = '123';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateUser.updateUser(data);

        System.Assert(RestContext.response.statuscode == 200, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Contact Where MailingPostalCode ='14033'] == 1, 'Inccorect Number Of Contacts');
        System.Assert([Select Count() from Contact Where Phone ='8145744389;123'] == 1, 'Incorrect Number of Contacts returned by Name');
    }

    @isTest
    public static void testUpdateUserBadID(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceUpdateUser.UserUpdateRequest data = new IdentityServiceUpdateUser.UserUpdateRequest();
        data.name = 'Bill Sutton';
        data.phone = '8145744389';
        data.id = '133';
        data.zipCode = '14033';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateUser.updateUser(data);

        System.Assert(RestContext.response.statuscode == 501, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Contact Where MailingPostalCode ='14033'] == 0, 'Inccorect Number Of Contacts');
        System.Assert([Select Count() from Contact Where Name ='Bill Sutton'] == 0, 'Incorrect Number of Contacts returned by Name');
    }

    @isTest
    public static void testUpdateUserBadPhone(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceUpdateUser.UserUpdateRequest data = new IdentityServiceUpdateUser.UserUpdateRequest();
        data.name = 'Bill Sutton';
        data.phone = '8!45744389';
        data.id = '123';
        data.zipCode = '14033';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateUser.updateUser(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Contact Where MailingPostalCode ='14033'] == 0, 'Inccorect Number Of Contacts');
        System.Assert([Select Count() from Contact Where Name ='Bill Sutton'] == 0, 'Incorrect Number of Contacts returned by Name');
    }

    @isTest
    public static void testUpdateUserBadData(){
        Account a = new Account(Name = 'TestAccount', phone='1234567890',Dealership_ID__c='111', Active__c = true, legal_name__c = 'testAccount', Dealer_Type__c = '1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact( email = 'email@test.com', AccountID = a.Id, ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceUpdateUser.UserUpdateRequest data = new IdentityServiceUpdateUser.UserUpdateRequest();
        data.name = '12346789546213 54675625614684561564564564564151351687484564561564648456456154561321546789786456456489784654561516848978945648756456456415345345341531564164153156456153135153435153135153153151561351231231351531351213543123135153135135131351531351321315153541';
        data.phone = '8145744389';
        data.id = '123';
        data.zipCode = '14033';


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'PATCH';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceUpdateUser.updateUser(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Contact Where MailingPostalCode ='14033'] == 0, 'Inccorect Number Of Contacts');
        System.Assert([Select Count() from Contact Where Name ='Bill Sutton'] == 0, 'Incorrect Number of Contacts returned by Name');
    }

}