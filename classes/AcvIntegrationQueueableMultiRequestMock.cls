public class AcvIntegrationQueueableMultiRequestMock implements HttpCalloutMock{
	Map<String, HttpCalloutMock> requests;

	public AcvIntegrationQueueableMultiRequestMock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;		
	}

	public HTTPResponse respond(HTTPRequest req){
	
		httpCalloutMock mock = requests.get(req.getEndpoint());
		System.debug('mock: ' + mock);
		return mock.respond(req);
		
	}

	public void addRequestMock(String url, HttpCalloutMock mock){
		requests.put(url, mock);
	}
}