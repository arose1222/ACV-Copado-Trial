@isTest
global class PredictedHighBidMockErrorCallout implements HttpCalloutMock{

    public Integer responseCode;

    public PredictedHighBidMockErrorCallout(Integer responseCode){
        this.responseCode = responseCode;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HTTPResponse();
        response.setStatusCode(this.responseCode);
        return response;
    }
}