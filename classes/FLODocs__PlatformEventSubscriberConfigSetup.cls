/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class PlatformEventSubscriberConfigSetup {
    global PlatformEventSubscriberConfigSetup() {

    }
    global static Boolean configExists(String triggerApiName) {
        return null;
    }
    global static String getCurrentRunningUser() {
        return null;
    }
    global static FLODocs.PlatformEventSubscriberConfigSetup.SaveResult setNewRunningUser(String username) {
        return null;
    }
global class Error {
    global List<String> fields;
    global String message;
    global String statusCode;
}
global class PlatformEventSubscriberConfigException extends Exception {
}
global class SaveResult {
    global List<FLODocs.PlatformEventSubscriberConfigSetup.Error> errors;
    global String id;
    global Boolean success;
}
}
