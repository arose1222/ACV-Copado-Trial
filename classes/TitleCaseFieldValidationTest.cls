// TODO: Remove this class along with TitleCaseFieldValidation (trigger handler)
@isTest
public class TitleCaseFieldValidationTest {
    @isTest
    static void bogus(){
    }
    
    /*
    @isTest
    static void insertTestCase1() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase1 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = false, Missing_Notary__c = true, ACV_Titles_External_ID__c='123');

        System.runAs( u ) {
            try {
                insert testCase1;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Incorrect Vehicle Information on Title to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void insertTestCase2() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase2 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'B', Odometer_Discrepancy__c = false, Missing_Notary__c = true, ACV_Titles_External_ID__c='124');
    
        System.runAs( u ) {
            try {
                insert testCase2;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Odometer Discrepancy to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void insertTestCase3() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase3 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'M', Missing_Signature__c = false, Missing_Notary__c = true, ACV_Titles_External_ID__c='125');
        
        System.runAs( u ) {
            try {
                insert testCase3;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Missing Signature to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void insertTestCase4() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase4 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'E', Reassignment_Error__c = false, Missing_Notary__c = true, ACV_Titles_External_ID__c='126');
        
        System.runAs( u ) {
            try {
                insert testCase4;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Reassignment Errors to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void insertTestCase5() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase5 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'D', Write_Overs__c = false, Missing_Notary__c = true, ACV_Titles_External_ID__c='127');
       
        System.runAs( u ) {
            try {
                insert testCase5;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Write-Overs to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void insertTestCase6() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase6 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'G', Reassigned_To_Wrong_Purchaser__c = false, Missing_Notary__c = true, ACV_Titles_External_ID__c='128');
        
        System.runAs( u ) {
            try {
                insert testCase6;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Reassigned to Wrong Purchaser to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void insertTestCase7() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase7 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Damaged_Title__c = true, ACV_Titles_External_ID__c='129');
        
        System.runAs( u ) {
            try {
                insert testCase7;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Please fill out the Title Problem Subset values related to your Primary Problem checkboxes' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }
       

    @isTest
    static void updateTestCase1() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase1 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='129');
        insert testCase1;
        testCase1.Title_Problem_Subset__c = 'B';

        System.runAs( u ) {
            try {
                update testCase1;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Odometer Discrepancy to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void updateTestCase2() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase2 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='131');
        insert testCase2;
        testCase2.Title_Problem_Subset__c = 'K';

        System.runAs( u ) {
            try {
                update testCase2;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Missing Signature to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void updateTestCase3() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase3 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='132');
        insert testCase3;
        testCase3.Title_Problem_Subset__c = 'Q';

        System.runAs( u ) {
            try {
                update testCase3;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Reassignment Errors to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void updateTestCase4() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase4 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='133');
        insert testCase4;
        testCase4.Title_Problem_Subset__c = 'I';

        System.runAs( u ) {
            try {
                update testCase4;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Write-Overs to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }

    @isTest
    static void updateTestCase5() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase5 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='134');
        insert testCase5;
        testCase5.Title_Problem_Subset__c = 'F';

        System.runAs( u ) {
            try {
                update testCase5;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Reassignment Errors to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }
       @isTest
    static void updateTestCase6() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase6 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='135');
        insert testCase6;
        testCase6.Title_Problem_Subset__c = 'U';

        System.runAs( u ) {
            try {
                update testCase6;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains('Your Title Problem Subset values require Missing Lien release to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }
      @isTest
    static void updateTestCase7() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase7 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='136');
        insert testCase7;
        testCase7.Title_Problem_Subset__c = 'V';

        System.runAs( u ) {
            try {
                update testCase7;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset values require Damaged Title to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }
     @isTest
    static void updateTestCase8() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [ SELECT Id FROM Profile WHERE Name='Standard User' ];
        User u = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/New_York',
            UserName=uniqueUserName
        );

        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case testCase8 = new Case(recordTypeId = titlesRecordType, Status = 'Problem', Origin = 'Phone', Title_Problem_Subset__c = 'O', Incorrect_Vehicle_Information_on_Title__c = true, ACV_Titles_External_ID__c='137');
        insert testCase8;
        testCase8.Title_Problem_Subset__c = 'W';

        System.runAs( u ) {
            try {
                update testCase8;
                system.assert( false, 'This message indicates an error was not thrown when expected!' );
            } catch(exception e) {
                system.assert( 
                    e.getMessage().contains( 'Your Title Problem Subset Values require Listing Error to be selected.' ), 
                    'The error message thrown was unexpected: ' + e.getMessage()
                );
            }
        }
    }
*/
}