/**
 * @description https://acvauctions.atlassian.net/browse/TDO-26
 * Update Title Due Date field on existing Case when Seller Account's Legal/Billing State changes.
 * 
 * @author Manmeet Vaseer
 * @date 05/10/2021
 * 
 * @history 06/09/2021 Manmeet Vaseer - Added logic to handle Legal vs Billing state.
 * 
 */
public class CalculateTitleDueDateAccount extends TriggerInterface	{

    /**
     * Invoked only for Account Before Update
     */ 
    public override void beforeUpdate(Map<Id,SObject> oldMap , Map<Id,SObject> newMap)  {
        CalculateTitleDueDateHelper.cases = new List<Case>();
        calculateTitleDueDateOnAccountUpdate((Map<Id,Account>)oldMap,(Map<id,Account>)newMap); 
    }
    
    /**
     * Invoked only for Account After Update
     */ 
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        if(CalculateTitleDueDateHelper.cases.size() > 0)	update CalculateTitleDueDateHelper.cases;
    }
    
    /**
     * @description Set Title Due Date on Case when Seller Account's Legal/Billing State is updated.
     * 
     * @param oldAccountMap A map of Old Account.
     * @param newAccountMap A list of New Account.
     * 
     */
    private static void calculateTitleDueDateOnAccountUpdate(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CalculateTitleDueDateHelper.TITLE_INFORMATION_RT).getRecordTypeId();
        
		// Get all Cases related to all the Accounts        
        List<Case> allRelatedCases = [SELECT Id, Seller_Dealership__c, Title_Attached__c, Title_Due_Date__c, Auction_End__c, CaseNumber, CreatedDate FROM Case 
                                      WHERE Seller_Dealership__c IN :newAccountMap.keySet()
                                     AND RecordTypeId = :caseRecordTypeId
                                     AND (NOT Status LIKE 'Close%')];
        Map<Id,List<Case>> accountCasesMap = new Map<Id, List<Case>>();
        for(Case c : allRelatedCases)	{
            List<Case> acctRelatedCases = accountCasesMap.get(c.Seller_Dealership__c);
            if(acctRelatedCases == null)	{
                acctRelatedCases = new List<Case>();
                accountCasesMap.put(c.Seller_Dealership__c, acctRelatedCases);
            }
            acctRelatedCases.add(c);
        }
        
        for(Id newAcctId : newAccountMap.keySet())	{
            String[] sellerStates = CalculateTitleDueDateHelper.getSellerLegalOrBillingState(oldAccountMap.get(newAcctId), newAccountMap.get(newAcctId));
            if(sellerStates != null && sellerStates.size() == 2)	{
                String sellerStateOld = sellerStates[0];
                String sellerStateNew = sellerStates[1];
                
                boolean isSellerChanged = (sellerStateNew != sellerStateOld) || (oldAccountMap.isempty() && sellerStateNew != null); 
                if(isSellerChanged)	{
                    List<Case> acctRelatedCases = accountCasesMap.get(newAcctId);
                    if(acctRelatedCases != null)	{
                        for(Case c : acctRelatedCases) {
                            CalculateTitleDueDateHelper.setTitleDueDate(sellerStateNew, c, c.CreatedDate);
                        }                    
                    }
                } // if isSellerChanged     
            }
        } //for        
    }
    
}