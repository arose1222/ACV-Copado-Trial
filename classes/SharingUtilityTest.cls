/**
 * Class to test Sharing Utility Creation amongst various Sharing Utility backend methods
 * @group Test
 * @author Gerald McEvoy
 * @since 2/25/21
 */
@isTest
public class SharingUtilityTest {
    private static String stageName = 'Discovery';

    /**
     * Setup data that creates the standard Account and Opportunity data for sharing usage
     */
    @TestSetup
    static void makeData() {
        Account acct = TestUtility.createAccount();
        insert acct;

        Opportunity testOppty = new Opportunity(
            AccountId = acct.Id,
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId(),
            Name = 'Big Opportunity, very good',
            CloseDate = Date.today().addDays(30),
            StageName = stageName
        );
        insert testOppty;
    }

    /**
     * Method tests the basic sharing functionality of a standard Salesforce object, ensuring that only one result is returned
     */
    @isTest
    static void shareOppty() {
        User u = TestUtility.createUser();
        insert u;

        List<OpportunityShare> opptyShareLst;

        Test.startTest();
            Id opptyId = [ SELECT Id FROM Opportunity LIMIT 1 ][0].Id;

            Map<Id, List<SharingUtility.SharingDefinition>> testSharingDataMap = new Map<Id, List<SharingUtility.SharingDefinition>>();
            testSharingDataMap.put( opptyId, new List<SharingUtility.SharingDefinition>() );

            SharingUtility.SharingDefinition testSharingDefRec = new SharingUtility.SharingDefinition( u.Id, 'Read', null );

            testSharingDataMap.get( opptyId ).add( testSharingDefRec );

            opptyShareLst = SharingUtility.createSharingRecords( Schema.SObjectType.Opportunity.getSObjectType(), testSharingDataMap );
        Test.stopTest();

        System.assertEquals( 1, opptyShareLst.size(), 'There was an unexpected amount of sharing records returned for our Opportunity' );
    }

    /**
     * Method tests the more advanced sharing functionality, which removes duplicates that exist against the database already, to ensure no records are returned
     */
    @isTest
    static void shareOpptyAndRemoveDupes() {
        User u = TestUtility.createUser();
        insert u;

        Id opptyId = [ SELECT Id FROM Opportunity LIMIT 1 ][0].Id;

        Map<Id, List<SharingUtility.SharingDefinition>> testSharingDataMap = new Map<Id, List<SharingUtility.SharingDefinition>>();
        testSharingDataMap.put( opptyId, new List<SharingUtility.SharingDefinition>() );

        SharingUtility.SharingDefinition testSharingDefRec = new SharingUtility.SharingDefinition( u.Id, 'Edit', null );

        testSharingDataMap.get( opptyId ).add( testSharingDefRec );

        List<OpportunityShare> opptyShareLst = SharingUtility.createSharingRecords( Schema.SObjectType.Opportunity.getSObjectType(), testSharingDataMap );

        System.assertEquals( 1, opptyShareLst.size(), 'There was an unexpected amount of sharing records returned for our Opportunity' );

        insert opptyShareLst;

        Test.startTest();
            List<OpportunityShare> opptyShareDupeLst = SharingUtility.createAndCompareSharingRecords( Schema.SObjectType.Opportunity.getSObjectType(), testSharingDataMap );
        Test.stopTest();

        System.assert( opptyShareDupeLst.isEmpty(), 'No records should return from this callout, due to duplicates being removed. ' + opptyShareDupeLst.size() + ' Opportunity Sharing Records were returned in error.' );
    }

}