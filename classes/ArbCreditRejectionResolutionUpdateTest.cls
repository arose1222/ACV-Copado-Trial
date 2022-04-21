@isTest
public class ArbCreditRejectionResolutionUpdateTest {
    /**
     * Create Test Data
     */
    @TestSetup
    static void makeData(){
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        Account acctSeller = TestUtility.createAccount('seller');
        Account acctBuyer = TestUtility.createAccount('buyer');
        insert new List<Account>{acctSeller, acctBuyer};
        Vehicle__c newCar0 = TestUtility.createVehicle();
        newCar0.Vin__c = '1234567890102030';
        insert newCar0;
        Auction__c newAuction = TestUtility.createAuction(newCar0);
        newAuction.Status__c = 'Active';
        newAuction.Buyer_Dealership__c = acctBuyer.id; 
        newAuction.Seller_Dealership__c = acctSeller.id;
        insert newAuction;
        Contact con = TestUtility.createContact(acctBuyer);
        insert con;
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Case newCase = TestUtility.createCase(newAuction, newCar0, acctBuyer, con);
        insert newCase;
        Complaint__c newComplaint = TestUtility.createComplaint(newCase);
        newComplaint.Valid__c = 'Yes';
        newComplaint.Reviewed_Avoidable__c = true;
        newComplaint.Reviewed_Avoidable_Reason__c = true;
        newComplaint.Reviewed_Invalid_Reason__c = true;
        newComplaint.Reviewed_Valid__c = true;
        insert newComplaint;
        Resolution__c newResolution = TestUtility.createResolution(newCase, newComplaint); 
        newResolution.Amount__c = 600.00;
        newResolution.Resolution__c = 'ACV Credit Assigned';
        newResolution.description__c = 'Test Description';
        newResolution.Goodwill__c = false;
        newResolution.Credit_Check_Created__c = true;
        newResolution.RecordTypeId = Schema.SObjectType.Resolution__c.getRecordTypeInfosByDeveloperName().get('Locked_Resolution').getRecordTypeId();
        insert newResolution;
        Budget__c bud = TestUtility.createBudget();
        bud.Name = 'Arbitration';
        insert bud;
        Credits_Checks__c cc = TestUtility.createCredit( acctBuyer.Id, bud.Id );
        cc.Resolution__c = newResolution.Id;
        insert cc;
    }
    /**
     * Test the successful rejection of a Credit and how it impacts the Resolution Record
     */
    @isTest 
    static void createRejectionTest(){
        List<Credits_Checks__c> creditList = [ SELECT Id, Approval_Status__c, Resolution__c, Resolution__r.RecordTypeId FROM Credits_Checks__c WHERE Resolution__c != null LIMIT 1 ];
        Test.startTest();
            creditList[0].Approval_Status__c = 'Rejected';
            update creditList;      
        Test.stopTest();
        List<Resolution__c> resList = [ SELECT Id, RecordTypeId, Credit_Check_Created__c FROM Resolution__c WHERE Id = :creditList[0].Resolution__c LIMIT 1 ];
        System.assertEquals( false, resList[0].Credit_Check_Created__c) ;
    }   
}