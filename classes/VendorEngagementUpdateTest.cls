@isTest
public class VendorEngagementUpdateTest {
    @isTest
    static void testAfterUpdate(){
    
        Account accRec = TestUtility.createAccount('Acc Test');
        insert accRec ;
        
        Contact conRec = TestUtility.createContact(accRec);
        insert conRec;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec, vehcRec);
        insert auctionRec;
        
        Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec);
        insert titleInfoCaseRec;
        
        Vendor_Engagement__c vendorRec = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        insert vendorRec;
        
        titleInfoCaseRec.Status = 'Received';
        update titleInfoCaseRec;
        
        vendorrec = [select id, status__c, Ops_Case__c from Vendor_Engagement__c where id = : vendorrec.Id];
        
        system.assertEquals(vendorRec.Ops_Case__c, titleInfoCaseRec.Id);
        system.assertEquals(vendorRec.Status__c,'Received', 'Status should say received');
    }
     @isTest
    static void testAfterUpdatenegativecase(){
    
        Account accRec = TestUtility.createAccount('Acc Test');
        insert accRec ;
        
        Contact conRec = TestUtility.createContact(accRec);
        insert conRec;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec, vehcRec);
        insert auctionRec;
        
        Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec);
        insert titleInfoCaseRec;
        
        Vendor_Engagement__c vendorRec = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id);
        insert vendorRec;
        
        
        titleInfoCaseRec.Status = 'Problem';
        update titleInfoCaseRec;
        
        vendorrec = [select id, status__c, Ops_Case__c from Vendor_Engagement__c where id = : vendorrec.Id];
        
        system.assertEquals(vendorRec.Ops_Case__c, titleInfoCaseRec.Id);
        system.assertEquals(vendorRec.Status__c,'Submitted', 'Status should  say Submitted');
    }
}