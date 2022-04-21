global class BatchTransRequestOutbound implements Database.Batchable<sObject>, Schedulable{
    
    String query;
    
    global BatchTransRequestOutbound() {
        Id transRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        query = 'SELECT id, status, Auction_Number_Case__c, Date_Delivered_Actual__c, Date_Picked_Up__c, Date_Last_Posted__c, Expected_Delivery__c, ACV_Transportation_Request_Id__c, Date_First_Posted_Portal__c, Description, Posted_Price__c, Buyer_Price__c, Transporter_Name__c, Vehicle_Abandoned__c FROM Case WHERE RecordTypeId = \''+transRecordTypeId+'\' AND Send_To_ACV__c = true AND ACV_Transportation_Request_Id__c != null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        BatchTransRequestOutbound batchClass = new BatchTransRequestOutbound();
        database.executebatch(batchClass,200);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> lTransCases = (List<Case>)scope;
        System.enqueueJob(new AcvIntegrationQueueableJob('Update Transportation Request', lTransCases, null));   
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}