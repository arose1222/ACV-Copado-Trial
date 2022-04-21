@isTest
global class PredictedFloorCeilingMockCallout implements HttpCalloutMock{
    
    public Integer responseCode;
    public String responseBody;

    public PredictedFloorCeilingMockCallout(Integer responseCode, String responseBody){
        this.responseCode = responseCode;
        this.responseBody = responseBody;
    }

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HTTPResponse();
        response.setHeader('Content-Type','application/json');
        response.setBody(responseBody);
        response.setStatusCode(responseCode);
        return response;
    }
}