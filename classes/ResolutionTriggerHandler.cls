/**
 * This class holds the logic for the old ResolutionTriggerHandler
 * It has been moved to the new Trigger Framework.
 * Originally Created by Huron Admin
 * @author James Andre LaCour
 */
public class ResolutionTriggerHandler extends TriggerInterface {
	/****************Class Variables************************/
	public static List<String> userNames {
		get{
			if( userNames == null ){
				List<String> acvIntegrationUserNameList = new List<String>();
				for( Integration_User_Name__mdt iun : [ SELECT MasterLabel FROM Integration_User_Name__mdt ] ){
					acvIntegrationUserNameList.add( iun.MasterLabel );
				}
				userNames = acvIntegrationUserNameList;
			}
			return userNames;
		}
		set;
	}
	public static boolean isupdateResolution = false;
	public static boolean iscreateResolution = false;
	/****************Context Methods************************/
	public override void afterInsert( Map<Id, SObject> newMap ){
		createResolution( (Map<Id, Resolution__c>)newMap );
	}
	public override void afterUpdate( Map<Id,SObject> oldMap, Map<Id,SObject> newMap ){
		updateResolution( (Map<Id, Resolution__c>)oldMap, (Map<Id, Resolution__c>)newMap );
	}
	/****************Helper Methods*************************/
	/**
     * On creation of Resolutions, calls the Create Adjustment AcvIntegrationQueueableJob job for certain users
	 * indicated in the Integration_User_Name__mdt metadata type
     * @param newMap - Map of Id-->Resolution new values
     * @return void
     */
	public static void createResolution( Map<Id, Resolution__c> newMap) {
		if (!iscreateResolution) {
            iscreateResolution = True;
			for (Resolution__c resolutionObj: newMap.values() ) {
				if (!System.isQueueable() && !userNames.contains(UserInfo.getUserName())) {
					System.enqueueJob(New AcvIntegrationQueueableJob('Create Adjustment', New List < Resolution__c > {
						resolutionObj
					},null));
					System.Debug('Create 1');
				}
			}
		}
	}
	/**
     * On update of Resolutions, calls the Create Adjustment or Update Adjustment AcvIntegrationQueueableJob job for certain users
	 * indicated in the Integration_User_Name__mdt metadata type
     * @param oldResolutionMap - Map of Id-->Complaint old values
	 * @param newResolutionMap - Map of Id-->Complaint new values
     * @return void
     */
	public static void updateResolution( Map<Id, Resolution__c> oldResolutionMap, Map<Id, Resolution__c> newResolutionMap ) {
		if (!isupdateResolution) {
            isupdateResolution = true;
			for (Resolution__c resolutionObj : newResolutionMap.values()) {
				If((oldResolutionMap.get(resolutionObj.Id).Amount__c != resolutionObj.Amount__c || oldResolutionMap.get(resolutionObj.Id).Goodwill__c != resolutionObj.Goodwill__c || oldResolutionMap.get(resolutionObj.Id).Resolution__c != resolutionObj.Resolution__c) && (resolutionObj.id__c == NULL && !System.isQueueable() && !userNames.contains(UserInfo.getUserName()))) {
					System.enqueueJob(New AcvIntegrationQueueableJob('Create Adjustment', New List < Resolution__c > {
						resolutionObj
					},null));
					System.Debug('Create 2');
				} 
				IF((oldResolutionMap.get(resolutionObj.Id).Amount__c != resolutionObj.Amount__c || oldResolutionMap.get(resolutionObj.Id).Goodwill__c != resolutionObj.Goodwill__c || oldResolutionMap.get(resolutionObj.Id).Resolution__c != resolutionObj.Resolution__c) && (resolutionObj.id__c != NULL && !System.isQueueable() && !userNames.contains(UserInfo.getUserName()))) {
					System.enqueueJob(New AcvIntegrationQueueableJob('Update Adjustment', New List < Resolution__c > {
						resolutionObj
					},null));
					System.Debug('Update 1');
				}
			}
		}
	}
}