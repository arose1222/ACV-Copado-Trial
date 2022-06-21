/**
 *
        String acctUniqueName = 'Test TitleStatusTransitionTriggerHandlerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';

        SObject[] newObjs = new SObject[] {newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;
 * 
 * 
CreateSampleTitleCase.createCompleteTitleCase(
    'Account #1',
	'Auction Id #1',
    'Auction Name #1', 
    'New', 
    'Title Subject #1',
	true);

CreateSampleTitleCase.bulkCreateCases(
    'Account Bulk#A',
	'AuctionId Bulk#A',
    'AuctionName Bulk#A', 
    'New', 
    'Title Subject Bulk#A',
	205);

 */
// CreateSampleTitleCase.createData();
// CreateSampleTitleCase.createTitleCase();
// CreateSampleTitleCase.updateStatusAndS3Image();
// CreateSampleTitleCase.deleteCasesOlderThanNDays(5);
// CreateSampleTitleCase.bulkUpdateCases('New', 'Received');
// CreateSampleTitleCase.deleteAllTrackRecs();
// CreateSampleTitleCase.deleteTrackRecsWithSortOrder(5);
// CreateSampleTitleCase.createCaseWithQualityControl();
// CreateSampleTitleCase.createTitleLateFeeData();
// CreateSampleTitleCase.createTitleLateFeeData2();
// CreateSampleTitleCase.createCaseWithQualityControlAndCustomerInquiries();
// CreateSampleTitleCase.createTitleAssociatedRecsForDatahubConsumer();
// CreateSampleTitleCase.calculateTitleDueCaseNewCases('calcdd1');
// CreateSampleTitleCase.createCaseWithTitleAndDealershipNotes();
// CreateSampleTitleCase.createCaseWithTitleAndTitleReview();
// CreateSampleTitleCase.createCaseForTitlesAutomationAPI();
public class CreateSampleTitleCase {
    static String TITLE_INFO_RT = 'Title_Information';

    static List<Track_Id_to_Delete__c> tRecs = new List<Track_Id_to_Delete__c>();

    static public void createCaseForTitlesAutomationAPI()	{
        String acvTitlesExternalId = 'external_title_uuid_BB';
        String acctUniqueName = 'BB_TitlesAuto_BB';
        
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        newSellerAcct.IST_Account_Owner__c = '0050a00000JAbJiAAL';
        
        Contact newContact = createContact(newSellerAcct);
        //newContact.Email = 'msingh@vaseer.com';
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'acv_capital_60_30';
        insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        newTitleCase.ClosedDate = System.now();
        insert newTitleCase;
    }
    
    static public void createCaseWithTitleAndTitleReview()	{
        String acvTitlesExternalId = 'external_title_uuid_AA';
        String acctUniqueName = 'AATitleReview#AA';
        
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        newSellerAcct.IST_Account_Owner__c = '0050a00000JAbJiAAL';
        
        Contact newContact = createContact(newSellerAcct);
        //newContact.Email = 'msingh@vaseer.com';
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'ACV_Capital';
        insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'Working';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = false;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        insert newTitleCase;

        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;        
        
        Customer_Inquiry__c ci = new Customer_Inquiry__c(Ops_Case__c=newTitleCase.Id, Account__c=newBuyerAcct.Id, Call_Bucket__c='Titles', Status__c='New');
        insert ci;   

		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        Id titleRecordTypeId = digitalTitleRecordTypeId;
        
        Title__c aNewTitle = new Title__c (
            RecordTypeId = titleRecordTypeId,
            Name = acvTitlesExternalId,
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
        insert aNewTitle;
        
        newTitleCase.Title__c = aNewTitle.Id;
        update newTitleCase;
        
        Title_Review__c aTR = new Title_Review__c (
            Name = 'review_uuidAA',
            Title__c = aNewTitle.Id,
            Commit_Pending__c = true
        );

        insert aTR;

    }
    
    
    static public void createCaseWithTitleAndDealershipNotes()	{
        String acctUniqueName = 'DealeNote #1';
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        newSellerAcct.IST_Account_Owner__c = '0050a00000JAbJiAAL';
        
        Contact newContact = createContact(newSellerAcct);
        //newContact.Email = 'msingh@vaseer.com';
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'adi';
        insert newAuction;
        
        String acvTitlesExternalId = 'external_title_uuid';
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.ACV_Titles_External_ID__c = acvTitlesExternalId;
        newTitleCase.Title_Attached__c = true;
        newTitleCase.Digital_Title__c = true;
        newTitleCase.Vehicle__c = newVehicle.Id;        
        insert newTitleCase;

        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;        
        
        Customer_Inquiry__c ci = new Customer_Inquiry__c(Ops_Case__c=newTitleCase.Id, Account__c=newBuyerAcct.Id, Call_Bucket__c='Titles', Status__c='New');
        insert ci;   

		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        Id titleRecordTypeId = digitalTitleRecordTypeId;
        
        Title__c aNewTitle = new Title__c (
            RecordTypeId = titleRecordTypeId,
            Name = acvTitlesExternalId,
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
        insert aNewTitle;
        
        Dealership_Note__c aNewNote1 = new Dealership_Note__c (
            Name = 'noteId_uuid1',
            Note__c = 'this is note one.',
            Title__c = aNewTitle.Id
            //Note_Author__c = authorContactId
        );

        Dealership_Note__c aNewNote2 = new Dealership_Note__c (
            Name = 'noteId_uuid2',
            Note__c = 'this is note two.',
            Title__c = aNewTitle.Id
            //Note_Author__c = authorContactId
        );

        Dealership_Note__c aNewNote3 = new Dealership_Note__c (
            Name = 'noteId_uuid3',
            Note__c = 'this is note three.',
            Title__c = aNewTitle.Id
            //Note_Author__c = authorContactId
        );
        
        insert aNewNote1;
        insert aNewNote2;
        insert aNewNote3;

    }
    
    static public void calculateTitleDueCaseNewCases(String uniqueId)	{
        String acctUniqueName = uniqueId;        
        Account newAcctSeller = createAccount(acctUniqueName + ' (Seller)');
        Account newAcctBuyer = createAccount(acctUniqueName + ' (Buyer)');
        Account newAcctBuyerAuction = createAccount(acctUniqueName + ' (Auction Buyer)');

        SObject[] newObjs = new SObject[] {newAcctSeller, newAcctBuyer, newAcctBuyerAuction};
        insert newObjs;
        
        Contact newContactSeller = createContact(newAcctSeller);
        newContactSeller.LastName = 'Seller';
        Contact newContactBuyer = createContact(newAcctBuyer);
        newContactBuyer.LastName = 'Buyer';
        
        Vehicle__c newVehicle = createVehicle();
        
        newObjs = new SObject[] {newContactSeller, newContactBuyer, newVehicle};
        insert newObjs;
                
        Auction__c newAuction = createAuction(newAcctSeller, newContactSeller, newVehicle);
        newAuction.Name = uniqueId + 'Auc';
        newAuction.Buyer_Dealership__c = newAcctBuyer.Id;
        newAuction.Seller_Dealership__c = newAcctSeller.Id;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        newAuction.end_time__c= system.today();
        insert newAuction;    

		Case newTitleCase = createTitleCase(newAuction, newAcctBuyer, newContactSeller);
        newTitleCase.AccountId = newAcctBuyer.Id;
        newTitleCase.Subject = 'calc due date';
        newTitleCase.Status = 'New';
        newTitleCase.Title_Attached__c = true;
        insert newTitleCase;
    }
                                                     
    // This will not create a Title Case. Just the reference records needed to create Title Case.
    static public void createTitleAssociatedRecsForDatahubConsumer()	{
        
        String acctUniqueName = 'TitleDatahubC#1';
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
        newBuyerAcct.Dealership_ID__c = '678456';
        
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
        newSellerAcct.Dealership_ID__c = '890321';

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct};
        insert newObjs;
        
        Contact newBuyerContact = createContact(newBuyerAcct);
        newBuyerContact.ID__c = '567321';
        
        Contact newSellerContact = createContact(newSellerAcct);
        newSellerContact.ID__c = '901765';
        
        Vehicle__c newVehicle = createVehicle();
		newVehicle.Name = '1J4F4C9SX5P328524';
		newVehicle.Vin__c = '1J4F4C9SX5P328524';
        
        newObjs = new SObject[] {newBuyerContact, newSellerContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newSellerContact, newVehicle);
        newAuction.Name = '346712';
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;    
    }
    
    static public void createCaseWithQualityControlAndCustomerInquiries()	{
        String acctUniqueName = 'EasyPostTest #7';
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        newSellerAcct.IST_Account_Owner__c = '0050a00000JAbJiAAL';
        
        Contact newContact = createContact(newSellerAcct);
        //newContact.Email = 'msingh@vaseer.com';
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'adi';
        insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.IST_Account_Owner_Lookup__c = '0050a00000JAbJiAAL';
        insert newTitleCase;

        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;        
        
        Customer_Inquiry__c ci = new Customer_Inquiry__c(Ops_Case__c=newTitleCase.Id, Account__c=newBuyerAcct.Id, Call_Bucket__c='Titles', Status__c='New');
        insert ci;        
    }
    
    static public void createTitleLateFeeData2()	{ 
        
        Id titleInfoCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TITLE_INFO_RT).getRecordTypeId();
        
        Fee__c aFee = null;
        List<Fee__c> fees = [SELECT Id, Name, Default_Amount__c, Max_Allowable_Fees__c FROM Fee__c WHERE Name = 'Title Late Fee' AND Type__c = 'Seller Fee' LIMIT 1];
        if(fees == null || fees.size() == 0) {
            aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
            insert aFee;
        }
        else aFee = fees[0];
        
        String acctUniqueName = 'CaseyTRecv';        
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;
        newSellerAcct.Total_Billable_Amount__c=50;
        newSellerAcct.Potential_Billable_Amount__c=50;

        Contact newContact = createContact(newSellerAcct);
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = System.today(); //null;        
        insert newTitleCase;
        
        newTitleCase.Title_Due_Date__c = System.today().addDays(-1); // Title is late by a day
        update newTitleCase;        

        Id titleLateFeeRecordTypeId = Schema.SObjectType.Assigned_Fee__c.getRecordTypeInfosByDeveloperName().get('Title_Late_Fee').getRecordTypeId();
        Assigned_Fee__c newAssignedFee = new Assigned_Fee__c(Case__c=newTitleCase.Id, Account__c=newTitleCase.Seller_Dealership__c, Override_Amount__c=aFee.Default_Amount__c,
                                                             Fee__c=aFee.Id, Fee_Status__c='Fee Pending', RecordTypeId=titleLateFeeRecordTypeId,
                                                             Total_Billable_Amount__c=50, Potential_Billable_Amount__c=50);
        insert newAssignedFee;
    }

    static public void createTitleLateFeeData()	{
        Id titleInfoCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TITLE_INFO_RT).getRecordTypeId();
        
        List<Fee__c> fees = [SELECT Id, Name, Default_Amount__c, Max_Allowable_Fees__c FROM Fee__c WHERE Name = 'Title Late Fee' AND Type__c = 'Seller Fee' LIMIT 1];
        if(fees == null || fees.size() == 0) {
            Fee__c aFee = new Fee__c(Name = 'Title Late Fee', Default_Amount__c=25, Max_Allowable_Fees__c=250, Type__c='Seller Fee');
            insert aFee;
        }
        
        String acctUniqueName = 'TitleLateFee #1';
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Late_Title_Fee_Eligible__c = true;
        newSellerAcct.Late_Title_Fee_Start_Date__c = System.today().addDays(-5); // 5 days ago
        newSellerAcct.Unpaid_Title_Late_Fee__c = false;
        //newSellerAcct.Total_Billable_Amount__c = 0;
        //newSellerAcct.Potential_Billable_Amount__c = 0;

        Contact newContact = createContact(newSellerAcct);
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;    
        newAuction.Payment_Status__c = 'Paid';
        insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.Title_Received_Date__c = null;        
        insert newTitleCase;
        
        newTitleCase.Title_Due_Date__c = System.today().addDays(-1);
        update newTitleCase;        
    }
    
    static public void createCaseWithQualityControl()	{
        String acctUniqueName = 'EasyPostTest #5';
        Account newBuyerAcct = createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        newSellerAcct.IST_Account_Owner__c = '0050a00000JAbJiAAL';
        
        Contact newContact = createContact(newSellerAcct);
        //newContact.Email = 'msingh@vaseer.com';
        Vehicle__c newVehicle = createVehicle();

        SObject[] newObjs = new SObject[] {newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Name = acctUniqueName;
        newAuction.id__c = acctUniqueName;        
        newAuction.Payment_Status__c = 'Paid';
        newAuction.Payment_Method__c= 'adi';
        insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        newTitleCase.IST_Account_Owner_Lookup__c = '0050a00000JAbJiAAL';
        insert newTitleCase;

        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;        
    }
    
    static public void deleteCasesOlderThanNDays(Integer days)	{
        //Case cases = [SELECT Id, LastModifiedDate FROM Case WHERE LastModifiedDate < LAST_N_DAYS:30];
        if(days < 0) throw new  IllegalArgumentException('days value cannot be negative.');
        Date d = System.today().addDays(-1*days);
        List<Case> cases = [SELECT Id FROM Case WHERE LastModifiedDate <= :d];
        delete cases;
    }
    
    static public void bulkUpdateCases(String fromStaus, String toStatus)	{
        //Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        //User newTitlesUser = createUser(p.Id);
        //User titlesUser = [SELECT Id from User WHERE ProfileId= :p.Id AND isActive=true LIMIT 1];
        
        List<Case> casesToUpdate = [SELECT Id, Status From Case WHERE Status= :fromStaus];
        for(Case c : casesToUpdate)	{
            c.Status = toStatus;
        }
        
        System.debug('* * * Total Cases to be Updated: ' + casesToUpdate.size());
        update casesToUpdate;
        
        List<Case> casesNotUpdated = [SELECT Id, Status From Case WHERE Status= :fromStaus];
        System.debug('* * * Total Cases not updated: ' + casesNotUpdated.size());
    }
    
    static public void createTrackRec(SObject sobj, Integer sortOrder)	{
        sObjectType objectType = sobj.getSObjectType();
        String sObjectName = objectType.getDescribe().getName();        
        String objId = sobj.Id;
        
        Track_Id_to_Delete__c tRec = new Track_Id_to_Delete__c(Obj_Id__c=objId, Obj_Name__c=sObjectName, Sort_Order__c=sortOrder);
        tRecs.add(tRec);
    }
    
    static public void saveTrackRecs()	{
        if(tRecs.size() > 0)	{
            insert tRecs;
        }
        
        tRecs = new List<Track_Id_to_Delete__c>();
    }

    static public void deleteTrackRecsWithSortOrder(Integer recsToDelWithSortOrder)	{
        List<Track_Id_to_Delete__c> ids = [SELECT Id, Obj_Id__c, Obj_Name__c, Sort_Order__c, LastModifiedById FROM Track_Id_to_Delete__c WHERE Sort_Order__c = :recsToDelWithSortOrder];
        deleteTrackRecs(ids);
    }

    static public void deleteAllTrackRecs()	{
        List<Track_Id_to_Delete__c> ids = [SELECT Id, Obj_Id__c, Obj_Name__c, Sort_Order__c, LastModifiedById FROM Track_Id_to_Delete__c ORDER BY Sort_Order__c DESC];
        deleteTrackRecs(ids);
    }
    
	// SELECT Id, Obj_Id__c, Obj_Name__c, Sort_Order__c, LastModifiedById FROM Track_Id_to_Delete__c    
    static private void deleteTrackRecs(List<Track_Id_to_Delete__c> ids)	{
        List<Integer> sortOrderList = new List<Integer>();
        Map<Integer,String> sortOrderObjNameMap = new Map<Integer,String>();
        Map<Integer,List<Track_Id_to_Delete__c>> sortOrderTrackRecsMap = new Map<Integer,List<Track_Id_to_Delete__c>>();
        Integer tempSortOrder = -1;
        List<Track_Id_to_Delete__c> trs;
        
        /*
         * This 'for' loop is responsible for creating a Map of Sort Order and associated Object Name.
         * This 'for' look also create a Map of Sort Order and associated Track_Id_to_Delete__c records.
         * 
         * Later these 2 maps will be used to delete all the Track_Id_to_Delete__c 
         * (along with object.records represented by Ids in Track_Id_to_Delete__c) records starting for the hightest Sort Order,
         * until all records are deleted (to lowest Sort Order).
         * 
         * Highest Sort Order is assumed that the records has no dependencies (not parent). That is, these are the leaf records.
         * Lowest Sort Order is assumed that the records has dependencies (has associated children records). That is, these are parent records.
         * 
         */         
        for(Track_Id_to_Delete__c tr : ids)	{            
            if(tempSortOrder != tr.Sort_Order__c)	{
                tempSortOrder = (Integer) tr.Sort_Order__c; 
                sortOrderList.add(tempSortOrder);
                trs = sortOrderTrackRecsMap.get(tempSortOrder);
                if(trs == null)	{
                    trs = new List<Track_Id_to_Delete__c>();
                    sortOrderTrackRecsMap.put(tempSortOrder, trs);
                    sortOrderObjNameMap.put(tempSortOrder,tr.Obj_Name__c);
                }
            }
            
            trs.add(tr);
        }
        
        /*
         * Delete records one Sort Order at a time.
         * 
         */        
        for(Integer so : sortOrderList)	{
            List<Track_Id_to_Delete__c> trs2 = sortOrderTrackRecsMap.get(so);
            List<Id> idsToDel = new List<Id>();
            for(Track_Id_to_Delete__c tr : trs2)	{
            	System.debug('* * * tr: ' +  tr);
                idsToDel.add(tr.Obj_Id__c);
            }

            String objName = sortOrderObjNameMap.get(so);
            String sql = 'SELECT Id FROM ' + objName + ' WHERE Id IN (';
            for(String s : idsToDel)	{
                sql = sql + '\'' + s + '\',';
            }
            sql = sql.removeEnd(',');
            sql = sql + ')';
            
            System.debug('* * * sql: ' + sql);
            
            List<sObject> recsToDel = Database.query(sql);
            System.debug('* * * recsToDel size: ' + recsToDel.size());
            System.debug('* * * recsToDel: ' + recsToDel);
            delete recsToDel;
            
            System.debug('* * * trs2 size: ' + trs2.size());
            System.debug('* * * trs2: ' + trs2);
            delete trs2;
        }
    }
    
    static public void bulkCreateCases(String acctUniqueName, String auctionId, String auctionName, String titleStatus, String titleSubject, Integer totalNumOfCasesToCreate)	{
        Boolean createCaseWithAuctionBuyer = true;
        
        Account newAcctSeller = createAccount(acctUniqueName + ' (Seller)');
        Account newAcctBuyer = createAccount(acctUniqueName + ' (Buyer)');
        Account newAcctBuyerAuction = createAccount(acctUniqueName + ' (Auction Buyer)');
        
        Contact newContactSeller = createContact(newAcctSeller);
        newContactSeller.LastName = 'Seller';
        Contact newContactBuyer = createContact(newAcctBuyer);
        newContactBuyer.LastName = 'Buyer';
        
        Vehicle__c newVehicle = createVehicle();
        
        SObject[] newObjs = new SObject[] {newAcctBuyerAuction, newAcctSeller, newAcctBuyer, newContactSeller, newContactBuyer, newVehicle};
        insert newObjs;        

        createTrackRec(newAcctSeller, 1);
        createTrackRec(newAcctBuyer, 1);
        createTrackRec(newAcctBuyerAuction, 1);
        createTrackRec(newContactSeller, 2);
        createTrackRec(newContactBuyer, 2);        
        createTrackRec(newVehicle, 3);
        
        Auction__c newAuction = createAuction(newAcctSeller, newContactSeller, newVehicle);
        newAuction.Buyer_Dealership__c = newAcctBuyerAuction.Id;
        newAuction.Seller_Dealership__c = newAcctSeller.Id;
        newAuction.Name = auctionName;
        newAuction.id__c = auctionId;
		insert newAuction;
        createTrackRec(newAuction, 4);
        
        List<Case> newCases = new List<Case>();
        for(Integer i = 0; i < totalNumOfCasesToCreate; i++)	{
            Case newTitleCase = createTitleCase(newAuction, newAcctBuyer, newContactSeller);
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
        insert newCases;
        
        for(Case c : newCases)	createTrackRec(c, 5);
        
		saveTrackRecs();        
    }
    
    static public void updateStatusAndS3Image()	{
		Case updateCase = [SELECT Id, Status, Image_Location__c From Case WHERE CaseNumber = '03049731']; 
        updateCase.Status = 'Working';
        updateCase.Image_Location__c = 'https://acv-titles.s3.amazonaws.com/1609950915023.9717-MFP12232089-23/pdf/DOC010621-01062021113404.pdf?AWSAccessKeyId=AKIAUJBISKUOSVGENNGX&Expires=1610037315&Signature=YWQFFnqg8FcdVQrAbxscVlC1cJo%3D';
		//updateCase.Image_Location__c = 'https://acv-titles.s3.amazonaws.com/1609954994216.3289-MFP11826039-25/pdf/DOC010621-01062021121937.pdf?AWSAccessKeyId=AKIAUJBISKUOSVGENNGX&Expires=1610041394&Signature=RXjm5tC0KKC2%2FHkCwuPl9H%2BWMcA%3D';
		update updateCase;        
    }
    static public void createCompleteTitleCase(String acctUniqueName, String auctionId, String auctionName, String titleStatus, String titleSubject, Boolean createCaseWithAuctionBuyer)	{
            //insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
            
        Account newAcctSeller = createAccount(acctUniqueName + ' (Seller)');
        Account newAcctBuyer = createAccount(acctUniqueName + ' (Buyer)');
        Account newAcctBuyerAuction = createAccount(acctUniqueName + ' (Auction Buyer)');
        
        Contact newContactSeller = createContact(newAcctSeller);
        newContactSeller.LastName = 'Seller';
        Contact newContactBuyer = createContact(newAcctBuyer);
        newContactBuyer.LastName = 'Buyer';
        
        Vehicle__c newVehicle = createVehicle();
        
        SObject[] newObjs = new SObject[] {newAcctBuyerAuction, newAcctSeller, newAcctBuyer, newContactSeller, newContactBuyer, newVehicle};
        insert newObjs;        

        Auction__c newAuction = createAuction(newAcctSeller, newContactSeller, newVehicle);
        newAuction.Buyer_Dealership__c = newAcctBuyerAuction.Id;
        newAuction.Seller_Dealership__c = newAcctSeller.Id;
        newAuction.Name = auctionName;
        newAuction.id__c = auctionId;
		insert newAuction;
        
		Case newTitleCase = createTitleCase(newAuction, newAcctBuyer, newContactSeller);
        /*
         * - On Case,  AccountId is set to Buyer.
         * - If AccountId on Case is already set when creating a new Case record then it will not be overwritten by Auction.Buyer_Dealership__c.  However, Auction will still use Buyer_Dealership__c (not the one on Case).
         * - If AccountId on Case is already NOT set when creating a new Case record then it will use Auction.Buyer_Dealership__c. 
         */
        if(createCaseWithAuctionBuyer) newTitleCase.AccountId = null;
        newTitleCase.Status = titleStatus;
        newTitleCase.Subject = titleSubject;
        insert newTitleCase;
    }
    
    static public void createTitleCase()	{
        
        Auction__c newAuction = [SELECT Id From Auction__c WHERE Id = 'a0d1F000003YIo2']; 
		List<Account> accountList = [SELECT Id FROM Account WHERE Id IN ('0011F00000s5kUDQAY', '0011F00000s5kUEQAY')]; // fist seller and 2nd buyer
        List<Contact> contactList = [SELECT Id FROM Contact WHERE Id IN ('0031F00000iyg2IQAQ', '0031F00000iyg2JQAQ')]; /// fist seller and 2nd buyer

        Case titleCase = createTitleCase('Title Testing #6', 'Sent', newAuction, accountList[0], contactList[0]);
        insert titleCase;
    }
    
    
        static public void createData(){
            insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
            List<Account> accountList = New List<Account>();
            accountList.add(new Account(Dealership_ID__c = '456', Name='seller',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', legal_Name__c='seller', dealer_type__c='1'));
            accountList.add(new Account(Dealership_ID__c = '123', Name='buyer',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', legal_Name__c='buyer', dealer_type__c='1'));
            insert accountList;
            List<Contact> contactList = new List<Contact>();
            contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id, Active__c = TRUE, ACV_Updated__c = Datetime.now().addMinutes(-5)));
            contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id, Active__c = TRUE, ACV_Updated__c = Datetime.now().addMinutes(-5)));
            insert contactList;
            vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
            insert newCar;
            vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
            insert newCar1;
            auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[0].id, 
            Seller_Dealership__c = accountList[1].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
            insert newAuction;
    
            Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
            Case newCase = new Case( accountId = accountList[0].id, RecordTypeId = arbRecordType, Vehicle__c = newCar.id, status= 'Awaiting Release', Buyer_s_Assurance_Exceptions__c = 'Goodwill', ACV_Titles_External_ID__c='456' ); //, Denial_status__C = 'Denial Pending'
            insert newCase;
            Case titleCase = createTitleCase('Title Testing', 'New', newAuction, accountList[0], contactList[0]);
            insert titleCase;
    
            /*PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Related_Case_Object_Access'];
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
            User u = TestUtility.createUser(p.Id);
            insert u;
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
            }*/
    }

    /**
     * Creates an Account with the running users default Record Type and a custom Name
     * @param  uniqueName The Custom Name we want for the Account
     * @return            Basic Account with a custom name
     */
    public static Account createAccount(String uniqueName){
        Account actobj = New Account();
        actobj.Name = uniqueName;
        actobj.Phone = '7161234560';
        actobj.BillingStreet = '12 Test St';
        actobj.BillingCity = 'Buffalo';
        actobj.BillingState = 'NY';
        actobj.BillingPostalCode = '14228';
        actobj.BillingCountry = 'US';
        actobj.legal_Name__c= uniqueName;
        actobj.dealer_type__c='1';
        return actobj;
    }
    
    /**
     * Creates a ACV User cotact record that represnts the a User in the ACV App
     * This class disables a callout so you don't have to.
     * @param  actObj The Account that the User is related to
     * @return        Valid ACV User Contact
     */
    public static Contact createContact(Account actObj){
        Id acvUserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();

        SalesforceGatewayUserCreateLogic.disableGatewayLogic();
        contact conObj = New Contact();
        conObj.firstName = 'TestNameContact';
        conObj.LastName = 'TestNameLastName';
        conObj.Email = ACVUtility.NewGuid()+'@test.com';
        conObj.AccountId = actObj.Id;
        conObj.Phone = '7161234560';
        conObj.RecordTypeId = acvUserRecordTypeId;
        return conObj;
    }

    /**
     * Creates a simple Vehicle__c record
     * @return   Hard coded values for a Rav4 and MSRP of 26640.0
     */
    public static Vehicle__c createVehicle(){
        Vehicle__c vehicleObj = New Vehicle__c();
        vehicleObj.basic_color__c='4';
        vehicleObj.class_name__c='Small Crossover/SUV';
        vehicleObj.drivetrain__c='AWD';
        vehicleObj.fuel_type__c='Gas';
        vehicleObj.model__c='Rav4';
        vehicleObj.msrp__c = 26640.0;
        vehicleObj.Name ='TestVehicle';
        return vehicleObj;
    }

    /**
     * Creates an Auction__c record with prepopulated values
     * @param  actObj     Represents an Account that is used as both the seller and the buyer
     * @param  conObj     Represents the Buyer Contact
     * @param  vehicleobj The Vehicle__c that the auction is for
     * @return            Returns back an Auction__c record with an id__c of 123456 and buyer and seller information populated
     */
    public static Auction__c createAuction(Account actObj, Contact conObj, Vehicle__c vehicleobj){
        Auction__c auctionObj = New Auction__c(
            id__c = '123456',
            floor_price__c=6000.0,
            Name='TestAuction',
            notes__c='Car was sold as it is',
            vehicle_id__c=vehicleobj.Id,
            buyer_dealership__c = actObj.Id,
            seller_dealership__c = actObj.Id,
            buyer_contact__c = conObj.Id,
            end_time__c= system.today()
        );
        return auctionObj;
    }
 
    /**
     * Creates a Title Cas with no seller set
     * @param  auctionObj The auction that we are working a title for
     * @param  accountObj The Buyer Account
     * @param  conObj     The Buyer Contact
     * @return            Returns a Title Case in the 'Received' status
     */
    public static Case createTitleCase(Auction__c auctionObj, Account accountObj, Contact conObj){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case caseObj = new Case(
            Status = 'Received',
            Auction_Number__c = auctionObj.Id,
            AccountId = accountObj.Id,
            ContactId = conObj.Id,
            Subject = 'Title Testing',
            RecordTypeId = caseRecordTypeId,
            Easypost_Parcel_Predefined_Package__c = 'FedExEnvelope',
            Easypost_Parcel_Weight__c = 10,
            Default_Delivery_Address__c = '12 Test St',
            Default_Delivery_Address_Line2__c = 'Suite 1',
            Default_Delivery_City__c = 'Buffalo',
            Default_Delivery_State__c = 'NY',
            Default_Delivery_Postal_Code__c = '14228',
            Pickup_Address__c = '12 Test St',
            Pick_Up_Address_Line_2__c = 'Suite 1',
            Default_Pickup_City__c = 'Buffalo',
            Default_Pickup_State__c = 'NY',
            Default_Pickup_Postal_Code__c = '14228',
            ACV_Titles_External_ID__c = ACVUtility.NewGuid(),
            Image_Location__c='https://acv-titles.s3.amazonaws.com/1609954994216.3289-MFP11826039-25/pdf/DOC010621-01062021121937.pdf?AWSAccessKeyId=AKIAUJBISKUOSVGENNGX&Expires=1610041394&Signature=RXjm5tC0KKC2%2FHkCwuPl9H%2BWMcA%3D'
        );
        return caseObj;
    }
    
    /**
     * Creates a Title Cas with no seller set
     * @param  auctionObj The auction that we are working a title for
     * @param  accountObj The Buyer Account
     * @param  conObj     The Buyer Contact
     * @return            Returns a Title Case in the 'Received' status
     */
    public static Case createTitleCase(String caseSubject, String caseStatus, Auction__c auctionObj, Account accountObj, Contact conObj){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        Case caseObj = new Case(
            Status = caseStatus,
            Auction_Number__c = auctionObj.Id,
            AccountId = accountObj.Id,
            ContactId = conObj.Id,
            Subject = caseSubject,
            RecordTypeId = caseRecordTypeId,
            Easypost_Parcel_Predefined_Package__c = 'FedExEnvelope',
            Easypost_Parcel_Weight__c = 10,
            Default_Delivery_Address__c = '12 Test St',
            Default_Delivery_Address_Line2__c = 'Suite 1',
            Default_Delivery_City__c = 'Buffalo',
            Default_Delivery_State__c = 'NY',
            Default_Delivery_Postal_Code__c = '14228',
            Pickup_Address__c = '12 Test St',
            Pick_Up_Address_Line_2__c = 'Suite 1',
            Default_Pickup_City__c = 'Buffalo',
            Default_Pickup_State__c = 'NY',
            Default_Pickup_Postal_Code__c = '14228',
            ACV_Titles_External_ID__c = ACVUtility.NewGuid(),
            Image_Location__c='https://acv-titles.s3.amazonaws.com/1609954994216.3289-MFP11826039-25/pdf/DOC010621-01062021121937.pdf?AWSAccessKeyId=AKIAUJBISKUOSVGENNGX&Expires=1610041394&Signature=RXjm5tC0KKC2%2FHkCwuPl9H%2BWMcA%3D'
        );
        return caseObj;
    }
 
    public static User createUser( Id pId ) {
        String uniqueUserName = 'testuser' + ACVUtility.NewGuid() + '@test.com';
        
        User newUser = new User(Alias = 'standt', Email=uniqueUserName, EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = pId, TimeZoneSidKey='America/New_York', UserName=uniqueUserName);

        return newUser;
    }

    
}