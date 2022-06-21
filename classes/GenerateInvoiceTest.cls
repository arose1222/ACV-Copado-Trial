@isTest
public class GenerateInvoiceTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        Account acct = TestUtility.createAccount();
        insert acct;
    }   

    @IsTest
    static void createInvoice(){
        Account testAcct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        String invoiceNumber = '1';
        ServiceTerritory testST = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType assetWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_Id__c = 'verification' LIMIT 1 ];
        
        Boolean errorThrown = FALSE;
        String errorMsg;
        Test.startTest();
            WorkOrder createdWork = FSLTestUtility.createWorkOrder( assetWT, testAcct, '14209', testST, null );
            insert createdWork;

            WorkOrderLineItem createLineItem = FSLTestUtility.createWorkOrderLineItem( createdWork, assetWT, 0 );
            createLineItem.External_Invoice_Id__c = invoiceNumber;

            insert createLineItem;
        Test.stopTest();    

        List<Invoice__c> invoiceLst = [ SELECT Id, Name, Invoice_Id__c, Account__c, ( SELECT Id FROM Work_Order_Line_Items__r ) FROM Invoice__c ];
        Integer invoiceCount = invoiceLst.size();

        System.assertEquals( 1, invoiceCount, 'There was an incorrect number of Invoices generated: ' + invoiceCount );

        Invoice__c selectedInvoice = invoiceLst[0];
        
        System.assertEquals( invoiceNumber, selectedInvoice.Name, 'The Invoice Name was not correct' );
        System.assertEquals( invoiceNumber, selectedInvoice.Invoice_Id__c, 'The Invoice Id was not correct' );
        System.assertEquals( testAcct.Id, selectedInvoice.Account__c, 'The Invoice Account was not correct' );
        System.assertEquals( 1, selectedInvoice.Work_Order_Line_Items__r.size(), 'The Invoice had an unexpected amount of work order line items' );
    }   
}