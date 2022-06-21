/**
 * Tests addAddressToAccount LWC - address management
 * @author Bill Sutton
 * @since 2020
 * @group Identity & Org
 */
@isTest
public class AddAddressToAccountControllerTest {
    public static string addyStringBilling = '{"street":"8369 Lower East Hill Rd","city":"Colden","state":"AK","postalCode":"14033","country":"US","type":"billing","note":"8369 Lower East Hill Rd"}';
    public static string addyStringDelivery = '{"street":"8369 Lower East Hill Rd","city":"Colden","state":"AK","postalCode":"14033","country":"US","type":"delivery","note":"8369 Lower East Hill Rd"}';
    public static string addyStringBillingBad = '{"street":"8369 Lower East Hill Rd","city":"Colden","state":"NYC","postalCode":"14033","country":"US","type":"billing","note":"8369 Lower East Hill Rd"}';
    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        insert a;
    }

    @isTest
    static void testGoodBillingAddress(){
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        Test.startTest();
        AddAddressToAccountController.GenerateAddress(addyStringBilling, accId);
        Test.stopTest();
        System.Assert([SELECT COUNT() FROM AssociatedLocation WHERE ParentRecordId = :accId] == 1, 'Issue finding Assoicated Locations');
    }
    @isTest
    static void testMultipleGoodBillingAddress(){
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        Test.startTest();
        AddAddressToAccountController.GenerateAddress(addyStringBilling, accId);
        AddAddressToAccountController.GenerateAddress(addyStringBilling, accId);
        Test.stopTest();
        System.Assert([SELECT COUNT() FROM AssociatedLocation WHERE ParentRecordId = :accId] == 2, 'Issue finding Assoicated Locations');
    }
    @isTest
    static void testGoodDeliveryAddress(){
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        Test.startTest();
        AddAddressToAccountController.GenerateAddress(addyStringDelivery, accId);
        Test.stopTest();
        System.Assert([SELECT COUNT() FROM AssociatedLocation WHERE ParentRecordId = :accId] == 1, 'Issue finding Assoicated Locations');
    }

    @isTest
    static void testBadBillingAddress(){
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        Boolean errorThrown = false;
        Test.startTest();
        try{
            AddAddressToAccountController.GenerateAddress(addyStringBillingBad, accId);
        }
        catch(Exception e){
            errorThrown = true;
        }
        Test.stopTest();
        System.Assert(errorThrown, 'Error was not thrown');
        System.Assert([SELECT COUNT() FROM AssociatedLocation WHERE ParentRecordId = :accId] == 0, 'Assoicated Locations Found');
        System.Assert([SELECT COUNT() FROM Address] == 0, 'Address Found');
        System.Assert([SELECT COUNT() FROM Location] == 0, 'Location Found');
    }

    @isTest
    static void testGetAddressAndDeactivate() {
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        AddAddressToAccountController.GenerateAddress(addyStringBilling, accId);

        Test.startTest();
            List<AddAddressToAccountController.LocationWrapper> locations = AddAddressToAccountController.getAddressList(accId);
        Test.stopTest();

        System.assert(locations.size() > 0);
        System.assertEquals('billing', locations[0].Location.Type);
        System.assertEquals(true, locations[0].Location.Active_Address__c);

        Boolean deactivated = AddAddressToAccountController.deactivateAddress(locations[0].Location.Id);

        AssociatedLocation locationAfter = [SELECT Id, ActiveTo, Organization_Address_Id__c, Active_Address__c FROM AssociatedLocation WHERE Id = :locations[0].Location.Id];

        System.assertEquals(true, deactivated);
        System.assertNotEquals(null, locationAfter.ActiveTo);
        System.assertEquals(false, locationAfter.Active_Address__c);
    }

    @isTest
    static void testRetrieveCurrentAddress() {
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        List<AssociatedLocation> assLocation = new List<AssociatedLocation>();

        Test.startTest();
            AddAddressToAccountController.GenerateAddress(addyStringDelivery, accId);
            List<AddAddressToAccountController.LocationWrapper> locations = AddAddressToAccountController.getAddressList(accId);
            assLocation = AddAddressToAccountController.retrieveCurrentAddress(accId,locations[0].Location.Id);
        Test.stopTest();     

        System.assert(assLocation.size() > 0);
        System.assertEquals(1, assLocation.size());
    }

    @isTest
    static void testUpdateAddress() {
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        String result;

        Test.startTest();
            AddAddressToAccountController.GenerateAddress(addyStringDelivery, accId);
            List<AddAddressToAccountController.LocationWrapper> locations = AddAddressToAccountController.getAddressList(accId);
            String addressAlternate = locations[0].Location.Alternate_Address_Name__c = 'New Alternate Address';
            String addressNotes = locations[0].Location.Notes__c = 'New Note';
            String MonFriStartTime = locations[0].Location.Monday_Friday_Start_Time__c = '8:00 AM';
            String MonFriEndTime = locations[0].Location.Monday_Friday_End_Time__c = '12:00 PM';
            String SatStartTime = locations[0].Location.Saturday_Start_Time__c = '9:00 AM';
            String SatEndTime = locations[0].Location.Saturday_End_Time__c = '1:00 PM';
            String SunStartTime = locations[0].Location.Sunday_Start_Time__c = '10:00 AM';
            String SunEndTim = locations[0].Location.Sunday_End_Time__c = '2:00 PM';
            String TimeZone = locations[0].Location.TimeZone__c = 'central';
            result = AddAddressToAccountController.updateAddress(accId,locations[0].Location.Id, addressAlternate, addressNotes, TimeZone, MonFriStartTime, MonFriEndTime, SatStartTime, SatEndTime, SunStartTime, SunEndTim);            
        Test.stopTest();             

        System.assertEquals('Success', result);
    }

    @isTest
    static void testBadUpdateAddress() {
        String accId = [SELECT ID FROM Account LIMIT 1].Id;
        String result;
        Boolean errorThrown = false;
        Test.startTest();
        try{
            AddAddressToAccountController.GenerateAddress(addyStringDelivery, accId);
            List<AddAddressToAccountController.LocationWrapper> locations = AddAddressToAccountController.getAddressList(accId);                            
            String TimeZone = locations[0].Location.TimeZone__c = 'center';
            result = AddAddressToAccountController.updateAddress(accId,locations[0].Location.Id, '', '', TimeZone, '', '', '', '', '', '');            
        }
        catch(Exception e){
            errorThrown = true;
        }
        Test.stopTest();     

        System.assertEquals(null, result);                
    }
}