/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class FloDRDViewController {
    @RemoteAction
    global static List<FLODocs__FLO_Customization__c> getCustomObjectCustomizations() {
        return null;
    }
    @RemoteAction
    global static FLODocs.FloDRDViewController.JsonCustoContainer loadChildrenRecordsWithoutDuplicatesAndPersistError(String fId, Integer offSetN, List<String> custoIds, List<String> setScriptIds) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static FLODocs.FloDRDViewController.JsonCustoContainer loadChildrenRecordsWithoutDuplicates(String fId, Integer offSetN, List<String> custoIds, List<String> setScriptIds) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static FLODocs.FloDRDViewController.JsonCustoContainer loadChildrenRecords(String fId, Integer offSetN, List<String> custoIds) {
        return null;
    }
    @RemoteAction
    global static Map<Id,FLODocs__FLO_Junction__c> processInvertedSecondChildren(Set<String> floCustoIds, String CUSTO_TO_CUSTO_RT, Map<String,Map<String,List<FLODocs__FLO_Junction__c>>> custosMaping) {
        return null;
    }
    @RemoteAction
    global static Map<Id,FLODocs__FLO_Junction__c> processSecondChildren(Set<String> floCustoIds, String CUSTO_TO_CUSTO_RT, Map<String,Map<String,List<FLODocs__FLO_Junction__c>>> custosMaping) {
        return null;
    }
    @RemoteAction
    global static FLODocs__FLO_Customization__c retrieveRecordInfo(String fId) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<FLODocs.FloDRDViewController.JsonCustomization> retrieveRecordJsonInfo(List<String> floIds) {
        return null;
    }
global class JsonCustoContainer {
    global Boolean hasNext {
        get;
        set;
    }
    global List<FLODocs.FloDRDViewController.JsonCustomization> jsonCustos {
        get;
        set;
    }
    global String lastId {
        get;
        set;
    }
    global Integer offSetNumber {
        get;
        set;
    }
    global String parentId {
        get;
        set;
    }
    global List<String> scriptIds {
        get;
        set;
    }
    global JsonCustoContainer() {

    }
}
global class JsonCustomization {
    global String customlistfields {
        get;
        set;
    }
    global String custrecord_flo_cust_forms {
        get;
        set;
    }
    global String custrecord_flo_cust_id {
        get;
        set;
    }
    global String custrecord_flo_cust_type {
        get;
        set;
    }
    global String custrecord_flo_data_source {
        get;
        set;
    }
    global String custrecord_flo_data_type {
        get;
        set;
    }
    global String custrecord_flo_description {
        get;
        set;
    }
    global String custrecord_flo_dls {
        get;
        set;
    }
    global String custrecord_flo_external {
        get;
        set;
    }
    global String custrecord_flo_integrations {
        get;
        set;
    }
    global String custrecord_flo_list {
        get;
        set;
    }
    global String custrecord_flo_scripts {
        get;
        set;
    }
    global String custrecord_flo_searches {
        get;
        set;
    }
    global String formulatext {
        get;
        set;
    }
    global String integrationColor {
        get;
        set;
    }
    global String internalid {
        get;
        set;
    }
    global String list_custrecord_flo_cust_id {
        get;
        set;
    }
    global String list_custrecord_flo_extended {
        get;
        set;
    }
    global String list_custrecord_flo_int_id {
        get;
        set;
    }
    global String list_custrecord_flo_wflws {
        get;
        set;
    }
    global String list_internalid {
        get;
        set;
    }
    global String list_name {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global JsonCustomization() {

    }
}
}
