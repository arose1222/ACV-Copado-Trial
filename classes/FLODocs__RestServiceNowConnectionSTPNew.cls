/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/ServiceNowConnectionNew/*')
global class RestServiceNowConnectionSTPNew {
    @HttpPost
    global static FLODocs.RestServiceNowConnectionSTPNew.JsonChangeRequest createChangeRequest(String customizations, String incidentNumber, String num, String userID, String userName, String proposedCustomizations) {
        return null;
    }
    @HttpDelete
    global static void doDelete() {

    }
    @HttpGet
    global static List<FLODocs__FLO_Customization__c> getCustomizations() {
        return null;
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
