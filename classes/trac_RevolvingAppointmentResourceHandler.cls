/**
*******************************************************************************
* trac_RevolvingAppointmentResourceHandler  
* @description: This will check if the tagged service resource matches the skill
				set required in order to complete a certain work type
* @author  		Traction on Demand
* @date 2020-04-09

//Updated 1/22/2020 to be on the new framework
********************************************************************************/
public class trac_RevolvingAppointmentResourceHandler extends TriggerInterface{
	
    /**
    * @description : before Insert scenario 
    * @param: New List of Timeline Records
    * @return : NULL
    */
    public override void beforeInsert(List<SObject> newList){
        List<Timeline__C> newRevAppList =(List<Timeline__C>) newList;
       	trac_UtilityClass.compareSkillsWorkTypeAndSerResource(newList);
    }
	
    /**
    * @description :Before Update Scenario
    * @param: Oldmap Map<Id,Timeline__c> old records of Timeline
    * @param: newMap Map<Id,Timeline__c> changed records of Timeline
    * @return : NULL
    */
    public override void beforeUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        Map<Id, Timeline__C> newRevolvingAppMap = (Map<Id, Timeline__C>) newMap;
        Map<Id, Timeline__C> oldRevolvingAppMap = (Map<Id, Timeline__C>) oldMap;
        trac_UtilityClass.compareSkillsWorkTypeAndSerResource(newRevolvingAppMap.values());
    }
}