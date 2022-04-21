@IsTest//(SeeAllData=TRUE)
public class FillTerritoryOnAccountTest {
    @IsTest
    static void updateAccountTerritory(){
        Account acct = new Account(
            Name = 'Smith Dealerships', legal_name__c='Smith Dealerships'
        );
        insert acct;

        acct.legal_name__c = 'John Smith Dealerships';
        update acct;

        /*maps__AssignmentRule__c rec = [ SELECT Id, maps__ShapeLayer__c, maps__ShapeLayer__r.Name FROM maps__AssignmentRule__c WHERE maps__Active__c = TRUE LIMIT 1 ];

        Test.startTest();

            acct.Maps_TM_Assignment_Rule_Territory_A_E__c = rec.Id;
            update acct;
            /*acct.Maps_TM_Assignment_Rule_Territory_F_O__c = rec.Id;
            update acct;
            acct.Maps_TM_Assignment_Rule_Territory_P_Z__c = rec.Id;
            update acct;

        Test.stopTest();

        acct = [ SELECT Id, Territory_Name__c FROM Account WHERE Id = :acct.Id LIMIT 1 ];
        system.assertEquals( rec.maps__ShapeLayer__r.Name, acct.Territory_Name__c, 'The Map Assignment Rule did not change as expected' );*/
    }
}