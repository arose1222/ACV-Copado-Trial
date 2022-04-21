@isTest
public class WorkAPITest {

    // Request Variables
    private final static String WORKAPI_TEST_SINGLE_VALID_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleValidRequest';
    private final static String WORKAPI_TEST_SINGLE_INVALID_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleInvalidRequest';
    private final static String WORKAPI_TEST_MULTI_VALID_REQUEST_RESOURCE_NAME = 'WorkAPITest_MultiValidRequest';
    private final static String WORKAPI_TEST_MULTI_INVALID_REQUEST_RESOURCE_NAME = 'WorkAPITest_MultiInvalidRequest';
    private final static String WORKAPI_TEST_MULTI_MIXED_REQUEST_RESOURCE_NAME = 'WorkAPITest_MultiMixedRequest';
    private final static String WORKAPI_TEST_SINGLE_VALID_UPSERT_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleValidUpsertRequest';
    private final static String WORKAPI_TEST_SINGLE_INVALID_WORKTYPE_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleInvalidWorkTypeRequest';
    private final static String WORKAPI_TEST_SINGLE_VALID_GET_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleValidGetRequest';
    private final static String WORKAPI_TEST_SINGLE_INVALID_GET_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleInvalidGetRequest';
    private final static String WORKAPI_TEST_TRUE_360_REQUEST_RESOURCE_NAME = 'WorkAPITest_TRUE360Request';
    private final static String WORKAPI_TEST_SINGLEWO_SINGLEWOLI_VALID_REQUEST_RESOURCE_NAME = 'WorkAPITest_SingleWoSingleWoliRequest';
    private final static String WORKAPI_TEST_MULTI_WOLI_DATE_REQUEST_RESOURCE_NAME = 'WorkAPITest_MultiWOLIDateRequest';
    private final static String WORKAPI_TEST_BAD_DATE_DATA_REQUEST_RESOURCE_NAME = 'WorkAPITest_BadDateDataRequest';
    private final static String WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_REQUEST_RESOURCE_NAME = 'WorkAPITest_BadDateDataWithExistingDataRequest';
    private final static String WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_WITH_OTHER_WOLIS_REQUEST_RESOURCE_NAME = 'WorkAPITest_BadDateDataWithExistingDataOtherWolisRequest';

    // Response Variables
    private final static String WORKAPI_TEST_SINGLE_VALID_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleValidReturn';
    private final static String WORKAPI_TEST_SINGLE_INVALID_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleInvalidReturn';
    private final static String WORKAPI_TEST_MULTI_VALID_RETURN_RESOURCE_NAME = 'WorkAPITest_MultiValidReturn';
    private final static String WORKAPI_TEST_MULTI_INVALID_RETURN_RESOURCE_NAME = 'WorkAPITest_MultiInvalidReturn';
    private final static String WORKAPI_TEST_MULTI_MIXED_RETURN_RESOURCE_NAME = 'WorkAPITest_MultiMixedReturn';
    private final static String WORKAPI_TEST_SINGLE_VALID_UPSERT_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleValidUpsertReturn';
    private final static String WORKAPI_TEST_SINGLE_INVALID_WORKTYPE_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleInvalidWorkTypeReturn';
    private final static String WORKAPI_TEST_SINGLE_VALID_GET_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleValidGetReturn';
    private final static String WORKAPI_TEST_SINGLE_INVALID_GET_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleInvalidGetReturn';
    private final static String WORKAPI_TEST_SINGLE_GET_NO_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleNoGetReturn';
    private final static String WORKAPI_TEST_TRUE_360_RETURN_RESOURCE_NAME = 'WorkAPITest_TRUE360Return';
    private final static String WORKAPI_TEST_SINGLEWO_SINGLEWOLI_VALID_RETURN_RESOURCE_NAME = 'WorkAPITest_SingleWoSingleWoliReturn';
    private final static String WORKAPI_TEST_MULTI_WOLI_DATE_RETURN_RESOURCE_NAME = 'WorkAPITest_MultiWOLIDateReturn';
    private final static String WORKAPI_TEST_BAD_DATE_DATA_RETURN_RESOURCE_NAME = 'WorkAPITest_BadDateDataReturn';
    private final static String WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_RETURN_RESOURCE_NAME = 'WorkAPITest_BadDateDataWithExistingDataReturn';
    private final static String WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_WITH_OTHER_WOLIS_RETURN_RESOURCE_NAME = 'WorkAPITest_BadDateDataWithExistingDataOtherWolisReturn';

    // Map of Request to Responses
    private final static Map<String, String> WORKAPI_TEST_RESOURCE_MAP = new Map<String, String>{
        WORKAPI_TEST_SINGLE_VALID_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLE_VALID_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_SINGLE_INVALID_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLE_INVALID_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_MULTI_VALID_REQUEST_RESOURCE_NAME => WORKAPI_TEST_MULTI_VALID_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_MULTI_INVALID_REQUEST_RESOURCE_NAME => WORKAPI_TEST_MULTI_INVALID_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_MULTI_MIXED_REQUEST_RESOURCE_NAME => WORKAPI_TEST_MULTI_MIXED_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_SINGLE_VALID_UPSERT_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLE_VALID_UPSERT_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_SINGLE_INVALID_WORKTYPE_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLE_INVALID_WORKTYPE_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_SINGLE_VALID_GET_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLE_VALID_GET_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_SINGLE_INVALID_GET_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLE_INVALID_GET_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_TRUE_360_REQUEST_RESOURCE_NAME => WORKAPI_TEST_TRUE_360_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_SINGLEWO_SINGLEWOLI_VALID_REQUEST_RESOURCE_NAME => WORKAPI_TEST_SINGLEWO_SINGLEWOLI_VALID_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_MULTI_WOLI_DATE_REQUEST_RESOURCE_NAME => WORKAPI_TEST_MULTI_WOLI_DATE_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_BAD_DATE_DATA_REQUEST_RESOURCE_NAME => WORKAPI_TEST_BAD_DATE_DATA_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_REQUEST_RESOURCE_NAME => WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_RETURN_RESOURCE_NAME,
        WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_WITH_OTHER_WOLIS_REQUEST_RESOURCE_NAME => WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_WITH_OTHER_WOLIS_RETURN_RESOURCE_NAME
    };

    @TestSetup
    static void createTerritory() {
        Account a = TestUtility.createAccount();
        a.Dealership_Id__c = '1';
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        Affiliation__c aff = new Affiliation__c(
            Account__c=a.id, Contact__c=c.id, Active__c=true, Receive_Push__c = true, 
            Primary_Contact__c = true, Start_Date__c = Date.today().addDays(-7),
            type__c='rep'
        );
        insert aff;

        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
    }

    private static void debug( String restBody ) {
        Integer index = 0;
        system.debug( '----------------------------- Start of Current REST Body -----------------------------' );
        do {
            if ( index + 250 >= restBody.length() ) {
                system.debug( restBody.subString( index, restBody.length() ) );
            } else { 
                system.debug( restBody.subString( index, index + 250 ) );
            }
            index += 250;       
        } while ( index < restBody.length() );
        system.debug( '----------------------------- End of Current REST Body -----------------------------' );
    }

    @IsTest
    static void processOneSuccess(){
        //WORKAPITest.createTerritory();

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_VALID_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_SINGLE_VALID_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            singleReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
        
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    }

    @IsTest
    static void processOneFailure(){
        //WORKAPITest.createTerritory();

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_INVALID_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_SINGLE_INVALID_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            singleReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
        
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    }

    @IsTest
    static void processMultipleSuccesses(){
        //WORKAPITest.createTerritory();

        StaticResource multiRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_MULTI_VALID_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource multiReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_MULTI_VALID_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( multiRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( multiReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            multiReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
    
        System.assertEquals( 2, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    }

    @IsTest
    static void processMultipleFailures(){
        //WORKAPITest.createTerritory();

        StaticResource multiRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_MULTI_INVALID_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource multiReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_MULTI_INVALID_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( multiRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( multiReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            multiReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );

        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
        
    }

    @IsTest
    static void processMixedResults(){
        //WORKAPITest.createTerritory();

        StaticResource multiRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_MULTI_MIXED_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource multiReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_MULTI_MIXED_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( multiRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( multiReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            multiReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
   
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    }

    @IsTest
    static void processUpsertResults(){
        //WORKAPITest.createTerritory();

        final String INCORRECT_VIN = '12345678901234560'; // VIN Different from File

        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id
        );
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = wo.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = INCORRECT_VIN,
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert woli;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_VALID_UPSERT_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_SINGLE_VALID_UPSERT_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            singleReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
   
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );

        System.assertNotEquals( [ SELECT Id, VIN__c FROM WorkOrderLineItem LIMIT 1 ].VIN__c, INCORRECT_VIN, 'The VIN was expected to change after upsert, but it did not' );
        System.assertNotEquals( [ SELECT Id, VIN__c FROM WorkOrderLineItem LIMIT 1 ], null, 'The VIN should not be null after upsert' );
    }

    // Verify New Work Order + 2 Line Combination works even if 1 line is bad data
    // @IsTest
    // static void processMixedNewResultsOnSingleWorkOrder(){
    //     //WORKAPITest.createTerritory();

    //     Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
    //     WorkOrder wo = new WorkOrder(
    //         AccountId = testAcct.Id,
    //         Street = '101 Main Street',
    //         State = 'New York',
    //         City = 'Buffalo',
    //         PostalCode = '14209',
    //         Country = 'US',
    //         WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id,
    //         ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory LIMIT 1 ].Id
    //     );

    //     WorkOrderLineItem woli = new WorkOrderLineItem(
    //         Street = '101 Main Street',
    //         State = 'New York',
    //         City = 'Buffalo',
    //         PostalCode = '14209',
    //         Country = 'US',
    //         VIN__c = '1234567890123456',
    //         WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id,
    //         External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
    //     );

    //     // Active Work Type Filter should restrict this Work Order Line Item from being created
    //     WorkOrderLineItem woli2 = new WorkOrderLineItem(
    //         Street = '101 Main Street',
    //         State = 'New York',
    //         City = 'Buffalo',
    //         PostalCode = '14209',
    //         Country = 'US',
    //         //VIN__c = '1234567890123456',
    //         WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id,
    //         External_Record_guid__c = 'b2045401-f7e0-4f44-b572-0bf872d1fbca'
    //     );

    //     List<FSLWorkProcess.WorkStruct> workStructLst = new List<FSLWorkProcess.WorkStruct>();
    //     FSLWorkProcess.WorkStruct workStruct = new FSLWorkProcess.WorkStruct();
    //     workStruct.workRec = wo;
    //     workStruct.workLineMap = new Map<String,WorkOrderLineItem>();
    //     workStruct.workLineMap.put(woli.External_Record_guid__c,woli);
    //     WorkStruct.workLineMap.put(woli2.External_Record_guid__c,woli2);
    //     workStruct.externalIdsFromIntegration.add(woli.External_Record_Guid__c);
    //     workStruct.externalIdsFromIntegration.add(woli2.External_Record_Guid__c);
    //     workStructLst.add( workStruct );

    //     Test.startTest();
    //         List<FSLWorkProcess.ProcessedWorkStruct> returnLst = FSLWorkProcess.commitWork( workStructLst );
    //     Test.stopTest();
    //     system.debug('ReturnList: ' + returnLst);
    //     Boolean hasSuccess = FALSE;
    //     Boolean hasFailure = FALSE;

    //     for ( FSLWorkProcess.ProcessedWorkStruct pwsRec : returnLst ) {   
    //         if ( pwsRec.hasErrors ) {
    //             hasFailure = TRUE;
    //         } else {
    //             hasSuccess = TRUE;
    //         }
    //     }

    //     System.assert( hasSuccess && hasFailure, 'The ProcessedWorkStruct List was expected to have both successes and failures' );
    //     System.assertEquals( 2, returnLst.size(), 'The ProcessedWorkStruct List was expected to have only 2 return elements' );

    //     System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
    //     System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    // }


    // Check for Type not existing in DB
    @IsTest
    static void processNoWorkTypeFailure(){
        //WORKAPITest.createTerritory();

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_INVALID_WORKTYPE_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_SINGLE_INVALID_WORKTYPE_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            singleReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
        
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    }

    @IsTest
    static void getWorkOrder(){
        //WORKAPITest.createTerritory();

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Origin__c = 'SF REST API',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id
        );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_VALID_GET_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_SINGLE_VALID_GET_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        Test.startTest();
            WorkAPI.getWork( (List<SearchWorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<SearchWorkObject>.class ) ); 
        Test.stopTest();

        String returnBody = RestContext.response.responseBody.toString().trim();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        System.assertEquals( singleReturnRes.body.toString().trim(), returnBody, 'The API Return was different then expected' );
    }

    @IsTest
    static void getNoWorkOrder(){
        //WORKAPITest.createTerritory();

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account testAcct = [ SELECT Id FROM Account LIMIT 1 ];
        WorkOrder wo = new WorkOrder(
            AccountId = testAcct.Id,
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            Origin__c = 'SF REST API',
            WorkTypeId = [ SELECT ID FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id
        );

        WorkOrderLineItem woli = new WorkOrderLineItem(
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :FSLTestUtility.INSPECTION LIMIT 1 ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836'
        );
        insert wo;
        woli.WorkOrderId = wo.Id;
        insert woli;

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_INVALID_GET_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_SINGLE_INVALID_GET_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        Test.startTest();
            WorkAPI.getWork( (List<SearchWorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<SearchWorkObject>.class ) ); 
        Test.stopTest();

        String returnBody = RestContext.response.responseBody.toString().trim();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        System.assertEquals( singleReturnRes.body.toString(), returnBody, 'The API Return was different then expected' );
    }

    @IsTest
    static void getNoValues(){
        //WORKAPITest.createTerritory();

        RestResponse res = new RestResponse();
        RestContext.response = res;

        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLE_GET_NO_RETURN_RESOURCE_NAME LIMIT 1 ];

        Test.startTest();
            WorkAPI.getWork( new List<SearchWorkObject>() ); 
        Test.stopTest();

        String returnBody = RestContext.response.responseBody.toString().trim();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        System.assertEquals( singleReturnRes.body.toString(), returnBody, 'The API Return was different then expected' );
    }

    @IsTest
    static void processTrue360(){
        //WORKAPITest.createTerritory();

        StaticResource singleRequestRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_TRUE_360_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleReturnRes = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_TRUE_360_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( singleRequestRes.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( singleReturnRes.body.toString().trim() );

        // Verify Return from API
        System.assertEquals(
            RestContext.response.responseBody.toString().trim(),
            singleReturnRes.body.toString().trim(),
            'The API return structure and/or data was different then the test expected'
        );
        
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
    }

    //Expectation - If a Work Order has multiple Work Order Line Items,
    //We expect the Work Order Line Item that date is being adjusted to delete the old one and create a new WOLI under a new WO
    @isTest
    static void processMultipleWoliDateUpdate(){
        StaticResource multiWoliRequest = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_MULTI_WOLI_DATE_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource multiWoliReturn = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get(WORKAPI_TEST_MULTI_WOLI_DATE_REQUEST_RESOURCE_NAME) LIMIT 1 ];
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Date earliestStartDate = Date.newInstance(2020, 4, 29);
        Date dueDate = earliestStartDate.addDays(7);
        List<WorkObject> woList = (List<WorkObject>) JSON.deserialize( multiWoliRequest.body.toString(), List<WorkObject>.class );
        FSLWorkProcess.commitWork( FSLWorkProcess.groupWork( woList ) );

        Test.startTest();
            
            woList[0].workDetail.dueDate = String.valueOf(dueDate);
            woList[0].workDetail.earliestStartDate = String.valueOf(earliestStartDate);
            WorkAPI.createWork( woList );

            WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
            WorkAPITest.debug( multiWoliReturn.body.toString().trim() );
    
             // Verify Return from API
             System.assertEquals(
                RestContext.response.responseBody.toString().trim(),
                multiWoliReturn.body.toString().trim(),
                'The API return structure and/or data was different then the test expected'
            );
            
            System.assertEquals( 2, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
            System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
            List<ServiceAppointment> servApptList = [ SELECT Id, DueDate, EarliestStartTime FROM ServiceAppointment ];
        Test.stopTest();
    }

    //Expectation - If dates update on am existing Work Order Line Item where the WO only has 1 Woli,
    //the dates on the service appointment should update as well
    @isTest 
    static void processSingleWoSingleWoliDateUpdate(){
        StaticResource singleWOsingleWOLIRequest = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_SINGLEWO_SINGLEWOLI_VALID_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource singleWOsingleWOLIResponse = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get(WORKAPI_TEST_SINGLEWO_SINGLEWOLI_VALID_REQUEST_RESOURCE_NAME) LIMIT 1 ];
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Date earliestStartDate = Date.newInstance(2020, 4, 29);
        Date dueDate = earliestStartDate.addDays(7);
        List<WorkObject> woList = (List<WorkObject>) JSON.deserialize( singleWOsingleWOLIRequest.body.toString(), List<WorkObject>.class );
        FSLWorkProcess.commitWork( FSLWorkProcess.groupWork( woList ) );

        Test.startTest();
            
            woList[0].workDetail.dueDate = String.valueOf(dueDate);
            woList[0].workDetail.earliestStartDate = String.valueOf(earliestStartDate);
            WorkAPI.createWork( woList );

            WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
            WorkAPITest.debug( singleWOsingleWOLIResponse.body.toString().trim() );
    
             // Verify Return from API
             System.assertEquals(
                RestContext.response.responseBody.toString().trim(),
                singleWOsingleWOLIResponse.body.toString().trim(),
                'The API return structure and/or data was different then the test expected'
            );
            
            System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
            System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
            List<ServiceAppointment> servApptList = [ SELECT Id, DueDate, EarliestStartTime FROM ServiceAppointment ];
            System.assertEquals( 1, servApptList.size() , 'There was an unexpected number of Service Appointments');
            System.assertEquals( dueDate, servApptList[0].DueDate.date(), 'The Service Appointment Due Date does not seem to be correct.');
            System.assertEquals( earliestStartDate, servApptList[0].EarliestStartTime.date(), 'the Service Appointment Earliest Start Date does not seem to be correct.');
        Test.stopTest();
    }
    @isTest
    //Expectation -Creating a WOLI with bad dueDate/EarliestStartDate
    //Confirming WOLI and WO is delete so no data should exist
    static void badDueDateEarliestStartDateTest(){
        //WORKAPITest.createTerritory();

        StaticResource reqJSON = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_BAD_DATE_DATA_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource retJSON = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get( WORKAPI_TEST_BAD_DATE_DATA_REQUEST_RESOURCE_NAME ) LIMIT 1 ];

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            WorkAPI.createWork(
                (List<WorkObject>) JSON.deserialize( reqJSON.body.toString(), List<WorkObject>.class )
            );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( retJSON.body.toString().trim() );

        // Verify Return from API
        // System.assertEquals(
        //     RestContext.response.responseBody.toString().trim(),
        //     retJSON.body.toString().trim(),
        //     'The API return structure and/or data was different then the test expected'
        // );
        
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrder ], 'A Work Order was found. There should be no Work Orders Created' );
        System.assertEquals( 0, [ SELECT Count() FROM WorkOrderLineItem ], 'A Work Order Line Item was found. There should be no Work Order Line Items Created' );
    }
    @isTest
    //Expectation - Creating a WOLI with good data. Go back and updating the woli with bad data
    //Confirming WOLI and WO still exist and data is as before.
    static void badDueDateEarliestStartDateExistingData(){
        StaticResource reqJSON = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource retJSON = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get(WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_REQUEST_RESOURCE_NAME) LIMIT 1 ];
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Date dueDate = Date.newInstance(2020, 4, 29);
        Date earliestStartDate = dueDate.addDays(7);
        List<WorkObject> woList = (List<WorkObject>) JSON.deserialize( reqJSON.body.toString(), List<WorkObject>.class );
        FSLWorkProcess.commitWork( FSLWorkProcess.groupWork( woList ) );
        List<ServiceAppointment> intialServApptList = [ SELECT Id, DueDate, EarliestStartTime FROM ServiceAppointment ];
        Test.startTest();
            
            woList[0].workDetail.dueDate = String.valueOf(dueDate);
            woList[0].workDetail.earliestStartDate = String.valueOf(earliestStartDate);
            WorkAPI.createWork( woList );

            WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
            WorkAPITest.debug( retJSON.body.toString().trim() );
    
             // Verify Return from API
            //  System.assertEquals(
            //     RestContext.response.responseBody.toString().trim(),
            //     retJSON.body.toString().trim(),
            //     'The API return structure and/or data was different then the test expected'
            // );
            
            System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
            System.assertEquals( 1, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
            List<ServiceAppointment> servApptList = [ SELECT Id, DueDate, EarliestStartTime FROM ServiceAppointment ];
            System.assertEquals( 1, servApptList.size() , 'There was an unexpected number of Service Appointments');
            System.assertEquals( intialServApptList[0].DueDate, servApptList[0].DueDate, 'The Service Appointment Due Date does not seem to be correct.');
            System.assertEquals( intialServApptList[0].EarliestStartTime, servApptList[0].EarliestStartTime, 'the Service Appointment Earliest Start Date does not seem to be correct.');
        Test.stopTest();
    }
    @isTest
    //Creating a WOLI that is attached to a WO that has other WOLI’s. Updating the woli with bad data in the sense it should create a new wo/woli and delete the old one
    //Confirming the new one was never created and the old data still exist attached
    static void badDueDateEarliestStartDateExistingDataWithOtherWOLIs(){
        StaticResource reqJSON = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_WITH_OTHER_WOLIS_REQUEST_RESOURCE_NAME LIMIT 1 ];
        StaticResource retJSON = [ SELECT Id, Body FROM StaticResource WHERE Name = :WORKAPI_TEST_RESOURCE_MAP.get(WORKAPI_TEST_BAD_DATE_DATA_WITH_EXISTING_DATA_WITH_OTHER_WOLIS_REQUEST_RESOURCE_NAME) LIMIT 1 ];
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Date dueDate = Date.newInstance(2020, 4, 29);
        Date earliestStartDate = dueDate.addDays(7);
        List<WorkObject> woList = (List<WorkObject>) JSON.deserialize( reqJSON.body.toString(), List<WorkObject>.class );
        FSLWorkProcess.commitWork( FSLWorkProcess.groupWork( woList ) );

        Test.startTest();
            woList[0].workDetail.dueDate = String.valueOf(dueDate);
            woList[0].workDetail.earliestStartDate = String.valueOf(earliestStartDate);
            woList.remove(1);
            WorkAPI.createWork( woList );
        Test.stopTest();

        WorkAPITest.debug( RestContext.response.responseBody.toString().trim() );
        WorkAPITest.debug( retJSON.body.toString().trim() );

         // Verify Return from API
        //  System.assertEquals(
        //     RestContext.response.responseBody.toString().trim(),
        //     retJSON.body.toString().trim(),
        //     'The API return structure and/or data was different then the test expected'
        // );
        
        System.assertEquals( 1, [ SELECT Count() FROM WorkOrder ], 'There was an unexpected number of Work Orders' );
        System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected number of Work Orders Line Items' );
        List<ServiceAppointment> servApptList = [ SELECT Id, DueDate, EarliestStartTime FROM ServiceAppointment ];
    }
}