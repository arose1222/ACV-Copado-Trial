/**
 * @description https://acvauctions.atlassian.net/browse/TDO-292
 * 
 * @author Manmeet Vaseer
 * @date 09/03/2021
 * 
 */
public class SetTitleContactEmail extends TriggerInterface {

    public static String TITLE_INFO_RT = 'Title_Information';
    
    public override void beforeInsert( List<SObject> newList ){
        processCaseList( (List<Case>) newList, new Map<Id, Case>() );
    }

    public override void beforeUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        processCaseList( (List<Case>) newMap.values(), (Map<Id, Case>) oldMap );
    }

    private void processCaseList( List<Case> newCaseLst, Map<Id, Case> oldMap ) {
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TITLE_INFO_RT).getRecordTypeId();
        
        List<Id> sellerAccountIds = new List<Id>();
        List<Case> titleCaseList = new List<Case>();
        for ( Case caseRec : newCaseLst ) {
            // Only apply this logic to Title Information record type.
            if(caseRec.RecordTypeId == titlesRecordType)	{
                titleCaseList.add( caseRec );
                if(caseRec.Seller_Dealership__c != null) sellerAccountIds.add(caseRec.Seller_Dealership__c);
            }
        }

        if ( !titleCaseList.isEmpty() && !sellerAccountIds.isEmpty() ) {
            setTitleContactEmails( sellerAccountIds, titleCaseList);
        }
    }
    
    private void setTitleContactEmails(List<Id> sellerAccountIds, List<Case> newCaseList){        
        // Affiliations related to all Cases
        List<Affiliation__c> relatedAffiliations = [SELECT Id, Account__c, Contact__c, Contact__r.Email FROM Affiliation__c WHERE Account__c IN :sellerAccountIds AND Primary_Contact__c = true];
        Map<Id, Affiliation__c> sellerAcctIdAffiliationMap = new Map<Id, Affiliation__c>();
        for(Affiliation__c aff : relatedAffiliations)	{
            sellerAcctIdAffiliationMap.put(aff.Account__c, aff);
        }
        
        for(Case caseRec : newCaseList)	{
            if(sellerAcctIdAffiliationMap.get(caseRec.Seller_Dealership__c) != null) caseRec.Seller_Contact_Email__c = sellerAcctIdAffiliationMap.get(caseRec.Seller_Dealership__c)?.Contact__r?.Email;
            else caseRec.Seller_Contact_Email__c = null; // if the related seller account not set/found in the Case
        }        
    }
}