/**
 * @description https://acvauctions.atlassian.net/browse/TDO-26 requirements.
 * Update Title Due Date field on new Case based on Seller Account's Legal/Billing State.
 * Also, update Title Due Date field on existing Case when Title Absent (Title_Attached__c) flag is changed on Case.
 * 
 * @author Manmeet Vaseer
 * @date 05/10/2021
 * 
 * @history 
 * 			06/09/2021 Manmeet Vaseer - Added logic to handle Legal vs Billing state.
 * 			01/08/2022 Manmeet Vaseer - Use Case.CreatedDate instead of Case.Auction_End__c date for the Due Date calculations (https://acvauctions.atlassian.net/browse/TDO-692).
 * 			02/21/2022 Manmeet Vaseer - Modify the Update Trigger to populate the Title Due Date, when Seller Dealership field changes. (https://acvauctions.atlassian.net/browse/TDO-731).
 * 
 */
public class CalculateTitleDueDateCase extends TriggerInterface {
    public static String SPLUNK_COMPONENT_NAME = 'Calculate_Title_Due_Date';
    
    private static Map<Id, String> triggeredCases = new Map<Id, String>();
    private static SplunkLogging sl = new SplunkLogging(SPLUNK_COMPONENT_NAME);
    
	private static Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CalculateTitleDueDateHelper.TITLE_INFORMATION_RT).getRecordTypeId();
    
    /**
     * Invoked only for Case Before Insert
     */ 
    public override void beforeInsert( List<SObject> newList ) {
        calculateTitleDueDateOnCaseInsert(newList);
    }
    
    /**
     * Invoked only for Case Before Update
     */ 
    public override void beforeUpdate(Map<Id,SObject> oldMap , Map<Id,SObject> newMap)  {
        calculateTitleDueDateOnCaseUpdate((Map<Id,Case>)oldMap, (Map<Id,Case>)newMap);
    }
        
    /**
     * @description Set Title Due Date on Case Insert based on Seller Account's Legal/Billing State.
     * 
     * @param newCases A list of New Case.
     * 
     */
    private static void calculateTitleDueDateOnCaseInsert(List<Case> newCases){        
        String classMethod = 'CalculateTitleDueDateCase.calculateTitleDueDateOnCaseInsert';
        
        Map<Id, Account> accountsForNewCases = CalculateTitleDueDateHelper.getAccountsFor(newCases);
        
        for(Case c :newCases){
            if(c.RecordTypeId == caseRecordTypeId) {
            	sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 
                           'Case Id: ' + c.Id + ', c.Auction_End__c: ' + c.Auction_End__c + ', c.Seller_Dealership__c: ' + c.Seller_Dealership__c);
                if(c.Auction_End__c != null)	{
                    Account acctNew = accountsForNewCases.get(c.Seller_Dealership__c);
                    if(acctNew != null) sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'acctNew: ' + acctNew);
                    
                    String[] sellerStates = CalculateTitleDueDateHelper.getSellerLegalOrBillingState(null, acctNew);
                    if(sellerStates != null) sl.addDebug(ACVUtility.currentLineNumber(), classMethod, 'sellerStates: ' + sellerStates);
                    if(sellerStates != null && sellerStates.size() == 2)	{
                        String sellerStateNew = sellerStates[1];
                        
                        Boolean isSellerChanged = (sellerStateNew != null);
                        sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'isSellerChanged: ' + isSellerChanged);
                        if(isSellerChanged)	{
                            CalculateTitleDueDateHelper.setTitleDueDate(sellerStateNew, c, System.now());
                        }
                    }
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
        String classMethod = 'CalculateTitleDueDateCase.calculateTitleDueDateOnCaseUpdate';
        
        List<Case> newCases = (List<Case>)newCaseMap.values();
        Map<Id, Account> accountsForNewCases = CalculateTitleDueDateHelper.getAccountsFor(newCases);
        
        for(Case c :newCases){
            if(c.RecordTypeId == caseRecordTypeId) {
                Case oldCase = oldCaseMap.get(c.Id);
                sl.addDebugFine(ACVUtility.currentLineNumber(),  classMethod, 
                            'Case Id: ' + c.Id + ', c.Auction_End__c: ' + c.Auction_End__c + ', c.Seller_Dealership__c: ' + c.Seller_Dealership__c +
                            ', c.Title_Attached__c : ' + c.Title_Attached__c + ', oldCase.Title_Attached__c: ' + oldCase.Title_Attached__c + ', c.Status: ' + c.Status);
                
                if(c.Auction_End__c != null && !c.Status.contains('Close') && 
                   (c.Title_Attached__c != oldCase.Title_Attached__c || c.Seller_Dealership__c != oldCase.Seller_Dealership__c) )	{
                    Account acctNew = accountsForNewCases.get(c.Seller_Dealership__c);
                    if(acctNew != null) sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'acctNew: ' + acctNew);
                    
                    String[] sellerStates = CalculateTitleDueDateHelper.getSellerLegalOrBillingState(null, acctNew);
                    if(sellerStates != null && sellerStates.size() == 2)	{
                        String sellerStateNew = sellerStates[1];
                        
                        boolean isSellerChanged = (sellerStateNew != null);
                        sl.addDebug(ACVUtility.currentLineNumber(),  classMethod, 'isSellerChanged: ' + isSellerChanged + ', sellerStates: ' + sellerStates);
                        if(isSellerChanged)	{
                            CalculateTitleDueDateHelper.setTitleDueDate(sellerStateNew, c, c.CreatedDate);
                        }
                    }
                }
            }
        }                
    }    
}