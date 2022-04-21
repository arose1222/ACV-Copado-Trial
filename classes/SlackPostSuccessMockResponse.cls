/**
 * This class holds the mock response for a successful Slack Post
 * @author James Andre LaCour
 */
@isTest
 global class SlackPostSuccessMockResponse implements HttpCalloutMock {
     /**
     * returns a successful HttpResponse for test classes going to Slack
     * @param req - HttpRequest that is sent in
     * @return HttpResponse
     */
    global HttpResponse respond( HttpRequest req ){
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
}