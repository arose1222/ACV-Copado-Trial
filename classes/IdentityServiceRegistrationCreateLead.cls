/*
    This class is contains REST method to create lead & related EULA/TOS object.
*/
@RestResource(urlMapping='/IdentityService/Registration/createLead')
global class IdentityServiceRegistrationCreateLead {
    
    private static List<String> DealerTypeList = new List<String>{'Franchise', 'Wholesaler', 'Independent', 'Commercial'};
    private static List<String> LanguagePreferenceList = new List<String>{'English', 'Spanish'};
    global static String leadRTID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Organization_Lead').getRecordTypeId();

    // Create lead
    @HTTPPost
    global static void createLead(LeadCreateRequest newLead){
        ACVAPIHelper.SFResponse identityResult = new ACVAPIHelper.SFResponse(newLead, '', 200);
        identityResult.originalRequest = newLead;
        String endpointURL = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/services/identityservice/createlead';
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        
           
        //Lastname cannot be blank
        if(String.isBlank(newLead.LastName)){
            identityResult.message = 'LastName cannot be blank';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }

        //Username/Email cannot be blank
        if(String.isBlank(newLead.UserName)){
            identityResult.message = 'Username/Email cannot be blank';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }

        //Dealership legal name cannot be blank
        if(String.isBlank(newLead.CompanyName)){
            identityResult.message = 'Company name cannot be blank';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }
        
        //Checking for invalid phone number
        if(!String.isBlank(newLead.Phone) && !ACVUtility.isValidPhone(newLead.Phone)){
            identityResult.message = 'Invalid Phone Format';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }

        //Checking validity of the dealer type
        if(!DealerTypeList.contains(newLead.Dealer_Type)){
            identityResult.message = 'Invalid dealer type';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }

        // Address is not valid
        if(String.isBlank(newLead.Street) || String.isBlank(newLead.City) || String.isBlank(newLead.State) || String.isBlank(newLead.Zipcode)){
            identityResult.message = 'Address is not valid. Please check Street, City, State and Zipcode';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }

        // Mapping dealers interest SF fields
        Boolean interestedInBuying= false;
        Boolean interestedInSelling= false;
        Boolean smsOptIn= String.isBlank(newLead.SMSOptIn)? false : Boolean.valueOf(newLead.SMSOptIn);
        Boolean marketPlaceReportUser= String.isBlank(newLead.MarketPlaceReportUser)? false : Boolean.valueOf(newLead.MarketPlaceReportUser);
        Boolean isCreatedByBlitzTeam= !String.isBlank(newLead.ReferralCode) && (newLead.ReferralCode.toLowerCase()=='blitzteam');
        switch on newlead.DealersInterest {
            when 'sell' {
                interestedInSelling= true;
            }when 'purchase' {
                interestedInBuying= true;
            }when 'both' {
                interestedInSelling= true;
                interestedInBuying= true;
            }
        }

        //Checking validity of the dealer type
        if(!LanguagePreferenceList.contains(newLead.LanguagePreference)){
            identityResult.message = 'Invalid Language Preference';
            identityResult.statusCode = 409;
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
            identityResult.generateResponse(headerMap);
            return;
        }

        //Generate New Lead
        Lead leadRecord;
        Savepoint sp = Database.setSavepoint();
        try{
            String compondPhone = String.isBlank(newLead.phoneExt) || String.isBlank(newLead.Phone)  ? newLead.Phone : newLead.Phone+';'+newLead.phoneExt;
            String firstName= String.IsBlank(newLead.FirstName)? '' : newLead.FirstName.trim(); 
            String lastName= newLead.LastName.trim(); 
            String userName= String.isBlank(newLead.UserName)?'':newLead.UserName.trim(); 
            String cellPhone= (String.isBlank(newLead.CellPhone) || !ACVUtility.isValidPhone(newLead.CellPhone))? '' : newLead.CellPhone;
            
            String sanitizedLegalName= String.IsBlank(newLead.CompanyName)? '' : newLead.CompanyName.replaceAll('`','\'');
            String sanitizedDBAName= String.IsBlank(newLead.DealerShip_DBAName)? '' : newLead.DealerShip_DBAName.replaceAll('`','\'');
            leadRecord = new Lead( FirstName = firstName, LastName = lastName, 
            Email = userName, Phone = compondPhone, RecordTypeId = leadRTID, Company= sanitizedLegalName, LeadSource= 'Online Registration', 
            Street= newLead.Street, City= newLead.City, State= newLead.State, PostalCode= newLead.Zipcode, Country='US', Dealer_Type__c= newLead.Dealer_Type,
            Dealership_DBA_Name__c= sanitizedDBAName, Contact_Method_Preference__c= newlead.ContactPreference, Referral__c= newLead.ReferralType,
            Referral_Code__c = newLead.ReferralCode, SMS_Opt_In__c= smsOptIn, Website= newLead.Website, How_many_cars_do_you_stock__c= newLead.CarsInstock,
            Interested_in_Buying__c	= interestedInBuying, 	Interested_In_Selling__c= interestedInSelling, MobilePhone= cellPhone, 
            Language_Preference__c= newLead.LanguagePreference, Dont_Send_BDR_Email__c= isCreatedByBlitzTeam, utm_source__c= newLead.UtmSource, 
            utm_medium__c= newLead.UtmMedium, utm_campaign__c= newLead.UtmCampaign, GCLID__c= newLead.GoogleClickId, Market_Place_Report_User__c= marketPlaceReportUser); 

            // Apply lead assignment rules
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;
            leadRecord.setOptions(dmo);

            insert leadRecord;

            // Create EULA/TOS record
            Datetime dt = Datetime.valueOfGMT(newLead.EulaTosAcceptedDate);
            Eula_Tos__c eula= new Eula_Tos__C(Accepted_Date__c= dt, Eula_Id__c= newLead.EulaId, Lead__c= leadRecord.Id);
            insert eula;


            if(isCreatedByBlitzTeam==true || marketPlaceReportUser== true)
            {
                LeadConversion.AddressWrapper aw= LeadConversion.getLeadAddress(leadRecord.Id);
                LeadConversion.ReturnWrapper rw= LeadConversion.updateAddAndConvertLead(leadRecord.Id, aw); 
                if(rw.hasError)
                {
                    Database.rollback(sp);
                    identityResult.message = 'Lead Auto Conversion Failed. ' + rw.message;
                    identityResult.statusCode = 409;
                    IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.ERROR, 400);
                    identityResult.generateResponse(headerMap);
                    return;

                }               
            }

        }

        catch(Exception e){
            identityResult.message = 'Error Generating Lead';
            identityResult.statusCode = 500;
            if(e.getMessage().contains('DUPLICATES_DETECTED'))
                { 
                    identityResult.message = 'Duplicate lead found';
                    identityResult.statusCode = 409;
                }
            IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', e.getStackTraceString()+':'+e.getMessage(), SplunkHelper.LOGLEVEL.FATAL, 500);
            identityResult.generateResponse(headerMap);
            
            return;
        }

        LeadCreateResponse lcr = new LeadCreateResponse();
        lcr.Lead_Id = leadRecord.Id;
        identityResult.message = 'Lead Created';
        identityResult.statusCode = 201;
        identityResult.apiResponse = lcr;
        IdentityHelper.makeLog(newLead, identityResult, ACVUtility.currentLineNumber(), endpointURL, 'POST', 'IdentityService.createLead Line: '+ACVUtility.currentLineNumber(), SplunkHelper.LOGLEVEL.INFO, 201);
        
        identityResult.generateResponse(headerMap);
    }

    

    global class LeadCreateRequest{
        global String FirstName;
        global String LastName;
        global String CompanyName;
        global String UserName; //this is the users email address
        global String DealerShip_DBAName;
        global String Dealer_Type;
        global String Phone;
        global String PhoneExt;
        global String Street;
        global String City;
        global String State;
        global String Zipcode;
        global String ContactPreference;
        global String ReferralType;
        global String ReferralCode;
        global String SMSOptIn;
        global String Website;        
        global Integer CarsInstock;
        global String DealersInterest;
        global String EulaTosAcceptedDate;
        global String EulaId;   
        global String CellPhone;
        global String LanguagePreference;
        global String UtmSource;
        global String UtmMedium;
        global String UtmCampaign;
        global String GoogleClickId;
        global String MarketPlaceReportUser;
    }

    global class LeadCreateResponse{
        global String Lead_Id {get;set;}
    }

}