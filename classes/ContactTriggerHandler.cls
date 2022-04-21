public class ContactTriggerHandler extends TriggerInterface {

	public override void afterInsert(Map<Id, SObject> newMap) {
        updateSellerTitle( (Map<Id, Contact>) newMap, null );
	}
	public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
        updateSellerTitle( (Map<Id, Contact>) newMap, (Map<Id, Contact>) oldMap );
	}
    public override void afterDelete(Map<Id, SObject> oldMap) {
        updateSellerTitle( null, (Map<Id, Contact>) oldMap );
	}
    public override void afterUnDelete(Map<Id, SObject> newMap) {
        updateSellerTitle( (Map<Id, Contact>) newMap, null );
	}

    /**
     * updateSellerTitle 
     *  GIVEN A Contact
     *  WHEN A Contact is created or has an updated Account or Title
     *  THEN update the Clerk email fields to reflect the new Account
     *
     * @param  newMap
     * @param  oldMap
     */
    public static void updateSellerTitle( Map<Id, Contact> newMap, Map<Id, Contact> oldMap ) {
        Map<Id, String> accountToEmailIdMap = new Map<Id, String>();
        Set<Id> oldConSet = new Set<Id>();
        if ( newMap != null ) {
            for ( Contact conRecord : newMap.values() ) {
                if ( ( conRecord.AccountId != null ) && ( ( oldMap != null
                && ( oldMap.get( conRecord.Id ).Title != conRecord.Title || 
                oldMap.get( conRecord.Id ).AccountId != conRecord.AccountId || 
                oldMap.get( conRecord.Id ).Email != conRecord.Email || 
                oldMap.get( conRecord.Id ).Active__c != conRecord.Active__c ) 
                 ) || ( oldMap == null ) ) ) {
                    if ( conRecord.Title == CaseUtility.TITLE_CLERK && ( ( oldMap != null && conRecord.AccountId == oldMap.get( conRecord.Id ).AccountId ) || ( oldMap == null ) ) ) {
                        accountToEmailIdMap.put( conRecord.AccountId, conRecord.Email );
                    } else if ( oldMap != null && oldMap.get( conRecord.Id ).Title == CaseUtility.TITLE_CLERK ) {
                        // In this case, we don't know the Contact to provide the email directly
                        oldConSet.add( conRecord.AccountId );
                        oldConSet.add( oldMap.get( conRecord.Id ).AccountId );
                    }
                }
            }
        }

        if ( newMap == null ) { // If there is no new value, all old values need to be added
            for ( Contact conRecord : oldMap.values() ) {
                oldConSet.add( conRecord.AccountId );
            }
        }

        if ( !oldConSet.isEmpty() ) { 
            List<Contact> conLst = [ SELECT Id, AccountId, Email FROM Contact WHERE AccountId IN :oldConSet AND Active__c = TRUE AND Title = :CaseUtility.TITLE_CLERK ORDER BY ACV_Updated__c DESC ];           
            for ( Contact conRecord : conLst ) {
                if ( accountToEmailIdMap.get( conRecord.AccountId ) == null ) {
                    accountToEmailIdMap.put( conRecord.AccountId, conRecord.Email );
                }
            }
            if ( conLst.isEmpty() ) {
                for ( Id acctId : oldConSet ) {
                    accountToEmailIdMap.put( acctId, null );
                }
            }
        }       

        if ( !accountToEmailIdMap.isEmpty() ) {
            final Id TITLE_CASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
            // Query for Cases under Account that are open
            List<Case> caseUpdateLst = [ SELECT Id, Seller_Dealership__c,Seller_Title_Clerk_Email__c FROM Case WHERE Seller_Dealership__c IN :accountToEmailIdMap.keyset() AND RecordTypeId = :TITLE_CASE_RT_ID AND IsClosed = FALSE ];
            // Loop over Cases, update each one's Seller Title Email thread to new Email from Map
            for ( Case caseRecord : caseUpdateLst ) {
                if ( accountToEmailIdMap.get( caseRecord.Seller_Dealership__c ) != null ) {
                    caseRecord.Seller_Title_Clerk_Email__c = accountToEmailIdMap.get( caseRecord.Seller_Dealership__c );
                } else {
                    caseRecord.Seller_Title_Clerk_Email__c = null;
                }
            }

            update caseUpdateLst;
        }
    }
	
}