/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ApsonaUtils {
    global ApsonaUtils() {

    }
    webService static List<String> describeSObjects(List<String> sObjectNames) {
        return null;
    }
    webService static apsona.ApsonaUtils.ApsonaInitData getInitData() {
        return null;
    }
    webService static List<SObject> runSoqlRW(String soqlString) {
        return null;
    }
    @ReadOnly
    webService static List<SObject> runSoql(String soqlString) {
        return null;
    }
    webService static Document saveMetadata(String metadataInJSON) {
        return null;
    }
global class ApsonaInitData {
    @WebService
    webService apsona.ApsonaUtils.OrgData orgData;
    @WebService
    webService apsona.ApsonaUtils.UserData userData;
    global ApsonaInitData() {

    }
}
global class OrgData {
    @WebService
    webService List<apsona__apsona_item__c> configs;
    @WebService
    webService String errorMessage;
    @WebService
    webService List<LeadStatus> leadStatuses;
    @WebService
    webService List<Profile> profiles;
    @WebService
    webService List<RecordType> recordTypes;
    @WebService
    webService List<User> users;
    global OrgData() {

    }
}
global class UserData {
    @WebService
    webService List<apsona__apsona_item__c> defaultConsoleViewLayouts;
    @WebService
    webService String defaultCurrency;
    @WebService
    webService List<apsona__apsona_item__c> defaultTabularViewLayouts;
    @WebService
    webService String errorMessage;
    @WebService
    webService Boolean hasApsonaLicense;
    @WebService
    webService Boolean hasMsrLicense;
    @WebService
    webService Boolean isAdmin;
    @WebService
    webService String locale;
    @WebService
    webService String metadataInJSON;
    @WebService
    webService Id profileId;
    @WebService
    webService Id userId;
    @WebService
    webService List<apsona__apsona_item__c> userPrefs;
    @WebService
    webService List<apsona__apsona_item__c> usersConsoleViewLayouts;
    global UserData() {

    }
}
}
