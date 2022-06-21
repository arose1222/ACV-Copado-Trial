/**
 * @description Test for utility class for updating a work orders status and owner based on its new and existing assigned resources.
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-13
 */
@IsTest
private class trac_AssignedResourceStatusOwnerTest {
    static final String SENIOR_VEHICLE_CONDITION_INSPECTOR_PERMISSION_SET = 'Senior_VCI';
    static final String ON_HOLD_STATUS = 'On Hold';
    static final String COMPLETED_STATUS = 'Completed';

    @TestSetup
    static void loadTestData() {

        FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );

        WorkType workType1 = new WorkType(Name = tracConstants.WORKTYPE_DEALER_STANDARD_INSPECTION, EstimatedDuration = 10, DurationType='Hours');
        insert workType1;

        Id systemAdministratorProfileId;
        Id vehicleConditionInspectorProfileId;
        List<User> users = new List<User>();
        List<PermissionSet> vciSeniorPermissionSets = [SELECT Id FROM PermissionSet WHERE Name = :SENIOR_VEHICLE_CONDITION_INSPECTOR_PERMISSION_SET];
        List<String> profiles = new List<String>{trac_AssignedResourceValidationHelper.VEHICLE_CONDITION_INSPECTOR_PROFILE,'System Administrator'};
        List<Profile> vciProfiles = new List<Profile>([SELECT Id,Name FROM Profile WHERE Name in :profiles]);

        for(Profile profile : vciProfiles) {
            if (profile.Name == trac_AssignedResourceValidationHelper.VEHICLE_CONDITION_INSPECTOR_PROFILE) {
                vehicleConditionInspectorProfileId = profile.Id;
            }

            if (profile.Name == 'System Administrator') {
                systemAdministratorProfileId = profile.Id;
            }
        }

        Account a = TestUtility.createAccount();
        insert a;
        List<Contact> conLst = new List<Contact>();
        Contact c1 = TestUtility.createContact( a );
        c1.Identity_Id__c = ACVUtility.NewGuid();
        conLst.add( c1 );
        Contact c2 = TestUtility.createContact( a );
        c2.Identity_Id__c = ACVUtility.NewGuid();
        conLst.add( c2 );
        Contact c3 = TestUtility.createContact( a );
        c3.Identity_Id__c = ACVUtility.NewGuid();
        conLst.add( c3 );


        User vciUser1 = TestUtility.createUser();
        vciUser1.LastName = 'vciUser1';
        vciUser1.Username = 'vciUser1@traction'+System.currentTimeMillis() + '.com';
        vciUser1.Email = c1.Email;
        vciUser1.ProfileId = vehicleConditionInspectorProfileId;
        users.add(vciUser1);

        User vciSeniorUser1 = TestUtility.createUser();
        vciSeniorUser1.LastName = 'vciSeniorUser1';
        vciSeniorUser1.Username = 'vciSeniorUser1@traction'+System.currentTimeMillis() + '.com';
        vciSeniorUser1.Email = c2.Email;
        vciSeniorUser1.ProfileId = vehicleConditionInspectorProfileId;
        users.add(vciSeniorUser1);

        TestUtility.insertValidationBypass();
        User adminUser1 = TestUtility.createUser();
        adminUser1.LastName = 'adminUser1';
        adminUser1.Username = 'admin@traction'+System.currentTimeMillis() + '.com';
        adminUser1.Email = c3.Email;
        adminUser1.ProfileId = systemAdministratorProfileId;
        users.add(adminUser1);
        insert users;

        c1.ACV_User__c = vciUser1.Id;
        c2.ACV_User__c = vciSeniorUser1.Id;
        c3.ACV_User__c = adminUser1.Id;
        insert conLst;

        // Make Permission Set Assignment for 'FSL Resource License' (Scheduling License)
        List<PermissionSetAssignment> psaLst = new List<PermissionSetAssignment>();
        System.runAs( users[0] ) { 
            for(User u : users) {
                psaLst.add( FSLTestUtility.makePermissionSet( u.Id ) );
            }
            insert psaLst;
        }
        

        List<ServiceResource> serviceResources = new List<ServiceResource>();

        ServiceResource vciServiceResource = new ServiceResource(Name = vciUser1.LastName, RelatedRecordId = vciUser1.Id, IsActive=true);
        serviceResources.add(vciServiceResource);

        ServiceResource vciSeniorServiceResource = new ServiceResource(Name = vciSeniorUser1.LastName, RelatedRecordId = vciSeniorUser1.Id, IsActive=true);
        serviceResources.add(vciSeniorServiceResource);

        ServiceResource adminServiceResource = new ServiceResource(Name = adminUser1.LastName, RelatedRecordId = adminUser1.Id, IsActive=true);
        serviceResources.add(adminServiceResource);

        insert serviceResources;

        OperatingHours operatingHours = new OperatingHours(Name = 'vciTest');
        insert operatingHours;

        ServiceTerritory serviceTerritory = new ServiceTerritory(
                Name = 'Great Lakes', IsActive = true, OperatingHoursId = operatingHours.Id);
        insert serviceTerritory;

        Schema.Location location = new Schema.Location(Name = 'vciTest');
        insert location;

        ServiceTerritoryLocation serviceTerritoryLocation = new ServiceTerritoryLocation(
                LocationId = location.Id, ServiceTerritoryId = serviceTerritory.Id);
        insert serviceTerritoryLocation;

        List<ServiceTerritoryMember> serviceTerritoryMembers = new List<ServiceTerritoryMember>();

        ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
                ServiceTerritoryId = serviceTerritory.Id, ServiceResourceId = vciServiceResource.Id, OperatingHoursId = operatingHours.Id, EffectiveStartDate = Date.today(), TerritoryType = 'P');
        serviceTerritoryMembers.add(vciServiceTerritoryMember);

        ServiceTerritoryMember vciSeniorServiceTerritoryMember = new ServiceTerritoryMember(
                ServiceTerritoryId = serviceTerritory.Id, ServiceResourceId = vciSeniorServiceResource.Id, OperatingHoursId = operatingHours.Id, EffectiveStartDate = Date.today(), TerritoryType = 'P');
        serviceTerritoryMembers.add(vciSeniorServiceTerritoryMember);

        ServiceTerritoryMember adminServiceTerritoryMember = new ServiceTerritoryMember(
                ServiceTerritoryId = serviceTerritory.Id, ServiceResourceId = adminServiceResource.Id, OperatingHoursId = operatingHours.Id, EffectiveStartDate = Date.today(), TerritoryType = 'P');
        serviceTerritoryMembers.add(adminServiceTerritoryMember);

        insert serviceTerritoryMembers;

        List<WorkOrder> workOrders = new List<WorkOrder>();

        WorkOrder workOrder1 = new WorkOrder(Description = '1', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder1);
        WorkOrder workOrder4 = new WorkOrder(Description = '1.4', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder4);
        WorkOrder workOrder5 = new WorkOrder(Description = '1.5', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder5);

        WorkOrder workOrder2 = new WorkOrder(Description = '2', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder2);
        WorkOrder workOrder6 = new WorkOrder(Description = '2.6', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder6);
        WorkOrder workOrder7 = new WorkOrder(Description = '2.7', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder7);

        WorkOrder workOrder3 = new WorkOrder(Description = '3', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder3);
        WorkOrder workOrder8 = new WorkOrder(Description = '3.8', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder8);
        WorkOrder workOrder9 = new WorkOrder(Description = '3.9', ServiceTerritoryId = serviceTerritory.Id, Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        workOrders.add(workOrder9);
        insert workOrders;

        List<ServiceAppointment> serviceAppointments = new List<ServiceAppointment>();

        //Service Appointments for All Open Status Tests
        ServiceAppointment serviceAppointment1 = new ServiceAppointment(
                Description='1', Work_Order__c = workOrder1.Id, ParentRecordId = workOrder1.Id, ServiceTerritoryId = serviceTerritory.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment1);

        ServiceAppointment serviceAppointment2 = new ServiceAppointment(
                Description='2', Work_Order__c = workOrder4.Id,ParentRecordId = workOrder4.Id, ServiceTerritoryId = serviceTerritory.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment2);

        ServiceAppointment serviceAppointment3 = new ServiceAppointment(
                Description='3', Work_Order__c = workOrder5.Id, ParentRecordId = workOrder5.Id, ServiceTerritoryId = serviceTerritory.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment3);

        //Service Appointments for All Closed Status Test
        ServiceAppointment serviceAppointment4 = new ServiceAppointment(
                Description='4', Work_Order__c = workOrder2.Id, ParentRecordId = workOrder2.Id, ServiceTerritoryId = serviceTerritory.Id, Status='Cannot Complete',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment4);

        ServiceAppointment serviceAppointment5 = new ServiceAppointment(
                Description='5', Work_Order__c = workOrder6.Id, ParentRecordId = workOrder6.Id, ServiceTerritoryId = serviceTerritory.Id, Status= 'Completed',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12), Completed_Canceled_Notes__c='close this',
                ActualStartTime = DateTime.now(), ActualEndTime = DateTime.Now(),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment5);

        ServiceAppointment serviceAppointment6 = new ServiceAppointment(
                Description='6', Work_Order__c = workOrder7.Id, ParentRecordId = workOrder7.Id, ServiceTerritoryId = serviceTerritory.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment6);

        //Service Appointments for Mixed Status Test
        ServiceAppointment serviceAppointment7 = new ServiceAppointment(
                Description='7', Work_Order__c = workOrder3.Id, ParentRecordId = workOrder3.Id, ServiceTerritoryId = serviceTerritory.Id, Status='Canceled',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12), Completed_Canceled_Notes__c='cancel this',
                ActualStartTime = DateTime.now(), ActualEndTime = DateTime.Now(),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment7);

        ServiceAppointment serviceAppointment8 = new ServiceAppointment(
                Description='8', Work_Order__c = workOrder8.Id, ParentRecordId = workOrder8.Id, ServiceTerritoryId = serviceTerritory.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment8);

        ServiceAppointment serviceAppointment9 = new ServiceAppointment(
                Description='9', Work_Order__c = workOrder9.Id, ParentRecordId = workOrder9.Id, ServiceTerritoryId = serviceTerritory.Id, Status='New',
                DueDate = Date.today().addMonths(1), EarliestStartTime = Datetime.now(),
                SchedStartTime = Datetime.now().addHours(1), SchedEndTime = Datetime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        serviceAppointments.add(serviceAppointment9);

        insert serviceAppointments;

    }

    private static void grantScheduleOtherResourcesPermission(User user) {
        List<PermissionSet> vciSeniorPermissionSets = [SELECT Id FROM PermissionSet WHERE Name = :SENIOR_VEHICLE_CONDITION_INSPECTOR_PERMISSION_SET];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = vciSeniorPermissionSets[0].Id);

        insert permissionSetAssignment;
    }

    private static User getUser(String lastName) {
        List<User> users = [SELECT Id, ProfileId FROM User WHERE LastName = :lastName];

        return (users.isEmpty()) ? null : users[0];
    }

    private static ServiceResource getServiceResource(String lastName) {
        ServiceResource serviceResource;
        User user = getUser(lastName);

        if (user != null) {
            List<ServiceResource> serviceResources = [SELECT Id FROM ServiceResource WHERE RelatedRecordId = :user.Id];
            serviceResource = (serviceResources.isEmpty()) ? null : serviceResources[0];
        }

        return serviceResource;
    }

    private static AssignedResource getAssignedResource(Id serviceResourceId) {
        List<AssignedResource> assignedResources = [SELECT Id FROM AssignedResource WHERE ServiceResourceId = :serviceResourceId];

        return (assignedResources.isEmpty()) ? null : assignedResources[0];
    }

    private static ServiceAppointment getServiceAppointment(String description) {
        List<ServiceAppointment> serviceAppointments = [SELECT Id, Description,Status, SchedStartTime FROM ServiceAppointment];
        for (ServiceAppointment serviceAppointment :serviceAppointments) {
            if (serviceAppointment.Description == description) {
                return serviceAppointment;
            }
        }

        return null; //not found
    }


    private static WorkOrder getWorkOrder(Id serviceAppointmentId) {
        List<WorkOrder> workOrders = [SELECT Id, Description, Status, OwnerId FROM WorkOrder WHERE Id IN (SELECT ParentRecordId FROM ServiceAppointment WHERE Id = :serviceAppointmentId)];

        return (workOrders.isEmpty()) ? null : workOrders[0];
    }

    @IsTest
    static void FirstAssignedTest() {
        User user = getUser('vciSeniorUser1');
        ServiceResource serviceResource = getServiceResource('vciUser1');

        grantScheduleOtherResourcesPermission(user);

        System.runAs(user) {
            ServiceAppointment serviceAppointment1 = getServiceAppointment('1');
            serviceAppointment1.SchedStartTime = Datetime.now().addHours(1);
            serviceAppointment1.SchedEndTime = Datetime.now().addHours(12);
            serviceAppointment1.Allow_VCI_Status_Change__c = TRUE;
            update serviceAppointment1;

            WorkOrder workOrder1 = getWorkOrder(serviceAppointment1.Id);
            workOrder1.Status = ON_HOLD_STATUS;
            update workOrder1;

            Test.startTest();
            AssignedResource assignedResource1 = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = serviceAppointment1.Id);
            insert assignedResource1;
            Test.stopTest();

            workOrder1 = getWorkOrder(serviceAppointment1.Id);
            System.assertEquals(user.Id, workOrder1.OwnerId, 'FirstAssignedTest did not update work order owner to the running user as expected');
            System.assertEquals(trac_AssignedResourceStatusOwnerHelper.ASSIGNED_STATUS, workOrder1.Status, 'FirstAssignedTest did not update work order status to the assigned status, as expected');
        }
    }

    @IsTest
    static void AllOpenTest() {
        Test.startTest();
            User user1 = getUser('vciSeniorUser1');
            User user2 = getUser('vciUser1');
            ServiceResource serviceResource1 = getServiceResource('vciSeniorUser1');
            ServiceResource serviceResource2 = getServiceResource('vciUser1');
            ServiceResource serviceResource3 = getServiceResource('vciUser1');

            grantScheduleOtherResourcesPermission(user1);

            System.runAs(user1) {
                List<ServiceAppointment> saLst = new List<ServiceAppointment>();
                ServiceAppointment serviceAppointment1 = getServiceAppointment('1');
                serviceAppointment1.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment1.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment1.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment1 );
                ServiceAppointment serviceAppointment2 = getServiceAppointment('2');
                serviceAppointment2.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment2.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment2.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment2 );

                update saLst;

                List<AssignedResource> assignedResources1 = new List<AssignedResource>();
                AssignedResource assignedResource1 = new AssignedResource(ServiceResourceId = serviceResource1.Id, ServiceAppointmentId = serviceAppointment1.Id);
                assignedResources1.add(assignedResource1);
                AssignedResource assignedResource2 = new AssignedResource(ServiceResourceId = serviceResource2.Id, ServiceAppointmentId = serviceAppointment2.Id);
                assignedResources1.add(assignedResource2);

                insert assignedResources1;

                WorkOrder workOrder1 = getWorkOrder(serviceAppointment2.Id);
                workOrder1.Status = ON_HOLD_STATUS;
                update workOrder1;
            }

            System.runAs(user2) {
                ServiceAppointment serviceAppointment3 = getServiceAppointment('3');
                serviceAppointment3.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment3.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment3.Allow_VCI_Status_Change__c = TRUE;
                update serviceAppointment3;

                List<AssignedResource> assignedResources2 = new List<AssignedResource>();
                AssignedResource assignedResource3 = new AssignedResource(ServiceResourceId = serviceResource3.Id, ServiceAppointmentId = serviceAppointment3.Id);
                assignedResources2.add(assignedResource3);
                insert assignedResources2;

                WorkOrder workOrder1 = getWorkOrder(serviceAppointment3.Id);
                //System.assertEquals(user2.Id, workOrder1.OwnerId, 'AllOpenTest did not update work order owner to the running user as expected');
                //System.assertEquals(ON_HOLD_STATUS, workOrder1.Status, 'AllOpenTest updated work order  status when not expected. Should still be On Hold');
            }
        Test.stopTest();
    }

    @IsTest
    static void AllClosedTest() {
        User user1 = getUser('vciSeniorUser1');
        User user2 = getUser('vciUser1');
        ServiceResource serviceResource1 = getServiceResource('vciSeniorUser1');
        ServiceResource serviceResource2 = getServiceResource('vciUser1');
        ServiceResource serviceResource3 = getServiceResource('vciUser1');

        grantScheduleOtherResourcesPermission(user1);

        System.runAs(user1) {
            ServiceAppointment serviceAppointment4 = getServiceAppointment('4');
            WorkOrder workOrder2 = getWorkOrder(serviceAppointment4.Id);
            workOrder2.Status = ON_HOLD_STATUS;
            update workOrder2;
        }

        System.runAs(user2) {
            ServiceAppointment serviceAppointment6 = getServiceAppointment('6');
            serviceAppointment6.Status = 'New';
            serviceAppointment6.Allow_VCI_Status_Change__c = TRUE;
            update serviceAppointment6;

            Test.startTest();
            List<AssignedResource> assignedResources1 = new List<AssignedResource>();
            AssignedResource assignedResource1 = new AssignedResource(ServiceResourceId = serviceResource3.Id, ServiceAppointmentId = serviceAppointment6.Id);
            assignedResources1.add(assignedResource1);
            insert assignedResources1;
            Test.stopTest();

            WorkOrder workOrder2 = getWorkOrder(serviceAppointment6.Id);
            System.assertEquals(user2.Id, workOrder2.OwnerId, 'AllClosedTest did not update work order owner to the running user as expected');
            System.assertEquals(trac_AssignedResourceStatusOwnerHelper.ASSIGNED_STATUS, workOrder2.Status, 'AllClosedTest did not update work order status to the assigned status, as expected');
        }
    }

    @IsTest
    static void MixedStatusTest() {
        User user1 = getUser('vciSeniorUser1');
        User user2 = getUser('vciUser1');
        ServiceResource serviceResource1 = getServiceResource('vciSeniorUser1');
        ServiceResource serviceResource2 = getServiceResource('vciUser1');
        ServiceResource serviceResource3 = getServiceResource('vciUser1');

        grantScheduleOtherResourcesPermission(user1);
    Test.startTest();
            System.runAs(user1) {
                ServiceAppointment serviceAppointment8 = getServiceAppointment('8');
    
                List<AssignedResource> assignedResources1 = new List<AssignedResource>();
                AssignedResource assignedResource8 = new AssignedResource(ServiceResourceId = serviceResource1.Id, ServiceAppointmentId = serviceAppointment8.Id);
                assignedResources1.add(assignedResource8);
    
                insert assignedResources1;
                WorkOrder workOrder3 = getWorkOrder(serviceAppointment8.Id);
                workOrder3.Status = ON_HOLD_STATUS;
                update workOrder3;
            }
    
            System.runAs(user2) {
                ServiceAppointment serviceAppointment9 = getServiceAppointment('9');
    
                
                List<AssignedResource> assignedResources2 = new List<AssignedResource>();
                AssignedResource assignedResource9 = new AssignedResource(ServiceResourceId = serviceResource3.Id, ServiceAppointmentId = serviceAppointment9.Id);
                assignedResources2.add(assignedResource9);
                insert assignedResources2;
    
                WorkOrder workOrder3 = getWorkOrder(serviceAppointment9.Id);
                System.assertEquals(user2.Id, workOrder3.OwnerId, 'MixedStatusTest did not update work order owner to the running user as expected');
                //System.assertEquals(ON_HOLD_STATUS, workOrder3.Status, 'MixedStatusTest updated work order status when not expected. Should still be On Hold');
            }
        Test.stopTest();
    }

    @IsTest
    static void EmptyAssignedResourcesTest() {
        User user = getUser('vciSeniorUser1');

        grantScheduleOtherResourcesPermission(user);

        System.runAs(user) {

            Test.startTest();
            new trac_AssignedResourceStatusOwnerHelper().updateWorkOrderStatusOwner(new List<AssignedResource>());
            Test.stopTest();

            List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE Status = :trac_AssignedResourceStatusOwnerHelper.ASSIGNED_STATUS];

            System.assertEquals(true, workOrders.isEmpty(), 'EmptyAssignedResourcesTest updated work order status when not expected. There should be no assigned work orders');
        }
    }

    @IsTest
    static void NullAssignedResourcesTest() {
        User user = getUser('vciSeniorUser1');

        grantScheduleOtherResourcesPermission(user);

        System.runAs(user) {
            Test.startTest();
            new trac_AssignedResourceStatusOwnerHelper().updateWorkOrderStatusOwner(null);
            Test.stopTest();

            List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE Status = :trac_AssignedResourceStatusOwnerHelper.ASSIGNED_STATUS];

            System.assertEquals(true, workOrders.isEmpty(), 'NullAssignedResourcesTest updated work order status when not expected. There should be no assigned work orders');
        }
    }

    @IsTest
    static void EmptyServiceAppointmentTest() {
        User user = getUser('vciSeniorUser1');
        ServiceResource serviceResource = getServiceResource('vciSeniorUser1');

        grantScheduleOtherResourcesPermission(user);

        System.runAs(user) {

            Test.startTest();
            AssignedResource assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = null);
            new trac_AssignedResourceStatusOwnerHelper().updateWorkOrderStatusOwner(new List<AssignedResource>{assignedResource});
            Test.stopTest();

            List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE Status = :trac_AssignedResourceStatusOwnerHelper.ASSIGNED_STATUS];

            System.assertEquals(true, workOrders.isEmpty(), 'EmptyServiceAppointmentTest updated work order status when not expected. There should be no assigned work orders');
        }
    }

    @IsTest
    static void MultiWorkOrderTest() {
        Test.startTest();
            User user1 = getUser('vciSeniorUser1');
            ServiceResource serviceResource1 = getServiceResource('vciSeniorUser1');
            ServiceResource serviceResource2 = getServiceResource('vciUser1');

            grantScheduleOtherResourcesPermission(user1);

            System.runAs(user1) {
                List<ServiceAppointment> saLst = new List<ServiceAppointment>();
                ServiceAppointment serviceAppointment1 = getServiceAppointment('1');
                serviceAppointment1.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment1.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment1.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment1 );
                ServiceAppointment serviceAppointment2 = getServiceAppointment('2');
                serviceAppointment2.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment2.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment2.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment2 );
                ServiceAppointment serviceAppointment4 = getServiceAppointment('4');
                serviceAppointment4.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment4.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment4.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment4 );
                ServiceAppointment serviceAppointment8 = getServiceAppointment('8');
                serviceAppointment8.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment8.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment8.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment8 );
                update saLst;

                List<AssignedResource> assignedResources1 = new List<AssignedResource>();
                AssignedResource assignedResource1 = new AssignedResource(ServiceResourceId = serviceResource1.Id, ServiceAppointmentId = serviceAppointment1.Id);
                assignedResources1.add(assignedResource1);
                AssignedResource assignedResource2 = new AssignedResource(ServiceResourceId = serviceResource2.Id, ServiceAppointmentId = serviceAppointment2.Id);
                assignedResources1.add(assignedResource2);
                AssignedResource assignedResource8 = new AssignedResource(ServiceResourceId = serviceResource2.Id, ServiceAppointmentId = serviceAppointment8.Id);
                assignedResources1.add(assignedResource8);

                insert assignedResources1;

                List<WorkOrder> workOrders = new List<WorkOrder>();
                WorkOrder workOrder1 = getWorkOrder(serviceAppointment1.Id);
                workOrder1.Status = ON_HOLD_STATUS;
                workOrders.add(workOrder1);
                WorkOrder workOrder2 = getWorkOrder(serviceAppointment4.Id);
                workOrder2.Status = ON_HOLD_STATUS;
                workOrders.add(workOrder2);
                WorkOrder workOrder3 = getWorkOrder(serviceAppointment8.Id);
                workOrder3.Status = ON_HOLD_STATUS;
                workOrders.add(workOrder3);

                update workOrders;
            }

            System.runAs(user1) {
                List<ServiceAppointment> saLst = new List<ServiceAppointment>();
                ServiceAppointment serviceAppointment3 = getServiceAppointment('3');
                serviceAppointment3.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment3.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment3.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment3 );
                ServiceAppointment serviceAppointment6 = getServiceAppointment('6');
                serviceAppointment6.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment6.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment6.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment6 );
                ServiceAppointment serviceAppointment9 = getServiceAppointment('9');
                serviceAppointment9.SchedStartTime = Datetime.now().addHours(1);
                serviceAppointment9.SchedEndTime = Datetime.now().addHours(12);
                serviceAppointment9.Allow_VCI_Status_Change__c = TRUE;
                saLst.add( serviceAppointment9 );
                update saLst;

                List<AssignedResource> assignedResources2 = new List<AssignedResource>();
                AssignedResource assignedResource3 = new AssignedResource(ServiceResourceId = serviceResource2.Id, ServiceAppointmentId = serviceAppointment3.Id);
                assignedResources2.add(assignedResource3);
                AssignedResource assignedResource6 = new AssignedResource(ServiceResourceId = serviceResource2.Id, ServiceAppointmentId = serviceAppointment6.Id);
                assignedResources2.add(assignedResource6);
                AssignedResource assignedResource9 = new AssignedResource(ServiceResourceId = serviceResource2.Id, ServiceAppointmentId = serviceAppointment9.Id);
                assignedResources2.add(assignedResource9);
                insert assignedResources2;

                // WorkOrder workOrder1 = getWorkOrder(serviceAppointment3.Id);
                // System.assertEquals(user1.Id, workOrder1.OwnerId, 'Multi-AllOpenTest did not update work order owner to the running user as expected');
                // System.assertEquals(ON_HOLD_STATUS, workOrder1.Status, 'AllOpenTest updated work order  status when not expected. Should still be On Hold');

                // WorkOrder workOrder2 = getWorkOrder(serviceAppointment6.Id);
                // System.assertEquals(user1.Id, workOrder2.OwnerId, 'Multi-AllClosedTest did not update work order owner to the running user as expected');
                // System.assertEquals(trac_AssignedResourceStatusOwnerHelper.ASSIGNED_STATUS, workOrder2.Status, 'AllClosedTest did not update work order status to the assigned status, as expected');

                // WorkOrder workOrder3 = getWorkOrder(serviceAppointment9.Id);
                // System.assertEquals(user1.Id, workOrder3.OwnerId, 'Multi-MixedStatusTest did not update work order owner to the running user as expected');
                // System.assertEquals(ON_HOLD_STATUS, workOrder3.Status, 'MixedStatusTest updated work order status when not expected. Should still be On Hold');
            }
        Test.stopTest();
    }
}