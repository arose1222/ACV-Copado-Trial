/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class BatchInsertDecisionAndScoring implements Database.AllowsCallouts, Database.Batchable<SObject>, Database.Stateful {
    global Id batchProcessId;
    global String sBatchType;
    global String sCreditPolicy;
    global String sQuery;
    global String sScoringModel;
    global BatchInsertDecisionAndScoring(String batchType, String creditPolicy, String scoringModel, String strQuery) {

    }
    global BatchInsertDecisionAndScoring(String batchType, String creditPolicy, String scoringModel, String strQuery, Id ProcessId) {

    }
    global void execute(Database.BatchableContext info, List<Account> listAccount) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return null;
    }
}
