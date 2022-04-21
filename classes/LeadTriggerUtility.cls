/*
Name - LeadTriggerUtility
Called From - AfterUpdate method on DemoRequestReminder Class
Description - Update the Lead and Account Count either when a lead is associated with a group 
or Lead is converted
Initial Implementation - Nagendra Namburi
*/

public inherited sharing class LeadTriggerUtility{
    
    /*
* Description - Method will be return an instance of group affiliation object
* Params - Current Lead against which the group affiliation will be created
* Return - Group_Affiliation__c object
*/
    public static Group_Affiliation__c getGroupAffiliationInstance(Lead oCurrentLead){
        return new Group_Affiliation__c(
            Group__c = oCurrentLead.Organization_Group__c ,
            Lead__c = oCurrentLead.Id,
            Lead_Id_Text__c = oCurrentLead.Id,
            Unique_Affiliation__c = oCurrentLead.Organization_Group__c+'_'+oCurrentLead.Id,
            Active__c = true
        );
    }
    
    /*
* Description - Method will be executed on after update of the Lead records. It has two primary responsibilities -
* 				1. Create an group affiliation record when a lead is associated with a org. group
* 				2. Update the AccountId on the group affiliation record when the lead is converted 
* Params - Old and New Instances of Trigger.Maps
* Return - null
*/
    public static void setLeadAndAccountCount(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        List<Group_Affiliation__c> lGroupAffiliationsToInsert = new List<Group_Affiliation__c>();
        Map<Id, Group__c> mGroupIdToGroup = new Map<Id, Group__c>();
        Map<Id, Integer> mGroupIdToLeadCount = new Map<Id, Integer>();
        Map<Id, Lead> mConvertedLeadIdToLead = new Map<Id, Lead>();
        
        
        for(Id sEachLeadId : newMap.keySet()){
            Lead oNewLead = (Lead)newMap.get(sEachLeadId);
            Lead oOldLead = (Lead)oldMap.get(sEachLeadId);
            
            if(!oOldLead.IsConverted 
               && oNewLead.Organization_Group__c != oOldLead.Organization_Group__c){
                   if(oNewLead.Organization_Group__c != null){
                       Group_Affiliation__c  oGroupAffiliation=  LeadTriggerUtility.getGroupAffiliationInstance(oNewLead);
                       lGroupAffiliationsToInsert.add(oGroupAffiliation);
                       
                   }
               }
            
            if(oOldLead.IsConverted != oNewLead.IsConverted  
               && oNewLead.IsConverted && oNewLead.Organization_Group__c != null ){
                   mConvertedLeadIdToLead.put(oNewLead.Id, oNewLead);
               }
        }
        
        if(!mConvertedLeadIdToLead.isEmpty()){
            updateGroupAffiliationRecords(mConvertedLeadIdToLead);
            
        }
        
        if(!lGroupAffiliationsToInsert.isEmpty()){
            insert lGroupAffiliationsToInsert;
        }
        
        
    }
    

    
    public static void updateGroupAffiliationRecords(Map<Id, Lead> mLeadIdToLead){
        List<Group_Affiliation__c> lGroupAffiliationsToUpdate = new List<Group_Affiliation__c>();
        For(Group_Affiliation__c oEachGroupAffiliation : [Select Id, Lead__c, Account__c FROM Group_Affiliation__c
                                                          WHERE Lead__c IN :mLeadIdToLead.keySet() ]){
                                                              Lead oAssociatedLead = (Lead)mLeadIdToLead.get(oEachGroupAffiliation.Lead__c);                                                
                                                              oEachGroupAffiliation.Account__c = oAssociatedLead.ConvertedAccountId;
                                                              oEachGroupAffiliation.Lead_Id_Text__c = null;
                                                              lGroupAffiliationsToUpdate.add(oEachGroupAffiliation);
                                                          }
        if(!lGroupAffiliationsToUpdate.isEmpty()){
            update lGroupAffiliationsToUpdate;
        }
    }
    
        /*
* Description - Method will be executed on after update of the Lead records. It has two primary responsibilities -
* 				1. Create an group affiliation record when a lead is associated with a org. group
* 				2. Update the AccountId on the group affiliation record when the lead is converted 
* Params - Old and New Instances of Trigger.Maps
* Return - null

    public static void setLeadAndAccountCount(Map<Id,SObject> oldMap){
        
        Map<Id, Lead> mOldLeadIdToLead = (Map<Id, Lead>)oldMap;
        updateGroupAffiliationRecords(mOldLeadIdToLead);
    }
*/
}