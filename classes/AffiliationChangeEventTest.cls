@istest
public class AffiliationChangeEventTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        
        Account a = new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact1', AccountId = a.id, id__c='123', RecordTypeId = acvuserRecordTypeId, email='test1@email.com');
        insert c;
        Integration_Result__c integrationAll= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll;
        Account a2 = new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a2;
        Contact c2 = new Contact(FirstName = 'test', LastName='Contact2', AccountId = a2.id, id__c='456', RecordTypeId = acvuserRecordTypeId, email='test@email.com');
        insert c2;
        Integration_Result__c integrationAll2= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll2;
        Affiliation__c af1 = new Affiliation__c(Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true, type__c='admin', primary_contact__c=true);
        insert af1;
        Integration_Result__c integrationAll3= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll3;
        Affiliation__c af2 = new Affiliation__c(Account__c=a2.id, Contact__c=c2.id, primary_contact__c=true, type__c='admin');
        insert af2;
        Integration_Result__c integrationAll4= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll4;

        Affiliation__c af3 = new Affiliation__c(Account__c=a2.id, Contact__c=c.id, Receive_Email__c=true, type__c='rep');
        insert af3;
        Integration_Result__c integrationAll5= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll5;


    }
    @istest
    static void UpdateAffiliationEventTest()  {
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Update Active flag
        Affiliation__c newAff = new Affiliation__c();
        newAff = [SELECT ID, Id__c, Active__c FROM Affiliation__c Where Receive_Push__c = true];
        newAff.Receive_Push__c= false;
        update newAff;
        System.debug(newAff);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newAff.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('update-affiliation'), 'Changing Active flag does not generate update-affiliation Platform Event');

    }
    @istest
    static void AddAffiliationEventTest()  {
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //insert new affiliation
        Account a = [Select id From Account Where Name='seller'];
        Contact c = [Select id From Contact Where LastName='Contact2'];
        Affiliation__c newAff = new Affiliation__c();
        newAff = (new Affiliation__c(Account__c=a.id, Contact__c=c.id, type__c='rep'));
        insert newAff;

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newAff.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'create-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('add-affiliation'), 'Inserting affiliation does not generate add-affiliation Platform Event');

    }
    @istest
    static void DeleteAffiliationEventTest()  {
        //delete affiliation
        Account a = [Select id From Account Where Name='buyer'];

        Affiliation__c newAff = new Affiliation__c();
        newAff = [SELECT ID, Id__c, Active__c FROM Affiliation__c Where type__c = 'rep' AND Account__c=:a.id];
        delete newAff;
        System.debug(newAff);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newAff.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'delete-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('delete-affiliation'), 'Changing Active flag does not generate update-affiliation Platform Event');


    }
    @istest
    static void UndeleteAffiliationEventTest()  {
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Undelete affiliation
        
        List<Affiliation__c> newAff = [SELECT ID, Id__c, Active__c FROM Affiliation__c Where Receive_email__c = true];
        System.assert(newAff.size() > 0, 'No Affiliations returned.');
        delete newAff;
        Integration_Result__c integrationAll6= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:newAff[0].id];
        delete integrationAll6;
        undelete newAff;
        System.debug(newAff);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newAff[0].id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('undelete-affiliation'), 'Changing Active flag does not generate update-affiliation Platform Event');

    }
}