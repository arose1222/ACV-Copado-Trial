public class DealerDocCompliance extends TriggerInterface {
    
    // final static String RESALE = 'Resale Certificate';
    // final static String DEALER_LICENSE = 'Dealer License';
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();
    final static Set<Id> DOC_TYPE_CHECK = new Set<Id>{ licenseId, resaleId };

    public override void afterInsert(List<sObject> objectList) {
        List<Dealer_Docs__c> filterDocLst = new List<Dealer_Docs__c>();
        Set<Id> acctIdSet = new Set<Id>();
        for ( Dealer_Docs__c doc : (List<Dealer_Docs__c>) objectList ) {
            if ( doc.Compliant__c && DOC_TYPE_CHECK.contains( doc.RecordTypeId ) ) {
                filterDocLst.add( doc );
                acctIdSet.add( doc.Account__c );
            }
        }

        if (!filterDocLst.isEmpty()) {
            update processDealerDocLogic( filterDocLst, acctIdSet, TRUE );
        }
    }

    public override void afterUpdate(List<sObject> oldList, List<sObject> newList) {
        Map<Id, Dealer_Docs__c> oldMap = new Map<Id, Dealer_Docs__c>( (List<Dealer_Docs__c>) oldList );

        List<Dealer_Docs__c> filterDocLst = new List<Dealer_Docs__c>();
        Set<Id> acctIdSet = new Set<Id>();

        for ( Dealer_Docs__c doc : (List<Dealer_Docs__c>) newList ) {
            if ( DOC_TYPE_CHECK.contains( doc.RecordTypeId ) && ( ( doc.Compliant__c != oldMap.get( doc.Id ).Compliant__c ) || ( doc.RecordTypeId != oldMap.get( doc.Id ).RecordTypeId ) ) ) {
                filterDocLst.add( doc );
                acctIdSet.add( doc.Account__c );
            }
        }

        if (!filterDocLst.isEmpty()) {
            update processDealerDocLogic( filterDocLst, acctIdSet, TRUE );
        }
    }

    public override void afterDelete( List<sObject> oldList ) {
        List<Dealer_Docs__c> filterDocLst = new List<Dealer_Docs__c>();
        Set<Id> acctIdSet = new Set<Id>();

        for ( Dealer_Docs__c doc : (List<Dealer_Docs__c>) oldList ) {
            filterDocLst.add( doc );
            acctIdSet.add( doc.Account__c );
        }

        if (!filterDocLst.isEmpty()) {
            update processDealerDocLogic( filterDocLst, acctIdSet, FALSE );
        }
    }

    public static List<Account> processDealerDocLogic( List<Dealer_Docs__c> filteredLst, Set<Id> acctIdSet, Boolean complianceVar ) {

        // Key is AcctId:RecordTypeId
        Map<String, Boolean> docCheckMap = new Map<String, Boolean>();
        Set<Id> ignoreDocSet = new Map<Id, Dealer_Docs__c>( filteredLst ).keyset();

        // Reference if Accounts have other Compliant Docs to avoid doing anything
        for ( Account acct : [ SELECT Id, ( SELECT Id, Account__c, RecordTypeId FROM Dealer_Docs__r WHERE Compliant__c = TRUE AND Id NOT IN :ignoreDocSet ) FROM Account WHERE Id IN :acctIdSet ] ) {
            for ( Dealer_Docs__c doc : acct.Dealer_Docs__r ) {
                docCheckMap.put( makeKey( doc ), TRUE );
            }
        }

        Map<Id, Account> updateAcctMap = new Map<Id, Account>();
        for ( Dealer_Docs__c doc : filteredLst ) {
            if ( doc.Compliant__c && complianceVar ) {
                if ( doc.RecordTypeId == resaleId ) {
                    updateAcctMap = acctHelper( updateAcctMap, doc.Account__c, 'Compliant_Resale_Certificate__c', complianceVar );
                } else if ( doc.RecordTypeId == licenseId ) {
                    updateAcctMap = acctHelper( updateAcctMap, doc.Account__c, 'Compliant_Dealer_License__c', complianceVar );
                }
            } else if (( !doc.Compliant__c && complianceVar ) || ( doc.Compliant__c && !complianceVar )) {       
                if ( doc.RecordTypeId == resaleId && ( ( docCheckMap.isEmpty() ) || ( !docCheckMap.isEmpty() && ( docCheckMap.get( makeKey( doc ) ) == FALSE || docCheckMap.get( makeKey( doc ) ) == null ) ) ) ) {
                    updateAcctMap = acctHelper( updateAcctMap, doc.Account__c, 'Compliant_Resale_Certificate__c', FALSE );
                } else if ( doc.RecordTypeId == licenseId && ( ( docCheckMap.isEmpty() ) || ( !docCheckMap.isEmpty() && ( docCheckMap.get( makeKey( doc ) ) == FALSE || docCheckMap.get( makeKey( doc ) ) == null ) ) ) ) {
                    updateAcctMap = acctHelper( updateAcctMap, doc.Account__c, 'Compliant_Dealer_License__c', FALSE );
                }
            }
        }
        return updateAcctMap.values();
    }

    public static Map<Id, Account> acctHelper( Map<Id, Account> updateAcctMap, Id acctId, String fieldName, Boolean value ) {
        SObject acct = updateAcctMap.get( acctId ) == null ? Schema.getGlobalDescribe().get( 'Account' ).newSObject() : updateAcctMap.get( acctId );

        acct.put( 'Id', acctId );
        acct.put( FieldName, value );
        updateAcctMap.put( 
            acctId,
            (Account) acct
        );

        return updateAcctMap;
    }

    public static String makeKey( Dealer_Docs__c doc ) {
        return doc.Account__c + ':' + doc.RecordTypeId;
    }
}