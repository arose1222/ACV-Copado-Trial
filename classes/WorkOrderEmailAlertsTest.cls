@isTest
public class WorkOrderEmailAlertsTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //need an account
        List<Account> acctList = new List<Account>();
        
        Account acct1 = TestUtility.createAccount('Test1');
        acct1.Dealership_Id__c = '11111';
        acct1.legal_Name__c='Test1';
        acct1.dealer_type__c='1';
        acctList.add(acct1);

        Account acct2 = TestUtility.createAccount('Test2');
        acct2.Dealership_Id__c = '22222';
        acct2.legal_Name__c='Test2';
        acct2.dealer_type__c='1';
        acctList.add(acct2);

        Account acct3 = TestUtility.createAccount('Test3');
        acct3.Dealership_Id__c = '33333';
        acct3.legal_Name__c='Test3';
        acct3.dealer_type__c='1';
        acctList.add(acct3);

        Account acct4 = TestUtility.createAccount('Test4');
        acct4.Dealership_Id__c = '44444';
        acct4.legal_Name__c='Test4';
        acct4.dealer_type__c='1';
        acctList.add(acct4);
        
        Account acct5 = TestUtility.createAccount('Test5');
        acct5.Dealership_Id__c = '55555';
        acct5.legal_Name__c='Test5';
        acct5.dealer_type__c='1';
        acctList.add(acct5);

        insert acctList;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );
        WorkType wt = [ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        
        //need a work order for that account (Account, Priority, Service Territory)
        List<WorkOrder> woList = new List<WorkOrder>();
        woList.add(new WorkOrder(AccountId = acctList[0].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        woList.add(new WorkOrder(AccountId = acctList[1].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        woList.add(new WorkOrder(AccountId = acctList[2].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        woList.add(new WorkOrder(AccountId = acctList[3].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        woList.add(new WorkOrder(AccountId = acctList[3].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        woList.add(new WorkOrder(AccountId = acctList[4].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        woList.add(new WorkOrder(AccountId = acctList[4].Id, ServiceTerritoryId = st.Id, Priority = 'Low', Status = 'New', WorkTypeId = wt.Id));
        insert woList;

        //need some line items
        List<WorkOrderLineItem> woliList = new List<WorkOrderLineItem>();
        woliList.add(new WorkOrderLineItem(WorkOrderId = woList[2].Id, Status = 'New', VIN__c = '1234567890', WorkTypeId = wt.Id));
        woliList.add(new WorkOrderLineItem(WorkOrderId = woList[2].Id, Status = 'New', VIN__c = '0987654321', WorkTypeId = wt.Id));
        insert woliList;

        //need a record of the subscription
        List<Email_Notification_Subscription__c> ensList = new List<Email_Notification_Subscription__c>();
        ensList.add(new Email_Notification_Subscription__c(User__c = UserInfo.getUserId(),Account__c = acctList[0].Id, Email_User_on_Work_Order_Completion__c = true));
        ensList.add(new Email_Notification_Subscription__c(User__c = UserInfo.getUserId(),Account__c = acctList[2].Id, Email_User_on_Work_Order_Completion__c = true));
        ensList.add(new Email_Notification_Subscription__c(User__c = UserInfo.getUserId(),Account__c = acctList[3].Id, Email_User_on_Work_Order_Completion__c = true, Work_Order__c = woList[4].Id));
        ensList.add(new Email_Notification_Subscription__c(User__c = UserInfo.getUserId(),Account__c = acctList[4].Id, Email_User_on_Work_Order_Completion__c = true));
        ensList.add(new Email_Notification_Subscription__c(User__c = UserInfo.getUserId(),Account__c = acctList[4].Id, Email_User_on_Work_Order_Completion__c = true, Work_Order__c = woList[6].Id));
        insert ensList;
    }

    @isTest
    static void workOrderCompletedForAccountWithSubs() {
        //query work order and set status to completed
        WorkOrder wo = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test1' LIMIT 1];
        wo.Status = 'Completed';
        update wo;
        //check that a email notification record has been created
        List<Email_Notification__c> en = [SELECT Id FROM Email_Notification__c];
        System.assertEquals(true, en.size() > 0);
    }

    @isTest
    static void workOrderNotCompleted() {
        //query work order and set status to anything but completed
        WorkOrder wo = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test1' LIMIT 1];
        wo.Status = 'In Progress';
        update wo;
        //make sure that no email notification record has been created
        List<Email_Notification__c> en = [SELECT Id FROM Email_Notification__c];
        System.assertEquals(true, en.size() < 1);
    }

    @isTest
    static void workOrderCompletedForAccountWithNoSubs() {
        //query for work order for the second account
        WorkOrder wo = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test2' LIMIT 1];
        wo.Status = 'Completed';
        update wo;
        //make sure that no email notification record has been created
        List<Email_Notification__c> en = [SELECT Id FROM Email_Notification__c];
        System.assertEquals(true, en.size() < 1);
    }

    @isTest
    static void multipleWorkOrdersUpdated() {
        //get both work orders
        List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test1' OR Account.Name = 'Test2' OR Account.Name = 'Test3'];
        for (WorkOrder w : woList) {
            w.Status = 'Completed';
        }
        update woList;
        //make sure only 2 email notification records were created
        List<Email_Notification__c> en = [SELECT Id FROM Email_Notification__c];
        System.assertEquals(true, en.size() == 2);
    }

    @isTest
    static void workOrderCompletedWithWOLIs() {
        //testing new VIN field in email notification record
        //query for work orders for the third account
        WorkOrder wo = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test3' LIMIT 1];
        wo.Status = 'Completed';
        update wo;
        //check that a email notification record has been created
        List<Email_Notification__c> en = [SELECT Id, Work_Order_VINs__c FROM Email_Notification__c];
        System.assertEquals(true, en.size() > 0);
        System.assertEquals(true, en[0].Work_Order_VINs__c != null);
    }

    @isTest
    static void workOrderCompletedForSpecificWorkOrder() {
        //query for work order for the second account
        List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test4'];
        System.assertEquals(2, woList.size());
        for(WorkOrder wo : woList) {
            wo.Status = 'Completed';
        }
        update woList;
        //make sure that one email notification record has been created for the two work orders
        List<Email_Notification__c> en = [SELECT Id FROM Email_Notification__c];
        System.assertEquals(1, en.size());
    }

    @isTest
    static void workOrderCompletedForSpecificAndGeneralEmailSubscription() {
        //query for work order for the second account
        List<WorkOrder> woList = [SELECT Id, Status FROM WorkOrder WHERE Account.Name = 'Test4' OR Account.Name = 'Test5'];
        System.assertEquals(4, woList.size());
        for(WorkOrder wo : woList) {
            wo.Status = 'Completed';
        }
        update woList;
        //make sure that one email notification record has been created for the two work orders
        List<Email_Notification__c> en = [SELECT Id FROM Email_Notification__c];
        System.assertEquals(3, en.size());
    }
}