@IsTest
public class RescheduleServiceApptControllerTest {

    static DateTime now = System.now();

    @TestSetup
    static void createData() {
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        FSL.GlobalAPIS.addStatusTransition( 'Scheduled', 'Cannot Complete' );
        Account a = TestUtility.createAccount();
        insert a;

        Contact c = TestUtility.createContact( a );
        insert c;

        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209'  );

        ServiceResource sr = FSLTestUtility.makeResourceData();

        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.id, ServiceTerritoryId = st.id, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P',
            OperatingHoursId = optHour.Id
        );
        insert stm;

        WorkType inspectionWT = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];
        WorkOrder wo = new WorkOrder(
            AccountId = a?.Id,
            WorkTypeId = inspectionWT?.Id,
            Status = 'Cannot Complete',
            Inspection_Number_of_Vehicles__c = 1);
        
        insert wo;

        ServiceAppointment sa = [SELECT Id, Status, SchedStartTime, Cannot_Complete_Reason__c FROM ServiceAppointment WHERE AccountId = :a.Id LIMIT 1];

        sa.SchedStartTime = DateTime.newInstanceGmt(now.year(), now.month(), now.day(), 12, 0, 0);
        sa.SchedEndTime = sa.SchedStartTime.addMinutes(30);
        sa.Original_Due_Date__c = sa.SchedStartTime;
        sa.Status = 'Scheduled';
        sa.Cannot_Complete_Reason__c = 'Insufficient time to complete';
        sa.Completed_Canceled_Notes__c = 'Test';
        update sa;

        AssignedResource ar = new AssignedResource(ServiceResourceId=sr.Id, ServiceAppointmentId=sa.Id);
        insert ar;
    }

    @isTest
    static void createRescheduledSANoWOLIs(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceAppointment sa = [SELECT Id, Status, SchedStartTime, Completed_Canceled_Notes__c, Cannot_Complete_Reason__c, Work_Order__c, Current_Service_Resource__c, 
        WorkTypeId, Has_Been_Rescheduled__c, Reschedule__c, Original_Due_Date__c FROM ServiceAppointment WHERE AccountId = :acc.Id LIMIT 1];
        
        

        List<WorkOrderLineItem> wolis = RescheduleServiceAppointmentController.getWOLIsForServiceAppointment(sa.Work_Order__c);
        
        String serApptJSON = '{"Id":"'+ sa.Id + 
                                '","Work_Order__c":"'+ sa.Work_Order__c + 
                                '","WorkTypeId":"'+ sa.WorkTypeId + 
                                '","Reschedule__c":null' + 
                                ',"Current_Service_Resource__c":"'+ sa.Current_Service_Resource__c + 
                                '","Has_Been_Rescheduled__c":false' + 
                                ',"Cannot_Complete_Reason__c":"'+ sa.Cannot_Complete_Reason__c +
            					'","Original_Due_Date__c":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
            												'T12:00:00.000Z' +
                                '","SchedStartTime":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
            											'T12:00:00.000Z' +
                                '","FSL__GanttColor__c":"#FF0000"}';
        Test.startTest();
        RescheduleServiceAppointmentController.rescheduleAppointment(serApptJSON, wolis);
        Test.stopTest();
        
        List<Reschedule_History__c> resHis = [SELECT Id, Rescheduled_To__c, Rescheduled_From__c FROM Reschedule_History__c];
        System.assertEquals(1, resHis.size(), 'The wrong number of Reschedule_History__c have been found.');
        System.assertEquals(sa.Id, resHis[0].Rescheduled_From__c, 'The Reschedule_History__c is not linked to the proper SA.');
    }
    
    @isTest
    static void createRescheduledSAWithWOLIs(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceAppointment sa = [SELECT Id, Status, SchedStartTime, Completed_Canceled_Notes__c, Cannot_Complete_Reason__c, Work_Order__c, Current_Service_Resource__c, 
        WorkTypeId, Has_Been_Rescheduled__c, Reschedule__c, Original_Due_Date__c FROM ServiceAppointment WHERE AccountId = :acc.Id LIMIT 1];
        
        List<WorkOrderLineItem> wolisToInsert = new List<WorkOrderLineItem>();
        for(Integer i = 0; i < 5; i++) {
            WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId=sa.Work_Order__c, WorkTypeId=sa.WorkTypeId);
            wolisToInsert.add(woli);
        }
        Test.startTest();
        insert wolisToInsert;
		
        List<WorkOrderLineItem> wolis = RescheduleServiceAppointmentController.getWOLIsForServiceAppointment(sa.Work_Order__c);
        
        String serApptJSON = '{"Id":"'+ sa.Id + 
                                '","Work_Order__c":"'+ sa.Work_Order__c + 
                                '","WorkTypeId":"'+ sa.WorkTypeId + 
                                '","Reschedule__c":null' + 
                                ',"Current_Service_Resource__c":"'+ sa.Current_Service_Resource__c + 
                                '","Has_Been_Rescheduled__c":false' + 
                                ',"Cannot_Complete_Reason__c":"'+ sa.Cannot_Complete_Reason__c +
            					'","Original_Due_Date__c":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
            												'T12:00:00.000Z' +
                                '","SchedStartTime":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
                                                            'T12:00:00.000Z' +
                                '","FSL__GanttColor__c":"#FF0000"}';
        
        RescheduleServiceAppointmentController.rescheduleAppointment(serApptJSON, wolis);
        Test.stopTest();
        
        List<Reschedule_History__c> resHis = [SELECT Id, Rescheduled_To__c, Rescheduled_From__c FROM Reschedule_History__c];
        System.assertEquals(1, resHis.size(), 'The wrong number of Reschedule_History__c have been found.');
        System.assertEquals(sa.Id, resHis[0].Rescheduled_From__c, 'The Reschedule_History__c is not linked to the proper SA.');
        
        ServiceAppointment newSA = [SELECT Id, Work_Order__c FROM ServiceAppointment WHERE Id=:resHis[0].Rescheduled_To__c];
        WorkOrder newWO = [SELECT Id, (SELECT Id FROM WorkOrderLineItems) FROM WorkOrder WHERE Id=:newSA.Work_Order__c];
        System.assertEquals(5, newWO.WorkOrderLineItems.size(), 'The wrong number of Work Order Line Items were copied over.');
    }
    
    @isTest
    static void createRescheduledSAWithResourcePreferences(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceAppointment sa = [SELECT Id, Status, SchedStartTime, Completed_Canceled_Notes__c, Cannot_Complete_Reason__c, Work_Order__c, Current_Service_Resource__c, 
        WorkTypeId, Has_Been_Rescheduled__c, Reschedule__c,Most_Recent_Service_Resource__c, Original_Due_Date__c FROM ServiceAppointment WHERE AccountId = :acc.Id LIMIT 1];
        
        ResourcePreference resPref = new ResourcePreference(RelatedRecordId=sa.Work_Order__c, ServiceResourceId=sa.Most_Recent_Service_Resource__c);
        Test.startTest();
        insert resPref;
		
        List<WorkOrderLineItem> wolis = RescheduleServiceAppointmentController.getWOLIsForServiceAppointment(sa.Work_Order__c);
        
        String serApptJSON = '{"Id":"'+ sa.Id + 
                                '","Work_Order__c":"'+ sa.Work_Order__c + 
                                '","WorkTypeId":"'+ sa.WorkTypeId + 
                                '","Reschedule__c":null' + 
                                ',"Current_Service_Resource__c":"'+ sa.Current_Service_Resource__c + 
                                '","Has_Been_Rescheduled__c":false' + 
                                ',"Cannot_Complete_Reason__c":"'+ sa.Cannot_Complete_Reason__c +
            					'","Original_Due_Date__c":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
            												'T12:00:00.000Z' +
                                '","SchedStartTime":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
                                                            'T12:00:00.000Z' +
                                '","FSL__GanttColor__c":"#FF0000"}';
        
        RescheduleServiceAppointmentController.rescheduleAppointment(serApptJSON, wolis);
        Test.stopTest();
        
        List<Reschedule_History__c> resHis = [SELECT Id, Rescheduled_To__c, Rescheduled_From__c FROM Reschedule_History__c];
        ServiceAppointment newSA = [SELECT Id, Work_Order__c FROM ServiceAppointment WHERE Id=:resHis[0].Rescheduled_To__c];
        WorkOrder newWO = [SELECT Id, (SELECT Id FROM ResourcePreferences) FROM WorkOrder WHERE Id=:newSA.Work_Order__c];
        System.assertEquals(1, newWO.ResourcePreferences.size(), 'The wrong number of Resource Preferences were copied over.');
    }
    
    @isTest
    static void createRescheduledSAWithEmailNotificationSubscription(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ServiceAppointment sa = [SELECT Id, Status, SchedStartTime, Completed_Canceled_Notes__c, Cannot_Complete_Reason__c, Work_Order__c, Current_Service_Resource__c, 
        WorkTypeId, Has_Been_Rescheduled__c, Reschedule__c,Most_Recent_Service_Resource__c, Original_Due_Date__c FROM ServiceAppointment WHERE AccountId = :acc.Id LIMIT 1];
        
		List<Email_Notification_Subscription__c> ensToInsert = new List<Email_Notification_Subscription__c>();
        ensToInsert.add(new Email_Notification_Subscription__c(Service_Appointment__c=sa.Id));
        ensToInsert.add(new Email_Notification_Subscription__c(Work_Order__c=sa.Work_Order__c));
        Test.startTest();
        insert ensToInsert;
		
        List<WorkOrderLineItem> wolis = RescheduleServiceAppointmentController.getWOLIsForServiceAppointment(sa.Work_Order__c);
        
        String serApptJSON = '{"Id":"'+ sa.Id + 
                                '","Work_Order__c":"'+ sa.Work_Order__c + 
                                '","WorkTypeId":"'+ sa.WorkTypeId + 
                                '","Reschedule__c":null' + 
                                ',"Current_Service_Resource__c":"'+ sa.Current_Service_Resource__c + 
                                '","Has_Been_Rescheduled__c":false' + 
                                ',"Cannot_Complete_Reason__c":"'+ sa.Cannot_Complete_Reason__c +
            					'","Original_Due_Date__c":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
            												'T12:00:00.000Z' +
                                '","SchedStartTime":"'+ now.year() + '-' + now.month() + '-' + now.day() + 
                                                            'T12:00:00.000Z' +
                                '","FSL__GanttColor__c":"#FF0000"}';
        
        RescheduleServiceAppointmentController.rescheduleAppointment(serApptJSON, wolis);
        Test.stopTest();
        
        List<Reschedule_History__c> resHis = [SELECT Id, Rescheduled_To__c, Rescheduled_From__c FROM Reschedule_History__c];
        ServiceAppointment newSA = [SELECT Id, Work_Order__c, (SELECT Id FROM Email_Notification_Subscriptions__r) FROM ServiceAppointment WHERE Id=:resHis[0].Rescheduled_To__c];
        WorkOrder newWO = [SELECT Id, (SELECT Id FROM Email_Notification_Subscriptions__r) FROM WorkOrder WHERE Id=:newSA.Work_Order__c];
        
        System.assertEquals(1, newWO.Email_Notification_Subscriptions__r.size(), 'The wrong number of Email_Notification_Subscription__c were copied over to the Work Order.');
        System.assertEquals(1, newSA.Email_Notification_Subscriptions__r.size(), 'The wrong number of Email_Notification_Subscription__c were copied over to the Service Appointment.');
    }
}