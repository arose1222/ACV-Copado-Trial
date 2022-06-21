public without sharing class CaseCreateUtilityController {
    public static final Id supportId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Support').getRecordTypeId();
    public static final Id notesId = Schema.SObjectType.Inquiry_Comment__c.getRecordTypeInfosByDeveloperName().get('Inquiry_Comment').getRecordTypeId();
    public static final Id junctionId = Schema.SObjectType.Inquiry_Comment__c.getRecordTypeInfosByDeveloperName().get('Inquiry_Junction_Object').getRecordTypeId();
    //public static final List<Group> queue48Hr = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Forty_Eight_Hour_Queue'];

    /**
     * Returns boolean used to determine if user has access to LaI process
     * @return  `Boolean`
     */
    @AuraEnabled
    public static Boolean checkPermissions() {
        Boolean access = false;
        Set<String> profileSet = new Set<String>();
        for (Profile_Group__mdt pg : [SELECT Profile_Name__c FROM Profile_Group__mdt WHERE Group_Name__c IN ('IST Profiles', 'Title Profiles', 'Capital and Major Accounts Profiles')]) {
            profileSet.add(pg.Profile_Name__c);
        }
        if (profileSet.contains(ACVUtility.profileNameMap.get(UserInfo.getProfileId()))) {
            access = true;
        }
        return access;
    }

    /**
     * Returns true or false based on ability for current user to create affiliations
     * @return  `Boolean`    
     */
    @AuraEnabled
    public static Boolean checkAffiliationCreateAccess(){
        return Affiliation__c.sObjectType.getDescribe().isCreateable();
    }

    /**
     * Determines object type and returns necessary json details
     * @param recordId      The ID of the record log an interaction was launched from
     * @return  `String`    JsonString
     */
    @AuraEnabled
    public static String initialQuery(Id recordId) {
        String jsonStr = '';
        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();

        if (sobjectName == 'Case') {
            SObject record = Database.query('SELECT Id, RecordType.DeveloperName, Auction_Number__c FROM ' + sobjectName + ' WHERE Id = :recordId');
            jsonStr = JSON.serialize(record);
        }
        else if (sobjectName == 'Auction__c') {
            String record = sobjectName + ' ' + recordId;
            jsonStr = JSON.serialize(record);
        }
        else if (sobjectName == 'Account') {
            SObject record = Database.query('SELECT Id, Name FROM ' + sobjectName + ' WHERE Id = :recordId');
            jsonStr = JSON.serialize(record);
            List<String> splitStr = jsonStr.split('"Name":"');
            String finalStr = splitStr[1].removeEnd('"}');
            jsonStr = JSON.serialize(getAccounts(finalStr));
        }
        return jsonStr;
    }

    /**
     * Creates Support Case and necessary Customer Inquiries and Inquiry Comments
     * @param accountId     The accountId from Interaction
     * @param inquiryOwner  UserId of Inquiry Owner
     * @param contactId     The contactId from Interaction
     * @param jsonString    Json of inquiry details
     * @return  `Id`
     */
    @AuraEnabled
    public static Id logAnInteraction(Id accountId, Id inquiryOwner, String contactId, String jsonString) {
        System.debug('json: '+jsonString);
        List<newCustInq> newInqList = new List<newCustInq>();
        List<Inquiry_Comment__c> newInqComments = new List<Inquiry_Comment__c>();
        List<Customer_Inquiry__c> existingCustInqs = new List<Customer_Inquiry__c>();
        List<Customer_Inquiry__c> allCustInqs = new List<Customer_Inquiry__c>();
        List<Task> caseFeedTasks = new List<Task>();
        Map<String,newCustInq> cisMissingOpsCase = new Map<String,newCustInq>();
        Set<Id> aucIdSet = new Set<Id>();
        Set<Id> aucsOpsCaseMissing = new Set<Id>();
        Set<String> bucketSet = new Set<String>();
        Set<String> typeSet = new Set<String>();
        Set<String> caseTypes = new Set<String>();
        Id suppCaseId;
        Case newSupportCase;

        //create a database rollback point here (and send a splunk log)
        SavePoint dbSave = Database.setSavePoint();

        try {

            if(String.isBlank(inquiryOwner)) {
                inquiryOwner = UserInfo.getUserId();
            }

            newSupportCase = createSupportCase(contactId, accountId, inquiryOwner, jsonString, aucIdSet, bucketSet, typeSet, newInqList);

            suppCaseId = upsertCustomerInquiries(aucIdSet, bucketSet, typeSet, newInqList, inquiryOwner, accountId, newSupportCase, existingCustInqs, allCustInqs);
        
            for (Customer_Inquiry__c cic : existingCustInqs) { //create a junction rec
                newInqComments.add(new Inquiry_Comment__c(RecordTypeId = junctionId, Customer_Inquiry__c = cic.Id, Auction__c = cic.Auction__c, Support_Case__c = suppCaseId));
            }

            for (Customer_Inquiry__c cc : allCustInqs) { //create inquiry comments records
                newInqComments.add(new Inquiry_Comment__c(RecordTypeId = notesId, Customer_Inquiry__c = cc.Id, Inquiry_Notes__c = cc.Call_Notes__c));
            }

            insert newInqComments;
            
        }
        catch (Exception e) {
            Database.rollback(dbSave);
            SplunkHelper.buildAndProcessLog( createLog( SplunkHelper.LOGLEVEL.FATAL, e.getMessage(), e.getStackTraceString(), ACVUtility.currentLineNumber()) );
        }
        
        return suppCaseId;
    }

    /**
     * Populates all details on Support case to be inserted
     * @param contactId     Contact Id from Interaction
     * @param accountId     Account Id from Interaction
     * @param inquiryOwner  User to own newly created Inquiry
     * @param jsonString    Json of inquiry details
     * @param aucIdSet      Set of auction Ids from interaction
     * @param bucketSet     Set of call buckets from interaction
     * @param typeSet       Set of call types from interaction
     * @param newInqList    List to be populated with inquiry details from jsonString
     * @return  `Case`
     */
    public static Case createSupportCase(String contactId, Id accountId, Id inquiryOwner, String jsonString, Set<Id> aucIdSet, Set<String> bucketSet, Set<String> typeSet, List<newCustInq> newInqList) {
        Case newCase = new Case();
        Boolean containsOpenInqs = false;
        Boolean containsClosedInqs = false;

        if (contactId != '') {
            newCase = new Case(RecordTypeId = supportId, AccountId = accountId, ContactId = contactId, Origin = 'Phone', OwnerId = inquiryOwner, Priority = 'Low'); //Description = 'Initial General Call Notes: ' + initComments,
        }
        else {
            newCase = new Case(RecordTypeId = supportId, AccountId = accountId, Origin = 'Phone', OwnerId = inquiryOwner, Priority = 'Low'); //Description = 'Initial General Call Notes: ' + initComments,
        }

        for (newCustInq n : (List<newCustInq>)JSON.deserialize(jsonString, List<newCustInq>.class)) {
            if(!String.isBlank(n.auctionId)) {
                aucIdSet.add(n.auctionId);
            }
            bucketSet.add(n.callBucketLabel);
            typeSet.add(n.callType);
            if (n.resolved == true) {
                containsClosedInqs = true;
            }
            else {
                containsOpenInqs = true;
            }
            newInqList.add(n);
        }

        if (containsOpenInqs == true && containsClosedInqs == true) {
            newCase.Status = 'Working';
        }
        else if (containsOpenInqs == true && containsClosedInqs == false) {
            newCase.Status = 'New';
        }
        else {
            newCase.Status = 'Closed';
        }
        return newCase;
    }

    /**
     * Inserts Support Case and upserts Customer Inquiries
     * @param aucIdSet              Set of auction Ids from interaction
     * @param bucketSet             Set of call buckets from interaction
     * @param typeSet               Set of call types from interaction
     * @param newInqList            List populated with all inquiry data
     * @param inquiryOwner          User Id to own created inquiries
     * @param accountId             Account Id from Interaction
     * @param supportCase           The support case to be inserted as parent to new inquiries
     * @param existingCustInqs      List of inquiries that already existed and may need updates
     * @param allCustInqs           List of all Inquiries
     * @return  `Id`
     */
    public static Id upsertCustomerInquiries(Set<Id> aucIdSet, Set<String> bucketSet, Set<String> typeSet, List<newCustInq> newInqList, Id inquiryOwner, Id accountId, Case supportCase, List<Customer_Inquiry__c> existingCustInqs, List<Customer_Inquiry__c> allCustInqs) {
        Map<String, Customer_Inquiry__c> existingCustInqMap = new Map<String, Customer_Inquiry__c>();
        List<Customer_Inquiry__c> newCustInqList = new List<Customer_Inquiry__c>();

        for (Customer_Inquiry__c eci : [SELECT Id, Ops_Case__c, Account__c, Auction__c, Support_Case__r.AccountId, Call_Bucket__c, Call_Type__c, Status__c, Call_Count__c, First_Call_Resolution__c FROM Customer_Inquiry__c WHERE Auction__c IN :aucIdSet AND Call_Bucket__c IN :bucketSet AND Call_Type__c IN :typeSet]) {
            existingCustInqMap.put((eci.Auction__c + eci.Call_Bucket__c + eci.Call_Type__c + eci.Account__c), eci);
        }
        Integer counter = 0;
        List<Integer> intList = new List<Integer>();
        for (newCustInq nci : newInqList) {
            if (existingCustInqMap.containsKey(nci.auctionId + nci.callBucketLabel + nci.callType + nci.relatedAccount)) { //this will run for old CI's only
                Customer_Inquiry__c currentCI = existingCustInqMap.get(nci.auctionId + nci.callBucketLabel + nci.callType + nci.relatedAccount);
                currentCI.Call_Count__c ++;
                if(currentCI.Call_Count__c >= 3){
                    currentCI.Priority__c = 'High';
                }
                else {
                    currentCI.Priority__c = 'Medium';
                }

                if (currentCI.Status__c == 'Closed' && !nci.resolved) {
                    currentCI.Status__c = 'New';
                    currentCI.First_Call_Resolution__c = false; // We set this false in case it was set to true on first call
                }
                else if (nci.resolved) {
                    currentCI.Status__c = 'Closed';
                }
                existingCustInqs.add(currentCI); //add existing CI to list to be updated
                currentCI.Call_Notes__c = nci.callNotes; // add the latest notes to the map (will become comment records later)
                allCustInqs.add(currentCI); //add existing CI with notes to allCI list to process junction and comment records later
                intList.add(counter);
            }
            counter++;
        }

        Integer numRemoved = 0;
        for (Integer i : intList) {
            Integer index = i - numRemoved;
            newInqList.remove(index); //removes the pre-existing CI's from the list we will use to create new CI's with
            numRemoved++;
        }

        if (newInqList.size() > 0) {

            insert supportCase;

            newInqList = getAssignedTo(newInqList, aucIdSet, accountId);
System.debug('newInqList: ' + newInqList);

            for (newCustInq c : newInqList) {
                if(String.isBlank(c.auctionId)) {
                    c.auctionId = null;
                }
                Customer_Inquiry__c newCI = new Customer_Inquiry__c(Support_Case__c = supportCase.Id, Auction__c = c.auctionId, Call_Bucket__c = c.callBucketLabel, Call_Type__c = c.callType, Call_Notes__c = c.callNotes, Ops_Case__c = c.relatedOpsCase, Account__c = c.relatedAccount, Status__c = 'New', Call_Count__c = 1, Priority__c = 'Low', Origin__c = 'Log an Interaction', OwnerId = inquiryOwner, Assigned_To__c = c.assignedTo, Should_Assign_To__c = c.shouldAssignTo);
                if (c.resolved == true) {
                    newCI.First_Call_Resolution__c = true;
                    newCi.Status__c = 'Closed';
                }
System.debug('newCustInq: ' + newCI);
                newCustInqList.add(newCI);
            }
            allCustInqs.addAll(newCustInqList);
        }
        else {
            // If no new inquiries are associated with this support case, it should be closed on creation
            supportCase.Status = 'Closed';
            insert supportCase;
        }

        newCustInqList.addAll(existingCustInqs); //concat the two lists for one DML call
System.debug(newCustInqList.size());
        upsert newCustInqList;

System.debug(supportCase.Id);
        return supportCase.Id;
    }

    /**
     * Determines who Inquiry should be assigned to upon creation
     * @param newInqList    List of new Inquiries to be created
     * @param aucIdSet      Set of all auction ids from Interaction
     * @param accountId     Account logged on Interaction
     * @return  `List<newCustInq>`
     */
    public static List<newCustInq> getAssignedTo(List<newCustInq> newInqList, Set<Id> aucIdSet, Id accountId) {
        Map<Id, Case> relCases = new Map<Id, Case>();
        Set<String> specialistStatusSet = new Set<String>{'Problem', 'Return to Seller', 'Closed Unwound', 'Returned to Seller Unwound', 'Title at ACV Unwound'};
        Set<String> otherStatusSet = new Set<String>{'Working', 'Received', 'New', '48 Hour Notice', 'Sent'};
        Account a = [SELECT Id, Customer_Success_Advocate__c, Title_Specialist__c, IST_Account_Owner__c FROM Account WHERE Id = :accountId];
        for (Case c : [SELECT Id, Status, Seller_Dealership__r.Customer_Success_Advocate__c, Seller_Dealership__r.Title_Specialist__c, CreatedDate, Auction_Number__c, Account.IST_Account_Owner__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND Auction_Number__c IN :aucIdSet]) {
            if (relCases.containsKey(c.Auction_Number__c)) {
                if (c.CreatedDate > relCases.get(c.Auction_Number__c).CreatedDate) {
                    relCases.put(c.Auction_Number__c, c);
                }
            }
            else {
                relCases.put(c.Auction_Number__c, c);
            }
        }

        for (newCustInq inq : newInqList) {
            if (inq.AuctionId != null && inq.AuctionId != '') {
                if ( ( (inq.callType == 'Buyer Title Status' || inq.callType == 'Seller Title Status') && specialistStatusSet.contains(relCases.get(inq.AuctionId)?.Status) ) || inq.callType == 'Buyer Reported Problem') {
                    inq = setAssignedTo(inq, relCases, a, 'Title_Specialist__c');
                    if (inq.assignedTo == null) {
                        inq.shouldAssignTo = 'Specialist';
                    }
                }
                // else if ( (inq.callType == 'Buyer Title Status' && otherStatusSet.contains(relCases.get(inq.AuctionId)?.Status) ) || inq.callType == '48 Hour Submit' || inq.callType == '48 Hour Update' || (inq.callBucket == 'Title_Information' && inq.callType == 'Other')) {
                //     inq = setAssignedTo(inq, relCases, a, 'Customer_Success_Advocate__c');
                //     if (inq.assignedTo == null) {
                //         inq.shouldAssignTo = 'Consultant';
                //     }
                // }
                else if ( (inq.callType == 'Buyer Title Status' && otherStatusSet.contains(relCases.get(inq.AuctionId)?.Status) ) || (inq.callBucket == 'Title_Information' && inq.callType == 'Other')) {
                    inq = setAssignedTo(inq, relCases, a, 'Customer_Success_Advocate__c');
                    if (inq.assignedTo == null) {
                        inq.shouldAssignTo = 'Consultant';
                    }
                }
                else if (inq.callType == '48 Hour Notice Request' || inq.callType == '48 Hour Unwind Request') { //inq.callType == '48 Hour Notice Update' ||
                    inq.assignedTo = null;
                }
                else if (otherStatusSet.contains(relCases.get(inq.auctionId)?.Status) && inq.callType == 'Seller Title Status') {
                    // assigning to buyer IST account owner
                    if (relCases.get(inq.auctionId).Account.IST_Account_Owner__c != null) {
                        inq.assignedTo = relCases.get(inq.auctionId).Account.IST_Account_Owner__c;
                    }
                    else {
                        inq.assignedTo = UserInfo.getUserId();
                    }
                }
                else if (a.IST_Account_Owner__c != null) {
                    inq.assignedTo = a.IST_Account_Owner__c;
                }
                else if (a.IST_Account_Owner__c == null) {
                    inq.assignedTo = UserInfo.getUserId();
                }
            }
            // if this inquiry is not related to an auction set assigned to as IST Account Owner
            else if (a.IST_Account_Owner__c != null) {
                inq.assignedTo = a.IST_Account_Owner__c;
            }
            // if this inquiry is not related to an auction and there is no IST Account Owner, set assigned to as creating user
            else if (a.IST_Account_Owner__c == null) {
                inq.assignedTo = UserInfo.getUserId();
            }
            
        } 
        return newInqList;
    }

    /**
     * Sets assigned to on inquiries that should take sellers title consultant or specialist
     * @param inq           single newCustInq Inquiry
     * @param relCases      map of auction Id to most recent title case on that auction
     * @param a             Account logged on interaction
     * @param field         The field to reference the assigned to from.  This is from the related ops case's seller dealership
     * @return  `newCustInq`
     */
    public static newCustInq setAssignedTo(newCustInq inq, Map<Id, Case> relCases, Account a, String field) {
        if (relCases.get(inq.auctionId)?.Seller_Dealership__c != null) {
            if (relCases.get(inq.auctionId).Seller_Dealership__r?.get(field) != null) { //had to do this to get it to find the field we passed in as a string
                inq.assignedTo = String.valueOf(relCases.get(inq.auctionId).Seller_Dealership__r?.get(field)); //had to do this to get it to find the field we passed in as a string
            }
        }
        else {
            if (a?.get(field) != null) {
                inq.assignedTo = String.valueOf(a.get(field)); //had to do this to get it to find the field we passed in as a string
            }
        }
        return inq;
    }

    public class newCustInq { //object for inbound data
        public String uuid;
        public String auctionId;
        public String callBucket;
        public String callType;
        public String callNotes;
        public Boolean resolved;
        public String relatedAccount;
        public String relatedOpsCase;
        public String callBucketLabel;
        public String assignedTo;
        public String shouldAssignTo;
    }

    /**
     * Returns the accounts IST Account Owner if not null or DO NOT CALL
     * @param accountId     The account Id logged on Interaction
     * @return  `String`
     */
    @AuraEnabled
    public static String findOwner(Id accountId) {
        String inquiryOwner;
        Account acct = [SELECT Id, IST_Account_Owner__c, IST_Account_Owner__r.Name FROM Account WHERE Id = :accountId];
        if(acct.IST_Account_Owner__c == null || acct.IST_Account_Owner__r.Name == 'Do Not Call'){
            inquiryOwner = 'NO IST';
        }
        else {
            inquiryOwner = acct.IST_Account_Owner__c;
        }
        return inquiryOwner;
    }

    /**
     * Returns the most recent ops case for the selected auction if there is one
     * @param currentBucket     Selected call bucket for specific row of interaction
     * @param currentAuction    Auction for specific row of interaction
     * @return  `String`
     */
    @AuraEnabled
    public static String setOpsCase(String currentBucket, Id currentAuction) {
        String opsInfo;
        List<Case> opsCases = [SELECT Id, Status FROM Case WHERE RecordType.DeveloperName = :currentBucket AND Auction_Number__c = :currentAuction ORDER BY CreatedDate DESC LIMIT 1];
        if(opsCases.size() > 0){
            opsInfo = opsCases[0].Id;
        }
        else {
            opsInfo = null; //This means there is no ops Case of the selected Bucket
        }
        return opsInfo;
    }

    /**
     * Returns search results of contacts related to selected account
     * @param searchTerm        
     * @param selectedIds       If populated it is with the accountId selected on the Log An Interaction page       
     * @return  `List<LookupSearchResult>`
     */
    @AuraEnabled
    public static List<LookupSearchResult> getContacts(String searchTerm, List<String> selectedIds) {
        List<Contact> contactList = new List<Contact>();
        Map<Contact,Account> contactToAccount = new Map<Contact,Account>();
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        // Create and run SOSL query
        searchTerm += '*';
        String searchString = 'FIND \'' + searchTerm + '\'IN ALL FIELDS RETURNING Contact (Id)';
        contactList = Search.query(searchString)[0];
        Map<Id,Contact> contactMap = new Map<Id,Contact>(contactList);
        
        if (contactMap.size() > 0) {
            // Create SOQL query string depending on whether account has been entered
            Set<Id> contactIds = contactMap.keySet();
            String affiliationQueryString = 'SELECT Id, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Account__r.Name, Account__r.Dealership_Id__c FROM Affiliation__c WHERE Active__c = true AND Contact__c IN :contactIds';
            if (selectedIds.size() > 0) {
                affiliationQueryString += ' AND Account__c IN :selectedIds';
            }
            affiliationQueryString += ' LIMIT 10';
    
            for (Affiliation__c aff : Database.query(affiliationQueryString)) {
                contactToAccount.put(aff.Contact__r, aff.Account__r);
            }     
    
            // This will only run if our first query returned nothing
            // Meaning that there are no ACV User contacts of the search associated to this account
            // Now we will look for any Dealership Contacts with direct associations to the Account
            if (contactToAccount.isEmpty()) {
                String contactQueryString = 'SELECT Id, Name, Email, Phone, Account.Name, Account.Dealership_Id__c FROM Contact WHERE Active__c = true AND Id IN :contactIds AND RecordType.DeveloperName = \'Dealership_Contact\'';
                if (selectedIds.size() > 0) {
                    contactQueryString += ' AND AccountId IN :selectedIds';
                }
                contactQueryString += ' LIMIT 10';
                for (Contact con : Database.query(contactQueryString)) {
                    contactToAccount.put(con, con.Account);
                }    
            }
            
            for (Contact con : contactToAccount.keySet()) {
                String accountName =contactToAccount.get(con).Name;
                String dealerId = contactToAccount.get(con).Dealership_Id__c;
                String phoneStr = '';
                if (con.Phone != null) {
                    phoneStr = ' • ' + con.Phone;
                }
                results.add(new LookupSearchResult(con.Id, 'Contact', 'standard:contact', con.Name, accountName + ' • ' + dealerId + ' • ' + con.Email + phoneStr ));
            }
        }
        return results;
    }


    /**
     * Returns Accounts
     * @param searchTerm 
     * @return  `List<LookupSearchResult>`
     */
    @AuraEnabled
    public static List<LookupSearchResult> getAccounts(String searchTerm) {
        searchTerm += '*';

        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING Account (Id, Name, Dealership_Id__c, BillingCity, BillingState) LIMIT 10];
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        Account [] accountList = ((List<Account>) searchResults[0]);
        for (Account a : accountList) {
            results.add(new LookupSearchResult(a.Id, 'Account', 'standard:account', a.Name, a.Dealership_Id__c+ ' • ' + a.BillingCity + ' • ' + a.BillingState));
        }
        return results;
    }

    /**
     * Checks the status of the related ops case
     * @param opsCaseId     related ops case
     * @param callType      selected call type
     * @return  `String`
     */
    @AuraEnabled
    public static TitleWrapper checkTitle(Id opsCaseId) { //, String callType
        Case c = [SELECT Id, Status, Title_Absent__c, Seller_State__c, Payment_Status__c, Auction_Number__r.Name, T_A_Hold_Buyer__c, Auction_Number__r.Calendar_Days_Since_Auction_End__c, Title_Sent_Date__c FROM Case WHERE Id = :opsCaseId]; //CaseNumber, T_A_Hold_Buyer__c, Auction_Number__r.Calendar_Days_Since_Auction_End__c, Title_Sent_Date__c
        TitleWrapper tw = new TitleWrapper();
        tw.Status = c.Status;
        tw.AuctionNumber = c.Auction_Number__r.Name;
        tw.FortyEightHrEligible = true; //set true by default, can be changed in subsequent code. don't love this
        //return c.Status;
        //if (callType == '48 Hour Notice Request') { //this will always be null so i can't check it...
        User currentUser = [SELECT Id, UserRole.DeveloperName, Full_Name__c FROM User WHERE Id = :UserInfo.getUserId()];
        Set<String> paymentStatusSet = new Set<String>{'Paid', 'Deposited', 'Approved'};
        Set<String> titleStatusSet = new Set<String>{'New', 'Problem', 'Return to Seller', 'Closed Unwound'}; //, '48 Hour Notice' --> pulled out, this shouldn't be in this set i don't think since it's checking if the title can be put to that status
        
        if (currentUser.UserRole.DeveloperName != 'Titles_Manager' && currentUser.UserRole.DeveloperName != 'Customer_Success' && currentUser.Full_Name__c != 'Zachary Damon') {
            // Check to see if this VR on case will fire if Status changed to 48 Hour Notice: x48HourStatus_Validation_with_Title_NoCA
            if (c.Title_Absent__c == true && c.Seller_State__c != 'CA' && ((!paymentStatusSet.contains(c.Payment_Status__c) && c.T_A_Hold_Buyer__c == false) || !titleStatusSet.contains(c.Status) || c.Auction_Number__r.Calendar_Days_Since_Auction_End__c < 28 || c.Title_Sent_Date__c != null)) {
                //result = 'allowedCaseNumber:' + c.CaseNumber;
                tw.FortyEightHrEligible = false; //is this how i should do it? or should these be setting it to false? i think so...
            }
            // Check to see if this VR on case will fire if Status changed to 48 Hour Notice: x48HourStatus_Validation_with_Title_InCA
            else if (c.Title_Absent__c == true && c.Seller_State__c == 'CA' && ((!paymentStatusSet.contains(c.Payment_Status__c) && c.T_A_Hold_Buyer__c == false) || !titleStatusSet.contains(c.Status) || c.Auction_Number__r.Calendar_Days_Since_Auction_End__c < 43 || c.Title_Sent_Date__c != null)) {
                //result = 'allowedCaseNumber:' + c.CaseNumber;
                tw.FortyEightHrEligible = false;
            }
            // Check to see if this VR on case will fire if Status changed to 48 Hour Notice: x48HourStatus_Validation_No_Title
            else if (currentUser.Full_Name__c != 'Jared Impson' && c.Title_Absent__c == false && ((!paymentStatusSet.contains(c.Payment_Status__c) && c.T_A_Hold_Buyer__c == false) || !titleStatusSet.contains(c.Status) || c.Auction_Number__r.Calendar_Days_Since_Auction_End__c < 5 || c.Title_Sent_Date__c != null)) {
                //result = 'allowedCaseNumber:' + c.CaseNumber;
                tw.FortyEightHrEligible = false;
            }
        }
        //}
        return tw;
    }

    @TestVisible
    private class TitleWrapper {
        @AuraEnabled
        public String Status {get; set;}
        @AuraEnabled
        public Boolean FortyEightHrEligible {get; set;}
        @AuraEnabled
        public String AuctionNumber {get; set;}
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
        log.sfObject = 'Case';
        log.version = 'v1';
        log.componentName = 'LWC - CaseCreateUtility';
        log.location = 'CaseCreateUtilityController Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
}