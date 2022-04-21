public class DataUpdateAutomation extends TriggerInterface {
    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        processCases( oldMap, newMap );
    }

    public static List<Case> processCases( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Map<Id, Case> oldCaseMap =  (Map<Id, Case>) oldMap;

        List<Case> titleCaseLst = new List<Case>();
        for ( Case caseRec : (List<Case>) newMap.values() ) {
            if ( ACVUtility.recordTypeCheck( CaseUtility.TITLES_RECORDTYPE_DEV_NAME, 'Case', caseRec.RecordTypeId )
            && ( caseRec.Status == 'Received' || caseRec.Status == 'Working' || caseRec.Status == 'Sent' ) 
            && caseRec.Status != oldCaseMap.get( caseRec.Id ).Status) {
                titleCaseLst.add( caseRec );
            }
        }

        return dataUpdateAutomation( titleCaseLst );
    }

    /** dataUpdateAutomation
     *   GIVEN A Titles Case with status of 'Working' 
     *   AND user is not a System administrator
     *   WHEN the Title Case Status changes
     *   THEN set Owner Id to User Id
     *
     *   GIVEN A Titles Case with status of 'Received'
     *   AND user is not a System administrator
     *   WHEN the Title Case Status changes
     *   THEN set Title Received Date to Today
     *
     *   GIVEN A Titles Case with status of 'Sent'
     *   AND user is not a System administrator
     *   WHEN the Title Case Status changes
     *   THEN set Title Sent Date to Today
     *   
     *
     * @param   caseList  
     */
    private static List<Case> dataUpdateAutomation( List<Case> caseList ){
        for( Case c : caseList ) {
            if( c.Status == 'Working' ) {
                c.OwnerId = UserInfo.getUserId();
            } else if( c.Status == 'Received' ) {
                c.Title_Received_Date__c = Date.Today();
            } else if( c.Status == 'Sent' ) {
                c.Title_Sent_Date__c = Date.Today();
            }
        }
        return caseList;
    }

    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Map<Id, Case> oldCaseMap =  (Map<Id, Case>) oldMap;
        Set<Id> idSet = new Set<Id>();

        for (Case c : (List<Case>) newMap.values()) {
            if (c.Status == 'Sent' && oldCaseMap.get(c.Id).Status != 'Sent') {
                idSet.add(c.Id);
            }
        }
        if (!idSet.isEmpty()) {
            updateCustomerInquiries(idSet);
        }
    }

    private static void updateCustomerInquiries(Set<Id> idSet) {
        Set<String> typeSet = new Set<String>{'Buyer Title Status', 'Buyer Reported Problem', 'Seller Title Status', '48 Hour Notice Request', '48 Hour Unwind Request',''}; //'48 Hour Notice Update', 
        Set<String> statusSet = new Set<String>{'New', 'Working'};
        List<Customer_Inquiry__c> ciList = [SELECT Id, Status__c FROM Customer_Inquiry__c WHERE Ops_Case__c IN :idSet AND Call_Type__c IN :typeSet AND Status__c IN :statusSet];
        for (Customer_Inquiry__c ci : ciList) {
            ci.Status__c = 'AM Follow Up';
        }
        update ciList;
    }
}