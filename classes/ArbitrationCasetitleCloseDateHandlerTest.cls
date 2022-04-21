@isTest
public class ArbitrationCasetitleCloseDateHandlerTest {
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
        
      //  Id arbrecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Arbitration_Claim').getRecordTypeId();
        Case arbCaseRec = TestUtility.createCase(auctionRec,vehcRec,accRec,conRec);
      //  arbCaseRec.RecordTypeId = arbrecordTypeId;
        insert arbCaseRec;
        
        arbCaseRec.Status = 'Closed';
        update arbCaseRec;
        
        system.assertEquals(arbCaseRec.Auction_Number__c, titleInfoCaseRec.Auction_Number__c);
        system.assertEquals(arbCaseRec.ClosedDate, titleInfoCaseRec.Arb_Close_Date_for_Titles__c);
    }
}