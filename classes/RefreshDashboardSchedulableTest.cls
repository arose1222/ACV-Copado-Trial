@isTest
public class RefreshDashboardSchedulableTest {
    
    @isTest
    static void scheduleClass() {
        Test.setMock( HttpCalloutMock.class, new DashboardRefresh() );
        
        Test.startTest();
            RefreshDashboardSchedulable schClass = new RefreshDashboardSchedulable();
            SchedulableContext sc = null;
            schClass.execute( sc );
        Test.stopTest();
    }

    public class DashboardRefresh implements HTTPCalloutMock {
        public HTTPResponse respond( HTTPRequest req ) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader( 'Content-Type', 'application-json' );
            res.setBody( '{"statusUrl":"/services/data/v35.0/analytics/dashboards/01ZK0000000BDPOMA4/status"}' );
            res.setStatusCode( 201 );

            return res;
        }
    }
    
}