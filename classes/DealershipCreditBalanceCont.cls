/**
 * The Controller for DealershipCreditBalance LWC
 * @author James Andre LaCour
 * @since April 26th, 2021
 */
public without sharing class DealershipCreditBalanceCont {
    /**
     * When passed in the Organization Credit Id for a Dealership,
     * Returns the current balance
     * @param orgCreditId - Organization Credit Id for a Dealer
     * @return  `Integer` - The account balance. If null, could not find an account balance.
     */
    @AuraEnabled
    public static Integer getAccountBalance( String recordId ){
        Integer accountBalance = null;  // Null will be used as a stand in for "Nothing found, hide component"
        if( String.isNotBlank(recordId) ){
            List<Account> acct = [ SELECT Id, Organization_Credit_Id__c FROM Account WHERE Id = :recordId LIMIT 1];
            if( !acct.isEmpty() ){
                try{
                    AccountSummary dealershipAccountInfo = CreditCallout.getAccountTotal( Integer.valueOf(acct[0].Organization_Credit_Id__c) );
                    accountBalance = dealershipAccountInfo?.data?.accountTotal;
                }catch(Exception ex){
                    System.debug(ex.getMessage());
                    System.debug(ex.getStackTraceString());
                }
            }
        }
        return accountBalance;
    }
}