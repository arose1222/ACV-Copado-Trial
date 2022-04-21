@isTest
public class SetFirstArbitrationTest {
    
    @isTest
    static void testSetFirstArb(){ 
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c au = TestUtility.createAuction(v);
        insert au;

        Test.startTest();
        Case firstArbCase = TestUtility.createCase(au,v,a,c);
        firstArbCase.Description='first';
        insert firstArbCase;

        Case titleCase = TestUtility.createTitleCase(au, a, c);
        insert titleCase;

        Case secondArbCase = TestUtility.createCase(au,v,a,c);
        secondArbCase.Description='second';
        insert secondArbCase;
        Test.stopTest();

        List<Case> arbCases = [SELECT Id, First_Arbitration__c, Description FROM Case];
        for(Case cs : arbCases){
            if(cs.Description == 'first'){
                System.assertEquals(true,cs.First_Arbitration__c,'First Arbitration should set to true when first arb logged on account');
            }
            else if(cs.Description == 'second') {
                System.assertEquals(false,cs.First_Arbitration__c,'First Arbitration should remain false when not first arb logged on account');
            }
            else {
                // assert title case is not changed
                System.assertEquals(false,cs.First_Arbitration__c,'First Arbitration should not be set on a title case');
            }
        }
    }
}