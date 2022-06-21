@isTest
public class AssignedResourceFieldTriggerHandlerTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account vciAccount = TestUtility.createAccount('vciTestAccount');
        insert vciAccount;

        // Create Operating Hours (needed for Service Service Territory & Service Territory Member):
        OperatingHours vciOperatingHours = new OperatingHours(Name = 'vciTestOpHours');
        insert vciOperatingHours;

        // Create Service Territory (needed for Work Order, Service Territory Member & Service Appointment):
        ServiceTerritory vciServiceTerritory = new ServiceTerritory(
            Name = 'Greater Buffalo',
            OperatingHoursId = vciOperatingHours.Id,
            IsActive = true
            ); 
        insert vciServiceTerritory;

        // Create Work Type (needed for Work Order):
        WorkType vciWorkType = new WorkType(
            Name = 'Standard Inspection', 
            EstimatedDuration = 1, 
            ShouldAutoCreateSvcAppt = false
        );
        insert vciWorkType;

        // Create Work Order (needed for Service Appointment):
        WorkOrder vciWorkOrder = new WorkOrder(
            AccountId = vciAccount.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            WorkTypeId = vciWorkType.Id, 
            Priority = 'Low'
        );
        insert vciWorkOrder;

        ServiceResource vciServiceResource = FSLTestUtility.makeResourceData();
        ServiceResource vciServiceResource2 = FSLTestUtility.makeResourceData();

        // Create Service Territory Member:
        List<ServiceTerritoryMember> stmLst = new List<ServiceTerritoryMember>();
        ServiceTerritoryMember vciServiceTerritoryMember = new ServiceTerritoryMember(
            OperatingHoursId = vciOperatingHours.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            ServiceResourceId = vciServiceResource.Id,
            EffectiveStartDate = Date.today(), 
            TerritoryType = 'P'
        );
        stmLst.add( vciServiceTerritoryMember );

        ServiceTerritoryMember vciServiceTerritoryMember2 = new ServiceTerritoryMember(
            OperatingHoursId = vciOperatingHours.Id, 
            ServiceTerritoryId = vciServiceTerritory.Id, 
            ServiceResourceId = vciServiceResource2.Id,
            EffectiveStartDate = Date.today(), 
            TerritoryType = 'P'
        );
        stmLst.add( vciServiceTerritoryMember2 );
        insert stmLst;
    }

    @isTest
    public static void mostRecentResourceInsertion(){
        Test.startTest();
            FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
            Id srId = [SELECT Id FROM ServiceResource LIMIT 1].Id;
            Id srId2 = [SELECT Id FROM ServiceResource WHERE Id != :srId LIMIT 1].Id;
            ServiceAppointment saRec = [SELECT Id FROM ServiceAppointment LIMIT 1];
	        Id saId = saRec.Id;
        
        	saRec.SchedStartTime = DateTime.now();
			saRec.SchedEndTime = saRec.SchedStartTime.addMinutes(30);
        	update saRec;
        	
            AssignedResource ar = new AssignedResource(
                ServiceResourceId = srId,
                ServiceAppointmentId = saId
            );
            insert ar;
            ServiceAppointment sa = [SELECT Id, Most_Recent_Service_Resource__c FROM ServiceAppointment WHERE Id = :saId LIMIT 1];
            System.Assert(sa.Most_Recent_Service_Resource__c == srId);

            AssignedResource ar2 = new AssignedResource(
                ServiceResourceId = srId2,
                ServiceAppointmentId = saId
            );
            insert ar2;
            sa = [SELECT Id, Most_Recent_Service_Resource__c FROM ServiceAppointment WHERE Id = :saId LIMIT 1];
            System.Assert(sa.Most_Recent_Service_Resource__c == srId2);
        Test.stopTest();
    }

    @isTest
    public static void mostRecentResourceUpdate(){
        Test.startTest();
            FSL.GlobalAPIS.addStatusTransition( 'New', 'Scheduled' );
            Id srId = [SELECT Id FROM ServiceResource LIMIT 1].Id;
            Id srId2 = [SELECT Id FROM ServiceResource WHERE Id != :srId LIMIT 1].Id;
			ServiceAppointment saRec = [SELECT Id FROM ServiceAppointment LIMIT 1];
	        Id saId = saRec.Id;
        
        	saRec.SchedStartTime = DateTime.now();
			saRec.SchedEndTime = saRec.SchedStartTime.addMinutes(30);
        	update saRec;
        
            AssignedResource ar = new AssignedResource(
                ServiceResourceId = srId,
                ServiceAppointmentId = saId
            );
            insert ar;
            ServiceAppointment sa = [SELECT Id, Most_Recent_Service_Resource__c FROM ServiceAppointment WHERE Id = :saId LIMIT 1];
            System.Assert(sa.Most_Recent_Service_Resource__c == srId);
            ar.ServiceResourceId = srId2;
            update ar;
            sa = [SELECT Id, Most_Recent_Service_Resource__c FROM ServiceAppointment WHERE Id = :saId LIMIT 1];
            System.Assert(sa.Most_Recent_Service_Resource__c == srId2);
        Test.stopTest();
    }
}