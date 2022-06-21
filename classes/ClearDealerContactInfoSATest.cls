@isTest
public class ClearDealerContactInfoSATest {
    private final static String WORK_TYPE_UNIQUE_NAME = 'fbi';
    private final static String WORK_TYPE_STANDARD = 'inspection';

    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact( a );
        insert c;
        a.Primary_Contact__c = c.Id;
        update a;
    }

    @IsTest
    static void createSA(){
        WorkType fbi = [ SELECT Id, Name, EstimatedDuration, DurationType, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_Id__c = :WORK_TYPE_UNIQUE_NAME LIMIT 1 ];
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        
        Test.startTest();
            FSLTestUtility.generateWork( fbi, fbi, acct, '14209', st, 1);
        Test.stopTest();
        
        ServiceAppointment sa = [ SELECT Id, ContactId FROM ServiceAppointment LIMIT 1 ];

        System.assert( sa.ContactId == null, 'The contact information was not properly removed' );
    }

    @IsTest
    static void updateSA(){
        WorkType fbi = [ SELECT Id, Name, EstimatedDuration, DurationType, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_Id__c = :WORK_TYPE_UNIQUE_NAME LIMIT 1 ];
        
        ServiceTerritory st = [ SELECT Id FROM ServiceTerritory LIMIT 1 ];
        Account acct = [ SELECT Id, Name FROM Account LIMIT 1 ];
        WorkType standard = [ SELECT Id, Name, EstimatedDuration, DurationType, Work_Type_Unique_ID__c FROM WorkType WHERE Work_Type_Unique_Id__c = :WORK_TYPE_STANDARD LIMIT 1 ];        
        FSLTestUtility.generateWork( standard, standard, acct, '14209', st, 1);

        WorkOrder wo = [ SELECT Id FROM WorkOrder LIMIT 1 ];

        Test.startTest();
            wo.WorkTypeId = fbi.Id;
            update wo;
        Test.stopTest();
        
        ServiceAppointment sa = [ SELECT Id, ContactId FROM ServiceAppointment LIMIT 1 ];

        System.assert( sa.ContactId == null, 'The contact information was not properly removed' );
    }
}