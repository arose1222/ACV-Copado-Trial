/**
* @description : Test class for Lookup Field LWC component controller
* @author      : Ankit Bhatnagar, Traction On Demand
* @date        : 2020/03/31
*/
@isTest
public class LookupFieldCtrlTest {
    @TestSetup
    public static void setupData(){
        List<Sobject> sobjects = new List<Sobject>();
        //Insert Accounts
        for( Integer i = 0; i <5; i++ ){
            sobjects.add( new Account( Name='Test' + i, Phone = '123456789' + i ) );
        }
        for( Integer i = 0; i <5; i++ ){
            sobjects.add( new Account( Name='Dummy' + i, Phone = '123456789' + i ) );
        }
        INSERT sobjects;
        Id existingAccountId = sobjects[0].Id;
        sobjects = new List<Sobject>();
        //Insert Contacts
        for( Integer i = 0; i <1; i++ ){
            sobjects.add( new Contact( FirstName = 'Contact', LastName='Test' + i, email = 'test' + i + '@test.com', AccountId = existingAccountId ) );
        }
        for( Integer i = 0; i <1; i++ ){
            sobjects.add( new Contact( FirstName = 'Contact',LastName='Dummy' + i, email = 'dummy' + i + '@dummy.com',AccountId = existingAccountId ) );
        }
        INSERT sobjects;

    }
    @isTest
    static void getSingleAccount(){
        Test.startTest();
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        System.assertNotEquals(NULL, accounts);
        Test.setFixedSearchResults(new List<Id>{accounts[0].Id});
        String res = LookupFieldCtrl.getFilteredRecords( 'Account', 'Name,Phone', 'Test','', null);
        List<LookupFieldCtrl.ResultWrapper> resObj = (List<LookupFieldCtrl.ResultWrapper>)
                JSON.deserialize(res, List<LookupFieldCtrl.ResultWrapper>.class);
        Test.stopTest();
    }
    @isTest
    public static void getMultipleContacts(){
        Test.startTest();
        List<Id> contactIds = new List<Id>();
        for( Contact con : [SELECT Id FROM Contact WHERE LastName LIKE 'Dummy%' ]){
            contactIds.add( con.Id );
        }
        System.assertNotEquals(NULL, contactIds);
        Test.setFixedSearchResults( contactIds );
        String res = LookupFieldCtrl.getFilteredRecords( 'Contact', 'Name,Phone', 'Dummy','', null);
        List<LookupFieldCtrl.ResultWrapper> resObj = (List<LookupFieldCtrl.ResultWrapper>)
                JSON.deserialize(res, List<LookupFieldCtrl.ResultWrapper>.class);
        Test.stopTest();
    }
    @isTest
    public static void invalidSObjectName(){
        Test.startTest();
        String errorMsg;
        try{
            LookupFieldCtrl.getFilteredRecords( 'Incorrect_Object', 'Name,Phone', 'Dummy','', null);
        }catch( Exception e){
            errorMsg = e.getMessage();
        }
        System.assert( String.isNotBlank( errorMsg ) );
        Test.stopTest();
    }
    @isTest
    public static void invalidFieldName(){
        Test.startTest();
        String errorMsg;
        try{
            errorMsg = LookupFieldCtrl.getFilteredRecords( 'Contact', 'Name,Incorrect_Field', 'Dummy','', null);
        }catch( Exception e){
            errorMsg = e.getMessage();
        }
        System.assert( String.isNotBlank( errorMsg ) );
        Test.stopTest();
    }
    @isTest
    public static void noRecords(){
        Test.startTest();
        String res = LookupFieldCtrl.getFilteredRecords( 'Contact', 'Name,Phone', 'No Data','', null);
        List<LookupFieldCtrl.ResultWrapper> resObj = (List<LookupFieldCtrl.ResultWrapper>)
                JSON.deserialize(res, List<LookupFieldCtrl.ResultWrapper>.class);
        System.assert( String.isNotBlank( res ) );
        Test.stopTest();
    }

    @isTest
    public static void searchWithExcludedResource() {
        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        ServiceResource sr1 = FSLTestUtility.makeResourceData();
        ServiceResource sr2 = FSLTestUtility.makeResourceData();

        List<ResourcePreference> rpLst = new List<ResourcePreference>();
        ResourcePreference rp1 = FSLTestUtility.createPreference( sr1.Id, testAcct.Id );
        rpLst.add( rp1 );
        ResourcePreference rp2 = FSLTestUtility.createPreference( 'Excluded', sr2.Id, testAcct.Id );
        rpLst.add( rp2 );
        insert rpLst;

        List<Id> idLst = new List<Id>();
        idLst.add( sr1.Id );
        idLst.add( sr2.Id );
        Test.setFixedSearchResults( idLst );

        Test.startTest();
            String res = LookupFieldCtrl.getFilteredRecords( 'ServiceResource', 'Name', 'Testing', '', testAcct.Id );
            List<LookupFieldCtrl.ResultWrapper> resObjLst = (List<LookupFieldCtrl.ResultWrapper>) JSON.deserialize(res, List<LookupFieldCtrl.ResultWrapper>.class);
        Test.stopTest();

        Boolean foundProperResource = FALSE;
        Boolean foundExcludedResource = FALSE;   
        for ( LookupFieldCtrl.ResultWrapper wrapperResult : resObjLst ) {
            if ( wrapperResult.Id == sr1.Id ) {
                foundProperResource = TRUE;
            } else if ( wrapperResult.Id == sr2.Id ) {
                foundExcludedResource = TRUE;
            }
        }

        System.assertEquals( FALSE, foundExcludedResource, 'An Excluded Resource was returned in the search!' );
        System.assertEquals( TRUE, foundProperResource, 'A Normal Resource was not found by the search!' );
    }
}