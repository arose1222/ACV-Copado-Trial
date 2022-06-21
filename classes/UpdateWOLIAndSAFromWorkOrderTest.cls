@isTest
public class UpdateWOLIAndSAFromWorkOrderTest {
    
    @TestSetup
    public static void makeData() {
		FSL.GlobalAPIS.addStatusTransition( 'New', 'Canceled' );
        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        ServiceResource sr = FSLTestUtility.makeResourceData();

        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.id, ServiceTerritoryId = st.id, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P',
            OperatingHoursId = optHour.Id
        );
        insert stm;

        WorkType inspectionWT = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        WorkType dealerWT = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'dealer' LIMIT 1];

        List<WorkOrder> workOrdersToInsert = new List<WorkOrder>();
        workOrdersToInsert.add(new WorkOrder(AccountId = a?.Id,WorkTypeId = inspectionWT?.Id,Status = 'New',Inspection_Number_of_Vehicles__c = 1));
        workOrdersToInsert.add(new WorkOrder(AccountId = a?.Id,WorkTypeId = dealerWT?.Id,Status = 'New'));
        insert workOrdersToInsert;
    }

    @isTest
    static void CancelStandardWorkOrderNoWOLIs() {
        WorkOrder wo = [SELECT Id, Status FROM WorkOrder WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        Test.startTest();
        wo.Status = 'Canceled';
        update wo;
        Test.stopTest();

        wo = [SELECT Id, Status FROM WorkOrder WHERE Id = :wo.Id];
        ServiceAppointment sa = [SELECT Id, Status, When_to_Return__c, Completed_Canceled_Notes__c FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];

        System.assertEquals('Canceled', wo.Status, 'Work Order has the wrong Status.');
        System.assertEquals('Canceled', sa.Status, 'Service Appointment has the wrong Status.');
        System.assertEquals('The Work Order was canceled for this appointment, so the status of the appointment and all Work Order Line Items have been automatically updated to reflect this.', sa.Completed_Canceled_Notes__c, 'Service Appointment has the wrong value for Completed_Canceled_Notes__c.');
        System.assertEquals('Never (Cancel the Work Order)', sa.When_to_Return__c, 'Service Appointment has the wrong value for When_to_Return__c.');
    }

    @isTest
    static void CancelStandardWorkOrderWithWOLIs() {
        WorkOrder wo = [SELECT Id, Status, WorkTypeId FROM WorkOrder WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        List<WorkOrderLineItem> wolisToInsert = new List<WorkOrderLineItem>();
        for(Integer i = 0; i < 5; i++) {
            WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId=wo.Id, WorkTypeId=wo.WorkTypeId, Status='New');
            wolisToInsert.add(woli);
        }

        Test.startTest();
        insert wolisToInsert;
        wo.Status = 'Canceled';
        update wo;
        Test.stopTest();

        wo = [SELECT Id, Status FROM WorkOrder WHERE Id = :wo.Id];
        ServiceAppointment sa = [SELECT Id, Status, When_to_Return__c, Completed_Canceled_Notes__c FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];

        System.assertEquals('Canceled', wo.Status, 'Work Order has the wrong Status.');
        System.assertEquals('Canceled', sa.Status, 'Service Appointment has the wrong Status.');
        System.assertEquals('The Work Order was canceled for this appointment, so the status of the appointment and all Work Order Line Items have been automatically updated to reflect this.', sa.Completed_Canceled_Notes__c, 'Service Appointment has the wrong value for Completed_Canceled_Notes__c.');
        System.assertEquals('Never (Cancel the Work Order)', sa.When_to_Return__c, 'Service Appointment has the wrong value for When_to_Return__c.');
        
        for(WorkOrderLineItem woli : [SELECT Id, Status FROM WorkOrderLineItem]) {
            System.assertEquals('Canceled', woli.Status, 'Work Order Line Item has the wrong Status.');
        }
    }
    
    @isTest
    static void CancelStandardWorkOrderWithCanceledWOLIs() {
        WorkOrder wo = [SELECT Id, Status, WorkTypeId FROM WorkOrder WHERE WorkType.Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        List<WorkOrderLineItem> wolisToInsert = new List<WorkOrderLineItem>();
        for(Integer i = 0; i < 5; i++) {
            String status = Math.mod(i,2) == 0 ? 'Canceled' : 'New';
            WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId=wo.Id, WorkTypeId=wo.WorkTypeId, Status=status);
            wolisToInsert.add(woli);
        }

        Test.startTest();
        insert wolisToInsert;
        wo.Status = 'Canceled';
        update wo;
        Test.stopTest();

        wo = [SELECT Id, Status FROM WorkOrder WHERE Id = :wo.Id];
        ServiceAppointment sa = [SELECT Id, Status, When_to_Return__c, Completed_Canceled_Notes__c FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];

        System.assertEquals('Canceled', wo.Status, 'Work Order has the wrong Status.');
        System.assertEquals('Canceled', sa.Status, 'Service Appointment has the wrong Status.');
        System.assertEquals('The Work Order was canceled for this appointment, so the status of the appointment and all Work Order Line Items have been automatically updated to reflect this.', sa.Completed_Canceled_Notes__c, 'Service Appointment has the wrong value for Completed_Canceled_Notes__c.');
        System.assertEquals('Never (Cancel the Work Order)', sa.When_to_Return__c, 'Service Appointment has the wrong value for When_to_Return__c.');
        
        for(WorkOrderLineItem woli : [SELECT Id, Status FROM WorkOrderLineItem]) {
            System.assertEquals('Canceled', woli.Status, 'Work Order Line Item has the wrong Status.');
        }
    }
    
    @isTest
    static void CancelAsiWorkOrderWithOneWOLIs() {
        WorkOrder wo = [SELECT Id, Status, WorkTypeId FROM WorkOrder WHERE WorkType.Work_Type_Unique_ID__c = 'dealer' LIMIT 1];

        Test.startTest();
        insert new WorkOrderLineItem(WorkOrderId=wo.Id, WorkTypeId=wo.WorkTypeId, Status='New');
        wo.Status = 'Canceled';
        update wo;
        Test.stopTest();

        wo = [SELECT Id, Status FROM WorkOrder WHERE Id = :wo.Id];
        ServiceAppointment sa = [SELECT Id, Status, When_to_Return__c, Completed_Canceled_Notes__c FROM ServiceAppointment WHERE ParentRecordId = :wo.Id LIMIT 1];

        System.assertEquals('Canceled', wo.Status, 'Work Order has the wrong Status.');
        System.assertEquals('Canceled', sa.Status, 'Service Appointment has the wrong Status.');
        System.assertEquals('The Work Order was canceled for this appointment, so the status of the appointment and all Work Order Line Items have been automatically updated to reflect this.', sa.Completed_Canceled_Notes__c, 'Service Appointment has the wrong value for Completed_Canceled_Notes__c.');
        System.assertEquals('Never (Cancel the Work Order)', sa.When_to_Return__c, 'Service Appointment has the wrong value for When_to_Return__c.');
        
        List<WorkOrderLineItem> wolis = [SELECT Id, Status FROM WorkOrderLineItem];
        System.assertEquals(1, wolis.size(), 'Wrong number of Work Order Line Items.');
        System.assertEquals('Canceled', wolis[0].Status, 'Work Order Line Item has the wrong Status.');
    }

}