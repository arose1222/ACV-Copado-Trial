@isTest
private class DealMakerView2Test {
    
    @TestSetup
    private static void makeData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Username = 'Testy1@Testington.test', LastName = 'McTesty1', Email ='Testy1@Testington.test', Alias = 'TESTBOY1', CommunityNickname = 'tEsT1', TimeZoneSidKey = 'America/New_York', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8', ProfileId = p.Id, LanguageLocaleKey = 'en_US');
        insert u1;
        list<Account> actList = new list<Account>();
        actList.add(new Account(Name = 'Test Account'));
        //actList.add(new Account(Name = 'Test Account 2', Sales_Region_Formula__c = 'Great Lakes Region'));
        insert actList;
        Auction__c testAuc = new Auction__c(Name = '940938', status__c = 'counter_sent');
        insert testAuc;
        Datetime now = System.Now();
        date future = System.Today().addDays(30);
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Maker').getRecordTypeId();
        List<Opportunity> oppList = new list<Opportunity>();
        oppList.add(new Opportunity(Auction_End_Date_Time__c = now, RecordTypeId = recordTypeId, Name = 'Test', CloseDate = future, StageName = 'New', AccountId = actList[0].Id, Auction__c = testAuc.Id, Seller_IST__c = u1.Id));
        oppList.add(new Opportunity(Auction_End_Date_Time__c = now, RecordTypeId = recordTypeId, Name = 'Test', CloseDate = future, StageName = 'New', AccountId = actList[0].Id, Auction__c = testAuc.Id));
        insert oppList;
    }

    @IsTest
    private static void testReturn(){
        String blank = '[]';
        List<Opportunity> oppList = DealMakerView2.getOpportunities(blank);
        System.assertEquals(2, oppList.size());
    }

    @IsTest
    private static void testSearch(){
        User testUser = [SELECT Id FROM User WHERE LastName = 'McTesty1'];
        Opportunity searchOpp = [SELECT Id, Seller_IST__c FROM Opportunity WHERE Seller_IST__c != null];
        List<Opportunity> oppList = DealMakerView2.getOpportunities('["'+testUser.Id+'"]');
        System.assertEquals(1, oppList.size());
        System.assertEquals(searchOpp.Id, oppList[0].Id);
    }

    @IsTest
    private static void nullTest(){
        List<Opportunity> oppList = DealMakerView2.getOpportunities('["User 3000"]');
        System.assertEquals(0, oppList.size());
    }

    @IsTest
    private static void lfListTest(){
        User testUser = [SELECT Id FROM User WHERE LastName = 'McTesty1'];
        List<LookupSearchResult> useList = DealMakerView2.searchTheTerm('Roxanne');
        System.assertEquals(0, useList.size());
    }

    @IsTest
    private static void loadFiltTest(){
        User testUser = [SELECT Id FROM User WHERE LastName = 'McTesty1'];
        list<String> testStrings = new List<String>();
        testStrings.add('McTesty1');
        DealMakerView2.filterSave(testStrings);
        List<LookupSearchResult> loadTest = DealMakerView2.loadFilterList();
        System.assertEquals(1, loadTest.size());
    }

}