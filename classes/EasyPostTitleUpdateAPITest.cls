@isTest
public class EasyPostTitleUpdateAPITest {
    @TestSetup
    static void makeData(){
        // Create Case Trigger Flag
        insert new CaseTriggerFlag__c( Name='Default', Enabled__c = true );

        Account acct = TestUtility.createAccount();
        insert acct;

        Contact con = TestUtility.createContact( acct );
        insert con;

        Vehicle__c vech = TestUtility.createVehicle();
        insert vech;

        Auction__c auct = TestUtility.createAuction( acct, con, vech );
        insert auct;

        Case titleCase = TestUtility.createTitleCase( auct, acct, con );
        titleCase.ACV_Titles_External_ID__c = '123456789';
        insert titleCase;
    }
	@isTest
    public static void testTitleUpdate(){
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Case titleCase = [SELECT Id, Auction_Number_Searchable__c, Easypost_Tracker__C, Easypost_PostageLabel_Label_URL__c FROM Case LIMIT 1];
        EasyPostTitleUpdateAPI.updateTitle(titleCase.Auction_Number_Searchable__c, 'integration@acvauctions.com', 'htttps://www.testurl.com', '420691142');
        System.assertEquals('htttps://www.testurl.com',[SELECT Id, Auction_Number_Searchable__c, Easypost_Tracker__C, Easypost_PostageLabel_Label_URL__c FROM Case LIMIT 1].Easypost_PostageLabel_Label_URL__C);
    }
    
    @isTest
    public static void testExceptions(){
        RestResponse res = new RestResponse();
        RestContext.response = res;
        Case titleCase = [SELECT Id, Auction_Number_Searchable__c, Easypost_Tracker__C, Easypost_PostageLabel_Label_URL__c FROM Case LIMIT 1];
        EasyPostTitleUpdateAPI.updateTitle(titleCase.Auction_Number_Searchable__c, '', 'htttps://www.testurl.com', '420691142');
        EasyPostTitleUpdateAPI.updateTitle(titleCase.Auction_Number_Searchable__c, 'invalid@invalid.com', 'htttps://www.testurl.com', '420691142');
        EasyPostTitleUpdateAPI.updateTitle(titleCase.Auction_Number_Searchable__c, 'integration@acvauctions.com', '', '420691142');
        EasyPostTitleUpdateAPI.updateTitle(titleCase.Auction_Number_Searchable__c, 'integration@acvauctions.com', 'htttps://www.testurl.com', '');

    }
}