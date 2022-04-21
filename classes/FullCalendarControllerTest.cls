@isTest
public class FullCalendarControllerTest {
    @TestSetup
    static void makeData(){
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
        WorkType workTypeResult = [ SELECT Id, Name, Work_Type_Color__c FROM WorkType LIMIT 1 ];
        DateTime rightNow = System.now();

        insert new Down_Day__c(
            Work_Type__c = workTypeResult.Id,
            Name = workTypeResult.Name + ' Down Day: ' + rightNow.date(),
            Work_Type_Color__c = workTypeResult.Work_Type_Color__c,
            Start__c = rightNow,
            End__c = rightNow.addMinutes(5),
            Is_All_Day__c = TRUE
        );
    }

    @IsTest
    static void searchForRecords(){
        Date startDate = Date.today().addDays( -5 );
        Date endDate = Date.today().adddays( 5 );
        String objectName = 'Down_Day__c';
        String titleFIeld = 'Title__c';
        String startField = 'Start__c';
        String endField = 'End__c';
        String colorField = 'Work_Type_Color__c';
        String allDayField = 'Is_All_Day__c';
        String additionalFilter; // If additional Filter wants to be tested later
        
        List<Object> objectLst = new List<Object>();

        Test.startTest();
            objectLst = FullCalendarController.getEventsNearbyDynamic( startDate, endDate, objectName, titleField, startField, endField, colorField, allDayField, additionalFilter);
        Test.stopTest();

        System.assertEquals( 1, objectLst.size(), 'There was an unexpected amount of search results' );
    }
}