@isTest
public class TrueFrameAccountSyncTest {

    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        a.Dealership_ID__c = '1';
        insert a;
    }
    
    @isTest
    public static void testGoodCall(){
        TrueFrameAccountSync.tfSync jsObject = new TrueFrameAccountSync.tfSync();
        jsObject.acv_id = 1;
        jsObject.info_id = 1;
        jsObject.name = 'String';
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(setCallOutDetailsGood()));
        System.Assert(TrueFrameAccountSync.syncAccount(JSON.serialize(jsObject)),'False was returned instead of true');
        Test.stopTest();
    }

    @isTest
    public static void testBadCall(){
        TrueFrameAccountSync.tfSync jsObject = new TrueFrameAccountSync.tfSync();
        jsObject.acv_id = 1;
        jsObject.info_id = 1;
        jsObject.name = 'String';
        Test.startTest();
        test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(setCallOutDetailsBad()));
        System.Assert(!TrueFrameAccountSync.syncAccount(JSON.serialize(jsObject)),'True was returned instead of true');
        Test.stopTest();
    }

    static Map<String,HttpCalloutMock> setCallOutDetailsGood(){
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(200,'OK','',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Trueframe/api/dealer-proxy', uactiveRes);
        return multiCall;
    }

    static Map<String,HttpCalloutMock> setCallOutDetailsBad(){
        TestingUtility.SingleRequestMock uactiveRes = new TestingUtility.SingleRequestMock(401,'OK','',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:Trueframe/api/dealer-proxy', uactiveRes);
        return multiCall;
    }
}