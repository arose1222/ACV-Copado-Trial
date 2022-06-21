// CreateTitleCasesInBatch.runThisBatch();
global class CreateTitleCasesInBatch implements Database.Batchable<sObject> {
    static Integer batchSize = 10000;
    static Integer totalCasesToCreate = 9000;
    static String uniqueSufixForRec = '#H';
    
    public static void runThisBatch()	{
         Database.executeBatch(new CreateTitleCasesInBatch(), batchSize);
    }
    
    global List<SObject> start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return bulkCreateCases(
            'Account Batch' + uniqueSufixForRec,
            'Auc Id Batch' + uniqueSufixForRec,
            'AuctionName Batch' + uniqueSufixForRec, 
            'New', 
            'Title Subject Batch' + uniqueSufixForRec,
            totalCasesToCreate);        
    }
    global void execute(Database.BatchableContext bc, List<SObject> records){
        // process each batch of records
        insert records;
        
        for(SObject c : records)	CreateSampleTitleCase.createTrackRec(c, 5);        
		CreateSampleTitleCase.saveTrackRecs();                
    }    
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        /*
        aAJ = [ SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob WHERE Id = :BC.getJobId()];
    	if(aAJ != null && statusSObject!=null && statusSObjectFieldName!=null) {
        	statusSObject.put(statusSObjectFieldName,aAJ.Status);
            update statusSObject;
		*/
    }    
    
    static public List<Case> bulkCreateCases(String acctUniqueName, String auctionId, String auctionName, String titleStatus, String titleSubject, Integer totalNumOfCasesToCreate)	{
        Boolean createCaseWithAuctionBuyer = true;
        
        Account newAcctSeller = CreateSampleTitleCase.createAccount(acctUniqueName + ' (Seller)');
        Account newAcctBuyer = CreateSampleTitleCase.createAccount(acctUniqueName + ' (Buyer)');
        Account newAcctBuyerAuction = CreateSampleTitleCase.createAccount(acctUniqueName + ' (Auction Buyer)');
        
        Contact newContactSeller = CreateSampleTitleCase.createContact(newAcctSeller);
        newContactSeller.LastName = 'Seller';
        Contact newContactBuyer = CreateSampleTitleCase.createContact(newAcctBuyer);
        newContactBuyer.LastName = 'Buyer';
        
        Vehicle__c newVehicle = CreateSampleTitleCase.createVehicle();
        
        SObject[] newObjs = new SObject[] {newAcctBuyerAuction, newAcctSeller, newAcctBuyer, newContactSeller, newContactBuyer, newVehicle};
        insert newObjs;        

        CreateSampleTitleCase.createTrackRec(newAcctSeller, 1);
        CreateSampleTitleCase.createTrackRec(newAcctBuyer, 1);
        CreateSampleTitleCase.createTrackRec(newAcctBuyerAuction, 1);
        CreateSampleTitleCase.createTrackRec(newContactSeller, 2);
        CreateSampleTitleCase.createTrackRec(newContactBuyer, 2);        
        CreateSampleTitleCase.createTrackRec(newVehicle, 3);
        
        Auction__c newAuction = CreateSampleTitleCase.createAuction(newAcctSeller, newContactSeller, newVehicle);
        newAuction.Buyer_Dealership__c = newAcctBuyerAuction.Id;
        newAuction.Seller_Dealership__c = newAcctSeller.Id;
        newAuction.Name = auctionName;
        newAuction.id__c = auctionId;
		insert newAuction;
        
        CreateSampleTitleCase.createTrackRec(newAuction, 4);
		CreateSampleTitleCase.saveTrackRecs();                
        
        List<Case> newCases = new List<Case>();
        for(Integer i = 0; i < totalNumOfCasesToCreate; i++)	{
            Case newTitleCase = CreateSampleTitleCase.createTitleCase(newAuction, newAcctBuyer, newContactSeller);
            /*
             * - On Case,  AccountId is set to Buyer.
             * - If AccountId on Case is already set when creating a new Case record then it will not be overwritten by Auction.Buyer_Dealership__c.  However, Auction will still use Buyer_Dealership__c (not the one on Case).
             * - If AccountId on Case is already NOT set when creating a new Case record then it will use Auction.Buyer_Dealership__c. 
             */
            if(createCaseWithAuctionBuyer) newTitleCase.AccountId = null;
            newTitleCase.Status = titleStatus;
            newTitleCase.Subject = titleSubject + ' #' + i;
            
            newCases.add(newTitleCase);
        }        
        
        return newCases;
    }
    
}