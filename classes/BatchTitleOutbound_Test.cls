@isTest
private class BatchTitleOutbound_Test {
	
	//Main execute function covered in AcvIntegrationQueueableJobTest class

	@isTest static void testSchedule() {
		BatchTitleOutbound titleBatchClass = new BatchTitleOutbound();
		String sch = '0 5 * * * ? *';
		String jobID = system.schedule('BatchTitleOutbound', sch, titleBatchClass);
	}
	
}