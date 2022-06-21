/**
 * CreditDecisionOpportunityTrigger class to execute Automatic Credit Decision Processs when certain Opportunities are updated.
 * @author Oscar Argueyo
 * @team ACV Capital
 * @jiraticket CSO-660 
 */
public class CreditDecisionOpportunityTrigger extends TriggerInterface {
   
    public override void beforeUpdate(Map<Id,SObject> incomingOldMap, Map<Id,SObject> incomingNewMap){
        Map<Id, Opportunity> newMap = (Map<Id, Opportunity>)incomingNewMap;
        Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>)incomingOldMap;    
        CreditDecisionCalloutService.initOpportunityCreditDecisionProcess(oldMap, newMap);
    }
}