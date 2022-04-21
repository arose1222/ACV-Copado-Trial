@istest
public class AddressGuidGenerationTest {
    @testSetup
    Static void createTestData(){

        Schema.Location l = new Schema.Location(Name='Test1');
        insert l;
        Schema.Address ab = new Schema.Address(ParentId = l.id, Street = '123 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        Schema.Address atm = new Schema.Address(ParentId = l.id, Street = '124 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        insert ab;
        insert atm;

    }
    public static testMethod void TestAssLocationGuidGenerationUponInsert(){
        Schema.Location l = new Schema.Location();
        l = [Select id From Location Where Name='Test1'];
        Schema.Address ab = new Schema.Address();
        ab = [Select id, Address_Guid__c From Address Where ParentId=:l.id AND Street = '123 Street Rd'];
        System.Debug(ab);
        System.assert(ab.Address_Guid__c != null, 'Address_Guid__c null when it shouldnt be');      
    }
    public static testMethod void TestAssLocationGuidGenerationUponUpdate(){
        Schema.Location l = new Schema.Location();
        l = [Select id From Location Where Name='Test1'];
        Schema.Address ab = new Schema.Address();
        ab = [Select id, Address_Guid__c From Address Where ParentId=:l.id AND Street = '124 Street Rd'];
        ab.Address_Guid__c = null;
        update ab;

        Schema.Address ab2 = new Schema.Address();
        ab2 = [Select id, Address_Guid__c From Address Where ParentId=:l.id AND Street = '124 Street Rd'];

        System.assert(ab2.Address_Guid__c != null, 'Address_Guid__c null when it shouldnt be');      
    }
}