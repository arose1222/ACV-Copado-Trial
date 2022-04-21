/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CourseEnrollmentTriggerBatch implements Database.Batchable<SObject>, Database.Stateful {
    global Integer recordsProcessed;
    global void execute(Database.BatchableContext bc, List<docebo_v3__CourseEnrollment__c> enrollments) {

    }
    global void finish(Database.BatchableContext bc) {

    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return null;
    }
}
