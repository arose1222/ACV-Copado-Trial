global class FSLBackfillBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        Set<String> checkSet = new Set<String>{ 'New', 'Scheduled' };
        String query = 'SELECT Id, Longitude, Latitude FROM ServiceAppointment';
        query += ' WHERE Beta_Flag__c = TRUE AND Status IN :checkSet AND Not_Beta_Territory__c = FALSE';
        return Database.getQueryLocator( query );
    }

    global void execute( SchedulableContext sc ) {
        FSLBackfillBatch batchClass = new FSLBackfillBatch();
        database.executebatch( batchClass, 1 );
    }

    global void execute( Database.BatchableContext BC, List<sObject> scope ) {
        List<ServiceAppointment> newSALst = (List<ServiceAppointment>) scope;
        List<ServiceAppointment> updateLst = new List<ServiceAppointment>();
        for ( ServiceAppointment saRec : newSALst ) {  
            Id stId = FSL.PolygonUtils.getTerritoryIdByPolygons( 
                Double.valueOf( saRec.longitude ), 
                Double.valueOf( saRec.latitude ) 
            );
            if ( !String.isBlank( stId ) ) {
                saRec.ServiceTerritoryId = stId;
                updateLst.add( saRec );
            }
        }

        update updateLst;
    }
    
    global void finish( Database.BatchableContext BC ) {
        // don't do anything
    }
}