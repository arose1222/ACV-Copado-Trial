/**
 * The class for unlocking Resolutions after a Credit has been Rejected
 * @author James Andre LaCour
 * @since August 24th, 2021
 */
public class ArbCreditRejectionResolutionUpdate extends TriggerInterface {
    /**
     * after update method that will update the related resolution when the credit is rejected
     * @param oldMap old value of the Credits_Checks__c
     * @param newMap new value of the Credits_Checks__c
     */
    public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
        Set<Id> resolutionIdSet = new Set<Id>();
        Set<Id> resolutionAppIdSet = new Set<Id>();          //RobZ added
        Map<Id,Double> CredAppAmountMap = New Map<Id, Double>();
        
        // Checking if this is a valid Credit to update the connected Resolution
        for( Credits_Checks__c credCheck : (List<Credits_Checks__c>)newMap.values() ){
            if( credCheck.Approval_Status__c == 'Rejected' && credCheck.Approval_Status__c != ((Credits_Checks__c)oldMap.get(credCheck.Id)).Approval_Status__c && credCheck.Resolution__c != null)
            {
                resolutionIdSet.add(credCheck.Resolution__c);
            }
            //Rob added for Resolution updates when Approved
            else if(credCheck.Approval_Status__c == 'Approved' && credCheck.Approval_Status__c != ((Credits_Checks__c)oldMap.get(credCheck.Id)).Approval_Status__c && credCheck.Resolution__c != null)
            {
                resolutionAppIdSet.add(credCheck.Resolution__c);
                CredAppAmountMap.put(credCheck.Resolution__c, credCheck.Total_Arb_Amount_Requested__c);
            }
        }
        if( resolutionIdSet.isEmpty() && resolutionAppIdSet.isEmpty() ) return;
        Id openResolutionRecordTypeId = Schema.SObjectType.Resolution__c.getRecordTypeInfosByDeveloperName().get('Arb_Resolution_1').getRecordTypeId();
        List<Resolution__c> resToUpdateList = new List<Resolution__c>();
        // Updating the Resolution Credits when Approved - New 12-2021
        for( Id resolutionbId : resolutionAppIdSet ){
            Resolution__c res = new Resolution__c();
            res.Id = resolutionbId;
            res.Approved_Credits__c = CredAppAmountMap.get(ResolutionBId) ;
            resToUpdateList.add(res);
        }
        // Clearing Amounts when Rejected
        for( Id resolutionId : resolutionIdSet ){
            Resolution__c res = new Resolution__c();
            res.Id = resolutionId;
            res.Credit_Check_Created__c = false;
            res.Amount__c = 0;                       // Rob
            res.Amount_Diagnostic__c = 0;            // Rob
            res.Tow_Fee__c = 0;						 // Rob
            //res.RecordTypeId = openResolutionRecordTypeId;
            resToUpdateList.add(res);
        }
        
        update resToUpdateList;
    }
}