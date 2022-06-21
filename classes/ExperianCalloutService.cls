public class ExperianCalloutService {
    
    /**
     * Future callout to get experian data from Business API and create a SF Object with that information.
     * @param account_id - String - Account ID 
     * @return void
     */
    @future(callout=true)
    public static void makeCallout(String account_id) {
        
        List <Account> accounts = [SELECT Id, Name, BillingPostalCode, BillingState, BillingStreet, 
                                   Tax_ID__c, Phone, BillingCity FROM Account WHERE Id = :account_id];

        if (accounts.isEmpty() == false){
        
            try{
                ExperianAuthenticateUser auth_credentials = login();
                String bin_code = getBinAccount(accounts[0], auth_credentials);
                if (bin_code != null){
                    ExperianBusinessFactsResponse business_facts = getBusinessFacts(bin_code , auth_credentials);
                    ExperianLegalFilingsResponse legal_filings = getLegalFilings(bin_code, auth_credentials);
                    ExperianCreditStatusResponse credit_status = getCreditStatus(bin_code, auth_credentials);
                    ExperianScoreResponse business_score = getBusinessScore(bin_code, auth_credentials);
                    createExperianBussinessInformationRecord(accounts[0], business_facts , legal_filings, credit_status, business_score);
                    //Success Log
                    if(!Test.isRunningTest()) {
                        SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.INFO, 'Account trigger for ID: '+accounts[0].Id+' succesfully executed!', '-', ACVUtility.currentLineNumber()));
                    }
                }
                
            }catch(Exception e){
                Account acc = accounts[0];
                acc.FastPass_Approval__c = 'Error';
                String message = 'Account: '+String.valueOf(acc.Id)+' Error:'+e.getMessage();
                //Failure Log
                if(!Test.isRunningTest()) {
                	SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, message, e.getStackTraceString(), ACVUtility.currentLineNumber()));
                }
                update acc;
            }
        }    
        
    }
    
    /**
     * Get custom metadata type for obtain Experian Base URL and others custom fields.
     * @return Fast_Pass_Experian_Credential__mdt
     */
    public static Fast_Pass_Experian_Credential__mdt getExperianCustomMDT(){
        Fast_Pass_Experian_Credential__mdt experian_data = Fast_Pass_Experian_Credential__mdt.getInstance('auth_credentials');
        return experian_data;
    }
    
    /**
     * Soon to be deprecated, using named credentials on auth provider (Open ID connect protocol)
     * Authenticates in Experian REST API 
     * @return ExperianAuthenticateUser - Auth Credentials with JWT Token
     */
	public static ExperianAuthenticateUser login(){
        System.debug('Experian Authentication');
        Fast_Pass_Experian_Credential__mdt experian_auth_credentials = getExperianCustomMDT();
        HttpRequest request = new HttpRequest();
        
        String endpoint = experian_auth_credentials.auth_url__c;
        JSONGenerator gen = JSON.createGenerator(true);    
		
		gen.writeStartObject();      
		gen.writeStringField('username', experian_auth_credentials.username__c);
		gen.writeStringField('password', experian_auth_credentials.password__c);
		gen.writeStringField('client_id', experian_auth_credentials.client_id__c);
		gen.writeStringField('client_secret', experian_auth_credentials.client_secret__c);
		gen.writeEndObject();    
	 
		String jsonS = gen.getAsString();
		request.setBody(jsonS);
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Grant_type', 'password');
        
        HttpResponse response = new HTTP().send(request);
        if (response.getStatusCode() != 200){
            throw new ExperianCalloutServiceException('Could not get auth token from Experian.');
        }
        
        ExperianAuthenticateUser auth_credentials = (ExperianAuthenticateUser)JSON.deserializeStrict(response.getBody(), ExperianAuthenticateUser.class);
        return auth_credentials;
    }
    
    /**
     * Get Experian Account Identifier (BIN Code) from Experian Search Endpoint 
     * @param account - Account Object 
     * @param auth_credential - ExperianAuthenticateUser Auth Credentials with JWT Token
     * @return String bin code
     */
    public static String getBinAccount(Account account , ExperianAuthenticateUser auth_credentials){
        
        Fast_Pass_Experian_Credential__mdt experian_data = getExperianCustomMDT();
        String endpoint = experian_data.base_url__c+'/businessinformation/businesses/v1/search';
        
        JSONGenerator search_request = JSON.createGenerator(true);    
		search_request.writeStartObject();      
		search_request.writeStringField('name', account.Name);
		search_request.writeStringField('city', account.BillingCity);
		search_request.writeStringField('state',account.BillingState);
		search_request.writeStringField('subcode',experian_data.subcode__c);
		search_request.writeStringField('street',(String)account.BillingStreet);
  		search_request.writeStringField('zip', account.BillingPostalCode);
		search_request.writeStringField('phone', (String)account.Phone);
        if(account.Tax_ID__c != null){
			String taxId = account.Tax_ID__c.replaceAll('[^0-9]', '');
            if (taxId.length() == 9) {
                search_request.writeStringField('taxId', taxId);   
            }     
        }
		search_request.writeBooleanField('geo',true);
		search_request.writeStringField('comments','Search-EXP');
		search_request.writeEndObject();   
        String json_search_request = search_request.getAsString();
        
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ auth_credentials.access_token);
        request.setBody(json_search_request);
        HttpResponse search_response = new HTTP().send(request);
        
        System.debug('Response '+ search_response.getBody());
        if (search_response.getStatusCode() == 200){
            ExperianBusinessSearchResponse experian_search_response = (ExperianBusinessSearchResponse)JSON.deserializeStrict(search_response.getBody(), ExperianBusinessSearchResponse.class);
            if (experian_search_response.results.isEmpty() == false){
                String bin_code = experian_search_response.results.get(0).bin;
                return bin_code;
            }    
        }
 	    
        throw new ExperianCalloutServiceException('getBinAccount from Experian is failing: Reason: ' + search_response.getBody());
    }
    
    /**
     * Get Experian Business Facts Response 
     * @param bin - String -BIN Code related to the SF Account 
     * @param auth_credential - ExperianAuthenticateUser Auth Credentials with JWT Token
     * @return ExperianBusinessFactsResponse 
     */
    public static ExperianBusinessFactsResponse getBusinessFacts(String bin,  ExperianAuthenticateUser auth_credentials){
        System.debug('getBusinessFacts in Experian');
        
        Fast_Pass_Experian_Credential__mdt experian_data = getExperianCustomMDT();
        String endpoint = experian_data.base_url__c+'/businessinformation/businesses/v1/facts';
       
        System.debug('User token'+ auth_credentials.access_token);
        JSONGenerator facts_request = JSON.createGenerator(true);    
		
		facts_request.writeStartObject();      
		facts_request.writeStringField('bin',bin);
		facts_request.writeStringField('subcode',experian_data.subcode__c);
		facts_request.writeEndObject();   
        String json_facts_request = facts_request.getAsString();
        HttpRequest request = new HttpRequest();
        // Set the endpoint URL.
        request.setEndPoint(endpoint);
        // Set the HTTP verb to POST.
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ auth_credentials.access_token);
        request.setBody(json_facts_request);
        HttpResponse response = new HTTP().send(request);
        System.debug('Response '+ response.getBody());
        
        if (response.getStatusCode() == 200){
        	ExperianBusinessFactsResponse experian_response = (ExperianBusinessFactsResponse)JSON.deserializeStrict(response.getBody(), ExperianBusinessFactsResponse.class);
        	return experian_response;   
        }
        throw new ExperianCalloutServiceException('getBusinessFacts from Experian is failing: Reason: ' + response.getBody());
        
    }
    
    /**
     * Get Experian Legal Filings Response 
     * @param bin - String -BIN Code related to the SF Account 
     * @param auth_credential - ExperianAuthenticateUser Auth Credentials with JWT Token
     * @return ExperianLegalFilingsResponse 
     */
    public static ExperianLegalFilingsResponse getLegalFilings(String bin, ExperianAuthenticateUser auth_credentials){
        Fast_Pass_Experian_Credential__mdt experian_data = getExperianCustomMDT();
        String endpoint = experian_data.base_url__c+'/businessinformation/businesses/v1/legalcollectionsummaries';
        System.debug('User token'+ auth_credentials.access_token);
        JSONGenerator legal_filings_request = JSON.createGenerator(true);    
		legal_filings_request.writeStartObject();      
		legal_filings_request.writeStringField('bin',bin);
		legal_filings_request.writeStringField('subcode',experian_data.subcode__c);
        legal_filings_request.writeBooleanField('legalFilingsCollectionsSummary',true);
        legal_filings_request.writeBooleanField('legalFilingsSummary',true);
		legal_filings_request.writeEndObject();   
        String json_request = legal_filings_request.getAsString();
        System.debug('Request LegalFilings'+ json_request);
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+ auth_credentials.access_token);
        request.setBody(json_request);
        HttpResponse response = new HTTP().send(request);        
        System.debug('Response LegalFilings'+ response.getBody());
        
        if (response.getStatusCode() == 200){
        	ExperianLegalFilingsResponse experian_response = (ExperianLegalFilingsResponse)JSON.deserializeStrict(response.getBody(), ExperianLegalFilingsResponse.class);
        	return experian_response; 
        }
        throw new ExperianCalloutServiceException('getLegalFilings from Experian is failing. Reason: ' + response.getBody());
  	    
    }
	
    /**
     * Get Experian Credit Status Response 
     * @param bin - String -BIN Code related to the SF Account 
     * @param auth_credential - ExperianAuthenticateUser Auth Credentials with JWT Token
     * @return ExperianCreditStatusResponse 
     */
	public static ExperianCreditStatusResponse getCreditStatus(String bin, ExperianAuthenticateUser auth_credentials){
        Fast_Pass_Experian_Credential__mdt experian_data = getExperianCustomMDT();
        String endpoint = experian_data.base_url__c+'/businessinformation/businesses/v1/creditstatus';
        System.debug('User token'+ auth_credentials.access_token);
        JSONGenerator credit_status_request = JSON.createGenerator(true);    
		credit_status_request.writeStartObject();      
		credit_status_request.writeStringField('bin',bin);
		credit_status_request.writeStringField('subcode',experian_data.subcode__c);
        credit_status_request.writeEndObject();
        String json_request = credit_status_request.getAsString();
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+auth_credentials.access_token);
        request.setBody(json_request);
        HttpResponse response = new HTTP().send(request);

        
        System.debug('Response ExperianCreditStatusResponse' + response.getBody());
        
        if (response.getStatusCode() == 200){
        	ExperianCreditStatusResponse experian_response = (ExperianCreditStatusResponse)JSON.deserializeStrict(
            	response.getBody(), 
            	ExperianCreditStatusResponse.class
       	 	);
        	return experian_response;
        
        }
        throw new ExperianCalloutServiceException('getCreditStatus from Experian is failing. Reason: ' + response.getBody());
  	   
    }
    
    /**
     * Get Experian Credit Score Response 
     * @param bin - String -BIN Code related to the SF Account 
     * @param auth_credential - ExperianAuthenticateUser Auth Credentials with JWT Token
     * @return ExperianScoreResponse 
     */
    public static ExperianScoreResponse getBusinessScore(String bin, ExperianAuthenticateUser auth_credentials){
        Fast_Pass_Experian_Credential__mdt experian_data = getExperianCustomMDT();
        String endpoint = experian_data.base_url__c+'/businessinformation/businesses/v1/scores';
        System.debug('User token'+ auth_credentials.access_token);
        JSONGenerator business_score_request = JSON.createGenerator(true);    
		business_score_request.writeStartObject();      
		business_score_request.writeStringField('bin',bin);
		business_score_request.writeStringField('subcode',experian_data.subcode__c);
        business_score_request.writeStringField('modelCode','000224');
        business_score_request.writeBooleanField('fsrScore',true);
        business_score_request.writeBooleanField('commercialScore',true);
		business_score_request.writeEndObject();
        
        String json_request = business_score_request.getAsString();
        System.debug('Request Score'+ json_request);
        
        HttpRequest request = new HttpRequest();
        request.setEndPoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+auth_credentials.access_token);
        request.setBody(json_request);
        HttpResponse response = new HTTP().send(request);

        System.debug('Response ExperianScoreResponse'+ response.getBody());
        
        if (response.getStatusCode() == 200){
        	ExperianScoreResponse experian_response = (ExperianScoreResponse)JSON.deserializeStrict(
            	response.getBody(), 
            	ExperianScoreResponse.class
       	 	);
        	return experian_response;
        
        }
        throw new ExperianCalloutServiceException('getBusinessScore from Experian is failing. Reason: ' + response.getBody());
 	    
    }
    
    /**
     * Creates Experian Business Information Record in Salesforce  
     * @param account - Account
     * @param business_facts ExperianBusinessFactsResponse  
     * @param legal_filings ExperianLegalFilingsResponse 
     * @param credit_status ExperianCreditStatusResponse 
     * @param business_score ExperianScoreResponse  
     * @return void 
     */
    public static void createExperianBussinessInformationRecord(
        Account account,
        ExperianBusinessFactsResponse business_facts, 
        ExperianLegalFilingsResponse legal_filings,
        ExperianCreditStatusResponse credit_status,
        ExperianScoreResponse business_score
    ){
        SavePoint dbSave = Database.setSavePoint();
        try {
            EXPRN__Exp_Business_Info__c exp_business_info = new EXPRN__Exp_Business_Info__c();
            exp_business_info.EXPRN__Account_Name__c = account.id;
            // Business Facts Fields 
            exp_business_info.Business_Facts_Success__c =  String.valueOf(business_facts.success);
            
            if (business_facts.results.businessHeader!=null){
               
                exp_business_info.Name = business_facts.results.businessHeader.businessName;
				exp_business_info.EXPRN__Exp_Tax_ID__c = business_facts.results.businessHeader.taxId;
            	exp_business_info.EXPRN__Exp_Business_Name__c = business_facts.results.businessHeader.legalBusinessName;
            	exp_business_info.EXPRN__Experian_Website__c = business_facts.results.businessHeader.websiteUrl;
            	exp_business_info.Foreign_Country__c = String.valueOf(business_facts.results.businessHeader.foreignCountry);
            	exp_business_info.Corporate_Linkage_Indicator__c = String.valueOf(business_facts.results.businessHeader.corporateLinkageIndicator);
            
            	if (business_facts.results.businessHeader.matchingBranchAddress != null){
                    exp_business_info.Branch_Street__c = business_facts.results.businessHeader.matchingBranchAddress.street;
                    exp_business_info.Branch_City__c = business_facts.results.businessHeader.matchingBranchAddress.city;
                    exp_business_info.Branch_State__c = business_facts.results.businessHeader.matchingBranchAddress.state;
                    exp_business_info.Branch_Zip__c = business_facts.results.businessHeader.matchingBranchAddress.zip;
                    exp_business_info.Branch_Zip_Extension__c = business_facts.results.businessHeader.matchingBranchAddress.zipExtension;
                }
            	if (business_facts.results.businessHeader.dbaNames != null){
     	       		String dbaNames = String.join(business_facts.results.businessHeader.dbaNames,',');
                    Integer maxLengh = 120;
                    if (dbaNames.length() > maxLengh) {
                        exp_business_info.EXPRN__DBA_Doing_Business_As__c = dbaNames.substring(0, maxLengh-10) + '...';
                    } else {
                        exp_business_info.EXPRN__DBA_Doing_Business_As__c = dbaNames;
                    }
            		
            	}
     
            }
           
            
            if (business_facts.results.sicCodes != null){
    	        exp_business_info.EXPRN__SIC_Code__c = business_facts.results.sicCodes[0].code;
            }
            
            if (business_facts.results.naicsCodes != null){
    	        exp_business_info.EXPRN__NAICS_Code__c = business_facts.results.naicsCodes[0].code;
                exp_business_info.NAICS_Description__c = business_facts.results.naicsCodes[0].definition;
            }
            
            
            // Business Score
            exp_business_info.Score_Success__c = String.valueOf(business_score.success);
            exp_business_info.Score_Comments__c = business_score.comments;
            if (business_score.results.fsrScore != null){
    	        exp_business_info.fsrScore_Model_Code__c = business_score.results.fsrScore.modelCode;
	            exp_business_info.fsrScore_Model_Title__c = business_score.results.fsrScore.modelTitle;
        	    exp_business_info.fsrScore_Score__c	  =  business_score.results.fsrScore.score;    
    	       	exp_business_info.Percentile_Ranking__c = business_score.results.fsrScore.percentileRanking;
 	           	exp_business_info.fsrScore_Recommended_Credit_Limit_Amount__c = business_score.results.fsrScore.recommendedCreditLimitAmount;
                if (business_score.results.fsrScore.riskClass!= null){
 		       	    exp_business_info.Risk_Class_Definition__c = business_score.results.fsrScore.riskClass.definition;
                }
            }
            
            if (business_score.results.commercialScore != null){
	            exp_business_info.Score__c = business_score.results.commercialScore.score;
    	        exp_business_info.Commercial_Score__c  = business_score.results.commercialScore.score;        
            }
            
            if (business_score.results.commercialScoreFactors != null && business_score.results.commercialScoreFactors.isEmpty() == false){
                exp_business_info.Commercial_Score_Definition__c = business_score.results.commercialScoreFactors[0].definition;
            }
            
            if (business_score.results.fsrScoreFactors != null && business_score.results.fsrScoreFactors.isEmpty() == false){
                exp_business_info.fsrScoreFactors_Score_Factor_Definition__c = business_score.results.fsrScoreFactors[0].definition;
            }
            
            if (business_score.results.fsrScoreTrends != null && business_score.results.fsrScoreTrends.isEmpty() == false){
                exp_business_info.fsrScoreTrends_Score_Trends_Quarter__c = business_score.results.fsrScoreTrends[0].quarter;
                exp_business_info.fsrScoreTrends_Score_Trends_Score__c = String.valueOf(business_score.results.fsrScoreTrends[0].score);
            }
            
            if (business_score.results.collectionScore != null){
                exp_business_info.fsrScoreTrends_Collection_Score__c = String.valueOf(business_score.results.collectionScore.score);
            	exp_business_info.fsrScoreTrends_Model_Title__c = business_score.results.collectionScore.modelTitle;
            	exp_business_info.fsrScoreTrends_Score__c = business_score.results.collectionScore.score;
            	exp_business_info.fsrScoreTrends_Percentile_Ranking__c = business_score.results.collectionScore.percentileRanking;
            	exp_business_info.fsrScoreTrends_Risk_Class__c = business_score.results.collectionScore.riskClass.definition;
            }
  
            if (business_score.results.commercialScoreTrends != null && business_score.results.commercialScoreTrends.isEmpty() == false){
                exp_business_info.Commercial_Score_Quarter__c = business_score.results.commercialScoreTrends[0].quarter;
                exp_business_info.Commercial_Score__c = business_score.results.commercialScoreTrends[0].score;
            }
             
            // Business Legal Filings Mapping Fields
            exp_business_info.Legal_Filings_Success__c =  String.valueOf(legal_filings.success);
            if (legal_filings.results.legalFilingsCollectionsSummary != null){
                exp_business_info.Judgement_Count__c =  legal_filings.results.legalFilingsCollectionsSummary.judgmentCount;
                exp_business_info.Judgement_Balance__c = legal_filings.results.legalFilingsCollectionsSummary.judgmentBalance;
                exp_business_info.UCC_Filings_Count__c =  legal_filings.results.legalFilingsCollectionsSummary.uccFilingsCount;
                exp_business_info.UCC_Derogatory_Count__c = legal_filings.results.legalFilingsCollectionsSummary.uccDerogatoryCount;
                exp_business_info.EXPRN__All_Collections_Count__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.collectionCount);
                exp_business_info.Collection_Balance__c =  legal_filings.results.legalFilingsCollectionsSummary.collectionBalance;
                exp_business_info.EXPRN__Experian_Lien_Bal__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.lienBalance);
                exp_business_info.EXPRN__Original_Filings__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.derogatoryLegalCount);	
                exp_business_info.EXPRN__Experian_No_Judgments__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.judgmentCount);            
                exp_business_info.EXPRN__Experian_Judgment_Bal__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.judgmentBalance);
                exp_business_info.EXPRN__Bankruptcy__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.bankruptcyIndicator);            
                exp_business_info.EXPRN__Bankruptcy_Filings__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.bankruptcyCount);
                exp_business_info.EXPRN__Experian_No_Liens__c =  String.valueOf(legal_filings.results.legalFilingsCollectionsSummary.lienCount);   
            }
            if (credit_status != null){
            	exp_business_info.fsrScoreTrends_Credit_Status_Success__c = String.valueOf(credit_status.success);
            	exp_business_info.fsrScoreTrends_Credit_Status_Comments__c = credit_status.comments;
                
            }
            if (credit_status.results != null){
	            // Business Credit Status
    	        exp_business_info.EXPRN__Experian_No_Combined_Tradelines__c	 = String.valueOf(credit_status.results.combinedTradelineCount);
        	    exp_business_info.EXPRN__Combined_Trade_Balance__c = String.valueOf(credit_status.results.combinedAccountBalance);
            	exp_business_info.EXPRN__Current_DBT__c	 = String.valueOf(credit_status.results.currentDbt);
            	exp_business_info.EXPRN__Combined_Trade_Recent_High_Credit__c = String.valueOf(credit_status.results.combinedRecentHighCreditAmount);
            	exp_business_info.EXPRN__Years_on_File__c = String.valueOf(credit_status.results.yearsOnFile);
	            //exp_business_info.Inquiry_Count__c = credit_status.results.inquiryCount;
            }
  
            insert exp_business_info;
                       
        }
        catch (Exception e) {
            Database.rollback(dbSave);
            throw new ExperianCalloutServiceException('createExperianBussinessInformationRecord is failing. Reason: ' + e.getMessage());                
            
        }          
    }
    
    /**
     * Creates SplunkHelper Log
     * @param loglevel - ERROR, FATAL, INFO, DEBUG, WARN, or PERFORMANCE
     * @param message - error message
     * @param stackTrace - Full Detailed Stack Trace
     * @param lineNumber - Line Number that the error has happened on
     * @return SplunkHelper.log
     */
    public static SplunkHelper.Log createLog(SplunkHelper.LOGLEVEL loglevel, String message, String stackTrace, Integer lineNumber){
        SplunkHelper.Log log = new SplunkHelper.log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SALES};
        log.sfObject = 'Account';
        log.version = 'v1';
        log.componentName = 'FastPassExperianCalloutService';
        log.location = 'ExperianCalloutService Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
    
}