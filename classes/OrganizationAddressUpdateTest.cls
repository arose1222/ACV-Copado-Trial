@istest
public class OrganizationAddressUpdateTest {
    @TestSetup
    static void makeData(){
        Id orgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        List<Schema.Location> locationList = new List<Schema.Location>();
        Schema.Location l0 = new Schema.Location(Name='Test0');
        locationList.add(l0);
        Schema.Location l2 = new Schema.Location(Name='Test1');
        locationList.add(l2);
        
        insert locationList;
        
        List<Schema.Address> addressList = new List<Schema.Address>();
        Schema.Address a1 = new Schema.Address(ParentId = locationList[0].id, Street = '123 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        Schema.Address a2 = new Schema.Address(ParentId = locationList[1].id, Street = '1234 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        addressList.add(a1);
        addressList.add(a2);
        insert addressList;

        locationList = new List<Schema.Location>();
        l0.VisitorAddressId = a1.id;
        l2.VisitorAddressId = a2.id;
        locationList.add(l0);
        locationList.add(l2);

        update locationList;

        List<Account> accountList = new List<Account>();
        Account acc = new Account(Dealership_ID__c = '4568777', RecordTypeId = orgRecordTypeId, Active__c=false, Name='sellerr',legal_Name__c='sellerr', dealer_type__c='2');
        accountList.add(acc);
        Account acc1 = new Account(Dealership_ID__c = '456', RecordTypeId = orgRecordTypeId ,Name='buyer', legal_Name__c='buyer', dealer_type__c='1');
        accountList.add(acc1);

        insert accountList;

        List<AssociatedLocation> assList = new List<AssociatedLocation>();
        AssociatedLocation al = new AssociatedLocation(ParentRecordId=accountList[0].id, LocationId=l0.id, Type='billing', Notes__c = 'TEST billing');
        AssociatedLocation al2 = new AssociatedLocation(ParentRecordId=accountList[0].id, LocationId=l0.id, Type='title_mailing', Notes__c = 'TEST title_mailing');
        AssociatedLocation al3 = new AssociatedLocation(ParentRecordId=accountList[0].id, LocationId=l0.id, Type='legal', Notes__c = 'TEST legal');
        AssociatedLocation al4 = new AssociatedLocation(ParentRecordId=accountList[1].id, LocationId=l2.id, Type='billing', Notes__c = 'TEST billing');
        AssociatedLocation al5 = new AssociatedLocation(ParentRecordId=accountList[1].id, LocationId=l2.id, Type='title_mailing', Notes__c = 'TEST title_mailing');
        AssociatedLocation al6 = new AssociatedLocation(ParentRecordId=accountList[1].id, LocationId=l2.id, Type='legal', Notes__c = 'TEST legal');
        assList.add(al);
        assList.add(al2);
        assList.add(al3);
        assList.add(al4);
        assList.add(al5);
        assList.add(al6);

        insert assList;
        System.debug('HERE HERE HERE');
    

    }
    @istest
    static void InsertAssociatedLocations()  {
        //Find Account
        Account newAcc1 = new Account();
        newAcc1 = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];


        //check that new address updated account 
        System.assertEquals(newAcc1.BillingStreet, '123 Street Rd');
        System.assertEquals(newAcc1.Title_Mailing_Street__c, '123 Street Rd');
        System.assertEquals(newAcc1.Legal_Street__c, '123 Street Rd');
    }
    @istest
    static void UpdateAssociatedLocations()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];

        Schema.Location l2 = new Schema.Location();
        l2 = [Select id From Location Where Name='Test0'];

        Schema.Address a1 = new Schema.Address();
        a1 = [Select id, Street From Address Where ParentId = :l2.id];
        a1.street = '777 Street Rd';
        update a1;

        
        Account newAcc2 = new Account();
        newAcc2 = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];

        //check that new address updated account 
        System.assertEquals(newAcc2.BillingStreet, '777 Street Rd');
        System.assertEquals(newAcc2.Title_Mailing_Street__c, '777 Street Rd');
        System.assertEquals(newAcc2.Legal_Street__c, '777 Street Rd');
    }
    @istest
    static void DeleteAssociatedLocations()  {
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];

        System.assertEquals(newAcc.BillingStreet, '123 Street Rd');

        AssociatedLocation al = new AssociatedLocation();
        al = [Select id From AssociatedLocation Where type = 'billing' AND ParentRecordId = :newAcc.Id];

        System.debug(al);
        delete al;
        
        Account newAcc2 = new Account();
        newAcc2 = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='4568777'];


        //check that new address updated account 
        System.assertEquals(null, newAcc2.BillingStreet);
    }
    @istest
    static void UndeleteAddresses()  {
        //Find Account
        Account newAcc = new Account();
        newAcc = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456'];

        AssociatedLocation al = new AssociatedLocation();
        al = [Select id, isdeleted From AssociatedLocation Where type = 'billing' AND ParentRecordId = :newAcc.Id];
        delete al;

        Account newAcc1 = new Account();
        newAcc1 = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456'];

        System.assertEquals(null, newAcc1.BillingStreet);

        undelete al;

        Account newAcc3 = new Account();
        newAcc3 = [SELECT ID, Active__c, billingStreet, Legal_Street__c, Title_Mailing_Street__c FROM Account Where Dealership_ID__c='456'];

        System.assertEquals(newAcc3.BillingStreet, '1234 Street Rd');
    }
}