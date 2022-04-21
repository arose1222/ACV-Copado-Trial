global class BackfillSAAccount implements Database.Batchable<SObject>, Database.Stateful{

    global Database.QueryLocator start (Database.BatchableContext bc) {
        String query = 'SELECT Id, AccountId, CreatedDate FROM ServiceAppointment WHERE AccountId != null AND CreatedDate > 2020-01-01T00:00:00Z';
        return Database.getQueryLocator(query);
    }

    
    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        List<ServiceAppointment> updateSAs = new List<ServiceAppointment>();
        for(ServiceAppointment sa : (List<ServiceAppointment>)scope){
            if(sa.AccountId != null){
                sa.Account__c = sa.AccountId;
                updateSAs.add(sa);
            }
        }

        update updateSAs;

    }

    global void finish(Database.BatchableContext bc) {
    
    }
}