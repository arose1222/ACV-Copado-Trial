@istest
public class OrganizationAddressTypeValidationTest {
    @testSetup
    Static void createTestData(){

        Account a4 = new Account(Name='Test',legal_Name__c='Test',Dealership_ID__c='1234567', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a4;
        Schema.Location l = new Schema.Location(Name='Test1');
        insert l;
        Schema.Address a1 = new Schema.Address(ParentId = l.id, Street = '123 Street Rd', City = 'Buffalo', State = 'NY', PostalCode= '12345', Country = 'US');
        insert a1;
        l.VisitorAddressId = a1.id;
        update l;
        AssociatedLocation l0 = new AssociatedLocation(ParentRecordId=a4.id, Type= 'legal', Organization_Address_Id__c=1, LocationId=l.id);
        insert l0;
        AssociatedLocation l2 = new AssociatedLocation(ParentRecordId=a4.id, Type = 'billing', LocationId=l.id);
        insert l2;
        AssociatedLocation l3 = new AssociatedLocation(ParentRecordId=a4.id, Type = 'title_mailing', LocationId=l.id);
        insert l3;
        delete l3;
        

    }
    public static testMethod void TestAssLocationTypeErrorUponInsert(){
        Schema.Location l = new Schema.Location();
        l = [Select id From Location Where Name='Test1'];
        Account a = new Account();
        a = [Select id From Account Where Dealership_ID__c='1234567'];
        AssociatedLocation l2 = new AssociatedLocation(ParentRecordId=a.id, Type = 'billing', LocationId=l.id);
        Boolean goterror = false;
            try{
                System.debug(l2);
                insert l2;
            }catch(Exception exc){
                System.debug(exc);
                if(exc.getMessage().contains('This Account already has a billing Address. Please update this address instead of creating a new one')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'OrganizationAddressTypeValidation Rule to prevent multiple Address types for an account has failed to fire');    
    }
    public static testMethod void TestAssLocationTypeErrorUponUpdate(){
        Schema.Location l = new Schema.Location();
        l = [Select id From Location Where Name='Test1'];
        Account a = new Account();
        a = [Select id From Account Where Dealership_ID__c='1234567'];
        AssociatedLocation l2 = new AssociatedLocation();
        l2 = [Select id, Type From AssociatedLocation Where Type = 'legal' AND LocationId=:l.id];
        Boolean goterror = false;
            try{
                System.debug(l2);
                l2.type = 'billing';
                update l2;
            }catch(Exception exc){
                System.debug(exc);
                if(exc.getMessage().contains('This Account already has a billing Address. Please update this address instead of creating a new one')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'OrganizationAddressTypeValidation Rule to prevent multiple Address types for an account has failed to fire');    
    }
    public static testMethod void TestAssLocationTypeErrorUponUndelete(){
        Schema.Location l = new Schema.Location();
        l = [Select id From Location Where Name='Test1'];
        Account a = new Account();
        a = [Select id From Account Where Dealership_ID__c='1234567'];
        AssociatedLocation l2 = new AssociatedLocation();
        l2 = [Select id, Type, isDeleted From AssociatedLocation Where Type = 'title_mailing' AND ParentRecordId=:a.id ALL ROWS];

        AssociatedLocation l3 = new AssociatedLocation(ParentRecordId=a.id, Type = 'title_mailing', LocationId=l.id);
        insert l3;
        Boolean goterror = false;
            try{
                System.debug(l2);
                undelete l2;
                AssociatedLocation l4 = new AssociatedLocation();
                l4 = [Select id, Type, isDeleted From AssociatedLocation Where Type = 'title_mailing' AND LocationId=:l.id ALL ROWS];
                System.debug(l4);
            }catch(Exception exc){
                System.debug(exc);
                if(exc.getMessage().contains('This Account already has a title_mailing Address. Please update this address instead of creating a new one')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'OrganizationAddressTypeValidation Rule to prevent multiple Address types for an account has failed to fire');    
    }
}