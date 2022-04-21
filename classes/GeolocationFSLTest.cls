@isTest
public class GeolocationFSLTest {
    final static String ZIPCODE = '14209';
    final static String SERVICE_TERRITORY_NAME = 'Ohio Valley';

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

        FSLTestUtility.createAllStructureWithParentST( SERVICE_TERRITORY_NAME, ZIPCODE );
    }

    @isTest
    static void updateWorkOrder() {
        WorkType stInspec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :SERVICE_TERRITORY_NAME LIMIT 1 ];

        Test.startTest();
            FSLTestUtility.generateWork( stInspec, stInspec, acct, ZIPCODE, stRec, 1 );
            WorkOrder wo = [ SELECT Id FROM WorkOrder LIMIT 1 ];
            wo.Latitude = 1;
            wo.Longitude = 1;
            update wo;
        Test.stopTest();
    }

    @isTest
    static void updateServiceAppointment() {
        WorkType stInspec = [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name = 'Standard Inspection' LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :SERVICE_TERRITORY_NAME LIMIT 1 ];

        Test.startTest();
            FSLTestUtility.generateWork( stInspec, stInspec, acct, ZIPCODE, stRec, 1 );
            ServiceAppointment sa = [ SELECT Id FROM ServiceAppointment LIMIT 1 ];
            sa.Latitude = 1;
            sa.Longitude = 1;
            update sa;
        Test.stopTest();
    }
}