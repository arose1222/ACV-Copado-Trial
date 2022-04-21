@isTest
public class ISTCaseListControllerTest {
    
    @TestSetup
    static void makeData(){
        Account a =TestUtility.createAccount('Bill Test');
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c au = TestUtility.createAuction(a,c,v);
        insert au;
        List<Case> casesToInsert = new List<Case>();
        Case ca1 = TestUtility.createTitleCase(au, a, c);
        casesToInsert.add(ca1);
        Case ca2 = TestUtility.createTitleCase(au, a, c);
        ca2.Seller_Dealership__c = a.Id;
        ca2.Subject = 'Seller';
        casesToInsert.add(ca2);
        insert casesToInsert;
        
    }

    @isTest
    static void testGettingCaseRT(){
        List<LWCUtility.Picklist> testList = (List<LWCUtility.Picklist>)JSON.deserialize(ISTCaseListController.getRecordTypeSelectList(), List<LWCUtility.Picklist>.class);
        System.assert(testList.size() > 0, 'No RTs Returned when there should have been');
    }

    @isTest
    static void testGettingCasesAsBuyer(){
        List<Account> aList = [SELECT Id FROM Account];
        if(aList.size() > 0){
            System.assert(ISTCaseListController.getAllCases(aList[0].Id, false).size() == 2, 'Both cases should be returned');
        }
    }

    @isTest
    static void testGettingCasesAsSeller(){
        // added test with Sale-701
        List<Account> aList = [SELECT Id FROM Account];
        Case sellerCase = [SELECT Id FROM Case WHERE Subject = 'Seller'];

        test.startTest();
            List<Case> returnedCases = ISTCaseListController.getAllCases(aList[0].Id, true);
        test.stopTest();

        System.assertEquals(sellerCase.Id, returnedCases[0].Id);
    
    }

    
}