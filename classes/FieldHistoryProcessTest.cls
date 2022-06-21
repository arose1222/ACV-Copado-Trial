@isTest
public class FieldHistoryProcessTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        Account acct = new Account(
            Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'
        );
        insert acct;
        Vehicle__c vech = TestUtility.createVehicle();
        insert vech;
        Contact con = TestUtility.createContact( acct );
        insert con;
        Auction__c auct = TestUtility.createAuction( acct, con, vech );
        insert auct;
    }

    @isTest 
    static void updateAuction(){
        Auction__c auctInfo = [SELECT Id, buy_fee__c FROM Auction__c LIMIT 1];
        auctInfo.buy_fee__c = 500;
        update auctInfo;
        List<Field_History__c> field = [SELECT Id FROM Field_History__c WHERE Auction__c=:auctInfo.Id];
        Decimal expected = 1;
        Decimal actual = field.size();
        System.assertEquals(expected, actual);
    }

    @isTest
    static void createTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        Case caseRecord = new Case(
            AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='123'
        );

        Test.startTest();

            insert caseRecord;

        Test.stopTest();

        List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];

        System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
        System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
    }

    @isTest
    static void updateWorkingTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];
        
        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        
        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='124'
            );
            insert caseRecord;
            
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
            
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
            
            caseRecord.Status = 'Working';
            
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
            
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c, Field__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Working', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        }
    }

    @isTest
    static void updateReceivedTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='125'
            );
            insert caseRecord;
            
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
            
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
            
            caseRecord.Status = 'Received';
            
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
            
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Received', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        }
    }

    @isTest
    static void updateProblemTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            TitleProblemStatus__c tpsCS = new TitleProblemStatus__c(DisableValidation__c=true);
            insert tpsCS;
            
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='126'
            );
            insert caseRecord;
            
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
            
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
            /*
            caseRecord.Status = 'Problem';
            caseRecord.Title_Problem_Subset__c = 'O';
            caseRecord.Incorrect_Vehicle_Information_on_Title__c = TRUE;
            
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
            
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Problem', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        	*/
		}
    }

    @isTest
    static void update48HourNoticeTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];

        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;

        List<Field_History__c> fhLst;
        Case caseRecord;

        System.runAs( testUser ) {

            caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='127'
            );
            insert caseRecord;

            fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];

            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );

            caseRecord.Status = '48 Hour Notice';

        	RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
        }

        fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
        System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
        System.assertEquals( '48 Hour Notice', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
    }

    @isTest
    static void updateReturnTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            TitleProblemStatus__c tpsCS = new TitleProblemStatus__c(DisableValidation__c=true);
            insert tpsCS;
            
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='128'
            );
            insert caseRecord;
            
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
            
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
            /*
            caseRecord.Status = 'Return to Seller';
            
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
            
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Return to Seller', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        	*/
		}
    }

    @isTest
    static void updateSentTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='129'
            );
            insert caseRecord;
            
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
            
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
            
            caseRecord.Status = 'Sent';
            caseRecord.Reason_for_Out_of_Process_Send__c  = 'test';
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
            
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Sent', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        }
    }

    @isTest
    static void updateTitleAtACVUnwoundTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='131'
            );
            insert caseRecord;
    
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
    
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
    
            caseRecord.Status = 'Title at ACV Unwound';
    
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
    
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Title at ACV Unwound', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        }
    }

    @isTest
    static void updateClosedTitleCase() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        UserRole titleManagerRole = [ SELECT Id FROM UserRole WHERE DeveloperName = 'Titles_Manager' LIMIT 1];
        User testUser = TestUtility.createUser();
        testUser.UserRoleId = titleManagerRole.Id;
        insert testUser;
        
        System.runAs(testUser)	{
            Case caseRecord = new Case(
                AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='132'
            );
            insert caseRecord;
            
            List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];
            
            System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
            System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
            
            caseRecord.Status = 'Closed Unwound';
            
            RecordCaseFieldHistory.reset();
            Test.startTest();
            update caseRecord;
            Test.stopTest();
            
            fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
            System.assertEquals( 2, fhLst.size(), 'There was expected to be two Field History Results' );
            System.assertEquals( 'Closed Unwound', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        }
    }

    @isTest
    static void setOverwriteUserId() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com'
        );
        insert u;

        FieldHistoryProcess.overwriteUserId = u.Id;

        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        Case caseRecord = new Case(
            AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='133'
        );

        Test.startTest();

            System.runAs( u ) {
                insert caseRecord;
            }

        Test.stopTest();

        List<Field_History__c> fhLst = [ SELECT Id, New_Value__c, User__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];

        System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
        System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );
        System.assertEquals( u.Id, fhLst[0].User__c, 'The Field History Result was expected to show the test user as the user who made the change' );
    }

    @isTest
    static void processWithEmptyDates() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        Case caseRecord = new Case(
            AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='134'
        );
        insert caseRecord;

        List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];

        System.assertEquals( 1, fhLst.size(), 'There was expected to be one Field History Result' );
        System.assertEquals( 'New', fhLst[0].New_Value__c, 'There was expected to be one Field History Result to capture the Status change' );

        caseRecord.Status = 'Working';

        insert new Field_History__c(
            Case__c = caseRecord.Id, Field__c = 'Status', New_Value__c ='New', Old_Value__c = null
        );

        RecordCaseFieldHistory.reset();
        Test.startTest();
        update caseRecord;
        Test.stopTest();

        fhLst = [ SELECT Id, New_Value__c, CreatedDate FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate DESC ];
        System.assertEquals( 3, fhLst.size(), 'There was expected to be two Field History Results' );

        //fhLst = [ SELECT Id, Next_Change_Time__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ORDER BY CreatedDate ASC ];
        //System.assert( fhLst[0].Next_Change_Time__c != null, 'There was expected to be one Field History Result which captured the Status duration' );
        //System.assert( fhLst[1].Next_Change_Time__c == null, 'The earlier, blank Field History record shouldn\'t have been updated by the logic' );
    }
    
    /**
     * @description Ensure that the field history is not being created for the Record Type we are not tracking.
     * 
     */
    @isTest
    static void testUndefinedRecordType() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Transportation').getRecordTypeId();

        Case caseRecord = new Case(
            AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'Ready-to-Post', ACV_Titles_External_ID__c='124'
        );
        insert caseRecord;

        List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id AND Field__c = 'Status' ];

        System.assertEquals( 0, fhLst.size(), 'There was expected to be one Field History Result' );
    }
 
    @isTest
    static void testDoNotSetOldValueAndSortOrder() {
        List<Account> acctLst = [ SELECT Id FROM Account LIMIT 1 ];

        final Id TITLES_RT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();

        Case caseRecord = new Case(
            AccountId = acctLst[0].Id, RecordTypeId = TITLES_RT, Status = 'New', ACV_Titles_External_ID__c='125', Image_Location__c='s3 image 1'
        );
        insert caseRecord;

        List<Field_History__c> fhLst = [ SELECT Id, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id];

        System.assertEquals( 2, fhLst.size(), 'There was expected to be 2 Field History Results' );
        System.assertEquals( 'New', fhLst[0].New_Value__c, 'Status should be set to New in the New_Value__c field.' );
        System.assertEquals( 's3 image 1', fhLst[1].New_Value__c, 'Image_Location__c should be set to s3 image 1 in the New_Value__c field.' );

        caseRecord.Status = 'Received';
        caseRecord.Image_Location__c= 's3 image 2';

        RecordCaseFieldHistory.reset();
        Test.startTest();
        update caseRecord;
        Test.stopTest();

        fhLst = [ SELECT Id, Old_Value__c, New_Value__c FROM Field_History__c WHERE Case__c = :caseRecord.Id ORDER BY CreatedDate];

        System.assertEquals( 4, fhLst.size(), 'There was expected to be two Field History Results' );
        System.assertEquals( 'New', fhLst[0].New_Value__c, 'Status should be set to New in the New_Value__c field.' );
        System.assertEquals( 's3 image 1', fhLst[1].New_Value__c, 'Image_Location__c should be set to s3 image 1 in the New_Value__c field.' );
        System.assertEquals( 'Received', fhLst[2].New_Value__c, 'Status should be set to Received in the New_Value__c field.' );
        System.assertEquals( 's3 image 2', fhLst[3].New_Value__c, 'Image_Location__c should be set to s3 image 2 in the New_Value__c field.' );
    }

}