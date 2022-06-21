/**
 * @description Mock Class for Capital Credit Decision Process Callout
 * @author Oscar Argueyo
 * @since 06/16/2022
 * @group Capital
 * @see [CSO-660]https://acvauctions.atlassian.net/browse/CSO-660
 */
@isTest
global class CapitalCreditDecisionCalloutMock implements HttpCalloutMock {
    
    protected Integer code;
    protected String status;
    public String body;
    protected Map<String, String> responseHeaders;
    
    /**
     * @description CapitalCreditDecisionCalloutMock Construct with basic params for mocked requests. 
     */
    public CapitalCreditDecisionCalloutMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    /**
     * @description CapitalCreditDecisionCalloutMock Construct with no params for sucess mocked request. 
     */
    public CapitalCreditDecisionCalloutMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '';
        this.responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
    }
    
    /**
     * @description Respond function that returns a HTTPResponse with custom params.
     * @param HTTPRequest - Request that is going to have a mocked response
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}