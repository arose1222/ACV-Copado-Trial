@isTest
 public class ResourceAbsenceTimeZoneTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        List<OperatingHours> opLst = FSLTestUtility.createOperatingHours( new Set<String>{ 'CDT Mon-Fri 8am-8pm, Sat 9am-5pm', 'EDT Mon-Fri 8am-8pm, Sat 9am-5pm' } );
        opLst[0].TimeZone = 'America/Chicago';
        opLst[1].TimeZone = 'America/New_York';
        insert opLst;
        
        insert FSLTestUtility.createTimeSlots( new Set<Id>{ opLst[0].Id, opLst[1].Id } );
        List<ServiceTerritory> stLst = FSLTestUtility.createST( new Map<String,  FSLTestUtility.ServiceTerritoryStructure>{ 'Chicago' => new FSLTestUtility.ServiceTerritoryStructure( opLst[0].Id ),
            																												'Buffalo' => new FSLTestUtility.ServiceTerritoryStructure( opLst[1].Id ) } );
        insert stLst;

        List<ServiceTerritory> serviceTerritories = [SELECT Id, Name, OperatingHoursId, OperatingHours.TimeZone FROM ServiceTerritory ORDER BY Name DESC];
        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData();
        ServiceTerritoryMember stm1 = new ServiceTerritoryMember(ServiceResourceId=vciServiceResource.Id, ServiceTerritoryId=serviceTerritories[1].Id, TerritoryType='P', EffectiveStartDate=System.today().addDays(-1), OperatingHoursId=opLst[1].Id);
        ServiceResource vciServiceResource2 = FSLTestUtility.makeResourceData();
        vciServiceResource2.Name='vciTestServiceResource2';
        update vciServiceResource2;
        ServiceTerritoryMember stm2 = new ServiceTerritoryMember(ServiceResourceId=vciServiceResource2.Id, ServiceTerritoryId=serviceTerritories[0].Id, TerritoryType='P', EffectiveStartDate=System.today().addDays(-1), OperatingHoursId=opLst[0].Id);
        List<ServiceTerritoryMember> stmToInsert = new List<ServiceTerritoryMember>();
        stmToInsert.add(stm1);
        stmToInsert.add(stm2);
        insert stmToInsert;
        
        List<WorkType> wtLst = FSLTestUtility.createWorkTypes();
        insert wtLst;
    }

    @IsTest
    static void testInsertCurrentTimeZoneFromGANTT() {
        List<ServiceResource> testSvcRsrcList = [ SELECT Id, (SELECT Id, ServiceTerritoryId, OperatingHoursId, OperatingHours.TimeZone, TerritoryType, EffectiveStartDate, EffectiveEndDate
                                                                                        FROM ServiceTerritories )  FROM ServiceResource WHERE  Name = 'vciTestServiceResource' LIMIT 1];
        String timezone = testSvcRsrcList[0].ServiceTerritories[0].OperatingHours.TimeZone;
        DateTime dtime = DateTime.newInstance(system.today(), Time.newInstance(12, 0, 0, 0));
        
        ResourceAbsence ra = new ResourceAbsence(Start = dtime, End = dtime.addHours(1), ResourceId = testSvcRsrcList[0].Id);
        Test.startTest();
        insert ra;
        Test.stopTest();
        
        ra = [SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE Id = :ra.Id];
        System.assertEquals(dtime, ra.Start);
        System.assertEquals(dtime.addHours(1), ra.End);
        System.assertEquals(dtime.format('MMMMM dd, yyyy hh:mm a z', timezone), ra.Start_Time_in_resource_s_time_zone__c);
        System.assertEquals(dtime.addHours(1).format('MMMMM dd, yyyy hh:mm a z', timezone), ra.End_Time_in_resource_s_time_zone__c);
    }

    @IsTest
    static void testUpdateCurrentTimeZoneFromGANTT() {
        List<ServiceResource> testSvcRsrcList = [ SELECT Id, (SELECT Id, ServiceTerritoryId, OperatingHoursId, OperatingHours.TimeZone, TerritoryType, EffectiveStartDate, EffectiveEndDate
                                                                                        FROM ServiceTerritories )  FROM ServiceResource WHERE  Name = 'vciTestServiceResource' LIMIT 1];
        String timezone = testSvcRsrcList[0].ServiceTerritories[0].OperatingHours.TimeZone;
        DateTime dtime = DateTime.newInstance(system.today(), Time.newInstance(12, 0, 0, 0));
        
        ResourceAbsence ra = new ResourceAbsence(Start = dtime, End = dtime.addHours(1), ResourceId = testSvcRsrcList[0].Id);
        Test.startTest();
        insert ra;
        
        ra = [SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE Id = :ra.Id];
        ra.Start = dtime.addHours(1);
        ra.End=dtime.addHours(2);
        update ra;
        Test.stopTest();

        ra = [SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE Id = :ra.Id];
        System.assertEquals(dtime.addHours(1), ra.Start);
        System.assertEquals(dtime.addHours(2), ra.End);
        System.assertEquals(dtime.addHours(1).format('MMMMM dd, yyyy hh:mm a z', timezone), ra.Start_Time_in_resource_s_time_zone__c);
        System.assertEquals(dtime.addHours(2).format('MMMMM dd, yyyy hh:mm a z', timezone), ra.End_Time_in_resource_s_time_zone__c);
    }

    @IsTest
    static void testInsertOtherTimeZoneFromGANTT() {
        //Using America/Chicago TimeZone for a test. They are one hour behind EST.
        List<ServiceResource> testSvcRsrcList = [ SELECT Id, (SELECT Id, ServiceTerritoryId, OperatingHoursId, OperatingHours.TimeZone, TerritoryType, EffectiveStartDate, EffectiveEndDate
                                                                                        FROM ServiceTerritories )  FROM ServiceResource WHERE  Name = 'vciTestServiceResource2' LIMIT 1];
        String timezone = testSvcRsrcList[0].ServiceTerritories[0].OperatingHours.TimeZone;
        DateTime dtime = DateTime.newInstance(system.today(), Time.newInstance(12, 0, 0, 0));
        
        ResourceAbsence ra = new ResourceAbsence(Start = dtime, End = dtime.addHours(1), ResourceId = testSvcRsrcList[0].Id);
        Test.startTest();
        insert ra;
        Test.stopTest();

        ra = [SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE Id = :ra.Id];
        System.assertEquals(dtime, ra.Start);
        System.assertEquals(dtime.addHours(1), ra.End);
        System.assertEquals(dtime.format('MMMMM dd, yyyy hh:mm a z', timezone), ra.Start_Time_in_resource_s_time_zone__c);
        System.assertEquals(dtime.addhours(1).format('MMMMM dd, yyyy hh:mm a z', timezone), ra.End_Time_in_resource_s_time_zone__c);
    }

    @IsTest
    static void testUpdateOtherTimeZoneFromGANTT() {
        //Using America/Chicago TimeZone for a test. They are one hour behind EST.
        List<ServiceResource> testSvcRsrcList = [ SELECT Id, (SELECT Id, ServiceTerritoryId, OperatingHoursId, OperatingHours.TimeZone, TerritoryType, EffectiveStartDate, EffectiveEndDate
                                                                                        FROM ServiceTerritories )  FROM ServiceResource WHERE  Name = 'vciTestServiceResource2' LIMIT 1];
        String timezone = testSvcRsrcList[0].ServiceTerritories[0].OperatingHours.TimeZone;
        DateTime dtime = DateTime.newInstance(system.today(), Time.newInstance(12, 0, 0, 0));
        
        ResourceAbsence ra = new ResourceAbsence(Start = dtime, End = dtime.addHours(1), ResourceId = testSvcRsrcList[0].Id);
        Test.startTest();
        insert ra;

        ra = [SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE Id = :ra.Id];
        
        ra.Start = dtime.addHours(1);
        ra.End=dtime.addHours(2);
        update ra;
        Test.stopTest();

        ra = [SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE Id = :ra.Id];
        System.assertEquals(dtime.addHours(1), ra.Start);
        System.assertEquals(dtime.addHours(2), ra.End);
        System.assertEquals(dtime.addHours(1).format('MMMMM dd, yyyy hh:mm a z', timezone), ra.Start_Time_in_resource_s_time_zone__c);
        System.assertEquals(dtime.addHours(2).format('MMMMM dd, yyyy hh:mm a z', timezone), ra.End_Time_in_resource_s_time_zone__c);
    }

    @IsTest
    static void testMassRAInsert() {
        TimeZone currentTimeZone = UserInfo.getTimeZone();
        List<ServiceResource> testSvcRsrcList = [ SELECT Id, Name, (SELECT Id, ServiceTerritoryId, OperatingHoursId, OperatingHours.TimeZone, TerritoryType, EffectiveStartDate, EffectiveEndDate
                                                                                        FROM ServiceTerritories ) FROM ServiceResource WHERE  Name LIKE 'vciTestServiceResource%' ORDER BY Name ASC];
        System.assert(testSvcRsrcList.size() > 1);
		String estTimezone = testSvcRsrcList[0].ServiceTerritories[0].OperatingHours.TimeZone;
        String cstTimezone = testSvcRsrcList[1].ServiceTerritories[0].OperatingHours.TimeZone;
        
        List<ResourceAbsence> resourceAbsencesToInsert = new List<ResourceAbsence>();
        for(Integer count = 0; count <= 100; count++) {
            resourceAbsencesToInsert.add(new ResourceAbsence(Start = DateTime.newInstance(system.today().addDays(count), Time.newInstance(12, 0, 0, 0)), 
                                                            End = DateTime.newInstance(system.today().addDays(count), Time.newInstance(13, 0, 0, 0)), 
                                                            ResourceId = testSvcRsrcList[0].Id, 
                                                            Verify_Timezone__c=true));
        }
        
        for(Integer count = 0; count <= 100; count++) {
            resourceAbsencesToInsert.add(new ResourceAbsence(Start = DateTime.newInstance(system.today().addDays(count), Time.newInstance(12, 0, 0, 0)), 
                                                            End = DateTime.newInstance(system.today().addDays(count), Time.newInstance(13, 0, 0, 0)), 
                                                            ResourceId = testSvcRsrcList[1].Id, 
                                                            Verify_Timezone__c=true));
        }
        
        Test.startTest();
        insert resourceAbsencesToInsert;
        Test.stopTest();

        List<ResourceAbsence> raListSameTimeZone = new List<ResourceAbsence>([SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE ResourceId = :testSvcRsrcList[0].Id ORDER BY Start ASC]);
        System.assertEquals(101, raListSameTimeZone.size());
        Integer numDays = 0;
        for(ResourceAbsence ra :raListSameTimeZone) {
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(12, 0, 0, 0)), ra.Start);
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(13, 0, 0, 0)), ra.End);
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(12, 0, 0, 0)).format('MMMMM dd, yyyy hh:mm a z', estTimezone), ra.Start_Time_in_resource_s_time_zone__c);
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(13, 0, 0, 0)).format('MMMMM dd, yyyy hh:mm a z', estTimezone), ra.End_Time_in_resource_s_time_zone__c);
            numDays++;
        }

        List<ResourceAbsence> raListDifferentTimeZone = new List<ResourceAbsence>([SELECT Id, Start, End, Start_Time_in_resource_s_time_zone__c, End_Time_in_resource_s_time_zone__c FROM ResourceAbsence WHERE ResourceId = :testSvcRsrcList[1].Id ORDER BY Start ASC]);
        System.assertEquals(101, raListDifferentTimeZone.size());
        numDays = 0;
        for(ResourceAbsence ra :raListDifferentTimeZone) {
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(13, 0, 0, 0)), ra.Start);
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(14, 0, 0, 0)), ra.End);
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(13, 0, 0, 0)).format('MMMMM dd, yyyy hh:mm a z', cstTimezone), ra.Start_Time_in_resource_s_time_zone__c);
            System.assertEquals(DateTime.newInstance(system.today().addDays(numDays), Time.newInstance(14, 0, 0, 0)).format('MMMMM dd, yyyy hh:mm a z', cstTimezone), ra.End_Time_in_resource_s_time_zone__c);
            numDays++;
        }
    }
}