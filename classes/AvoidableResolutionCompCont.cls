public class AvoidableResolutionCompCont {
    public Id resId {get;set;}

    public AvoidableResolutionCompCont(){

    }

    public resolution__c getNewRes(){
        return [Select id, Case__r.Vehicle__c, Case__r.Vehicle__r.Name, Case__r.Auction_Number__r.Name, Case__r.Vehicle__r.Make__c,Case__r.Vehicle_Year_Make_Model__c,
                      Case__r.Vehicle__r.Model__c,Case__r.Vehicle__r.Year__c,Case__r.Auction_Number__c,complaint_id__r.Avoidable_Notes__c, Case__c, Case__r.CaseNumber 
                      from Resolution__c where id = :resId limit 1];
    }
}