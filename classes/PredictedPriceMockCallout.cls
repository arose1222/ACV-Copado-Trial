@isTest
global class PredictedPriceMockCallout implements HttpCalloutMock{
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HTTPResponse();
        response.setHeader('Content-Type','application/json');
        response.setBody('{"timestamp": "2019-02-28T21:16:38.688597+00:00", "version": "v1.0", "highBid": 283.0}');
        response.setStatusCode(200);
        return response;
    }
}