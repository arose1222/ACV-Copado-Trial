public class DateStampBuyerAssuranceOnAccount extends TriggerInterface {

    final public static String GOODWILL = 'Goodwill';
    final public static String RETRO_CHARGE = 'Retro Charge';
    final public static String DENY = 'Deny';

    public override void beforeInsert(List<sObject> objectList) {
        processStamp( (List<Account>) objectList );
    }

    public override void beforeUpdate(List<sObject> oldList, List<sObject> newList) {
        Map<Id, Account> oldMap = new Map<Id, Account>( (List<Account>) oldList );
        
        List<Account> acctLst = new List<Account>();
        for ( Account acct : (List<Account>) newList ) {
            if ( ( acct.Buyer_s_Assurance_Exceptions__c != oldMap.get( acct.Id ).Buyer_s_Assurance_Exceptions__c ) || ( acct.Date_Of_Goodwill__c != oldMap.get( acct.Id ).Date_Of_Goodwill__c ) || ( acct.Date_of_Retro_Charge__c != oldMap.get( acct.Id ).Date_of_Retro_Charge__c ) || ( acct.Date_of_Deny__c != oldMap.get( acct.Id ).Date_of_Deny__c ) ) {
                acctLst.add( acct );
            }
        }

        processStamp( acctLst );
    }

    public List<Account> processStamp( List<Account> objectList ) {
        for ( Account acct : objectList ) {
            if ( acct.Date_Of_Goodwill__c == null && acct.Buyer_s_Assurance_Exceptions__c == DateStampBuyerAssuranceOnAccount.GOODWILL ) {
                acct.Date_Of_Goodwill__c = ACVUtility.newESTInstance( date.today() );
            }
            if ( acct.Date_of_Retro_Charge__c == null && acct.Buyer_s_Assurance_Exceptions__c == DateStampBuyerAssuranceOnAccount.RETRO_CHARGE ) {
                acct.Date_of_Retro_Charge__c = ACVUtility.newESTInstance( date.today() );
            }
            if ( acct.Date_of_Deny__c == null && acct.Buyer_s_Assurance_Exceptions__c == DateStampBuyerAssuranceOnAccount.DENY ) {
                acct.Date_of_Deny__c = ACVUtility.newESTInstance( date.today() );
            }
        }

        return objectList;
    }
}