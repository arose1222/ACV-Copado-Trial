@isTest
public class AccountMergeProcessTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        List<Schema.Account> accountList = new List<Schema.Account>();
        List<Schema.Contact> contactList = new List<Schema.Contact>();
        List<Schema.Affiliation__c> affiliationList = new List<Schema.Affiliation__c>();

        Account a = TestUtility.createAccount('Master');
        accountList.add(a);
        Account a2 = TestUtility.createAccount('Merge');
        accountList.add(a2);

        insert accountList;

        Contact c = TestUtility.createContact(a);
        contactList.add(c);
        Contact c2 = TestUtility.createContact(a2);
        contactList.add(c2);
        Contact dc = TestUtility.createDealerContact(a);
        contactList.add(dc);
        Contact dc2 = TestUtility.createDealerContact(a2);
        contactList.add(dc2);

        insert contactList;

        Affiliation__c af = TestUtility.createAffiliation(a, c);
        affiliationList.add(af);
        Affiliation__c af2 = TestUtility.createAffiliation(a, c2);
        affiliationList.add(af2);
        Affiliation__c af3 = TestUtility.createAffiliation(a2, c2);
        affiliationList.add(af3);

        insert affiliationList;

        Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        List<Schema.Location> locationList = new List<Schema.Location>();
        List<Schema.Address> addressList = new List<Schema.Address>();

        Schema.Location l0 = new Schema.Location(Name='Test0');
        locationList.add(l0);
        Schema.Location l1 = new Schema.Location(Name='Test1');
        locationList.add(l1);

        insert locationList;
        
        Schema.Address add1 = new Schema.Address(ParentId = locationList[0].id, Street = '123 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        addressList.add(add1);       
        Schema.Address add2 = new Schema.Address(ParentId = locationList[1].id, Street = '321 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '54321', Country = 'US');
        addressList.add(add2);       

        insert addressList;

        locationList = new List<Schema.Location>();

        l0.VisitorAddressId = add1.id;
        locationList.add(l0);
        l1.VisitorAddressId = add2.id;
        locationList.add(l1);

        update locationList;

        List<AssociatedLocation> alInsertList = new List<AssociatedLocation>();

        AssociatedLocation al = new AssociatedLocation(ParentRecordId=a.id, LocationId=l0.id, Type='billing', Notes__c = 'TEST billing', Organization_Address_Id__c=1);
        alInsertList.add(al);
        AssociatedLocation al2 = new AssociatedLocation(ParentRecordId=a2.id, LocationId=l1.id, Type='billing', Notes__c = 'TEST billing 2', Organization_Address_Id__c=2);
        alInsertList.add(al2);

        insert alInsertList;

        delete [Select id From Integration_Result__c];
    }
    @istest
    static void MergeAccount()  {
        
        Account masterAcc = new Account();
        Account mergeAcc = new Account();
        Affiliation__c mergeAff = new Affiliation__c();
        Contact mergeCon = new Contact();
        Contact mergeUser = new Contact();
        AssociatedLocation mergeAdd = new AssociatedLocation();


        test.startTest();
        
        Id acvUserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        masterAcc = [SELECT ID FROM Account Where Name = 'Master'];
        mergeAcc = [SELECT ID FROM Account WHERE Name = 'Merge'];
        mergeAff = [SELECT ID FROM Affiliation__c Where Account__c = :mergeAcc.Id];
        mergeCon = [SELECT ID FROM Contact Where AccountId = :mergeAcc.Id AND RecordTypeId = '0125b000000PXoNAAW'];
        mergeUser = [SELECT ID, AccountId FROM Contact Where AccountId = :mergeAcc.Id AND RecordTypeId = :acvUserRecordTypeId];
        mergeAdd = [SELECT ID FROM AssociatedLocation Where ParentRecordId = :mergeAcc.Id];

        mergeUser.AccountId = masterAcc.Id;
        update mergeUser;
        merge masterAcc mergeAcc;

        Integration_Result__c affIntegrationTest = [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:mergeAff.id][0];

        System.assertEquals(200, affIntegrationTest.Status_Code__c);
        //Confirm Event type is 'delete-affiliation'
        System.assert(affIntegrationTest.Request_Message__c.contains('delete-affiliation'), 'Deleting affiliation does not generate delete-affiliation Platform Event');

        Integration_Result__c conIntegrationTest = [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:mergeCon.id][0];

        System.assertEquals(200, conIntegrationTest.Status_Code__c);
        //Confirm Event type is 'delete-contact'
        System.assert(conIntegrationTest.Request_Message__c.contains('delete-contact'), 'Deleting contact does not generate delete-contact Platform Event');

        Integration_Result__c addIntegrationTest = [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:mergeAdd.id][0];

        System.assertEquals(200, addIntegrationTest.Status_Code__c);
        //Confirm Event type is 'delete-address'
        System.assert(addIntegrationTest.Request_Message__c.contains('delete-address'), 'Deleting address does not generate delete-address Platform Event');

        test.stopTest();
    }
}