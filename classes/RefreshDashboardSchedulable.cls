global class RefreshDashboardSchedulable implements Database.Stateful, Schedulable {

	global void execute( SchedulableContext sc ) {
        Set<String> dashIdSet = new Set<String>();

		for ( Refresh_dashboard__mdt dashboardRec : [ SELECT Salesforce_id__c FROM Refresh_Dashboard__mdt ] ) {
            dashIdSet.add( dashboardRec.Salesforce_id__c );
        }

        RefreshDashboardSchedulable.processCallout( dashIdSet );
        ACVUtility.scheduleJob( DateTime.now().addMinutes( 5 ), 'RefreshDashboardSchedulable' );
	}

    @future(callout=true)
    global static void processCallout( Set<String> dashIdSet ) {
        if ( !dashIdSet.isEmpty() ) {
            for ( Id dashboardId : dashIdSet ) {
                HttpRequest req = new HTTPRequest();
                req.setHeader( 'Authorization', 'Bearer ' + UserInfo.getSessionId() );
                req.setMethod( 'PUT' );
                req.setEndpoint( URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v35.0/analytics/dashboards/' + dashboardId );

                Http http = new Http();
                HttpResponse res = http.send( req );
            }
        }
    }
}