/**
 * @description Trigger to automatically set Case Status field for 'Title Information' record type. This is part of Force State Transition work (BIZ-86).
 * We want to control the lifecycle of Status field. We are doing this by relying on dependent Update_Status__c field. A user has access to a set of
 * values to pick from Update_Status__c and in this trigger we update the Status field with the value in Update_Status__c that a user selects. This in turns assign a new
 * set of values to Update_Status__c using controlling/dependent fields relationship between Status/Update_Status__c fields.
 * 
 * @author Manmeet Vaseer
 * @date 05/21/2021
 */
public class TitleStatusTransitionTriggerHandler extends TriggerInterface {
    // To prevent Recursive Trigger
    public static Boolean isStatusFieldAlreadyUpdated = false;

    /*
     * Do not allow changing the Status fields for the following Record Type and Profiles.
     */
    public static String TITLE_INFO_RT = 'Title_Information';
    public static String[] USER_PROFILE_NAMES = new String[]{'Titles', 'Title Manager'};
    
    public override void beforeUpdate( Map<Id,sObject> oldMap, Map<Id,sObject> newMap ) {
        if(!isStatusFieldAlreadyUpdated) updateTitleStatus((Map<Id,Case>) oldMap, (Map<Id,Case>) newMap);
    }    

    /**
     * @description Update the value of Title Status field from Update Status field value
     * 
     * @param oldMap Map of old Cases to Ids
     * @param newMap Map of new Caeses to Ids
     */
    private void updateTitleStatus(Map<Id,Case> oldMap, Map<Id,Case> newMap)	{
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TITLE_INFO_RT).getRecordTypeId();
        Map<ID, Profile> profiles = new Map<ID, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :USER_PROFILE_NAMES]);
        
        for (Id key : newMap.keySet()) {
            Case newCase = newMap.get(key);
            // Only apply this logic to Title Information record type and specified User Profiles.
            if(newCase.RecordTypeId == titlesRecordType && profiles.get(UserInfo.getProfileId()) != null)	{
                Case oldCase = oldMap.get(key);
                // Ensure that a user is not changing the value of the Case Status field directly
                if(oldCase.Status == newCase.Status)	{
                    // Update the Status using Update_Status__c field
                    // and reset the Update_Status__c field. If we don't reset this field, then it may have a value that is not in the dependent field values so it will throw an error.
                    if(newCase.Update_Status__c != null && !String.isBlank(newCase.Update_Status__c))	{                        
                        newCase.Status = newCase.Update_Status__c;
                        newCase.Update_Status__c = null;
                        
                        /*
                         * As we are updating Case.Status field in this trigger, which will cause this trigger to call itself again.
                         * To prevent this trigger to call itself recursively, we are using the following static method that 
                         * will be reset on every new transaction.
                         */
                        TitleStatusTransitionTriggerHandler.isStatusFieldAlreadyUpdated = true;
                    }
                }
                else {
                    // let the user know that he/she can't update the Case Status value directly.
                    newCase.Status.addError('You can not change the Status field value. Use Update Status field to change the Title Status');
                }
            }
        }        
    }

    /*
     * @description This recussive trigger is reset after every trancsaction (like insert/update/etc operations).
     * Sometimes, we want to reset the recussive trigger within a transaction (e.g. a Unit Test where each test method is run within a single transaction).
     */
    public static void reset()	{
        isStatusFieldAlreadyUpdated = false;
    }
}