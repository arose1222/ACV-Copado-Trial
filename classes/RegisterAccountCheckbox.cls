public class RegisterAccountCheckbox extends TriggerInterface {
    public override void beforeInsert(List<sObject> objectList) {
        processRegister( (List<Account>) objectList );
    }

    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        Map<Id, Account> oldMap = new Map<Id, Account>( (List<Account>) oldList );
        
        List<Account> acctLst = new List<Account>();
        for ( Account acct : (List<Account>) newList ) {
            if ( ( acct.Last_30_Days_Bought__c != oldMap.get( acct.Id ).Last_30_Days_Bought__c ) || ( acct.Last_30_Days_Sold__c != oldMap.get( acct.Id ).Last_30_Days_Sold__c ) ) {
                acctLst.add( acct );
            }
        }

        processRegister( acctLst );
    }

    public List<Account> processRegister( List<Account> objectList ) {
        for ( Account acct : objectList ) {
            if ( checkNumber( acct.Last_30_Days_Bought__c ) || checkNumber( acct.Last_30_Days_Sold__c ) ) {
                acct.Registered__c = TRUE;
            }
        }

        return objectList;
    }

    public boolean checkNumber( Decimal decVal ) {
        if ( decVal != null && decVal > 0 ) {
            return true;
        }

        return false;
    }
}