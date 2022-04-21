/**
 * @description A batch process to backfill Title__c field on Case object.
 * 				We added the new Title__c field on the Case object and modified the TitleService to populate this field.
 * 
 * To run this batch manually:
 * PopulateCaseTitleFieldBatch be = new PopulateCaseTitleFieldBatch(10);
 * database.executeBatch(be);
 * 
 * @author Manmeet Vaseer
 * @date 03/08/2022
 * 
 * @history
 * 
 */
global with sharing class PopulateCaseTitleFieldBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private String lastNumDays; // fetch the Title Cases for Last X Number of Days.
    private Id caseRecordTypeId;
        
    /**
     * Intiliaze the Batch Job.
     * 
     * @param lastNumDays It behaves likes last_n_days (SOQL). 
     * 					  If lastNumDays=30, the batch query is going to fetch all the recrods for last 30 days.
     */
    public PopulateCaseTitleFieldBatch(Integer lastNDays)	{
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
     * Populate Title Ids on Case obj.
     * 
     * @param BC Batch Context
     * @param titles A batch of Titles that will be processed.
     */
    global void execute(Database.BatchableContext BC, List<Title__c> titles){
        try {
        	populateTitleIdOnCase(titles);
        }
        catch(Exception e)	{
            throw e;
        }
    }
    
    /**
     * Email SF Dev group when the batch is finished.
     * 
     * @param BC Batch Context
     */
    global void finish(Database.BatchableContext BC){
    } 
    
    /**
     * Fetch all Cases for LAST_N_DAYS where Title Due Date is not set.
     * 
     * @return Query String
     */
    public String getQuery()	{
        String query = 'SELECT Id, Case__c FROM Title__c WHERE CreatedDate = LAST_N_DAYS:' + lastNumDays;

		return query;        
    }
    
    /**
     * @description Set Title Due Date on Case.
     * 
     * @param cases A list of Title Cases to update.
     * 
     */
    public void populateTitleIdOnCase(List<Title__c> titles){ 
        Map<Id, Title__c> caseIdTitleMap = new Map<Id, Title__c>();
        for(Title__c t : titles) caseIdTitleMap.put(t.Case__c, t);
                   
        List<Case> updatedCases = new List<Case>();
        List<Case> associatedCases = [SELECT Id, Title__c FROM Case WHERE Title__c = null AND Id IN : caseIdTitleMap.keySet()];
        for(Case c : associatedCases)	{
            Title__c title = caseIdTitleMap.get(c.Id);
            c.Title__c = title.Id;
            
            updatedCases.add(c);
        }
        
        update updatedCases;
    }        
}