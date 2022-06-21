@isTest
public with sharing class ImportManagerBatchTest {
    private static final String BUFFALO_ST = 'Buffalo';

    private final static String DEALER_ID = '4538u75632d1';

    private static Integer IMPORT_BATCH_SIZE {
        get {
            if ( IMPORT_BATCH_SIZE == null ) {
                Salesforce_Setting__mdt batchSize = [ SELECT Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Import_Manager_Batch_Size' LIMIT 1 ];
                IMPORT_BATCH_SIZE = Integer.valueOf( batchSize.Value__c );
            }
            return IMPORT_BATCH_SIZE;
        }
        set;
    }

    @TestSetup
    static void makeData(){
        Account a = new Account(Name='test', Dealership_Id__c = DEALER_ID, legal_Name__c='test', dealer_type__c='1' );
        insert a;

        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ BUFFALO_ST, '14209' );
    }

    @isTest
    static void testBatchSuccess() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        for ( Integer index = 0; index < IMPORT_BATCH_SIZE; index++ ) {
            assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
            newRec.uuid = ACVUtility.NewGuid();
            newRec.vin = 'V' + index;
            newRec.make = 'Hyundai';
            newRec.model = 'Tucson';
            newRec.color = 'Yellow';
            newRec.acctId = DEALER_ID;
            newRec.stockNumber = 'SN' + index;
            newRec.inspectiontype = 'inspection';
            newRec.address = index + ' Main Street, Buffalo, NY, 14209';
            newRec.reservePrice = '' + index;
            newRec.titleStatus = 'Status: ' + index;
            newRec.titleWithDealer = 'true';
            newRec.dealerContact = 'Joe Schmo No.: ' + index;
            newRec.residential = 'false';
            newRec.addToRunList = 'false';
            newRec.floorPrice = '' + index;
            newRec.dateInspected = '12/12/19';

            createLineLst.add( newRec );
        }

        Test.startTest();
            Id importJobId =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        Test.stopTest();


        Import_Manager_Job__c  importJob = [SELECT Id, Number_of_Successes__c, Number_of_Failures__c, Import_Status__c, Result__c, (SELECT Id, Name FROM Attachments) FROM Import_Manager_Job__c WHERE Id = :importJobId LIMIT 1];

        System.assert(importJob.Number_of_Successes__c == IMPORT_BATCH_SIZE, 'Expected ' + IMPORT_BATCH_SIZE + ' but actual = ' + importJob.Number_of_Successes__c);
        System.assert(importJob.Number_of_Failures__c == 0, 'Expected 0 but actual = ' + importJob.Number_of_Failures__c);
        System.assert(importJob.Import_Status__c == 'Complete', 'Expected Complete but actual = ' + importJob.Import_Status__c);
        System.assert(importJob.Result__c == 'Success', 'Expected Success but actual = ' + importJob.Result__c);
        System.assert(importJob.Attachments.size() == 1, 'Expected 1 attachment but actual = ' + importJob.Attachments.size());
        System.assert(importJob.Attachments[0].name.contains('success'), 'Expected success file but actual = ' + importJob.Attachments[0].name);
    }



    @isTest
    static void testBatchPartialSuccess() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        for ( Integer index = 0; index < IMPORT_BATCH_SIZE; index++ ) {
            assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
            newRec.uuid = ACVUtility.NewGuid();
            newRec.vin = 'V' + index;
            newRec.make = 'Hyundai';
            newRec.model = 'Tucson';
            newRec.color = 'Yellow';
            newRec.acctId = DEALER_ID;
            newRec.stockNumber = 'SN' + index;
            newRec.inspectiontype = 'inspection';
            newRec.address = index + ' Main Street, Buffalo, NY, 14209';
            newRec.reservePrice = '' + index;
            newRec.titleStatus = 'Status: ' + index;
            newRec.titleWithDealer = 'true';
            newRec.dealerContact = 'Joe Schmo No.: ' + index;
            newRec.residential = 'false';
            newRec.addToRunList = 'false';
            newRec.floorPrice = '' + index;
            newRec.dateInspected = '12/12/19';

            createLineLst.add( newRec );
        }

        createLineLst[0].vin = null;

        Test.startTest();
            Id importJobId =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        Test.stopTest();


        Import_Manager_Job__c  importJob = [SELECT Id, Number_of_Successes__c, Number_of_Failures__c, Import_Status__c, Result__c, (SELECT Id, Name FROM Attachments) FROM Import_Manager_Job__c WHERE Id = :importJobId LIMIT 1];
        System.assert(importJob.Number_of_Successes__c == IMPORT_BATCH_SIZE - 1, 'Expected ' + (IMPORT_BATCH_SIZE - 1) + ' but actual = ' + importJob.Number_of_Successes__c);
        System.assert(importJob.Number_of_Failures__c == 1, 'Expected 1 but actual = ' + importJob.Number_of_Failures__c);
        System.assert(importJob.Import_Status__c == 'Complete', 'Expected Complete but actual = ' + importJob.Import_Status__c);
        System.assert(importJob.Result__c == 'Partial Success', 'Expected Partial Success but actual = ' + importJob.Result__c);
        System.assert(importJob.Attachments.size() == 2, 'Expected 2 attachments but actual = ' + importJob.Attachments.size());
    }

    @isTest
    static void testBatchFailureVinRequired() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
        newRec.uuid = ACVUtility.NewGuid();
        newRec.vin = null;
        newRec.make = 'Hyundai';
        newRec.model = 'Tucson';
        newRec.color = 'Yellow';
        newRec.acctId = DEALER_ID;
        newRec.stockNumber = 'SN';
        newRec.inspectiontype = 'inspection';
        newRec.address = 'Main Street, Buffalo, NY, 14209';
        newRec.reservePrice = '2';
        newRec.titleStatus = 'Status: ';
        newRec.titleWithDealer = 'true';
        newRec.dealerContact = 'Joe Schmo No.: ';
        newRec.residential = 'false';
        newRec.addToRunList = 'false';
        newRec.floorPrice = '3';
        newRec.dateInspected = '12/12/19';

        createLineLst.add( newRec );


        Test.startTest();
            Id importJobId =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        Test.stopTest();


        Import_Manager_Job__c  importJob = [SELECT Id, Number_of_Successes__c, Number_of_Failures__c, Import_Status__c, Result__c, (SELECT Id, Name FROM Attachments) FROM Import_Manager_Job__c WHERE Id = :importJobId LIMIT 1];
        System.assert(importJob.Number_of_Successes__c == 0, 'Expected 0 but actual = ' + importJob.Number_of_Successes__c);
        System.assert(importJob.Number_of_Failures__c == 1, 'Expected 1 but actual = ' + importJob.Number_of_Failures__c);
        System.assert(importJob.Import_Status__c == 'Complete', 'Expected Complete but actual = ' + importJob.Import_Status__c);
        System.assert(importJob.Result__c == 'Failure', 'Expected Failure but actual = ' + importJob.Result__c);
        System.assert(importJob.Attachments.size() == 1, 'Expected 1 attachment but actual = ' + importJob.Attachments.size());
        System.assert(importJob.Attachments[0].name.contains('error'), 'Expected error file but actual = ' + importJob.Attachments[0].name);
    }

    @isTest
    static void testFailureBadAddress() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
        newRec.uuid = ACVUtility.NewGuid();
        newRec.vin = 'V';
        newRec.vin = null;
        newRec.make = 'Hyundai';
        newRec.model = 'Tucson';
        newRec.color = 'Yellow';
        newRec.acctId = DEALER_ID;
        newRec.stockNumber = 'SN';
        newRec.inspectiontype = 'inspection';
        newRec.address = 'Main Street, Suite 60, Buffalo, NY, 14209';
        newRec.reservePrice = '2';
        newRec.titleStatus = 'Status: ';
        newRec.titleWithDealer = 'true';
        newRec.dealerContact = 'Joe Schmo No.: ';
        newRec.residential = 'false';
        newRec.addToRunList = 'false';
        newRec.floorPrice = '3';
        newRec.dateInspected = '12/12/19';

        createLineLst.add( newRec );

        Test.startTest();
            Id importJobId =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        Test.stopTest();


        Import_Manager_Job__c  importJob = [SELECT Id, Number_of_Successes__c, Number_of_Failures__c, Import_Status__c, Result__c, (SELECT Id, Name FROM Attachments) FROM Import_Manager_Job__c WHERE Id = :importJobId LIMIT 1];
        System.assert(importJob.Number_of_Successes__c == 0, 'Expected 0 but actual = ' + importJob.Number_of_Successes__c);
        System.assert(importJob.Number_of_Failures__c == 1, 'Expected 1 but actual = ' + importJob.Number_of_Failures__c);
        System.assert(importJob.Import_Status__c == 'Complete', 'Expected Complete but actual = ' + importJob.Import_Status__c);
        System.assert(importJob.Result__c == 'Failure', 'Expected Failure but actual = ' + importJob.Result__c);
        System.assert(importJob.Attachments.size() == 1, 'Expected 1 attachment but actual = ' + importJob.Attachments.size());
        System.assert(importJob.Attachments[0].name.contains('error'), 'Expected error file but actual = ' + importJob.Attachments[0].name);
    }

    @isTest
    static void testFailureBadDate() {
        Asset_Verification_Owners__mdt avo = [SELECT User_Record_Id__c FROM Asset_Verification_Owners__mdt LIMIT 1];
        User u = [SELECT Id, Name FROM User WHERE Id=:avo.User_Record_Id__c LIMIT 1];

        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
        newRec.uuid = ACVUtility.NewGuid();
        newRec.vin = 'V';
        newRec.vin = null;
        newRec.make = 'Hyundai';
        newRec.model = 'Tucson';
        newRec.color = 'Yellow';
        newRec.acctId = DEALER_ID;
        newRec.stockNumber = 'SN';
        newRec.inspectiontype = 'inspection';
        newRec.address = 'Main Street Suite 60, Buffalo, NY, 14209';
        newRec.reservePrice = '2';
        newRec.titleStatus = 'Status: ';
        newRec.titleWithDealer = 'true';
        newRec.dealerContact = 'Joe Schmo No.: ';
        newRec.residential = 'false';
        newRec.addToRunList = 'false';
        newRec.floorPrice = '3';
        newRec.dateInspected = '12/12/19';
        newRec.earlyStartDate = '#N/A';
        newRec.dueDate = '12/12/19';

        createLineLst.add( newRec );

        assignmentManagerCreateWorkLinesCont.jsonVin newRec2 = new assignmentManagerCreateWorkLinesCont.jsonVin();
        newRec2.uuid = ACVUtility.NewGuid();
        newRec2.vin = 'V';
        newRec2.vin = null;
        newRec2.make = 'Hyundai';
        newRec2.model = 'Tucson';
        newRec2.color = 'Yellow';
        newRec2.acctId = DEALER_ID;
        newRec2.stockNumber = 'SN';
        newRec2.inspectiontype = 'inspection';
        newRec2.address = 'Main Street Suite 60, Buffalo, NY, 14209';
        newRec2.reservePrice = '2';
        newRec2.titleStatus = 'Status: ';
        newRec2.titleWithDealer = 'true';
        newRec2.dealerContact = 'Joe Schmo No.: ';
        newRec2.residential = 'false';
        newRec2.addToRunList = 'false';
        newRec2.floorPrice = '3';
        newRec2.dateInspected = '12/12/19';
        newRec2.dueDate = '#N/A';
        newRec2.earlyStartDate = '12/12/19';

        createLineLst.add( newRec2 );
        
        Test.startTest();
        Id importJobId;
        System.runAs(u) {
            importJobId = assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        }
             
        Test.stopTest();

        Import_Manager_Job__c  importJob = [SELECT Id, Number_of_Successes__c, Number_of_Failures__c, Import_Status__c, Result__c, (SELECT Id, Name FROM Attachments) FROM Import_Manager_Job__c WHERE Id = :importJobId LIMIT 1];
        System.assert(importJob.Number_of_Successes__c == 0, 'Expected 0 but actual = ' + importJob.Number_of_Successes__c);
        System.assert(importJob.Number_of_Failures__c == 2, 'Expected 1 but actual = ' + importJob.Number_of_Failures__c);
        System.assert(importJob.Import_Status__c == 'Complete', 'Expected Complete but actual = ' + importJob.Import_Status__c);
        System.assert(importJob.Result__c == 'Failure', 'Expected Failure but actual = ' + importJob.Result__c);
        System.assert(importJob.Attachments.size() == 1, 'Expected 1 attachment but actual = ' + importJob.Attachments.size());
        System.assert(importJob.Attachments[0].name.contains('error'), 'Expected error file but actual = ' + importJob.Attachments[0].name);
    }

    @isTest
    static void testFailureDealerIDRequired() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
        newRec.uuid = ACVUtility.NewGuid();
        newRec.vin = 'V';
        newRec.vin = null;
        newRec.make = 'Hyundai';
        newRec.model = 'Tucson';
        newRec.color = 'Yellow';
        // newRec.acctId = null;
        newRec.stockNumber = 'SN';
        newRec.inspectiontype = 'inspection';
        newRec.address = 'Main Street Buffalo, NY, 14209';
        newRec.reservePrice = '2';
        newRec.titleStatus = 'Status: ';
        newRec.titleWithDealer = 'true';
        newRec.dealerContact = 'Joe Schmo No.: ';
        newRec.residential = 'false';
        newRec.addToRunList = 'false';
        newRec.floorPrice = '3';
        newRec.dateInspected = '12/12/19';

        createLineLst.add( newRec );

        Test.startTest();
            Id importJobId =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        Test.stopTest();


        Import_Manager_Job__c  importJob = [SELECT Id, Number_of_Successes__c, Number_of_Failures__c, Import_Status__c, Result__c, (SELECT Id, Name FROM Attachments) FROM Import_Manager_Job__c WHERE Id = :importJobId LIMIT 1];
        System.assert(importJob.Number_of_Successes__c == 0, 'Expected 0 but actual = ' + importJob.Number_of_Successes__c);
        System.assert(importJob.Number_of_Failures__c == 1, 'Expected 1 but actual = ' + importJob.Number_of_Failures__c);
        System.assert(importJob.Import_Status__c == 'Complete', 'Expected Complete but actual = ' + importJob.Import_Status__c);
        System.assert(importJob.Result__c == 'Failure', 'Expected Failure but actual = ' + importJob.Result__c);
        System.assert(importJob.Attachments.size() == 1, 'Expected 1 attachment but actual = ' + importJob.Attachments.size());
        System.assert(importJob.Attachments[0].name.contains('error'), 'Expected error file but actual = ' + importJob.Attachments[0].name);
    }
}