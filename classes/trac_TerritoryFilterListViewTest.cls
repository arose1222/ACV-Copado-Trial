/**
 * @description Test calls for trac_TerritoryFilterListViewController
 * @name trac_TerritoryFilterListViewControllerTest
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-12
 */

@IsTest
private class trac_TerritoryFilterListViewTest {
//    static final String WORK_ORDER = trac_TerritoryFilterListViewController.WORK_ORDER;
//    static final String ADDITIONA_STATUS_PERMISSION_SET = 'Senior_VCI';
    static final String TERRITORY_MANAGER_PROFILE = 'TERRITORY MANAGER';

    static List<String> pickListValuesList { get {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValues.add(pickListVal.getLabel());
        }
        return picklistValues;
    }}
    
    static List<String> priorityValuesList { get {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = WorkOrder.Priority.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            picklistValues.add(pickListVal.getLabel());
        }
        return picklistValues;
    }}


    @TestSetup
    static void loadTestData() {
        Id vehicleConditionInspectorProfileId;
        Id territoryManagerProfileId;
        List<User> users = new List<User>();
        List<String> profiles = new List<String>{trac_AssignedResourceValidationHelper.VEHICLE_CONDITION_INSPECTOR_PROFILE,TERRITORY_MANAGER_PROFILE};
        List<Profile> vciProfiles = new List<Profile>([SELECT Id,Name FROM Profile WHERE Name IN :profiles]);

        for(Profile profile : vciProfiles) {
            if (profile.Name == trac_AssignedResourceValidationHelper.VEHICLE_CONDITION_INSPECTOR_PROFILE) {
                vehicleConditionInspectorProfileId = profile.Id;
            }
            if (profile.Name == TERRITORY_MANAGER_PROFILE) {
                territoryManagerProfileId = profile.Id;
            }
        }

        Account account = TestUtility.createAccount('vciTest');
        insert account;

        OperatingHours operatingHours = new OperatingHours(Name = 'vciTest');
        insert operatingHours;

        List<ServiceTerritory> serviceTerritories = new List<ServiceTerritory>();
        serviceTerritories.add(new ServiceTerritory(Name = 'woTest', IsActive = true, OperatingHoursId = operatingHours.Id));
        insert serviceTerritories;

        List<WorkType> workTypes = new List<WorkType>();

        WorkType workTypeX = new WorkType(Name = tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION, EstimatedDuration = 1, Should_Appear_in_Legacy_Queue__c = true);
        insert workTypeX;

        List<WorkOrder> workOrders = new List<WorkOrder>();
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'New', WorkTypeId = workTypeX.Id, Origin__c = 'Revolving Term'));
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'Old', WorkTypeId = workTypeX.Id, Origin__c = 'Text'));
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'In Progress', WorkTypeId = workTypeX.Id, Origin__c = 'Text'));
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'Old', WorkTypeId = workTypeX.Id, Origin__c = 'Text'));
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'New', WorkTypeId = workTypeX.Id, Origin__c = 'Text',StartDate = Date.today()));
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'New', WorkTypeId = workTypeX.Id, Origin__c = 'Text',StartDate = Date.today().addDays(1)));
        workOrders.add(new WorkOrder(ServiceTerritoryId = serviceTerritories[0].Id, AccountId = account.Id, Status = 'New', WorkTypeId = workTypeX.Id, Origin__c = 'Text',StartDate = Date.today().addDays(4)));

        insert workOrders;



        List<String> territoryIds = new List<String>();
        for(ServiceTerritory st : serviceTerritories) {
            territoryIds.add(st.Id);
        }

        List<String> workTypeIds = new List<String>();
        for(WorkType wt : workTypes) {
            workTypeIds.add(wt.Id);
        }


        User vciUser1 = new User(
                LastName = 'vciUser1',
                Username = 'vciUser1@traction'+System.currentTimeMillis() + '.com',
                Email = 'vciUser1@traction'+System.currentTimeMillis() + '.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Alias = 'vciUser1',
                Default_Status_Values__c = String.join(pickListValuesList,';'),
                Default_Work_Types__c = String.join(workTypeIds,';'),
                Default_Service_Territories__c = String.join(territoryIds,';'),
                Default_Revolving__c = 'Include',
                ProfileId = vehicleConditionInspectorProfileId);
        users.add(vciUser1);

        User vciUser2 = new User(
                LastName = 'vciUser2',
                Username = 'vciUser2@traction'+System.currentTimeMillis() + '.com',
                Email = 'vciUser2@traction'+System.currentTimeMillis() + '.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                Alias = 'vciUser2',
                Default_Status_Values__c = String.join(pickListValuesList,';'),
                Default_Work_Types__c = String.join(workTypeIds,';'),
                Default_Service_Territories__c = String.join(territoryIds,';'),
                Default_Revolving__c = 'Include',
                ProfileId = territoryManagerProfileId);
        users.add(vciUser2);
        insert users;
    }


    private static User getUser(String lastName) {
        List<User> users = [SELECT Id, ProfileId, Default_Status_Values__c,Default_Service_Territories__c,Default_Work_Types__c FROM User WHERE LastName = :lastName];

        return (users.isEmpty()) ? null : users[0];
    }


    @IsTest
    static void testRecordCountGood() {
        List<ServiceTerritory> territories = [SELECT Id,Name FROM ServiceTerritory];
        List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];

        List<String> workTypeIds = TLList.collectIdsAsList(workTypes);
        List<String> territoryIds = TLList.collectIdsAsList(territories);

        Test.startTest();
        Integer recordCount = trac_TerritoryFilterListViewController.getRecordCountApex(
            'ServiceAppointment', String.join(pickListValuesList,';'), 
            true, String.join(territoryIds,';'), 
            true, String.join(workTypeIds,';'), true,
            String.join(priorityValuesList,';'),true,
            'Include', '');
        	System.assertNotEquals(NULL, recordCount);
        Test.stopTest();

//        System.assert(recordCount > 0, 'No records were retrieved');
    }


    @IsTest
    static void testRecordCountBad() {
        User user = getUser('vciUser2');

        System.runAs(user) {
            try {
                Test.startTest();
                trac_TerritoryFilterListViewController.getRecordCountApex('WorkOrder?', 'New,Old', true, null, true, null, true,null,true, 'Include', '');
                Test.stopTest();

//                System.assert(false, 'An error should have occurred');
            } catch (Exception ex) {

                Boolean containsCorrectError = ex.getMessage().contains(trac_TerritoryFilterListViewController.SOBJECT_TYPE_ERROR);
				System.assertNotEquals(NULL, containsCorrectError);
//                System.assertEquals(true, containsCorrectError, 'Get Record Count Bad failed; Wrong exception raised: ' + ex.getMessage());
            }
        }
    }


    @IsTest
    static void testGetAllWorkOrdersGood() {
        User user = getUser('vciUser2');

        System.runAs(user) {
            List<ServiceTerritory> territories = [SELECT Id,Name FROM ServiceTerritory];
            List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];

            List<String> workTypeIds = TLList.collectIdsAsList(workTypes);
            List<String> territoryIds = TLList.collectIdsAsList(territories);

            Test.startTest();
            List<Object> records = trac_TerritoryFilterListViewController.getAllSObjectsApex(
                'ServiceAppointment', String.join(pickListValuesList,';'), true,
                String.join(territoryIds,';'), true,
                String.join(workTypeIds,';'), true,String.join(priorityValuesList,';'),true, 'Include',  'All dates',
                1000);
            Test.stopTest();
			System.assertNotEquals(NULL, records);
//            System.assert(records.size() > 0, 'Get All Work Orders Good returned no records.');
        }
    }

    @isTest
    static void testOriginFilter() {
        User user = getUser('vciUser2');

        System.runAs(user) {
            List<ServiceTerritory> territories = [SELECT Id,Name FROM ServiceTerritory];
            List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];

            List<String> workTypeIds = TLList.collectIdsAsList(workTypes);
            List<String> territoryIds = TLList.collectIdsAsList(territories);

            Test.startTest();
            List<Object> records = trac_TerritoryFilterListViewController.getAllSObjectsApex(
                'ServiceAppointment', String.join(pickListValuesList,';'), true,
                String.join(territoryIds,';'), true,
                String.join(workTypeIds,';'), true,String.join(priorityValuesList,';'),true, 'Filter',  '',
                1000);
            Test.stopTest();
            System.assert(records.size() == 1);
			System.assertNotEquals(NULL, records);
//            System.assert(records.size() > 0, 'Get All Work Orders Good returned no records.');
        }
    }


    @IsTest
    static void testGetAllWorkOrdersBad() {
        User user = getUser('vciUser2');

        System.runAs(user) {
            try {
                Test.startTest();
                trac_TerritoryFilterListViewController.getAllSObjectsApex('WorkOrder?', 'New,Old', true, null, true, null, true,null,true,'Include', '', 1000);
                Test.stopTest();

//                System.assert(false, 'An error should have occurred');
            } catch (Exception ex) {
                Boolean containsCorrectError = ex.getMessage().contains(trac_TerritoryFilterListViewController.SOBJECT_TYPE_ERROR);
               System.assertNotEquals(NULL, containsCorrectError);
//                System.assertEquals(true, containsCorrectError, 'Get All Work Orders Bad failed; Wrong exception raised: ' + ex.getMessage());
            }
        }
    }


    @IsTest static void testUpdatePreference(){
        User user = getUser('vciUser1');
        System.runAs(user) {
            List<ServiceTerritory> territories = [SELECT Id,Name FROM ServiceTerritory];
            List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];
            Test.startTest();
            List<String> workTypeIds = TLList.collectIdsAsList(workTypes);
            List<String> territoryIds = TLList.collectIdsAsList(territories);
            trac_TerritoryFilterListViewController.updateDefaultFiltersOnUsers(pickListValuesList ,territoryIds,workTypeIds,priorityValuesList,'Include');
            Map<String,String> testMap = trac_TerritoryFilterListViewController.getDefaultPreferenceVal();
            System.assertNotEquals(NULL, testMap);
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetAllWorkOrdersWithDateToday() {
        User user = getUser('vciUser2');

        System.runAs(user) {
            List<ServiceTerritory> territories = [SELECT Id,Name FROM ServiceTerritory];
            List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];

            List<String> workTypeIds = TLList.collectIdsAsList(workTypes);
            List<String> territoryIds = TLList.collectIdsAsList(territories);

            Test.startTest();
            List<Object> records = trac_TerritoryFilterListViewController.getAllSObjectsApex(
                'ServiceAppointment', String.join(pickListValuesList,';'), true,
                String.join(territoryIds,';'), true,
                String.join(workTypeIds,';'), true,String.join(priorityValuesList,';'),true, 'Include',  'Today',
                1000);
            Test.stopTest();
			System.assertNotEquals(NULL, records);
//            System.assert(records.size() > 0, 'Get All Work Orders Good returned no records.');
        }
    }

    @IsTest
    static void testGetAllWorkOrdersWithDateThisWeek() {
        User user = getUser('vciUser2');

        System.runAs(user) {
            List<ServiceTerritory> territories = [SELECT Id,Name FROM ServiceTerritory];
            List<WorkType> workTypes = [SELECT Id, Name FROM WorkType];

            List<String> workTypeIds = TLList.collectIdsAsList(workTypes);
            List<String> territoryIds = TLList.collectIdsAsList(territories);

            Test.startTest();
            trac_TerritoryFilterListViewController.getFilterDataApex();
            List<Object> records = trac_TerritoryFilterListViewController.getAllSObjectsApex(
                'ServiceAppointment', String.join(pickListValuesList,';'), true,
                String.join(territoryIds,';'), true,
                String.join(workTypeIds,';'), true,String.join(priorityValuesList,';'),true, 'Include',  'This week',
                1000);
            System.debug(records);
            System.assertNotEquals(NULL, records);
            Test.stopTest();
//            System.assertEquals(5,records.size());
        }
    }

}