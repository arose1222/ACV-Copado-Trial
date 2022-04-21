/**
 * @description 
 * 
 * 
 * @author Manmeet Vaseer
 * @date 03/17/2022
 * 
 * @history
 * 		03/17/2022 Manmeet Vaseer - Initial Revision.
 * 
 */ 
public class TitleReviewCallouts extends TriggerInterface {

    TitleReviewAPI titleReviewAPI = new TitleReviewAPI();
    
    public override void afterInsert(List<SObject> newList){
        sendSalesforceIds(newList); 
    }

    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        //calculateTitleDueDateOnCaseUpdate((Map<Id,Case>)oldMap, (Map<Id,Case>)newMap);
        //titleReviewAPI.setTitleReviewSalesforceId(newMap.values());
    }
    
    private void sendSalesforceIds(List<Title_Review__c> newList)	{
        titleReviewAPI.setTitleReviewSalesforceId(newList);
    }
}