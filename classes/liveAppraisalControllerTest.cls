@IsTest
public with sharing class liveAppraisalControllerTest {
    
    @TestSetup
    static void createTerritory() {

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );

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
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        ServiceResource sr = FSLTestUtility.makeResourceData();

        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];

        OperatingHours optHour = [ SELECT Id FROM OperatingHours LIMIT 1 ];
        ServiceTerritoryMember stm = new ServiceTerritoryMember(
            ServiceResourceId = sr.id, ServiceTerritoryId = st.id, EffectiveStartDate = DateTime.now().addDays(-1), TerritoryType = 'P',
            OperatingHoursId = optHour.Id
        );
        insert stm;
    }

    @isTest
    static void createLiveAppraisal(){
        ServiceTerritory st = [SELECT id FROM ServiceTerritory LIMIT 1];
        String workOrderJSON = '{"city":"Buffalo","state":"NY","zip":"14203","country":"United States","street":"101 Main Street","NotificationRequest":false,"accountName":"';

        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        workOrderJSON += acct.Name;

        workOrderJSON +='","serviceTerritory":"'+st.Id+'","contact":null,"accountId":"';
        workOrderJSON += acct.Id;
        workOrderJSON += '","WSCount":"0","AVCount":"0","T360Count":"0","date":"';

        workOrderJSON += System.today().year() + '-' + System.today().month() + '-' + System.today().day();

        workOrderJSON += '","time":"Later","notes":"Inspection Notes Here",';

        ServiceResource sr = [SELECT id, relatedRecordId FROM ServiceResource Limit 1];

        workOrderJSON +='"userId":"';
        workOrderJSON += sr.relatedRecordId;
        workOrderJSON += '","SXMCount":"0","BSUCheck":false,"timeSelection":"Live Appraisal","startTime":"12:00:00.000","endTime":"15:00:00.000"}';

        List<String> serviceResourceIds = new List<String>();
        serviceResourceIds.add(sr.Id);
        Test.startTest();
        liveAppraisalController.submitWorkOrders( workOrderJSON, serviceResourceIds );
        Test.stopTest();

        List<ServiceAppointment> saList = new List<ServiceAppointment>([SELECT id, status, Live_Appraisal_Event__c, SchedStartTime FROM ServiceAppointment]);
        System.Assert(saList.size() == 1 , saList.size() + ' service appointments created. Expected 1 to be created');
        System.Assert(saList[0].status == 'Scheduled', 'Expected Service Appointment to have a status of \'Scheduled\', status was ' + saLIst[0].status + ' instead');
        System.Assert(true , saList[0].Live_Appraisal_Event__c + 'Service Appointment is not a Live Appraisal Event.');
        System.assertEquals(DateTime.newInstance(System.date.today(), Time.newInstance(12, 0, 0, 0)), saList[0].SchedStartTime, 'Service Appointment Start Time is incorrect.');
        List<AssignedResource> arList = new List<AssignedResource>([SELECT ServiceResourceId, ServiceAppointmentId FROM AssignedResource]);
        System.Assert(arList.size() == 1, arList.size() + ' assigned resource records created. Expected 1 to be created');
        System.Assert(arList[0].ServiceResourceId == sr.Id, 'Incorrect service resource assigned to service appointment');
        System.Assert(arList[0].ServiceAppointmentId == saList[0].id, 'Service Resource assigned to incorrect Service Appointment');
    }

    @isTest
    static void searchServiceResources(){
        ServiceResource sr = [SELECT id, Name, relatedRecordId FROM ServiceResource Limit 1];
        
		Id [] fixedSearchResults= new Id[1];
       	fixedSearchResults[0] = sr.Id;
       	Test.setFixedSearchResults(fixedSearchResults);
        
        List<LookupSearchResult> returnLst = liveAppraisalController.getServiceResources( sr.Name, new List<String>() );

        System.assertEquals( 1, returnLst.size(), 'The wrong number of Service Resources were returned.' );
    }
}