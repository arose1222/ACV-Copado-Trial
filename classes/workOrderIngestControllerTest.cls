@IsTest
public class workOrderIngestControllerTest {
    @TestSetup
    static void createTerritory() {

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Dispatched' );

        Account a = TestUtility.createAccount();
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

        ServiceResource sr = FSLTestUtility.makeResourceData();
        /*
         * insert TestUtility.createUser(p.id);
        User u = [SELECT id, UserName FROM User Limit 1];

        ServiceResource sr = new ServiceResource(Name = u.userName,IsActive = true, RelatedRecordId = u.Id, ResourceType = 'T');
        insert sr;
        */

        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.id, ServiceTerritoryId = st.id, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P',
            OperatingHoursId = optHour.Id
        );
        insert stm;
    }


    @isTest
    static void createSelfAssignment(){

        String json = '{"city":"Buffalo","state":"NY","zip":"14203","country":"United States","street":"101 Main Street","NotificationRequest":false,"accountName":"';

        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        json += acct.Name;

        json +='","serviceTerritory":null,"contact":null,"accountId":"';
        json += acct.Id;
        json += '","WSCount":"1","AVCount":"0","T360Count":"0","date":"';

        json += System.today().year() + '-' + System.today().month() + '-' + System.today().day();

        json += '","time":"ASAP","notes":"Inspection Notes Here",';

        ServiceResource sr = [SELECT id, relatedRecordId FROM ServiceResource Limit 1];

        json +='"userId":"';
        json += sr.relatedRecordId;
        json += '","SXMCount":"0","BSUCheck":false,"timeSelection":"Now"}';

        Test.startTest();
        workOrderIngestController.submitWorkOrders( json, false );
        Test.stopTest();

        List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT id, status FROM ServiceAppointment]);
        System.Assert(saList.size() == 1 , saList.size() + ' service appointments created. Expected 1 to be created');
        System.Assert(saList[0].status == 'Dispatched', 'Expected Service Appointment to have a status of \'Dispatched\', status was ' + saLIst[0].status + ' instead');
        List<AssignedResource> arList = new List<AssignedResource>([SELECT ServiceResourceId, ServiceAppointmentId FROM AssignedResource]);
        System.Assert(arList.size() == 1, arList.size() + ' assigned resource records created. Expected 1 to be created');
        System.Assert(arList[0].ServiceResourceId == sr.Id, 'Incorrect service resource assigned to service appointment');
        System.Assert(arList[0].ServiceAppointmentId == saList[0].id, 'Service Resource assigned to incorrect Service Appointment');

    }

    @isTest
    static void searchContact(){
        Account acct = [ SELECT Id FROM Account LIMIT 1 ];
        Contact cont = [ SELECT Id, Name FROM Contact LIMIT 1 ];

        List<LookupSearchResult> returnLst = workOrderIngestController.getContacts( cont.Name, new List<String>() );

        System.assertEquals( cont.Name, workOrderIngestController.getContactName( cont.Id ), 'The Contact Name was not correctly found' );
    }

    @isTest
    static void saveOffer(){

        Account acc = [SELECT Id FROM Account LIMIT 1];
        WorkType inspectionWT = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];

        WorkOrder workOrder = new WorkOrder(
            AccountId = acc?.Id,
            WorkTypeId = inspectionWT?.Id,
            Status = 'New',
            Priority = 'Low',
            Processing_Offers__c = true,
            Inspection_Number_of_Vehicles__c = 1
        );
        insert workOrder;

        ServiceTerritoryMember stm = [SELECT ServiceResourceId, ServiceTerritoryId FROM ServiceTerritoryMember LIMIT 1];

        ServiceAppointment saRec = [SELECT Id, ServiceTerritoryId FROM ServiceAppointment LIMIT 1];
        saRec.ServiceTerritoryId = stm?.ServiceTerritoryId;
        update saRec;

        Appointment_Offer__c apptOffer = new Appointment_Offer__c(
            Service_Appointment__c = saRec?.Id,
            Service_Resource__c = stm?.ServiceResourceId,

            Start_Time__c = System.now().addDays(1),
            End_Time__c = System.now().addDays(1).addHours(8),
            Scheduled_Start__c = System.now().addDays(1).addHours(4)
        );
        insert apptOffer;

        Test.startTest();
        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
        workOrderIngestController.saveOffer( apptOffer.Id );
        Test.stopTest();

        // Selected_Offer__c
        System.assert([SELECT Id, Selected_Offer__c FROM ServiceAppointment LIMIT 1]?.Selected_Offer__c == apptOffer.Id, 'Service Appointment was not assigned the expected offer');
        System.assert([SELECT Id FROM Inspection_Request__c]?.Id == [SELECT Inspection_Request__c FROM WorkOrder LIMIT 1]?.Inspection_Request__c, 'The SA was not assigned the expecte Inspection Request');

    }

    @isTest
    static void saveOfferNoAvailability(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        WorkType inspectionWT = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1];

        WorkOrder workOrder = new WorkOrder(
            AccountId = acc?.Id,
            WorkTypeId = inspectionWT?.Id,
            Status = 'New',
            Priority = 'Low',
            Processing_Offers__c = true
        );
        insert workOrder;

        Test.startTest();
        workOrderIngestController.saveOfferNoAvailability( workOrder.Id );
        Test.stopTest();

        WorkOrder woRec = [SELECT Id, Processing_Offers__c FROM WorkOrder WHERE Id = :workOrder.Id];
        ServiceAppointment saRec = [SELECT Id, Exclude_from_Optimization__c FROM ServiceAppointment WHERE Work_Order__c = :workOrder.Id];

        system.assert(woRec?.Processing_Offers__c == false, 'Expected Processing_Offers__c to be false');
        system.assert(saRec?.Exclude_from_Optimization__c == false, 'Expected Exclude_from_Optimization__c to be false');

    }

    @isTest
    static void updateWork(){

        String json = '{"city":"Buffalo","state":"NY","zip":"14203","country":"United States","street":"101 Main Street","NotificationRequest":false,"accountName":"';

        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        json += acct.Name;

        json +='","serviceTerritory":null,"contact":null,"accountId":"';
        json += acct.Id;
        json += '","WSCount":"1","AVCount":"0","T360Count":"0","date":"';

        json += System.today().year() + '-' + System.today().month() + '-' + System.today().day();

        json += '","time":"ASAP","notes":"New Inspection Notes",';

        json +='"userId":"';
        json += '","SXMCount":"0","BSUCheck":false,"timeSelection":"Later"}';

        WorkType standardWT = [SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_Id__c = 'inspection'];
        ServiceTerritory servTerrRec = [SELECT Id FROM ServiceTerritory LIMIT 1];
        WorkOrder standardWO = FSLTestUtility.createWorkOrder(standardWT, acct, '14203', servTerrRec, null);
        insert standardWO;

        Test.startTest();
        workOrderIngestController.updateWork( json, standardWO.Id, null, null );
        Test.stopTest();

        WorkOrder updatedWO = [SELECT Id, Special_Instructions_for_VCI__c FROM WorkOrder WHERE Id = :standardWO.Id];

        System.assert(updatedWO.Special_Instructions_for_VCI__c == 'New Inspection Notes');
    }

}