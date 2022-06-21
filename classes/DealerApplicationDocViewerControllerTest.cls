@isTest
private class DealerApplicationDocViewerControllerTest {
    
    @isTest
	static void testGetFileSucceed() {
		Test.setMock(HttpCalloutMock.class, getFileListRequestMock());
		
		Test.startTest();
        try {
			String test = DealerApplicationDocViewerController.getDealerApplicationDoc('recordId', 'documentType');
            System.debug(test);
		}
		catch(Exception e) {
            System.debug(e);
		}
		Test.stopTest();
    }
    
    @isTest
    static void testSaveFile() {
		Test.setMock(HttpCalloutMock.class, getCreateFileSuccessRequestMock());

		Test.startTest();
		Integer status = DealerApplicationDocViewerController.saveFile('fileName', 'base64Data', 'contentType', 'recordId', 'documentType');
		Test.stopTest();
        System.assert(status==200, 'status should be 200');
    }
    
    @isTest
    static void testDeleteFile() {
		Test.setMock(HttpCalloutMock.class, deleteFileRequestMock());

		Test.startTest();
		Integer status = DealerApplicationDocViewerController.deleteDealerApplicationDoc('fileName', 'https://test.com');
		Test.stopTest();
        System.assert(status==200, 'status should be 200');
    }
    
   	static TestingUtility.SingleRequestMock getFileListRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>{
			'Content-Type' => 'application/x-www-form-urlencoded'
		};

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '{"firstImage": "url1"}', responseHeaders
		);

		return mock;
	}
    
    static TestingUtility.SingleRequestMock deleteFileRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>{
			'Content-Type' => 'application/x-www-form-urlencoded'
		};

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}
    
    static TestingUtility.SingleRequestMock getCreateFileSuccessRequestMock() {
		Map<String, String> responseHeaders = new Map<String, String>();

		TestingUtility.SingleRequestMock mock = new TestingUtility.SingleRequestMock(
			200, 'Success', '', responseHeaders
		);

		return mock;
	}
}