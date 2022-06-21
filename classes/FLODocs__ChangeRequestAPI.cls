/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/changeRequest/*')
global class ChangeRequestAPI {
    global ChangeRequestAPI() {

    }
    @HttpGet
    global static FLODocs.ChangeRequestAPI.TicketResponse getTicketData() {
        return null;
    }
    @HttpPost
    global static FLODocs.ChangeRequestAPI.TicketResponse pushChangeRequest() {
        return null;
    }
    @HttpPut
    global static String pushDragandDrop() {
        return null;
    }
global class ChangeRequestRecordType {
    global String id {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global ChangeRequestRecordType() {

    }
}
global class DragAndDropWrapper {
    global DragAndDropWrapper() {

    }
}
global class ExternalChangeLog {
    global String authorEmail;
    global String authorName;
    global String created;
    global String value;
    global ExternalChangeLog() {

    }
}
global class TicketData {
    global String affectedBundleId {
        get;
        set;
    }
    global String ApprovalStatus {
        get;
        set;
    }
    global String changeLevelReq {
        get;
        set;
    }
    global String changeRequestId {
        get;
        set;
    }
    global String completionStatus {
        get;
        set;
    }
    global String crURL {
        get;
        set;
    }
    global List<FLODocs.FloDRDUtils.JsonCustomization> existingCustomizations {
        get;
        set;
    }
    global List<FLODocs.DataRecordSearchAPI.DataRecordInfo> existingDataRecords {
        get;
        set;
    }
    global Boolean inactive {
        get;
        set;
    }
    global String policy {
        get;
        set;
    }
    global String proposedCustomizations {
        get;
        set;
    }
    global List<FLODocs.DataRecordSearchAPI.DataRecordInfo> proposedDataRecords {
        get;
        set;
    }
    global FLODocs.ChangeRequestAPI.ChangeRequestRecordType recordType {
        get;
        set;
    }
    global TicketData() {

    }
}
global class TicketError {
    global String message {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global TicketError() {

    }
}
global class TicketResponse {
    global FLODocs.ChangeRequestAPI.TicketData data {
        get;
        set;
    }
    global List<FLODocs.ChangeRequestAPI.TicketError> errors {
        get;
        set;
    }
    global Integer status {
        get;
        set;
    }
    global TicketResponse() {

    }
}
global class pushChangeRequestBody {
    global String affectedBundleId {
        get;
        set;
    }
    global String approvalStatus {
        get;
        set;
    }
    global String crRecordtype {
        get;
        set;
    }
    global String currentStatus {
        get;
        set;
    }
    global String currentUser {
        get;
        set;
    }
    global List<FLODocs.FloDRDUtils.JsonCustomization> existingCustomizations {
        get;
        set;
    }
    global List<FLODocs.DataRecordSearchAPI.DataRecordInfo> existingDataRecords {
        get;
        set;
    }
    global List<FLODocs.ChangeRequestAPI.ExternalChangeLog> externalChangeLog {
        get;
        set;
    }
    global String externalCreatedBy {
        get;
        set;
    }
    global String externalLink {
        get;
        set;
    }
    global String externalType {
        get;
        set;
    }
    global List<String> proposedCustomizations {
        get;
        set;
    }
    global List<FLODocs.DataRecordSearchAPI.DataRecordInfo> proposedDataRecords {
        get;
        set;
    }
    global String sourceType {
        get;
        set;
    }
    global String ticketCreatedDate {
        get;
        set;
    }
    global String ticketDescription {
        get;
        set;
    }
    global String ticketId {
        get;
        set;
    }
    global String ticketName {
        get;
        set;
    }
    global String ticketUpdatedDate {
        get;
        set;
    }
    global pushChangeRequestBody() {

    }
}
}
