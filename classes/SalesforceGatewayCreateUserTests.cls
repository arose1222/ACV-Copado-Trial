@isTest
public class SalesforceGatewayCreateUserTests {
 
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert TestUtility.createAccount();

        Lead leadRec = TestUtility.createLead();
        leadRec.State = 'AK';
        leadRec.EIN_Number__c= '456123';
        leadRec.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
        leadRec.Dealer_Type__c='Franchise';
        insert leadRec;

   }

    @isTest
    public static void testContactInsertWithNoLoginHistory(){
        User u = TestUtility.createUser();
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        Test.startTest();
        System.runAs(u){
            SalesforceGatewayUserCreateLogic.enableGatewayLogic();
            insert c;
        }
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = null] == 1, 'Identity Id was created when it shouldnt have');
    }

    @isTest
    public static void testBasicContactInsert(){
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"active": true,"identity_user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6","acv_api_user_id": 0}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.enableGatewayLogic();
        insert c;
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = null] == 0, 'Identity Id was not created when it shouldnt have');
    }

    @isTest
    public static void testBasicContactInsertBadResponse(){
        SalesforceGatewayCreateUserQueueable.makeCallout= false;
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(500,'Error','{"Success": false}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.enableGatewayLogic();
        insert c;
        Test.stopTest();
        //System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = null] == 0, 'Identity Id was not created when it shouldnt have');
    }


    @isTest
    public static void testBulkContactInsertWithSource(){
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"active": true,"identity_user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6","acv_api_user_id": 0}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);

        List<Contact> cList = new List<Contact>();

        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        cList.add(c);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.enableGatewayLogic();
        insert cList;
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = null] == 0, 'Identity Id was not created when it shouldnt have');
    }
    
    @isTest
    public static void testBasicContactInsertBadRunningUser(){
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        Boolean errorHit = false;
        Boolean errorMessageFound = false;
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.startTest();
        SalesforceGatewayUserCreateLogic.enableGatewayLogic();
        try{
            insert c;
        }
        catch(Exception e){
            errorHit = true;
            errorMessageFound = e.getMessage().contains('You do not have an active Identity Id');
        }
        Test.stopTest();
        System.assert(errorHit, 'Error not triggered when it should');
        System.assert(errorMessageFound, 'Bad Error Message');
    }

    @isTest
    public static void testBasicContactInsertRoleSelected(){
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"active": true,"identity_user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6","acv_api_user_id": 0}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        c.Role__c = 'VCI';
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        insert c1;
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.enableGatewayLogic();
        insert c;
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = null] == 0, 'Identity Id was not created when it shouldnt have');
    }

    // @isTest
    // public static void testBulkContactInsertRoleSelected(){
    //     Account a = [SELECT Id FROM Account][0];
    //     TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"active": true,"identity_user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6","acv_api_user_id": 0}',null);
    //     Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
    //     multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);
    //     List<Contact> conList = new List<Contact>();
    //     Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
    //     c1.Identity_Id__c = '111';
    //     c1.Email = UserInfo.getUserEmail();
    //     insert c1;
    //     Boolean errorMessage = false;
    //     for(Integer i = 0; i < 105; i++){
    //         conList.add(TestUtility.createContact(a));
    //     }
    //     Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
    //     Test.startTest();
    //     SalesforceGatewayUserCreateLogic.enableGatewayLogic();
    //     try{
    //         insert conList;
    //     }
    //     catch(Exception e){
    //         errorMessage = e.getMessage().contains('Too many callouts:');
    //     }
    //     Test.stopTest();
    //     System.assert(errorMessage, 'Bad Error Message Thrown');
    // }

    @isTest
    public static void testBasicContactInsertWithLeadConvBadResponse(){
        SalesforceGatewayCreateUserQueueable.makeCallout= false;
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(500,'Error','{"active": true,"identity_user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6","acv_api_user_id": 0}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);

        List<Account> accList = [SELECT Id, Lead_Convert_Status__c FROM Account LIMIT 1];
        accList[0].Lead_Convert_Status__c='Converting';
        update accList;

        List<Contact> cList= new List<Contact>();
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        //insert c;

        
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Map<Id,SalesforceGatewayUserCreate> input= new Map<Id,SalesforceGatewayUserCreate>();
        input.put(c.Id, new SalesforceGatewayUserCreate(c.email, '', 
        c.FirstName+ ' '+ c.LastName , c.mailingPostalCode, 
        c.phone, 'Google', '10.0.0.1', '3fa85f64-5798-4562-b3fc-2c963f66afa6', c.id__c, null, c.Creation_Source__c, c.Contact_Guid__c));
        System.enqueueJob(new SalesforceGatewayCreateUserQueueable(input, 4));
        Test.stopTest();

        System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = null] == 1, 'Identity Id was created when it shouldnt have');
    }
    @isTest
    public static void testBasicContactInsertWithLeadConv(){
        
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','{"active": true,"identity_user_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6","acv_api_user_id": 0}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user',uactiveRes);

        List<Account> accList = [SELECT Id, Lead_Convert_Status__c FROM Account LIMIT 1];
        accList[0].Lead_Convert_Status__c='Converting';
        update accList;

        List<Contact> cList= new List<Contact>();
        Contact c = TestUtility.createContact([SELECT Id FROM Account][0]);
        //insert c;

        
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        insert c;
        Map<Id,SalesforceGatewayUserCreate> input= new Map<Id,SalesforceGatewayUserCreate>();
        input.put(c.Id, new SalesforceGatewayUserCreate(c.email, '', 
        c.FirstName+ ' '+ c.LastName , c.mailingPostalCode, 
        c.phone, 'Google', '10.0.0.1', '3fa85f64-5798-4562-b3fc-2c963f66afa6', c.id__c, null, c.Creation_Source__c, c.Contact_Guid__c));
        System.enqueueJob(new SalesforceGatewayCreateUserQueueable(input));
        Test.stopTest();

        System.assert([SELECT COUNT() FROM CONTACT WHERE Identity_Id__c = '3fa85f64-5717-4562-b3fc-2c963f66afa6'] > 0, 'Identity Id was not created when it shouldnt have');
    }

    @isTest
    public static void testEulaQueueable(){
           

        TestingUtility.SingleRequestMock eulaMockRes = new TestingUtility.SingleRequestMock(200,'OK','{"success": true}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/eula',eulaMockRes);

        List<Account> accList = [SELECT Id, Lead_Convert_Status__c FROM Account LIMIT 1];
        accList[0].Lead_Convert_Status__c='Converting';
        update accList;

        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        c1.Active__c= false;
        insert c1;

        List<lead> leadRecLst = [SELECT Id, Email FROM Lead LIMIT 1];
        Eula_Tos__c eulaTosRec = new Eula_Tos__c(Contact__c = c1.Id, Lead__c=leadRecLst[0].Id, Accepted_Date__c = System.now());
        insert eulaTosRec;

        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        System.enqueueJob(new SalesforceGatewayValidateEulaQueueable(new List<Id>{c1.Id}));
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Lead_Convert_Status__c = 'Complete' and Active__c= true] == 1, 'Eula Endpoint call failed');
        
    }

    
    @isTest
    public static void testEulaQueueableError(){
          
        List<Account> accList = [SELECT Id, Lead_Convert_Status__c FROM Account LIMIT 1];
        accList[0].Lead_Convert_Status__c='Converting';
        update accList;

        TestingUtility.SingleRequestMock eulaMockRes = new TestingUtility.SingleRequestMock(500,'Error','{"success": false}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/eula',eulaMockRes);
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        c1.Active__c= false;
        insert c1;
    
        List<lead> leadRecLst = [SELECT Id, Email FROM Lead LIMIT 1];
        Eula_Tos__c eulaTosRec = new Eula_Tos__c(Contact__c = c1.Id, Lead__c=leadRecLst[0].Id, Accepted_Date__c = System.now());
        insert eulaTosRec;

        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        System.enqueueJob(new SalesforceGatewayValidateEulaQueueable(new List<Id>{c1.Id}));
        Test.stopTest();
        System.assert([SELECT COUNT() FROM CONTACT WHERE Lead_Convert_Status__c = 'Eula/Tos Endpoint Failed' and Active__c= false] == 1, 'Incorrect Lead Convert Status');
        
    }


    
    @isTest
    public static void testCreateUserSendEmailQueueable(){
      
        
        Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
        c1.Identity_Id__c = '111';
        c1.Email = UserInfo.getUserEmail();
        c1.Active__c= false;
        insert c1;

        TestingUtility.SingleRequestMock emailMockRes = new TestingUtility.SingleRequestMock(200,'OK','{"success": true}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Salesforce_Gateway/api/v1/user/welcome',emailMockRes);
    
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));

        Test.startTest();
        List<String> input= new List<String>();
        input.add('test@test.com');
        System.enqueueJob(new SalesforceGatewaySendEmailQueueable(input));
        Test.stopTest();

        }
    
        @isTest
        public static void testCreateUserSendEmailQueueableError(){
          
            
            Contact c1 = TestUtility.createContact([SELECT Id FROM Account][0]);
            c1.Identity_Id__c = '111';
            c1.Email = UserInfo.getUserEmail();
            c1.Active__c= false;
            insert c1;
    
            TestingUtility.SingleRequestMock emailMockRes = new TestingUtility.SingleRequestMock(500,'ERROR','{"success": false}',null);
            Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
            multiCall.put('callout:Salesforce_Gateway/api/v1/user/welcome',emailMockRes);
        
            Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
    
            Test.startTest();
            List<String> input= new List<String>();
            input.add('test@test.com');
            System.enqueueJob(new SalesforceGatewaySendEmailQueueable(input));
            Test.stopTest();
    
            }
}