/**
 * Tests for TLList
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLList
 */
@IsTest
private class TLListTest {
    private static final Integer SORT_RECORD_COUNT = 200;

    private static List<Account> testAccounts;

    static {
        testAccounts = new List<Account>{
                new Account(
                        Id = fflib_IDGenerator.generate(Account.SObjectType),
                        Name = 'Account1',
                        OwnerId = fflib_IDGenerator.generate(User.SObjectType)
                ),
                new Account(
                        Id = fflib_IDGenerator.generate(Account.SObjectType),
                        Name = 'Account2',
                        OwnerId = fflib_IDGenerator.generate(User.SObjectType)
                ),
                new Account() // null Id values should be omitted
        };
    }

    @IsTest
    private static void collectIds() {
        Test.startTest();

        final Set<Id> results = TLList.collectIds(testAccounts);

        Test.stopTest();

        System.assertEquals(2, results.size(), 'Two Ids should be returned');
        System.assert(results.contains(testAccounts[0].Id),
                'The Id from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].Id),
                'The Id from the second account record should be in the set');
    }

    @IsTest
    private static void collectIdsAsList() {
        Test.startTest();

        final List<Id> results = TLList.collectIdsAsList(testAccounts);

        Test.stopTest();

        System.assertEquals(3, results.size(), 'Three elements should be returned');
        for(Integer i = 0; i < testAccounts.size(); i++) {
            System.assertEquals(testAccounts[i].Id, results[i], 'The element should contain the expected Id');
        }
    }

    @IsTest
    private static void collectIdsSObjectField() {
        Test.startTest();

        final Set<Id> results = TLList.collectIds(testAccounts, Account.OwnerId);

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Ids should be returned');
        System.assert(results.contains(testAccounts[0].OwnerId),
                'The owner Id from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].OwnerId),
                'The owner Id from the second account record should be in the set');
    }

    @IsTest
    private static void collectIdsString() {
        Test.startTest();

        final Set<Id> results = TLList.collectIds(testAccounts, 'OwnerId');

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Ids should be returned');
        System.assert(results.contains(testAccounts[0].OwnerId),
                'The owner Id from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].OwnerId),
                'The owner Id from the second account record should be in the set');
    }

    @IsTest
    private static void collectIdsAsListSObjectField() {
        Test.startTest();

        final List<Id> results = TLList.collectIdsAsList(testAccounts, Account.OwnerId);

        Test.stopTest();

        System.assertEquals(3, results.size(), 'Three elements should be returned');
        for(Integer i = 0; i < testAccounts.size(); i++) {
            System.assertEquals(testAccounts[i].OwnerId, results[i], 'The element should contain the expected Id');
        }
    }

    @IsTest
    private static void collectIdsAsListSObjectString() {
        Test.startTest();

        final List<Id> results = TLList.collectIdsAsList(testAccounts, 'OwnerId');

        Test.stopTest();

        System.assertEquals(3, results.size(), 'Three elements should be returned');
        for(Integer i = 0; i < testAccounts.size(); i++) {
            System.assertEquals(testAccounts[i].OwnerId, results[i], 'The element should contain the expected Id');
        }
    }

    @IsTest
    private static void collectStringsSObjectField() {
        Test.startTest();

        final Set<String> results = TLList.collectStrings(testAccounts, Account.Name);

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Strings should be returned');
        System.assert(results.contains(testAccounts[0].Name),
                'The Name from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].Name),
                'The Name from the second account record should be in the set');
    }

    @IsTest
    private static void collectStringsString() {
        Test.startTest();

        final Set<String> results = TLList.collectStrings(testAccounts, 'Name');

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Strings should be returned');
        System.assert(results.contains(testAccounts[0].Name),
                'The Name from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].Name),
                'The Name from the second account record should be in the set');
    }

    @IsTest
    private static void combineSetList() {
        final Id testId1 = fflib_IDGenerator.generate(Account.SObjectType);
        final Id testId2 = fflib_IDGenerator.generate(Contact.SObjectType);


        Test.startTest();

        final Set<Id> results = TLList.combineSetList(new List<Set<Id>>{ new Set<Id>{ testId1 }, new Set<Id>{ testId2 } });

        Test.stopTest();


        System.assert(results.contains(testId1), 'The first test id should be contained in the result');
        System.assert(results.contains(testId1), 'The second test id should be contained in the result');
    }

    @IsTest
    private static void splitStrings() {
        final List<String> testList = new List<String> { 'a', 'b', 'c'};

        Test.startTest();

        List<List<String>> chunkSizeSmallerThanListResult = TLList.split(testList, 2);
        List<List<String>> chunkSizeLargerThanListResult = TLList.split(testList, 4);

        Test.stopTest();

        System.assertEquals(2, chunkSizeSmallerThanListResult.size(), 'The list should be split into two sub-lists');
        System.assertEquals(new String[]{ 'a', 'b' }, chunkSizeSmallerThanListResult[0],
                'The first sub-list should contain the expected elements');
        System.assertEquals(new String[]{ 'c' }, chunkSizeSmallerThanListResult[1],
                'The second sub-list should contain the expected elements');

        System.assertEquals(1, chunkSizeLargerThanListResult.size(), 'The list should contain a single sub-list');
        System.assertEquals(new String[]{ 'a', 'b', 'c' }, chunkSizeLargerThanListResult[0],
                'The first sub-list should contain the expected elements');
    }

    @IsTest
    private static void splitSObjects() {
        final Account a1 = new Account(Name = 'a1');
        final Account a2 = new Account(Name = 'a2');
        final Account a3 = new Account(Name = 'a3');
        final List<Account> testList = new List<Account> { a1, a2, a3};

        Test.startTest();

        List<List<Account>> chunkSizeSmallerThanListResult = TLList.split(testList, 2);
        List<List<Account>> chunkSizeLargerThanListResult = TLList.split(testList, 4);

        Test.stopTest();

        System.assertEquals(2, chunkSizeSmallerThanListResult.size(), 'The list should be split into two sub-lists');
        System.assertEquals(new Account[]{ a1, a2 }, chunkSizeSmallerThanListResult[0],
                'The first sub-list should contain the expected elements');
        System.assertEquals(new Account[]{ a3 }, chunkSizeSmallerThanListResult[1],
                'The second sub-list should contain the expected elements');

        System.assertEquals(1, chunkSizeLargerThanListResult.size(), 'The list should contain a single sub-list');
        System.assertEquals(new Account[]{ a1, a2, a3 }, chunkSizeLargerThanListResult[0],
                'The first sub-list should contain the expected elements');
    }

    // Tests adapted from https://github.com/ChuckJonas/apex-sort-sobs

    @IsTest
    static void sortString() {
        Account[] accs = new Account[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            accs.add(new Account(
                    Name = generateRandomString(30)
            ));
        }

        Test.startTest();
        TLList.sort(accs, Account.Name);
        Test.stopTest();

        Account previousAccount = accs.remove(0);
        for(Account acc : accs){
            System.assert(previousAccount.Name <= acc.Name);
            previousAccount = acc;
        }
    }

    @IsTest
    static void sortStringDesc() {
        Account[] accs = new Account[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            accs.add(new Account(
                    Name = generateRandomString(30)
            ));
        }

        Test.startTest();
        TLList.sortDesc(accs, Account.Name);
        Test.stopTest();

        Account previousAccount = accs.remove(0);
        for(Account acc : accs){
            System.assert(previousAccount.Name >= acc.Name);
            previousAccount = acc;
        }
    }

    @IsTest
    static void sortNumber() {
        Account[] accs = new Account[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            accs.add(new Account(
                    AnnualRevenue = Math.random() * 1000
            ));
        }

        Test.startTest();
        TLList.sort(accs, Account.AnnualRevenue);
        Test.stopTest();

        Account previousAccount = accs.remove(0);
        for(Account acc : accs){
            System.assert(previousAccount.AnnualRevenue <= acc.AnnualRevenue);
            previousAccount = acc;
        }
    }

    @IsTest
    static void sortNumberDesc() {
        Account[] accs = new Account[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            accs.add(new Account(
                    AnnualRevenue = Math.random() * 1000
            ));
        }

        Test.startTest();
        TLList.sortDesc(accs, Account.AnnualRevenue);
        Test.stopTest();

        Account previousAccount = accs.remove(0);
        for(Account acc : accs){
            System.assert(previousAccount.AnnualRevenue >= acc.AnnualRevenue);
            previousAccount = acc;
        }
    }

    @IsTest
    static void sortDate() {
        Opportunity[] opps = new Opportunity[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            opps.add(new Opportunity(
                    CloseDate = Date.today().addDays((Integer)Math.random() * 1000)
            ));
        }

        Test.startTest();
        TLList.sort(opps, Opportunity.CloseDate);
        Test.stopTest();

        Opportunity previousOpportunity = opps.remove(0);
        for(Opportunity opp : opps){
            System.assert(previousOpportunity.CloseDate <= opp.CloseDate);
            previousOpportunity = opp;
        }
    }

    @IsTest
    static void sortDateDesc() {
        Opportunity[] opps = new Opportunity[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            opps.add(new Opportunity(
                    CloseDate = Date.today().addDays((Integer)Math.random() * 1000)
            ));
        }

        Test.startTest();
        TLList.sortDesc(opps, Opportunity.CloseDate);
        Test.stopTest();

        Opportunity previousOpportunity = opps.remove(0);
        for(Opportunity opp : opps){
            System.assert(previousOpportunity.CloseDate >= opp.CloseDate);
            previousOpportunity = opp;
        }
    }

    @IsTest
    static void sortDatetime() {
        Task[] tasks = new Task[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            tasks.add(new Task(
                    ReminderDateTime = Datetime.now().addDays((Integer)Math.random() * 1000)
            ));
        }

        Test.startTest();
        TLList.sort(tasks, Task.ReminderDateTime);
        Test.stopTest();

        Task previousTask = tasks.remove(0);
        for(Task t : tasks){
            System.assert(previousTask.ReminderDateTime <= t.ReminderDateTime);
            previousTask = t;
        }
    }

    @IsTest
    static void sortDatetimeDesc() {
        Task[] tasks = new Task[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            tasks.add(new Task(
                    ReminderDateTime = Datetime.now().addDays((Integer)Math.random() * 1000)
            ));
        }

        Test.startTest();
        TLList.sortDesc(tasks, Task.ReminderDateTime);
        Test.stopTest();

        Task previousTask = tasks.remove(0);
        for(Task t : tasks){
            System.assert(previousTask.ReminderDateTime >= t.ReminderDateTime);
            previousTask = t;
        }
    }

    @IsTest
    static void sortBoolean() {
        Case[] cases = new Case[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            cases.add(new Case(
                    IsEscalated = Math.random() < .5 ? true : false
            ));
        }

        Test.startTest();
        TLList.sort(cases, Case.IsEscalated);
        Test.stopTest();

        Boolean switched = false;
        for(Case c : cases){
            //should only encounter falses from here on out
            if(c.IsEscalated == true){
                switched = true;
            }
            System.assert((!switched && !c.IsEscalated) || (switched && c.IsEscalated));
        }
    }

    @IsTest
    static void sortBooleanDesc() {
        Case[] cases = new Case[]{};
        for(Integer i = 0; i < SORT_RECORD_COUNT; i++){
            cases.add(new Case(
                    IsEscalated = Math.random() < .5 ? true : false
            ));
        }

        Test.startTest();
        TLList.sortDesc(cases, Case.IsEscalated);
        Test.stopTest();

        Boolean switched = false;
        for(Case c : cases){
            //should only encounter falses from here on out
            if(c.IsEscalated == false){
                switched = true;
            }
            System.assert((!switched && c.IsEscalated) || (switched && !c.IsEscalated));
        }
    }

    @IsTest
    static void sortRelationship() {
        Account[] accs = new Account[]{};
        for(Integer i = 0; i < 100; i++){
            accs.add(new Account(
                    Name = generateRandomString(30)
            ));
        }

        Contact[] contacts = new Contact[]{};
        for(Account acc : accs){
            for(Integer i = 0; i < 10; i++){
                contacts.add(new Contact(
                        Account = acc
                ));
            }
        }

        Test.startTest();
        TLList.sort(contacts, new SObjectField[]{ Contact.AccountId, Account.Name });
        Test.stopTest();

        Contact previousContact = contacts.remove(0);
        for(Contact c : contacts){
            System.assert(previousContact.Account.Name <= c.Account.Name);
            previousContact = c;
        }
    }

    @IsTest
    static void sortRelationshipDesc() {
        Account[] accs = new Account[]{};
        for(Integer i = 0; i < 100; i++){
            accs.add(new Account(
                    Name = generateRandomString(30)
            ));
        }

        Contact[] contacts = new Contact[]{};
        for(Account acc : accs){
            for(Integer i = 0; i < 10; i++){
                contacts.add(new Contact(
                        Account = acc
                ));
            }
        }

        Test.startTest();
        TLList.sortDesc(contacts, new SObjectField[]{ Contact.AccountId, Account.Name });
        Test.stopTest();

        Contact previousContact = contacts.remove(0);
        for(Contact c : contacts){
            System.assert(previousContact.Account.Name >= c.Account.Name);
            previousContact = c;
        }
    }

    private static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
}