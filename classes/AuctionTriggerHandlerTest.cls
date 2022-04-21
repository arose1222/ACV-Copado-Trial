@isTest
public class AuctionTriggerHandlerTest {

    @isTest
    static void testuncheckMostRecent(){
        //Create new account record
        Account a = new Account (Name='Test Exceptions Update');
        insert a;
        Account b = new Account (Name='Buyer Test');
        insert b;
        //Create new vehicle records    
        Vehicle__c v = new Vehicle__c (Name='987654321');
        insert v;
        
        //Create new auction record
        Auction__c au = new Auction__c (Name='987654321', Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id);
        insert au;
        System.assertEquals(true, [SELECT Most_Recent_Auction__c FROM Auction__c WHERE id = :au.id].Most_Recent_Auction__c);
    
        Auction__c au1 = new Auction__c (Name='987654321', Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id);
        insert au1;
        System.assertEquals(false, [SELECT Most_Recent_Auction__c FROM Auction__c WHERE id = :au.id].Most_Recent_Auction__c);
    }

    @isTest
    static void stampRPInfo(){
        Vehicle__c v = new Vehicle__c (Name='987654321');
        insert v;

        //Create new account record
        Account a = new Account (Name='Test Exceptions Update');
        insert a;
        Account b = new Account (Name='Buyer Test');
        insert b;

        Auction__c au = new Auction__c (Name='987654321', Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id);
        insert au;
        insert new Recommended_Price__c(Price_Ceiling__c=5000, Price_Floor__c=3000,Vehicle__c = v.Id, Pricing_Status__c='Active', Auction_Where_Vehicle_Launched__c = au.id);
        au = new Auction__c (Name='9876543', Vehicle_id__c = v.id, buyer_dealership__c = b.id, Seller_Dealership__c = a.id);
        insert au;
        Auction__c newAuc = [SELECT Relevant_Recommended_Floor_Price__c,Relevant_Recommended_Price_Created_By__c FROM Auction__c WHERE id = :au.id];

        System.assertEquals(3000, newAuc.Relevant_Recommended_Floor_Price__c);
        System.assertNotEquals(null, newAuc.Relevant_Recommended_Price_Created_By__c);
    }
}