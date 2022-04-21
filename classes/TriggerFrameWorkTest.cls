@IsTest
public class TriggerFrameWorkTest {

    public static Set<String> lastNamesSeen = new Set<String>();

    public class TestHandler extends TriggerInterface {

        public override void afterDelete(List<sObject> oldList) {
            handle(oldList);
        }

        public override void afterDelete(Map<Id,sObject> oldList) {
            handle(oldList);
        }

        public override void afterInsert(List<sObject> newList) {
            handle(newList);
        }

        public override void afterInsert(Map<Id,sObject> newList) {
            handle(newList);
        }

        public override void afterUndelete(List<sObject> newList) {
            handle(newList);
        }

        public override void afterUndelete(Map<Id, sObject> newList) {
            handle(newList);
        }

        public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
            handle(newList);
        }

        public override void afterUpdate(Map<Id, sObject> oldList, Map<Id, sObject> newList) {
            handle(newList);
        }

        public override void beforeDelete(List<sObject> oldList) {
            handle(oldList);
        }

        public override void beforeDelete(Map<Id, sObject> oldList) {
            handle(oldList);
        }

        public override void beforeInsert(List<sObject> newList) {
            handle(newList);
        }

        public override void beforeUndelete(List<sObject> newList) {
            handle(newList);
        }

        public override void beforeUndelete(Map<Id, sObject> newList) {
            handle(newList);
        }

        public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
            handle(newList);
        }

        public override void beforeUpdate(Map<Id, sObject> oldList, Map<Id, sObject> newList) {
            handle(newList);
        }

        private void handle(List<sObject> aList) {
            List<Account> cList = (List<Account>)aList;
            for(Account c : cList) {
                TriggerFrameWorkTest.lastNamesSeen.add(c.Name);
            }
        }

        private void handle(Map<Id, sObject> aList) {
            handle(aList.values());
        }
    }

    @IsTest
    public static void basic() {
        String mockMetaDataString = '';

        Map<String, List<Boolean>> events = new Map<String, List<Boolean>> {
                'AfterDelete' => new List<Boolean>{false, false, false, true, false},
                'AfterInsert' => new List<Boolean>{false, false, true, false, false},
                'AfterUndelete' => new List<Boolean>{false, false, false, false, true},
                'AfterUpdate' => new List<Boolean>{false, true, false, false, false},
                'BeforeDelete' => new List<Boolean>{true, false, false, true, false},
                'BeforeInsert' => new List<Boolean>{true, false, true, false, false},
                'BeforeUndelete' => new List<Boolean>{true, false, false, false, true},
                'BeforeUpdate' => new List<Boolean>{true, true, false, false, false}
        };

        for(String event : events.keySet()) {
            if(event == 'AfterDelete'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"After_Delete__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'AfterInsert'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"After_Insert__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'AfterUndelete'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"After_Undelete__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'AfterUpdate'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"After_Update__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'BeforeDelete'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"Before_Delete__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'BeforeInsert'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"Before_Insert__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'BeforeUndelete'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"Before_Undelete__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            if(event == 'BeforeUpdate'){
                mockMetaDataString += '{"DeveloperName": "TestHandler' + event + '", '
                    + '"NamespacePrefix": "",'
                    + '"Before_Update__c": "true", '
                    + '"sObject__c": "Account", "Class_Name__c": "TriggerFrameWorkTest.TestHandler"},';
            }
            
        }

        mockMetaDataString = '[' + mockMetaDataString.substringBeforeLast(',') + ']';

        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        TriggerFrameWork manager = new TriggerFrameWork(Account.sObjectType);

        String lastName = 'Simpson';

        List<Account> AccountList = new List<Account>{new Account(Name = lastName)};
        insert AccountList;
        Map<Id, Account> AccountMap = new Map<Id, Account>(AccountList);

        for(String event : events.keySet()) {
            List<Boolean> flags = events.get(event);
            lastNamesSeen = new Set<String>();
            manager.handle(flags[0], flags[1], flags[2], flags[3], flags[4], AccountList, AccountList, AccountMap, AccountMap);

            System.assert(lastNamesSeen.contains(AccountList[0].Name));
        }

    }
    @IsTest
    public static void noSuchHandler() {
        String mockMetaDataString = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"After_Update__c": "true", '
                + '"sObject__c": "Account", "Class_Name__c": "NoSuchClass"}]';

        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        TriggerFrameWork manager = new TriggerFrameWork(Account.sObjectType);

        String lastName = 'Simpson';

        List<Account> AccountList = new List<Account>{new Account(name = lastName)};
        insert AccountList;
        Map<Id, Account> AccountMap = new Map<Id, Account>(AccountList);
        try {
            manager.handle(false, true, false, false, false, AccountList, AccountList,AccountMap,AccountMap);
        } catch(TriggerFrameWork.TriggerException e) {
            // expected this!
            return;
        }

        System.assert(false, 'Expected a ClassNotFoundException');
    }

    @IsTest
    public static void noHandlers() {
        TriggerFrameWork.mockMetaData = new List<TriggerHandler__mdt>();

        TriggerFrameWork manager = new TriggerFrameWork(Account.sObjectType);

        String lastName = 'Simpson';

        List<Account> AccountList = new List<Account>{new Account(Name = lastName)};
        insert AccountList;
        Map<Id, Account> AccountMap = new Map<Id, Account>(AccountList);
        manager.handle(false, true, false, false, false, AccountList, AccountList,AccountMap,AccountMap);
        // no result
    }

    @IsTest
    public static void noHandlersForThisEvent() {
        String mockMetaDataString = '[{"DeveloperName": "TestHandler", '
                + '"NamespacePrefix": "Nebula_Tools",'
                + '"After_Update__c": "true", '
                + '"sObject__c": "Account", "Class_Name__c": "NoSuchClass"}]';

        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>)JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        TriggerFrameWork manager = new TriggerFrameWork(Account.sObjectType);

        String lastName = 'Simpson';

        List<Account> AccountList = new List<Account>{new Account(Name = lastName)};
        insert AccountList;
        Map<Id, Account> AccountMap = new Map<Id, Account>(AccountList);
        manager.handle(true, true, false, false, false, AccountList, AccountList,AccountMap,AccountMap);
        // no result
    }

    @IsTest
    public static void queryHandlers() {

        TriggerFrameWork manager = new TriggerFrameWork(Account.sObjectType);

        String lastName = 'Simpson';

        List<Account> AccountList = new List<Account>{new Account(Name = lastName)};
        insert AccountList;
        Map<Id, Account> AccountMap = new Map<Id, Account>(AccountList);
        manager.handle(false, true, false, false, false, AccountList, AccountList,AccountMap,AccountMap);
        // no result
    }

    @IsTest
    public static void lineCoverageOnTriggerInterface() {

        TriggerInterface t = new TriggerInterface();
        t.afterDelete(new List<SObject>());
        t.afterDelete(new Map<Id, SObject>());
        t.afterInsert(new List<SObject>());
        t.afterInsert(new Map<Id, SObject>());
        t.afterUndelete(new List<SObject>());
        t.afterUndelete(new Map<Id, SObject>());
        t.afterUpdate(new List<SObject>(), new List<SObject>());
        t.afterUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
        t.beforeDelete(new List<SObject>());
        t.beforeDelete(new Map<Id, SObject>());
        t.beforeInsert(new List<SObject>());
        t.beforeUndelete(new List<SObject>());
        t.beforeUndelete(new Map<Id, SObject>());
        t.beforeUpdate(new List<SObject>(), new List<SObject>());
        t.beforeUpdate(new Map<Id, SObject>(), new Map<Id, SObject>());
    }
}