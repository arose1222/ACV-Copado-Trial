global class CleanUpExcessRevApptResourcePrefBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start( Database.BatchableContext BC ) {      
        String query = 'SELECT Id, Status,';
        query += ' Occurrence__c, Occurrence__r.Timeline__c, Occurrence__r.Timeline__r.Service_Resource__c,';
        query += '  ( SELECT Id, RelatedRecordId, ServiceResourceId FROM ResourcePreferences )';
        query += ' FROM WorkOrder';
        query += ' WHERE StatusCategory in (\'New\') AND Occurrence__c != null';
        return Database.getQueryLocator( query );
    }

    global void execute(Database.BatchableContext BC, List<WorkOrder> scope) { 
        List<ResourcePreference> deleteRecLst = new List<ResourcePreference>();
        for ( WorkOrder woRec : scope ) {
            if ( woRec.Occurrence__c != null && woRec.Occurrence__r.Timeline__c != null &&  woRec.Occurrence__r.Timeline__r.Service_Resource__c != null ) {
                // If a Service Resource Exists on the Work Order, continue
                for ( ResourcePreference rpRec : woRec.ResourcePreferences ) {
                    if ( rpRec.ServiceResourceId != woRec.Occurrence__r.Timeline__r.Service_Resource__c ) {
                        deleteRecLst.add( rpRec );
                    }
                }
            }
        }

        if ( !deleteRecLst.isEmpty() ) { delete deleteRecLst; }
    }

    global void finish( Database.BatchableContext BC ) {
        // Don't do anything
    }
}