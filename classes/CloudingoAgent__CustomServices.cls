/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CustomServices {
    global CustomServices() {

    }
    webService static String CloudingoPKG(String token) {
        return null;
    }
    webService static String CloudingoRPT(String token, String content) {
        return null;
    }
    webService static Boolean activateAgent(String licenseKey, String token) {
        return null;
    }
    webService static Boolean activateAgentV2(String licenseKey, String token, String endpoint) {
        return null;
    }
    global static Boolean activateAgentV2(String licenseKey, String token, String endpoint, Boolean isTrigger) {
        return null;
    }
    webService static void confirmSync(String batchId, Boolean resend) {

    }
    webService static Boolean confirmSyncV2(String batchId, Boolean resend, String token) {
        return null;
    }
    webService static Boolean deactivateAgent(String message, String token) {
        return null;
    }
    webService static Boolean disableAgent(String token) {
        return null;
    }
    webService static Boolean disableObject(String objectName, String token) {
        return null;
    }
    webService static Boolean enableAgent(String token) {
        return null;
    }
    webService static Boolean enableAgentAndUpdateFilters(String filters, String token) {
        return null;
    }
    webService static Boolean enableObject(String objectName, String token) {
        return null;
    }
    webService static Boolean flushPoSyncs(String token) {
        return null;
    }
    webService static String getContent(String token, String url, String jsonArrayRegExpressions) {
        return null;
    }
    webService static String getFilterJSON(String token) {
        return null;
    }
    webService static List<User> getLicensedUsers(String token) {
        return null;
    }
    @ReadOnly
    webService static Integer getRecordCountForObject(String objectName, String token) {
        return null;
    }
    webService static String getSetting(String key, String token) {
        return null;
    }
    webService static List<CloudingoAgent__AgentSettings__c> getSettings(String token) {
        return null;
    }
    webService static List<AsyncApexJob> getStatusV2(String token) {
        return null;
    }
    webService static List<AsyncApexJob> getStatus() {
        return null;
    }
    webService static String ping() {
        return null;
    }
    webService static Boolean removeExpiredLogs(String token, String daysToKeep) {
        return null;
    }
    webService static List<CloudingoAgent__Log__c> requestAgentLogsV2(String minimumPriority, Datetime startDate, Datetime endDate, String token) {
        return null;
    }
    webService static List<CloudingoAgent__Log__c> requestAgentLogs(String minimumPriority, Datetime startDate, Datetime endDate) {
        return null;
    }
    webService static String startCloudingoAM(String token, String mode, String content) {
        return null;
    }
    webService static String startCloudingoPOM(String token, String content) {
        return null;
    }
    webService static Boolean startProfiling(String objectName) {
        return null;
    }
    webService static Boolean startProfilingV2(String objectName, String token) {
        return null;
    }
    webService static Boolean startScheduledProfiler(String token) {
        return null;
    }
    webService static Boolean startSynchronizing(String objectName) {
        return null;
    }
    webService static Boolean startSynchronizingV2(String objectName, String token) {
        return null;
    }
    webService static Boolean stopScheduledProfiler(String token) {
        return null;
    }
    webService static Boolean updateFilters(String filters) {
        return null;
    }
    webService static Boolean updateFiltersV2(String filters, String token) {
        return null;
    }
    webService static Boolean updateFiltersV3(String content, String token) {
        return null;
    }
    webService static Boolean updateSetting(String key, String value) {
        return null;
    }
    webService static Boolean updateSettingV2(String key, String value, String token) {
        return null;
    }
    webService static Boolean updateSingleFilter(String filters, String token, Boolean isFirstSingleFilter) {
        return null;
    }
}
