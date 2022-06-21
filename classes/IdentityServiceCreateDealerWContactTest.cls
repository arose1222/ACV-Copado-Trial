@isTest
public class IdentityServiceCreateDealerWContactTest {
    
    @isTest
    public static void testCreateAcccountWithContact(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        String standardAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer` Name';
        data.Legal_Name = 'New Dealer` Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.phoneExt='123';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);
        List<Account> accCreated=[select  Id, Name from Account];
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account Where Name='New Dealer\' Name' and dba_trade_name__c='New Dealer\' Name' and 
                         legal_name__c='New Dealer\' Name' and Phone = '8145744389;123' and RecordTypeId = :standardAccountRecordTypeId  
                         and Dealer_Type__c= '1'and BillingStreet= '123 Main St' and BillingCity='Buffalo'
                         and BillingState= 'NY' and BillingPostalCode='01515' and Tax_Id__c= '123123123' and 
                         License_Number__c= '456456456' ] == 1, 'Incorrect number of Accounts');
        System.Assert([Select Count() from Contact Where AccountID = :accCreated[0].Id] == 1, 'Contact did not move to the new Account');
        System.Assert([Select Count() from Affiliation__c] == 1, 'Affiliation records was not generated');
    }

    @isTest
    public static void testCreateAcccountWithInvalidContact(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( RecordTypeID = contactRTID, email = 'email@test.com', ID__c = '123', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '1234';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateDuplicateAcccountWithContact(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);
        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);

        System.Assert(RestContext.response.statuscode == 409, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 1, 'Not Enough Accounts');
        System.Assert([Select Count() from Affiliation__c] == 1, 'Affiliation record was not generated');
    }

    @isTest
    public static void testCreateAcccountWithContactBadCell(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeID = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest  data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '(721.714.3112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);

        System.Assert(RestContext.response.statuscode == 400, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountWithContactBadPhone(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '(814.574.4389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);

        System.Assert(RestContext.response.statuscode == 400, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountWithContactBadAccDML(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = '1234678954621354675625614684561564564564564151351687484564561564648456456154561321546789786456456489784654561516848978945648756456456415345345341531564164153156456153135153435153135153153151561351231231351531351213543123135153135135131351531351321315153541';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateAcccountWithContactBadAffiliateDML(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        Contact c = new Contact( RecordTypeId = contactRTID, email = 'email@test.com', ID__c = '123467895462135467562561468456156456456456415135168748456456156464845645615456132154678978645645648978465456151684897894564875645645641534534534153156416415315645615313515343515313515315315156135123123135153135121354312313515313513513135153135132131515555', LastName = 'tester');
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer Name';
        data.Legal_Name = 'New Dealer Name';
        data.User_Id = '123467895462135467562561468456156456456456415135168748456456156464845645615456132154678978645645648978465456151684897894564875645645641534534534153156416415315645615313515343515313515315315156135123123135153135121354312313515313513513135153135132131515555';
        data.Phone = '8145744389';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);

        System.Assert(RestContext.response.statuscode == 500, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 0, 'Too many Accounts');
        System.Assert([Select Count() from Affiliation__c] == 0, 'Affiliation records was generated');
    }

    @isTest
    public static void testCreateTwoAcccountsForContact(){
        String contactRTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ACV_User').getRecordTypeId();
        String standardAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Standard').getRecordTypeId();
        Contact c = new Contact( email = 'email@test.com', ID__c = '123', LastName = 'tester', RecordTypeId = contactRTID);
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data.DBA_Trade_Name = 'New Dealer` Name';
        data.Legal_Name = 'New Dealer` Name';
        data.User_Id = '123';
        data.Phone = '8145744389';
        data.phoneExt='123';
        data.Cell = '7217143112';
        data.Dealership_Type = 'Franchise';
        data.Street= '123 Main St';
        data.City= 'Buffalo';
        data.State= 'NY';
        data.Zip_code= '01515';
        data.Federal_Tax_ID= '123123123';
        data.License_Number= '456456456';

        IdentityServiceCreateDealerWithContact.CreateDealerRequest data1 = new IdentityServiceCreateDealerWithContact.CreateDealerRequest();
        data1.DBA_Trade_Name = 'Second Account';
        data1.Legal_Name = 'Second Account';
        data1.User_Id = '123';
        data1.Phone = '1234567890';
        data1.phoneExt='123';
        data1.Cell = '';
        data1.Dealership_Type = 'Franchise';
        data1.Street= '456 Main St';
        data1.City= 'Buffalo';
        data1.State= 'NY';
        data1.Zip_code= '01515';
        data1.Federal_Tax_ID= '098766333';
        data1.License_Number= '121212121';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        IdentityServiceCreateDealerWithContact.createDealerWithContact(data);
        IdentityServiceCreateDealerWithContact.createDealerWithContact(data1);
        Test.stopTest();
   
        List<Account> accCreated=[select  Id, Name from Account where legal_name__c= 'Second Account'];
        System.Assert(RestContext.response.statuscode == 201, 'Bad Status Code: '+RestContext.response.statuscode);
        System.Assert([Select Count() from Account] == 2, 'Incorrect number of Accounts');
        System.Assert([Select Count() from Contact Where AccountID = :accCreated[0].Id] == 1, 'Contact did not move to the new Account');
        System.Assert([Select Count() from Affiliation__c] == 2, 'Affiliation records was not generated');
    }
}