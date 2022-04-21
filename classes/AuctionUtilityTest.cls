@isTest
public class AuctionUtilityTest {
    
    @TestSetup
    static void makeData(){
      //Create new account record
        Account a = new Account (Name='Test Exceptions Update');
        insert a;
        Account b = new Account (Name='Buyer Test');
        insert b;
    //Create new vehicle records    
        Vehicle__c v = new Vehicle__c (Name='987654321');     
        Vehicle__c v1 = new Vehicle__c (Name='9876543210');
        insert v;
        insert v1;
    //Create new auction record
        Auction__c au = new Auction__c (Name='987654321', Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id, ACV_Inop__c = false);
        insert au;
    //Create new case record
        Case c = new Case (Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=b.id, Auction_number__c=au.id, Vehicle__c=v.id);
        insert c;
    }

    @isTest
    static void testOnlyAuctionVinUpdate(){
        List<case> caseList = [select id, Vehicle__c, Auction_number__c from case];
        //do a clone here so we are not using pointers when we try to see if our case has updated
        case oldCaseInformation = caseList[0].clone(true,true,false,false);
        List<Auction__c> auctionList = [select id, Vehicle_id__c from Auction__c];
        for(Vehicle__c v :[select id from Vehicle__c]){
            if(auctionList[0].Vehicle_id__c != v.id){
                system.debug('changing vin');
                auctionList[0].Vehicle_id__c = v.id;
            }
        }

        test.startTest();
        update auctionList;
        test.stopTest();

        caseList = [Select id, Vehicle__c from case];

        system.assert(caseList[0].Vehicle__c != oldCaseInformation.Vehicle__c, 'The Vehicles Match when they should not');
    }

    @isTest
    static void testOnlyAuctionBuyerUpdate(){
        List<case> caseList = [select id, Vehicle__c, Auction_number__c,AccountId from case];
        //do a clone here so we are not using pointers when we try to see if our case has updated
        case oldCaseInformation = caseList[0].clone(true,true,false,false);
        List<Auction__c> auctionList = [select id, Vehicle_id__c, buyer_dealership__c from Auction__c];
        for(account v :[select id from account]){
            if(oldCaseInformation.accountId != v.id){
                system.debug('changing dealer');
                auctionList[0].buyer_dealership__c = v.id;
            }
        }
        
        test.startTest();
        update auctionList;
        test.stopTest();

        caseList = [Select id, Vehicle__c ,AccountId from case];

        system.assert(caseList[0].AccountId != oldCaseInformation.AccountId, 'The Accounts Match when they should not');
    }

    @isTest
    static void testOnlyAuctionSellerUpdate(){
        List<case> caseList = [select id, Vehicle__c, Auction_number__c,AccountId,Seller_Dealership__c from case];
        //do a clone here so we are not using pointers when we try to see if our case has updated
        case oldCaseInformation = caseList[0].clone(true,true,false,false);
        List<Auction__c> auctionList = [select id, Vehicle_id__c, Seller_Dealership__c from Auction__c];
        for(account v :[select id from account]){
            if(oldCaseInformation.Seller_Dealership__c != v.id){
                system.debug('changing dealer');
                auctionList[0].Seller_Dealership__c = v.id;
            }
        }
        
        test.startTest();
        update auctionList;
        test.stopTest();

        caseList = [Select id, Vehicle__c ,Seller_Dealership__c from case];
    
        system.assert(caseList[0].Seller_Dealership__c != oldCaseInformation.Seller_Dealership__c, 'The Accounts Match when they should not');
    }

    @isTest
    static void testUnwindException(){
        List<case> caseList = [select id, Vehicle__c, Auction_number__c,AccountId,Seller_Dealership__c from case];
        //do a clone here so we are not using pointers when we try to see if our case has updated
        Id unwindRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unwind').getRecordTypeId();
        case oldCaseInformation = caseList[0].clone(true,true,false,false);
        oldCaseInformation.recordTypeId = unwindRTID;
        update oldCaseInformation;
        List<Auction__c> auctionList = [select id, Vehicle_id__c, Seller_Dealership__c from Auction__c];
        for(account v :[select id from account]){
            if(oldCaseInformation.Seller_Dealership__c != v.id){
                system.debug('changing dealer');
                auctionList[0].Seller_Dealership__c = v.id;
            }
        }
        
        test.startTest();
        update auctionList;
        test.stopTest();

        caseList = [Select id, Vehicle__c ,Seller_Dealership__c from case];
    
        system.assert(caseList[0].Seller_Dealership__c == oldCaseInformation.Seller_Dealership__c, 'The Accounts don\'t Match when they should');
    }

    @isTest
    static void testupdateCasesWithNewFieldData(){
        List<case> caseList = [select id, Vehicle__c, Status, recordTypeId, Auction_number__c,AccountId,Seller_Dealership__c from case];
        Id TransportRTID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        caseList[0].recordTypeId = TransportRTID;
        caseList[0].Status = 'Awaiting Release';
        update caseList;
        //do a clone here so we are not using pointers when we try to see if our case has updated
        case oldCaseInformation = caseList[0].clone(true,true,false,false);
        List<Auction__c> auctionList = [select id, Vehicle_id__c,Release_Available__c, Seller_Dealership__c from Auction__c];
        
        for(Auction__c a :auctionList){
            a.Release_Available__c = true;
            a.Release_DateTime__c = System.Now();
        }
        
        test.startTest();
        update auctionList;
        test.stopTest();

        caseList = [Select id, Vehicle__c ,Seller_Dealership__c,Release_DateTime__c,Release_Available__c from case];
        system.debug(caseList[0].Release_Available__c);
        system.assert(caseList[0].Release_Available__c, 'Release Avaliable Is False');
    }

    @isTest
    static void testupdateAuctionACVInop(){
        List<Auction__C> auctionList = [select id, Vehicle_id__c, buyer_dealership__c, Seller_Dealership__c, ACV_Inop__c from Auction__c];
        auctionList[0].ACV_inop__c = true;

        test.startTest();
        update auctionList;
        test.stopTest();

        List<Case> caseList = [Select inop__C from case];
        system.debug(caseList[0].inop__c);
        system.assert(caseList[0].inop__c, 'Inop Is False');
    }

    @isTest
    static void testUpdateTitles(){
        Auction__c a = [SELECT Id, Seller_Payment_Method__c, Seller_Payment_Tracking_Number__c FROM Auction__c LIMIT 1];
        a.Seller_Payment_Method__c = 'ach';
        a.Seller_Payment_Tracking_Number__c = '1SATR@CK1NG';
        
        test.startTest();
        update a;
        test.stopTest();
        Case c = [SELECT Seller_Payment_Method__c, Seller_Payment_Tracking_Number__c, RecordType.Name FROM Case WHERE Auction_Number__c = :a.Id];
        System.assertEquals('ach', c.Seller_Payment_Method__c, 'RecordType is ' + c.RecordType.Name);

        a.Seller_Payment_Method__c = 'check';
        update a;
        System.assertEquals('check', [SELECT Seller_Payment_Method__c, Seller_Payment_Tracking_Number__c FROM Case WHERE Auction_Number__c = :a.Id].Seller_Payment_Method__c);
    }
}