@isTest
public class InvoiceCancelAPITest {
    private static final string INVOICE_NUM = '1';
    private static final string ZIP = '14209';

    @TestSetup
    static void createTerritory() {
        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', ZIP );
    }

    @IsTest
    static void cancelExistingInvoiceWithItem() {
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );

        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account acctRec = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType assetWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' ];
        
        WorkOrder workRec = FSLTestUtility.createWorkOrder( assetWT, acctRec, ZIP, stRec, null );
        insert workRec;
        WorkOrderLineItem woliRec = FSLTestUtility.createWorkOrderLineItem( workRec, assetWT, 1 );
        woliRec.External_Invoice_Id__c = INVOICE_NUM;
        insert woliRec;

        Test.startTest();
            InvoiceCancelAPI.CancelStruct newCancelRec = new InvoiceCancelAPI.CancelStruct();
            newCancelRec.invoiceId = INVOICE_NUM;

            InvoiceCancelAPI.cancelInvoice( new List<InvoiceCancelAPI.CancelStruct>{ newCancelRec } );
        Test.stopTest();

        system.debug( RestContext.response );

        System.assertEquals( 200, RestContext.response.statusCode, 'The status code resulted in an error when hitting the API' );

        Invoice__c systemInvoice = [ SELECT Id, Status__c FROM Invoice__c LIMIT 1 ];
        System.assertEquals(  'Closed', systemInvoice.Status__c, 'The Invoice was not properly closed as expected' );

        woliRec = [ SELECT Id, Status FROM WorkOrderLineItem LIMIT 1 ];
        System.assertEquals( 'Canceled', woliRec.Status, 'The Work Order Line Item was not properly canceled as expected' );
    }

    @IsTest
    static void cancelExistingInvoice() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account acctRec = [ SELECT Id FROM Account LIMIT 1 ];
        insert CapitalTestUtility.createInvoice( INVOICE_NUM, acctRec.Id );

        Test.startTest();
            InvoiceCancelAPI.CancelStruct newCancelRec = new InvoiceCancelAPI.CancelStruct();
            newCancelRec.invoiceId = INVOICE_NUM;

            InvoiceCancelAPI.cancelInvoice( new List<InvoiceCancelAPI.CancelStruct>{ newCancelRec } );
        Test.stopTest();

        system.debug( RestContext.response );

        System.assertEquals( 200, RestContext.response.statusCode, 'The status code resulted in an error when hitting the API' );

        Invoice__c systemInvoice = [ SELECT Id, Status__c FROM Invoice__c LIMIT 1 ];
        System.assertEquals(  'Closed', systemInvoice.Status__c, 'The Invoice was not properly closed as expected' );
    }

    @IsTest
    static void cancelNoInvoice() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Test.startTest();
            InvoiceCancelAPI.CancelStruct newCancelRec = new InvoiceCancelAPI.CancelStruct();
            newCancelRec.invoiceId = INVOICE_NUM;

            InvoiceCancelAPI.cancelInvoice( new List<InvoiceCancelAPI.CancelStruct>{ newCancelRec } );
        Test.stopTest();

        system.debug( RestContext.response );

        System.assertEquals( 400, RestContext.response.statusCode, 'The status code resulted in an error when hitting the API' );
    }

    @IsTest
    static void cancelMissingOneInvoice() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account acctRec = [ SELECT Id FROM Account LIMIT 1 ];
        insert CapitalTestUtility.createInvoice( INVOICE_NUM, acctRec.Id );

        Test.startTest();
            InvoiceCancelAPI.CancelStruct newCancelRec = new InvoiceCancelAPI.CancelStruct();
            newCancelRec.invoiceId = INVOICE_NUM;

            InvoiceCancelAPI.CancelStruct missingCancelRec = new InvoiceCancelAPI.CancelStruct();
            missingCancelRec.invoiceId = '2';

            InvoiceCancelAPI.cancelInvoice( new List<InvoiceCancelAPI.CancelStruct>{ newCancelRec,missingCancelRec } );
        Test.stopTest();

        system.debug( RestContext.response );

        System.assertEquals( 207, RestContext.response.statusCode, 'The status code resulted in an error when hitting the API' );

        Invoice__c systemInvoice = [ SELECT Id, Status__c FROM Invoice__c LIMIT 1 ];
        System.assertEquals(  'Closed', systemInvoice.Status__c, 'The Invoice was not properly closed as expected' );
    }

    @IsTest
    static void cancelExistingInvoiceWithItemError() {
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account acctRec = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType assetWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' ];
        
        WorkOrder workRec = FSLTestUtility.createWorkOrder( assetWT, acctRec, ZIP, stRec, null );
        insert workRec;
        WorkOrderLineItem woliRec = FSLTestUtility.createWorkOrderLineItem( workRec, assetWT, 1 );
        woliRec.External_Invoice_Id__c = INVOICE_NUM;
        insert woliRec;

        Test.startTest();
            InvoiceCancelAPI.CancelStruct newCancelRec = new InvoiceCancelAPI.CancelStruct();
            newCancelRec.invoiceId = INVOICE_NUM;

            InvoiceCancelAPI.cancelInvoice( new List<InvoiceCancelAPI.CancelStruct>{ newCancelRec } );
        Test.stopTest();

        system.debug( RestContext.response );

        System.assertEquals( 400, RestContext.response.statusCode, 'The status code resulted in an error when hitting the API' );
    }
}