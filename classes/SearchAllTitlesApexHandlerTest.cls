@isTest
public class SearchAllTitlesApexHandlerTest {
    @TestSetup
    static void makeData() {
        //make three titles
        //pass in a search for one of the vins
        //make sure it is returning only that vin (or that the first item it returns is that vin)
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Date createdDate = system.today().addDays(-5);
        List<Case> caseList = new List<Case>();
        Case newCase1 = new Case(Status = 'New', Origin = 'Phone', Vehicle_VIN_Last_6__c = '898080', RecordTypeId = recordTypeId, ACV_Titles_External_ID__c='123');
        caseList.add(newCase1);
        Case newCase2 = new Case(Status = 'New', Origin = 'Phone', Vehicle_VIN_Last_6__c = '898081', RecordTypeId = recordTypeId, ACV_Titles_External_ID__c='124');
        caseList.add(newCase2);
        Case newCase3 = new Case(Status = 'New', Origin = 'Phone', Vehicle_VIN_Last_6__c = '898082', RecordTypeId = recordTypeId, ACV_Titles_External_ID__c='125');
        caseList.add(newCase3);
        // for (integer i = 0; i < 3; i++) {
        //     Case newCase = new Case(Status = 'New', Origin = 'Phone', Vehicle_VIN_Last_6__c = '89808' + i, RecordTypeId = recordTypeId);
        //     caseList.add(newCase);
        // }
        insert caseList;
        Test.setCreatedDate(newCase1.Id, createdDate);
        Test.setCreatedDate(newCase2.Id, createdDate);
        Test.setCreatedDate(newCase3.Id, createdDate);
        //RecordType.Name = 'Titles Information'
        //removing for now
        //how to set the record type - this is a stipulation in the search
        //will setting the Age in Days field work? NO
    }

    @isTest
    static void testQuery() {
        Id [] fixedResults = new Id[1];
        Case caseSearch = [SELECT ID, Vehicle_VIN_Last_6__c FROM Case WHERE Vehicle_VIN_Last_6__c = '898081'];
        fixedResults.add(caseSearch.Id);
        Test.setFixedSearchResults(fixedResults);

        List<Case> results = SearchAllTitlesApexHandler.getTitles('898081');

        System.assertEquals(1, results.size());
        System.assertEquals(caseSearch.Id, results[0].Id);
        //how do i get it to search? it doesn't run automatically from a trigger handler, it's based on user input
        //so how do i simulate that
    }
}