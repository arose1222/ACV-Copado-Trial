/**
 * The Class for the Trigger BDR Assignment Email
 * Which sends an email to the customer from the BDR when Org Lead is switched from queue to a User
 * @author James Andre LaCour
 */
public without sharing class BdrAssignmentEmail extends TriggerInterface {
    /**
     * The prefix for all Resale Certificates in Content Documents
     */
    public static final String RESALE_CERTIFICATE_CONTENT_DOCUMENT_TITLE_PREFIX = 'Resale Certificate - ';
    /**
     * The Email Template Title for a Lead in a State with a Resale Certificate
     */
    public static final String WITH_CERTIFICATE_EMAIL_TEMPLATE = 'BDR Assignment Email With Certificate';
    /**
     * The Email Template Title for a Lead in a State without a Resale Certificate
     */
    public static final String NO_CERTIFICATE_EMAIL_TEMPLATE = 'BDR Assignment Email No Certificate'; 
    /**
     * The Email Template Title for a Lead in a Florida or Lousina
     */
    public static final String UNIQUE_CERTIFICATE_EMAIL_TEMPLATE = 'BDR Assignment Email Unique Certificate'; 
    /**
     * Set with the names of the Email Templates in it
     */
    public static final Set<String> EMAIL_TEMPLATE_DEVELOPER_NAMES_SET = new Set<String>{WITH_CERTIFICATE_EMAIL_TEMPLATE,NO_CERTIFICATE_EMAIL_TEMPLATE,UNIQUE_CERTIFICATE_EMAIL_TEMPLATE};
    /**
     * The Record Type Id of Organization Lead on the Lead Object
     */
    public static final Id ORGANIZATION_LEAD_RECORD_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();
    /**
     * Leads that we will process in the afterUpdate gathered in the beforeUpdate
     */
    public static Set<Lead> processingLeadSet = new Set<Lead>();
    /**
     * Leads States that we will process in the afterUpdate gathered in the beforeUpdate. Used in query
     */
    public static Set<String> processingLeadStateSet = new Set<String>();
    /**
     * Leads Owners that we will process in the afterUpdate gathered in the beforeUpdate. Used in query
     */
    public static Map<Id,User> processingOwnerMap = new Map<Id,User>();
    /**
     * Lead Queue for which Email should not be sent
     */
    public static Set<String> dontSendEmailQueues = new Set<String>();
    /**
     * Lead QueueIds for which Email should not be sent
     */
    public static Map<Id, Group> dontSendEmailQueueMap = new Map<Id, Group>();
    
    //static init block added as part of IO-1646 - refactoring code
    static{
        dontSendEmailQueues = new Set<String>( System.Label.Dont_Send_BDR_Email_Queues.split(',') );
        dontSendEmailQueueMap = new Map<Id, Group>([Select Id, DeveloperName from Group where DeveloperName IN:dontSendEmailQueues]);
    }

    /**
     * BeforeUpdate for Trigger
     * Willupdate the field BDR Email Sent to true if we will be sending this Lead an email
     * @param oldMap old values of Leads
     * @param newMap new values of Leads
     */
    public override void beforeUpdate( Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
        Set<Id> ownerIdSet = new Set<Id>();
        /* commented as part of IO-1646 - refactoring code, moved to static block
        dontSendEmailQueues =  new Set<String>( System.Label.Dont_Send_BDR_Email_Queues.split(',') );
        dontSendEmailQueueMap = new Map<Id, Group>([Select Id, DeveloperName from Group where DeveloperName IN:dontSendEmailQueues]);*/
        List<Lead> leadsTofollowUp = new List<Lead>();
        for( Lead l : (List<Lead>)newMap.values() ){
            Lead oldLead = (Lead)oldMap.get(l.Id);
            if(oldLead.OwnerId != l.OwnerId && l.RecordTypeId == ORGANIZATION_LEAD_RECORD_ID && l.OwnerId.getSobjectType() == Schema.User.SObjectType) {
                l.IST_Account_Owner__c= l.OwnerId;
            } 
            
            if((!l.Dont_Send_BDR_Email__c && l.OwnerId != null && oldLead.OwnerId != null && !l.BDR_Email_Sent__c && l.RecordTypeId == ORGANIZATION_LEAD_RECORD_ID && !FromDontSendEmailQueue(oldLead)) && 
              (l.Assigned_On_Insert__c || ownerChangedToUser(oldLead, l))) {
                 ownerIdSet.add(l.OwnerId);
                 leadsToFollowUp.add(l);
             }
        }
        if( !ownerIdSet.isEmpty() ){
            processingOwnerMap = new Map<Id,User>( [ SELECT Id, Calendly_Link__c, Email FROM User WHERE Id IN :ownerIdSet ] );
            for( Lead l : leadsToFollowUp ){
                Lead oldLead = (Lead)oldMap.get(l.Id);
                if( processingOwnerMap.get(l.OwnerId) != null && String.isNotBlank( processingOwnerMap.get(l.OwnerId).Calendly_Link__c ) ){
                    l.BDR_Email_Sent__c = true;
                    l.Assigned_On_Insert__c = false; // Setting this false so we don't send email a second time for any that had this as true
                    processingLeadSet.add(l);
                    String strState = l.State;
                    String strStateUpperCase = strState.toUpperCase();
                    processingLeadStateSet.add(RESALE_CERTIFICATE_CONTENT_DOCUMENT_TITLE_PREFIX+strStateUpperCase);
                }else{
                    l.addError('This BDR does not have a Calendly Link. Please update this on their user before assigning them a lead.');
                }
            }
        }
    }
    /**
     * AfterUpdate logic
     * Sends the Apex Email to the user
     * @param oldMap old values of Leads
     * @param newMap new values of Leads
     */
    public override void afterUpdate( Map<Id,sObject> oldMap, Map<Id,sObject> newMap){
        if( processingLeadSet.size() > 0 ){
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Map<String,EmailTemplate> bdrEmailTemplateMap = new Map<String,EmailTemplate>();
            for( EmailTemplate et : [ SELECT Id, Name FROM EmailTemplate WHERE Name IN :EMAIL_TEMPLATE_DEVELOPER_NAMES_SET LIMIT 3 ] ){
                bdrEmailTemplateMap.put(et.Name, et);
            }
            Set<String> noCertStateSet = new Set<String>( System.Label.No_Certificate_States.split(',') );
            Set<String> uniqueCertStateSet = new Set<String>( System.Label.Unique_Certificate_States.split(',') );
            Map<String,ContentVersion> resaleCertMap = new Map<String,ContentVersion>();
            for( ContentVersion cv : [SELECT Id, Title FROM ContentVersion WHERE Title IN :processingLeadStateSet AND isLatest = true] ){
                resaleCertMap.put( cv.title.removeStartIgnoreCase(RESALE_CERTIFICATE_CONTENT_DOCUMENT_TITLE_PREFIX), cv);
            }
            List<OrgWideEmailAddress> lstEmailAddress=[ SELECT Id FROM OrgWideEmailAddress WHERE Address = 'dealeronboarding@acvauctions.com' ];
            for( Lead l : new List<Lead>(processingLeadSet) ){
 				String strState = l.State.trim();
                String strStateUpperCase = strState.toUpperCase();                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if( noCertStateSet.contains(strStateUpperCase) ){
                    email.setTemplateId(bdrEmailTemplateMap.get(NO_CERTIFICATE_EMAIL_TEMPLATE).Id);
                }else if( uniqueCertStateSet.contains(strStateUpperCase) ){
                    email.setTemplateId(bdrEmailTemplateMap.get(UNIQUE_CERTIFICATE_EMAIL_TEMPLATE).Id);
                }else if( resaleCertMap.isEmpty() ){
                    throw new CustomException('We could not properly validate this was a US Address. Please look at the Address on this lead before assigning');
                }else{
                    email.setTemplateId(bdrEmailTemplateMap.get(WITH_CERTIFICATE_EMAIL_TEMPLATE).Id);
                   
                    email.setEntityAttachments( new List<String>{resaleCertMap.get(strStateUpperCase).Id} );
                }
                email.setReplyTo(processingOwnerMap.get(l.OwnerId).Email);
                email.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
                email.setTargetObjectId(l.Id);
                emailList.add(email);
            }
            if( !emailList.isEmpty() ){
                try{
                    if( !Test.isRunningTest() ) Messaging.sendEmail( emailList );
                }catch( Exception ex ){
                    if( !ex.getMessage().contains('NO_MASS_MAIL_PERMISSION') ) throw new CustomException( ex.getMessage() );
                }
            }
            processingLeadSet.clear();
            processingLeadStateSet.clear();
            processingOwnerMap.clear();
            dontSendEmailQueueMap.clear();
            dontSendEmailQueues.clear();
        }
    }
    /**
     * a helper to check ownership changing from queue to user
     * @param oldLead oldLead Values
     * @param newLead newLead Values
     * @return  `Boolean` - whether the owner has changed to a user
     */
    public static Boolean ownerChangedToUser( Lead oldLead, Lead newLead ){
        Boolean changed = newLead.OwnerId != oldLead.OwnerId && oldLead.OwnerId.getSobjectType() == Schema.Group.SObjectType && newLead.OwnerId.getSobjectType() == Schema.User.SObjectType;
        return newLead.OwnerId != oldLead.OwnerId && oldLead.OwnerId.getSobjectType() == Schema.Group.SObjectType && newLead.OwnerId.getSobjectType() == Schema.User.SObjectType;
    }


    /**
     * a helper to check if the lead owner belongs to "Don't Sened Email" queue set
     * @param oldLead oldLead Values
     * @return  `Boolean` - whether the owner belongs to "Don't send email" queue set
     */
    public static Boolean FromDontSendEmailQueue(Lead oldLead){
        return dontSendEmailQueueMap.keyset().contains(oldLead.OwnerId);
    }
}