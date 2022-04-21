public class CreditCheckController {
    
    //******** Custom wrapper for returning dealerships and budget ***********
    public class creditReturnWrapper{
        public String objectName;
        public auctionWrapper auctionInfo;
        public budgetWrapper budgetInfo;
        public List<budgetWrapper> budgetList;
        public String expirationDate;
        public Boolean showSlamDunkCheckbox;
    }
    public class auctionWrapper{
        public accountWrapper buyerDealer;
        public accountWrapper sellerDealer;
    }
    public class accountWrapper{
        public String name;
        public String key;
        public String territoryManagerName;
        public String territoryManagerEmail;
        public accountWrapper(String name, String key, String territoryManagerEmail, String territoryManagerName){
            this.name=name;
            this.key=key;
            this.territoryManagerEmail = territoryManagerEmail;
            this.territoryManagerName = territoryManagerName;
        }
    }
    public class budgetWrapper {
        public String budgetName;
        public String budgetId;
        public budgetWrapper( String budgetName, String budgetId) {
            this.budgetName = budgetName;
            this.budgetId = budgetId;
           
        }
    }
    
    //**** Custom 'wrapper' to hold data for creating credit/check record *****
    public class creditObj{
        public String currentObjectType;
        public String selectedDealer;
        public String otherDealer;
        public String resolution;
        public String enteredAmount;
        public String selectedBudget;
        public String selectedRecord;
        public String secondaryRecord;
        public String creditReason;
        public String selectedRootCause;
        public String enteredExplanation;
        public String caseId;
        public String currentId;
        public String goodwill;
        public String budget;
        public String expirationDate;
        public Boolean slamDunk;

        public creditObj(){
            currentObjectType ='';
            selectedDealer = '';
            otherDealer = '';
            resolution = '';
            enteredAmount = '';
            selectedBudget = '';
            selectedRecord = '';
            secondaryRecord = '';
            creditReason = '';
            selectedRootCause = '';
            enteredExplanation = '';
            caseId = '';
            currentId = '';
            goodwill = '';
            budget = '';
            expirationDate = '';
            slamDunk = false;
        }
    }
    //************************************************************************
    public static Set<String> slamDunkProfiles = new Set<String>{'System Administrator', 'Inside Sales - Managers'};
    @AuraEnabled(cacheable=false)
    public static String getObjectInfo(String objectRecordId){
        // Record Id of current record passed in
        // Determines record type: If Auction, returns dealers and auctionId
        // Looks for budget
        Id objectId = (Id) objectRecordId;
        String objectType = objectId.getSObjectType().getDescribe().getName();
        String queryString = '';
        creditReturnWrapper newWrapper = new creditReturnWrapper();
        newWrapper.objectName=objectType;
        List<Profile> runningUserProf = [ SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1 ];
        if( runningUserProf == null || runningUserProf.size() == 0 ){
            newWrapper.showSlamDunkCheckbox = false;
        }else{
            if( slamDunkProfiles.contains(runningUserProf[0].Name) ){
                newWrapper.showSlamDunkCheckbox = true;
            }else{
                newWrapper.showSlamDunkCheckbox = false;
            }
        }
        if(objectType=='Auction__c'){
            queryString += 'SELECT buyer_dealership__c, buyer_dealership__r.name, buyer_dealership__r.Owner.Name, buyer_dealership__r.Owner.Email, Seller_Dealership__c, Seller_Dealership__r.name, Seller_Dealership__r.Owner.Name, Seller_Dealership__r.Owner.Email ';
            queryString += 'FROM Auction__c WHERE Id=:objectId';
            sObject objectInfo = Database.query(queryString);
            newWrapper.auctionInfo = new auctionWrapper(); 
            try{
                String sellerTMName = objectInfo.get('seller_dealership__c') == null ? '' : (String)objectInfo.getsObject('seller_dealership__r').getsObject('Owner').get('Name');
                String sellerTMEmail = objectInfo.get('seller_dealership__c') == null ? '' : (String)objectInfo.getsObject('seller_dealership__r').getsObject('Owner').get('Email');
                newWrapper.auctionInfo.sellerDealer = new accountWrapper((String) objectInfo.getsObject('seller_dealership__r').get('name'), (String) objectInfo.get('seller_dealership__c'), sellerTMEmail, sellerTMName );
            }
            catch(Exception e){
                System.debug('Error caught: ' + e.getMessage());
            }
            try{
                system.debug(objectInfo.get('buyer_dealership__c'));
                String buyerTMName = objectInfo.get('buyer_dealership__c') == null ? '' : (String)objectInfo.getsObject('buyer_dealership__r').getsObject('Owner').get('Name');
                String buyerTMEmail = objectInfo.get('buyer_dealership__c') == null ? '' : (String)objectInfo.getsObject('buyer_dealership__r').getsObject('Owner').get('Email');
                newWrapper.auctionInfo.buyerDealer = new accountWrapper((String) objectInfo.getsObject('buyer_dealership__r').get('name'), (String) objectInfo.get('buyer_dealership__c'), buyerTMEmail, buyerTMName );
            } 
            catch(Exception e){
                System.debug('Error caught: ' + e.getMessage());
            }
        }else if( objectType == 'Account' ){
            Account thisDealership = [ SELECT Id, Name, OwnerId, Owner.Name, Owner.Email FROM Account WHERE Id = :objectId LIMIT 1 ];
            newWrapper.auctionInfo = new auctionWrapper();
            newWrapper.auctionInfo.buyerDealer = new accountWrapper( thisDealership.Name, thisDealership.Id, thisDealership.Owner.Email, thisDealership.Owner.Name );
        }
        // Retrieve all Budgets associated to Users' Groups
        List<String> groupList = new List<String>();
        newWrapper.budgetList = new List<budgetWrapper>();
        if( objectType == 'Account' ){
            for( Budget__c marketingBudget : [ SELECT Id, Name FROM Budget__c WHERE Name like 'Marketing%' ] ){
                newWrapper.budgetList.add(new budgetWrapper(marketingBudget.Name, marketingBudget.Id));
            }
        }else{
            for(GroupMember g: [SELECT GroupID, UserOrGroupId, Group.Name FROM GroupMember WHERE UserOrGroupId =:UserInfo.getUserId() AND Group.Name like 'Credit_%']){
                if(g != null){
                    groupList.add(g.Group.Name.removeStart('Credit '));
                }
            }
            if(groupList.size()>0){
                for(Budget__c b: [SELECT Id, Name FROM Budget__c WHERE Name IN :groupList]){
                    newWrapper.budgetList.add(new budgetWrapper((String)b.Name,(String)b.Id));
                }
            }
        }
        List<Salesforce_Setting__mdt> expirationDateDefault = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Credit_Expiration_Day' ];
        if(expirationDateDefault.size() > 0 ){
            newWrapper.expirationDate = String.valueOf(Date.today().addDays(Integer.valueOf(expirationDateDefault[0].Value__c)));
        }
        return JSON.serialize(newWrapper);
    }
    //************************************************************************


    @AuraEnabled(cacheable=false)
    public static String createCreditRecord(String inputObject){
        // inputObject is data from user entered on Auction or pre-existing credits_checks_c object which is deserialized into custom 'wrapper'
        creditObj creditObjToMake = new creditObj();
        creditObjToMake = (creditObj)JSON.deserialize(inputObject, creditObj.class);
        Credits_Checks__c newCreditCheck = new Credits_Checks__c();
        Id objectId = (Id) creditObjToMake.currentId;
        String insertSuccess = '';
        
        // selectedRecord is chosen by user on Auction, but if record is being created from credits_check__c record then no selection has been made, so it is set here
        if(creditObjToMake.currentObjectType=='Credits_Checks__c'){
            creditObjToMake.selectedRecord = 'Credit';
        }
        newCreditCheck.RecordTypeId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get(creditObjToMake.selectedRecord).getRecordTypeId(); //recordId
        
        if(creditObjToMake.currentObjectType=='Auction__c' || creditObjToMake.currentObjectType == 'Account' ){
            newCreditCheck.Dealer__c = creditObjToMake.selectedDealer;                                         // Buyer or Seller Dealer
            newCreditCheck.Payment_Type__c = creditObjToMake.resolution;                                       // ACV Credit Assigned, ACV Issued Check, Seller Issue Check, ACV Credit Deduction
            newCreditCheck.Amount_Requested__c = decimal.valueOf(creditObjToMake.enteredAmount);               // Amount
            newCreditCheck.Reason__c = creditObjToMake.creditReason;                                           // Arbitration, Bad Expense, Goodwill, No Direct Expense to ACV, Promotion
            newCreditCheck.Root_Cause__c = creditObjToMake.selectedRootCause;                                  // Dependent on ^^
            newCreditCheck.Explanation__c = creditObjToMake.enteredExplanation;                                // Description
            newCreditCheck.Applicable_To__c = 'ACV Fees';                                                      // ACV Fees, Assurance, Transportation
            newCreditCheck.Approval_Status__c = 'Submitted';                                                   // Approval Status
            newCreditCheck.Budget_Name__c = (Id)creditObjToMake.selectedBudget;                                // Associated Budget
            if( newCreditCheck.Payment_Type__c.contains('ACV Credit') ){
                newCreditCheck.Expiration_Date__c = Date.valueOf(creditObjToMake.expirationDate).addDays(-1);  // Sets Expiration Date     The endpoint adds a day so we subtract it so it looks consistent
            }
            newCreditCheck.Slam_Dunk__c = (Boolean)creditObjToMake.slamDunk;
            if( creditObjToMake.currentObjectType=='Auction__c'){
                newCreditCheck.Auction__c = creditObjToMake.currentId;                                             // Auction Id
            }
        }else if(creditObjToMake.currentObjectType=='Credits_Checks__c'){
            String queryString = '';
            queryString += 'SELECT Dealer__c, Reason__c, Root_Cause__c, Auction__c, Applicable_To__c, Budget_Name__c, Case__c,  Resolution__c, Expiration_Date__c ';
            queryString += 'FROM Credits_Checks__c WHERE Id=:objectId';
            sObject objectInfo = Database.query(queryString);
            newCreditCheck.Dealer__c = (Id)objectInfo.get('Dealer__c');                                     // Buyer or Seller Dealer
            newCreditCheck.Payment_Type__c = creditObjToMake.resolution;                                    // ACV Credit Assigned, ACV Issued Check, Seller Issue Check, ACV Credit Deduction
            newCreditCheck.Amount_Requested__c = decimal.valueOf(creditObjToMake.enteredAmount);            // Amount
            newCreditCheck.Reason__c = (String)objectInfo.get('Reason__c');                                 // Arbitration, Bad Expense, Goodwill, No Direct Expense to ACV, Promotion
            newCreditCheck.Root_Cause__c = (String)objectInfo.get('Root_Cause__c');                         // Dependent on ^^
            newCreditCheck.Auction__c = (Id)objectInfo.get('Auction__c');                                   // Auction Id
            newCreditCheck.Explanation__c = creditObjToMake.enteredExplanation;                             // Description
            newCreditCheck.Applicable_To__c = 'ACV Fees';                                                   // ACV Fees, Assurance, Transportation
            newCreditCheck.Approval_Status__c = 'Submitted';                                                // Approval Status
            newCreditCheck.Budget_Name__c = (Id)objectInfo.get('Budget_Name__c');                           // Associated Budget
            newCreditCheck.Adjustment__c = true;                                                            // Set Checkbox to True for Adjustment
            newCreditCheck.Parent_Credit__c = creditObjToMake.currentId;                                    // Credit Id
            newCreditCheck.Case__c = (Id)objectInfo.get('Case__c');
            newCreditCheck.Resolution__c = (Id)objectInfo.get('Resolution__c');
            newCreditCheck.Expiration_Date__c = Date.valueOf(objectInfo.get('Expiration_Date__c'));         //Adjustment Expiration date is the parents Expiration Date
        }

        try{
            if(newCreditCheck.Budget_Name__c != null){
                insert newCreditCheck;
                insertSuccess = 'true';
            }
            else{
                insertSuccess = 'falseBudget';
            }
        }
        catch(Exception e){
            System.debug('An error has occurred: ' + e.getMessage());
            insertSuccess = 'false';
        }

        if(insertSuccess == 'true'){
            return 'Success';
        }
        else if(insertSuccess == 'falseBudget'){
            return 'falseBudget';
        }
        else{
            return 'Failure';
        }
    }
}