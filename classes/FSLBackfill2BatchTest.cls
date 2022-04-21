@isTest
public class FSLBackfill2BatchTest {
    
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

        final String ZIPCODE = '14209';
        final String TERRITORY_NAME = 'Ohio Valley';
        FSLTestUtility.createAllStructureWithParentST( TERRITORY_NAME, ZIPCODE );
        ServiceTerritory stRec = [ SELECT Id FROM ServiceTerritory WHERE Name = :TERRITORY_NAME LIMIT 1 ];

        Map<String, WorkType> wtMap = new Map<String, WorkType>();
        for ( WorkType wtRec : [ SELECT Id, Name, EstimatedDuration, DurationType FROM WorkType WHERE Name IN :( new Set<String>{ 'Standard Inspection' } ) ] ) {
            wtMap.put( wtRec.Name, wtRec );
        }
        FSLTestUtility.generateWork( wtMap.get( 'Standard Inspection' ), wtMap.get( 'Standard Inspection' ), a, ZIPCODE, stRec, 1 );
    }
       
    @isTest
    static void runTest() {

        Test.startTest();

            SchedulableContext sc = null;
            FSLBackfill2Batch batch = new FSLBackfill2Batch();
            batch.execute( sc );

        Test.stopTest();
    }
}