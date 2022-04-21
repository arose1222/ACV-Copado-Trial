@isTest
private class AcvOutboundScheduler_Test {
	
	@isTest static void testSchedule() {
		AcvOutboundScheduler acvScheduler = new AcvOutboundScheduler();
		acvScheduler.executeScheduledLogic();
	}
	
}