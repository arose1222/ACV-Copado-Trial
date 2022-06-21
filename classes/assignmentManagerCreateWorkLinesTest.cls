@isTest
public class assignmentManagerCreateWorkLinesTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount('test');
        insert a;
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
        insert new workType(name='Remote Inspection', EstimatedDuration=10, Work_Type_Unique_ID__c = 'Remote Inspection' );
    }

    @IsTest
    static void testFindingAccount(){
        Id [] fixedResults = new Id[1];
        Account account = [select id, name from account limit 1];
        fixedResults.add(account.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = assignmentManagerCreateWorkLinesCont.getAccounts('Acc', selectedIds);

        System.assertEquals(1, results.size());
        System.assertEquals(account.Id, results.get(0).getId());
    }
    

    @IsTest
    static void testCreatingWorkOrderLines(){
        List<Account> aList = [Select id from account];
        List<assignmentManagerCreateWorkLinesCont.jsonVin> newVinList = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();
        assignmentManagerCreateWorkLinesCont.jsonVin inboundLine = new assignmentManagerCreateWorkLinesCont.jsonVin();
        inboundLine.color = 'Red';
        inboundLine.inspectiontype = 'inspection';
        inboundLine.lotId = aList[0].id;
        inboundLine.vin = '12389054327';
        inboundLine.make = 'Saturn';
        inboundLine.model = 'SC2';
        inboundLine.uuid = '734789289432799054890';
        newVinList.add(inboundLine);
        test.startTest();
            assignmentManagerCreateWorkLinesCont.createWorkOrders(JSON.serialize(newVinList));
            System.assert([Select id from WorkOrder].size() == 1, 'More than 1 Work Order Exists');
            System.assert([Select ID from WorkOrderLineItem].size() == 1, 'More than 1 Work Order Line Exists');
            assignmentManagerCreateWorkLinesCont.createWorkOrders(JSON.serialize(newVinList));
            System.assert([Select id from WorkOrder].size() == 1, 'More than 1 Work Order Exists');
            System.assert([Select ID from WorkOrderLineItem].size() == 2, 'More than 2 Work Order Line Exists');
        test.stopTest();
    }

    @IsTest
    static void testAvoidBundleRemoteInspectionWOs(){
        List<Account> aList = [Select id from account];
        final WorkType WORK_TYPE_RI = [ SELECT Id FROM WorkType WHERE Name = 'Remote Inspection' LIMIT 1 ];

        WorkOrder createRemoteWorkOrder = new WorkOrder(
            WorkTypeId = WORK_TYPE_RI.Id,
            AccountId = aList[0].Id
        );
        insert createRemoteWorkOrder;
        
        WorkOrderLineItem createRemoteWorkItem = new WorkOrderLineItem(
            WorkTypeId = WORK_TYPE_RI.Id,
            WorkOrderId = createRemoteWorkOrder.Id
        );
        insert createRemoteWorkItem;

        test.startTest();
            List<assignmentManagerCreateWorkLinesCont.jsonVin> newVinList = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();
            assignmentManagerCreateWorkLinesCont.jsonVin inboundLine = new assignmentManagerCreateWorkLinesCont.jsonVin();
            inboundLine.color = 'Red';
            inboundLine.inspectiontype = 'Remote Inspection';
            inboundLine.lotId = aList[0].id;
            inboundLine.vin = '12389054327';
            inboundLine.make = 'Saturn';
            inboundLine.model = 'SC2';
            inboundLine.uuid = '734789289432799054890';
            newVinList.add(inboundLine);
            assignmentManagerCreateWorkLinesCont.createWorkOrders(JSON.serialize(newVinList));
            System.assert([Select id from WorkOrder].size() == 2, 'More than 2 Work Orders Exists');
            System.assert([Select ID from WorkOrderLineItem].size() == 2, 'More than 2 Work Order Line Exists');
        test.stopTest();
    }

    @IsTest
    static void testAvoidBundleMixedWOsExistingRemote(){
        List<Account> aList = [Select id from account];
        final WorkType WORK_TYPE_RI = [ SELECT Id FROM WorkType WHERE Name = 'Remote Inspection' LIMIT 1 ];

        WorkOrder createRemoteWorkOrder = new WorkOrder(
            WorkTypeId = WORK_TYPE_RI.Id,
            AccountId = aList[0].Id
        );
        insert createRemoteWorkOrder;
        
        WorkOrderLineItem createRemoteWorkItem = new WorkOrderLineItem(
            WorkTypeId = WORK_TYPE_RI.Id,
            WorkOrderId = createRemoteWorkOrder.Id
        );
        insert createRemoteWorkItem;

        test.startTest();
            List<assignmentManagerCreateWorkLinesCont.jsonVin> newVinList = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();
            assignmentManagerCreateWorkLinesCont.jsonVin inboundLine = new assignmentManagerCreateWorkLinesCont.jsonVin();
            inboundLine.color = 'Red';
            inboundLine.inspectiontype = 'inspection';
            inboundLine.lotId = aList[0].id;
            inboundLine.vin = '12389054327';
            inboundLine.make = 'Saturn';
            inboundLine.model = 'SC2';
            inboundLine.uuid = '734789289432799054890';
            newVinList.add(inboundLine);
            assignmentManagerCreateWorkLinesCont.createWorkOrders(JSON.serialize(newVinList));
            System.assert([Select id from WorkOrder].size() == 2, 'More than 2 Work Orders Exists');
            System.assert([Select ID from WorkOrderLineItem].size() == 2, 'More than 2 Work Order Line Exists');
        test.stopTest();
    }

    @IsTest
    static void testAvoidBundleMixedWOsNewRemote(){
        List<Account> aList = [Select id from account];
        final WorkType WORK_TYPE_RI = [ SELECT Id FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1 ];

        WorkOrder createRemoteWorkOrder = new WorkOrder(
            WorkTypeId = WORK_TYPE_RI.Id,
            AccountId = aList[0].Id
        );
        insert createRemoteWorkOrder;
        
        WorkOrderLineItem createRemoteWorkItem = new WorkOrderLineItem(
            WorkTypeId = WORK_TYPE_RI.Id,
            WorkOrderId = createRemoteWorkOrder.Id
        );
        insert createRemoteWorkItem;

        test.startTest();
            List<assignmentManagerCreateWorkLinesCont.jsonVin> newVinList = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();
            assignmentManagerCreateWorkLinesCont.jsonVin inboundLine = new assignmentManagerCreateWorkLinesCont.jsonVin();
            inboundLine.color = 'Red';
            inboundLine.inspectiontype = 'Remote Inspection';
            inboundLine.lotId = aList[0].id;
            inboundLine.vin = '12389054327';
            inboundLine.make = 'Saturn';
            inboundLine.model = 'SC2';
            inboundLine.uuid = '734789289432799054890';
            newVinList.add(inboundLine);
            assignmentManagerCreateWorkLinesCont.createWorkOrders(JSON.serialize(newVinList));
            System.assert([Select id from WorkOrder].size() == 2, 'More than 2 Work Orders Exists');
            System.assert([Select ID from WorkOrderLineItem].size() == 2, 'More than 2 Work Order Line Exists');
        test.stopTest();
    }
    /**
     * the Title of the Import Manager template ContentDocument
     */
    public static final String IMPORT_MANAGER_TEMPLATE_TITLE = 'Import Manager Template';
    /**
     * Gets the downloadable link for the template used in the Import Manager
     * @return  `String` url for the downloadable link
     */
    @AuraEnabled
    public static String getTemplateDownloadLink(){
        List<ContentVersion> cvList = [ SELECT Id FROM ContentVersion WHERE isLatest = true AND ContentDocument.Title = :IMPORT_MANAGER_TEMPLATE_TITLE LIMIT 1 ];
        if( cvList.size() == 0 ) return null;
        return ACVUtility.getContentVersionDownloadableLink( cvList[0].Id );
    }
}