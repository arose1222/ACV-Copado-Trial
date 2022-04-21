public class LegacyInspectionCallout implements Queueable, Database.AllowsCallouts {
 
    public List<LegacyInspectionStruct> dataLst = new List<LegacyInspectionStruct>();

    public LegacyInspectionCallout(List<LegacyInspectionStruct> input ) {        
        dataLst = input;
    }

    public void execute( QueueableContext context ) {
        runCalloutLogic();
    }

    public void runCalloutLogic() {     
        if ( !dataLst.isEmpty() ) {
            LegacyInspectionStruct givenData = dataLst.remove(0);
            processCallout( givenData );
            if ( !dataLst.isEmpty() ) {
                System.enqueueJob( new LegacyInspectionCallout( dataLst ) );
            }
        }
    }

    public void processCallout( LegacyInspectionStruct bodyData ) {
        HttpRequest req = new HTTPRequest();

        req.setEndpoint( 'callout:Legacy_InspectionDB' );    
        req.setMethod( 'POST' ); 

        req.setHeader( 'Content-Type', 'application/json' );
        // if ( ACVUtility.isProd() ) {
        //     req.setHeader( 'Authorization', '{!$Credential.Password}' ); // - Not sure of production method yet, for reference
        // }

        String body = JSON.serialize( bodyData );
        req.setBody( body );         

        Http http = new Http();
        HttpResponse res = http.send( req );

        String resBody = res.getBody();
        Boolean hasError = ( !String.isBlank( resBody ) && resBody.contains( '"Status":"Error"' ) ) ? TRUE : FALSE;

        Integer lineNum = ACVUtility.currentLineNumber();
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel =  ( res.getStatusCode() != 200 || hasError ) ? SplunkHelper.LOGLEVEL.FATAL : SplunkHelper.LOGLEVEL.INFO;
        infoLog.location = 'LegacyInspectionCallout:' + lineNum;
        infoLog.message = ( res.getStatusCode() != 200 || hasError ) ? 'There was an issue with the callout - Check response body for more details' : 'Callout Successful';
        infoLog.stackTrace = 'LegacyInspectionCallout:' + lineNum;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'LegacyInspectionCallout';
        infoLog.sfObject = 'WorkOrder, WorkOrderLineItem, ServiceAppointment, AssignedResource';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTOR_DISPATCH };

        SplunkHelper.processIntegrationLog( infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
    }
}