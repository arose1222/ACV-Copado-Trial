@isTest
public class VirtualLiftAPIHelperTest {

    @isTest
    public static void testUserActivateGood(){
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        List<String> newUserList = new List<String>();
        newUserList.add('9999');
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.whiteListUser(newUserList);
        Test.stopTest();
        System.assert(result, 'Users were not whitelisted');
    }

    @isTest
    public static void testUserActivateBad(){
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        List<String> newUserList = new List<String>();
        newUserList.add('9999');
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.whiteListUser(newUserList);
        Test.stopTest();
        System.assert(!result, 'Users were whitelisted');
    }

    @isTest
    public static void testUserActivateBadLogin(){
        SingleRequestMock loginResp = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/activate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        List<String> newUserList = new List<String>();
        newUserList.add('9999');
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.whiteListUser(newUserList);
        Test.stopTest();
        System.assert(!result, 'Users were whitelisted');
    }

    @isTest
    public static void testUserDeactivateGood(){
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        List<String> newUserList = new List<String>();
        newUserList.add('9999');
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.deactivateUser(newUserList);
        Test.stopTest();
        System.assert(result, 'Users were not deactivated');
    }

    @isTest
    public static void testUserDeactivateBad(){
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        List<String> newUserList = new List<String>();
        newUserList.add('9999');
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.deactivateUser(newUserList);
        Test.stopTest();
        System.assert(!result, 'Users were deactivated');
    }

    @isTest
    public static void testUserDeactivateBadLogin(){
        SingleRequestMock loginResp = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        List<String> newUserList = new List<String>();
        newUserList.add('9999');
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.deactivateUser(newUserList);
        Test.stopTest();
        System.assert(!result, 'Users were deactivated');
    }

    @isTest
    public static void testUserCheckGood(){
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(200,'OK','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        String userId = '9999';
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/check/'+userId+'/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.checkUserVLStatus(userId);
        Test.stopTest();
        System.assert(result, 'User is Not Active');
    }

    @isTest
    public static void testUserCheckBad(){
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        String userId = '9999';
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/check/'+userId+'/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.checkUserVLStatus(userId);
        Test.stopTest();
        System.assert(!result, 'User is Active');
    }

    @isTest
    public static void testUserCheckBadLogin(){
        SingleRequestMock loginResp = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"message": "Successfully added user to whitelist","code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        String userId = '9999';
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/whitelist/check/'+userId+'/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.checkUserVLStatus(userId);
        Test.stopTest();
        System.assert(!result, 'User is Acvtive');
    }

    @isTest
    public static void testVinDeactivateGood(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(200,'OK','{"api_version": 2,"data": {"vin": "'+vin+'","code": "200"}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.deactivateVLImagesByVin(vin);
        Test.stopTest();
        System.assert(result, 'Vin is Not Active');
    }

    @isTest
    public static void testVinDeactivateBad(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"vin": "'+vin+'","code": "200"}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.deactivateVLImagesByVin(vin);
        Test.stopTest();
        System.assert(!result, 'Vin is Active');
    }

    @isTest
    public static void testVinDeactivateBadLogin(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2,"data": {"vin": "'+vin+'","code": "200"}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/deactivate/',uactiveRes);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        Boolean result = vl.deactivateVLImagesByVin(vin);
        Test.stopTest();
        System.assert(!result, 'Vin is Acvtive');
    }

    @isTest
    public static void testVinCheckGood(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "2CNFLEEC6B6398791","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins='+vin+'&recent_days_back=90', uactiveRes);
        List<String> vinList = new List<String>();
        vinList.add(vin);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        List<VLVinObject.Virtual_lift_list> result = vl.getVLsFromListOfVins(vinList);
        Test.stopTest();
        System.assert(result.size() > 0, 'No Vin Found');
    }

    @isTest
    public static void testVinCheckBad(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "2CNFLEEC6B6398791","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins='+vin+'&recent_days_back=90', uactiveRes);
        List<String> vinList = new List<String>();
        vinList.add(vin);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        List<VLVinObject.Virtual_lift_list> result = vl.getVLsFromListOfVins(vinList);
        Test.stopTest();
        System.assert(result == null, 'Vin Found');
    }

    @isTest
    public static void testVinCheckBadLogin(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(400,'BAD','{"api_version": 2.0,"data": {"virtual_lift_list": [{"guid": 432193,"vin": "2CNFLEEC6B6398791","active": true,"owner_remote_uid": 13347,"link": "https://cdn.acvauctions.com/ent-micro-virtual-lift/prod/upload/virtualliftfiles/2019/11/26/user_1574796919.370457/reconstruction.jpg","created": "02:35 PM ET 11/26/19"}],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins='+vin+'&recent_days_back=90', uactiveRes);
        List<String> vinList = new List<String>();
        vinList.add(vin);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        List<VLVinObject.Virtual_lift_list> result = vl.getVLsFromListOfVins(vinList);
        Test.stopTest();
        System.assert(result == null, 'Vin Found');
    }

    @isTest
    public static void testVinCheckSuccessButNoResults(){
        String vin = '4561324645313216546';
        SingleRequestMock loginResp = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        SingleRequestMock uactiveRes = new SingleRequestMock(200,'OK','{"api_version": 2.0,"data": {"virtual_lift_list": [],"code": "200"}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:R_D_MicroService/login_acv',loginResp);
        multiCall.put('callout:R_D_MicroService/virtual_lift/vin/batch/?vins='+vin+'&recent_days_back=90', uactiveRes);
        List<String> vinList = new List<String>();
        vinList.add(vin);
        Test.setMock(HttpCalloutMock.class, new MultiRequestMock(multiCall));
        Test.startTest();
        VirtualLiftAPIHelper vl = new VirtualLiftAPIHelper();
        List<VLVinObject.Virtual_lift_list> result = vl.getVLsFromListOfVins(vinList);
        Test.stopTest();
        System.assert(result == null, 'Vin Found');
    }

    public class MultiRequestMock implements HttpCalloutMock {
        Map<String, HttpCalloutMock> requests;

        public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
            this.requests = requests;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpCalloutMock mock = requests.get(req.getEndpoint());
            if (mock != null) {
                return mock.respond(req);
            } else {
                    throw new CustomException('HTTP callout not supported for test methods: '+req.getEndpoint());
            }
        }

        public void addRequestMock(String url, HttpCalloutMock mock) {
            requests.put(url, mock);
        }
    }

    public class SingleRequestMock implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String bodyAsString;
		protected Blob bodyAsBlob;
		protected Map<String, String> responseHeaders;

		public SingleRequestMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
		}

		public SingleRequestMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
		}

	    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}
}