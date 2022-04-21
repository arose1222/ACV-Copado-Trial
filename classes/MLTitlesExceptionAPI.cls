@RestResource(urlMapping='/MLTitlesException/*')
global class MLTitlesExceptionAPI {
    @HTTPPost
    global static void createException() {
        RestResponse response = RestContext.response;
        response.headers.put('Content-Type', 'application/json');
        try{

            final Id recordType = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get( 'ML_Titles' ).getRecordTypeId();
            Exception__c titlesException = new Exception__c(RecordTypeId = recordType);

            MLExceptionWrapper req = (MLExceptionWrapper) System.JSON.deserialize(RestContext.request.requestBody.toString(), MLExceptionWrapper.class);
            if(req.Clerk.Email != null && req.Clerk.Email != ''){
                List<User> titleScannedBy = [SELECT Id FROM User WHERE Email = :req.Clerk.Email];

                if ( titleScannedBy.isEmpty() ){
                    throw new NotFoundException('A matching user with email ' + req.Clerk.Email + ' was not found.');
                }
                titlesException.Title_Scanned_By__c = titleScannedBy[0].Id;
                titlesException.OwnerId = titleScannedBy[0].Id;
            } else {
                throw new NotFoundException('The Clerk Email must be defined');
            }
            titlesException.Status__c = 'Open';
            titlesException.Email_Subject__c = req.Email.Subject;
            titlesException.Scanner_Model_Name__c = req.Scanner.ModelName;
            titlesException.Images_Location__c = req.Email.ImagesLocation;
            titlesException.Batch_Id__c = req.Title.BatchId;
            insert titlesException;

            response.responseBody = Blob.valueOf(JSON.serialize(titlesException, true));
            response.statusCode = 200;
            insert createIntegrationResult( response, RestContext.request, 'Success' );
        } catch( NotFoundException e){
            response.statusCode = 400;
            APIError errs = new APIError( 'NOT_FOUND', e.getMessage() );
            response.responseBody = Blob.valueOf(JSON.serialize(errs));
            insert createIntegrationResult( response, RestContext.request, e.getMessage() );
        }catch( Exception e) {
            response.statusCode = 500;
            APIError errs = new APIError( 'INTERNAL_ERROR', e.getMessage() );
            response.responseBody = Blob.valueOf(JSON.serialize(errs));
            insert createIntegrationResult( response, RestContext.request, e.getMessage() );
        }
    }

    public class APIError {
        public String errorCode;
        public String message;
        public APIError(String errorCode, string message){
            this.errorCode = errorCode;
            this.message = message;
        }
    }

    public class NotFoundException extends Exception{}

    public static Integration_Result__c createIntegrationResult( RestResponse response, RestRequest request, String message ) {
        return new Integration_Result__c(
            Integration_Name__c = 'ML Excpetion API',
            Integration_Type__c = 'Inbound',
            Request_Message__c = request.requestBody.toString(),
            Response_Message__c = response.responseBody.toString(),
            SObject_Name__c = 'Exception__c',
            Status_Code__c = response.statusCode,
            Endpoint_URL__c = '/services/apexrest/MLTitlesException',
            Status_Message__c = message.length() >= 255 ? message.subString( 0, 254 ) : message
        );
    }
}