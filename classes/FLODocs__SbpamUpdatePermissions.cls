/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/SbPAM/updatePermissions/*')
global class SbpamUpdatePermissions {
    global SbpamUpdatePermissions() {

    }
    @HttpPost
    global static List<FLODocs.SbpamUpdatePermissions.ErrorMessage> handlePost(String username, String operation, String entityType, String entityName) {
        return null;
    }
global class ErrorMessage {
    global String errorCode;
    global String message;
}
}
