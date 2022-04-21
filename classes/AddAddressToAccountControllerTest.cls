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
}