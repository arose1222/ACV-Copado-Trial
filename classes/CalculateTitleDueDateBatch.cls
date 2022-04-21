/**
 * @description A batch process to backfill Title Due Date on Case.
 * 				Due to a bug, there were a lots of missing Title Due Date on Case. 
 * 				This batch file will recalcuate the Title Due Date on case based on the https://acvauctions.atlassian.net/browse/TDO-26 requirements.
 * 
 * To run this batch manually:
 * CalculateTitleDueDateBatch be = new CalculateTitleDueDateBatch(45);
 * database.executeBatch(be);
 * 
 * @author Manmeet Vaseer
 * @date 02/11/2022
 * 
 * @history
 * 
 */
global with sharing class CalculateTitleDueDateBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public static String SPLUNK_COMPONENT_NAME = 'Calculate_Title_Due_Date_Batch';

    private static SplunkLogging sl = new SplunkLogging(SPLUNK_COMPONENT_NAME);
    
    private String lastNumDays; // fetch the Title Cases for Last X Number of Days.
    private Id caseRecordTypeId;
        
    /**
     * Intiliaze the Batch Job.
     * 
     * @param lastNumDays It behaves likes last_n_days (SOQL). 
     * 					  If lastNumDays=30, the batch query is going to fetch all the recrods for last 30 days.
     */
    public CalculateTitleDueDateBatch(Integer lastNDays)	{
        lastNumDays = String.valueOf(lastNDays);
        caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CalculateTitleDueDateHelper.TITLE_INFORMATION_RT).getRecordTypeId();
    }
    
    /**
     * Find LAST_N_DAYS Cases where Title Due Date is not set.
     * 
     * @param BC Batch Context
     * @return  `Database.QueryLocator` All Cases where Title Due Date is not set.
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(getQuery());
    }
    
    /**
     * Generate Title Late Fees.
     * 
     * @param BC Batch Context
     * @param cases A batch of cases that will be processed to calculate Title Late Fee.
     */
    global void execute(Database.BatchableContext BC, List<Case> cases){
        try {
        	calculateTitleDueDate(cases);
        }
        catch(Exception e)	{
            sl.error(SPLUNK_COMPONENT_NAME, ACVUtility.currentLineNumber(), 'Case__c', '', SplunkHelper.CONTEXT_TYPE.BATCH, 'Batch failed: ' + e.getMessage(), e.getStackTraceString());
            throw e;
        }
    }
    
    /**
     * Email SF Dev group when the batch is finished.
     * 
     * @param BC Batch Context
     */
    global void finish(Database.BatchableContext BC){
        sl.info(SPLUNK_COMPONENT_NAME, ACVUtility.currentLineNumber(), 'Batch Id', BC.getJobId(), SplunkHelper.CONTEXT_TYPE.BATCH, 'Batch finished.', 'CalculateTitleDueDateBatch.finish');
    } 
    
    /**
     * Fetch all Cases for LAST_N_DAYS where Title Due Date is not set.
     * 
     * @return Query String
     */
    public String getQuery()	{
        String query = 'SELECT Id, Status, CreatedDate, Seller_Dealership__c, Title_Due_Date__c, Title_Attached__c FROM Case ' + 
            'WHERE Title_Due_Date__c = null AND Auction_End__c != null AND RecordTypeId = \'' + caseRecordTypeId + '\' AND CreatedDate = LAST_N_DAYS:' + lastNumDays;

		return query;        
    }
    
    /**
     * @description Set Title Due Date on Case.
     * 
     * @param cases A list of Title Cases to update.
     * 
     */
    public void calculateTitleDueDate(List<Case> cases){        
        String classMethod = 'CalculateTitleDueDateBatch.calculateTitleDueDate';
        Map<Id, Account> accountsForNewCases = CalculateTitleDueDateHelper.getAccountsFor(cases);
        
        List<Case> updatedCases = new List<Case>();
        for(Case c :cases){
            sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 
                        'Case Id: ' + c.Id + ', c.Status: ' + c.Status + ', c.Seller_Dealership__c: ' + c.Seller_Dealership__c);
            if(!c.Status.contains('Close'))	{
                Account acctNew = accountsForNewCases.get(c.Seller_Dealership__c);
                if(acctNew != null) sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'acctNew: ' + acctNew);
                
                String[] sellerStates = CalculateTitleDueDateHelper.getSellerLegalOrBillingState(null, acctNew);
                String sellerStateNew = sellerStates[1];
                
                boolean isSellerChanged = (sellerStateNew != null);
                sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'isSellerChanged: ' + isSellerChanged + ', sellerStates: ' + sellerStates);
                if(isSellerChanged)	{
                    CalculateTitleDueDateHelper.setTitleDueDate(sellerStateNew, c, c.CreatedDate);
                    updatedCases.add(c);
                }
            }
        }  
        
        if(updatedCases.size() > 0) update updatedCases;
        sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'Total Records Upated: ' + updatedCases.size());
        
        sl.saveLogDebugMessages();
    }    
    
}