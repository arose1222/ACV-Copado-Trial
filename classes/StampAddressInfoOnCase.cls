public class StampAddressInfoOnCase extends TriggerInterface {

    public override void beforeInsert( List<SObject> newList ){
        processCaseLst( (List<Case>) newList );
    }

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        processCaseLst( (List<Case>) newMap.values() );
    }

    public List<Case> processCaseLst( List<Case> newCaseLst) {
        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : newCaseLst ) {
            if ( ACVUtility.recordTypeCheck( CaseUtility.TITLES_RECORDTYPE_DEV_NAME, 'Case', caseRec.RecordTypeId ) ) {
                titleCaseLst.add( caseRec );
            }
        }

        if ( !titleCaseLst.isEmpty() ) {
            return stampAddressInfoOnCase( titleCaseLst );
        }
        return null;
    }

    private static List<Case> stampAddressInfoOnCase(List<Case> newCaseList){
        List<Id> dealershipIdList = new List<Id>();
        for( Case c : newCaseList ) {
            if( c.AccountId != null ) {
                dealershipIdList.add( c.AccountId );
            }
        }

        Map<id,Account> dealerMap = new Map<Id, Account>( [ SELECT Id, BillingStreet, BillingState, BillingCity, BillingPostalCode, BillingCountry, Phone from Account where id in :dealershipIdList ] );

        for(case c :newCaseList){
            if(c.AccountId != null && dealerMap.get(c.AccountId) != null){
                if(c.Default_Delivery_Address__c == null){
                    c.Default_Delivery_Address__c = dealerMap.get(c.AccountId).BillingStreet;
                }
                if(c.Default_Delivery_City__c == null){
                    c.Default_Delivery_City__c = dealerMap.get(c.AccountId).BillingCity;
                }
                if(c.Default_Delivery_Country__c == null){
                    c.Default_Delivery_Country__c = dealerMap.get(c.AccountId).BillingCountry;
                }
                if(c.Default_Delivery_Postal_Code__c == null){
                    c.Default_Delivery_Postal_Code__c = dealerMap.get(c.AccountId).BillingPostalCode;
                }
                if(c.Default_Delivery_State__c == null){
                    c.Default_Delivery_State__c = dealerMap.get(c.AccountId).BillingState;
                }
            }
        }

        return newCaseList;
    }
}