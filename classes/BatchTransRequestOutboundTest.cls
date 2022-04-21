@isTest
private class BatchTransRequestOutboundTest {
	@isTest static void testSchedule() {
		BatchTransRequestOutbound transBatchClass = new BatchTransRequestOutbound();
		String sch = '0 5 * * * ? *';
		String jobID = system.schedule('BatchTransRequestOutbound', sch, transBatchClass);
	}

	@isTest static void testExecute(){
		BatchTransRequestOutbound transBatchClass = new BatchTransRequestOutbound();
		database.executebatch(transBatchClass,200);
	}
}