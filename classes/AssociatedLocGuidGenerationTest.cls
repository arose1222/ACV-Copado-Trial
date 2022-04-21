@istest
public class AssociatedLocGuidGenerationTest {
    @testSetup
    Static void createTestData(){

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
        l = [Select id, Organization_Address_Id__c, Associated_Location_Guid__c From AssociatedLocation Where ParentRecordId=:a.id AND Type = 'billing'];
        System.Debug(l);
        System.assert(l.Associated_Location_Guid__c != null, 'Associated_Location_Guid__c null when it shouldnt be');      
    }
    public static testMethod void TestAssLocationGuidGenerationUponUpdate(){
        Account a = new Account();
        a = [Select id From Account Where Name='Test'];
        AssociatedLocation l = new AssociatedLocation();
        l = [Select id, Organization_Address_Id__c, Associated_Location_Guid__c From AssociatedLocation Where ParentRecordId=:a.id AND Type = 'legal'];
        l.Associated_Location_Guid__c = null;
        update l;

        AssociatedLocation l1 = new AssociatedLocation();
        l1 = [Select id, Organization_Address_Id__c, Associated_Location_Guid__c From AssociatedLocation Where ParentRecordId=:a.id AND Type = 'legal'];

        System.assert(l1.Associated_Location_Guid__c != null, 'Associated_Location_Guid__c null when it shouldnt be');      
    }
}