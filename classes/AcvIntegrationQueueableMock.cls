@isTest
global class AcvIntegrationQueueableMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public AcvIntegrationQueueableMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public AcvIntegrationQueueableMock() {
        this.code = 200;
        this.status = 'OK';
        this.body = '{"status": "ok", "user_id": 123, "session_token": "TOKEN", "data": { "id": 123}}';
        this.responseHeaders = new Map<String,String>{'Content-Type' => 'application/json'};
    }

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