/**
 * @description Test class for the batch process to update late fee on Account and create a new Assigned Fee record.
 * 				Requirements: https://acvauctions.atlassian.net/browse/TDO-22
 * 
 * @author Manmeet Vaseer
 * @date 08/02/2021
 * 
 * @history
 * 		04/21/2022 Manmeet Vaseer - https://acvauctions.atlassian.net/browse/TDO-828.
 * 		06/08/2022 Manmeet Vaseer - https://acvauctions.atlassian.net/browse/TDO-935. Populate various emails from Case to Assigned Fee (when recrod is created).
 * 
 */
@IsTest(SeeAllData=false) 
public class TitleLateFeeBatchTest {
    
    /**
     * We want to calculate Late Fee one day after the Title Due Date (https://acvauctions.atlassian.net/browse/TDO-828).
     */
    @isTest
    static void testGracePeriodOfOneDay()	{
        TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>(); // disable all triggers
        
        Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
        
        String acctUniqueName = 'TLFBatchTest';        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;

        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {aFee, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = null;        
        insert newTitleCase;
        
        newTitleCase.Title_Due_Date__c = System.now().addDays(-1); // Title is late by a day but one day is grace period so there should be no Late Fee.
        update newTitleCase;        

		// Run the Batch - Create a new Assigned Fee record       
        Test.startTest();
        TitleLateFeeBatch acBatch = new TitleLateFeeBatch();
        Database.executebatch(acBatch);
        Test.stopTest();        
        
        Id titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Title_Late_Fee').getRecordTypeId();
        List<Assigned_Fee__c> assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c];
        System.assertEquals(0, assignedFees.size(), 'There should be no Assigned Fee record.');
    }
    
    @isTest
    static void testBatchSingleAccountSingleCase()	{
        TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>(); // disable all triggers
        
        Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
        
        String acctUniqueName = 'TLFBatchTest';        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;

        Contact newContact = TestUtility.createContact(newSellerAcct);
        newContact.Email = 'SellerContactEmail@email.com';
        
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {aFee, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        newSellerAcct.Primary_Contact__c = newContact.Id;
        update newSellerAcct;
            
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = null;
        //newTitleCase.Seller_Contact_Email__c = 'contact@email.com'; // Case's Selling dealers primary contact. It is set in Seller Contact.
        //newTitleCase.Seller_TM_Email__c = 'sellertm@email.com'; // Should be the Selling dealerships account owner email. It is set automatically.
        newTitleCase.Seller_Title_Clerk_Email__c = 'titleclerk@email.com';
            
        insert newTitleCase;
       
        newTitleCase.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase;        

		// Run the Batch - Create a new Assigned Fee record       
        Test.startTest();
        TitleLateFeeBatch acBatch = new TitleLateFeeBatch();
        Database.executebatch(acBatch);
        Test.stopTest();        
        
        Id titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Title_Late_Fee').getRecordTypeId();
        List<Assigned_Fee__c> assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId, Seller_Contact_Email__c, Seller_Territory_Manager_Email__c, Seller_Title_Clerk_Email__c  FROM Assigned_Fee__c];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(aFee.Default_Amount__c, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 25 for Total Billable Amount..');
        System.assertEquals(aFee.Default_Amount__c, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 25 for Potential Billable Amount..');
    
        //System.assertEquals(newContact.Email, assignedFees[0].Seller_Contact_Email__c, 'Seller_Contact_Email__c');
        //System.assertNotEquals(null, assignedFees[0].Seller_Territory_Manager_Email__c, 'Seller_Territory_Manager_Email__c');
        System.assertEquals(newTitleCase.Seller_Title_Clerk_Email__c, assignedFees[0].Seller_Title_Clerk_Email__c, 'Seller_Title_Clerk_Email__c');
        
        List<Account> theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(aFee.Default_Amount__c, theAccount[0].Total_Billable_Amount__c, 'Account should have 25 for Total Billable Amount.');
        System.assertEquals(aFee.Default_Amount__c, theAccount[0].Potential_Billable_Amount__c, 'Account should have 25 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
		// Run the Batch again to update the Assigned Fee record       
        List<Case> qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(2*aFee.Default_Amount__c, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(2*aFee.Default_Amount__c, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(2*aFee.Default_Amount__c, theAccount[0].Total_Billable_Amount__c, 'Account should have 50 for Total Billable Amount.');
        System.assertEquals(2*aFee.Default_Amount__c, theAccount[0].Potential_Billable_Amount__c, 'Account should have 50 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        

		// Title has received        
        newTitleCase.Title_Received_Date__c = System.today();        
        update newTitleCase;        

		// Run the Batch again to update the Assigned Fee & Account records
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(2*aFee.Default_Amount__c, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(2*aFee.Default_Amount__c, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(0, theAccount[0].Total_Billable_Amount__c, 'Account should have 0 for Total Billable Amount.');
        System.assertEquals(2*aFee.Default_Amount__c, theAccount[0].Potential_Billable_Amount__c, 'Account should have 50 for Potential Billable Amount.');
        System.assertEquals(false, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be false.');                
    }
    
    @isTest
    static void testBatchSingleAccountSingleCaseMaxLimit()	{
        TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>(); // disable all triggers
        
        Test.startTest();
        Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
        
        String acctUniqueName = 'TLFBatchTest';        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;
        newSellerAcct.Total_Billable_Amount__c=225;
        newSellerAcct.Potential_Billable_Amount__c=225;

        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {aFee, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = null;        
        insert newTitleCase;
        
        newTitleCase.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase;        

        List<Case> cases = [SELECT Id, Seller_Dealership__c FROM Case];
        System.assertEquals(1, cases.size(), 'There should be 1 Case.');
        System.assertEquals(newSellerAcct.Id, cases[0].Seller_Dealership__c, 'Case should be using the Seller Account.');

        Id titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Title_Late_Fee').getRecordTypeId();
        Assigned_Fee__c newAssignedFee = new Assigned_Fee__c(Case__c=newTitleCase.Id, Account__c=newTitleCase.Seller_Dealership__c, Override_Amount__c=aFee.Default_Amount__c,
                                                             Fee__c=aFee.Id, Fee_Status__c='Fee Pending', RecordTypeId=titleLateFeeRecordTypeId,
                                                             Total_Billable_Amount__c=225, Potential_Billable_Amount__c=225,
                                                             Seller_Contact_Email__c='Seller_Contact_Email__c@email.com', Seller_Territory_Manager_Email__c='Seller_TM_Email__c@email.com',
                                                             Seller_Title_Clerk_Email__c='Seller_Title_Clerk_Email__c@email.com');
        insert newAssignedFee;
        
		// Run the Batch - Create a new Assigned Fee record       
        TitleLateFeeBatch acBatch = new TitleLateFeeBatch();
        List<Case> qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        List<Assigned_Fee__c> assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed as max fee limit has reached.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(250, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 250 for Total Billable Amount..');
        System.assertEquals(250, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 250 for Potential Billable Amount..');
        
        List<Account> theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(0, theAccount[0].Total_Billable_Amount__c, 'Account should have 0 for Total Billable Amount.');
        System.assertEquals(250, theAccount[0].Potential_Billable_Amount__c, 'Account should have 250 for Potential Billable Amount.');
        System.assertEquals(false, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be false.');        
        
		// Run the Batch again to update the Assigned Fee record - this should update the Potentiall Billable Amount but not the Totoal Billiable Amount 
		// as Max Late Fee limit is reached but the Title has not received yet
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(250, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 250 for Total Billable Amount..');
        System.assertEquals(250+aFee.Default_Amount__c, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 275 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(0, theAccount[0].Total_Billable_Amount__c, 'Account should have 0 for Total Billable Amount.');
        System.assertEquals(250+aFee.Default_Amount__c, theAccount[0].Potential_Billable_Amount__c, 'Account should have 275 for Potential Billable Amount.');
        System.assertEquals(false, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be false.');        

		// Title has received        
        newTitleCase.Title_Received_Date__c = System.today();        
        update newTitleCase;        

        cases = [SELECT Id, Seller_Dealership__c, Title_Received_Date__c FROM Case];
        System.assertEquals(1, cases.size(), 'There should be 1 Case.');
        System.assertNotEquals(null, cases[0].Title_Received_Date__c, 'Case Title Received Date should not be null.');
        
		// Run the Batch again to update the Assigned Fee & Account records
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(250, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 250 for Total Billable Amount..');
        System.assertEquals(250+aFee.Default_Amount__c, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 275 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(0, theAccount[0].Total_Billable_Amount__c, 'Account should have 0 for Total Billable Amount.');
        System.assertEquals(250+aFee.Default_Amount__c, theAccount[0].Potential_Billable_Amount__c, 'Account should have 275 for Potential Billable Amount.');
        System.assertEquals(false, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be false.');        
        
        Test.stopTest();                
    }

    @isTest
    static void testBatchSingleAccountMultiCases()	{
        TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>(); // disable all triggers
        
        Test.startTest();
        Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
        
        String acctUniqueName = 'TLFBatchTest';        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;
        newSellerAcct.Total_Billable_Amount__c=225;
        newSellerAcct.Potential_Billable_Amount__c=225;

        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {aFee, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = null;        
        insert newTitleCase;
        
        newTitleCase.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase;        

        List<Case> cases = [SELECT Id, Seller_Dealership__c FROM Case];
        System.assertEquals(1, cases.size(), 'There should be 1 Case.');
        System.assertEquals(newSellerAcct.Id, cases[0].Seller_Dealership__c, 'Case should be using the Seller Account.');

		Case newTitleCase2 = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase2.AccountId = newBuyerAcct.Id;
        newTitleCase2.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase2.Status = 'New';
        newTitleCase2.Title_Received_Date__c = null;        
        insert newTitleCase2;
        
        newTitleCase2.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase2;        
        
        Id titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Title_Late_Fee').getRecordTypeId();
        Assigned_Fee__c newAssignedFee = new Assigned_Fee__c(Case__c=newTitleCase.Id, Account__c=newTitleCase.Seller_Dealership__c, Override_Amount__c=aFee.Default_Amount__c,
                                                             Fee__c=aFee.Id, Fee_Status__c='Fee Pending', RecordTypeId=titleLateFeeRecordTypeId,
                                                             Total_Billable_Amount__c=200, Potential_Billable_Amount__c=200,
                                                             Seller_Contact_Email__c='Seller_Contact_Email__c@email.com', Seller_Territory_Manager_Email__c='Seller_TM_Email__c@email.com',
                                                             Seller_Title_Clerk_Email__c='Seller_Title_Clerk_Email__c@email.com');
        insert newAssignedFee;

        Assigned_Fee__c newAssignedFee2 = new Assigned_Fee__c(Case__c=newTitleCase2.Id, Account__c=newTitleCase2.Seller_Dealership__c, Override_Amount__c=aFee.Default_Amount__c,
                                                             Fee__c=aFee.Id, Fee_Status__c='Fee Pending', RecordTypeId=titleLateFeeRecordTypeId,
                                                             Total_Billable_Amount__c=25, Potential_Billable_Amount__c=25,
                                                             Seller_Contact_Email__c='Seller_Contact_Email__c@email.com', Seller_Territory_Manager_Email__c='Seller_TM_Email__c@email.com',
                                                             Seller_Title_Clerk_Email__c='Seller_Title_Clerk_Email__c@email.com');
        insert newAssignedFee2;
        
		// Run the Batch - Create a new Assigned Fee record       
        TitleLateFeeBatch acBatch = new TitleLateFeeBatch();
        List<Case> qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        List<Assigned_Fee__c> assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(225, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 225 for Total Billable Amount..');
        System.assertEquals(225, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 225 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');
        
        List<Account> theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(275, theAccount[0].Total_Billable_Amount__c, 'Account should have 275 for Total Billable Amount.');
        System.assertEquals(275, theAccount[0].Potential_Billable_Amount__c, 'Account should have 275 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
		// Run the Batch again to update the Assigned Fee record 
		// Max Late Fee limit will be reached for Case1 but the Title has not received yet
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(System.today(), assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be Today Date.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(250, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 250 for Total Billable Amount..');
        System.assertEquals(250, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 250 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(null, assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be empty.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(75, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 75 for Total Billable Amount..');
        System.assertEquals(75, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 75 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(75, theAccount[0].Total_Billable_Amount__c, 'Account should have 75 for Total Billable Amount.');
        System.assertEquals(325, theAccount[0].Potential_Billable_Amount__c, 'Account should have 325 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
		// Run the Batch again - 3rd time
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(250, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 250 for Total Billable Amount..');
        System.assertEquals(275, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 275 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(100, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 100 for Total Billable Amount..');
        System.assertEquals(100, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 100 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(100, theAccount[0].Total_Billable_Amount__c, 'Account should have 100 for Total Billable Amount.');
        System.assertEquals(375, theAccount[0].Potential_Billable_Amount__c, 'Account should have 375 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
		// Both Titles have been received        
        newTitleCase.Title_Received_Date__c = System.today();        
        newTitleCase2.Title_Received_Date__c = System.today();        
        update new Case[] {newTitleCase, newTitleCase2};

        cases = [SELECT Id, Seller_Dealership__c, Title_Received_Date__c FROM Case];
        System.assertEquals(2, cases.size(), 'There should be 2 Case.');
        System.assertNotEquals(null, cases[0].Title_Received_Date__c, 'Case Title Received Date should not be null.');
        
		// Run the Batch again - 4th time
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);
        
        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(System.today(), assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be Today Date.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(250, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 250 for Total Billable Amount..');
        System.assertEquals(275, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 275 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(System.today(), assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be Today Date.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(100, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 100 for Total Billable Amount..');
        System.assertEquals(100, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 100 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(0, theAccount[0].Total_Billable_Amount__c, 'Account should have 0 for Total Billable Amount.');
        System.assertEquals(375, theAccount[0].Potential_Billable_Amount__c, 'Account should have 375 for Potential Billable Amount.');
        System.assertEquals(false, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be false.');        
                
        Test.stopTest();                
    }
    
    @isTest
    static void testBatchMultiAccountsMultiCases()	{
        TriggerFrameWork.mockMetadata = new List<TriggerHandler__mdt>(); // disable all triggers
        
        Test.startTest();
        Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
        
        String acctUniqueName = 'TLFBatchTest';        
        String acctUniqueName2 = '2ndTLFBatchTest';        
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;

        Account newSellerAcct2 = TestUtility.createAccount(acctUniqueName2 + 'Seller');  
		newSellerAcct2.Late_Title_Fee_Eligible__c = true;
        newSellerAcct2.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct2.Unpaid_Title_Late_Fee__c = false;
        
        Contact newContact = TestUtility.createContact(newSellerAcct);
        newContact.Email = 'SellerContactEmail@email.com';
        
        Vehicle__c newVehicle = TestUtility.createVehicle();

        Contact newContact2 = TestUtility.createContact(newSellerAcct2);
        newContact.Email = 'SellerContactEmail2@email.com';
        
        Vehicle__c newVehicle2 = TestUtility.createVehicle();
        
        SObject[] newObjs = new SObject[] {aFee, newBuyerAcct, newSellerAcct, newContact, newVehicle, newSellerAcct2, newContact2, newVehicle2};
        insert newObjs;
        
        newSellerAcct.Primary_Contact__c = newContact.Id;
        update newSellerAcct;

        newSellerAcct2.Primary_Contact__c = newContact2.Id;
        update newSellerAcct;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;

        Auction__c newAuction2 = TestUtility.createAuction(newSellerAcct2, newContact2, newVehicle2);
        newAuction2.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction2.Seller_Dealership__c = newSellerAcct2.Id;
        newAuction2.Name = acctUniqueName2;
        newAuction2.id__c = acctUniqueName2;    
        newAuction2.Payment_Status__c = 'Paid';
        insert newAuction2;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = null;        
        newTitleCase.Seller_Title_Clerk_Email__c = 'titleclerk@email.com';
        insert newTitleCase;
        
        newTitleCase.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase;        

		Case newTitleCase2 = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase2.AccountId = newBuyerAcct.Id;
        newTitleCase2.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase2.Status = 'New';
        newTitleCase2.Title_Received_Date__c = null;        
        newTitleCase2.Seller_Title_Clerk_Email__c = 'titleclerk2@email.com';
        insert newTitleCase2;
        
        newTitleCase2.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase2;        

		Case newTitleCase3 = TestUtility.createTitleCase(newAuction2, newBuyerAcct, newContact2);
        newTitleCase3.AccountId = newBuyerAcct.Id;
        newTitleCase3.Seller_Dealership__c = newSellerAcct2.Id;
        newTitleCase3.Status = 'New';
        newTitleCase3.Title_Received_Date__c = null;        
        newTitleCase3.Seller_Title_Clerk_Email__c = 'titleclerk3@email.com';
        insert newTitleCase3;
        
        newTitleCase3.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase3;        

		Case newTitleCase4 = TestUtility.createTitleCase(newAuction2, newBuyerAcct, newContact2);
        newTitleCase4.AccountId = newBuyerAcct.Id;
        newTitleCase4.Seller_Dealership__c = newSellerAcct2.Id;
        newTitleCase4.Status = 'New';
        newTitleCase4.Title_Received_Date__c = null;        
        newTitleCase4.Seller_Title_Clerk_Email__c = 'titleclerk4@email.com';
        insert newTitleCase4;
        
        newTitleCase4.Title_Due_Date__c = System.now().addDays(-2); // Title is late by a day
        update newTitleCase4;        
        
        Id titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Title_Late_Fee').getRecordTypeId();
        
		// Run the Batch - Create a new Assigned Fee record       
        TitleLateFeeBatch acBatch = new TitleLateFeeBatch();
        List<Case> qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);

		// Account 1        
        List<Assigned_Fee__c> assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(25, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 25 for Total Billable Amount..');
        System.assertEquals(25, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 25 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(25, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 25 for Total Billable Amount..');
        System.assertEquals(25, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 25 for Potential Billable Amount..');
        
        List<Account> theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(50, theAccount[0].Total_Billable_Amount__c, 'Account should have 50 for Total Billable Amount.');
        System.assertEquals(50, theAccount[0].Potential_Billable_Amount__c, 'Account should have 50 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        

		// Account 2        
        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase3.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(25, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 25 for Total Billable Amount..');
        System.assertEquals(25, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 25 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase4.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(25, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 25 for Total Billable Amount..');
        System.assertEquals(25, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 25 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(50, theAccount[0].Total_Billable_Amount__c, 'Account should have 50 for Total Billable Amount.');
        System.assertEquals(50, theAccount[0].Potential_Billable_Amount__c, 'Account should have 50 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
		// Run the Batch again to update the Assigned Fee record 
		// Max Late Fee limit will be reached for Case1 but the Title has not received yet
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);

        // Account 1
        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(null, assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should empty.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(null, assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be empty.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 75 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 75 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(100, theAccount[0].Total_Billable_Amount__c, 'Account should have 100 for Total Billable Amount.');
        System.assertEquals(100, theAccount[0].Potential_Billable_Amount__c, 'Account should have 100 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        

        // Account 2
        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase3.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(null, assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should empty.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase4.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(null, assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be empty.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 75 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 75 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(100, theAccount[0].Total_Billable_Amount__c, 'Account should have 100 for Total Billable Amount.');
        System.assertEquals(100, theAccount[0].Potential_Billable_Amount__c, 'Account should have 100 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
		// 3 Titles have been received        
        newTitleCase.Title_Received_Date__c = System.today();        
        newTitleCase2.Title_Received_Date__c = System.today();        
        newTitleCase3.Title_Received_Date__c = System.today();        
        update new Case[] {newTitleCase, newTitleCase2, newTitleCase3};

		// Run the Batch again - 3rd time
        qCases = Database.query(acBatch.getQuery());
        acBatch.calculateLateFees(qCases);

		// Account 1        
        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(System.today(), assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be Today Date.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase2.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(System.today(), assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be Today Date.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(0, theAccount[0].Total_Billable_Amount__c, 'Account should have 0 for Total Billable Amount.');
        System.assertEquals(100, theAccount[0].Potential_Billable_Amount__c, 'Account should have 100 for Potential Billable Amount.');
        System.assertEquals(false, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be false.');        

		// Account 2        
        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase3.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Assessed', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Assessed');
        System.assertEquals(System.today(), assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be Today Date.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(50, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 50 for Total Billable Amount..');
        System.assertEquals(50, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 50 for Potential Billable Amount..');

        assignedFees = [SELECT Id, Date_Fee_Accessed__c, Total_Billable_Amount__c, Potential_Billable_Amount__c, Case__c, Account__c, Fee__c, Fee_Status__c, RecordTypeId FROM Assigned_Fee__c WHERE Case__c = :newTitleCase4.Id];
        System.assertEquals(1, assignedFees.size(), 'There should be one Assigned Fee record.');
        System.assertEquals('Fee Pending', assignedFees[0].Fee_Status__c, 'Assigned Fee record Fee Status should be Fee Pending');
        System.assertEquals(null, assignedFees[0].Date_Fee_Accessed__c, 'Assigned Fee record Date Fee Assessed should be null.');
        System.assertEquals(titleLateFeeRecordTypeId, assignedFees[0].RecordTypeId, 'Assigned Fee Record Type should be Title_Late_Fee.');
        System.assertEquals(75, assignedFees[0].Total_Billable_Amount__c, 'Assigned Fee should have 75 for Total Billable Amount..');
        System.assertEquals(75, assignedFees[0].Potential_Billable_Amount__c, 'Assigned Fee should have 75 for Potential Billable Amount..');
        
        theAccount = [SELECT Total_Billable_Amount__c, Potential_Billable_Amount__c, Unpaid_Title_Late_Fee__c FROM Account WHERE Id = :assignedFees[0].Account__c];
        System.assertEquals(1, theAccount.size(), 'There should be one Account record.');
        System.assertEquals(75, theAccount[0].Total_Billable_Amount__c, 'Account should have 75 for Total Billable Amount.');
        System.assertEquals(125, theAccount[0].Potential_Billable_Amount__c, 'Account should have 125 for Potential Billable Amount.');
        System.assertEquals(true, theAccount[0].Unpaid_Title_Late_Fee__c, 'Account Unpaid Title Late Fee should be true.');        
        
        Test.stopTest();                
    }
     
}