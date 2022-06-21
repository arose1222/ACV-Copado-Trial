/**
 * @description A helper class used by CalculateTitleDueDateCase & CalculateTitleDueDateAccount trigger handlers.
 * 
 * 
 * @author Amul
 * @date 05/10/2021
 * 
 * @history 06/09/2021 Manmeet Vaseer - Added logic to handle Legal vs Billing state.
 * 
 */
public class CalculateTitleDueDateHelper {
    public static final string TITLE_INFORMATION_RT = 'Title_Information';
    
    public static List<Case> cases = new List<Case>();

    /**
     * @description Set the Title Due Date based on the State_Due_Date__mdt custom settings.
     * 
     * @param sellerStateNew Seller's State (Legal or Billing) from Trigger.New
     * @param c Case that will be updated with the Title Due Date.
     * 
     */
    public static void setTitleDueDate(String sellerStateNew, Case c)	{
        //Fetching the custom metadata and storing it in map with key as state and value as metadata record
        List<State_Due_Date__mdt> stateDueDateList = [SELECT Id,Title_Attached_If_False__c,Title_Attached_If_True__c,ABBREVIATION__c FROM State_Due_Date__mdt];
        Map<String,State_Due_Date__mdt> stateDueDateMap = new Map<String,State_Due_Date__mdt>();
        for(State_Due_Date__mdt objStateDueDate : stateDueDateList){
            stateDueDateMap.put(objStateDueDate.ABBREVIATION__c,objStateDueDate);
        }     
        
        if(c.Title_Attached__c == false){
            if(stateDueDateMap.containsKey(sellerStateNew) && stateDueDateMap.get(sellerStateNew).Title_Attached_If_False__c != null){
                Integer days = (Integer)stateDueDateMap.get(sellerStateNew).Title_Attached_If_False__c -1; 
                c.Title_Due_Date__c = c.Auction_End__c.addDays(days);
                cases.add(c);
            }
            else{
                if(stateDueDateMap.get('Default').Title_Attached_If_False__c!=null){
                    Integer days = (Integer)stateDueDateMap.get('Default').Title_Attached_If_False__c -1; 
                    c.Title_Due_Date__c = c.Auction_End__c.addDays(days); 
                	cases.add(c);
                }
            } 
        } 
        else if(c.Title_Attached__c == true){
            if(stateDueDateMap.containsKey(sellerStateNew) && stateDueDateMap.get(sellerStateNew).Title_Attached_If_True__c != null){
                Integer days =(Integer)stateDueDateMap.get(sellerStateNew).Title_Attached_If_True__c -1;                   
                c.Title_Due_Date__c = c.Auction_End__c.addDays(days);
                cases.add(c);
            }
            else{
                if(stateDueDateMap.get('Default').Title_Attached_If_True__c!=null){
                    Integer days = (Integer)stateDueDateMap.get('Default').Title_Attached_If_True__c -1; 
                    c.Title_Due_Date__c = c.Auction_End__c.addDays(days);  
                	cases.add(c);
                }
            } 
        }        
    }
    
    /**
     * @description Find & Return either Legal or Billing state for the associated Case.
     * 
     * @param acctOld Account associated with oldCase map.
     * @param acctNew Account associated with newCase list.
     * 
     * @retrun An array of size 2 that has Seller's Old State (at index 0) and Seller's New State (at index 1).
     */
    public static String[] getSellerLegalOrBillingState(Account acctOld, Account acctNew)	{
		// On Title Information Case, look to Seller -> Legal State. If Legal State = Null, use Billing State/Province.            
        String sellerStateNew = (acctNew != null && acctNew.Legal_State__c != null) ? acctNew.Legal_State__c : null;
        if(sellerStateNew == null)	{
        	sellerStateNew = (acctNew != null && acctNew.BillingState != null) ? acctNew.BillingState : null;
        }
        
        String sellerStateOld = (acctOld != null && acctOld.Legal_State__c != null) ? acctOld.Legal_State__c : null;
        if(sellerStateOld == null)	{
        	sellerStateOld = (acctOld != null && acctOld.BillingState != null) ? acctOld.BillingState : null;
        }
        
        return (new String[] {sellerStateOld, sellerStateNew});
    }
    
    /**
     * @description Create a map of Account Id and Legal/Billing State for the specified Cases.
     * 
     * @param cases A list of Cases for which associated Account will be used to create the map.
     * 
     * @retrun A map of Id & Account (that has Legal & Billing state info).
     */
    public static Map<Id, Account> getAccountsFor(List<Case> cases)	{
		Set<Id> accountIds = new Set<Id>();
        for (Case c : cases) {
            if (c.Seller_Dealership__c != null) {
                accountIds.add(c.Seller_Dealership__c);
            }
        }
        
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Legal_State__c, BillingState FROM Account WHERE Id in :accountIds]);
        return accounts;
    }
    
}