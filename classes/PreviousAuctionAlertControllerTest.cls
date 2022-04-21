/**
 * Test Class of PreviousAuctionAlertController
 * @author Ravi Shukla
 * @since Jan 27th, 2022
 */
@isTest
public class PreviousAuctionAlertControllerTest {
@TestSetup
    static void makeData(){
        
      //Create new account record
        Account a = new Account (Name='Test Exceptions Update');
        insert a;
        Account b = new Account (Name='Buyer Test');
        insert b;
        
    //Create new vehicle records    
        Vehicle__c v = new Vehicle__c (Name='987654321', vin__c ='111');     
        Vehicle__c v1 = new Vehicle__c (Name='9876543210', vin__c ='222');
        insert v;
        insert v1;
        
    //Create new auction record
        Auction__c au = new Auction__c (Name='987654321', vin__c ='111',Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id, ACV_Inop__c = false);
        insert au;
        
        Auction__c au1 = new Auction__c (Name='987654322',vin__c ='111', Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id, ACV_Inop__c = false);
        insert au1;
        
        Auction__c au2 = new Auction__c (Name='987654323',vin__c ='222', Vehicle_id__c = v1.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id, ACV_Inop__c = false);
        insert au2;
        
        Auction__c au3 = new Auction__c (Name='987654324',vin__c ='111', Vehicle_id__c = v1.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id, ACV_Inop__c = false);
        insert au3;
        
    //Create new case record
    Id recordTypeCase = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();
        Case c = new Case (RecordTypeId=recordTypeCase, Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=b.id, Auction_number__c=au.id, Vehicle__c  =v.id);
        insert c;
        Case c1 = new Case (RecordTypeId=recordTypeCase, Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=b.id, Auction_number__c=au2.id, Vehicle__c  =v1.id);
        insert c1;
        Case c2 = new Case (Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=b.id, Auction_number__c=au3.id, Vehicle__c  =v1.id);
        insert c2;
    }
    
    @isTest
    static void testCaseStatus(){
        
		boolean status = false;
        test.startTest();
        List<Vehicle__c> vList = [select id,Name,VIN__c from Vehicle__c where Name='987654321'];
        List<case> caseList = [select id,VIN__c, Auction_number__c from case where Vehicle__c  =:vList[0].id];
			status = PreviousAuctionAlertController.getCaseStatus(caseList[0].Id);        
        test.stopTest();

        system.assert(status, 'The Vehicles must match with multiple auction');
    }
    
    @isTest
    static void testCaseVehicleWithSingleAuction(){
        List<Vehicle__c> vList = [select id,Name,VIN__c from Vehicle__c where Name='9876543210'];
        List<case> caseList = [select id,VIN__c, Auction_number__c from case where Vehicle__c  =:vList[0].id];
		boolean status = false;
        test.startTest();
			status = PreviousAuctionAlertController.getCaseStatus(caseList[0].Id);        
        test.stopTest();

        system.assert(!status, 'The Vehicles must not match with multiple auction');
    }
    
    @isTest
    static void testOtherCase(){
        List<Auction__c> aList = [select id,Name from Auction__c where Name='987654324'];
        List<case> caseList = [select id,VIN__c, Auction_number__c from case where Auction_number__c  =:aList[0].id];
		boolean status = false;
        test.startTest();
			status = PreviousAuctionAlertController.getCaseStatus(caseList[0].Auction_number__c);        
        test.stopTest();

        system.assert(!status, 'The Vehicles must not match with any auction');
    }
}