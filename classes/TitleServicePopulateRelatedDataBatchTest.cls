/**
 * @description A batch process to populate missing Related records on Cases.
 * 				A shell Case record is created in TitleService to avoid ROW LOCK error. This batch process populated the missing related info on Cases where
 * 				Title__c.Is_Pending_Related_Info__c is True (i.e. related info missing).
 * 
 * @author Manmeet Vaseer
 * @date 04/27/2022
 * 
 * @history
 * 		04/27/2022 Manmeet Vaseer - Initial.
 * 
 */
@isTest
public class TitleServicePopulateRelatedDataBatchTest {
    
    @isTest
    public static void testPopulateMissingRelatedData() {
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
        
        List<Case> cases = [SELECT Id, Title__c, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Seller_Contact__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c, Legacy_Auction_Id__c, Is_Pending_Related_Info__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');
        
        System.assertEquals(caseRecordTypeId, cases[0].RecordTypeId, 'Case record type id.');
        System.assertEquals(td.titleId, cases[0].ACV_Titles_External_ID__c, 'Case record Title External Id.');
        System.assertEquals(td.titleAbsent, cases[0].Title_Attached__c, 'Case record title attached.');
        System.assertEquals(td.digitalTitle, cases[0].Digital_Title__c, 'Case record digital title.');
        System.assertEquals(td.status, cases[0].Status, 'Case record status.');
        System.assertEquals(null, cases[0].AccountId, 'Case buyer account id.');
        System.assertEquals(null, cases[0].ContactId, 'Case buyer contact id.');
        System.assertEquals(null, cases[0].Seller_Dealership__c, 'Case seller account id.');
        System.assertEquals(null, cases[0].Seller_Contact__c, 'Case seller contact id.');
        System.assertEquals(null, cases[0].Vehicle__c, 'Case vehicle id.');
        System.assertEquals(ve.vin, cases[0].Vehicle_VIN__c, 'Case VIN.');
        System.assertEquals(null, cases[0].Auction_Number__c, 'Case Auction id.');
        
        System.assertEquals(digitalTitleRecordTypeId, titles[0].RecordTypeId, 'Title record type id.');
        System.assertEquals(td.titleId, titles[0].Name, 'Title Name - Title External Id.');
        System.assertEquals(td.titleIdType, titles[0].Title_Id_Type__c, 'Title Id Type.');
        System.assertEquals(cases[0].Id, titles[0].Case__c, 'Title associated Case id.');
        System.assertEquals(newAuction.Name, titles[0].Legacy_Auction_Id__c, 'External Auction Number.');
        System.assertEquals(titles[0].Id, cases[0].Title__c, 'Assosiated Title with Case.');
        System.assertEquals(true, titles[0].Is_Pending_Related_Info__c, 'Pending Related Info should be true.');
        
		// Run the Batch - Populate Related Case & Title data
        TitleServicePopulateRelatedDataBatch batch = new TitleServicePopulateRelatedDataBatch();
        List<Title__c> qTitles = Database.query(batch.getQuery());
        batch.populateMissingRelatedData(qTitles);

        cases = [SELECT Id, Title__c, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Seller_Contact__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        titles = [SELECT Id, Name, RecordTypeId, Title_Id_Type__c, Case__c, Legacy_Auction_Id__c, Is_Pending_Related_Info__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');
        
        System.assertEquals(caseRecordTypeId, cases[0].RecordTypeId, 'Case record type id.');
        System.assertEquals(td.titleId, cases[0].ACV_Titles_External_ID__c, 'Case record Title External Id.');
        System.assertEquals(td.titleAbsent, cases[0].Title_Attached__c, 'Case record title attached.');
        System.assertEquals(td.digitalTitle, cases[0].Digital_Title__c, 'Case record digital title.');
        System.assertEquals(td.status, cases[0].Status, 'Case record status.');
        System.assertEquals(newBuyerAcct.Id, cases[0].AccountId, 'Case buyer account id.');
        System.assertEquals(newBuyerContact.Id, cases[0].ContactId, 'Case buyer contact id.');
        System.assertEquals(newSellerAcct.Id, cases[0].Seller_Dealership__c, 'Case seller account id.');
        System.assertEquals(newSellerContact.Id, cases[0].Seller_Contact__c, 'Case seller contact id.');
        System.assertEquals(newVehicle.Id, cases[0].Vehicle__c, 'Case vehicle id.');
        System.assertEquals(ve.vin, cases[0].Vehicle_VIN__c, 'Case VIN.');
        System.assertEquals(newAuction.Id, cases[0].Auction_Number__c, 'Case Auction id.');
        
        System.assertEquals(digitalTitleRecordTypeId, titles[0].RecordTypeId, 'Title record type id.');
        System.assertEquals(td.titleId, titles[0].Name, 'Title Name - Title External Id.');
        System.assertEquals(td.titleIdType, titles[0].Title_Id_Type__c, 'Title Id Type.');
        System.assertEquals(cases[0].Id, titles[0].Case__c, 'Title associated Case id.');
        System.assertEquals(newAuction.Name, titles[0].Legacy_Auction_Id__c, 'External Auction Number.');
        System.assertEquals(titles[0].Id, cases[0].Title__c, 'Assosiated Title with Case.');
        System.assertEquals(false, titles[0].Is_Pending_Related_Info__c, 'Pending Related Info should be false.');
        
        Test.stopTest();
    }

}