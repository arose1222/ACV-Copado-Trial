global class BatchCreateTransRequestOutbound implements Database.Batchable<sObject>, Schedulable{
    String query;
    
    global BatchCreateTransRequestOutbound() {
        Id transRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        query = 'SELECT id, status, Auction_Number_Case__c, Buyer_External_Id__c, Buyer_Name__c, Default_Delivery_Address__c, Default_Delivery_City__c, Default_Delivery_Country__c, Delivery_Address_Name__c,Default_Delivery_Postal_Code__c, Default_Delivery_State__c, Pickup_Address__c, Default_Pickup_City__c, Default_Pickup_Country__c, Pickup_Address_Name__c, Default_Pickup_Postal_Code__c,Default_Pickup_State__c, Posted_Price__c, Buyer_Price__c, Seller_External_Id__c, Seller_Name__c, Vehicle_Class_Name__c, Vehicle_Is_Oversize__c, Vehicle_Make__c, Vehicle_Model__c, Vehicle_VIN__c, Vehicle_Year__c, Vehicle_External_Id__c, Price_Pre_Promotion__c FROM Case WHERE RecordTypeId = \''+transRecordTypeId+'\' AND Send_To_ACV__c = true AND ACV_Transportation_Request_Id__c = null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(SchedulableContext sc) {
        BatchCreateTransRequestOutbound batchClass = new BatchCreateTransRequestOutbound();
        database.executebatch(batchClass,200);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Case> lTransCases = (List<Case>)scope;
        System.enqueueJob(new AcvIntegrationQueueableJob('Create Transportation Request', lTransCases, null));   
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}