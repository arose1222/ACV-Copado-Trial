/* DO NOT USE */
global class Pinned10DayRollOverBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public static List<String> errorList = new List<String>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        // String query = 'SELECT Id, Expiration_Date__c, Recommended_Price_Active__c, Pricing_Status__c FROM Recommended_Price__c WHERE Expiration_Date__c <= TODAY AND Recommended_Price_Active__c = TRUE AND Pricing_Status__c != \'Expired\'';
        String query = 'select DueDate, Original_Due_Date__c, work_type_name__c, status from serviceappointment WHERE work_type_name__c in (\'Auction Site\', \'Dealer\', \'Auction Off-Lease\') AND status in (\'New\', \'Scheduled\', \'Cannot Complete\') AND Original_Due_Date__c < TODAY';
        // return
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        // scheduling
        Pinned10DayRollOverBatch p10drob = new Pinned10DayRollOverBatch();
        Database.executeBatch(p10drob, 200);
    }

    global void execute(Database.BatchableContext bc, List<ServiceAppointment> scope){
        //batch process
        for (ServiceAppointment sa : scope) {
            // Add 10 days to Original_Due_Date__c
            //sa.Original_Due_Date__c = sa.Original_Due_Date__c.addDays(10);
            // Because Original_Due_Date__c was extended 10 days, Pinn the Service Appointment
            //sa.FSL__Pinned__c = true;
        }

        // update records
        Database.SaveResult[] mesgList = Database.update(scope, false); // try to update docs
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                // error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                Pinned10DayRollOverBatch.errorList.add(errMesg);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}