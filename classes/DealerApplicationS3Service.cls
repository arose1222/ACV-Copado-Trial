//Basically a replica of S3 class with Delete functionality
public with sharing class DealerApplicationS3Service {
    private String ACCESS_KEY;
    private String SECRET_KEY;

    private final String ALGORITHM = 'AWS4-HMAC-SHA256';
    private final String SERVICE = 's3';
    private final String AWS_DOMAIN = 's3.amazonaws.com';
    private final String EXPIRES = '86400';
    private final String XML_NAME_SPACE = 'http://s3.amazonaws.com/doc/2006-03-01/';
    private final String DEFAULT_REGION = 'us-east-1';

    private String bucketName;
    private final String region;
    private String folderName;
    private String fileName;
    private String fileType;
    private String resource;
    private String requestBody;
    private String currentDate;
    private String isoTimeStamp;
    private String scope;
    private String urlParams;
    private String canonicalRequest;
    private Blob decodedContent;

    @TestVisible
    private static List<AWS_Credential__mdt> mockMetadata;

    /**
     * DealerApplicationS3Service   Constructor
     * @param  String bucketName    name of S3 bucket
     * @param  String region        region where s3 bucket is hosted
     */
    public DealerApplicationS3Service(String bucketName, String region) {
        this.region = region;
        this.bucketName = bucketName;

        this.initialize();
    }

    /**
     * DealerApplicationS3Service   Constructor
     * @param  String bucketName    name of S3 bucket
     */
    public DealerApplicationS3Service(String bucketName) {
        this.region = this.DEFAULT_REGION;
        this.bucketName = bucketName;

        this.initialize();
    }

    private class AWSException extends Exception{}

    private void initialize() {
        List<AWS_Credential__mdt> awsCreds = new List<AWS_Credential__mdt>();
        if (Test.isRunningTest() && mockMetadata != null) {
            awsCreds = mockMetadata;
        }
        else {
            awsCreds = [SELECT Access_Key__c, Secret_Key__c, Bucket_Name__c FROM AWS_Credential__mdt WHERE Bucket_Name__c = :this.bucketName];
        }
        if (awsCreds.size() == 1) {
            this.ACCESS_KEY = awsCreds[0].Access_Key__c;
            this.SECRET_KEY = awsCreds[0].Secret_Key__c;
        }
        else if (awsCreds.size() == 0) {
            throw new AWSException('Credentials for this bucket: ' + this.bucketName + ' do not exist.');
        }
        else if (awsCreds.size() > 1) {
            throw new AWSException('More than one credential has been configured for this bucket: ' + this.bucketName);
        }

        Datetime dt = Datetime.now();

        // Format date as (YYYYMMDD)
        this.currentDate = dt.formatGMT('yyyyMMdd');
        // Format date time as ISO 8601 String
        this.isoTimeStamp = dt.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        this.scope = this.getScope();
    }

    /**
     * getFileList                  returns a list of file names and their presigned urls stored within a specfic file path of the S3 bucket
     * @param  String folderPath    the directory path that you want to list contents for, ex. 'folder1/test', 'folder1', 'folder3/folder2/folder1'
     * @return return               Map<String, String>  file name with presigned url
     */
    public Map<String, String> getFileList(String folderPath) {
        this.resource = folderPath;
        this.urlParams = 'prefix=' + this.urlEncode(this.resource);
        this.requestBody = '';
        this.decodedContent = EncodingUtil.base64Decode(this.requestBody);

        String url = 'https://' + this.bucketName + '.' + this.AWS_DOMAIN + '/?' + this.urlParams;
        HttpRequest req = new HttpRequest();

        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('X-Amz-Content-SHA256', this.getXAmzContent());
		req.setHeader('X-Amz-Date', this.isoTimeStamp);
		req.setHeader('Authorization', this.getAuthHeader(this.getFileListCanonicalRequest()));

        Http http = new Http();
        HttpResponse resp = http.send(req);
        return this.parseXMLFileList(resp);
    }

    /**
     * parseXMLFileList             Parse XML and generate Map of filename with url on S3
     * @param  HttpResponse resp    response from S3
     * @return      return          Map of filename to url
     */
    private Map<String,String> parseXMLFileList( HttpResponse resp ) {
        Dom.Document doc = resp.getBodyDocument();
		Dom.XMLNode result = doc.getRootElement();

        Map<String, String> files = new Map<String, String>();
		for (Dom.XMLNode node : result.getChildElements()) {
			if (node.getName() == 'Contents') {
				if (node.getChildElement('Size', this.XML_NAME_SPACE).getText() != '0') {
					String fileName = node.getChildElement('Key', this.XML_NAME_SPACE).getText();
					files.put(fileName, this.generatePreSignedFileUrl(fileName));
				}
			}
		}
        return files;
    }

    /**
     * generatePreSignedFileUrl     generate pre-signed URL for specific resource
     * @param  String resource      file/object to generate pre-signed URL for,
     *                              ex 1000/test/test.txt, /2020/woot/swoot.txt
     * @return          return  presigned url string for resource
     */
    public String generatePreSignedFileUrl( String resource ) {
        if (resource.charAt(0) == '/'.charAt(0)) {
            this.resource = resource.substring(1, resource.length());
        } else {
            this.resource = resource;
        }

        String url = 'https://' + this.bucketName + '.' + this.AWS_DOMAIN + '/' + this.urlEncode(this.resource);
        List<String> filePath = this.resource.split('/');
		this.folderName = '';
        for ( Integer i = 0; i < filePath.size()-1; i++ ) {
            this.folderName += filePath[i] + '/';
        }
        this.fileName = filePath[filePath.size()-1];
		this.urlParams = this.getPreSignedParams();
        this.canonicalRequest = this.getFileCanonicalRequest();

		return url + '?' +  this.urlParams + '&X-Amz-Signature=' + this.getSignature(); //added a this. in front of urlParams
    }

    /**
     * getPreSignedParams   genereate params for presigned url
     * @return   return description
     */
    private String getPreSignedParams() {
        return 'X-Amz-Algorithm=' + this.urlEncode(this.ALGORITHM) +
               '&X-Amz-Credential=' + this.urlEncode(this.ACCESS_KEY + '/' + this.scope) +
               '&X-Amz-Date=' + this.urlEncode(this.isoTimeStamp) +
               '&X-Amz-Expires=' + this.urlEncode(this.EXPIRES) + '&X-Amz-SignedHeaders=host';
    }

    /**
     * getFileCanonicalRequest      create canonical request to be encrypted for presigned url signature
     * @return      String          Canonical Request body
     */
    private String getFileCanonicalRequest() {
		String req = 'GET\n' +
				'/'+ this.urlEncode(this.folderName).replace('%2F','/') + this.urlEncode(this.fileName).replace('%2F','/') + '\n' +
				this.urlParams + '\n' +
				'host:' +this.bucketName+'.s3.amazonaws.com' + '\n\n' +
				'host\n' +
				'UNSIGNED-PAYLOAD';
		return req;
    }

    public Integer createFile(String folderName, String fileName, String fileType, Blob requestBody) {
		this.folderName = folderName;
		this.fileName = fileName;
        this.fileType = fileType;
        //this.requestBody = requestBody;
        this.decodedContent = requestBody;

		HttpResponse resp = this.putFile();
        
        return resp.getStatusCode();
	}

	private HttpResponse putFile() {
		Http http = new Http();
		HttpRequest req = this.getPutRequest();
        
        HttpResponse resp = http.send(req);
        
        Integer statusCode = resp.getStatusCode();
        String logLevel = '';
        String compName = 'S3 Class - File Upload';
        if (statusCode == 200) {
            logLevel = 'INFO';
        }
        else {
            logLevel = 'ERROR';
        }
        getSplunkLog(logLevel); //, compName, req, resp

		return resp;
	}

	private HttpRequest getPutRequest() {
		String url = 'https://' + this.bucketName + '.s3.amazonaws.com/' + urlEncode(this.folderName) + '/' + urlEncode(this.fileName);

		HttpRequest req = new HttpRequest();

        //this.decodedContent = EncodingUtil.base64Decode(this.requestBody);

        req.setEndpoint(url);
		req.setMethod('PUT');
		req.setHeader('X-Amz-Content-SHA256', this.getXAmzContent());
		req.setHeader('X-Amz-Date', this.isoTimeStamp);
        req.setHeader('Authorization', this.getAuthHeader(this.getPutCanonicalRequest()));
        req.setHeader('Content-Encoding', 'BASE64'); //added this
		req.setHeader('Content-Type', this.fileType);
        req.setHeader('Content-Length', String.valueOf(this.decodedContent.size())); //may as well keep this how it is


        req.setBodyAsBlob(this.decodedContent);


		return req;
	}

	private String getDeleteCanonicalRequest() {
		String canonicalRequest = 'DELETE\n' +
            '/' + urlEncode(this.folderName).replace('%2F', '/') + '/' + this.urlEncode(this.fileName) + '\n' + 
            '' + '\n' +
            'host:'+ this.bucketName + '.s3.amazonaws.com' + '\n' +
            'x-amz-content-sha256:' + this.getXAmzContent() + '\n' +
            'x-amz-date:' + this.isoTimeStamp + '\n\n' +
            'host;x-amz-content-sha256;x-amz-date\n' +
            this.getXAmzContent();
		return canonicalRequest;
	}
    
    public Integer deleteFile(String fileName, String originalUrl) {
        this.fileName = fileName;
        List<String> test = originalUrl.replace('%2F', '/').split('/');
        String path = '';
        for (Integer i = 3; i< test.size()-1; i++) {
            path += test[i];
            if (i < test.size()-2) {
                path += '/';
            }
        }
        this.folderName = path;
        this.requestBody = '';
        this.decodedContent = EncodingUtil.base64Decode(this.requestBody);

        String url = 'https://' + this.bucketName + '.s3.amazonaws.com/' + urlEncode(this.folderName).replace('%2F', '/') + '/' + urlEncode(this.fileName);
        HttpRequest req = new HttpRequest();

        req.setEndpoint(url);
        req.setMethod('DELETE');
        req.setHeader('X-Amz-Content-SHA256', this.getXAmzContent());
		req.setHeader('X-Amz-Date', this.isoTimeStamp);
		req.setHeader('Authorization', this.getAuthHeader(this.getDeleteCanonicalRequest()));
        Http http = new Http();
        HttpResponse resp = http.send(req);
        return resp.getStatusCode();
	}
    
    /**
	* Generate the canonical request needed for the PUT operation.
	*/
	private String getPutCanonicalRequest() {
		String req = 'PUT\n' +
				'/' + urlEncode(this.folderName).replace('%2F', '/') + '/' + this.urlEncode(this.fileName).replace('%2F', '/') + '\n' + 
				'' + '\n' +
				'host:' + this.bucketName + '.s3.amazonaws.com' + '\n' +
				'x-amz-content-sha256:' + this.getXAmzContent() + '\n' +
				'x-amz-date:' + this.isoTimeStamp + '\n\n' +
				'host;x-amz-content-sha256;x-amz-date' + '\n' +
				this.getXAmzContent();
		return req;
	}

    /**
     * getAuthHeader        generate authorization header for HTTP Request
     * @return   String     Authorization Header
     */
    private String getAuthHeader(String canonicalRequest) {
        String authHeader = this.ALGORITHM + ' ';
        this.canonicalRequest = canonicalRequest;
		authHeader += 'Credential=' + this.ACCESS_KEY + '/' + this.scope + ', ';
		authHeader += 'SignedHeaders=host;x-amz-content-sha256;x-amz-date, ';
		authHeader += 'Signature=' + this.getSignature();
        return authHeader;
    }

    /**
     * getFileListCanonicalRequest  Canonical Request for S3 listObjects request
     * @return   String             Canonical Request
     */
    private String getFileListCanonicalRequest() {
		String canonicalRequest = 'GET\n' +
            '/'+'\n' +
            'prefix='+urlEncode(this.resource)+ '\n' + 
            'host:'+ this.bucketName + '.s3.amazonaws.com' + '\n' +
            'x-amz-content-sha256:' + this.getXAmzContent() + '\n' +
            'x-amz-date:' + this.isoTimeStamp + '\n\n' +
            'host;x-amz-content-sha256;x-amz-date\n' +
            this.getXAmzContent();
		return canonicalRequest;
	}

    /**
     * urlEncode            UTF-8 encode String value to work with AWS HTTP Request
     * @param  String url   string to encode
     * @return              encoded string
     */
    private String urlEncode(String url) {
        return EncodingUtil.urlEncode(url, 'UTF-8').replace('%2B','+').replace('+','%20');
	}

    /**
     * getScope     generate string for auth header scope
     * @return      String of {(YYYYMMDD)}/{region}/{SERVICE}/aws4_request
     */
    private String getScope() {
        return this.currentDate + '/' + this.region + '/' + this.SERVICE + '/aws4_request';
    }

    /**
     * getXAmzContent   generate the X-Amz-Content-SHA256 based on requestBody value of instatiated class
     * @return          Blob value of encoded requestBody
     */
    private String getXAmzContent() {
        //this.base64content = EncodingUtil.base64Decode(EncodingUtil.urlDecode(this.requestBody, 'UTF-8'));
        return EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', this.decodedContent)); //Blob.valueOf(this.requestBody)
    }

    /**
     * getSignature     Genereate signature for S3 request
     * @return          Hex16 string of encrypted signature
     */
	private String getSignature() {
		return EncodingUtil.convertToHex(Crypto.generateMac( 'hmacSHA256', this.getStringToSign(), this.getSigningKey() ));
	}

    /**
     * getStringToSign  combination of the Algorithm, TimeStamp, Scopem and encrypted canonical request
     * @return   Blob   Binary value of StringToSign
     */
    private Blob getStringToSign() {
		String stringToSign = this.ALGORITHM + '\n' +
				this.isoTimeStamp + '\n' +
				this.scope + '\n' +
				EncodingUtil.convertToHex(Crypto.generateDigest('SHA-256', Blob.valueOf(this.canonicalRequest)));
		return Blob.valueOf(stringToSign);
	}

    /**
     * getSigningKey    generate Signing key using the HMAC-SHA256 encryption
     * @return   Blob   SigningKey for request
     */
    private Blob getSigningKey() {
		Blob dateKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.currentDate), Blob.valueOf('AWS4' +this.SECRET_KEY));
		Blob dateRegionKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.region), dateKey);
		Blob dateRegionServiceKey = Crypto.generateMac('hmacSHA256', Blob.valueOf(this.SERVICE), dateRegionKey);
		Blob signingKey = Crypto.generateMac('hmacSHA256', Blob.valueOf('aws4_request'), dateRegionServiceKey);
		return signingKey;
    }


    private class FieldValidationException extends Exception{}

    @TestVisible class S3LWCReturnObject{
        String url;
        String guid;
        String name;
        String associationId;
        String referenceId;
        @TestVisible Integer statusCode;
        String message;
    }



    @AuraEnabled
    public static string insertS3Objects(String s3Name, String s3Type, String s3Url, String junctionObjectType, String junctionObjectId){

        S3LWCReturnObject returnObj = new S3LWCReturnObject();
        Boolean referenceInserted = false;
        Id s3RefId;

        try{
            //run validation on fields
            if(String.isBlank(junctionObjectId)){
                throw new FieldValidationException('Junction Object ID cannot be blank');
            }

            //check for valid junctionObjectType
            Set<String> fieldNames = ACVUtility.getFieldList('S3_Association__c');
            if(!fieldNames.contains(junctionObjectType.toLowerCase())){
                String message = 'Junction Object Type field not found on S3_Association__c SObject.';
                throw new FieldValidationException(message);
            }

            //check for valid pickList
            
            List<String> picklistValues = ACVUtility.getPicklistValues('S3_Reference__c', 'Type__c', true).values();
            if(!picklistValues.contains(s3type)){
                String message = 'Value of parameter "type" not found as an option for field Type__c on SObject S3_Reference__c.';
                throw new FieldValidationException(message);
            }
            if(String.isBlank(s3Name)){
                throw new FieldValidationException('parameter s3Name cannot be blank');
            }
            if(String.isBlank(s3Url)){
                throw new FieldValidationException('parameter s3Url cannot be blank');
            }

            String guid = ACVUtility.NewGuid();
            String url = s3Url.substringBefore('?');

            S3_Reference__c reference = new S3_Reference__c();
            reference.Name = s3Name;
            reference.Type__c = s3Type;
            reference.External_Record_Guid__c = guid;
            reference.S3_URL__c = url;

            Database.SaveResult referenceResult = Database.insert(reference);
            if (referenceResult.isSuccess()) {
                makeLog(SplunkHelper.LOGLEVEL.INFO, 'Successfully inserted S3_Reference__c ' + referenceResult.id, 'S3_Reference__c', referenceResult.id);
                referenceInserted = true;
                s3RefId = reference.id;
            }
            else {
                String logMessage;
                for(Database.Error err : referenceResult.getErrors()) {
                    //err.getStatusCode(), err.getMessage(), err.getFields()
                    logMessage += 'Unable to insert S3_Reference__c. Status Code: ' + err.getStatusCode() + ' Message: ' +  err.getMessage() + ' Fields: ' + err.getFields();
                }
                makeLog(SplunkHelper.LOGLEVEL.ERROR, logMessage, 'S3_Reference__c', '');
                returnObj.statusCode = 500;
                returnObj.message = logMessage;
                return JSON.serialize(returnObj);
            }


            S3_Association__c association = new S3_Association__c();
            association.S3_Reference__c = reference.id;
            association.put(junctionObjectType, junctionObjectId);
            Database.SaveResult associationResult = Database.insert(association);

            if (associationResult.isSuccess()) {
                makeLog(SplunkHelper.LOGLEVEL.INFO, 'Successfully inserted S3_Association__c ' + associationResult.id, 'S3_Association__c', associationResult.id);
            }
            else {
                String logMessage;
                for(Database.Error err : associationResult.getErrors()) {
                    //err.getStatusCode(), err.getMessage(), err.getFields()
                    logMessage = 'Unable to insert S3_Reference__c. Status Code: ' + err.getStatusCode() + ' Message: ' +  err.getMessage() + ' Fields: ' + err.getFields() + '\n';
                }
                logMessage += 'Deleting related S3_Reference__c ' + reference.id + '.';
                makeLog(SplunkHelper.LOGLEVEL.ERROR, logMessage, 'S3_Association__c', '');
                Database.delete(reference.id);
                returnObj.statusCode = 500;
                returnObj.message = logMessage;
                return JSON.serialize(returnObj);
            }

            returnObj.referenceId = reference.id;
            returnObj.associationId = association.id;
            returnObj.name = s3Name;
            returnObj.guid = guid;
            returnObj.url = url;
            returnObj.statusCode = 200;
            returnObj.message = 'Records succesfully inserted.';
            return JSON.serialize(returnObj);
        }
        catch(FieldValidationException e){
            makeLog(SplunkHelper.LOGLEVEL.ERROR, e.getMessage(), 'S3_Reference__c', '');
            if(referenceInserted && s3RefId != null){
                Database.delete(s3RefId);
            }
            returnObj.statusCode = 400;
            returnObj.message = e.getMessage();
            return JSON.serialize(returnObj);
        }
        catch(Exception e){
            makeLog(SplunkHelper.LOGLEVEL.FATAL, e.getMessage(), 'S3_Reference__c', '');
            if(referenceInserted && s3RefId != null){
                Database.delete(s3RefId);
            }
            returnObj.statusCode = 500;
            returnObj.message = e.getMessage();
            return JSON.serialize(returnObj);
        }
    }



    public static void makeLog(SplunkHelper.LOGLEVEL level, string logMessage, string sfObj, string sfRecId){

        SplunkHelper.Log l = new SplunkHelper.Log();
        l.version = 'v1';
        l.logLevel = level;
        l.location = 'S3:' + ACVUtility.currentLineNumber();
        l.componentName = 's3FileUpload';
        l.message = logMessage;
        l.stackTrace = l.location;
        l.sfObject = sfObj;
        l.sfRecordId = sfRecId;
        l.domainSet = new Set<SplunkHelper.DOMAIN>();
        l.domainSet.add(SplunkHelper.DOMAIN.ENTERPRISE_APPS);

        SplunkHelper.buildAndProcessLog(l);
    }


    // public static void getSplunkLog(String logLevel, String compName, HttpRequest req, HttpResponse resp) {
    //     SplunkHelper.Log log = new SplunkHelper.Log();
    //     log.componentName = 'S3 Upload';
    //     log.sfObject = 'ContentDocument'; //leave for now
    //     log.domainSet = new Set<SplunkHelper.DOMAIN>();
    //     log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
    //     log.logLevel = logLevel == 'INFO' ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR;
    //     log.setContext(SplunkHelper.CONTEXT_TYPE.INTEGRATION);
    //     log.sfRecordId = UserInfo.getUserId(); //passing user id instead of docId
    //     log.stackTrace = 'S3: ' + ACVUtility.currentLineNumber();
    //     log.location = 'S3: ' + ACVUtility.currentLineNumber();
    //     log.message = logLevel == 'INFO' ? 'S3 upload successful.' : 'Error in uploading to S3, please investigate.';
    //     SplunkHelper.buildAndProcessIntegrationLog(log, req, resp);
    // }

    public static void getSplunkLog(String logLevel) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'S3 Upload';
        log.sfObject = 'Account -> Content Document';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
        log.logLevel = logLevel == 'INFO' ? SplunkHelper.LOGLEVEL.INFO : SplunkHelper.LOGLEVEL.ERROR;
        log.setContext(SplunkHelper.CONTEXT_TYPE.APEX_CODE);
        log.sfRecordId = UserInfo.getUserId();
        log.stackTrace = 'S3: ' + ACVUtility.currentLineNumber();
        log.location = 'S3: ' + ACVUtility.currentLineNumber();
        log.message = logLevel == 'INFO' ? 'S3 upload successful.' : 'Error in uploading to S3, please investigate.';
        SplunkHelper.buildAndProcessLog(log);
    }
}