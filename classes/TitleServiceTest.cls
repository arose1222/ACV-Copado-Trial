/**
 * @description Unit tests for TitleService class.
 * 
 * 
 * Requirements:
 * https://acvauctions.atlassian.net/browse/TDO-355
 * https://acvauctions.atlassian.net/browse/TDO-374
 * 
 * @author Manmeet Vaseer
 * @date 11/08/2021
 * 
 * @history
 * 		03/08/2022 Manmeet Vaseer - Added new Case.Title__c field and populate it in the Created event.
 * 		03/14/2022 Manmeet Vaseer - Title Review created & updated events addded.
 * 
 */ 
@isTest
public class TitleServiceTest {

    @isTest
    public static void testCreatedEvent() {
        // Begin - Setup Data
        String sellerAcctUniqueName = 'Seller TitleServiceTest';
        Account newSellerAcct = TestUtility.createAccount(sellerAcctUniqueName);
        newSellerAcct.Dealership_ID__c = '5';
        
        String buyerAcctUniqueName = 'Buyer TitleServiceTest';
        Account newBuyerAcct = TestUtility.createAccount(buyerAcctUniqueName);        
        newBuyerAcct.Dealership_ID__c = '6';
        
        SObject[] newObjs = new SObject[] {newSellerAcct, newBuyerAcct};
        insert newObjs;
        
        Contact newSellerContact = TestUtility.createContact(newSellerAcct);
        newSellerContact.Active__c = true;
        newSellerContact.Email = 'seller@dealership.com';
        newSellerContact.Title = 'Title Clerk';
		newSellerContact.ID__c = '3';

        Contact newBuyerContact = TestUtility.createContact(newBuyerAcct);
        newBuyerContact.Active__c = true;
        newBuyerContact.Email = 'buyer@dealership.com';
        newBuyerContact.Title = 'Title Clerk';
		newBuyerContact.ID__c = '4';
        
        newObjs = new SObject[] {newSellerContact, newBuyerContact};
        insert newObjs;
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        newVehicle.Name = '1J4F4C9SX5P328524';
        newVehicle.Vin__c = '1J4F4C9SX5P328524';
        newObjs = new SObject[] {newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';        
        newObjs = new SObject[] {newAuction};
        insert newObjs;

		List<TitleDefinition> titleList = new List<TitleDefinition>();
        
        TitleDefinition.VehicleInfo ve = new TitleDefinition.VehicleInfo();
        ve.make='jeep';
        ve.model='wrangler';
        ve.odometer=20000;
        ve.vin='1J4F4C9SX5P328524';
        ve.year='2020';
        
        TitleDefinition.MetaInfo md = new TitleDefinition.MetaInfo();
        md.entity='title';
        md.version='2.0';
        md.eventId='1000';
        md.correlationId='1000a';
        md.eventType='created';
        md.timestamp=System.now();
        md.domain='title';
        md.listOfAvailableFieldNamesInJson=null;
            
        TitleDefinition td = new TitleDefinition();
        td.fromHistoricalLoad=false;
        td.titleId='1a';
        td.legacyTitleId=1;
        td.titleIdType='guid';
        td.legacyAuctionId=2;
        td.titleAbsent=false;
        td.sellerUserId=3;
        td.buyerUserId=4;
        td.sellerOrganizationId=5;
        td.buyerOrganizationId=6;
        td.digitalTitle=true;
        td.legacyStatus=null;
        td.status='New';
        td.vehicle=ve;
        td.payment=null;
        td.metadata=md;
        
        titleList.add(td);
        // End - Setup Data
        
        Test.startTest();
        TitleService.processTitles(titleList);
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
        List<Case> cases = [SELECT Id, Title__c, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c, Legacy_Auction_Id__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');
        
        System.assertEquals(caseRecordTypeId, cases[0].RecordTypeId, 'Case record type id.');
        System.assertEquals(td.titleId, cases[0].ACV_Titles_External_ID__c, 'Case record Title External Id.');
        System.assertEquals(td.titleAbsent, cases[0].Title_Attached__c, 'Case record title attached.');
        System.assertEquals(td.digitalTitle, cases[0].Digital_Title__c, 'Case record digital title.');
        System.assertEquals(td.status, cases[0].Status, 'Case record status.');
        System.assertEquals(newBuyerAcct.Id, cases[0].AccountId, 'Case buyer account id.');
        System.assertEquals(newBuyerContact.Id, cases[0].ContactId, 'Case buyer contact id.');
        System.assertEquals(newSellerAcct.Id, cases[0].Seller_Dealership__c, 'Case seller account id.');
        System.assertEquals(newVehicle.Id, cases[0].Vehicle__c, 'Case vehicle id.');
        System.assertEquals(ve.vin, cases[0].Vehicle_VIN__c, 'Case VIN.');
        System.assertEquals(newAuction.Id, cases[0].Auction_Number__c, 'Case Auction id.');
        
        System.assertEquals(digitalTitleRecordTypeId, titles[0].RecordTypeId, 'Title record type id.');
        System.assertEquals(td.titleId, titles[0].Name, 'Title Name - Title External Id.');
        System.assertEquals(td.titleIdType, titles[0].Title_Id_Type__c, 'Title Id Type.');
        System.assertEquals(cases[0].Id, titles[0].Case__c, 'Title associated Case id.');
        System.assertEquals(newAuction.Name, titles[0].Legacy_Auction_Id__c, 'External Auction Number.');
        System.assertEquals(titles[0].Id, cases[0].Title__c, 'Assosiated Title with Case.');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdatedEvent() {
        // Setup Data Begins
        String sellerAcctUniqueName = 'Seller TitleServiceTest';
        Account newSellerAcct = TestUtility.createAccount(sellerAcctUniqueName);
        newSellerAcct.Dealership_ID__c = '5';
        
        String buyerAcctUniqueName = 'Buyer TitleServiceTest';
        Account newBuyerAcct = TestUtility.createAccount(buyerAcctUniqueName);        
        newBuyerAcct.Dealership_ID__c = '6';

        String sellerAcctUniqueName2 = 'Seller2 TitleServiceTest';
        Account newSellerAcct2 = TestUtility.createAccount(sellerAcctUniqueName2);
        newSellerAcct2.Dealership_ID__c = '50';
        
        String buyerAcctUniqueName2 = 'Buyer2 TitleServiceTest';
        Account newBuyerAcct2 = TestUtility.createAccount(buyerAcctUniqueName2);        
        newBuyerAcct2.Dealership_ID__c = '60';
        
        SObject[] newObjs = new SObject[] {newSellerAcct, newBuyerAcct, newSellerAcct2, newBuyerAcct2};
        insert newObjs;
        
        Contact newSellerContact = TestUtility.createContact(newSellerAcct);
        newSellerContact.Active__c = true;
        newSellerContact.Email = 'seller@dealership.com';
        newSellerContact.Title = 'Title Clerk';
		newSellerContact.ID__c = '3';

        Contact newSellerContact2 = TestUtility.createContact(newSellerAcct2);
        newSellerContact2.Active__c = true;
        newSellerContact2.Email = 'seller2@dealership.com';
        newSellerContact2.Title = 'Title Clerk';
		newSellerContact2.ID__c = '30';
        
        Contact newBuyerContact = TestUtility.createContact(newBuyerAcct);
        newBuyerContact.Active__c = true;
        newBuyerContact.Email = 'buyer@dealership.com';
        newBuyerContact.Title = 'Title Clerk';
		newBuyerContact.ID__c = '4';

        Contact newBuyerContact2 = TestUtility.createContact(newBuyerAcct2);
        newBuyerContact2.Active__c = true;
        newBuyerContact2.Email = 'buyer2@dealership.com';
        newBuyerContact2.Title = 'Title Clerk';
		newBuyerContact2.ID__c = '40';
        
        newObjs = new SObject[] {newSellerContact, newBuyerContact, newSellerContact2, newBuyerContact2};
        insert newObjs;
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        newVehicle.Name = '1J4F4C9SX5P328524';
        newVehicle.Vin__c = '1J4F4C9SX5P328524';
        
        Vehicle__c newVehicle2 = TestUtility.createVehicle();
        newVehicle2.Name = '1J4F4C9SX5P329080';
        newVehicle2.Vin__c = '1J4F4C9SX5P329080';
        
        newObjs = new SObject[] {newVehicle, newVehicle2};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';
        Auction__c newAuction2 = TestUtility.createAuction(newSellerAcct2, newSellerContact2, newVehicle2);        
        newAuction2.Name = '20';
		newAuction2.id__c = '123098';
        
        newObjs = new SObject[] {newAuction, newAuction2};
        insert newObjs;

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
		Case newTitleCase = new Case (
            RecordTypeId = caseRecordTypeId,
            ACV_Titles_External_ID__c = '1a',
            Title_Attached__c = false,
            Digital_Title__c = false,
            Status = 'New',
            AccountId = newBuyerAcct.Id,
            ContactId = newBuyerContact.Id,
            Seller_Dealership__c = newSellerAcct.Id,
            Vehicle__c = newVehicle.Id,
            Vehicle_VIN__c = newVehicle.Vin__c,
            Auction_Number__c = newAuction.Id
        );
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;

        Title__c aNewTitle = new Title__c (
            RecordTypeId = digitalTitleRecordTypeId,
            Name = '1a',
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
                
        newObjs = new SObject[] {aNewTitle};
        insert newObjs;
        
		// Check if the Case & Title__c is created successfully.        
        List<Case> cases = [SELECT Id, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');
        
        System.assertEquals(caseRecordTypeId, cases[0].RecordTypeId, 'Case record type id.');
        System.assertEquals(newTitleCase.ACV_Titles_External_ID__c, cases[0].ACV_Titles_External_ID__c, 'Case record Title External Id.');
        System.assertEquals(false, cases[0].Title_Attached__c, 'Case record title attached.');
        System.assertEquals(false, cases[0].Digital_Title__c, 'Case record digital title.');
        System.assertEquals(newTitleCase.Status, cases[0].Status, 'Case record status.');
        System.assertEquals(newBuyerAcct.Id, cases[0].AccountId, 'Case buyer account id.');
        System.assertEquals(newBuyerContact.Id, cases[0].ContactId, 'Case buyer contact id.');
        System.assertEquals(newSellerAcct.Id, cases[0].Seller_Dealership__c, 'Case seller account id.');
        System.assertEquals(newVehicle.Id, cases[0].Vehicle__c, 'Case vehicle id.');
        System.assertEquals(newVehicle.Name, cases[0].Vehicle_VIN__c, 'Case VIN.');
        System.assertEquals(newAuction.Id, cases[0].Auction_Number__c, 'Case Auction id.');
        
        System.assertEquals(digitalTitleRecordTypeId, titles[0].RecordTypeId, 'Title record type id.');
        System.assertEquals(newTitleCase.ACV_Titles_External_ID__c, titles[0].Name, 'Title Name - Title External Id.');
        System.assertEquals('guid', titles[0].Title_Id_Type__c, 'Title Id Type.');
        System.assertEquals(cases[0].Id, titles[0].Case__c, 'Title associated Case id.');
        
        //
        // Update the Case Info
        // 
		List<TitleDefinition> titleList = new List<TitleDefinition>();
        
        TitleDefinition.VehicleInfo ve = new TitleDefinition.VehicleInfo();
        ve.vin=newVehicle2.Name;
        
        TitleDefinition.MetaInfo md = new TitleDefinition.MetaInfo();
        md.entity='title';
        md.version='2.0';
        md.eventId='1000';
        md.correlationId='1000a';
        md.eventType='updated';
        md.timestamp=System.now();
        md.domain='title';
        md.listOfAvailableFieldNamesInJson= new List<String>{'fromHistoricalLoad','titleId','legacyTitleId','titleIdType','legacyAuctionId','titleAbsent',
            'sellerUserId','buyerUserId','sellerOrganizationId','buyerOrganizationId','digitalTitle','status','vehicle.vin','metadata.eventType'};
            
        TitleDefinition td = new TitleDefinition();
        td.fromHistoricalLoad=false;
        td.titleId='1a';
        td.legacyTitleId=1;
        td.titleIdType='guid';
        td.legacyAuctionId=20;
        td.titleAbsent=true;
        td.sellerUserId=30;
        td.buyerUserId=40;
        td.sellerOrganizationId=50;
        td.buyerOrganizationId=60;
        td.digitalTitle=true;
        td.legacyStatus=null;
        td.status='Working';
        td.vehicle=ve;
        td.payment=null;
        td.metadata=md;
        
        titleList.add(td);
        // Setup Data Ends
        
        Test.startTest();
        TitleService.processTitles(titleList); // Update Case
        
		// Check if the Case & Title__c is updated successfully.        
        cases = [SELECT Id, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record updated.');

        titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record updated.');
        
        System.assertEquals(caseRecordTypeId, cases[0].RecordTypeId, 'Case record type id.');
        System.assertEquals(newTitleCase.ACV_Titles_External_ID__c, cases[0].ACV_Titles_External_ID__c, 'Case record Title External Id.');
        System.assertEquals(true, cases[0].Title_Attached__c, 'Case record title attached.');
        System.assertEquals(true, cases[0].Digital_Title__c, 'Case record digital title.');
        System.assertEquals('Working', cases[0].Status, 'Case record status.');
        System.assertEquals(newBuyerAcct2.Id, cases[0].AccountId, 'Case buyer account id.');
        System.assertEquals(newBuyerContact2.Id, cases[0].ContactId, 'Case buyer contact id.');
        System.assertEquals(newSellerAcct2.Id, cases[0].Seller_Dealership__c, 'Case seller account id.');
        System.assertEquals(newVehicle2.Id, cases[0].Vehicle__c, 'Case vehicle id.');
        System.assertEquals(newVehicle2.Name, cases[0].Vehicle_VIN__c, 'Case VIN.');
        System.assertEquals(newAuction2.Id, cases[0].Auction_Number__c, 'Case Auction id.');
        
        System.assertEquals(digitalTitleRecordTypeId, titles[0].RecordTypeId, 'Title record type id.');
        System.assertEquals(newTitleCase.ACV_Titles_External_ID__c, titles[0].Name, 'Title Name - Title External Id.');
        System.assertEquals('guid', titles[0].Title_Id_Type__c, 'Title Id Type.');
        System.assertEquals(cases[0].Id, titles[0].Case__c, 'Title associated Case id.');
                
        Test.stopTest();
    }
   
 
    @isTest
    public static void testAddDealershipNoteEvent() {
        // Setup Data Begins
        String sellerAcctUniqueName = 'Seller TitleServiceTest';
        Account newSellerAcct = TestUtility.createAccount(sellerAcctUniqueName);
        newSellerAcct.Dealership_ID__c = '5';
        
        String buyerAcctUniqueName = 'Buyer TitleServiceTest';
        Account newBuyerAcct = TestUtility.createAccount(buyerAcctUniqueName);        
        newBuyerAcct.Dealership_ID__c = '6';

        String sellerAcctUniqueName2 = 'Seller2 TitleServiceTest';
        Account newSellerAcct2 = TestUtility.createAccount(sellerAcctUniqueName2);
        newSellerAcct2.Dealership_ID__c = '50';
        
        String buyerAcctUniqueName2 = 'Buyer2 TitleServiceTest';
        Account newBuyerAcct2 = TestUtility.createAccount(buyerAcctUniqueName2);        
        newBuyerAcct2.Dealership_ID__c = '60';
        
        SObject[] newObjs = new SObject[] {newSellerAcct, newBuyerAcct, newSellerAcct2, newBuyerAcct2};
        insert newObjs;
        
        Contact newSellerContact = TestUtility.createContact(newSellerAcct);
        newSellerContact.Active__c = true;
        newSellerContact.Email = 'seller@dealership.com';
        newSellerContact.Title = 'Title Clerk';
		newSellerContact.ID__c = '3';

        Contact newBuyerContact = TestUtility.createContact(newBuyerAcct);
        newBuyerContact.Active__c = true;
        newBuyerContact.Email = 'buyer@dealership.com';
        newBuyerContact.Title = 'Title Clerk';
		newBuyerContact.ID__c = '4';

        newObjs = new SObject[] {newSellerContact, newBuyerContact};
        insert newObjs;
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        newVehicle.Name = '1J4F4C9SX5P328524';
        newVehicle.Vin__c = '1J4F4C9SX5P328524';
        
        newObjs = new SObject[] {newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';
        
        newObjs = new SObject[] {newAuction};
        insert newObjs;

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
		Case newTitleCase = new Case (
            RecordTypeId = caseRecordTypeId,
            ACV_Titles_External_ID__c = '1a',
            Title_Attached__c = false,
            Digital_Title__c = false,
            Status = 'New',
            AccountId = newBuyerAcct.Id,
            ContactId = newBuyerContact.Id,
            Seller_Dealership__c = newSellerAcct.Id,
            Vehicle__c = newVehicle.Id,
            Vehicle_VIN__c = newVehicle.Vin__c,
            Auction_Number__c = newAuction.Id
        );
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;

        Title__c aNewTitle = new Title__c (
            RecordTypeId = digitalTitleRecordTypeId,
            Name = '1a',
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
                
        newObjs = new SObject[] {aNewTitle};
        insert newObjs;
        
		// Check if the Case & Title__c is created successfully.        
        List<Case> cases = [SELECT Id, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');

		List<TitleDefinition> titleList = new List<TitleDefinition>();
        
        TitleDefinition.MetaInfo md = new TitleDefinition.MetaInfo();
        md.entity='title';
        md.version='2.0';
        md.eventId='1000';
        md.correlationId='1000a';
        md.eventType='note-added';
        md.timestamp=System.now();
        md.domain='title';
        md.listOfAvailableFieldNamesInJson=null;
            
		TitleDefinition.DealershipNoteInfo dn = new TitleDefinition.DealershipNoteInfo();
        dn.authorId = 3; // seller user id (newSellerContact.ID__c)
        dn.noteId = 'note_gid';
        dn.note = 'dealership note description.';
        
        TitleDefinition td = new TitleDefinition();
        td.titleId='1a';
        td.legacyTitleId=null;
        td.titleIdType='guid';
        td.metadata=md;
        td.dealershipNote = dn;
        
        titleList.add(td);
        // End - Setup Data
        
        Test.startTest();
        TitleService.processTitles(titleList);

        List<Dealership_Note__c> notes = [SELECT Id, Name, Note__c, Title__c, Note_Author__c FROM Dealership_Note__c];
        
        System.assertEquals(dn.noteId, notes[0].Name, 'Note GUID.');
        System.assertEquals(dn.note, notes[0].Note__c, 'Note Description.');
        System.assertEquals(titles[0].Id, notes[0].Title__c, 'Title Salesforce Id.');
        System.assertEquals(newSellerContact.Id, notes[0].Note_Author__c, 'Note Aurthor Salesforce Id (Seller Contact Id).');
        
        Test.stopTest();
    }
    
    @isTest
    public static void testTitleReviewCreatedEvent() {
        // Setup Data Begins
        String sellerAcctUniqueName = 'Seller TitleServiceTest';
        Account newSellerAcct = TestUtility.createAccount(sellerAcctUniqueName);
        newSellerAcct.Dealership_ID__c = '5';
        
        String buyerAcctUniqueName = 'Buyer TitleServiceTest';
        Account newBuyerAcct = TestUtility.createAccount(buyerAcctUniqueName);        
        newBuyerAcct.Dealership_ID__c = '6';

        String sellerAcctUniqueName2 = 'Seller2 TitleServiceTest';
        Account newSellerAcct2 = TestUtility.createAccount(sellerAcctUniqueName2);
        newSellerAcct2.Dealership_ID__c = '50';
        
        String buyerAcctUniqueName2 = 'Buyer2 TitleServiceTest';
        Account newBuyerAcct2 = TestUtility.createAccount(buyerAcctUniqueName2);        
        newBuyerAcct2.Dealership_ID__c = '60';
        
        SObject[] newObjs = new SObject[] {newSellerAcct, newBuyerAcct, newSellerAcct2, newBuyerAcct2};
        insert newObjs;
        
        Contact newSellerContact = TestUtility.createContact(newSellerAcct);
        newSellerContact.Active__c = true;
        newSellerContact.Email = 'seller@dealership.com';
        newSellerContact.Title = 'Title Clerk';
		newSellerContact.ID__c = '3';

        Contact newBuyerContact = TestUtility.createContact(newBuyerAcct);
        newBuyerContact.Active__c = true;
        newBuyerContact.Email = 'buyer@dealership.com';
        newBuyerContact.Title = 'Title Clerk';
		newBuyerContact.ID__c = '4';

        newObjs = new SObject[] {newSellerContact, newBuyerContact};
        insert newObjs;
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        newVehicle.Name = '1J4F4C9SX5P328524';
        newVehicle.Vin__c = '1J4F4C9SX5P328524';
        
        newObjs = new SObject[] {newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';
        
        newObjs = new SObject[] {newAuction};
        insert newObjs;

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
		Case newTitleCase = new Case (
            RecordTypeId = caseRecordTypeId,
            ACV_Titles_External_ID__c = '1a',
            Title_Attached__c = false,
            Digital_Title__c = false,
            Status = 'New',
            AccountId = newBuyerAcct.Id,
            ContactId = newBuyerContact.Id,
            Seller_Dealership__c = newSellerAcct.Id,
            Vehicle__c = newVehicle.Id,
            Vehicle_VIN__c = newVehicle.Vin__c,
            Auction_Number__c = newAuction.Id
        );
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;

        Title__c aNewTitle = new Title__c (
            RecordTypeId = digitalTitleRecordTypeId,
            Name = '1a',
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
                
        newObjs = new SObject[] {aNewTitle};
        insert newObjs;
        
		// Check if the Case & Title__c is created successfully.        
        List<Case> cases = [SELECT Id, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');

		List<TitleDefinition> titleList = new List<TitleDefinition>();
        
        TitleDefinition.MetaInfo md = new TitleDefinition.MetaInfo();
        md.entity='title';
        md.version='2.0';
        md.eventId='1000';
        md.correlationId='1000a';
        md.eventType='title-review-created';
        md.timestamp=System.now();
        md.domain='title';
        md.listOfAvailableFieldNamesInJson=null;
            
		TitleDefinition.TitleReviewInfo tri = new TitleDefinition.TitleReviewInfo();
        tri.reviewId = 'review_guid';
        
        TitleDefinition td = new TitleDefinition();
        td.titleId='1a';
        td.legacyTitleId=null;
        td.titleIdType='guid';
        td.metadata=md;
        td.titleReview = tri;
        
        titleList.add(td);
        // End - Setup Data
        
        Test.startTest();
        TitleService.processTitles(titleList);

        List<Title_Review__c> trs = [SELECT Id, Name, Commit_Pending__c FROM Title_Review__c];
        
        System.assertEquals(tri.reviewId, trs[0].Name, 'Title Review GUID.');
        
        Test.stopTest();
    }

    @isTest
    public static void testTitleReviewUpdatedEvent() {
        // Setup Data Begins
        String sellerAcctUniqueName = 'Seller TitleServiceTest';
        Account newSellerAcct = TestUtility.createAccount(sellerAcctUniqueName);
        newSellerAcct.Dealership_ID__c = '5';
        
        String buyerAcctUniqueName = 'Buyer TitleServiceTest';
        Account newBuyerAcct = TestUtility.createAccount(buyerAcctUniqueName);        
        newBuyerAcct.Dealership_ID__c = '6';

        String sellerAcctUniqueName2 = 'Seller2 TitleServiceTest';
        Account newSellerAcct2 = TestUtility.createAccount(sellerAcctUniqueName2);
        newSellerAcct2.Dealership_ID__c = '50';
        
        String buyerAcctUniqueName2 = 'Buyer2 TitleServiceTest';
        Account newBuyerAcct2 = TestUtility.createAccount(buyerAcctUniqueName2);        
        newBuyerAcct2.Dealership_ID__c = '60';
        
        SObject[] newObjs = new SObject[] {newSellerAcct, newBuyerAcct, newSellerAcct2, newBuyerAcct2};
        insert newObjs;
        
        Contact newSellerContact = TestUtility.createContact(newSellerAcct);
        newSellerContact.Active__c = true;
        newSellerContact.Email = 'seller@dealership.com';
        newSellerContact.Title = 'Title Clerk';
		newSellerContact.ID__c = '3';

        Contact newBuyerContact = TestUtility.createContact(newBuyerAcct);
        newBuyerContact.Active__c = true;
        newBuyerContact.Email = 'buyer@dealership.com';
        newBuyerContact.Title = 'Title Clerk';
		newBuyerContact.ID__c = '4';

        newObjs = new SObject[] {newSellerContact, newBuyerContact};
        insert newObjs;
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        newVehicle.Name = '1J4F4C9SX5P328524';
        newVehicle.Vin__c = '1J4F4C9SX5P328524';
        
        newObjs = new SObject[] {newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';
        
        newObjs = new SObject[] {newAuction};
        insert newObjs;

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
		Case newTitleCase = new Case (
            RecordTypeId = caseRecordTypeId,
            ACV_Titles_External_ID__c = '1a',
            Title_Attached__c = false,
            Digital_Title__c = false,
            Status = 'New',
            AccountId = newBuyerAcct.Id,
            ContactId = newBuyerContact.Id,
            Seller_Dealership__c = newSellerAcct.Id,
            Vehicle__c = newVehicle.Id,
            Vehicle_VIN__c = newVehicle.Vin__c,
            Auction_Number__c = newAuction.Id
        );
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;

        Title__c aNewTitle = new Title__c (
            RecordTypeId = digitalTitleRecordTypeId,
            Name = '1a',
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
                
        newObjs = new SObject[] {aNewTitle};
        insert newObjs;
        
		// Check if the Case & Title__c is created successfully.        
        List<Case> cases = [SELECT Id, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');

		List<TitleDefinition> titleList = new List<TitleDefinition>();
        
        TitleDefinition.MetaInfo md = new TitleDefinition.MetaInfo();
        md.entity='title';
        md.version='2.0';
        md.eventId='1000';
        md.correlationId='1000a';
        md.eventType='title-review-created';
        md.timestamp=System.now();
        md.domain='title';
        md.listOfAvailableFieldNamesInJson=null;
            
		TitleDefinition.TitleReviewInfo tri = new TitleDefinition.TitleReviewInfo();
        tri.reviewId = 'review_guid';
        
        TitleDefinition td = new TitleDefinition();
        td.titleId='1a';
        td.legacyTitleId=null;
        td.titleIdType='guid';
        td.metadata=md;
        td.titleReview = tri;
        
        titleList.add(td);
        // End - Setup Data
        
        Test.startTest();
        TitleService.processTitles(titleList);

        // Created Title Review
        List<Title_Review__c> trs = [SELECT Id, Name, Commit_Pending__c FROM Title_Review__c];        
        System.assertEquals(tri.reviewId, trs[0].Name, 'Title Review GUID.');
        System.assertEquals(true, trs[0].Commit_Pending__c, 'Commit Pending.');
        
        // Updated Title Review
        md.listOfAvailableFieldNamesInJson= new List<String>{'titleId','legacyTitleId','titleIdType','metadata.eventType','reviewId','commitPending'};
        md.eventType='title-review-updated';
        tri.commitPending = false;
        TitleService.processTitles(titleList);

        trs = [SELECT Id, Name, Commit_Pending__c FROM Title_Review__c];        
        System.assertEquals(tri.reviewId, trs[0].Name, 'Title Review GUID.');
        System.assertEquals(false, trs[0].Commit_Pending__c, 'Commit Pending.');
        
        Test.stopTest();
    }
 
    @isTest
    public static void testAddTitleReviewDocument()
    {
         // Setup Data Begins
        String sellerAcctUniqueName = 'Seller TitleServiceTest';
        Account newSellerAcct = TestUtility.createAccount(sellerAcctUniqueName);
        newSellerAcct.Dealership_ID__c = '5';
        
        String buyerAcctUniqueName = 'Buyer TitleServiceTest';
        Account newBuyerAcct = TestUtility.createAccount(buyerAcctUniqueName);        
        newBuyerAcct.Dealership_ID__c = '6';

        String sellerAcctUniqueName2 = 'Seller2 TitleServiceTest';
        Account newSellerAcct2 = TestUtility.createAccount(sellerAcctUniqueName2);
        newSellerAcct2.Dealership_ID__c = '50';
        
        String buyerAcctUniqueName2 = 'Buyer2 TitleServiceTest';
        Account newBuyerAcct2 = TestUtility.createAccount(buyerAcctUniqueName2);        
        newBuyerAcct2.Dealership_ID__c = '60';
        
        SObject[] newObjs = new SObject[] {newSellerAcct, newBuyerAcct, newSellerAcct2, newBuyerAcct2};
        insert newObjs;
        
        Contact newSellerContact = TestUtility.createContact(newSellerAcct);
        newSellerContact.Active__c = true;
        newSellerContact.Email = 'seller@dealership.com';
        newSellerContact.Title = 'Title Clerk';
		newSellerContact.ID__c = '3';

        Contact newBuyerContact = TestUtility.createContact(newBuyerAcct);
        newBuyerContact.Active__c = true;
        newBuyerContact.Email = 'buyer@dealership.com';
        newBuyerContact.Title = 'Title Clerk';
		newBuyerContact.ID__c = '4';

        newObjs = new SObject[] {newSellerContact, newBuyerContact};
        insert newObjs;
        
        Vehicle__c newVehicle = TestUtility.createVehicle();
        newVehicle.Name = '1J4F4C9SX5P328524';
        newVehicle.Vin__c = '1J4F4C9SX5P328524';
        
        newObjs = new SObject[] {newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';
        
        newObjs = new SObject[] {newAuction};
        insert newObjs;

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
		Id digitalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Digital Title').getRecordTypeId();        
		Id physicalTitleRecordTypeId = Schema.getGlobalDescribe().get('Title__c').getDescribe().getRecordTypeInfosByName().get('Physical Title').getRecordTypeId();        
        
		Case newTitleCase = new Case (
            RecordTypeId = caseRecordTypeId,
            ACV_Titles_External_ID__c = '1a',
            Title_Attached__c = false,
            Digital_Title__c = false,
            Status = 'New',
            AccountId = newBuyerAcct.Id,
            ContactId = newBuyerContact.Id,
            Seller_Dealership__c = newSellerAcct.Id,
            Vehicle__c = newVehicle.Id,
            Vehicle_VIN__c = newVehicle.Vin__c,
            Auction_Number__c = newAuction.Id
        );
                
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;

        Title__c aNewTitle = new Title__c (
            RecordTypeId = digitalTitleRecordTypeId,
            Name = '1a',
            Title_Id_Type__c = 'guid',
            Case__c = newTitleCase.Id
        );
                
        newObjs = new SObject[] {aNewTitle};
        insert newObjs;
        
        Title_Review__c aNewTitleReview = new Title_Review__c (
            Name = '1a',
            Title__c = aNewTitle.Id
        );
        insert aNewTitleReview;
        
		// Check if the Case & Title__c is created successfully.        
        List<Title_Review__c> titleReviews = [SELECT Id, Name, Title__c FROM Title_Review__c];
		System.assertEquals(1, titleReviews.size(), 'There should be only one new Title Review record created.');

		List<TitleDefinition> titleList = new List<TitleDefinition>();
        
        TitleDefinition.MetaInfo md = new TitleDefinition.MetaInfo();
        md.entity='title';
        md.version='2.0';
        md.eventId='1000';
        md.correlationId='1000a';
        md.eventType='title-review-document-added';
        md.timestamp=System.now();
        md.domain='title';
        md.listOfAvailableFieldNamesInJson=null;

        TitleDefinition.TitleReviewDocumentInfo trdoc = new TitleDefinition.TitleReviewDocumentInfo();
        trdoc.documentId = 'docguid';
        trdoc.documentUri = 's3_url';
        trdoc.userId = 3;
            
		TitleDefinition.TitleReviewInfo tri = new TitleDefinition.TitleReviewInfo();
        tri.reviewId = 'review_guid';
        tri.salesforceId = aNewTitleReview.Id;
        tri.titleReviewDocument = trdoc;
        
        TitleDefinition td = new TitleDefinition();
        td.titleId='1a';
        td.legacyTitleId=null;
        td.titleIdType='guid';
        td.metadata=md;
        td.titleReview = tri;
        
        titleList.add(td);
        // End - Setup Data
        
        Test.startTest();
        TitleService.processTitles(titleList);

        List<Title_Review_Document__c> trds = [SELECT Id, Name, Document_URI__c, User_Id__c, Title_Review__c FROM Title_Review_Document__c];
		System.assertEquals(1, trds.size(), 'There should be only one new Title Review Document record created.');
        
        System.assertEquals(trdoc.documentId, trds[0].Name, 'Title Review Doc GUID.');
        System.assertEquals(trdoc.documentUri, trds[0].Document_URI__c, 'Title Review Doc URL.');
        System.assertNotEquals(null, trds[0].Title_Review__c, 'Title Review Id.');
        System.assertNotEquals(null, trds[0].User_Id__c, 'Title Review Doc Contact Id.');
        
        Test.stopTest();       
    }
}