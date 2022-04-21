global class FSLBackfill2Batch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    global Database.QueryLocator start( Database.BatchableContext BC ) {
        Set<String> checkSet = new Set<String>{ 'New', 'Assigned' };
        String query = 'SELECT Id, Longitude, Latitude FROM WorkOrder';
        query += ' WHERE Beta_Flag__c = TRUE AND Status IN :checkSet AND Not_Beta_Territory__c = FALSE';
        return Database.getQueryLocator( query );
    }

    global void execute( SchedulableContext sc ) {
        FSLBackfill2Batch batchClass = new FSLBackfill2Batch();
        database.executebatch( batchClass, 1 );
    }

    global void execute( Database.BatchableContext BC, List<sObject> scope ) {
        List<WorkOrder> newSALst = (List<WorkOrder>) scope;
        List<WorkOrder> updateLst = new List<WorkOrder>();
        for ( WorkOrder saRec : newSALst ) {  
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