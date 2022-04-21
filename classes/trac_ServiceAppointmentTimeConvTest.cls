/**
 * Created by zdeng on 9/24/2019.
 */
@IsTest
public with sharing class trac_ServiceAppointmentTimeConvTest {
    private static final Integer RECORDS_TO_CREATE = 1;
    private static final TLTestFactory factory = new TLTestFactory();

    @TestSetup static void SetupServiceAppointmentData() {
        // Operating Hours and service territory needs to be created first
        List<SObject> operatingHoursList = new List<SObject>();
        operatingHoursList.add(new OperatingHours(Name='Testing123'));
        for (SObject lt : operatingHoursList) {
            lt.put('TimeZone', 'America/New_York');
        }
        insert operatingHoursList;
        List<SObject> serviceTerritoryList = new List<SObject>();
        serviceTerritoryList.add(new ServiceTerritory(Name='Testing123'));
        for (SObject lt : serviceTerritoryList) {
            // set to previously created Operating Hours
            lt.put('OperatingHoursId', operatingHoursList[0].Id);
        }
        insert serviceTerritoryList;
    }

    @IsTest
    private static void ServiceAppointmentDateFieldsShouldConvert() {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        serviceAppointmentList.add(new ServiceAppointment());
        DateTime myDateTime = DateTime.newInstanceGMT(2019, 10, 10, 0, 0, 0);
        for (SObject lt : serviceAppointmentList) {
            lt.put('EarliestStartTime', myDateTime);
            lt.put('ActualEndTime', myDateTime);
            lt.put('ActualStartTime', myDateTime);
            lt.put('ArrivalWindowEndTime', myDateTime);
            lt.put('ArrivalWindowStartTime', myDateTime);
            lt.put('SchedEndTime', myDateTime);
            lt.put('SchedStartTime', myDateTime);
            lt.put('ServiceTerritoryId', [Select ID from ServiceTerritory].Id);
        }

        Test.startTest();
        trac_ServiceAppointmentTimeConv.execute(serviceAppointmentList);
        Test.stopTest();

        // 'America/New_York' timezone would be 4 hours ahead compared to GMT
        System.assertEquals('Oct 09 2019 08:00 PM',serviceAppointmentList[0].Local_Scheduled_Start_Time__c );
//        System.assertEquals('Oct 09 2019 08:00 PM',serviceAppointmentList[0].Local_Actual_Start_Time__c );
    }

    @IsTest
    private static void ServiceAppointmentDateFieldsShouldConvertOnUpdate() {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        serviceAppointmentList.add(new ServiceAppointment());
        DateTime myDateTime = DateTime.newInstanceGMT(2019, 10, 10, 0, 0, 0);
        for (SObject lt : serviceAppointmentList) {
            lt.put('ActualEndTime', myDateTime);
            lt.put('ActualStartTime', myDateTime);
            lt.put('ServiceTerritoryId', [Select ID from ServiceTerritory].Id);
        }
        Map<Id, ServiceAppointment> oldServiceAppointmentMap = new Map<Id, ServiceAppointment>();
        for(ServiceAppointment oldSA : serviceAppointmentList)
        {
            oldServiceAppointmentMap.put(oldSA.Id, oldSA);
        }
        ServiceAppointment newChanges = serviceAppointmentList[0].clone(true, true, false, false);
        newChanges.ActualEndTime = null;
        newChanges.ActualStartTime = null;
        List<ServiceAppointment> newServiceAppointmentList = new List<ServiceAppointment>{newChanges};

        Test.startTest();
        trac_ServiceAppointmentTimeConv.execute(newServiceAppointmentList, oldServiceAppointmentMap);
        Test.stopTest();

        System.assertEquals(null,serviceAppointmentList[0].Local_Scheduled_Start_Time__c );
//        System.assertEquals(null,serviceAppointmentList[0].Local_Actual_Start_Time__c );
    }

    @IsTest
    private static void ServiceAppointmentDateFieldsShouldConvertRunWithNullDate() {
        List<ServiceAppointment> serviceAppointmentList = new List<ServiceAppointment>();
        serviceAppointmentList.add(new ServiceAppointment());
        for (SObject lt : serviceAppointmentList) {
            lt.put('ServiceTerritoryId', [Select ID from ServiceTerritory].Id);
        }

        Test.startTest();
        trac_ServiceAppointmentTimeConv.localTimeConvert(serviceAppointmentList);
        Test.stopTest();

        System.assertEquals(null,serviceAppointmentList[0].Local_Scheduled_Start_Time__c );
    }
}