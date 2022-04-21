@isTest
public class FSLDownDaySchedulerControllerTest {
    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
    }

    @IsTest
    static void findingWorkType(){
        WorkType workTypeResult = [ SELECT id, name FROM WorkType LIMIT 1 ];

        Id [] fixedResults = new Id[1];
        fixedResults.add( workTypeResult.Id );
        Test.setFixedSearchResults(fixedResults);

        List<LookupSearchResult> resultsLst;

        Test.startTest();
            List<String> selectedIds = new List<String>();
            resultsLst = FSLDownDaySchedulerController.getWorkTypes( 'Standard', selectedIds );
        Test.stopTest();

        System.assertEquals( 1, resultsLst.size() );
        System.assertEquals( workTypeResult.Id, resultsLst[0].getId() );
    }

    @IsTest
    static void createDownDay(){
        WorkType workTypeResult = [ SELECT id, name FROM WorkType LIMIT 1 ];
        String dateStrg = '2021-09-23';

        Boolean resultCheck = false;
        system.assertEquals( 0, [ SELECT Count() FROM Down_Day__c ], 'There was an unexpected amount of down dates in the system already' );

        Test.startTest();
            resultCheck = FSLDownDaySchedulerController.saveDownDay( dateStrg, workTypeResult.Id );
        Test.stopTest();

        system.assertEquals( true, resultCheck, 'There was an unexpected error with the down date creation process' );
        system.assertEquals( 1, [ SELECT Count() FROM Down_Day__c ], 'There was an unexpected amount of down dates created' );
    }
}