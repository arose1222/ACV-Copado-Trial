@istest
public class ContactACVUserChangeEventTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        Account a = new Account(Dealership_ID__c = '4568777', Name='sellerr',legal_Name__c='sellerr', dealer_type__c='2',BillingStreet='159 main st', BillingState='NY', BillingCity='Rochester', BillingPostalCode='15555', BillingCountry='US', phone = '1234567890');
        insert a;
        Contact cc = new Contact(FirstName = 'test', LastName='Contact1', AccountId = a.id, RecordTypeId = acvuserRecordTypeId, email = UserInfo.getUserEmail(), Identity_Id__c = '1');
        insert cc;
        Integration_Result__c integrationAll0= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll0;
        Contact c = new Contact(FirstName = 'test', LastName='Contact5', AccountId = a.id, RecordTypeId = acvuserRecordTypeId, email = 'acv@email1.com');
        insert c;
        Integration_Result__c integrationAll= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll;
        Account a3 = new Account(Name='NoId',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a3;
        Contact c3 = new Contact(FirstName = 'test', MiddleName = 'J', LastName='Contact3', AccountId = a3.id, id__c='123', Dealership_Contact_Id__c='123', RecordTypeId = acvuserRecordTypeId, email = 'acv@email.com');
        insert c3;
        Integration_Result__c integrationAll2= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll2;
        Contact c4 = new Contact(FirstName = 'test', MiddleName = 'J', LastName='Contact4', AccountId = a3.id, id__c='1234', Dealership_Contact_Id__c='1234', RecordTypeId = acvuserRecordTypeId, email = 'acv@email2.com');
        insert c4;
        Integration_Result__c integrationAll3= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll3;
        delete c4;
        Integration_Result__c integrationAll4= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];


    }
    @istest
    static void UpdateACVUserEventTest()  {
        Test.startTest();
        //Update Active flag
        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, MobilePhone
        FROM Contact Where LastName='Contact1'];
        System.debug(newCon);
        newCon.MobilePhone = '123456789';
        update newCon;
        System.debug(newCon);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-user'
        System.assert(integrationTest.Request_Message__c.contains('update-user'), 'Changing MobilePhone does not generate update-user Platform Event');
        Test.stopTest();
    }
    @istest
    static void InsertUserTest()  {
        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        //insert new Contact
        Account a4 = new Account(dealership_id__c='12345699',Name='dealer666',legal_Name__c='dealer666', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Amherst', BillingPostalCode='16123', BillingCountry='US');
        insert a4;
        Contact newCon = new Contact();
        newCon = (new Contact(FirstName = 'test', LastName='Contact7', AccountId = a4.id, RecordTypeId = acvuserRecordTypeId, email = 'acv@email4.com'));
        insert newCon;
        System.debug([Select id, id__c, active__c, LastName, Contact_Guid__c From Contact where id=:newCon.id]);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'create-user'
        System.assert(integrationTest.Request_Message__c.contains('create-user'), 'Inserting contact does not generate create-user Platform Event');
        Test.stopTest();
    }
    @istest
    static void DeleteACVUserEventTest()  {
        Test.startTest();
        //Update Active flag
        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, Active__c FROM Contact Where LastName='Contact3'];
        System.debug(newCon);
        delete newCon;
        System.debug(newCon);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-user'
        System.assert(integrationTest.Request_Message__c.contains('delete-user'), 'Deleting ACV User does not generate delete-user Platform Event');
        Test.stopTest();
    }
    @istest
    static void UndeleteUserTest()  {
        Test.startTest();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        //insert new Contact
        Account a4 = new Account(dealership_id__c='12345699',Name='dealer666',legal_Name__c='dealer666', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Amherst', BillingPostalCode='16123', BillingCountry='US');
        insert a4;
        Contact newCon = new Contact();
        newCon = (new Contact(FirstName = 'test', LastName='Contact7', AccountId = a4.id, RecordTypeId = acvuserRecordTypeId, email = 'acv@email5.com'));
        insert newCon;
        System.debug([Select id, id__c, active__c, LastName, Contact_Guid__c From Contact where id=:newCon.id]);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        delete integrationTest;

        delete newCon;
        Integration_Result__c integrationTest2= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        delete integrationTest2;

        undelete newCon;
        Integration_Result__c integrationTest3= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        delete integrationTest3;

        System.assertEquals(200, integrationTest3.Status_Code__c);
        //Confirm Event type is 'undelete-user'
        System.assert(integrationTest3.Request_Message__c.contains('undelete-user'), 'Undeleting contact does not generate undelete-user Platform Event');
        Test.stopTest();
    }
}