/**
 * @description https://acvauctions.atlassian.net/browse/TDO-26 requirements.
 * Update Title Due Date field on new Case based on Seller Account's Legal/Billing State.
 * Also, update Title Due Date field on existing Case when Title Absent (Title_Attached__c) flag is changed on Case.
 * 
 * @author Amul
 * @date 05/10/2021
 * 
 * @history 06/09/2021 Manmeet Vaseer - Added logic to handle Legal vs Billing state.
 * 
 */
public class CalculateTitleDueDateCase extends TriggerInterface {

    /**
     * Invoked only for Case Before Insert
     */ 
    public override void beforeInsert(List<SObject> newCaseList)    {
        calculateTitleDueDateOnCaseInsert(newCaseList);
    }
    
    /**
     * Invoked only for Case Before Update
     */ 
    public override void beforeUpdate(Map<Id,SObject> oldMap , Map<Id,SObject> newMap)  {
        calculateTitleDueDateOnCaseUpdate((Map<Id,Case>)oldMap,(Map<id,Case>)newMap);
    }
    
    /**
     * @description Set Title Due Date on Case Insert based on Seller Account's Legal/Billing State.
     * 
     * @param newCases A list of New Case.
     * 
     */
    private static void calculateTitleDueDateOnCaseInsert(List<Case> newCases){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CalculateTitleDueDateHelper.TITLE_INFORMATION_RT).getRecordTypeId();
        
        Map<Id, Account> accountsForNewCases = CalculateTitleDueDateHelper.getAccountsFor(newCases);
        
        for(Case c :newCases){
            if(c.RecordTypeId == caseRecordTypeId && c.Auction_End__c != null)	{
                Account acctNew = accountsForNewCases.get(c.Seller_Dealership__c);
                
                String[] sellerStates = CalculateTitleDueDateHelper.getSellerLegalOrBillingState(null, acctNew);
                String sellerStateNew = sellerStates[1];
                
                boolean isSellerChanged = (sellerStateNew != null);
                if(isSellerChanged)	{
                    CalculateTitleDueDateHelper.setTitleDueDate(sellerStateNew, c);
                }
            }
        }        
    }
    
    /**
     * @description Set Title Due Date on Case Update when Title Absent (Title_Attached__c) flag is changed.
     * 
     * @param oldCaseMap A map of Old Case.
     * @param newCaseMap A list of New Case.
     * 
     */
    private static void calculateTitleDueDateOnCaseUpdate(Map<Id,Case> oldCaseMap, Map<Id,Case> newCaseMap){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CalculateTitleDueDateHelper.TITLE_INFORMATION_RT).getRecordTypeId();
        
        List<Case> newCases = (List<Case>)newCaseMap.values();
        Map<Id, Account> accountsForNewCases = CalculateTitleDueDateHelper.getAccountsFor(newCases);
        
        for(Case c :newCases){
            Case oldCase = oldCaseMap.get(c.Id);
            if(c.RecordTypeId == caseRecordTypeId && c.Auction_End__c != null && c.Title_Attached__c != oldCase.Title_Attached__c && !c.Status.contains('Close'))	{
                Account acctNew = accountsForNewCases.get(c.Seller_Dealership__c);
                
                String[] sellerStates = CalculateTitleDueDateHelper.getSellerLegalOrBillingState(null, acctNew);
                String sellerStateNew = sellerStates[1];
                
                boolean isSellerChanged = (sellerStateNew != null);
                if(isSellerChanged)	{
                    CalculateTitleDueDateHelper.setTitleDueDate(sellerStateNew, c);
                }
            }
        }                
    }    
}