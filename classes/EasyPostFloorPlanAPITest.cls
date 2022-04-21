@IsTest
public class EasyPostFloorPlanAPITest {

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

    static EasyPostFloorPlanAPI.AddressStruct getAddress() {
        EasyPostFloorPlanAPI.AddressStruct address = new EasyPostFloorPlanAPI.AddressStruct();
        address.addressName = 'Buffalo Location';
        address.city = 'Buffalo';
        address.country = 'US';
        address.postalCode = '14302';
        address.state = 'NY';
        address.street = '101 Main Street';
        
        return address;
    }

    @IsTest
    static void callValid(){

        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() );
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Only one case exists from TestSetup
        Case titleCase = [ SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1 ];

        Test.startTest();

            EasyPostFloorPlanAPI.generateLabel( titleCase.Auction_Number_Searchable__c, UserInfo.getUserEmail(), getAddress() );

        Test.stopTest();
        
    }

    @IsTest
    static void callValidAlternateAddress(){

        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() );
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Only one account exists from TestSetup
        Account testAcct = [ SELECT Id, BillingStreet, BillingCity, BillingState, BillingPostalCode FROM Account LIMIT 1 ];
        testAcct.Legal_Street__c = testAcct.BillingStreet;
        testAcct.Legal_City__c = testAcct.BillingCity;
        testAcct.Legal_State__c = testAcct.BillingState;
        testAcct.Legal_Zip_Code__c = testAcct.BillingPostalCode;
        testAcct.BillingStreet = null;
        testAcct.BillingCity = null;
        testAcct.BillingState = null;
        testAcct.BillingPostalCode = null;
        update testAcct;
        
        // Only one case exists from TestSetup
        Case titleCase = [ SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1 ];

        Test.startTest();

            EasyPostFloorPlanAPI.generateLabel( titleCase.Auction_Number_Searchable__c, UserInfo.getUserEmail(), getAddress() );

        Test.stopTest();
        
    }

    @IsTest
    static void callInvalidAddressEasyPost(){

        Test.setMock( HttpCalloutMock.class, new TestEasyPostComponentController.EasyPostMockCalloutBadCall() );
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Only one case exists from TestSetup
        Case titleCase = [ SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1 ];

        Test.startTest();

            EasyPostFloorPlanAPI.AddressStruct testAddress = getAddress();
            testAddress.street = null;
            EasyPostFloorPlanAPI.generateLabel( titleCase.Auction_Number_Searchable__c, UserInfo.getUserEmail(), testAddress );

            System.assert( RestContext.response.responseBody.toString().contains( 'One of the required Address parameters is missing:' ), 'The expected error was not provided. The provided error is as followed: ' + RestContext.response.responseBody.toString() );

        Test.stopTest();
        
    }

    @IsTest
    static void callInvalidEasyPost(){

        Test.setMock( HttpCalloutMock.class, new TestEasyPostComponentController.EasyPostMockCalloutBadCall() );
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Only one case exists from TestSetup
        Case titleCase = [ SELECT Id, Auction_Number_Searchable__c FROM Case LIMIT 1 ];

        Test.startTest();

            EasyPostFloorPlanAPI.generateLabel( titleCase.Auction_Number_Searchable__c, UserInfo.getUserEmail(), getAddress() );

            System.assert( RestContext.response.responseBody.toString().contains( 'No STANDARD_OVERNIGHT or PRIORITY_OVERNIGHT Available' ), 'The expected error was not provided. The provided error is as followed: ' + RestContext.response.responseBody.toString() );

        Test.stopTest();
        
    }

    @IsTest
    static void callInvalidRecord(){

        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() );
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();

            EasyPostFloorPlanAPI.generateLabel( '007', UserInfo.getUserEmail(), getAddress() );

            System.assert( RestContext.response.responseBody.toString().contains( 'There was an issue trying to retrieve a case with the given auction number.' ), 'The expected error was not provided. The provided error is as followed: ' + RestContext.response.responseBody.toString() );

        Test.stopTest();
        
    }

    @IsTest
    static void callInvalidDupeRecords(){

        Test.setMock( HttpCalloutMock.class, new EasyPostMockCalloutGoodCall() );
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Case titleCase = [ SELECT Id, Auction_Number_Searchable__c, RecordTypeId, Status, isClosed FROM Case LIMIT 1 ];
        
        // Gather up existing records for duplicate Case
        Account acct = [ SELECT Id FROM Account LIMIT 1 ];
        Contact con = [ SELECT Id FROM Contact LIMIT 1 ];
        Auction__c auct = [ SELECT Id FROM Auction__c LIMIT 1 ];
        Case titleCaseDup = TestUtility.createTitleCase( auct, acct, con );
        insert titleCaseDup;

        final Id TITLE_CASE_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get( 'Title_Information' ).getRecordTypeId();

        Test.startTest();

            EasyPostFloorPlanAPI.generateLabel( titleCase.Auction_Number_Searchable__c, UserInfo.getUserEmail(), getAddress() );

            System.assert( RestContext.response.responseBody.toString().contains( 'When attempting to retrieve a single case with the given auction number, 2 cases were located instead' ), 'The expected error was not provided. The provided error is as followed: ' + RestContext.response.responseBody.toString() );

        Test.stopTest();
        
    }

    public class EasyPostMockCalloutGoodCall implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            return TestEasyPostComponentController.processGoodResponse( req );    
        }
    }

}