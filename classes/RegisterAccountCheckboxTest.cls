@IsTest
public class RegisterAccountCheckboxTest {
    
    @IsTest
    static void insertBoughtAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships',
            Last_30_Days_Bought__c = 1
        );

        Test.startTest();
            insert acct;
        Test.stopTest();

        acct = [ SELECT Id, Registered__c FROM Account WHERE Id = :acct.Id ];
        system.assert( acct.Registered__c );
        
    }

    @IsTest
    static void updateBoughtAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships'
        );
        insert acct;

        acct = [ SELECT Id, Registered__c FROM Account WHERE Id = :acct.Id ];
        system.assert( !acct.Registered__c );

        Test.startTest();
            acct.Last_30_Days_Bought__c = 1;
            update acct;
        Test.stopTest();

        acct = [ SELECT Id, Registered__c FROM Account WHERE Id = :acct.Id ];
        system.assert( acct.Registered__c );
        
    }

    @IsTest
    static void insertSoldAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships',
            Last_30_Days_Sold__c = 1
        );

        Test.startTest();
            insert acct;
        Test.stopTest();

        acct = [ SELECT Id, Registered__c FROM Account WHERE Id = :acct.Id ];
        system.assert( acct.Registered__c );
        
    }

    @IsTest
    static void updateSoldAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships'
        );
        insert acct;

        acct = [ SELECT Id, Registered__c FROM Account WHERE Id = :acct.Id ];
        system.assert( !acct.Registered__c );

        Test.startTest();
            acct.Last_30_Days_Sold__c = 1;
            update acct;
        Test.stopTest();

        acct = [ SELECT Id, Registered__c FROM Account WHERE Id = :acct.Id ];
        system.assert( acct.Registered__c );
        
    }

}