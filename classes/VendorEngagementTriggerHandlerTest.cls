@isTest
public class VendorEngagementTriggerHandlerTest {
    @isTest
    static void testBeforeInsert(){
       
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = TestUtility.createSystemAdministratorUser();
        //u.ProfileID = p.id;
        u.IsActive = true;
        insert u;
        
        Account accRec = TestUtility.createAccount('Acc Test');
        accRec.Sr_Title_Specialist__c = u.Id;
        insert accRec ;
        
        Contact conRec = TestUtility.createContact(accRec);
        insert conRec;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec, vehcRec);
        insert auctionRec;
        
        Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec);
        titleInfoCaseRec.Seller_Dealership__c = accRec.Id;
        insert titleInfoCaseRec;
        
         Test.startTest();
        Vendor_Engagement__c vendorRec = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        insert vendorRec;
        
        vendorRec = [select id, OwnerId from Vendor_Engagement__c where id = : vendorRec.Id];
        
        system.assertEquals(accRec.Sr_Title_Specialist__c, vendorRec.OwnerId);
        Test.stopTest();
    }
    @isTest
    static void testNegScenarioBeforeInsert(){
       
        Account accRec = TestUtility.createAccount('Acc Test');
        insert accRec ;
        
        Contact conRec = TestUtility.createContact(accRec);
        insert conRec;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec, vehcRec);
        insert auctionRec;
        
        Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec);
        titleInfoCaseRec.Seller_Dealership__c = accRec.Id;
        insert titleInfoCaseRec;
         Test.startTest();
        Vendor_Engagement__c vendorRec = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        insert vendorRec;
        
        vendorRec = [select id, OwnerId from Vendor_Engagement__c where id = : vendorRec.Id];
        
        system.assertNotEquals(accRec.Sr_Title_Specialist__c, vendorRec.OwnerId);
        Test.stopTest();
    }
    @isTest
    static void testAfterUpdate(){
       
        List<Vendor_Engagement__c> vendorRecList = new List<Vendor_Engagement__c>();
        List<Vendor_Engagement__c> vendorRecListToUpdate = new List<Vendor_Engagement__c>();
        
        Account accRec = TestUtility.createAccount('Acc Test');
        insert accRec ;
        
        Contact conRec = TestUtility.createContact(accRec);
        insert conRec;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec, vehcRec);
        insert auctionRec;
        
        Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec);
        titleInfoCaseRec.Seller_Dealership__c = accRec.Id;
        insert titleInfoCaseRec;
        
        Vendor_Engagement__c vendorRec = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        vendorRecList.add(vendorRec);
        
        Vendor_Engagement__c vendorRec1 = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        vendorRecList.add(vendorRec1);
        
        Vendor_Engagement__c vendorRec2 = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        vendorRecList.add(vendorRec2);
        insert vendorRecList;
        
        vendorRec.Status__c = 'Working';
        vendorRec.Vendor_Name__c=accRec.id;
        vendorRecListToUpdate.add(vendorRec); 
        vendorRec1.Status__c = 'Received';
        vendorRec1.Vendor_Name__c=accRec.id;
        vendorRecListToUpdate.add(vendorRec1); 
        vendorRec2.Status__c = 'Approved';
        vendorRec2.Vendor_Name__c=accRec.id;
        vendorRecListToUpdate.add(vendorRec2); 
        update vendorRecListToUpdate;
         Test.startTest();
        vendorRec = [select id, Date_Time_of_Working_Status__c from Vendor_Engagement__c where id = : vendorRec.Id];
        vendorRec1 = [select id, Date_Time_of_Received_Status__c from Vendor_Engagement__c where id = : vendorRec1.Id];
        vendorRec2 = [select id, Date_Time_of_Approved_Denied_Status__c from Vendor_Engagement__c where id = : vendorRec2.Id];

        system.assertEquals(vendorRec.Date_Time_of_Working_Status__c.date(), System.today());
        system.assertEquals(vendorRec1.Date_Time_of_Received_Status__c.date(), System.today());
        system.assertEquals(vendorRec2.Date_Time_of_Approved_Denied_Status__c.date(), System.today());
        Test.stopTest();
    }
    
      @isTest
    static void testNegScenarioAfterUpdate(){
        Test.startTest();
        List<Vendor_Engagement__c> vendorRecList = new List<Vendor_Engagement__c>();
        List<Vendor_Engagement__c> vendorRecListToUpdate = new List<Vendor_Engagement__c>();
        
        Account accRec = TestUtility.createAccount('Acc Test');
        insert accRec ;
        
        Contact conRec = TestUtility.createContact(accRec);
        insert conRec;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec, vehcRec);
        insert auctionRec;
        
        Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec);
        titleInfoCaseRec.Seller_Dealership__c = accRec.Id;
        insert titleInfoCaseRec;
        
        Vendor_Engagement__c vendorRec = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        vendorRecList.add(vendorRec);
        
        Vendor_Engagement__c vendorRec1 = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        vendorRecList.add(vendorRec1);
        
        Vendor_Engagement__c vendorRec2 = TestUtility.createVendorEngagement(titleInfoCaseRec.Id,accRec.Id); 
        vendorRecList.add(vendorRec2);
        insert vendorRecList;
        
        vendorRec.Status__c = 'Working';
        vendorRec.Vendor_Name__c=accRec.id;
        vendorRecListToUpdate.add(vendorRec); 
        vendorRec1.Status__c = 'Received';
        vendorRec1.Vendor_Name__c=accRec.id;
        vendorRecListToUpdate.add(vendorRec1); 
        vendorRec2.Status__c = 'Approved';
        vendorRec2.Vendor_Name__c=accRec.id;
        vendorRecListToUpdate.add(vendorRec2); 
        update vendorRecListToUpdate;
        
        vendorRec = [select id, Date_Time_of_Working_Status__c from Vendor_Engagement__c where id = : vendorRec.Id];
        vendorRec1 = [select id, Date_Time_of_Received_Status__c from Vendor_Engagement__c where id = : vendorRec1.Id];
        vendorRec2 = [select id, Date_Time_of_Approved_Denied_Status__c from Vendor_Engagement__c where id = : vendorRec2.Id];

        system.assertEquals(vendorRec.Date_Time_of_Working_Status__c.date(), System.today());
        system.assertEquals(vendorRec1.Date_Time_of_Received_Status__c.date(), System.today());
        system.assertEquals(vendorRec2.Date_Time_of_Approved_Denied_Status__c.date(), System.today());
        Test.stopTest();
    }
}