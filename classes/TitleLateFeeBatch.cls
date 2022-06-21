/**
 * @description A batch process to update late fee on Account and create a new Assigned Fee record.
 * 				Requirements: 	https://acvauctions.atlassian.net/browse/TDO-22 
 * 								https://acvauctions.atlassian.net/browse/TDO-308
 * 
 * @author Manmeet Vaseer
 * @date 08/02/2021
 * 
 */
global with sharing class TitleLateFeeBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    static String TITLE_LATE_FEE_RT = 'Title_Late_Fee';
    
    Fee__c fee = null;
    Id titleLateFeeRecordTypeId;
    
    /**
     * Intiliaze the Batch Job.
     * 
     */
    public TitleLateFeeBatch()	{
        this.titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get(TITLE_LATE_FEE_RT).getRecordTypeId();

        String titleLateFeeName = ACVUtility.getSalesforceSettings(new Set<String>{'Title_Late_Fee'}).get('Title_Late_Fee').Value__c;
        List<Fee__c> fees = [SELECT Id, Name, Default_Amount__c, Max_Allowable_Fees__c FROM Fee__c WHERE Name = :titleLateFeeName AND Type__c = 'Seller Fee' LIMIT 1];
        if(fees == null || fees.size() == 0) throw new TitleLateFeeBatchException('No Fee record is found for Title Late Fee of type Seller Fee. Please, create the required record in the Fee__c object');
        this.fee = fees[0];
    }

    
    /**
     * Find all Cases where Title has not been received and enrolled in the late fee program.
     * 
     * @param BC Batch Context
     * @return  `Database.QueryLocator` All Cases where Title has not been received from Seller by the Title Due Date.
     */
    global Database.QueryLocator start(Database.BatchableContext BC){
        // Fetch all Cases where Title is past due and dealership is part of the late fee program.
        return Database.getQueryLocator(getQuery());
    }
    
    /**
     * Generate Title Late Fees.
     * 
     * @param BC Batch Context
     * @param cases A batch of cases that will be processed to calculate Title Late Fee.
     */
    global void execute(Database.BatchableContext BC, List<Case> cases){
        calculateLateFees(cases);
    }
    
    /**
     * Email SF Dev group when the batch is finished.
     * 
     * @param BC Batch Context
     */
    global void finish(Database.BatchableContext BC){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.componentName = 'TitleLateFeeBatch';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.POST_TRANSACTION};
        infoLog.location = 'TitleLateFeeBatch: '+ ACVUtility.currentLineNumber();
        infoLog.logLevel = SplunkHelper.LOGLEVEL.INFO;
        infoLog.message = 'TitleLateFeeBatch Finished';
        infoLog.sfObject = 'Assigned_Fee__c';
        infoLog.sfRecordId = BC.getJobId();
        infoLog.stackTrace = 'TitleLateFeeBatch.finish: '+ ACVUtility.currentLineNumber();
        infoLog.version = '1';
        infoLog.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        if(!Test.isRunningTest()){
        	SplunkHelper.processLog(infoLog);
        }
    } 
    
    /**
     * Fetch all Cases where Title is past due and dealership is part of the late fee program.
     * 
     * @return Query String
     */
    public String getQuery()	{
        String query = 'SELECT Id, Title_Received_Date__c, Title_Due_Date__c, CreatedDate, ' +
            'Seller_Dealership__c, Seller_Dealership__r.Late_Title_Fee_Eligible__c, Seller_Dealership__r.Late_Title_Fee_Start_Date__c, ' + 
            'Seller_Dealership__r.Unpaid_Title_Late_Fee__c, Seller_Dealership__r.Total_Billable_Amount__c, Seller_Dealership__r.Potential_Billable_Amount__c  FROM Case ' + 
            'WHERE Seller_Dealership__r.Late_Title_Fee_Eligible__c = true AND Title_Due_Date__c < TODAY';

		return query;        
    }
    
    /**
     * Generate Title Late Fees.
     * 
     * @param cases A batch of cases that will be processed to calculate Title Late Fee.
     */
    public void calculateLateFees(List<Case> cases) {
        List<Id> accountIds = new List<Id>();
        for(Case c : cases) accountIds.add(c.Seller_Dealership__c);
        
        // Get all unpaid fees related to each account
        List<Assigned_Fee__c> assignedFees = [SELECT Id, Fee_Status__c, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Fee__r.Max_Allowable_Fees__c, Fee__r.Default_Amount__c, 
                                              Case__c, Account__c, Account__r.Total_Billable_Amount__c, Account__r.Potential_Billable_Amount__c, Account__r.Unpaid_Title_Late_Fee__c 
                                              FROM Assigned_Fee__c WHERE Account__c IN :accountIds];
        
        /*
         * We have unpaid fees (as Assigned Fee) from all the cases. We will create a map of Cases and related Assigned Fees so
         * that we can calcuate total billiable amount for each Assigned Fee.
         */
        Map<Id, Assigned_Fee__c> caseIdAssignedFeeMap = new Map<Id, Assigned_Fee__c>();
        for(Assigned_Fee__c assignedFee : assignedFees)	caseIdAssignedFeeMap.put(assignedFee.Case__c, assignedFee);
        
        Map<Id, Account> updateAccounts = new Map<Id, Account>(); // use of Map to avoid duplicate entries
        Map<Id, Assigned_Fee__c> updateAssignedFees = new Map<Id, Assigned_Fee__c>(); // use of Map to avoid duplicate entries
        List<Assigned_Fee__c> newLateFees = new List<Assigned_Fee__c>();
     
        /*
         * The map will be used to determine if the fee (Assigned Fee) record already has been generated today.
         * If the record has already been generated today then we will add the record into this map.
         * This is to ensure that we only genrate one fee record a day (in case this batch procsess is run multiple times in a day).
         * 
         * A map of CaseId-AccountId for the Assigned Fee record.
         */
        Map<Id,Id> lateFeesAddedTodayCaseAccountMap = new Map<Id,Id>();
        for(Assigned_Fee__c af : [SELECT Id, Case__c, Account__c FROM Assigned_Fee__c WHERE LastModifiedDate = TODAY AND RecordTypeId = :this.titleLateFeeRecordTypeId AND Fee__c = :this.fee.Id])	{
            if(!Test.isRunningTest()) lateFeesAddedTodayCaseAccountMap.put(af.Case__c, af.Account__c);
        }
        
        /*
         * Calculate late fee for all the Accounts and related Assigned Fees.
         */
        for(Case aCase : cases)	{
            if(lateFeesAddedTodayCaseAccountMap.get(aCase.Id) == null)	{ // Update the AssignFee rec only if it is not already updated TODAY in the object.
                // Title is not received yet and the seller was enrolled in the late fee program before the Case was created.
                if(aCase.Title_Received_Date__c == null && aCase.Seller_Dealership__r.Late_Title_Fee_Start_Date__c < aCase.CreatedDate)	{ 
                    // Find out if the Assigned Fee record already exist that is associated with this Case
                    Assigned_Fee__c assignedFee = caseIdAssignedFeeMap.get(aCase.Id);
                    if(assignedFee == null)	{ 
                        addNewAssignedFee(aCase, updateAccounts, newLateFees);
                    }
                    else { 
                        updateExistingAssignedFee(assignedFee, aCase, updateAccounts, updateAssignedFees);
                    }                    
                } 
                else {
                    // Title has been received and Assigned Fee has Pending status.
                    titleReceived(caseIdAssignedFeeMap, aCase, updateAccounts, updateAssignedFees);
                }
            } 
        } 
        
        if(newLateFees.size() > 0) insert newLateFees;
        if(updateAccounts.size() > 0) update updateAccounts.values();
        if(updateAssignedFees.size() > 0) update updateAssignedFees.values();
    }

    private void addNewAssignedFee(Case aCase, Map<Id, SObject> updateAccounts, List<Assigned_Fee__c> newLateFees)	{
        Account sellerDealershipAcct = (Account) updateAccounts.get(aCase.Seller_Dealership__c);   
        if(sellerDealershipAcct == null) {
            sellerDealershipAcct = aCase.Seller_Dealership__r;
            updateAccounts.put(aCase.Seller_Dealership__c, aCase.Seller_Dealership__r);
        }
        
        Assigned_Fee__c newAssignedFee = new Assigned_Fee__c(Case__c=aCase.Id, Account__c=aCase.Seller_Dealership__c, Override_Amount__c=this.fee.Default_Amount__c,
                                                             Fee__c=this.fee.Id, Fee_Status__c='Fee Pending', RecordTypeId=this.titleLateFeeRecordTypeId,
                                                             Total_Billable_Amount__c=this.fee.Default_Amount__c, Potential_Billable_Amount__c=this.fee.Default_Amount__c);
        
        if(sellerDealershipAcct.Total_Billable_Amount__c == null) sellerDealershipAcct.Total_Billable_Amount__c = 0;
        if(sellerDealershipAcct.Potential_Billable_Amount__c == null) sellerDealershipAcct.Potential_Billable_Amount__c = 0;
        
        sellerDealershipAcct.Total_Billable_Amount__c = sellerDealershipAcct.Total_Billable_Amount__c + this.fee.Default_Amount__c;
        sellerDealershipAcct.Potential_Billable_Amount__c = sellerDealershipAcct.Potential_Billable_Amount__c + this.fee.Default_Amount__c;
        sellerDealershipAcct.Unpaid_Title_Late_Fee__c = true;    
        
        newLateFees.add(newAssignedFee);                                           
    }
    
    private void updateExistingAssignedFee(Assigned_Fee__c assignedFee, Case aCase, Map<Id, Account> updateAccounts, Map<Id, Assigned_Fee__c> updateAssignedFees)	{
        Account sellerDealershipAcct = (Account) updateAccounts.get(aCase.Seller_Dealership__c);   
        
        if(sellerDealershipAcct == null) {
            sellerDealershipAcct = aCase.Seller_Dealership__r;
            updateAccounts.put(aCase.Seller_Dealership__c, aCase.Seller_Dealership__r);
        }

        if(sellerDealershipAcct.Total_Billable_Amount__c == null) sellerDealershipAcct.Total_Billable_Amount__c = 0;
        if(sellerDealershipAcct.Potential_Billable_Amount__c == null) sellerDealershipAcct.Potential_Billable_Amount__c = 0;
        if(assignedFee.Total_Billable_Amount__c == null) assignedFee.Total_Billable_Amount__c = 0;
        if(assignedFee.Potential_Billable_Amount__c == null) assignedFee.Potential_Billable_Amount__c = 0;
                
        if(assignedFee.Fee_Status__c == 'Fee Pending')	{
            if((assignedFee.Total_Billable_Amount__c + this.fee.Default_Amount__c) < this.fee.Max_Allowable_Fees__c)	{ // max late fee limit not reached
                assignedFee.Total_Billable_Amount__c = assignedFee.Total_Billable_Amount__c + this.fee.Default_Amount__c;
                sellerDealershipAcct.Total_Billable_Amount__c = sellerDealershipAcct.Total_Billable_Amount__c + this.fee.Default_Amount__c;
                sellerDealershipAcct.Unpaid_Title_Late_Fee__c = true;    
            }
            else { // max late fee limit reached
                assignedFee.Fee_Status__c = 'Fee Assessed';
                assignedFee.Date_Fee_Accessed__c = System.today();
                assignedFee.Total_Billable_Amount__c = this.fee.Max_Allowable_Fees__c;
                sellerDealershipAcct.Total_Billable_Amount__c = sellerDealershipAcct.Total_Billable_Amount__c + this.fee.Default_Amount__c - this.fee.Max_Allowable_Fees__c;
                if(sellerDealershipAcct.Total_Billable_Amount__c <= 0)	{
                    sellerDealershipAcct.Total_Billable_Amount__c = 0;
                    sellerDealershipAcct.Unpaid_Title_Late_Fee__c = false;
                }
                else sellerDealershipAcct.Unpaid_Title_Late_Fee__c = true;
            }
        }
        
        // Once the max late fee limit has been reached, what is the potential late fee amount we could have charged per Title.
        assignedFee.Potential_Billable_Amount__c = assignedFee.Potential_Billable_Amount__c + this.fee.Default_Amount__c;                                           
        sellerDealershipAcct.Potential_Billable_Amount__c = sellerDealershipAcct.Potential_Billable_Amount__c + this.fee.Default_Amount__c;                                           
        
        updateAssignedFees.put(assignedFee.Id, assignedFee);
    }
    
    private void titleReceived(Map<Id, Assigned_Fee__c> caseIdAssignedFeeMap, Case aCase, Map<Id, Account> updateAccounts, Map<Id, Assigned_Fee__c> updateAssignedFees)	{
        Assigned_Fee__c assignedFee = caseIdAssignedFeeMap.get(aCase.Id);
        if(aCase.Title_Received_Date__c != null && assignedFee != null && assignedFee.Fee_Status__c == 'Fee Pending')	{
            Account sellerDealershipAcct = (Account) updateAccounts.get(aCase.Seller_Dealership__c);   
            if(sellerDealershipAcct == null) {
                sellerDealershipAcct = aCase.Seller_Dealership__r;
                updateAccounts.put(aCase.Seller_Dealership__c, aCase.Seller_Dealership__r);
            }
                        
            assignedFee.Fee_Status__c = 'Fee Assessed';
            assignedFee.Date_Fee_Accessed__c = System.today();
            sellerDealershipAcct.Total_Billable_Amount__c = sellerDealershipAcct.Total_Billable_Amount__c - assignedFee.Total_Billable_Amount__c;
            if(sellerDealershipAcct.Total_Billable_Amount__c <= 0)	{
                sellerDealershipAcct.Total_Billable_Amount__c = 0;
                sellerDealershipAcct.Unpaid_Title_Late_Fee__c = false;
            }
            else sellerDealershipAcct.Unpaid_Title_Late_Fee__c = true;
            
            updateAssignedFees.put(assignedFee.Id, assignedFee);                                                                   
        }        
    }
    
    public class TitleLateFeeBatchException extends Exception {}
}