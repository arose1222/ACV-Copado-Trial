global class SchedulableAccountUnwindHandler extends SchedulingInterface {
    public override void executeScheduledLogic() {
        //String query = 'SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c FROM Account WHERE MTD_Purchases__c != NULL AND Purchase_Last_Month__c != NULL AND ((MTD_Purchases__c != 0) OR (Purchase_Last_Month__c != 0))';
        //'SELECT Id, Purchase_Last_Month__c, MTD_Purchases__c FROM Account WHERE MTD_Purchases__c != NULL AND Purchase_Last_Month__c != NULL AND ((MTD_Purchases__c = 0 AND Purchase_Last_Month__c != 0) OR (MTD_Purchases__c != 0 AND Purchase_Last_Month__c = 0) OR (MTD_Purchases__c != 0 AND Purchase_Last_Month__c != 0))';
        AccountUpdateLogisticsUnwindHandlerBatch auluhb = new AccountUpdateLogisticsUnwindHandlerBatch();
        Database.executeBatch(auluhb, 1);
    }
}