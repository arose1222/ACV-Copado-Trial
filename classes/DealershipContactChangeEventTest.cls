@istest
public class DealershipContactChangeEventTest {
    @TestSetup
    static void makeData(){
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        Account a = new Account(Dealership_ID__c = '4568777', Name='sellerr',legal_Name__c='sellerr', dealer_type__c='2',BillingStreet='159 main st', BillingState='NY', BillingCity='Rochester', BillingPostalCode='15555', BillingCountry='US');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact1', AccountId = a.id, RecordTypeId = contactRecordTypeId, phone='1234567890');
        insert c;
        Integration_Result__c integrationAll= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll;
        Account a3 = new Account(Name='buyer',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a3;
        Contact c3 = new Contact(FirstName = 'test', MiddleName = 'J', LastName='Contact3', AccountId = a3.id, id__c='123', Dealership_Contact_Id__c='123', RecordTypeId = contactRecordTypeId, phone='1234567890');
        insert c3;
        Integration_Result__c integrationAll2= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll2;
        Contact c4 = new Contact(FirstName = 'test', MiddleName = 'J', LastName='Contact4', AccountId = a3.id, id__c='1234', Dealership_Contact_Id__c='1234', RecordTypeId = contactRecordTypeId, phone='1234567890');
        insert c4;
        Integration_Result__c integrationAll3= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];
        delete integrationAll3;
        delete c4;
        // Integration_Result__c integrationAll4= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];

    }
    @istest
    static void UpdateDealerContactEventTest()  {
        //Update Active flag
        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, LastName FROM Contact Where LastName='Contact1'];
        System.debug(newCon);
        newCon.LastName='Changed';
        update newCon;
        System.debug(newCon);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-user'
        System.assert(integrationTest.Request_Message__c.contains('update-contact'), 'Changing Active flag does not generate update-contact Platform Event');

    }
    @istest
    static void InsertDealerContactTest()  {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
        //insert new Contact
        Account a4 = new Account(dealership_id__c='12345699',Name='dealer666',legal_Name__c='dealer666', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Amherst', BillingPostalCode='16123', BillingCountry='US');
        insert a4;
        Contact newCon = new Contact();
        newCon = (new Contact(FirstName = 'test', LastName='Contact7', AccountId = a4.id, RecordTypeId = contactRecordTypeId, phone='1234567890'));
        insert newCon;
        System.debug([Select id, id__c, active__c, LastName, Contact_Guid__c From Contact where id=:newCon.id]);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'create-contact'
        System.assert(integrationTest.Request_Message__c.contains('add-contact'), 'Inserting contact does not generate add-contact Platform Event');
    }
    @istest
    static void DeleteDealerContactEventTest()  {
        //Update Active flag
        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, Active__c FROM Contact Where LastName='Contact3'];
        System.debug(newCon);
        delete newCon;
        System.debug(newCon);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'delete-contact'
        System.assert(integrationTest.Request_Message__c.contains('delete-contact'), 'Deleting Contact does not generate delete-contact Platform Event');
    }
    @istest
    static void UndeleteDealerContactTest()  {
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Dealership Contact').getRecordTypeId();
        //insert new Contact
        Account a4 = new Account(dealership_id__c='12345699',Name='dealer666',legal_Name__c='dealer666', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Amherst', BillingPostalCode='16123', BillingCountry='US');
        insert a4;
        Contact newCon = new Contact();
        newCon = (new Contact(FirstName = 'test', LastName='Contact7', AccountId = a4.id, RecordTypeId = contactRecordTypeId, phone='1234567890'));
        insert newCon;
        System.debug([Select id, id__c, active__c, LastName, Contact_Guid__c From Contact where id=:newCon.id]);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        delete integrationTest;

        delete newCon;
        Integration_Result__c integrationTest2= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        delete integrationTest2;

        undelete newCon;
        Integration_Result__c integrationTest3= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:newCon.id];
        System.debug('Undelete');
        System.debug(integrationTest3);
        delete integrationTest3;

        System.assertEquals(200, integrationTest3.Status_Code__c);
        //Confirm Event type is 'undelete-contact'
        System.assert(integrationTest3.Request_Message__c.contains('undelete-contact'), 'Undeleting contact does not generate undelete-contact Platform Event');
    }
    public static testMethod void TestContactAccountChangeErrorUponUpdate(){
        //Check an error message will fire when attempting to Change the Account field on an already exisitng Dealership Contact
        Account acOld = [Select id From Account Where Name='sellerr'];
        Account acNew = [Select id From Account Where Name='buyer'];
        Contact newCon = new Contact();
        newCon = [SELECT ID, Id__c, LastName FROM Contact Where LastName = 'Contact1'];        
        Boolean goterror = false;
            try{
                newCon.AccountId=acNew.id;
                update newCon;
            }catch(Exception exc){
                if(exc.getMessage().contains('Cannot change Contact account after creation. If this Contact record was created in error, please de-activiate this record and create a new Contact with the correct Account association.')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'Contact Account Change Error failed to prevent Account record change on Contact');   
    }
}