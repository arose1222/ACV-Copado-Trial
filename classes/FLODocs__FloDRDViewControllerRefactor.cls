/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FloDRDViewControllerRefactor {
    @RemoteAction
    global static FLODocs.FloDRDViewControllerRefactor.JsonCustoContainer retrieveChildrenRecords(String parentId, Boolean doCategorize, Boolean doFilter) {
        return null;
    }
    @RemoteAction
    global static FLODocs.FloDRDViewControllerRefactor.JsonCustomization retrieveRecordInfo(String rId) {
        return null;
    }
    @RemoteAction
    global static FLODocs.FloDRDViewControllerRefactor.JsonCustoContainer searchRecords(String sName, String sAPIName) {
        return null;
    }
    @RemoteAction
    global static FLODocs.FloDRDViewControllerRefactor.JsonCustoContainer searchRecordsFromChangeRequest(String changeRequestId) {
        return null;
    }
    @RemoteAction
    global static FLODocs.FloDRDViewControllerRefactor.JsonCustoContainer searchRecordsFromProcessIssue(String processIssueId) {
        return null;
    }
global class JsonCustoContainer {
    global Map<String,List<FLODocs.FloDRDViewControllerRefactor.JsonCustomization>> categoryMap;
    global List<FLODocs.FloDRDViewControllerRefactor.JsonCustomization> uncategorizedChildren;
    global JsonCustoContainer() {

    }
}
global class JsonCustomization {
    global String dataType {
        get;
        set;
    }
    global String description {
        get;
        set;
    }
    global String internalId {
        get;
        set;
    }
    global String lastModified {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String ownerName {
        get;
        set;
    }
    global String salesforceType {
        get;
        set;
    }
    global String scriptId {
        get;
        set;
    }
    global JsonCustomization() {

    }
}
}
