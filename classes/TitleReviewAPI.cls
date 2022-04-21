/**
 * @description 
 * 
 * 
 * @author Manmeet Vaseer
 * @date 03/17/2022
 * 
 * @history
 * 		03/17/2022 Manmeet Vaseer - Initial Revision.
 * 
 */ 
public class TitleReviewAPI implements Queueable, Database.AllowsCallouts {
    @testVisible private static final String SET_TITLE_REVIEW_SALESFORCE_IDS_ENDPOINT = '/api/v1/titlereview/salesforceIds';

    public ID jobId = null;

    List<TitleReviewPayload> payload = new List<TitleReviewPayload>(); 
    String endpointUrl = null;
    
    /**
     * Salesforce Gateway request to send Salesforce Ids for newly created Title Reviews.
     * 
     * @param titleReviews - A list of Title Review records.
     * 
     */
    public void setTitleReviewSalesforceId(List<Title_Review__c> titleReviews ){
        
        for(Title_Review__c aTitleReview : titleReviews)	{
            TitleReviewPayload tri = new TitleReviewPayload();
            tri.salesforceId = aTitleReview.Id;
            tri.reviewId = aTitleReview.Name;
            tri.commitPending = aTitleReview.Commit_Pending__c;
            tri.titleId = aTitleReview.ACV_Titles_External_Id__c;
            
            payload.add(tri);
        }

        this.endpointUrl = SET_TITLE_REVIEW_SALESFORCE_IDS_ENDPOINT;
		this.jobId = System.enqueueJob(this);
    }

    public void execute(QueueableContext context) {
        if(this.payload.size() > 0)  {
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Authorization', '{!$Credential.Password}');
            httpRequest.setEndpoint( 'callout:Salesforce_Gateway' + this.endpointUrl);
            httpRequest.setBody( JSON.serialize(payload) );
            
            
            HttpResponse res = new HttpResponse();
            if(!Test.isRunningTest()) res = new Http().send(httpRequest); // unit tests can't do callouts
            
            // System.HttpResponse[Status=Service Unavailable, StatusCode=503]
            if(res.getStatusCode() != 200 ) {
                makeSplunkLog(this.endpointUrl, 'POST', this.payload, null, res.getStatusCode(), ACVUtility.currentLineNumber(), 'Error Posting to Salesforce Gateway.', '', res.getStatus(), SplunkHelper.LOGLEVEL.ERROR);
            }
            else {
                makeSplunkLog(this.endpointUrl, 'POST', this.payload, null, res.getStatusCode(), ACVUtility.currentLineNumber(), 'Successfully Posted to Salesforce Gateway.', '', res.getStatus(), SplunkHelper.LOGLEVEL.INFO);
            }
        }        
    }
    
    public static void makeSplunkLog(String reqEndpoint, String reqMethodType, Object payload, Object resObj, Integer resStatusCode, Integer lineNumber, String message, String sfRecordId, String stackTrace, SplunkHelper.LOGLEVEL LogLevel){
        HttpRequest req = new HttpRequest();
        if(payload != null) req.setBody(JSON.serialize(payload));
        req.setMethod(reqMethodType);
        req.setEndpoint(reqEndpoint);
        
        HttpResponse res = new HttpResponse();
        if(resObj != null) res.setBody(JSON.serialize(resObj));
        res.setStatus(message);
        res.setStatusCode(resStatusCode);
        
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'TitleReviewAPI:' + lineNumber;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = sfRecordId;
        infoLog.componentName = 'TitleReviewAPI';
        infoLog.sfObject = 'Title_Review__c';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.ENTERPRISE_APPS};
            
        if(!Test.isRunningTest()) SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }
 
    public class TitleReviewPayload	{
        public String reviewId;			
        public String salesforceId;		// salesforce id for the Title Review
        public Boolean commitPending; 	
        public String titleId; 			
    }
}