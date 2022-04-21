public class CreateRelatedTDR {
	public static void create(List<Case> lCase){
		//get the ID of the trigger objects 
		Map<String, Case> caseMap = new Map<String,Case>();
		List<Transportation_Dispatch_Request__c> TDRlist = new List<Transportation_Dispatch_Request__c>();
		Id TransportationRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();

		for(Case c :lCase){
			if(c.recordTypeId == TransportationRTId && c.status != 'Cancelled by ACV' && c.status != 'Awaiting Release' && !caseMap.containsKey(c.id) ){
				caseMap.put(c.id,c);
			}
		}

		//if there are no triggerIDs to work with then exit
		if(caseMap.values().size() > 0){
				//create list of related TDRS for the cases. If the case is ready to post and doesn't have TDR then create one
			Set<Id> caseIdsWithTDRSet = new Set<Id>();
			for(Transportation_Dispatch_Request__c tdr :[SELECT Related_Transportation_Case__c FROM Transportation_Dispatch_Request__C WHERE Related_Transportation_Case__C IN :caseMap.keySet()]){
				caseIdsWithTDRSet.add(tdr.Related_Transportation_Case__c);	
			}

	
			for(case c :caseMap.values()){
				if(!caseIdsWithTDRSet.contains(c.id)){
					Transportation_Dispatch_Request__c newTDR = new Transportation_Dispatch_Request__c(Related_Transportation_Case__c = c.id);
					TDRlist.add(newTDR);
				}
			}

			//Insert TDRs for Read-to-Post transportation cases
			if(TDRlist.size() > 0){
				insert TDRlist;
				TransportationDispatchRequestHandler.setRecursion(false);
				System.Debug('TDRs Inserted');
				//TransportationDispatchRequestHandler.run(true, lCase);
			}
		}
	}
}