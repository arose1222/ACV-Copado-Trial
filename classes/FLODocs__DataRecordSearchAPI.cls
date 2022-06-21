/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/dataRecordSearch/*')
global class DataRecordSearchAPI {
    global DataRecordSearchAPI() {

    }
    @HttpGet
    global static void handleGet() {

    }
global class DataRecordInfo {
    global Id dataRecordId {
        get;
        set;
    }
    global String dataRecordName {
        get;
        set;
    }
    global Boolean isSelected {
        get;
        set;
    }
    global String sobjectApiName {
        get;
        set;
    }
    global Id sobjectCustomizationId {
        get;
        set;
    }
    global String sobjectCustomizationName {
        get;
        set;
    }
    global DataRecordInfo() {

    }
}
}
