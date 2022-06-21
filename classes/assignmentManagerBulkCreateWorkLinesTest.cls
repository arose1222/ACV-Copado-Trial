/**
 * @description Bulk test class for assignmentManagerCreateWorkLinesCont. The class was turned off from the test suite as of 4/22/2022. This test class should still be run whenever changes are made to assignment manager.
 * @author Adam Richbart
 * @since 4/22/2022
 * @group Inspector Dispatch
 */

//@isTest
public with sharing class assignmentManagerBulkCreateWorkLinesTest {
    private static final String BUFFALO_ST = 'Buffalo';

    // WorkType Names
    private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
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

    //@TestSetup
    static void makeData() {
        //TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = new Account(Name='test', Dealership_Id__c = DEALER_ID, legal_Name__c='test', dealer_type__c='1' );
        insert a;

        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ BUFFALO_ST, '14209' );
    }

    //@isTest
    static void createMassRowsWithoutMatchingZip() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        ServiceTerritory st1 = [ SELECT Id, Name FROM ServiceTerritory WHERE Name = :assignmentManagerBulkCreateWorkLinesTest.BUFFALO_ST LIMIT 1 ];

        ServiceResource sr1 = FSLTestUtility.makeResourceData();

        Account testAcctRec = [ SELECT Id FROM Account LIMIT 1 ];
        testAcctRec.OwnerId = sr1.RelatedRecordId;
        update testAcctRec;

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P', OperatingHoursId = optHour.Id );
        insert stm1;

        for ( Integer index = 0; index < IMPORT_BATCH_SIZE; index++ ) {
            assignmentManagerCreateWorkLinesCont.jsonVin newRec = new assignmentManagerCreateWorkLinesCont.jsonVin();
            newRec.uuid = ACVUtility.NewGuid();
            newRec.vin = 'V' + index;
            newRec.make = 'Hyundai';
            newRec.model = 'Tucson';
            newRec.color = 'Yellow';
            newRec.acctId = testAcctRec.Id;
            newRec.stockNumber = 'SN' + index;
            newRec.inspectiontype = 'inspection';
            newRec.address = index + ' Main Street, Buffalo, NY, 14203';

            createLineLst.add( newRec );
        }

        Id checkReturn =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );

        System.assert(checkReturn != null);

    }

    //@isTest
    static void createMassRows() {
        List<assignmentManagerCreateWorkLinesCont.jsonVin> createLineLst = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();

        ServiceTerritory st1 = [ SELECT Id, Name FROM ServiceTerritory WHERE Name = :assignmentManagerBulkCreateWorkLinesTest.BUFFALO_ST LIMIT 1 ];

        ServiceResource sr1 = FSLTestUtility.makeResourceData();

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId = sr1.Id, ServiceTerritoryId = st1.Id, EffectiveStartDate = Date.valueOf('2019-10-1 00:00:00'), EffectiveEndDate = Date.valueOf('2019-11-2 00:00:00'), TerritoryType = 'P', OperatingHoursId = optHour.Id);
        insert stm1;

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
            Id checkReturn =  assignmentManagerCreateWorkLinesCont.processMassRows( JSON.serialize( createLineLst ) );
        Test.stopTest();

        System.assert(checkReturn != null);
    }

    //@isTest
    static void checkErrorService() {
        // Call Error WorkType Ref
        Test.startTest();
            Map<Id, String> errorMap = assignmentManagerCreateWorkLinesCont.errorWorkTypeRefs;
        Test.stopTest();

        //System.assertEquals( errorMap.size(), 43, 'There was an expectation of 43 Work Types in the system' );
    }

}