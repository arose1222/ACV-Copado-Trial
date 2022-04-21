@isTest
public class AssetVerificationAuditAPITest {
    private static final string INVOICE_NUM = '1';
    private static final string ZIP = '14209';

    @TestSetup
    static void createTerritory() {
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Completed' );
        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', ZIP );

        // User user = [SELECT Id FROM User WHERE Name = 'InspectionDB Integration'];
    }

    @IsTest
    static void updateAssetVerificationRecordsWithOpenLineItem(){
        RestResponse res = new RestResponse();
        RestContext.response = res;

        Account acctRec = [ SELECT Id, Name, Dealership_ID__c FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        WorkType assetWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' ];

        WorkOrder workRec = FSLTestUtility.createWorkOrder( assetWT, acctRec, ZIP, stRec, null );
        insert workRec;
        WorkOrderLineItem woliRec = FSLTestUtility.createWorkOrderLineItem( workRec, assetWT, 1 );
        woliRec.External_Invoice_Id__c = INVOICE_NUM;
        insert woliRec;

        List<AssetVerificationAuditAPI.AuditObject> auditStructLst = new List<AssetVerificationAuditAPI.AuditObject>();
        AssetVerificationAuditAPI.AuditObject auditStruct = new AssetVerificationAuditAPI.AuditObject();
        auditStruct.dealerId = acctRec.Dealership_ID__c;
        auditStruct.earliestStartDate = Date.today().addDays( 30 );
        auditStruct.auditDueDate = Date.today().addDays( 40 );
        auditStructLst.add( auditStruct );

        Test.startTest();
            AssetVerificationAuditAPI.updateAudit( auditStructLst );
        Test.stopTest();

        System.assertEquals( RestContext.response.statusCode, 200, 'The status code resulted in an error when hitting the API' );
    }

    @IsTest
    static void updateAssetVerificationRecordsWithClosedLineItem(){
        User user = [SELECT Id FROM User WHERE Name = 'InspectionDB Integration'];
        System.runAs(user) {

            RestResponse res = new RestResponse();
            RestContext.response = res;

            Account acctRec = [ SELECT Id, Name, Dealership_ID__c FROM Account LIMIT 1 ];
            ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
            WorkType assetWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' ];


            WorkOrder workRec = FSLTestUtility.createWorkOrder( assetWT, acctRec, ZIP, stRec, null );
            insert workRec;
            WorkOrderLineItem woliRec = FSLTestUtility.createWorkOrderLineItem( workRec, assetWT, 1 );
            woliRec.External_Invoice_Id__c = INVOICE_NUM;
            insert woliRec;

            woliRec.Status = 'Sold';
            update woliRec;

            List<AssetVerificationAuditAPI.AuditObject> auditStructLst = new List<AssetVerificationAuditAPI.AuditObject>();
            AssetVerificationAuditAPI.AuditObject auditStruct = new AssetVerificationAuditAPI.AuditObject();
            auditStruct.dealerId = acctRec.Dealership_ID__c;
            auditStruct.earliestStartDate = Date.today().addDays( 30 );
            auditStruct.auditDueDate = Date.today().addDays( 40 );
            auditStructLst.add( auditStruct );

            Test.startTest();
                AssetVerificationAuditAPI.updateAudit( auditStructLst );
            Test.stopTest();


            System.assertEquals( RestContext.response.statusCode, 200, 'The status code resulted in an error when hitting the API' );
            System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected amount of line items in the system' );
        }
    }

    @IsTest
    static void updateAssetVerificationRecordsWithClosedLineItemWithOpenParent(){
        User user = [SELECT Id FROM User WHERE Name = 'InspectionDB Integration'];
        System.runAs(user) {

            RestResponse res = new RestResponse();
            RestContext.response = res;

            Account acctRec = [ SELECT Id, Name, Dealership_ID__c FROM Account LIMIT 1 ];
            ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
            WorkType assetWT = [ SELECT Id, Name, DurationType, EstimatedDuration FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' ];

            List<WorkOrder> woLst = new List<WorkOrder>();
            WorkOrder workRec = FSLTestUtility.createWorkOrder( assetWT, acctRec, ZIP, stRec, null );
            woLst.add(workRec);
            WorkOrder workRec2 = FSLTestUtility.createWorkOrder( assetWT, acctRec, ZIP, stRec, null ); // Grouping Work Order for future line item
            woLst.add(workRec2);
            insert woLst;

            List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();
            WorkOrderLineItem woliRec = FSLTestUtility.createWorkOrderLineItem( workRec, assetWT, 1 );
            woliRec.External_Invoice_Id__c = INVOICE_NUM;
            woliLst.add( woliRec );
            WorkOrderLineItem woliRec2 = FSLTestUtility.createWorkOrderLineItem( workRec2, assetWT, 1 );
            woliRec2.External_Invoice_Id__c = '2';
            woliLst.add( woliRec2 );
            insert woliLst;

            woliRec.Status = 'Sold';
            update woliRec; // This should close out the original Work Order

            workRec = [ SELECT Id, Status FROM WorkOrder WHERE Id = :workRec.Id ];
            System.assertEquals( 'Completed', workRec.Status, 'The work order was not closed as expected' );

            List<AssetVerificationAuditAPI.AuditObject> auditStructLst = new List<AssetVerificationAuditAPI.AuditObject>();
            AssetVerificationAuditAPI.AuditObject auditStruct = new AssetVerificationAuditAPI.AuditObject();
            auditStruct.dealerId = acctRec.Dealership_ID__c;
            auditStruct.earliestStartDate = Date.today().addDays( 30 );
            auditStruct.auditDueDate = Date.today().addDays( 40 );
            auditStructLst.add( auditStruct );

            Test.startTest();
            AssetVerificationAuditAPI.updateAudit( auditStructLst );
            Test.stopTest();

            System.assertEquals( RestContext.response.statusCode, 200, 'The status code resulted in an error when hitting the API' );
            System.assertEquals( 3, [ SELECT Count() FROM WorkOrderLineItem ], 'There was an unexpected amount of line items in the system' );
            System.assertEquals( 2, [ SELECT Count() FROM WorkOrderLineItem WHERE WorkOrderId = :workRec2.Id ], 'The new line item does not have the expected parent' );
        }
    }
}