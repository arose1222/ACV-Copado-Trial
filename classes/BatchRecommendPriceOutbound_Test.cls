@isTest
private class BatchRecommendPriceOutbound_Test {
	
	//Main execute function covered in AcvIntegrationQueueableJobTest class

	@isTest static void testSchedule() {
		BatchRecommendPriceOutbound rpBatchClass = new BatchRecommendPriceOutbound(); 
		String sch = '0 5 * * * ? *';
		String jobID = system.schedule('BatchRecommendPriceOutbound', sch, rpBatchClass);
	}
	
}