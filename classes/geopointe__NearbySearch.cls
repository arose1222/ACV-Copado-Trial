/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class NearbySearch {
    global NearbySearch() {

    }
    @InvocableMethod(label='Run a Nearby Search' description='Run a nearby search using Geopointe.')
    global static List<geopointe.NearbySearch.NearbySearchResponse> doSearch(List<geopointe.NearbySearch.NearbySearchRequest> reqs) {
        return null;
    }
global class NearbySearchRequest {
    @InvocableVariable(label='Geopointe Data Set Id' description='The Geopointe Data Set Id that will be used for the search. Found in Other tab of Data Set Edit. e.g. 15550154368710.5619135620413018' required=false)
    global String dataSetId;
    @InvocableVariable(label='Distance' description='The range for the nearby search.' required=true)
    global Decimal distance;
    @InvocableVariable(label='Distance Units' description='The range units, "miles" or "kilometers".' required=true)
    global String distanceUnits;
    @InvocableVariable(label='Geopointe Map Object Name' description='The Geopointe Map Object that will be used for the search. Data Set Id takes precedence if defined.' required=false)
    global String mapObjectName;
    @InvocableVariable(label='Record ID' description='The Salesforce record ID from where the nearby search will start.' required=false)
    global Id recordId;
    @InvocableVariable(label='Record Limit' description='The number of records passed to the next step of the Flow. If the search finds 100 records but this value is set to 5, the 5 nearest records will continue to the next step in the Flow.' required=false)
    global Integer recordLimit;
    @InvocableVariable(label='SOQL Filter' description='SOQL Filter added to the search. Data Set Filters takes precedence if defined.' required=false)
    global String soql;
    global NearbySearchRequest() {

    }
}
global class NearbySearchResponse {
    @InvocableVariable(label='Error' description='True/False boolean value indicating if an error occured with the search.' required=false)
    global Boolean error;
    @InvocableVariable(label='Error Message' description='Error message if the search failed.' required=false)
    global String errorMessage;
    @InvocableVariable(label='Records' description='The Records returned from the nearby search.' required=false)
    global List<geopointe.NearbySearchRecord> records;
    global NearbySearchResponse() {

    }
}
}
