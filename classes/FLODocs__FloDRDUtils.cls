/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FloDRDUtils {
    global static FLODocs.FloDRDUtils.JsonCustoContainer retrieveChildrenRecords(String parentId, Boolean doCategorize, Boolean doFilter) {
        return null;
    }
    global static FLODocs.FloDRDUtils.JsonCustomization retrieveRecordInfo(String rId) {
        return null;
    }
    global static FLODocs.FloDRDUtils.JsonCustoContainer retrieveRecords(List<String> ids) {
        return null;
    }
global class JsonCustoContainer {
    global Map<String,List<FLODocs.FloDRDUtils.JsonCustomization>> categoryMap;
    global List<FLODocs.FloDRDUtils.JsonCustomization> uncategorizedChildren;
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
    global Boolean isSelected {
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
global class JsonJiraParameter {
    global String accountName {
        get;
        set;
    }
    global String cr_approved {
        get;
        set;
    }
    global String cr_complete {
        get;
        set;
    }
    global String cr_in_progress {
        get;
        set;
    }
    global String cr_pending_approval {
        get;
        set;
    }
    global Boolean isAutomaticSync {
        get;
        set;
    }
    global Integer strongpoint_License {
        get;
        set;
    }
    global String token {
        get;
        set;
    }
    global String userName {
        get;
        set;
    }
    global JsonJiraParameter() {

    }
}
}
