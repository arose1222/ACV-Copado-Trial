@istest
public class AssociatedLocAddressGuidGenerationTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        Account a4 = new Account(Name='Test',legal_Name__c='Test',Dealership_ID__c='1234567', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a4;
        Schema.Location l = new Schema.Location(Name='Test1');
        insert l;
        Schema.Address a2 = new Schema.Address(ParentId = l.id, Street = '1234 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        insert a2;
        l.VisitorAddressId = a2.id;
        update l;
        AssociatedLocation l0 = new AssociatedLocation(ParentRecordId=a4.id, Type='legal', Organization_Address_Id__c=1, LocationId=l.id);
        insert l0;
        AssociatedLocation l1 = new AssociatedLocation(ParentRecordId=a4.id, Type='billing', LocationId=l.id);
        insert l1;

    }
    public static testMethod void TestAssLocationGuidGenerationUponInsert(){
        Account a = new Account();
        a = [Select id From Account Where Name='Test'];
        AssociatedLocation l = new AssociatedLocation();
        l = [Select id, Organization_Address_Id__c, Organization_Address_Guid__c From AssociatedLocation Where ParentRecordId=:a.id AND Type = 'billing'];
        System.assert(l.Organization_Address_Guid__c != null, 'Organization_Address_Guid__c null when it shouldnt be');      
    }

    public static testMethod void TestAssLocationGuidGenerationUponInsertFailure(){
        Account a4 = [SELECT ID From Account Limit 1];
        Schema.Location l = new Schema.Location(Name='Testwww1');
        insert l;
        Schema.Address a2 = new Schema.Address(ParentId = l.id, Street = '12345 Street Rd', City = 'Erie', State = 'PA', PostalCode= '16870', Country = 'US');
        insert a2;
        l.VisitorAddressId = a2.id;
        update l;
        AssociatedLocation l0 = new AssociatedLocation(ParentRecordId=a4.id, Type='pickup', LocationId=l.id);
        Boolean failureDetected = false;
        Test.setMock( HTTPCalloutMock.class, new SplunkHelperTest.SplunkMock() );
        Test.startTest();
        try{
            AssociatedLocationUniqueIdGeneration.throwError = true;
            insert l0;
        } 
        catch(Exception e){
            failureDetected = true;
        }
        Test.stopTest();

        system.assert(failureDetected, 'Error Did not happen :(');
    }
}