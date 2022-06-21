/**
 * This is the Test class for the FilterManagerSidebarController
 * @author James Andre LaCour
 */
@isTest
public class FilterManagerSidebarControllerTest {
    public static final String ACV_TEST_ID = '000000';
    public static final String FILTER_GROUP_JSON = '{"filter":{"attributes":{"type":"Filter_Manager__c"},"Name":"test","Visibility__c":"Private"}}';
    public static final String FILTER_SET_JSON = '{"objectFields":[{"value":"False","operator":"Equals","label":"Archived","key":"Archived__cEqualsfalse","isActive":false,"field":"Archived__c","canDelete":false}],"logicFields":[{"value":"My","operator":"Equals","label":"Cars to Show","key":"AllOrMyCarsequalsMy","isActive":true,"field":"AllOrMyCars","canDelete":false}]}';
    /********************Test Data Setup*************************/
    /**
     * Creates Data needed for Test Methods
     */
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        User u = TestUtility.createUser();
        u.Id__c = ACV_TEST_ID;
        insert u;
        System.runAs(u){
            Filter_Manager__c fm = new Filter_Manager__c();
            fm.Name = 'Test123';
            fm.Visibility__c = 'Private';
            fm.Filter_Items_JSON__c = FILTER_SET_JSON;
            fm.RecordTypeId = FilterManagerSidebarController.FILTER_RT_ID;
            fm.Pinned__c = true;
            insert fm;
            Filter_Manager__c fmAssignment = new Filter_Manager__c();
            fmAssignment.Filter__c = fm.Id;
            fmAssignment.RecordTypeId = FilterManagerSidebarController.ASSIGNMENT_RT_ID;
            insert fmAssignment;
        }
    }
    /********************Test Methods****************************/
    /**
     * Tests that it gets the filters for just the user navigating to the page
     */
    @IsTest
    static void getAllFiltersAndSetsTest(){
        List<User> userList = [ SELECT Id FROM User WHERE Id__c = :ACV_TEST_ID ];
        FilterManagerSidebarController.ReturnWrapper rw = null;
        Test.startTest();
            System.runAs(userList[0]){
                rw = (FilterManagerSidebarController.ReturnWrapper)JSON.deserialize(FilterManagerSidebarController.getAllFiltersAndSets(),FilterManagerSidebarController.ReturnWrapper.class);
            }
        Test.stopTest();
        System.assert( rw.allFiltersAndSetsList.size() == 1 );
    }
    /**
     * Tests that pinning a Filter correctly updates the attribute
     */
    @IsTest
    static void modifyFilterPinnedFlagTest(){
        List<User> userList = [ SELECT Id FROM User WHERE Id__c = :ACV_TEST_ID ];
        List<Filter_Manager__c> fmList = [ SELECT Id, Pinned__c, Filter__c, Filter__r.Name, Filter__r.Visibility__c, Filter__r.Filter_Items_JSON__c FROM Filter_Manager__c WHERE RecordTypeId = :FilterManagerSidebarController.ASSIGNMENT_RT_ID ];
        Filter_Manager__c tempFilter = new Filter_Manager__c();
        tempFilter.Id = fmList[0].Filter__c;
        tempFilter.Name = fmList[0].Filter__r.Name;
        tempFilter.Visibility__c = fmList[0].Filter__r.Visibility__c;
        FilterManagerSidebarController.ReturnWrapper rw = null;
        Test.startTest();
            fmList[0].Pinned__c = false;
            System.runAs(userList[0]){
                FilterManagerSidebarController.FilterWrapper fw = new FilterManagerSidebarController.FilterWrapper( tempFilter, fmList[0] );
                rw = (FilterManagerSidebarController.ReturnWrapper)JSON.deserialize(FilterManagerSidebarController.modifyFilterPinnedFlag(JSON.serialize(new List<FilterManagerSidebarController.FilterWrapper>{fw})),FilterManagerSidebarController.ReturnWrapper.class);
            }
        Test.stopTest();
        Filter_Manager__c fmToCheck = [ SELECT Id, Pinned__c FROM Filter_Manager__c WHERE Id = :fmList[0].Id LIMIT 1 ];
        System.assertEquals( false, rw.hasError );
        System.assertEquals( false, fmToCheck.Pinned__c );
    }
    /**
     * Tests that creating a filter works
     */
    @IsTest
    static void createFilterTest(){
        List<User> userList = [ SELECT Id FROM User WHERE Id__c = :ACV_TEST_ID ];
        FilterManagerSidebarController.ReturnWrapper rw = null;
        Test.startTest();
            System.runAs(userList[0]){
                rw = (FilterManagerSidebarController.ReturnWrapper)JSON.deserialize(FilterManagerSidebarController.createUpdateFilter( FILTER_GROUP_JSON ), FilterManagerSidebarController.ReturnWrapper.class);
            }
        Test.stopTest();
        System.assertEquals( false, rw.hasError );
        List<Filter_Manager__c> fmList = [ SELECT Id FROM Filter_Manager__c WHERE Name = 'test' ];
        System.assertEquals( 1, fmList.size() );
    }
    /**
     * test that updating the name of a filter works
     */
    @IsTest
    static void updateFilterTest(){
        List<User> userList = [ SELECT Id FROM User WHERE Id__c = :ACV_TEST_ID ];
        List<Filter_Manager__c> fmList = [ SELECT Id, Pinned__c, Filter__c, Filter__r.Name, Filter__r.Visibility__c, Filter__r.Filter_Items_JSON__c FROM Filter_Manager__c WHERE RecordTypeId = :FilterManagerSidebarController.ASSIGNMENT_RT_ID ];
        Filter_Manager__c tempFilter = new Filter_Manager__c();
        tempFilter.Id = fmList[0].Filter__c;
        tempFilter.Name = 'New Update Name';
        tempFilter.Visibility__c = fmList[0].Filter__r.Visibility__c;
        FilterManagerSidebarController.FilterWrapper fw = new FilterManagerSidebarController.FilterWrapper( tempFilter, fmList[0] );
        FilterManagerSidebarController.ReturnWrapper rw = null;
        Test.startTest();
            System.runAs(userList[0]){
                rw = (FilterManagerSidebarController.ReturnWrapper)JSON.deserialize(FilterManagerSidebarController.createUpdateFilter( JSON.serialize(fw) ), FilterManagerSidebarController.ReturnWrapper.class);
            }
        Test.stopTest();
        System.assertEquals( false, rw.hasError );
        fmList = [ SELECT Id FROM Filter_Manager__c WHERE Name = 'New Update Name' ];
        System.assertEquals( 1, fmList.size() );
    }
    /**
     * Tests that modifying the Filters Item JSON works
     */
    @IsTest
    static void createUpdateFilterSetTest(){
        List<User> userList = [ SELECT Id FROM User WHERE Id__c = :ACV_TEST_ID ];
        FilterManagerSidebarController.ReturnWrapper rw = null;
        List<Filter_Manager__c> fmList = [ SELECT Id FROM Filter_Manager__c LIMIT 1 ];
        System.assertEquals( 1, fmList.size() );
        String filterIdJson = JSON.serialize(fmList[0].Id);
        Test.startTest();
            System.runAs(userList[0]){
                rw = (FilterManagerSidebarController.ReturnWrapper)JSON.deserialize(FilterManagerSidebarController.createUpdateFilterSet( filterIdJson, '{}' ), FilterManagerSidebarController.ReturnWrapper.class);
            }
        Test.stopTest();
        System.assertEquals( false, rw.hasError );
        fmList = [ SELECT Id, Filter_Items_JSON__c FROM Filter_Manager__c WHERE Name = 'test123' ];
        System.assertEquals( 1, fmList.size() );
        System.assertEquals( '{}', fmList[0].Filter_Items_JSON__c );
    }
    /**
     * Tests the deletion of a filter
     */
    @IsTest
    static void deleteFilterTest(){
        List<User> userList = [ SELECT Id FROM User WHERE Id__c = :ACV_TEST_ID ];
        FilterManagerSidebarController.ReturnWrapper rw = null;
        List<Filter_Manager__c> fmList = [ SELECT Id FROM Filter_Manager__c LIMIT 1 ];
        System.assertEquals( 1, fmList.size() );
        String filterIdJson = JSON.serialize(fmList[0].Id);
        Test.startTest();
            System.runAs(userList[0]){
                rw = (FilterManagerSidebarController.ReturnWrapper)JSON.deserialize(FilterManagerSidebarController.deleteFilter( filterIdJson ), FilterManagerSidebarController.ReturnWrapper.class);
            }
        Test.stopTest();
        System.assertEquals( false, rw.hasError );
        fmList = [ SELECT Id FROM Filter_Manager__c ];
        System.assertEquals( 0, fmList.size() );
    }
}