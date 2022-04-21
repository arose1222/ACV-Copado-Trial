/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BatchInsertDecisions implements Database.AllowsCallouts, Database.Batchable<SObject> {
    global String creditPolicyId;
    global Set<String> setAccountId;
    global String strQuery;
    global BatchInsertDecisions(String strQuery, Set<String> setAccountId, String creditPolicyId) {

    }
    global void execute(Database.BatchableContext info, List<Account> listAccount) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
