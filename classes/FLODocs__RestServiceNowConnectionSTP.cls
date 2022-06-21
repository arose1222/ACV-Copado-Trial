/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/ServiceNowConnection/*')
global class RestServiceNowConnectionSTP {
    @HttpPost
    global static String createChangeRequest(String customizations, String incidentNumber, String num, String userID, String userName, String proposedCustomizations) {
        return null;
    }
    @HttpGet
    global static FLODocs.RestServiceNowConnectionSTP.JsonChangeRequest createChangeRequestNew() {
        return null;
    }
    @HttpDelete
    global static void doDelete() {

    }
global class JsonChangeRequest {
    global String crAffectedBundleId {
        get;
        set;
    }
    global String crApprovalStatus {
        get;
        set;
    }
    global String crCustomizations {
        get;
        set;
    }
    global String crExternalLink {
        get;
        set;
    }
    global String crId {
        get;
        set;
    }
    global String crName {
        get;
        set;
    }
    global String crOverview {
        get;
        set;
    }
    global String crProposed {
        get;
        set;
    }
    global JsonChangeRequest() {

    }
}
}
