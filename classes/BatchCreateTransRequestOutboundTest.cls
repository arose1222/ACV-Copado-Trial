@isTest
private class BatchCreateTransRequestOutboundTest {

	@isTest static void testSchedule() {
		BatchCreateTransRequestOutbound transBatchClass = new BatchCreateTransRequestOutbound();
		String sch = '0 5 * * * ? *';
		String jobID = system.schedule('BatchCreateTransRequestOutbound', sch, transBatchClass);
	}
}