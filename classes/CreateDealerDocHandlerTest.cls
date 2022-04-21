@isTest
public class CreateDealerDocHandlerTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();

    @TestSetup
    static void makeData(){
        Account acct = new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId());
        insert acct;
        //create expiration date
        Date expDate = System.Today().addMonths(5);
        //create 2 dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = acct.Id, RecordTypeId = licenseId, Document_State__c = 'NY', License_Number__c = '1212345', Expiration_Date__c = expDate, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = acct.Id, RecordTypeId = licenseId, Document_State__c = 'NY', License_Number__c = '1216789', Expiration_Date__c = expDate, Compliant__c = true));
        //insert docs
        insert docList;
    }

    @isTest
    static void resultsTest() {
        Id [] fixedResults = new Id[1];
        //Account account = [select id, name from account limit 1];
        List<Dealer_Docs__c> docList = [SELECT Id, License_Number__c FROM Dealer_Docs__c];
        fixedResults.add(docList[0].Id);
        fixedResults.add(docList[1].Id);
        Test.setFixedSearchResults(fixedResults);
        List<LookupSearchResult> resultList = CreateDealerDocHandler.getLookupInfo('121');
        //make sure multiple licenses are returning
        //System.debug('size: ' + resultList.size());
        System.assertEquals(false, resultList.isEmpty());
        System.assertEquals(2, resultList.size());
    }

    //add new test for returning the license number
    @isTest
    static void licenseNumTest() {
        //need an account
        Account testAcct = new Account(Name = 'Test', IST_Account_Owner__c = UserInfo.getUserId());
        insert testAcct;
        //need a license
        Dealer_Docs__c testDoc = new Dealer_Docs__c(Account__c = testAcct.Id, Expiration_Date__c = null, No_Expiration__c = true, Document_State__c = 'AZ', RecordTypeId = licenseId, Compliant__c = true, License_Number__c = '11111');
        insert testDoc;
        //need to call the method and pass in the doc Id
        String testResp = CreateDealerDocHandler.getLicenseNumber(testDoc.Id);
        //make sure the license number mathes what is being returned
        System.assertEquals('11111', testResp);
    }
}