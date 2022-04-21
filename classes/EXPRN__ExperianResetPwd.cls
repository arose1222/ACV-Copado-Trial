/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ExperianResetPwd implements Database.AllowsCallouts, Database.Batchable<EXPRN__BIQ_Configuration__c>, Database.Stateful {
    global String authorizationHeader;
    global System.Iterable biqConfig;
    global String contentheader;
    global String sEncodedBIQCredBIQInternational;
    global String sEncodedBIQCredBIQWSPWD;
    global String sEncodedBIQCredDecisioning;
    global String sEncodedBIQCredNetConnect;
    global String sEncodedBIQUserId;
    global String strEndpointURL;
    global String strPwdTemplate;
    global ExperianResetPwd() {

    }
    global void execute(Database.BatchableContext BC, List<EXPRN__BIQ_Configuration__c> scope) {

    }
    global void finish(Database.BatchableContext BC) {

    }
    global System.Iterable start(Database.BatchableContext info) {
        return null;
    }
}
