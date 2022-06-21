@istest
public class OrganizationAddressChangeEventTest {
    @TestSetup
    static void makeData(){
        Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        List<Schema.Location> locationList = new List<Schema.Location>();
        List<Schema.Address> addressList = new List<Schema.Address>();
        Schema.Location l0 = new Schema.Location(Name='Test0');
        locationList.add(l0);
        
        Schema.Location l2 = new Schema.Location(Name='Test1');
        locationList.add(l2);

        Schema.Location l3 = new Schema.Location(Name='Test2');
        locationList.add(l3);
        
        insert locationList;
        
        Schema.Address a1 = new Schema.Address(ParentId = locationList[0].id, Street = '123 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        addressList.add(a1);       

        Schema.Address a2 = new Schema.Address(ParentId = locationList[1].id, Street = '1234 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        addressList.add(a2);

        Schema.Address a3 = new Schema.Address(ParentId = locationList[2].id, Street = '290 Tanner Street', City = 'Vancouver', State = 'BC', PostalCode= 'V5R 2T4', Country = 'CA');
        addressList.add(a3);
        
        insert addressList;

        locationList = new List<Schema.Location>();

        l0.VisitorAddressId = a1.id;
        locationList.add(l0);
        l2.VisitorAddressId = a2.id;
        locationList.add(l2);
        l3.VisitorAddressId = a3.id;
        locationList.add(l3);
        update locationList;

        List<Account> accountList = new List<Account>();
        Account acc = new Account(Dealership_ID__c = '4568777', RecordTypeId = orgRecordTypeId, Active__c=false, Name='sellerr',legal_Name__c='sellerr', dealer_type__c='2');
        accountList.add(acc);
        Account acc1 = new Account(Dealership_ID__c = '456', RecordTypeId = orgRecordTypeId ,Name='buyer', legal_Name__c='buyer', dealer_type__c='1');
        accountList.add(acc1);
        Account acc2 = new Account(Dealership_ID__c = '45678', RecordTypeId = orgRecordTypeId ,Name='buyer', legal_Name__c='buyer', dealer_type__c='1');
        accountList.add(acc2);
        Account acc3 = new Account(Dealership_ID__c = '456789', RecordTypeId = orgRecordTypeId ,Name='buyer', legal_Name__c='buyer', dealer_type__c='1');
        accountList.add(acc3);
        Account acc4 = new Account(Dealership_ID__c = '456767', RecordTypeId = orgRecordTypeId ,Name='buyer', legal_Name__c='buyer', dealer_type__c='1');
        accountList.add(acc4);
        insert accountList;

        List<AssociatedLocation> alInsertList = new List<AssociatedLocation>();
        List<AssociatedLocation> alDeleteList = new List<AssociatedLocation>();
        AssociatedLocation al = new AssociatedLocation(ParentRecordId=acc.id, LocationId=l0.id, Type='billing', Notes__c = 'TEST billing', Organization_Address_Id__c=1);
        alInsertList.add(al);
        AssociatedLocation al2 = new AssociatedLocation(ParentRecordId=acc1.id, LocationId=l2.id, Type='title_mailing', Notes__c = 'TEST title_mailing');
        alInsertList.add(al2);
        AssociatedLocation al3 = new AssociatedLocation(ParentRecordId=acc2.id, LocationId=l2.id, Type='title_mailing', Notes__c = 'TEST title_mailing');
        alInsertList.add(al3);
        AssociatedLocation al4 = new AssociatedLocation(ParentRecordId=acc3.id, LocationId=l2.id, Type='title_mailing', Notes__c = 'TEST title_mailing');
        alInsertList.add(al4);
        alDeleteList.add(al4);
        AssociatedLocation al5 = new AssociatedLocation(ParentRecordId=acc3.id, LocationId=l2.id, Type='legal', Notes__c = 'TEST legal');
        alInsertList.add(al5);
        alDeleteList.add(al5);
        AssociatedLocation al6 = new AssociatedLocation(ParentRecordId=acc4.id, LocationId=l3.id, Type='legal', Notes__c = 'TEST legal');
        alInsertList.add(al6);
        
        insert alInsertList;
        delete alDeleteList;
        delete [Select id From Integration_Result__c];
    }
    @istest
    static void InsertAddressTest()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];

        Schema.Location l0 = new Schema.Location();
        l0 = [Select id From Location Where Name='Test0'];
        OrganizationAddressChangeEvent.PreventRogueUpdate = true;
        //insert new AssociatedLocation
        AssociatedLocation al = new AssociatedLocation(ParentRecordId=newAcc.id, LocationId=l0.id, Type='legal', Notes__c = 'TEST legal', Inherited_Address_Id__c=false);
        insert al;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id ORDER BY CreatedDate DESC LIMIT 1];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'add-address'
        System.assert(integrationTest.Request_Message__c.contains('add-address'), 'Inserting associatedLocation does not generate add-address Platform Event');
    }
    @istest
    static void InsertInheritedAddressTest()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456'];

        Schema.Location l0 = new Schema.Location();
        l0 = [Select id From Location Where Name='Test0'];

        //insert new AssociatedLocation
        AssociatedLocation al = new AssociatedLocation(ParentRecordId=newAcc.id, LocationId=l0.id, Type='legal', Notes__c = 'TEST billing', Inherited_Address_Id__c = true);
        insert al;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id ORDER BY CreatedDate DESC LIMIT 1];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-address'
        System.assert(integrationTest.Request_Message__c.contains('update-address'), 'Inserting inherited associatedLocation does not generate add-address Platform Event');
    }
    @istest
    static void UpdateAssociatedLocationsAddress()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456'];

        Schema.Location l2 = new Schema.Location();
        l2 = [Select id From Location Where Name='Test1'];

        Schema.Address a1 = new Schema.Address();
        a1 = [Select id, Street, PostalCode From Address Where ParentId = :l2.id];
        System.debug(a1);
        a1.street = '777 Street Rd';
        update a1;

        AssociatedLocation aL = new AssociatedLocation();
        aL = [SELECT ID FROM AssociatedLocation Where ParentRecordId=:newAcc.id AND Type='title_mailing'];

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-address'
        System.assert(integrationTest.Request_Message__c.contains('update-address'), 'Updating associatedLocations related Address record does not generate update-address Platform Event');
    }
    @istest
    static void UpdateAssociatedLocationsAltNameAddress()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];

        AssociatedLocation aL = new AssociatedLocation();
        aL = [SELECT ID, Alternate_Address_Name__c FROM AssociatedLocation Where ParentRecordId=:newAcc.id AND Type='billing'];
        aL.Alternate_Address_Name__c = 'Test Name';
        update AL;

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-address'
        System.assert(integrationTest.Request_Message__c.contains('update-address'), 'Updating associatedLocations related Address record does not generate update-address Platform Event');
    }
    @istest
    static void UpdateAssociatedLocationsActiveStatus()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456'];

        AssociatedLocation aL = new AssociatedLocation();
        aL = [SELECT ID, ActiveTo, ActiveFrom FROM AssociatedLocation Where ParentRecordId=:newAcc.id AND Type='title_mailing'];
        aL.ActiveFrom = Datetime.now() - 1;
        aL.ActiveTo = Datetime.now();
        update aL;

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'delete-address'
        System.assert(integrationTest.Request_Message__c.contains('delete-address'), 'Updating associatedLocations related Address record to inactive does not generate delete-address Platform Event');
    }
    @istest
    static void DeleteAssociatedLocations()  {
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='45678'];

        AssociatedLocation aL = new AssociatedLocation();
        aL = [SELECT ID, ActiveTo, ActiveFrom FROM AssociatedLocation Where ParentRecordId=:newAcc.id AND Type='title_mailing'];
        delete aL;

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'delete-address'
        System.assert(integrationTest.Request_Message__c.contains('delete-address'), 'Deleting associatedLocations does not generate delete-address Platform Event');
    }
    @istest
    static void UnDeleteAssociatedLocations()  {
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456789'];

        AssociatedLocation aL = new AssociatedLocation();
        aL = [SELECT ID, ActiveTo, ActiveFrom, isDeleted FROM AssociatedLocation Where ParentRecordId=:newAcc.id AND Type='legal' ALL ROWS];
        undelete aL;

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c Where recordId__c=:al.id];
        System.debug(integrationTest);

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'Undelete-address'
        System.assert(integrationTest.Request_Message__c.contains('Undelete-address'), 'UnDeleting associatedLocations does not generate delete-address Platform Event');
    }
}