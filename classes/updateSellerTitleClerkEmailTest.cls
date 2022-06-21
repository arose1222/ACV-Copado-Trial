@isTest
public class updateSellerTitleClerkEmailTest {
    public static  Id conDealershipRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Dealership_Contact').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
       Account accRec = TestUtility.createAccount('Acc Test');
        insert accRec ;
        
        Contact conRec1 = TestUtility.createContact(accRec);
        insert conRec1;
        
        Vehicle__c vehcRec = TestUtility.createVehicle();
        insert vehcRec;
        
        Auction__c auctionRec = TestUtility.createAuction(accRec,conRec1, vehcRec);
        insert auctionRec;
        
         Case titleInfoCaseRec = TestUtility.createTitleCase(auctionRec,accRec,conRec1);
        titleInfoCaseRec.Seller_Dealership__c = accRec.Id;
        titleInfoCaseRec.Status = 'New';
        insert titleInfoCaseRec;
         
    }
    
    @isTest
    static void testAfterInsert(){
      
        Account accrec = [select id from Account Limit 1];
        
        Contact conRec = TestUtility.createContact(accRec);
        conRec.Title_Picklist__c = 'Title Clerk';
        conRec.RecordTypeId = conDealershipRecTypeId;
        insert conRec;
         
        
        Case caseRec = [Select Id,Seller_Title_Clerk_Email__c,Seller_Dealership__c from Case Limit 1];
        system.assertEquals(caseRec.Seller_Title_Clerk_Email__c, conRec.Email);
        system.assertEquals(caseRec.Seller_Dealership__c, conRec.AccountId);
    }
    @isTest
    static void testNegativeAfterInsert(){
        
        Account accrec = [select id from Account Limit 1];
        Contact conRec = TestUtility.createContact(accRec);
        conRec.Title_Picklist__c = 'Accounting';
        conRec.RecordTypeId = conDealershipRecTypeId;
        insert conRec;
         
        
        Case caseRec = [Select Id,Seller_Title_Clerk_Email__c,Seller_Dealership__c from Case Limit 1];
        system.assertNotEquals(caseRec.Seller_Title_Clerk_Email__c, conRec.Email);
        system.assertEquals(caseRec.Seller_Dealership__c, conRec.AccountId);
    }
     @isTest
    static void testAfterUpdate(){
        
     
        Account accrec = [select id from Account Limit 1];

        
        Contact conRec = TestUtility.createContact(accRec);
        conRec.Title_Picklist__c = 'Accounting';
        conRec.RecordTypeId = conDealershipRecTypeId;
        insert conRec;
        
        conRec.Title_Picklist__c = 'Title Clerk';
        update conRec;
        
        Case caseRec = [Select Id,Seller_Title_Clerk_Email__c,Seller_Dealership__c from Case Limit 1];
        system.assertEquals(caseRec.Seller_Title_Clerk_Email__c, conRec.Email);
        system.assertEquals(caseRec.Seller_Dealership__c, conRec.AccountId);
    }
     @isTest
    static void testNegativeAfterUpdate(){
        
       
       Account accrec = [select id from Account Limit 1];
        
        Contact conRec = TestUtility.createContact(accRec);
        conRec.Title_Picklist__c = 'Title Clerk';
        conRec.RecordTypeId = conDealershipRecTypeId;
        insert conRec;
         
        conRec.Title_Picklist__c = 'Accounting';
        update conRec;
        
        Case caseRec = [Select Id,Seller_Title_Clerk_Email__c,Seller_Dealership__c from Case Limit 1];
        system.assertNotEquals(caseRec.Seller_Title_Clerk_Email__c, conRec.Email);
        system.assertEquals(caseRec.Seller_Dealership__c, conRec.AccountId);
    }
}