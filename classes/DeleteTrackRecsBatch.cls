// DeleteTrackRecsBatch.runThisBatch(5);
global class DeleteTrackRecsBatch implements Database.Batchable<sObject> {
    static Integer batchSize = 200;
    static Integer recsToDelWithSortOrder = 5;
    static Integer splitINQuery = 100; // number of IDs to put in a single 'IN' soql statements.
    
    public static void runThisBatch(Integer sortOrderToDel)	{
         recsToDelWithSortOrder = sortOrderToDel;
         Database.executeBatch(new DeleteTrackRecsBatch(), batchSize);
    }
    
    global List<SObject> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return deleteTrackRecsWithSortOrder(recsToDelWithSortOrder);
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        // process each batch of records
        delete records;
    }    
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        /*
        aAJ = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    	if(aAJ != null && statusSObject!=null && statusSObjectFieldName!=null) {
        	statusSObject.put(statusSObjectFieldName,aAJ.Status);
            update statusSObject;
		*/
    }    
    
    //SELECT Id, Obj_Id__c, Obj_Name__c, Sort_Order__c, LastModifiedById FROM Track_Id_to_Delete__c ORDER BY Sort_Order__c DESC
    static private List<SObject> deleteTrackRecsWithSortOrder(Integer recsToDelWithSortOrder)	{
        List<Track_Id_to_Delete__c> trackRecs = [SELECT Id, Obj_Id__c, Obj_Name__c, Sort_Order__c, LastModifiedById FROM Track_Id_to_Delete__c WHERE Sort_Order__c = :recsToDelWithSortOrder];

        Integer splitNum = splitINQuery;
		List<SObject> returnRecordsToDelete = queriesForRecs(splitNum, trackRecs);
        returnRecordsToDelete.addAll(trackRecs);
        
        return returnRecordsToDelete;
    }

    /**
     * splitNum is used to split the trackRecs into multiple 'IN' queries so that it can handle 1000s of records.
     * 
     */
    private static List<SObject> queriesForRecs(Integer splitNum, List<Track_Id_to_Delete__c> trackRecs)	{
        List<SObject> returnRecordsToDelete = new List<SObject>();
        
        Integer counter = 0;
        String objNamePrev = '';
        String sql = '';
        for(Track_Id_to_Delete__c trackRec : trackRecs)	{
            String objName = trackRec.Obj_Name__c;
            String objId = trackRec.Obj_Id__c;
            
            if(objNamePrev != objName || counter >= splitNum)	{
                if(sql != null && sql.length() > 0) {
                    sql = sql.removeEnd(',');
                    sql = sql + ')';
					//System.debug('* * * sql: ' + sql);
                    returnRecordsToDelete.addAll(Database.query(sql));
                }
                counter = 0;
            	sql = 'SELECT Id FROM ' + objName + ' WHERE Id IN (';
            }
            
            sql = sql + '\'' + objId + '\',';
            counter = counter + 1;
            objNamePrev = objName;
        }
        
        sql = sql.removeEnd(',');
        sql = sql + ')';
        returnRecordsToDelete.addAll(Database.query(sql));
		//System.debug(returnRecordsToDelete.size() + ' * * * sql: ' + sql);
        
        return returnRecordsToDelete;
    }
  
}