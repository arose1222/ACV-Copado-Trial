@isTest
public class FSLTestUtilityTest {

    @isTest
    static void createData() {
        Account acct = TestUtility.createAccount();
        insert acct;
        Integer count = 5;
        FSLTestUtility.createData( acct, count );

        Integer workOrderCount = [ SELECT Count() FROM WorkOrder ];
        System.assertEquals( 1, workOrderCount, 'There was an unexpected amount of Work Orders in the system' );

        Integer workLineCount = [ SELECT Count() FROM WorkOrderLineItem ];
        System.assertEquals( count, workLineCount, 'There was an unexpected amount of Work Order Line Items in the system' );

        List<ServiceTerritory> stLst = [ SELECT Id, Name FROM ServiceTerritory ];
        System.assertEquals( FALSE, stLst.isEmpty() );
        System.assertEquals( 1, stLst.size() );

        List<WorkType> workTypeCount = [ SELECT Id FROM WorkType ];
        System.assert( workTypeCount != null && !workTypeCount.isEmpty(), 'There was an unexpected amount of Work Types in the system' );
    }
}