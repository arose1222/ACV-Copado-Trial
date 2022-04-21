/******************************************************************************* 
@description : This Apex class is used as a controller for dealerProgramApplication LWC Component
@author Saisystems
*******************************************************************************/
global without sharing class DealerProgramApplicationController {
    
    /******************************************************************************* 
    @description : This function is used to get all the Files related to ProgramEnrollment
    @author Saisystems
    *******************************************************************************/
    @AuraEnabled
    public static List<ContentVersion> getContentDetails(String recordId) {
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                         FROM   ContentDocumentLink 
                                                         WHERE  LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();
        
        for(ContentDocumentLink cdl : contentDocumentList){
            contentDocumentId.add(cdl.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                   ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                   CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                   FROM   ContentVersion 
                                                   WHERE  ContentDocumentId IN : contentDocumentId];
        return contentVersionList;
        //return JSON.serialize(contentVersionList);
    }
    
    /******************************************************************************* 
    @description : This function is used to get the details of Program And the ContactRecord Details
    @author Saisystems
    *******************************************************************************/
    @AuraEnabled(cacheable=true)
    public static ProgramAndContactDetails getProgramAndContactDetails(String programId, String accountId, 
                                                                       String primaryContactId, String recordId){
		system.debug('@@@@programId----'+programId);
        system.debug('@@@@accountId----'+accountId);
        system.debug('@@@@primaryContactId----'+primaryContactId);
        Boolean isLinkExpired = false;
		List<ContentVersion> contentVersionList = new List<ContentVersion>();
        Program__c programRecord = null;
        Contact contactRecord = null;
        Program_Enrollment__c programEnrollment = null;                                                                   
        List<Rule_Assignment__c> programRuleAssignments = null;
        List<ProgramRuleAssignmentAndAcceptance> ProgramRuleAssignmentAndAcceptanceList = new List<ProgramRuleAssignmentAndAcceptance>();
        if(!String.isBlank(programId)){
            //String programName = '%'+programId+'%';
            programRecord = [SELECT Id, Name, Active__c  
                             FROM Program__c
                             WHERE Id =: programId
                             ];
            programEnrollment = [SELECT Id, Name, Invitation_Sent_Date__c, No_Of_Days_Since_Invitation_Sent__c, Invitation_Link_Expired__c,
                                 Account_Manager_First_Name__c, Account_Manager_Email__c, Has_Customer_Applied__c
                             FROM Program_Enrollment__c
                             WHERE Id =: recordId
                             ];
            system.debug('@@@@programEnrollment----'+programEnrollment);
            if(programEnrollment != null && programEnrollment.No_Of_Days_Since_Invitation_Sent__c >= 15 ){	
                //programEnrollment.Invitation_Link_Expired__c = true;
                //update programEnrollment;
                isLinkExpired = true;
                updateEnrolmentRecord(programEnrollment.Id);
            }
            programRuleAssignments = [SELECT Id, Name, Program_Rule__c, Program__c, Program_Rule__r.Name, Program_Rule__r.Description__c
                                        FROM Rule_Assignment__c 
                                        WHERE Program__c =: programId
                                        ]; 
            if(!programRuleAssignments.isEmpty()){                
                for(Rule_Assignment__c ruleAssignmentRecord : programRuleAssignments){
                    ProgramRuleAssignmentAndAcceptance programRuleAssignmentAndAcceptanceRecord = new ProgramRuleAssignmentAndAcceptance(false, ruleAssignmentRecord);
                    ProgramRuleAssignmentAndAcceptanceList.add(programRuleAssignmentAndAcceptanceRecord);
                }    
            }                                                                      
        }
        if(!String.isBlank(primaryContactId)){
            contactRecord = [SELECT Id, Name, Account.Name, Title, Phone, Email, Account.Website 
                            FROM Contact
                            WHERE Id =: primaryContactId LIMIT 1
                            ];
        }
        if(!String.isBlank(recordId)){
            List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId 
                                                            FROM   ContentDocumentLink 
                                                            WHERE  LinkedEntityId =: recordId];
            Set<Id> contentDocumentId = new Set<Id>();
            for(ContentDocumentLink cdl : contentDocumentList){
            	contentDocumentId.add(cdl.ContentDocumentId);
            }
            contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                        ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                        CreatedDate, ContentDocumentId, ContentDocument.FileType
                                                        FROM   ContentVersion 
                                                        WHERE  ContentDocumentId IN : contentDocumentId];
        }
        system.debug('@@@@programRecord----'+programRecord);
        system.debug('@@@@contactRecord----'+contactRecord);
        return new ProgramAndContactDetails(isLinkExpired, programRecord, contactRecord, ProgramRuleAssignmentAndAcceptanceList, contentVersionList, programEnrollment);
    }
    /*
    @AuraEnabled(cacheable=true)
    public static Contact getContactCustom(String accountId) {
        if(!String.isBlank(accountId)){
            system.debug('@@@@accountId----'+accountId);
            system.debug('@@@@Inside getContact Method----');
            system.debug('@@@@contactRecord----'+[SELECT Id, Name, Account.Name, Title, Phone, Email, Account.Website 
                                                  FROM Contact
                                                  WHERE AccountId =: accountId LIMIT 1]);
            return [
                SELECT Id, Name, Account.Name, Title, Phone, Email, Account.Website 
                FROM Contact
                WHERE AccountId =: accountId LIMIT 1
            ];
        }
        return null;
    }*/
    
    @AuraEnabled
    public static boolean submitApplication(String parentId){
        system.debug('@@@@parentId----'+parentId);
        Program_Enrollment__c programEnrollmentToUpdate;
        if(!String.isEmpty(parentId)){
        	programEnrollmentToUpdate = 
                [SELECT Id, Status__c, Name, Has_Customer_Applied__c 
                FROM Program_Enrollment__c 
                WHERE Id =: parentId];
            //Desicuss the status value with Matt 
            programEnrollmentToUpdate.Status__c = 'TM will be reaching out to you soon Enrolled (start date)';
            programEnrollmentToUpdate.Has_Customer_Applied__c = true;
            update programEnrollmentToUpdate;
        }    
        return true;       
    }
    
    @future
    public static void updateEnrolmentRecord(String recordId)
    {   
         Program_Enrollment__c programEnrollment = [SELECT Id, Name, Invitation_Sent_Date__c, No_Of_Days_Since_Invitation_Sent__c, Invitation_Link_Expired__c    
                             FROM Program_Enrollment__c
                             WHERE Id =: recordId
                             ];
        programEnrollment.Invitation_Link_Expired__c = true;
        update programEnrollment;
    }
    
    /******************************************************************************* 
    @description : Wrapper class used to hold the details of Program and Contact Details
    @author Saisystems
    *******************************************************************************/
    public class ProgramAndContactDetails{
        @AuraEnabled
        Public Boolean isLinkExpired;
        @AuraEnabled
        Public Program__c programRecord;
        @AuraEnabled
        Public Program_Enrollment__c programEnrollmentRecord;
        @AuraEnabled
        Public Contact contactRecord;
        @AuraEnabled
        Public List<ProgramRuleAssignmentAndAcceptance> programRuleAssignmentAndAcceptanceList;
        @AuraEnabled 
        public List<ContentVersion> contentVersionList;
        
        ProgramAndContactDetails(Boolean isLinkExpired, Program__c programRecord, Contact contactRecord, List<ProgramRuleAssignmentAndAcceptance> programRuleAssignmentAndAcceptanceList, 
                                 List<ContentVersion> contentVersionList, Program_Enrollment__c programEnrollmentRecord){
                                     this.isLinkExpired = isLinkExpired;
                                     this.programRecord = programRecord;
                                     this.contactRecord = contactRecord;
                                     this.programRuleAssignmentAndAcceptanceList = programRuleAssignmentAndAcceptanceList;
                                     this.contentVersionList = contentVersionList;
                                     this.programEnrollmentRecord = programEnrollmentRecord;
                                 }
    }
    
    /******************************************************************************* 
    @description : Wrapper class used to hold the Program Rule Assignment and the rule Acceptance
    @author Saisystems
    *******************************************************************************/
    public class ProgramRuleAssignmentAndAcceptance{
        @AuraEnabled
        Public Boolean ruleAcceptance;
        @AuraEnabled
        Public Rule_Assignment__c programRuleAssignment;
        
        ProgramRuleAssignmentAndAcceptance(Boolean ruleAcceptance, Rule_Assignment__c programRuleAssignment){
            this.ruleAcceptance = ruleAcceptance;
            this.programRuleAssignment = programRuleAssignment;
        }
    }
}