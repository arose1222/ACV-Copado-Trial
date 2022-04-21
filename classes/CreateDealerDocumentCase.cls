public class CreateDealerDocumentCase {

    public static void runCaseCreate(Map<Id,sobject> inboundMap){
        Map<Id,Case> caseMap = (Map<Id,Case>)inboundMap;
        Id titleRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Set<Id> AccountIdSet = new Set<Id>();
        List<Case> targetCaseList = new List<Case>();
        for(Case c :caseMap.values()){
            //loop through all the cases we have, coming in, if we make a new titles case
            //add the accounts to the query set and add the case to a smaller list for later processing
            if(c.RecordTypeId == titleRTID){
            system.debug('first loop');
                AccountIdSet.add(c.AccountID);
                AccountIdSet.add(c.Seller_Dealership__c);
                targetCaseList.add(c);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>();
        Integer sellerCount = 0;
        for(Account a :[Select Id, Name,IST_Account_Owner__c,  Buyer_Compliance_Required__c, Reviewed_By_Compliance__c, Out_of_Document_Compliance__c from Account where Id in :AccountIdSet]){
            if(a.Buyer_Compliance_Required__c){
                sellerCount++;
            }
            accountMap.put(a.id,a);
        }
        system.debug(sellerCount);
        if(sellerCount > 0){
            Id complianceRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dealer Compliance').getRecordTypeId();
            //create set of eisting Document cases AccountIds so we can prevent making duplicates
            set<Id> accountIdSetWithActiveCases = new Set<id>();
            for(Case c : [select id, AccountId, isClosed from case where AccountId in :accountMap.keyset() AND recordTypeId = :complianceRTID]){
                //do not add closed cases (we will need new ones every so many years)
                if(!c.isClosed){
                    accountIdSetWithActiveCases.add(c.AccountID);
                }
            }

            List<Case> caseInsertList = new List<Case>();
            List<Group> queueList = [Select Id from Group where Type = 'Queue' and Name = 'Legal Review'];
            for(Case c :targetCaseList){
                if(accountMap.get(c.Seller_Dealership__c) != null && accountMap.get(c.AccountID) != null && accountMap.get(c.Seller_Dealership__c).Buyer_Compliance_Required__c && !accountMap.get(c.AccountID).Reviewed_By_Compliance__c && queueList.size() > 0){
                    //do we have an existing case of this type? if so we don't need that
                    if(!accountIdSetWithActiveCases.contains(c.AccountId)){
                        //create New Document Case
                        Case newComplianceCase = new Case();
                        newComplianceCase.RecordTypeId = complianceRTID;
                        if(!accountMap.get(c.AccountID).Reviewed_By_Compliance__c ){
                            newComplianceCase.OwnerId = accountMap.get(c.accountId).Out_of_Document_Compliance__c ? accountMap.get(c.AccountId).IST_Account_Owner__c : queueList[0].id;
                            newComplianceCase.Status = accountMap.get(c.accountId).Out_of_Document_Compliance__c ? 'IST Review' : 'Compliance Review';
                            newComplianceCase.AccountID = c.AccountId;
                            newComplianceCase.Seller_Dealership__c = c.Seller_Dealership__c;
                            newComplianceCase.Auction_Number__c = c.Auction_Number__c;
                            newComplianceCase.parentId = c.id;
                            newComplianceCase.subject = accountMap.get(c.AccountId).Name + ' - Document Review'; 
                            caseInsertList.add(newComplianceCase);
                            system.debug(newComplianceCase);
                        }
                        else if(accountMap.get(c.AccountID).Reviewed_By_Compliance__c && !accountMap.get(c.AccountID).Out_of_Document_Compliance__c){
                            //no need to create the case, move on to the next one
                            continue;
                        }
                    }
                }
            }
            //Inert the new Cases
            insert caseInsertList;
            //throw cases into approval processing
           List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest>();
            for(Case c :caseInsertList){
                Approval.ProcessSubmitRequest approval = new Approval.ProcessSubmitRequest();
                approval.setObjectID(c.id);
                approvalList.add(approval);
            }

            //set the reocrds to be in the process
            List<Approval.ProcessResult> resultList = Approval.Process(approvalList, FALSE);
            for(Approval.ProcessResult apr :resultList){
                if(apr.getErrors() != null){
                    //error handleing
                    system.debug(apr.getErrors());
                    throw new CustomException('Approval Error');
                }
            }
        }
    }

    public static void caseClosedLogic(Map<Id,sobject> inboundMap){
        Map<Id,Case> caseMap = (Map<Id,Case>)inboundMap;
        Id complianceRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dealer Compliance').getRecordTypeId();
        set<id> accountIdSet = new set<id>();
        Map<id,set<id>> sellerBuyerMap = new Map<Id,set<Id>>();
        set<id> caseNotificationSet = new set<id>();
        for(case c :caseMap.values()){
            if(c.recordTypeId == complianceRTID && c.isClosed){
                if(c.status == 'Closed(compliant)'){
                    accountIdSet.add(c.accountId);
                    if(sellerBuyerMap.get(c.Seller_Dealership__c) == null){
                        sellerBuyerMap.put(c.Seller_Dealership__c, New set<Id>());
                        sellerBuyerMap.get(c.Seller_Dealership__c).add(c.accountId);
                    }
                    else{
                        sellerBuyerMap.get(c.Seller_Dealership__c).add(c.accountId);
                    }
                    caseNotificationSet.add(c.parentID);
                }
            }
        }
        Map<Id,Account> accountUpdateMap = new Map<Id,Account>();
        for(Account a :[select id,Name, Reviewed_By_Compliance__c from account where id in :accountIdset]){
            if(accountUpdateMap.get(a.id) == null){
                a.Reviewed_By_Compliance__c = TRUE;
                accountUpdateMap.put(a.id,a);
            }
        }

        //Notify Case Title Owners that their cases can now be worked
        List<ChatterUtility.chatterWrapper> chatterList = new List<ChatterUtility.chatterWrapper>();
        List<Case> caseUpdateList = new List<Case>();
        Id titleRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        for(Case c :[Select id,Documentation_Case_Closed_Date__c, OwnerId,Seller_Dealership__c,AccountId from case where AccountId in :accountIdset and Seller_Dealership__c in :sellerBuyerMap.keySet() AND recordTypeId = :titleRTID]){
            if(sellerBuyerMap.get(c.Seller_Dealership__c) != null && sellerBuyerMap.get(c.Seller_Dealership__c).contains(c.accountId)){
                String message = 'This Title can now be processed';
                c.Documentation_Case_Closed_Date__c = System.Now();
                caseUpdateList.add(c);
                chatterList.add(new ChatterUtility.chatterWrapper(c.Id, message, c.OwnerId));
            }
        }

        if(accountUpdateMap.values().size()>0){
            update accountUpdateMap.values();
        }
        if(caseUpdateList.size() > 0){
            CaseUtility.toggleAlreadyProcessed();
            update caseUpdateList;
        }
        if(chatterList.size() > 0){
            ChatterUtility.mentionTextRecordPostBatch(chatterList);
        }
    }
}