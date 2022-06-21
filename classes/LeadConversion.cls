/*
    This class is called from leadConversion LWC
*/
public class LeadConversion {

    // This field is used in before insert triggers of Contact & Account to set "Lead Convert Status" field on Account
    public static Boolean isConverting= false;
    public static final Map<String, String> DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS = new Map<String,String>{'Franchise' => '1', 'Wholesaler' => '3', 'Independent' => '2', 'Commercial'=>'5'};
   
    // This method gets the lead address and called from leadConversion LWC
    @AuraEnabled
    public static AddressWrapper getLeadAddress(Id recordId){
        List<lead> leadList = [SELECT Street, City, State, PostalCode, Country FROM Lead WHERE ID=: recordId];
        AddressWrapper addWrapper;
        if(!leadList.isEmpty()){
            addWrapper = new AddressWrapper(leadList[0].Street, leadList[0].City, leadList[0].State, leadList[0].PostalCode, leadList[0].Country);
        }
        return addWrapper;
    }

    // This method updates lead address and converts lead into account & contact. 
    @AuraEnabled
    public static ReturnWrapper updateAddAndConvertLead(Id recordId, AddressWrapper addWrapper){
        ReturnWrapper rw= new ReturnWrapper();
        try{
            // Update lead record with address filled from UI
            Lead leadRec = new Lead();
            leadRec.Id = recordId;
            leadRec.Street = addWrapper.street;
            leadRec.City = addWrapper.city;
            leadRec.State = addWrapper.state;
            leadRec.PostalCode = addWrapper.postalCode;
            leadRec.Country = String.isNotBlank(addWrapper.Country) ? addWrapper.Country  : 'US';
            update leadRec;            
        

            isConverting= true;
            List<Lead> lead = [Select Id, Company, Email, Street, City, State, PostalCode, Country, RecordTypeId, NumberOfEmployees, Dealer_Type__c, Website from Lead WHERE Id = :recordId];
            
            // Checking for duplicate lead
            List<Lead> leadDupeCheck = [ SELECT Id FROM Lead WHERE Email = :lead[0].Email AND RecordTypeId = :lead[0].RecordTypeId AND isConverted = false ];
            if( leadDupeCheck.size() > 1 ){


                throw new CustomException('Duplicate Lead found. Please follow the procedure to merge the leads before continuing. Lead Conversion process aborted.');
            }
            
            //  Checking for duplicate contact
            List<Contact> contactList = [Select Id, Id__c from Contact WHERE Email = :lead[0].Email];
            if(!contactList.isEmpty()){
                throw new CustomException('Duplicate ACV User found. Lead conversion process aborted.');
            }

            // Checking for duplicate dealer
            List<Account> accountList = [Select Id from Account WHERE Legal_Name__c= :lead[0].Company and BillingStreet= :lead[0].Street and
                                        BillingCity= :lead[0].City and BillingState= :lead[0].State and BillingPostalCode= :lead[0].PostalCode];
            if(!accountList.isEmpty()){
                throw new CustomException('Dealer already exists. Lead conversion process aborted.');
            }

            // Lead Conversion
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(recordId);
            lc.setSendNotificationEmail(false);
            lc.setDoNotCreateOpportunity(true);
            leadstatus ls = [SELECT Id, MasterLabel, IsConverted FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            lc.setConvertedStatus(ls.MasterLabel);
        
            Database.LeadConvertResult lcr= Database.convertLead(lc);


            Id accId = lcr.getAccountId();
            Id conId = lcr.getContactId();
        
            List<Contact> con = [Select Id, Id__c, Account.Dealership_Id__c from Contact WHERE Id = :conId];
            List<Account> acc = [Select Id, Dealership_Id__c, Organization_Auto_Inc_Id__c, Total_Employees__c, Status__c, URL__c, Dealer_Type__c from Account WHERE Id = :accId];

                   
            // Update number of employees
            acc[0].Total_Employees__c =  lead[0].NumberOfEmployees;    
            acc[0].Status__c= '4'; // Updating the status to 100% Percent Complete.
            acc[0].URL__C= lead[0].Website;
            acc[0].Dealer_Type__c = DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.get(lead[0].Dealer_Type__c) != null ? 
                                    DEALER_TYPE_LABEL_TO_API_NAME_MAP_TO_PROCESS.get(lead[0].Dealer_Type__c) : lead[0].Dealer_Type__c;
            update acc;          
    
            // Create affiliation record
            try{
                Affiliation__c newAff = new Affiliation__c();
                newAff.Account__c = accId;
                newAff.Contact__c = conId;
                newAff.Active__c = True;
                newAff.primary_contact__c = True;
                newAff.type__c = 'admin';
                newAff.id__c = IdentityHelper.createAffiliationId(acc[0].Dealership_Id__c, con[0].Id__c);
                newAff.Start_Date__c = System.today();
                insert newAff;
            }
            catch(Exception e){
                throw new CustomException('Failed to create an affiliation. Lead conversion process aborted.');
            }

            // Link address to dealer
            AddressHelper.AddressWrapper aw= new AddressHelper.AddressWrapper(lead[0].Street, lead[0].City, lead[0].State, lead[0].PostalCode, lead[0].Country, 'billing', '', '');
            try{
                insert AddressHelper.generateAddressStack(aw, accId);
            }
            catch(Exception e){
                throw new CustomException('Failed to link an address the dealer. Lead conversion process aborted.');
            }

            // Update EULA/TOS record with Contact information
            List<Eula_Tos__C> eulaRecords= [Select Id, Contact__c From Eula_Tos__C where Lead__C=:recordId LIMIT 1];
            if(!eulaRecords.isEmpty())
            {
                eulaRecords[0].Contact__C= conId;
                update eulaRecords;
            } 

            // todo: This code is commented, but not deleted if incase we want to rollback to this approach.
            // Send Policy Email With a delay
            /*
            String scheduledTime= GetFormattedCronTime();
            SendPolicyEmailOnLeadConvertSchedulable s = new SendPolicyEmailOnLeadConvertSchedulable(new List<Id>{conId});
            System.schedule('SendPolicyEmailOnLeadConvertSchedulable: Job Started At ' + String.valueOf(Datetime.now()), scheduledTime, s);
            */
            rw.accountId= accId;
            rw.message= 'Lead Conversion successful.';
            rw.hasError= false;
            return rw;
        }
        Catch(Exception ex)
        {
            sendLog(SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber(),ex.getMessage(),ex.getStackTraceString(),recordId);
            if(ex.getMessage().contains('Lead conversion process aborted'))
            {
                rw.message= ex.getMessage();
            }
            else if(ex.getMessage().contains('Duplicate Account')) // This text is prefixed to all duplicate rules for the account object 
            {
                rw.message= 'Lead Conversion Failed. There is already duplicate accounts matching this record.';
            }
            else{
                rw.message= 'Lead Conversion Failed: Please Contact System Administrator.';
            }
            rw.hasError= true;
            return rw;
           
        }
        
    }

    // todo: This code is commented, but not deleted if incase we want to rollback to this approach.
    /*
    public static string GetFormattedCronTime(){
        
        // Add delay based on a custom label
        String[] delay= System.Label.Policy_Email_On_Lead_Convert_Delay.split(':');
        Datetime nextFireDateTime= Datetime.now();
        String hourDelay=  delay[0]; 
        String minuteDelay= delay[1];
        String secondsDelay=  delay[2];
        nextFireDateTime= nextFireDateTime.addHours(Integer.valueOf(hourDelay));
        nextFireDateTime= nextFireDateTime.addMinutes(Integer.valueOf(minuteDelay));
        nextFireDateTime= nextFireDateTime.addSeconds(Integer.valueOf(secondsDelay));
   
        // Format datetimesen
        String hour = String.valueOf(nextFireDateTime.hour());
        String min = String.valueOf(nextFireDateTime.minute()); 
        String ss = String.valueOf(nextFireDateTime.second());
        String day = String.valueOf(nextFireDateTime.day());
        String month = String.valueOf(nextFireDateTime.month());
        String year = String.valueOf(nextFireDateTime.year());

        return ss + ' ' + min + ' ' + hour + ' ' + day + ' '+ month + ' ? '+ year;
    }
    */
    public static void sendLog(SplunkHelper.LOGLEVEL logLevel, Integer lineNumber, String Message, String StackTrace, String recordId){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'LeadConversion:' + lineNumber;
        infoLog.message = Message;
        infoLog.stackTrace = StackTrace+ ' '+lineNumber;
        infoLog.sfRecordId = String.isBlank(recordId) ? '' : recordId;
        infoLog.componentName = 'LeadConversion';
        infoLog.sfObject = 'Lead';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.INSPECTION_PLATFORM};
        SplunkHelper.buildAndProcessLog(infoLog);
    }

   
    public class AddressWrapper{
        @AuraEnabled public string street {get;set;}
        @AuraEnabled public string city {get;set;}
        @AuraEnabled public string state {get;set;}
        @AuraEnabled public string postalCode {get;set;}
        @AuraEnabled public string country {get;set;}

        public AddressWrapper (String s, String c, String st, String pc, String cty){
            this.street = String.isNotBlank(s) ? s :'';
            this.city = String.isNotBlank(c) ? c :'';
            this.state = String.isNotBlank(st) ? st :'';
            this.postalCode = String.isNotBlank(pc) ? pc :'';
            this.country = String.isNotBlank(cty) ? cty :'';
        }

        public AddressWrapper(){}

    }

    public class ReturnWrapper{
        @AuraEnabled public String message;
        @AuraEnabled public Boolean hasError;
        @AuraEnabled public Id accountId;
        public ReturnWrapper(){
            message = '';
            hasError = false;
            accountId= null;
        }
    }
}