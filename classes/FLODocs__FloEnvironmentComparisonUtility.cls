/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FloEnvironmentComparisonUtility {
    global FloEnvironmentComparisonUtility() {

    }
global class ComparisonContainer {
    global List<FLODocs.FloEnvironmentComparisonUtility.DifferenceWrapper> inBothDifferent;
    global List<FLODocs.FloEnvironmentComparisonUtility.DifferenceWrapper> inBothSame;
    global List<FLODocs.FloEnvironmentComparisonUtility.SingleWrapper> inBothTheSame;
    global List<FLODocs.FloEnvironmentComparisonUtility.SingleWrapper> onlyInSource;
    global List<FLODocs.FloEnvironmentComparisonUtility.SingleWrapper> onlyInTarget;
    global ComparisonContainer() {

    }
}
global class DifferenceWrapper {
    global String sourceObjectApiName {
        get;
        set;
    }
    global String sourceObjectId {
        get;
        set;
    }
    global Date sourceObjectLastModifiedDate {
        get;
        set;
    }
    global Date sourceObjectLastUsedDate {
        get;
        set;
    }
    global String sourceObjectName {
        get;
        set;
    }
    global String sourceObjectType {
        get;
        set;
    }
    global String sourceXml {
        get;
        set;
    }
    global String targetObjectApiName {
        get;
        set;
    }
    global String targetObjectId {
        get;
        set;
    }
    global Date targetObjectLastModifiedDate {
        get;
        set;
    }
    global Date targetObjectLastUsedDate {
        get;
        set;
    }
    global String targetObjectName {
        get;
        set;
    }
    global String targetObjectType {
        get;
        set;
    }
    global String targetXml {
        get;
        set;
    }
    global DifferenceWrapper() {

    }
}
global class DifferencesWrapper {
    global String source;
    global String target;
    global DifferencesWrapper() {

    }
}
global class SingleWrapper {
    global String objectApiName {
        get;
        set;
    }
    global String objectId {
        get;
        set;
    }
    global Boolean objectIsActive {
        get;
        set;
    }
    global Date objectLastModifiedDate {
        get;
        set;
    }
    global Date objectLastUsedDate {
        get;
        set;
    }
    global String objectName {
        get;
        set;
    }
    global String objectType {
        get;
        set;
    }
    global String xml {
        get;
        set;
    }
    global SingleWrapper() {

    }
}
}
