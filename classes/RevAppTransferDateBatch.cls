global class RevAppTransferDateBatch implements Database.Batchable<SObject>, Database.Stateful {  
        global String query = 'SELECT Date_Of_Last_Generation__c FROM Occurrence__c WHERE Date_Of_Last_Generation__c != null AND Is_Active__c = true';
    
        global Database.QueryLocator start (Database.BatchableContext bc) {
            return Database.getQueryLocator(query);
        }
    
        global void execute(Database.BatchableContext bc, List<SObject> scope) {
            List<Occurrence__c> occs = (List<Occurrence__c>)scope;

            for(Occurrence__c occ : occs){
                if(occ.Date_Of_Last_Generation__c != null){
                    occ.Farthest_Date_Generated__c = occ.Date_Of_Last_Generation__c;
                    occ.Cleanup_Marker__c = true;
                }
            }

            Database.update(occs, false);

        }
    
        global void finish(Database.BatchableContext bc) {
            system.debug('finished');
        }
}