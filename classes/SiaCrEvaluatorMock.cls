global class SiaCrEvaluatorMock implements HttpCalloutMock{


    
    global HTTPResponse respond(HTTPRequest request) {
       HttpResponse response = new HttpResponse();
       response.setHeader('Content-Type', 'application/json');
              
       String resBody = '{'+
                            '"api_version": 2.0,'+
                            '"data": {'+
                                '"message": "OK",'+
                                '"status": "200",'+
                                '"tasks": ['+
                                    '{'+
                                        '"guid": "testId",'+
                                        '"status": "prescreen",'+
                                        '"detail": {'+
                                            '"totalDollarRisk": 34.85,'+
                                            '"categories": ['+
                                                '{'+
                                                    '"category": "Engine Noise",'+
                                                    '"odds": "1 in 30",'+
                                                    '"dollarRisk": 30,'+
                                                    '"note": "Suspicious noise in AMP"'+
                                                '}'+
                                            ']'+
                                        '}'+
                                    '}'+
                                ']'+
                            '}'+
                        '}';
       
       response.setBody(resBody);
       response.setStatusCode(200);
       return response; 
   }
   
}