/******************************************************************************* 
@description This trigger handler is used as part of trigger factory framework for EmailMessages
@author Huron Consulting Group
*******************************************************************************/
public class EmailMessageTriggerHandler extends TriggerInterface{
    /****************Class Variables************************/
    /*
     * @description wrapper class used to store information from the email message to be passed to exisiting transportation case
     * @author Huron Consulting Group
     */
    public class EmailCase{
        String caseId {get;set;}
        String contactEmail {get;set;}
        String auctionId {get;set;}
        String userSubmittedDetails {get;set;}
        String status {get;set;}
        EmailMessage email {get;set;}
        List<String> failReasons {get;set;}
        Date actualDate {get; set;}
        Date estDate {get;set;}
    }
    /****************Context Methods************************/
    /**
     * logic to run in before insert context.
     * @param newList - List of new Email Messages
     * @return void
     */
    public override void beforeInsert( List<SObject> newList ){
        ParseArbEmails( (List<EmailMessage>)newList );
        ParseCdStatusEmails( (List<EmailMessage>)newList );
        ParseCdBatchResponseEmails( (List<EmailMessage>)newList );
        ParseBOLEmails( (List<EmailMessage>)newList );
    }
    /****************Helper Methods*************************/
    public static void ParseArbEmails(List<EmailMessage> lEmailMsg){
        List<EmailCase> lEmailCases = new List<EmailCase>();
        Map<String,String> mContactEmailToId = new Map<String,String>();
        EmailToCase_Mapping__mdt e2cMapping = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Arb' LIMIT 1];
        String toAddress;
        if(e2cMapping != null){
            toAddress = e2cMapping.ToAddress__c;
        }
        for(EmailMessage em : lEmailMsg){
            if(em.ToAddress == toAddress){
                Map<String,String> mBodyFieldValues = new Map<String,String>();
                EmailCase newEmailCase = new EmailCase();
                newEmailCase.caseId = em.ParentId;
                List<String> lSplitBody = em.TextBody.split('\n\n');
                for(String str : lSplitBody){
                    if(str != null && !String.isBlank(str)){
                        //List<String> splitRes = str.split(':\n');
                        List<String> splitRes = str.replaceAll('\\*','').split(':\n');
                        if(splitRes != null && splitRes.size()>1){
                            String keyVal = splitRes[0].trim();
                            String value = splitRes[1].trim();
                            mBodyFieldValues.put(keyVal,value);
                        }
                    }
                }
                if(mBodyFieldValues.get('Report Email') != null){
                    String contactEmail = mBodyFieldValues.get('Report Email').split('<')[0];
                    newEmailCase.contactEmail = contactEmail;
                    mContactEmailToId.put(contactEmail,null);
                    //em.FromAddress = contactEmail;
                }
                if(mBodyFieldValues.get('Auction ID') != null){
                    String auctionId = mBodyFieldValues.get('Auction ID');
                    newEmailCase.auctionId = auctionId;
                }
                if(mBodyFieldValues.get('User Submitted Details') != null){
                    String userSubmittedDetails = mBodyFieldValues.get('User Submitted Details');
                    newEmailCase.userSubmittedDetails = userSubmittedDetails;
                }
                lEmailCases.add(newEmailCase);
            }
        }

        for(Contact con :[SELECT Id, Email FROM Contact WHERE Email IN :mContactEmailToId.keySet()]){
            mContactEmailToId.put(con.Email,con.Id);
        }
        List<Case> lCasesToUpdate = new List<Case>();
        for(EmailCase ec :lEmailCases){
            Boolean bUpdateCase = false;
            Case updateCase = new Case(Id = ec.caseId);
            updateCase.SuppliedEmail = ec.contactEmail;
            if(mContactEmailToId.get(ec.contactEmail) != null){
                updateCase.ContactId = mContactEmailToId.get(ec.contactEmail);
                bUpdateCase = true;
            }
            if(ec.auctionId != null){
                Auction__c auction = new Auction__c(id__c = ec.auctionId);
                updateCase.Auction_Number__r = auction;
                bUpdateCase = true;
            }
            
            if(ec.userSubmittedDetails != null){
                updateCase.User_Submitted_Details__c = ec.userSubmittedDetails;
            }
            if(bUpdateCase){
                lCasesToUpdate.add(updateCase);
            }

        }
    system.debug(lCasesToUpdate.size());
        if(lCasesToUpdate.size() > 0){
            CaseArbitrationProcesses.afterUpdateToggle(false);
            update(lCasesToUpdate);
        }
    }

    /******************************************************************************* 
    @description method to parse email messages containing BOL attachments
    @author Huron Consulting Group 
    @param  lEmailMsg - List of email-to-case email message records to process
    *******************************************************************************/
    public static void ParseBOLEmails(List<EmailMessage> lEmailMsg){
        List<EmailCase> lEmailCases = new List<EmailCase>();
        List<String> auctionIds = new List<String>();
        EmailToCase_Mapping__mdt e2cMapping = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        String toAddress;
        if(e2cMapping != null){
            toAddress = e2cMapping.ToAddress__c;
        }
        for(EmailMessage em :lEmailMsg){
            if(em.ToAddress==toAddress){
                EmailCase newEmailCase = new EmailCase();
                newEmailCase.caseId = em.ParentId;
                newEmailCase.email = em;
                if(em.Subject.contains('BOL:') && em.Subject!=null){
                    String aucId = em.Subject.split(' ')[1];
                    newEmailCase.auctionId = aucId;
                    auctionIds.add(aucId);
                    lEmailCases.add(newEmailCase);

                }
                if(em.Subject=='BOL upload for ACV Auctions' && em.Subject!=null){
                    String aucId = em.TextBody.split('\n\n')[1].split(':')[1].split('\n')[0].deleteWhitespace();
                    newEmailCase.auctionId = aucId;
                    auctionIds.add(aucId);
                    lEmailCases.add(newEmailCase);

                }
            }   
        }

        if(auctionIds.size()>0){
            updateCases(lEmailCases, auctionIds);
        }
    }

    /******************************************************************************* 
    @description method for parsing CD response emails when sending batch of jobs to post
    @author Huron Consulting Group 
    @param  lEmailMsg - List of email-to-case email message records to process
    *******************************************************************************/
    public static void ParseCdBatchResponseEmails(List<EmailMessage> lEmailMsg){
        List<EmailCase> lEmailCases = new List<EmailCase>();
        List<String> auctionIds = new List<String>();
        List<String> failReasons = new List<String>();
        List<Case> casesToDelete = new List<Case>();
        EmailToCase_Mapping__mdt e2cMapping = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        String toAddress;
        if(e2cMapping != null){
            toAddress = e2cMapping.ToAddress__c;
        }
        for(EmailMessage em :lEmailMsg){
            if(em.Subject=='Central Dispatch Import Log - ACV Auctions Inc (acvcars)' && em.Subject != null){
            if(em.ToAddress == toAddress){
                if(!em.TextBody.contains('Failed To Post: 0')){
                    //find the failed to post line
                    String failureRegex = 'Failed To Post: [0-9]+';
                    Pattern failPattern = Pattern.compile(failureRegex);
                    Matcher failMatcher = failPattern.Matcher(em.textbody);
                    String failureString ='';
                    if(failMatcher.find()){
                        failureString = failMatcher.group();
                    }
                    //find the number of failures
                    String failureNumRegex = '[0-9]+';
                    Pattern failureNumPattern = Pattern.compile(failureNumRegex);
                    Matcher failureNumMatcher = failureNumPattern.Matcher(failureString);
                    Integer numOfFailed;
                    if(failureNumMatcher.find()){
                        numOfFailed = Integer.ValueOf(failureNumMatcher.group());
                    }
                    //get the Error Lines from the rest of the email body
                    String errorLineRegex = '(>)(.*?)(\n.*)';
                    Pattern errorLinePattern = Pattern.compile(errorLineRegex);
                    Matcher errorLineMatcher = errorLinePattern.Matcher(em.textbody);
                    List<String> errorLines = new List<String>();
                    for(Integer i = 0; i < numOfFailed; i++){
                        if(errorLineMatcher.find()){
                            errorLines.add(errorLineMatcher.group());
                            //find the auction id of each error line
                            String auctionIdRegex = '[0-9]+';
                            Pattern auctionIdPattern = Pattern.compile(auctionIdRegex);
                            Matcher auctionIdMatcher = auctionIdPattern.Matcher(errorLineMatcher.group());
                            if(auctionIdMatcher.find()){
                                auctionIds.add(auctionIdMatcher.group());
                            }
                        }
                    }
                        String numberOfFailures = em.TextBody;
                        EmailCase newEmailCase = new EmailCase();
                        newEmailCase.caseId = em.ParentId;
                        newEmailCase.email = em;
                        newEmailCase.failReasons=errorLines;
                        lEmailCases.add(newEmailCase);
                    }
                    else{
                        casesToDelete.add(new Case(id=em.ParentID));
                        em.parentId = null;
                    }
                }
            }
        }
        

        if(auctionIds.size()>0){
            updateCases(lEmailCases, auctionIds);
        }
        else if(casesToDelete.size() > 0){
            delete casesToDelete;
        }
    }

    /******************************************************************************* 
    @description method for parsing CD status update emails for posted jobs
    @author Huron Consulting Group 
    @param  lEmailMsg - List of email-to-case email message records to process
    *******************************************************************************/
    public static void ParseCdStatusEmails(List<EmailMessage> lEmailMsg) {
        List<EmailCase> lEmailCases = new List<EmailCase>();
        List<String> auctionIds = new List<String>();
        List<Case> caseDeleteList = new List<Case>();
        List<EmailMessage> emailDeleteList = new List<EmailMessage>();
        EmailToCase_Mapping__mdt e2cMapping = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        String toAddress;
        if(e2cMapping != null){
            toAddress = e2cMapping.ToAddress__c;
        }
        for(EmailMessage em :lEmailMsg){
            if(em.Subject != null && em.Subject.contains('Order')){
                if(em.ToAddress == toAddress){
                    EmailCase newEmailCase = new EmailCase();
                    newEmailCase.caseId = em.ParentId;
                    newEmailCase.email = em;
                    String emailSubject = em.Subject.toUpperCase();
                    List<String> lSplitSubj = em.Subject.split(' ');
                    newEmailCase.auctionId = lSplitSubj[2];
                    if(emailSubject.contains('PICKED UP')){
                        newEmailCase.status = 'PICKED-UP';
                        lEmailCases.add(newEmailCase);
                        String auctionId = lSplitSubj[2];
                        auctionIds.add(auctionId);
                    }
                    //may want to get cancellation reason
                    else if(emailSubject.contains('CANCELLED') || emailSubject.contains('CANCELED')){
                        newEmailCase.status = 'CANCELLED';
                        lEmailCases.add(newEmailCase);
                        String auctionId = lSplitSubj[2];
                        auctionIds.add(auctionId);
                        
                    } 
                    else if(emailSubject.contains('DECLINED')){
                        newEmailCase.status = 'DECLINED';
                        lEmailCases.add(newEmailCase);
                        String auctionId = lSplitSubj[2];
                        auctionIds.add(auctionId);
                    }
                    else if(emailSubject.contains('DELIVERED')){
                    //else if(lSplitSubj[5] == 'Delivered') {
                        newEmailCase.status = 'DELIVERED';
                        String dateRegex = '[0-9]{4}-[0-9]{2}-[0-9]{2}';
                        Pattern regexPattern = Pattern.compile(dateRegex);
                        Matcher regexMatcher = regexPattern.Matcher(em.textbody);
                        if(regexMatcher.find()){
                            newEmailCase.actualDate = date.valueOf(regexMatcher.group());
                        }
                        if(regexMatcher.find(regexMatcher.end())){
                            newEmailCase.estDate = date.valueOf(regexMatcher.group());
                        }
                        lEmailCases.add(newEmailCase);
                        String auctionId = lSplitSubj[2];
                        auctionIds.add(auctionId);
                    }
                    else if(emailSubject.contains('ACCEPTED')){
                        newEmailCase.Status= 'Accepted';
                        lEmailCases.add(newEmailCase);
                        String auctionId = lSplitSubj[2];
                        auctionIds.add(auctionId);
                    }
                    else{
                        caseDeleteList.add(new case(id = em.parentId));
                        em.parentId = null;
                        emailDeleteList.add(em);
                    }                    
                    
                }
            }       
        }
        if(lEmailCases.size() > 0){
            updateCases(lEmailCases, auctionIds);
        }
        if(caseDeleteList.size() > 0){
            delete caseDeleteList;
        }
        if(emailDeleteList.size() > 0){
            delete emailDeleteList;
        }

            
    }

    /******************************************************************************* 
    @description method to update tranpsortation cases according to a received email
    @author Huron Consulting Group 
    @param  lEmCases - list of email cases wrappers
    @param  aucIds - list of auction Ids
    *******************************************************************************/
    private static void updateCases(List<EmailCase> lEmCases, List<String> aucIds){
        List<Case> lCasesToUpdate = new List<Case>();
        List<Case> lCasesToDelete = new List<Case>();
        List<CaseComment> lCommentsToAdd = new List<CaseComment>();
        Map<String, Case> mExistingCases = new Map<String, Case>();
        List<Account> lAccountsToUpdate = new List<Account>();
        Set<String> transAcctIds = new Set<String>();
        Map<Id, Account> mExistingTransporters = new Map<Id, Account>();
        for(Case tCase :[SELECT Id, Status, Transporter_Account__c, Auction_Number_Case__c, Auction_Number__c, Date_First_Posted__c,
                            RecordTypeId, RecordType.Name, Number_of_Times_Cancelled__c, Number_of_Times_Declined__c,
                            Expected_Delivery__c, Transporter_Account__r.Number_of_Times_Declined__c, BOL_Received__c, //Driver__c, 
                            Previous_Last_Posted_Date__c, Date_Estimated_Pick_Up__c,Transporter_Account__r.Number_of_Times_Cancelled__c, Times_Posted_to_CD__c FROM Case 
                            WHERE Auction_Number_Case__c IN : aucIds AND RecordType.Name = 'Transportation']){
            mExistingCases.put(tCase.Auction_Number_Case__c, tCase);
            if(tCase.Transporter_Account__c != null){     
                transAcctIds.add(tCase.Transporter_Account__c);
            }
        }
        for(Account transAcct :[SELECT Id, Number_of_Times_Cancelled__c, Number_of_Times_Declined__c, Times_Delayed_Updating_Delivery_CD__c FROM Account WHERE Id IN :transAcctIds]){
            mExistingTransporters.put(transAcct.Id, transAcct);
        }
        
        for (EmailCase ec :lEmCases){
            Case e2case = new Case(Id = ec.caseId);
            lCasesToDelete.add(e2case);
            //handle BOL checks
            if(ec.status == null && ec.auctionId!=null && ec.failReasons == null){
                Case eCase = mExistingCases.get(ec.auctionId);
                ec.email.ParentId = eCase.Id;
                eCase.BOL_Received__c = true;
                lCasesToUpdate.add(eCase);

            }
            //handle status updates from CD
            if(ec.status != null && ec.auctionId!=null && mExistingCases.containsKey(ec.auctionId)){
                Case eCase = mExistingCases.get(ec.auctionId);
                ec.email.ParentId = eCase.Id;
                if(ec.status == 'Picked-Up'){
                    eCase.Status = ec.status;
                    eCase.Marked_Picked_Up_in_CD__c = 'Yes';
                    eCase.Date_Picked_Up__c = Date.Today();
                }
                else if(ec.status=='Cancelled'){
                    eCase.Status = 'Cancelled by Transporter';
                    if(mExistingTransporters.get(eCase.Transporter_Account__c) != null){
                        Account transAcct = mExistingTransporters.get(eCase.Transporter_Account__c);
                        if(eCase.Transporter_Account__r.Number_of_Times_Cancelled__c != null){
                            transAcct.Number_of_Times_Cancelled__c = eCase.Transporter_Account__r.Number_of_Times_Cancelled__c + 1;
                        }
                        else{
                            transAcct.Number_of_Times_Cancelled__c = 1;
                        }
                        lAccountsToUpdate.add(transAcct);
                    }                        
                    eCase.Number_of_Times_Cancelled__c += 1;
                    eCase.Transporter_Account__c = null;                    
                    //eCase.Driver__c = null;

                }  
                else if(ec.status=='DECLINED'){
                    eCase.Status = 'Ready-to-Post';
                    if(mExistingTransporters.get(eCase.Transporter_Account__c) != null){
                        Account transAcct = mExistingTransporters.get(eCase.Transporter_Account__c);
                        if(eCase.Transporter_Account__r.Number_of_Times_Declined__c != null){
                            transAcct.Number_of_Times_Declined__c = eCase.Transporter_Account__r.Number_of_Times_Declined__c + 1;
                        }
                        else{
                            transAcct.Number_of_Times_Declined__c = 1;
                        }
                        lAccountsToUpdate.add(transAcct);
                    }                      
                    eCase.Number_of_Times_Declined__c += 1;
                    eCase.Transporter_Account__c = null;                    
                    //eCase.Driver__c = null;
                }                         
                else if(ec.status == 'Accepted'){
                    eCase.Status= ec.status;
                    if(eCase.Date_First_Accepted__c == null){
                        eCase.Date_First_Accepted__c = Date.Today();
                    }
                    eCase.Date_Last_Accepted__c = Date.Today();
                    
                }
                else if(ec.status == 'Delivered'){
                    eCase.Status = ec.status;
                    eCase.Date_Delivered__c = Date.Today();
                    eCase.Date_Delivered_Actual__c = ec.actualDate;
                    eCase.Date_Estimated_Pick_Up__c = ec.estDate;
                    if(eCase.Date_Delivered_Actual__c > eCase.Expected_Delivery__c){
                        eCAse.Delivery_Delayed__c = 'Yes';
                    }
                    if(eCase.Transporter_Account__c != null && eCase.Date_Delivered__c > eCase.Date_Delivered_Actual__c){
                        Account transAcct = mExistingTransporters.get(eCase.Transporter_Account__c);
                        transAcct.Times_Delayed_Updating_Delivery_CD__c += 1;
                        lAccountsToUpdate.add(transAcct);
                    }
                }
                lCasesToUpdate.add(eCase);
            }
            //handle failed posts
            if(ec.auctionId == null && aucIds != null){

                for(Integer i=0; i<aucIds.size(); i++){
                    Case exCase = mExistingCases.get(aucIds[i]);
                    ec.email.ParentId = exCase.Id;
                    if(exCase.Times_Posted_to_CD__c==1){
                        exCase.Date_First_Posted__c=null;
                    }
                    exCase.Status = 'Failed Post';
                    exCase.Times_Posted_to_CD__c -= 1;
                    exCase.Date_Last_Posted__c=exCase.Previous_Last_Posted_Date__c;
                    CaseComment failReason=new CaseComment();
                    failReason.CommentBody='Failed Post Reason: '+ec.failReasons[i];
                    failReason.IsPublished=true;
                    failReason.ParentId=exCase.Id;
                    lCasesToUpdate.add(exCase);
                    lCommentsToAdd.add(failReason);
                }
                                                
            }
            
        }
        
        if(lCasesToUpdate.size()>0){
            update(lCasesToUpdate);
        }
        if(lCasesToDelete.size()>0){
            delete(lCasesToDelete);
        }
        if(lAccountsToUpdate.size()>0){
            update(lAccountsToUpdate);
        }
        if(lCommentsToAdd.size()>0){
            insert(lCommentsToAdd);
        }
        
    }

}