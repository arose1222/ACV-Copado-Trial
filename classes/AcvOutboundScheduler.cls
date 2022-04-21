global class AcvOutboundScheduler extends SchedulingInterface {
    public override void executeScheduledLogic() {
        BatchRecommendPriceOutbound rpBatchClass = new BatchRecommendPriceOutbound();
        database.executebatch(rpBatchClass,200);

        /*BatchTitleOutbound titleBatchClass = new BatchTitleOutbound();
        database.executebatch(titleBatchClass,200);*/

        // BatchCreateTransRequestOutbound createTransBatchClass = new BatchCreateTransRequestOutbound();
        // database.executebatch(createTransBatchClass,200);
        
        BatchTransRequestOutbound transBatchClass = new BatchTransRequestOutbound();
        database.executebatch(transBatchClass,200);

        BatchUnwindOutbound unwindBatchClass = new BatchUnwindOutbound();
        database.executebatch(unwindBatchClass,200);
    }
    
}