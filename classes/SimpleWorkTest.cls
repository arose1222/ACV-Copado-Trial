@isTest
public class SimpleWorkTest {

    // WorkType Names
    private final static String INSPECTION = 'Standard Inspection';
    private final static String ASSET = 'Asset Verification';
    private final static String TRUE_360 = 'True 360';

    @TestSetup
    static void createTerritory() {
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '1';
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

    @IsTest
    static void processWork(){
        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = '1234567890123456';
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = ACVUtility.NewGuid();
        woRec.origin = 'Simple API Test Class';

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.createWork( new List<WorkObject>{ woRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );

        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );
    }

    @IsTest
    static void processExistingWorkWithWOLI(){
        WorkOrder wo = new WorkOrder(
            Street = '101 Main Street',
            City = 'Buffalo',
            State = 'New York',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION ].Id,
            AccountId = [ SELECT Id FROM Account LIMIT 1 ].Id,
            ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory WHERE Name = 'Buffalo' LIMIT 1 ].Id,
            Origin__c = 'SF Test Code'
        );
        insert wo;

        WorkOrderLineItem woli = new WorkOrderLineItem(
            Street = '101 Main Street',
            State = 'New York',
            City = 'Buffalo',
            PostalCode = '14209',
            Country = 'US',
            VIN__c = '12345678901234567',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION ].Id,
            External_Record_guid__c = 'AA97B177-9383-4934-8543-0F91A7A02836',
            WorkOrderId = wo.Id
        );
        insert woli;

        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = '1234567890123456';
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = ACVUtility.NewGuid();
        woRec.origin = 'Simple API Test Class';

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.createWork( new List<WorkObject>{ woRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );

        List<WorkOrder> workOrderList = [SELECT Id, (SELECT Id FROM WorkOrderLineItems) FROM WorkOrder];
        System.assert(workOrderList.size() == 1, 'Expecting 1 (grouped) work order, but actual = ' + workOrderList.size());
        System.assert(workOrderList[0].WorkOrderLineItems.size() == 2, 'Expected 2 line items but actual = ' + workOrderList[0].WorkOrderLineItems.size());
        System.assert(RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );
    }

    @IsTest
    static void processExistingWorkNoWOLI(){
        WorkOrder wo = new WorkOrder(
            Street = '101 Main Street',
            City = 'Buffalo',
            State = 'New York',
            PostalCode = '14209',
            Country = 'US',
            WorkTypeId = [ SELECT Id FROM WorkType WHERE Name = :INSPECTION ].Id,
            AccountId = [ SELECT Id FROM Account LIMIT 1 ].Id,
            ServiceTerritoryId = [ SELECT Id FROM ServiceTerritory WHERE Name = 'Buffalo' LIMIT 1 ].Id,
            Origin__c = 'SF Test Code'
        );
        insert wo;

        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = '1234567890123456';
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = ACVUtility.NewGuid();
        woRec.origin = 'Simple API Test Class';

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.createWork( new List<WorkObject>{ woRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );

        List<WorkOrder> workOrderList = [SELECT Id FROM WorkOrder];
        System.assert(workOrderList.size() == 2, 'Expecting 2 (not grouped) work orders, but actual = ' + workOrderList.size());
        System.assert(RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );
    }

    @IsTest
    static void cancelWorkVinDealer(){
        String uuid = ACVUtility.NewGuid();

        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = '1234567890123456';
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = uuid;
        woRec.origin = 'Simple API Test Class';


        RestResponse res = new RestResponse();
        RestContext.response = res;

        SimpleWork.createWork( new List<WorkObject>{ woRec } );
        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );

        res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.CancelRequest canRec = new SimpleWork.CancelRequest();
            canRec.dealerId = woRec.workDetail.dealerId;
            canRec.vin = woRec.vehicle.vin;

            SimpleWork.cancelWork( new List<SimpleWork.CancelRequest>{ canRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully canceled' ), 'There was an issue with the response not being successful' );
    }

    @IsTest
    static void cancelWorkVinDealerUnsuccessfully(){
        String uuid = ACVUtility.NewGuid();
        String vin = '1234567890123456';

        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = vin;
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = uuid;
        woRec.origin = 'Simple API Test Class';


        RestResponse res = new RestResponse();
        RestContext.response = res;

        SimpleWork.createWork( new List<WorkObject>{ woRec } );
        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );

        WorkOrderLineItem woli = [ SELECT Id, Status FROM WorkOrderLineItem WHERE Vin__c = :vin LIMIT 1 ];
        woli.Status = 'Inspected';
        update woli;

        res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.CancelRequest canRec = new SimpleWork.CancelRequest();
            canRec.dealerId = woRec.workDetail.dealerId;
            canRec.vin = woRec.vehicle.vin;

            SimpleWork.cancelWork( new List<SimpleWork.CancelRequest>{ canRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'This was an issue cancelling some of the records. Please see the return for more information' ), 'There was an issue with the response' );
    }

    @IsTest
    static void cancelWorkUuid(){
        String uuid = ACVUtility.NewGuid();

        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = '1234567890123456';
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = uuid;
        woRec.origin = 'Simple API Test Class';


        RestResponse res = new RestResponse();
        RestContext.response = res;

        SimpleWork.createWork( new List<WorkObject>{ woRec } );
        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );

        res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.CancelRequest canRec = new SimpleWork.CancelRequest();
            canRec.uuid = woRec.uuid;

            SimpleWork.cancelWork( new List<SimpleWork.CancelRequest>{ canRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully canceled' ), 'There was an issue with the response not being successful' );
    }

    @IsTest
    static void cancelWorkUuidUnsuccessfully(){
        String uuid = ACVUtility.NewGuid();
        String vin = '1234567890123456';

        WorkObject woRec = new WorkObject();
        woRec.address = new AddressObject();
        woRec.address.street = '101 Main Street';
        woRec.address.city = 'Buffalo';
        woRec.address.state = 'New York';
        woRec.address.postalCode = '14209';
        woRec.address.country = 'US';
        woRec.vehicle = new VehicleObject();
        woRec.vehicle.vin = vin;
        woRec.workDetail = new InspectionDetails();
        woRec.workDetail.type = 'inspection';
        woRec.workDetail.dealerId = '1';
        woRec.uuid = uuid;
        woRec.origin = 'Simple API Test Class';


        RestResponse res = new RestResponse();
        RestContext.response = res;

        SimpleWork.createWork( new List<WorkObject>{ woRec } );
        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'All records have been successfully processed' ), 'There was an issue with the response not being successful' );

        WorkOrderLineItem woli = [ SELECT Id, Status FROM WorkOrderLineItem WHERE Vin__c = :vin LIMIT 1 ];
        woli.Status = 'Inspected';
        update woli;

        res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            SimpleWork.CancelRequest canRec = new SimpleWork.CancelRequest();
            canRec.uuid = woRec.uuid;

            SimpleWork.cancelWork( new List<SimpleWork.CancelRequest>{ canRec } );
        Test.stopTest();

        debug( RestContext.response.responseBody.toString().trim() );
        System.assert(
            RestContext.response.responseBody.toString().trim().contains( 'This was an issue cancelling some of the records. Please see the return for more information' ), 'There was an issue with the response' );
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
}