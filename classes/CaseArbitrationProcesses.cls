public class CaseArbitrationProcesses {
    private static boolean beforeInsertProcessed = false;
    private static boolean afterInsertProcessed = false;
    private static boolean beforeUpdateProcessed = false;
    private static boolean afterUpdateProcessed = false;
    private static Id arbitrationClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();

    public static void beforeInsert(List<Case> newCaseList){
        if(beforeInsertProcessed == false){
            List<Case> filteredList = filter(newCaseList);

            if(filteredList.size() > 0){
                beforeInsertProcessed = true;
                System.debug('Before Insert processes for Arb Cases executed');
            }
        } else{
            System.debug('Recursion on Before Insert on Arb Cases blocked. Use ArbitrationCaseProcesses.beforeInsertToggle() to step in.');
        }        
    }

    public static void afterInsert(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(afterInsertProcessed == false){
            //This is particular process builder is for 'Standard' record type but relates to Arb's
            arbDenialChildCaseClosed((Map<Id,Case>)newCaseMap, (Map<Id,Case>)oldCaseMap);

            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                afterInsertProcessed = true;
                //arbDenialProcessEntry(filteredMap);
                arbCreateCreditProcess(filteredMap, null);
                calculateArbsRollup(filteredMap, (Map<Id,Case>)oldCaseMap);
                System.debug('After Insert processes for Arb Cases executed');
            }

        } else{
            System.debug('Recursion on After Insert on Arb Cases blocked. Use ArbitrationCaseProcesses.afterInsertToggle() to step in.');
        }
    }

    public static void beforeUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(beforeUpdateProcessed == false){
            List<Case> casesToProcess = new List<Case>();
            for( Case c : (List<Case>)newCaseMap.values() ){
                if( c.RecordTypeId == arbitrationClaimRecordTypeId && c.Status != ((Case)oldCaseMap.get(c.Id)).Status && c.Status == 'Closed' ){
                    casesToProcess.add(c);
                }
            }
            if( casesToProcess.size() > 0 ) limitCaseClose(casesToProcess);

            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                beforeUpdateProcessed = true;
                dateTimeStamp(filteredMap, (Map<Id,Case>)oldcasemap);
                System.debug('Before Update processes for Arb Cases executed.');
            }
        } else{
            System.debug('Recursion on Before Update on Arb Cases blocked. Use ArbitrationCaseProcesses.beforeUpdateToggle() to step in.');
        }
    }

    public static void afterUpdate(Map<Id,SObject> newCaseMap, Map<Id,SObject> oldCaseMap){
        if(afterUpdateProcessed == false){
            //This is particular process builder is for 'Standard' record type but relates to Arb's
            arbDenialChildCaseClosed((Map<Id,Case>)newCaseMap, (Map<Id,Case>)oldCaseMap);

            Map<Id,Case> filteredMap = filter((Map<Id,Case>) newCaseMap);
            if(filteredMap.size() > 0){
                afterUpdateProcessed = true;
                syncBuyersAssurance(filteredMap, (Map<Id,Case>)oldCaseMap);
                //arbDenialProcessEntry(filteredMap);
                arbCreateCreditProcess(filteredMap,(Map<Id,Case>)oldCaseMap);
                calculateArbsRollup(filteredMap, (Map<Id,Case>)oldCaseMap);
                System.debug('After Update processes for Arb Cases executed');
            }
        } else{
            System.debug('Recursion on Before Update on Arb Cases blocked. Use ArbitrationCaseProcesses.afterUpdateToggle() to step in.');
        }
    }

    //Process Arbitration Denial Aprproval Process Entry ...Triggers the Denial Approval Flow.. DONE
    /**
     * arbDenialProcessEntry 
     *   GIVEN A Case with Record Type 'Arbitration Claim'
     *   AND the Status is equal to 'Denial Pending'
     *   WHEN the Case is inserted or updated
     *   THEN Submit the Case to Arbitration Denial approval process
     *
     * @param  newCaseMap 
     */

    //Commented out 2/3/20 to remove status of Denial Pending
    // public static void arbDenialProcessEntry (Map<Id,Case> newCaseMap ){
    //     List<approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest>();

    //     for(Case c :newCaseMap.values() ){
    //         if(c.status == 'Denial Pending'){
    //             Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
    //             req1.setObjectID(c.Id);
    //             req1.setSubmitterId(UserInfo.getUserId());
    //             req1.setSkipEntryCriteria(true);
    //             approvalList.add(req1);
    //         }
    //     }

    //     if(approvalList.size()>0){
    //         List<Approval.ProcessResult> resultList = Approval.Process(approvalList);
    //         for(Approval.ProcessResult apr :resultList){
    //             if(apr.getErrors() != null){
    //                 system.debug(apr.getErrors());
    //                 throw new CustomException('Approval Error');
    //             }
    //         }
    //     }
    // }

    
    public static void limitCaseClose(List<Case> caseList){
        Boolean arbMember = false;
        for(GroupMember g: [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId =:UserInfo.getUserId()]){
            if(g.Group.Name == 'Arbitration'){
                arbMember = true;
                break;
            }
        }
        if(arbMember == false){
            for( Case c : caseList ){
                c.addError( 'Non-Arb team member cannot close Arb Case' );
            }
        }
    }
    public static void arbCreateCreditProcess( Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap ){
        Map<Id, Case> filteredCaseMap = new Map<Id,Case>();
        for( Case c : newCaseMap.values() ){
            if( c.Status == 'Closed' && (oldCaseMap == null || (oldCaseMap != null && c.Status != oldCaseMap.get(c.Id).Status)) ){
                filteredCaseMap.put(c.Id,c);
            }
        }
        if( filteredCaseMap.size() > 0 ) arbCreateCreditProcess(filteredCaseMap);
    }
    //Process Arbitration - Create Credit/Check Object
    /**
     * GIVEN case with record type Arb
     * AND case has complaint(s)
     * AND complaint(s) have at least one resolution each
     * AND resolution(s) don't already have related credit/check.  <-Will need to create lookup-field first to check
     * AND case status changed to CLOSED
     * THEN create credit/check for each resolution
     */
    public static void arbCreateCreditProcess (Map<Id,Case> newCaseMap ){

        //****************** Find Budget associated ******************************
        // Retrieve Budget associated to Users' Groups, which in this case should only be Arbitration Team
        String groupName = 'Arbitration';
        String resBudgetId = '';
        if(groupName != ''){
            List<Budget__c> budgetIdList = [SELECT Id FROM Budget__c WHERE Name=:groupName];
            if(budgetIdList.size()>0){
                System.debug('budgetIdList: ' + budgetIdList[0].Id);
                resBudgetId = budgetIdList[0].Id;
            }
        }
        //************************************************************************
        // Complaints have a field for their related case "arbitration_id__r"
        // For each complaint and each resolution related to that complaint:
        List<Credits_Checks__c> credListToMake = new List<Credits_Checks__c>();
        List<Credits_Checks__c> invListToMake = new List<Credits_Checks__c>();
        List<Resolution__c> resListToUpdate = new List<Resolution__c>();
        Id invoiceId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get('Invoice').getRecordTypeId();
        Id creditId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get('Credit').getRecordTypeId();
        Id checkId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get('Check').getRecordTypeId();
        List<GroupMember> gmList = [ SELECT Id FROM GroupMember WHERE Group.Name = 'Arbitration' AND UserOrGroupId = :UserInfo.getUserId() ];
        if(gmList.size() == 0){
            List<Integration_Result__c> irList = new List<Integration_Result__c>();
            for( Case c : newCaseMap.values() ){
                Integration_Result__c ir = new Integration_Result__c();
                ir.recordId__c = c.Id;
                ir.Integration_Name__c = 'Create Credit/Check on Arb Failed';
                ir.Sobject_name__c = 'Case';
                ir.Integration_Type__c = 'Internal';
                ir.Status_Message__c = 'An Arbitration Case has been closed but the user who closed the Case was not apart of the Public Group "Arbitration" which indicates the only users that can close Arbitration Casses';
                irList.add(ir);
            }
            if (irList.size() > 0 ) insert irList;
            return;
        }
        List<Salesforce_Setting__mdt> expirationDateDefault = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Credit_Expiration_Day' ];
        for (Complaint__c currentComplaint : [SELECT Id, arbitration_id__r.Status, arbitration_id__r.AccountId, arbitration_id__r.Seller_Dealership__c, arbitration_id__r.Auction_Number__c,arbitration_id__c, (SELECT Id, Amount__c, Resolution__c, description__c, Avoidable_Complaint__c, Goodwill__c, Case__c, Credit_Check_Created__c, Post_Close_Resolution__c, Total_with_Fees__c FROM Resolutions__r) FROM Complaint__c WHERE arbitration_id__c IN :newCaseMap.keySet()]){
            if(currentComplaint.arbitration_id__c != null && currentComplaint.arbitration_id__r.Status == 'Closed'){
                for(Resolution__c resolution : currentComplaint.Resolutions__r){
                    if(resolution.Credit_Check_Created__c == false){
                        String rootCause = '';
                        if(resolution.Avoidable_Complaint__c == true){
                            rootCause = 'Arbitration avoidable';
                        }else{rootCause = 'Arbitration unavoidable';}
                        
                        Credits_Checks__c newCreditCheck = new Credits_Checks__c();
                        
                        
                        // This needs to create two records: one Invoice for seller and one Check for buyer
                        if(resolution.Resolution__c == 'Seller Issue Check'){ 
                            newCreditCheck.RecordTypeId = checkId;

                            Credits_Checks__c invoiceRecord = new Credits_Checks__c();
                            invoiceRecord.RecordTypeId = invoiceId;
                            if(currentComplaint.arbitration_id__r.Seller_Dealership__c != null){
                                invoiceRecord.Dealer__c = currentComplaint.arbitration_id__r.Seller_Dealership__c;         // Seller Dealer
                            }
                            //invoiceRecord.Amount_Requested__c = resolution.Amount__c;                                      // Amount
                            invoiceRecord.Amount_Requested__c = resolution.Total_with_Fees__c;  						   //Adjusted Amount - Rob
                            invoiceRecord.Total_Arb_Amount_Requested__c = resolution.Total_with_Fees__c;						   // Arb Amount - Rob
                            invoiceRecord.Reason__c = 'Arbitration';                                                       // Arbitration
                            invoiceRecord.Root_Cause__c = rootCause;                                                       // Avoidable/Unavoidable
                            invoiceRecord.Case__c = resolution.Case__c;                                                    // Case Id
                            invoiceRecord.Applicable_To__c = 'ACV Fees';                                                   // Applicable to
                            invoiceRecord.Approval_Status__c = 'Submitted';                                                // Approval Status
                            invoiceRecord.Resolution__c = resolution.Id;                                                   // Resolution Id
                            if(currentComplaint.arbitration_id__r.Auction_Number__c != null){
                                invoiceRecord.Auction__c = currentComplaint.arbitration_id__r.Auction_Number__c;               // Auction Id
                            }
                            invoiceRecord.Explanation__c = resolution.description__c;                                      // Explanation Notes
                            invoiceRecord.Payment_Type__c = resolution.Resolution__c;                                      // Seller Issue Check, ACV Credit Assigned, ACV Issued Check, ACV Credit Deduction
                            if(resBudgetId != ''){
                                invoiceRecord.Budget_Name__c = resBudgetId;                                                // Associated Budget
                            }
                            invListToMake.add(invoiceRecord);
                        }
                        else if(resolution.Resolution__c == 'ACV Credit Assigned' || resolution.Resolution__c == 'ACV Credit Deduction'){
                            newCreditCheck.RecordTypeId = creditId;
                            newCreditCheck.Expiration_Date__c = Date.Today().addDays( Integer.valueOf(expirationDateDefault[0].Value__c) - 1 );
                        }
                        else if(resolution.Resolution__c == 'ACV Issue Check'){
                            newCreditCheck.RecordTypeId = checkId;
                        }


                        if(resolution.Resolution__c == 'ACV Credit Assigned' || resolution.Resolution__c == 'ACV Credit Deduction' || resolution.Resolution__c == 'ACV Issue Check' || resolution.Resolution__c == 'Seller Issue Check'){
                            if(currentComplaint.arbitration_id__r.AccountId != null){
                                newCreditCheck.Dealer__c = currentComplaint.arbitration_id__r.AccountId;                    // Some Dealer
                            }
                            newCreditCheck.Amount_Requested__c = resolution.Total_with_Fees__c ;                            // Amount
                            newCreditCheck.Total_Arb_Amount_Requested__c = resolution.Total_with_Fees__c ;					    //Arb Amount decimal - Rob
                            newCreditCheck.Reason__c = 'Arbitration';                                                       // Arbitration
                            newCreditCheck.Root_Cause__c = rootCause;                                                       // Avoidable/Unavoidable
                            newCreditCheck.Case__c = resolution.Case__c;                                                    // Case Id
                            newCreditCheck.Applicable_To__c = 'ACV Fees';                                                   // Applicable To
                            newCreditCheck.Approval_Status__c = 'Submitted';                                                // Credit Approval Status
                            newCreditCheck.Resolution__c = resolution.Id;                                                   // Resolution Id
                            if(currentComplaint.arbitration_id__r.Auction_Number__c != null){
                            newCreditCheck.Auction__c = currentComplaint.arbitration_id__r.Auction_Number__c;               // Auction Id
                            }
                            newCreditCheck.Explanation__c = resolution.description__c;                                      // Explanation Notes
                            newCreditCheck.Payment_Type__c = resolution.Resolution__c;                                      // Seller Issue Check, ACV Credit Assigned, ACV Issued Check, ACV Credit Deduction
                            if(resBudgetId != ''){
                                newCreditCheck.Budget_Name__c = resBudgetId;
                            }
                            credListToMake.add(newCreditCheck);
                        }

                        resolution.Credit_Check_Created__c = true;
                        resListToUpdate.add(resolution);
                    }
                }
            }
        }
        
        if(invListToMake.size()>0){
            try{
                insert invListToMake;
            }
            catch(DmlException e){
                System.debug('An error has occurred: ' + e.getMessage());
            }
        }
        if(credListToMake.size()>0){
            try{
                insert credListToMake;
            }
            catch(DmlException e){
                System.debug('An error has occurred: ' + e.getMessage());
            }
        }
        if(resListToUpdate.size()>0){
            update resListToUpdate;
        }
    }

    /** 
     * Process Builder - Arb Denial - Indicate on Parent Case when Child Case is Closed
     * arbDenialChildCaseClosed 
     *   GIVEN that Case type is 'Arbitration Denial'
     *   AND Case RecordType is 'Standard'
     *   AND Case Status is 'Closed'
     *   WHEN Case Status is changed 
     *   THEN Update the Parent Case, 'Arb Denial Child Case Closed' to be true
     *
     * @param  newCaseMap - new values, key is id of case and value is Case object with that id 
     * @param  oldcasemap - old values, key is id of case and value is Case object with that id 
     */
    public static void arbDenialChildCaseClosed(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        Id supportRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();
        Set<Id> caseIdSet = new Set<Id>();

        //Build set of Parent Cases that should be updated
        for(Case c: newCaseMap.values()){
            if(c.ParentId != null && c.Type == 'Arbitration Denial' && c.RecordTypeId == supportRecordType && c.isClosed == True && c.Status != oldCaseMap.get(c.Id).Status){
                caseIdSet.add(c.ParentId);
            }
        }

        if(caseIdSet.isEmpty()){
            return;
        }

        List<Case> lCases = new List<Case>();

        for(Id cId : caseIdSet){
            lCases.add(new Case(Id = cId, Arb_Denial_Child_Case_CLosed__c = true));
        }

        if(lCases.size() > 0){
            update lCases;
        }
    }

    //Process: Sync Buyers  Assurance Exceptions -DONE
    /**
     * syncBuyersAssurance 
     *   GIVEN Arbitration Case with Related Account
     *   AND Buyer's Assurance Exception on the Case differs from the related Account
     *   WHEN Buyer's Assurance Exception on Case is changed
     *   THEN Update the Account's Buyer's Assurance Exception to match the Case's
     *
     * @param  newcaseMap 
     * @param  oldcaseMap
     */
    public static void  syncBuyersAssurance (Map<id, case> newcaseMap, Map<id, case> oldcaseMap){
        set<id> accIDSet = new set <id> ();
        List<Account> acc2update = new List<Account>();
        for(Case c: newcaseMap.values()){
            accIDSet.add(c.accountid);
        }
        accIDSet.remove(null);

        if(accIDSet.isEmpty()){
            return;
        }

        Map<Id,Account> accMap = new Map<Id,Account> ([Select id, Buyer_s_assurance_exceptions__C from account where id in : accIDSet ]);
        for (Case c :newcaseMap.values()){
            if(c.buyer_s_assurance_exceptions__C != null && 
               c.buyer_s_assurance_exceptions__C != oldcaseMap.get(c.Id).buyer_s_assurance_exceptions__c && 
               c.buyer_s_assurance_exceptions__C != accMap.get(c.AccountId).buyer_s_assurance_exceptions__C){
                    acc2update.add(new Account(Id = c.AccountId, buyer_s_assurance_exceptions__C = c.buyer_s_assurance_exceptions__C));   
            }
        }

        if(acc2update.size() > 0){
            update acc2update;
            System.Debug('syncBuyersAssurance: Account\'s Updated');
        }
    }
    /**
     * dateTimeStamp 
     * process name: Date/Time Stamp on Case Reviews
     *   GIVEN An Arbitration Claim
     *   AND Status is 'Under Review'
     *   WHEN Status is changed 
     *   THEN update 'Date_Time_Case_Status_Under_Review__c' with current time
     * 
     *   Repeat for 'Reviewed' and 'Denial Pending'
     *
     *
     * @param  newCaseMap - new values, key is id of case and value is Case object with that id 
     * @param  oldcasemap - old values, key is id of case and value is Case object with that id 
     */
    public static void dateTimeStamp( Map<Id, Case> newCaseMap, Map<Id, Case> oldcasemap){
        for(Id caseId :newCaseMap.keySet()){ 
            if( newCaseMap.get(caseID).status != null && newCaseMap.get(caseID).Status != oldCaseMap.get(caseID).status){
                if((newCaseMap.get(caseId).Date_Time_Case_Status_Under_Review__c == null) && newcaseMap.get(caseID).Status== 'Under Review' ){
                    newCaseMap.get(caseId).Date_Time_Case_Status_Under_Review__c =  datetime.valueOf(system.NOW());  
                }
                if((newCaseMap.get(caseId).Date_Time_Case_Status_Reviewed__c == null) && newcaseMap.get(caseID).Status== 'Reviewed' ){  
                    newCaseMap.get(caseId).Date_Time_Case_Status_Reviewed__c = datetime.valueOf(system.NOW());  
                }
                // if((newCaseMap.get(caseId).Date_Time_Case_Denial_Enters_Pending__c == null) && newcaseMap.get(caseID).Status== 'Denial Pending' ){
                //     newCaseMap.get(caseId).Date_Time_Case_Denial_Enters_Pending__c = datetime.valueOf(system.NOW());  
                // }
            }
        }
    }
	
     /**
     * calculateArbsRollup 
     * process name: Calculate Arbs Roll Up
     *   GIVEN An Arbitration Claim
     *   AND Status is 'New'
     * 	 OR IsClosed value changed
     * 	 OR the related Auction_Number__c changed
     *   WHEN Case is updated or Inserted
     *   THEN recalculate both Open and Closed Arbitration Cases for the Auction
     * 	 AND update the related Auctions
     *
     * @param  newCaseMap - new values, key is id of case and value is Case object with that id 
     * @param  oldcasemap - old values, key is id of case and value is Case object with that id 
     */
    public static void calculateArbsRollup(Map<Id,Case> newCaseMap, Map<Id,Case> oldCaseMap){
        Set<Id> sArbAuctionIds = new Set<Id>();

        Map<Id,Profile> userProfiles = new Map<Id,Profile>([SELECT Id, Name FROM Profile]);
        for (Case newCase : newCaseMap.values()) {
            // Add if the case get's updated to be closed and has auction number
            if (newCase.Auction_Number__c != null && oldCaseMap != null && oldCaseMap.get(newCase.Id) != null && (newCase.IsClosed != oldCaseMap.get(newCase.Id).IsClosed || newCase.Auction_Number__c != oldCaseMap.get(newCase.Id).Auction_Number__c)) {
                sArbAuctionIds.add(newCase.Auction_Number__c);
            }
            // Ensure that when a  new Case is created that it evaluates the arb roll up 
            else if (newCase.Status == 'New' && newCase.Auction_Number__c != null) {
                sArbAuctionIds.add(newCase.Auction_Number__c);
            }
        }

        if (sArbAuctionIds.size() > 0) {
            Map<Id,Auction__c> updateAuctionMap = new Map<Id,Auction__c>();

            // Grab all arb cases for Auctions
            for (Case arbCaseResult : [SELECT Id,IsClosed, Auction_Number__c FROM Case WHERE Auction_Number__c IN :sArbAuctionIds AND RecordTypeId = :arbitrationClaimRecordTypeId ]) {
                // Initialize the arb case counts if they haven't been added to the map yet
                if (updateAuctionMap.get(arbCaseResult.Auction_Number__c) == null) {
                    updateAuctionMap.put(arbCaseResult.Auction_Number__c, new Auction__c( Id=arbCaseResult.Auction_Number__c, Closed_Arbitration_Cases__c = 0, Open_Arbitration_Cases__c = 0));
                }

                // Increment values based on the Closed status
                if (arbCaseResult.IsClosed) {
                    updateAuctionMap.get(arbCaseResult.Auction_Number__c).Closed_Arbitration_Cases__c += 1;
                } else {
System.debug('COUNT INCREMENTED');
                    updateAuctionMap.get(arbCaseResult.Auction_Number__c).Open_Arbitration_Cases__c += 1;
                }
            }
            //Update auctions
            if(updateAuctionMap.size() > 0){
                update updateAuctionMap.values();
            }
        }
    }

    public static Map<Id,Case> filter(Map<Id,Case> newCaseMap){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Map<Id,Case> filteredMap = new Map<Id,Case>();

        for(Case c : newCaseMap.values()){
            if(c.RecordTypeId == arbRecordType){
                filteredMap.put(c.Id,c);
            }
        }

        return filteredMap;
    }

    public static List<Case> filter(List<Case> newCaseList){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        List<Case> filteredList = new List<Case>();

        for(Case c : newCaseList){
            if(c.RecordTypeId == arbRecordType){
                filteredList.add(c);
            }
        }

        return filteredList;
    }

    public static void beforeInsertToggle(){
        beforeInsertProcessed = !beforeInsertProcessed;
    }
    public static void beforeInsertToggle(Boolean foo){
        beforeInsertProcessed = foo;
    }

    public static void afterInsertToggle(){
        afterInsertProcessed = !afterInsertProcessed;
    }
    public static void afterInsertToggle(Boolean foo){
        afterInsertProcessed = foo;
    }

    public static void beforeUpdateToggle(){
        beforeUpdateProcessed = !beforeUpdateProcessed;
    }
    public static void beforeUpdateToggle(Boolean foo){
        beforeUpdateProcessed = foo;
    }

    public static void afterUpdateToggle(){
        afterUpdateProcessed = !afterUpdateProcessed;
    }
    public static void afterUpdateToggle(Boolean foo){
        afterUpdateProcessed = foo;
    }
}