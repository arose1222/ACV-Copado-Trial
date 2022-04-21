/**
 * @description Salesforce Auction Id is missing on Case when a digital Case is created before Auction.
 * This trigger will backfill the missing Acution Id on Case.
 * 
 * 
 * @author Manmeet Vaseer
 * @date 04/07/2022
 * 
 * @history
 * 		04/07/2022 Manmeet Vaseer - Initial Revision.
 * 
 */ 
@isTest
public class TitleServiceUpdateCaseTest {
    @isTest
    public static void testCreatedEventWithoutAuction() {
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
        
        List<Case> cases = [SELECT Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');

        List<Title__c> titles = [SELECT Legacy_Auction_Id__c FROM Title__c];
		System.assertEquals(1, titles.size(), 'There should be only one new Title record created.');
        
        System.assertEquals(String.valueOf(td.legacyAuctionId), titles[0].Legacy_Auction_Id__c, 'External Auction Number.');
        System.assertEquals(null, cases[0].Auction_Number__c, 'Case Auction id.');

        //
		// Adding a new Auction will trigger TitleServiceUpdateCase class and update the Auction Id on Case.        
		// 
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newSellerContact, newVehicle);        
        newAuction.Name = '2';        
        newObjs = new SObject[] {newAuction};
        insert newObjs;

        cases = [SELECT Id, Title__c, RecordTypeId, ACV_Titles_External_ID__c, Title_Attached__c, Digital_Title__c, Status, AccountId, ContactId, Seller_Dealership__c, Vehicle__c, Vehicle_VIN__c, Auction_Number__c FROM Case];
		System.assertEquals(1, cases.size(), 'There should be only one new Case record created.');
        System.assertEquals(newAuction.Name, titles[0].Legacy_Auction_Id__c, 'External Auction Number.');
        System.assertEquals(newAuction.Id, cases[0].Auction_Number__c, 'Case Auction id.');
        
        Test.stopTest();
    }
}