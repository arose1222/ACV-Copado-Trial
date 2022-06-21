/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/ServiceNowConnection/JsonCusto/*')
global class RestServiceNowConnectionSTPJsonCusto {
    @HttpGet
    global static List<FLODocs.RestServiceNowConnectionSTPJsonCusto.JsonCustoContainer> callServiceNowMessage() {
        return null;
    }
    @HttpPost
    global static List<FLODocs.RestServiceNowConnectionSTPJsonCusto.JsonCustomization> getRecordJsonInfo() {
        return null;
    }
    global static List<FLODocs.RestServiceNowConnectionSTPJsonCusto.JsonCustomization> retrieveRecordJsonInfo(List<String> floIds) {
        return null;
    }
global class JsonCustoContainer {
    global Boolean hasNext {
        get;
        set;
    }
    global List<FLODocs.RestServiceNowConnectionSTPJsonCusto.JsonCustomization> jsonCustos {
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
