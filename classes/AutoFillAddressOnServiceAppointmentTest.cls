@isTest
public class AutoFillAddressOnServiceAppointmentTest {
    
    @TestSetup
    static void makeData(){
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
    }

    @isTest
    static void createWorkWithNoAddress() {
        Account acctRec = [ SELECT Id, Name, BillingStreet FROM Account LIMIT 1 ];
        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        Test.startTest();
            WorkOrder woRec = new WorkOrder(
                AccountId = acctRec.Id,
                WorkTypeId = standardWorkType.Id,
                Subject = standardWorkType.Name + ' ' + acctRec.Name,
                Duration = standardWorkType.EstimatedDuration,
                DurationType = standardWorkType.DurationType,
                Origin__c = 'Apex Test Code',
                Status = 'New'
            );

            insert woRec;
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, Street FROM ServiceAppointment LIMIT 1 ];

        System.assertEquals( acctRec.BillingStreet, saRec.Street, 'The Service Appointment Street did not match the Account Address' );
    }

    @isTest
    static void createWorkWithPartialAddress() {
        Account acctRec = [ SELECT Id, Name, BillingStreet FROM Account LIMIT 1 ];
        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        String adressStreet = '101 Main Street';

        Test.startTest();
            WorkOrder woRec = new WorkOrder(
                AccountId = acctRec.Id,
                Street = adressStreet,
                WorkTypeId = standardWorkType.Id,
                Subject = standardWorkType.Name + ' ' + acctRec.Name,
                Duration = standardWorkType.EstimatedDuration,
                DurationType = standardWorkType.DurationType,
                Origin__c = 'Apex Test Code',
                Status = 'New'
            );

            insert woRec;
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, Street FROM ServiceAppointment LIMIT 1 ];

        System.assertNotEquals( adressStreet, saRec.Street, 'The Service Appointment Street was unexpectedly left alone' );

        System.assertEquals( acctRec.BillingStreet, saRec.Street, 'The Service Appointment Street did not match the Account Address' );
    }

    @isTest
    static void createWorkWithAddress() {
        Account acctRec = [ SELECT Id, Name, BillingStreet FROM Account LIMIT 1 ];
        WorkType standardWorkType = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];

        Test.startTest();
            WorkOrder woRec = new WorkOrder(
                AccountId = acctRec.Id,
                Street = '101 Main Street',
                City = 'Buffalo',
                PostalCode = '14209',
                State = 'NY',
                Country = 'US',
                WorkTypeId = standardWorkType.Id,
                Subject = standardWorkType.Name + ' ' + acctRec.Name,
                Duration = standardWorkType.EstimatedDuration,
                DurationType = standardWorkType.DurationType,
                Origin__c = 'Apex Test Code',
                Status = 'New'
            );

            insert woRec;
        Test.stopTest();

        ServiceAppointment saRec = [ SELECT Id, Street FROM ServiceAppointment LIMIT 1 ];

        System.assertNotEquals( acctRec.BillingStreet, saRec.Street, 'The Service Appointment Street unexpectedly matched the Account Address' );
    }
}