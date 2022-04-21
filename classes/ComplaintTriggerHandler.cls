/**
 * This class holds the logic for the old ComplaintTriggerHandler
 * It has been moved to the new Trigger Framework.
 * Originally Created by Huron Admin
 * @author James Andre LaCour
 */
public class ComplaintTriggerHandler extends TriggerInterface {
    /****************Class Variables************************/
    public static boolean isCreateComplaint = false;
    public static boolean isupdateComplaint = false;
    /****************Context Methods************************/
    /**
     * logic to run in after insert context.
     * @param newMap - Map of Id-->Complaint new values
     * @return void
     */
    public override void afterInsert( Map<Id, SObject> newMap ){
        createComplaint( (Map<Id,Complaint__c>)newMap );
    }
    /**
     * logic to run in after update context
     * @param oldMap - Map of Id-->Complaint old values
     * @param newMap - Map of Id-->Complaint new values
     * @return void
     */
    public override void afterUpdate( Map<Id, sObject> oldMap, Map<Id, sObject> newMap ){
        updateComplaint( (Map<Id,Complaint__c>)oldMap, (Map<Id,Complaint__c>)newMap );
    }
    /****************Helper Methods************************/
    /**
     * On creation of complaint, calls the Create Complaint AcvIntegrationQueueableJob job for certain users
     * indicated in the Integration_User_Name__mdt metadata type
     * @param newComplaints - Map of Id-->Complaint onewld values
     * @return void
     */
    public static void createComplaint( Map<Id,Complaint__c> newComplaints ){
        if ( !isCreateComplaint ) {
            Id CRReviewComplaintId = Schema.SObjectType.Complaint__c.getRecordTypeInfosByName().get('CR Review Issue').getRecordTypeId();
            Set<String> userNames = getUserNamesFromIntegrationUserNameMetadata();
            isCreateComplaint = true;
            for( Complaint__c comObj: newComplaints.values() ){
                if( !System.isQueueable() && !userNames.contains(UserInfo.getUserName()) && comObj.recordTypeId != CRReviewComplaintId ){
                    System.enqueueJob( new AcvIntegrationQueueableJob( 'Create Complaint', new List<Complaint__c>{comObj}, null) );
                }
            }
        }
    }
    /**
     * logic to run in after update context
     * @param oldComplaints - Map of Id-->Complaint old values
     * @param newComplaints - Map of Id-->Complaint new values
     * @return void
     */
    public static void updateComplaint( Map<Id,Complaint__c> oldComplaints, Map<Id,Complaint__c> newComplaints ) {
        if(!isupdateComplaint){
            Id CRReviewComplaintId = Schema.SObjectType.Complaint__c.getRecordTypeInfosByName().get('CR Review Issue').getRecordTypeId();
            Set<String> userNames = getUserNamesFromIntegrationUserNameMetadata();
            isupdateComplaint = true;
            for( Complaint__c comObj: newComplaints.values() ){
                if( comObj.id__c == null && !System.isQueueable() && userNames != null && !userNames.contains(UserInfo.getUserName()) && comObj.recordTypeId != CRReviewComplaintId ){
                    System.enqueueJob( new AcvIntegrationQueueableJob( 'Create Complaint', new List<Complaint__c>{comObj}, null) );
                }
                if( comObj.id__c != null && !System.isQueueable() && userNames != null && !userNames.contains(UserInfo.getUserName()) && comObj.recordTypeId != CRReviewComplaintId ){
                    System.enqueueJob( new AcvIntegrationQueueableJob(  'Update Complaint', new List<Complaint__c> {comObj}, null) );
                }
            }
        }
    }
    /**
     * Returns a set of Usernames that the createComplaint and
     * updateComplaint use to determine if automation should run
     * @return set of usernames that this automation will run for
     */
    private static Set<String> getUserNamesFromIntegrationUserNameMetadata(){
        Set<String> userNames = new Set<String>();
        for( Integration_User_Name__mdt iUN : [ SELECT MasterLabel FROM Integration_User_Name__mdt ] ){
            userNames.add(iUN.MasterLabel);
        }
        return userNames;
    }
}