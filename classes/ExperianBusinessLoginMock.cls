@isTest
global class ExperianBusinessLoginMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest request) {
        String json = '{'+
		'  \"issued_at\"  : \"1509914612223\",'+
		'  \"expires_in\" : \"1800\",'+
		'  \"token_type\" : \"Bearer\",'+
		'  \"access_token\" : \"VALIDACCESSTOKEN\",'+
		'  \"refresh_token\" : \"VALIDREFRESHTOKEN\"'+
		'}';
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(json);
        response.setStatusCode(200);
        return response; 
    }
}