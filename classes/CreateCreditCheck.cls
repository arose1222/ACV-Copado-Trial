public class CreateCreditCheck extends TriggerInterface {
    public static Set<String> checkPaymentTypes = new Set<String>{'ACV Issue Check'};
    public static Set<String> creditPaymentTypes = new Set<String>{'ACV Credit Assigned', 'ACV Credit Deduction'};
    
    public override void beforeInsert(List<SObject> newList) {
        List<Credits_Checks__c> newCreditCheckList = (List<Credits_Checks__c>) newList;
        List<Id> budgetIdList = new List<Id>();
        List<Id> updateApproverList = new List<Id>();
        List<String> dealerIdList = new List<String>();
        Map<Id,Account> dealerIdMap = new Map<Id,Account>();
        Map<Id,String> userMap = new Map<Id,String>();

        for(Credits_Checks__c c : newCreditCheckList){
            updateApproverList.add(c.OwnerId);
            dealerIdList.add(c.Dealer__c);
            if(c.Budget_Name__c != null){
                budgetIdList.add(c.Budget_Name__c);
            }
        }        
        for(Account a : [SELECT Id, Dealership_ID__c, Organization_Credit_Id__c FROM Account WHERE Id IN: dealerIdList]){
            dealerIdMap.put(a.Id, a);
        }
        for(User u : [SELECT Id, Id__c FROM User WHERE CaseSafe_Id__c IN:updateApproverList]){
            userMap.put(u.Id, u.Id__c);
        }

        for(Credits_Checks__c c : newCreditCheckList){
            c.Dealership_ID__c = dealerIdMap.get(c.Dealer__c).Dealership_ID__c;
            c.Organization_Credit_Id__c = dealerIdMap.get(c.Dealer__c).Organization_Credit_Id__c;
        }

        if(budgetIdList.size()>0){
            Map<Id,Budget__c> budgetMap = new Map<Id,Budget__c>([SELECT Id, Current_Balance__c, Name FROM Budget__c WHERE Id IN :budgetIdList]);
            List<Salesforce_Setting__mdt> defaultArbUserMetadata = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Arb_Credit_Check_ACV_User'];
            List<User> defaultArbUser = new List<User>();
            if( defaultArbUserMetadata.size() > 0 ) defaultArbUser = [ SELECT Id, Id__c FROM User WHERE UserName like :defaultArbUserMetadata[0].Value__c LIMIT 1 ];
            for(Credits_Checks__c c : newCreditCheckList){
                //Amount is under 500, Budget exists, and Amount is under Current Balance of Budget
                if(c.Amount_Requested__c < 0 && budgetMap.get(c.Budget_Name__c) != null && c.Amount_Requested__c < budgetMap.get(c.Budget_Name__c).Current_Balance__c){
                    c.Approval_Status__c = 'Approved';
                    c.Approval_Denial_Date__c = System.now();
                    c.Amount_Approved__c = c.Amount_Requested__c;
                    c.Approved_By__c = c.OwnerId;
                    c.ACV_User_Id__c = userMap.get(c.OwnerId);
                }
                // auto approve if from arbitration resolution
                // else if(budgetMap.get(c.Budget_Name__c).Name == 'Arbitration' || (budgetMap.get(c.Budget_Name__c).Name == 'Marketing' && c.Approval_Status__c == 'Approved' ) ){
                else if( budgetMap.get(c.Budget_Name__c).Name == 'Marketing' && c.Approval_Status__c == 'Approved'  ){
                    c.Approval_Status__c = 'Approved';
                    c.Approval_Denial_Date__c = System.now();
                    c.Amount_Approved__c = c.Amount_Requested__c;
                    // if( budgetMap.get(c.Budget_Name__c).Name == 'Arbitration' && defaultArbUserMetadata.size() > 0 && defaultArbUser.size() > 0 ){
                    //     c.Approved_By__c = defaultArbUser[0].Id;
                    //     c.ACV_User_Id__c = defaultArbUser[0].Id__c;
                    // }else{
                    c.Approved_By__c = c.OwnerId;
                    c.ACV_User_Id__c = userMap.get(c.OwnerId);
                    // }
                }
            }
        }
    }

    //***********************************************************************

    public override void afterInsert(List<SObject> newList) {
        List<Credits_Checks__c> newCreditCheckList = (List<Credits_Checks__c>) newList;
        List<Id> budgetIdList = new List<Id>();
        List<Credits_Checks__c> creditCheckInsertList = new List<Credits_Checks__c>();
        List<Id> listToSend = new List<Id>();
        List<Budget__c> budgetsToUpdate = new List<Budget__c>();

        for(Credits_Checks__c c : newCreditCheckList){
            if(c.Budget_Name__c != null){
                budgetIdList.add(c.Budget_Name__c);
            }
        }
        if(budgetIdList.size()>0){
            Map<Id,Budget__c> budgetMap = new Map<Id,Budget__c>([SELECT Id, Current_Balance__c, Name, Limitless_Budget__c FROM Budget__c WHERE Id IN :budgetIdList]);
            List<Credits_Checks__c> checksToProcess = new List<Credits_Checks__c>();
            for(Credits_Checks__c c : newCreditCheckList){
                if( c.Approval_Status__c == 'Done Successful'){
                    continue;
                }
                // auto send if from arbitration resolution
                // if( budgetMap.get(c.Budget_Name__c).Name == 'Arbitration' && creditPaymentTypes.contains(c.Payment_Type__c) ){
                //     System.debug('Inside budget name = Arb');
                //     listToSend.add(c.Id);
                // }
                // else {
                // if(budgetMap.get(c.Budget_Name__c).Name == 'Arbitration'){
                //     continue;
                // }
                // If Amount is over 0 or Current Balance of Budget - then go to approval
                /*else*/ if( c.Approval_Status__c != 'Approved' && (c.Amount_Requested__c > 0 || c.Amount_Requested__c > budgetMap.get(c.Budget_Name__c).Current_Balance__c) ){
                    creditCheckInsertList.add(c);
                }
                else if( creditPaymentTypes.contains(c.Payment_Type__c) && c.Approval_Status__c == 'Approved' && budgetMap.get(c.Budget_Name__c).Limitless_Budget__c ){
                    listToSend.add(c.Id);
                }
                else if( creditPaymentTypes.contains(c.Payment_Type__c) && c.Approval_Status__c == 'Approved' && !budgetMap.get(c.Budget_Name__c).Limitless_Budget__c ){
                    c.addError( 'Only Limitless budgets are allowed to insert Approved records.' );
                }
                // }
                if( checkPaymentTypes.contains(c.Payment_Type__c) && c.Approval_Status__c == 'Approved' ){
                    checksToProcess.add(c);
                }
            }
            if( checksToProcess.size() > 0 ){
                budgetsToUpdate = checkBudgetUpdates( budgetMap, checksToProcess );
            }
        }
        // Arb Cases can only close from Arb team.
        // Arb team has no Budget
        // Only check f amount is over 500
        // else if(budgetIdList.isEmpty()){
        //     for(Credits_Checks__c c : newCreditCheckList){
        //         if(c.Amount_Requested__c > 500){
        //             creditCheckInsertList.add(c);
        //         }
        //         else if(c.Payment_Type__c == 'ACV Credit Assigned' || c.Payment_Type__c == 'ACV Credit Deduction'){
        //             listToSend.add(c.Id);
        //         }     
        //     }
        // }
        if(creditCheckInsertList.size()>0){
            List<Approval.ProcessSubmitRequest> approvalList = new List<Approval.ProcessSubmitRequest>();
            for(Credits_Checks__c c :creditCheckInsertList){
                Approval.ProcessSubmitRequest approval = new Approval.ProcessSubmitRequest();
                approval.setObjectID(c.id);
                approvalList.add(approval);
            }
            //set the records to be in the process
            List<Approval.ProcessResult> resultList = Approval.Process(approvalList, FALSE);
            for(Approval.ProcessResult apr :resultList){
                if(apr.getErrors() != null){
                    System.debug(apr.getErrors());
                    throw new CustomException('Approval Error');
                }
            }
        }
        if(listToSend.size()>0){
            CreditCallout.getCredit(listToSend);
        }
        if( budgetsToUpdate.size() > 0 ){
            update budgetsToUpdate;
        }
    }

    //***********************************************************************
    public override void beforeUpdate(List<SObject> oldMap, List<SObject> newMap) {
        Map<Id,Credits_Checks__c> oldCreditCheckMap = new Map<Id,Credits_Checks__c>((List<Credits_Checks__c>) oldMap);
        Map<Id,Credits_Checks__c> newCreditCheckMap = new Map<Id,Credits_Checks__c>((List<Credits_Checks__c>) newMap);
        Set<Id> budgetIds = new Set<Id>();
        List<Credits_Checks__c> approvedCredits = new List<Credits_Checks__c>();
        Map<Id, Decimal> budgetIdToAmountApprovedMap = new Map<Id, Decimal>();
        //If approved, we need to check if money is left in the balance
        for(Credits_Checks__c c : newCreditCheckMap.values()){
            if(c.Approval_Status__c == 'Approved' && oldCreditCheckMap.get(c.Id).Approval_Status__c != c.Approval_Status__c){
                if( c.Budget_Name__c != null ){
                    budgetIds.add(c.Budget_Name__c);
                    if( budgetIdToAmountApprovedMap.get(c.Budget_Name__c) == null ) budgetIdToAmountApprovedMap.put(c.Budget_Name__c, 0);
                    budgetIdToAmountApprovedMap.put( c.Budget_Name__c, budgetIdToAmountApprovedMap.get(c.Budget_Name__c) + c.Amount_Approved__c );
                }
                approvedCredits.add(c);
            }
            else if(c.Approval_Status__c == 'Rejected' && oldCreditCheckMap.get(c.Id).Approval_Status__c != c.Approval_Status__c){
                if(c.Approval_Denial_Date__c == null){
                    c.Approval_Denial_Date__c = System.now();
                }
            }
        }
        if( budgetIds.size() == 0 ) return;
        Map<Id, Budget__c> budgetMap = new Map<Id, Budget__c>([ SELECT Id, Name, Limitless_Budget__c, Current_Balance__c FROM Budget__c WHERE Id IN :budgetIds ]);
        for( Credits_Checks__c cc : approvedCredits ){
            if( budgetMap.get(cc.Budget_Name__c).Limitless_Budget__c || budgetMap.get(cc.Budget_Name__c).Current_Balance__c >= budgetIdToAmountApprovedMap.get(cc.Budget_Name__c) ){
                if(cc.Approval_Denial_Date__c == null){
                    cc.Approval_Denial_Date__c = System.now();
                }
            }else{
                cc.addError( budgetMap.get(cc.Budget_Name__c).Name + ' does not have the funds to approve this request.' );
            }
        }
    }

    public override void afterUpdate(List<SObject> oldMap, List<SObject> newMap) {
        Map<Id,Credits_Checks__c> oldCreditCheckMap = new Map<Id,Credits_Checks__c>((List<Credits_Checks__c>) oldMap);
        Map<Id,Credits_Checks__c> newCreditCheckMap = new Map<Id,Credits_Checks__c>((List<Credits_Checks__c>) newMap);
        List<Id> listToSend = new List<Id>();
        Set<Id> budgetIdSet = new Set<Id>();
        List<Credits_Checks__c> checksToProcess = new List<Credits_Checks__c>();
        List<Budget__c> budgetsToUpdate = new List<Budget__c>();

        for(Credits_Checks__c c : newCreditCheckMap.values()){
            if(c.Approval_Status__c == 'Approved' && c.Credit_Id__c == null && creditPaymentTypes.contains(c.Payment_Type__c) ){
                listToSend.add(c.Id);
            }
            if( c.Budget_Name__c != null && (checkPaymentTypes.contains(c.Payment_Type__c) || c.Payment_Type__c == 'Debt Forgiveness') && c.Approval_Status__c == 'Approved' && ((Credits_Checks__c)oldCreditCheckMap.get(c.Id)).Approval_Status__c != 'Approved' ){
                budgetIdSet.add(c.Budget_Name__c);
                checksToProcess.add(c);
            }
        }

        if(listToSend.size()>0){
            CreditCallout.getCredit(listToSend);
        }

        if( budgetIdSet.size() > 0 ){
            Map<Id,Budget__c> budgetMap = new Map<Id,Budget__c>([SELECT Id, Current_Balance__c, Name FROM Budget__c WHERE Id IN :budgetIdSet]);
            budgetsToUpdate = checkBudgetUpdates( budgetMap, checksToProcess );
        }
        if(budgetsToUpdate.size() > 0 ){
            update budgetsToUpdate;
        }
    }

    private List<Budget__c> checkBudgetUpdates( Map<Id,Budget__c> budgetMap, List<Credits_Checks__c> checksToProcess ){
        List<Budget__c> budgetsToUpdate = new List<Budget__c>();
        for( Credits_Checks__c c : checksToProcess ){
            Budget__c b = budgetMap.get(c.Budget_Name__c);
            b.Current_Balance__c = b.Current_Balance__c - c.Amount_Approved__c;
        }
        return budgetMap.values();
    }
}