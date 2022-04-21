/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class OffPlatformQuery {
    global OffPlatformQuery() {

    }
global interface OPInterface {
    List<SObject> execute(geopointe.OffPlatformQuery.QueryRequest param0);
}
global class QueryParam {
    global Boolean isCollection;
    global Object value;
    global Schema.SoapType valueType;
    global QueryParam() {

    }
}
global class QueryRequest {
    global Map<String,geopointe.OffPlatformQuery.QueryParam> mergeVariables;
    global String query;
    global QueryRequest() {

    }
}
}
