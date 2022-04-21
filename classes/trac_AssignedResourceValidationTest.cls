/**
 * @description Test for utility class for validating permission to assign resources to a service appointment.
 * @author Karen Reardon, Traction on Demand
 * @date 2019-08-30
 */

@isTest
public with sharing class trac_AssignedResourceValidationTest {
    static final String SENIOR_VEHICLE_CONDITION_INSPECTOR_PERMISSION_SET = 'Senior_VCI';

    @testSetup
    static void loadTestData() {
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

        ServiceResource vciSeniorServiceResource = new ServiceResource(Name = vciSeniorUser1.LastName, RelatedRecordId = vciSeniorUser1.Id, isActive=true);
        serviceResources.add(vciSeniorServiceResource);

        ServiceResource adminServiceResource = new ServiceResource(Name = adminUser1.LastName, RelatedRecordId = adminUser1.Id, isActive=true);
        serviceResources.add(adminServiceResource);

        insert serviceResources;

        Account account = TestUtility.createAccount('vciTest');
        insert account;

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

        ServiceAppointment serviceAppointment = new ServiceAppointment(
                ParentRecordId = account.Id, ServiceTerritoryId = serviceTerritory.Id, Status='None',
                DueDate = Date.today().addMonths(1), EarliestStartTime = DateTime.now(),
                SchedStartTime = DateTime.now().addHours(1), SchedEndTime = DateTime.now().addHours(12),
                Street = '101 Main Street', City = 'Buffalo', PostalCode = '14209', State = 'NY', Country = 'US');
        insert serviceAppointment;
    }

    private static User getUser(String lastName) {
        List<User> users = [SELECT Id, ProfileId FROM User WHERE lastName = :lastName];

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

    private static void grantScheduleOtherResourcesPermission(User user) {
        List<PermissionSet> vciSeniorPermissionSets = [SELECT Id FROM PermissionSet WHERE Name = :SENIOR_VEHICLE_CONDITION_INSPECTOR_PERMISSION_SET];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = vciSeniorPermissionSets[0].Id);

        insert permissionSetAssignment;
    }

    private static ServiceAppointment getServiceAppointment() {
        List<ServiceAppointment> serviceAppointments = [SELECT Id from ServiceAppointment LIMIT 1];

        return (serviceAppointments.isEmpty()) ? null : serviceAppointments[0];
    }

    @isTest
    private static void testAssignOtherResourceAllowedBySeniorVCI() {
        User user = getUser('vciSeniorUser1');
        ServiceResource serviceResource = getServiceResource('vciUser1');

        grantScheduleOtherResourcesPermission(user);

        System.runAs(user) {
            Test.startTest();
            AssignedResource assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = getServiceAppointment().Id);
            insert assignedResource;
            Test.stopTest();

            assignedResource = getAssignedResource(serviceResource.Id);
            System.assertNotEquals(null, assignedResource, 'Senior VCI check failed; should be able to assign other resources.');
        }
    }

    @isTest
    private static void testAssignOwnResourceAllowedBySeniorVCI() {
        User user = getUser('vciSeniorUser1');
        ServiceResource serviceResource = getServiceResource('vciSeniorUser1');

        grantScheduleOtherResourcesPermission(user);

        System.runAs(user) {
            Test.startTest();
            AssignedResource assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = getServiceAppointment().Id);
            insert assignedResource;
            Test.stopTest();

            assignedResource = getAssignedResource(serviceResource.Id);
            System.assertNotEquals(null, assignedResource, 'Senior VCI check failed; should be able to assign their own resource.');
        }
    }

    @isTest
    private static void testAssignOtherResourceNotAllowedByVCI() {
        User user = getUser('vciUser1');
        ServiceResource serviceResource = getServiceResource('vciSeniorUser1');
        AssignedResource assignedResource;

        System.runAs(user) {
            try {
                Test.startTest();
                assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = getServiceAppointment().Id);
                system.debug('BILL INSERTING THE THING');
                insert assignedResource;
                Test.stopTest();
            }
            catch (Exception ex) {
                Boolean containsCorrectError = ex.getMessage().contains(trac_AssignedResourceValidationHelper.ASSIGN_RESOURCE_PERMISSION_VALIDATION_ERROR);
                System.assertEquals(true, containsCorrectError, 'VCI Check failed; Wrong exception raised: ' + ex.getMessage());
            }

            assignedResource = getAssignedResource(serviceResource.Id);
            //System.assertEquals(null, assignedResource, 'VCI check failed; should not be able to assign other resources.');
        }
    }

    @isTest
    private static void testAssignOwnResourceAllowedByVCI() {
        User user = getUser('vciUser1');
        ServiceResource serviceResource = getServiceResource('vciUser1');

        System.runAs(user) {
            Test.startTest();
            AssignedResource assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = getServiceAppointment().Id);
            insert assignedResource;
            Test.stopTest();

            assignedResource = getAssignedResource(serviceResource.Id);
            System.assertNotEquals(null, assignedResource, 'VCI check failed; should be able to assign their own resource.');
        }
    }

    @isTest
    private static void testAssignOtherResourceAllowedByAdmin() {
        User user = getUser('adminUser1');
        ServiceResource serviceResource = getServiceResource('adminUser1');

        System.runAs(user) {
            Test.startTest();
            AssignedResource assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = getServiceAppointment().Id);
            insert assignedResource;
            Test.stopTest();

            assignedResource = getAssignedResource(serviceResource.Id);
            System.assertNotEquals( null, assignedResource, 'Admin check failed; should be able to assign other resources.');
        }
    }

    @isTest
    private static void testAssignOwnResourceAllowedByAdmin() {
        User user = getUser('adminUser1');
        ServiceResource serviceResource = getServiceResource('adminUser1');

        System.runAs(user) {
            Test.startTest();
            AssignedResource assignedResource = new AssignedResource(ServiceResourceId = serviceResource.Id, ServiceAppointmentId = getServiceAppointment().Id);
            insert assignedResource;
            Test.stopTest();

            assignedResource = getAssignedResource(serviceResource.Id);
            System.assertNotEquals(null, assignedResource, 'Admin check failed; should be able to assign their own resource.');
        }
    }
}