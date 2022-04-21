/**
*******************************************************************************
* trac_UtilityClass  
* @description: This is a utility class where we can have functions which can be 
				called from any class for common implementation
* @author  		Traction on Demand
* @date 		2020-04-13
********************************************************************************/
public class trac_UtilityClass {
    
    /**
    * @description :compareSkillsWorkTypeAndSerResource utility method which compares
      service resource and it's corresponding skill set with work type and it's skill
      set
    * @Param: List<Timeline__c>
    * @return :
    */
    public static void compareSkillsWorkTypeAndSerResource(List<Timeline__c> newRevAppList){
        //fetch all work types with their skill set
        Set<ID> serviceReourceIdSet = new Set<ID>();
        Set<ID> workTypeIdSet = new Set<ID>();
        Map<String, Set<STRING>> mapOfServiceResourceAndSkills = new Map<String, Set<STRING>>();
        Map<String, Set<STRING>> mapOfWorkTypeAndSkills = new  Map<String, Set<STRING>>();
        for(Timeline__c revAppRecord: newRevAppList){
            //checking if both work type and service resources are tagged
            if( revAppRecord.Work_Type__c != NULL && revAppRecord.Service_Resource__c != NULL){
                workTypeIdSet.add(revAppRecord.Work_Type__c);
                serviceReourceIdSet.add(revAppRecord.Service_Resource__c);
            }
        }
       
        if(serviceReourceIdSet != NULL && !serviceReourceIdSet.isEmpty()){
            //creating a map of Service Resource and corresponding Skills
            mapOfServiceResourceAndSkills = createMapServiceResAndSkill(serviceReourceIdSet);
        }
        if(workTypeIdSet != NULL && !workTypeIdSet.isEmpty()){
            //creating a map of Work Type and corresponding Skills
            mapOfWorkTypeAndSkills = createMapWorkTypeAndSkill(workTypeIdSet);
        }
        
        if(!mapOfWorkTypeAndSkills.values().isEmpty() 
           && newRevAppList != NULL ){
            //Validating if service resource has required skill set to execute a worktype
            validateRecordsForValidSkillSet(newRevAppList,mapOfServiceResourceAndSkills,mapOfWorkTypeAndSkills);
        }
    }
    
    /**
    * @description :createMapServiceResAndSkill methods creates a map of
    * service resource and it's corresponding skill set
    * @Param: Set<Id>
    * @return :
    */
    private static Map<String, Set<STRING>> createMapServiceResAndSkill(Set<Id> serviceReourceIdSet){
        Map<String, Set<STRING>> mapOfServiceResourceAndSkills = new Map<String, Set<STRING>>();
        for(ServiceResourceSkill serviceResourceSkillRec:[SELECT ServiceResourceId,SkillId,Skill.MasterLabel 
                                                          FROM ServiceResourceSkill
                                                          WHERE ServiceResourceId IN:serviceReourceIdSet]){
                                                              
                                                              Set<String> setOfSkillDetails;
                                                              if(!mapOfServiceResourceAndSkills.containskey(serviceResourceSkillRec.ServiceResourceId)){
                                                                  setOfSkillDetails = new Set<String>();
                                                                  setOfSkillDetails.add(serviceResourceSkillRec.Skill.MasterLabel);
                                                                  mapOfServiceResourceAndSkills.put(serviceResourceSkillRec.ServiceResourceId,setOfSkillDetails);
                                                              }
                                                              else{
                                                                  setOfSkillDetails = mapOfServiceResourceAndSkills.get(serviceResourceSkillRec.ServiceResourceId);
                                                                  setOfSkillDetails.add(serviceResourceSkillRec.Skill.MasterLabel);
                                                                  mapOfServiceResourceAndSkills.put(serviceResourceSkillRec.ServiceResourceId,setOfSkillDetails);
                                                              }
                                                          }
        return mapOfServiceResourceAndSkills;
    }
    
    /**
    * @description :createMapWorkTypeAndSkill methods creates a map of
    * work type and it's corresponding skill set
    * @Param: Set<Id> Id's of work type
    * @return :Map<String, Set<STRING>>
    */
    private static Map<String, Set<STRING>> createMapWorkTypeAndSkill(Set<Id> workTypeIdSet){
        Map<String, Set<STRING>> mapOfWorkTypeAndSkills = new  Map<String, Set<STRING>>();
        for(SkillRequirement workTypeSkillRec:[SELECT RelatedRecordId,SkillId,skill.MasterLabel
                                               FROM SkillRequirement
                                               WHERE RelatedRecordId IN:workTypeIdSet]){
                                                   
                                                   Set<String> setOfSkillDetails;
                                                   if(!mapOfWorkTypeAndSkills.containskey(workTypeSkillRec.RelatedRecordId)){
                                                       setOfSkillDetails = new  Set<String>();
                                                       setOfSkillDetails.add(workTypeSkillRec.Skill.MasterLabel);
                                                       mapOfWorkTypeAndSkills.put(workTypeSkillRec.RelatedRecordId,setOfSkillDetails);
                                                   }
                                                   else{
                                                       setOfSkillDetails = mapOfWorkTypeAndSkills.get(workTypeSkillRec.RelatedRecordId);
                                                       setOfSkillDetails.add(workTypeSkillRec.Skill.MasterLabel);
                                                       mapOfWorkTypeAndSkills.put(workTypeSkillRec.RelatedRecordId,setOfSkillDetails);
                                                   }
                                               }
        return mapOfWorkTypeAndSkills;
    }
    
    /**
    * @description :validateRecordsForValidSkillSet checks if the service resource
    * is able to conduct the work type 
    * @Param newRevAppList List<Timeline__C> records
    * @Param mapOfServiceResourceAndSkills contains service resource and it's skills
    * @Param mapOfWorkTypeAndSkills contains work type and its corresponding skills
    * @return :NULL
    */
    private static void validateRecordsForValidSkillSet(List<Timeline__c> newRevAppList,  
                                                        Map<String, Set<STRING>> mapOfServiceResourceAndSkills, 
                                                        Map<String, Set<STRING>> mapOfWorkTypeAndSkills){
        for(Timeline__c revAppRecord: newRevAppList){
            //making sure that workType and service Resource both have skill set
            if( mapOfWorkTypeAndSkills.containsKey(revAppRecord.Work_Type__c) 
               && mapOfServiceResourceAndSkills.containsKey(revAppRecord.Service_Resource__c)){
                   // since both these map contains set we can now compare if after removing a complete still 
                   Set<String> setOfExistingWorkTypeSkills = mapOfWorkTypeAndSkills.get(revAppRecord.Work_Type__c);
                   Set<String> setOfExistingServiceResSkills = mapOfServiceResourceAndSkills.get(revAppRecord.Service_Resource__c);
                   setOfExistingWorkTypeSkills.removeAll(setOfExistingServiceResSkills);
                   if(setOfExistingWorkTypeSkills.size()>0){
                       revAppRecord.addError( Label.trac_Error_Message_Service_Resource_Skill +' '+setOfExistingWorkTypeSkills);
                   }
               }
            //Condition where a work type has added skill but service resource don't have any skill
            else if(mapOfWorkTypeAndSkills.containsKey(revAppRecord.Work_Type__c) && 
                    !mapOfServiceResourceAndSkills.containsKey(revAppRecord.Service_Resource__c) && revAppRecord.Service_Resource__c != null){
                        Set<String> setOfExistingWorkTypeSkills = mapOfWorkTypeAndSkills.get(revAppRecord.Work_Type__c);
                        revAppRecord.addError(Label.trac_Error_Message_Service_Resource_Skill +' '+setOfExistingWorkTypeSkills);
                    }
        }
    }
}