/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BatchInsertAlertsView implements Database.AllowsCallouts, Database.Batchable<EXPRN__Alerts_View__c>, Database.Stateful {
    global System.Iterable alertsView;
    global Map<String,Set<Id>> AlertsViewAccounts;
    global BatchInsertAlertsView() {

    }
    global void execute(Database.BatchableContext info, List<EXPRN__Alerts_View__c> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global System.Iterable start(Database.BatchableContext info) {
        return null;
    }
}
