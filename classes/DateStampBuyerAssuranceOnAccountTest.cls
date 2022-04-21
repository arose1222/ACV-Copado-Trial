@IsTest
public class DateStampBuyerAssuranceOnAccountTest {
    
    @IsTest
    static void insertGoodWillAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships',
            Buyer_s_Assurance_Exceptions__c = DateStampBuyerAssuranceOnAccount.GOODWILL
        );

        Test.startTest();
            insert acct;
        Test.stopTest();

        acct = [ SELECT Id, Date_Of_Goodwill__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_Of_Goodwill__c, ACVUtility.newESTInstance( date.today() ), 'The Goodwill Date was expected to be today' );
        
    }

    @IsTest
    static void updateGoodWillAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships'
        );
        insert acct;

        acct = [ SELECT Id, Date_Of_Goodwill__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_Of_Goodwill__c, null, 'The Goodwill Date was expected to be empty' );

        Test.startTest();
            acct.Buyer_s_Assurance_Exceptions__c = DateStampBuyerAssuranceOnAccount.GOODWILL;
            update acct;
        Test.stopTest();

        acct = [ SELECT Id, Date_Of_Goodwill__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_Of_Goodwill__c, ACVUtility.newESTInstance( date.today() ), 'The Goodwill Date was expected to be today' );
        
    }

    @IsTest
    static void insertRetroAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships',
            Buyer_s_Assurance_Exceptions__c = DateStampBuyerAssuranceOnAccount.RETRO_CHARGE
        );

        Test.startTest();
            insert acct;
        Test.stopTest();

        acct = [ SELECT Id, Date_of_Retro_Charge__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_of_Retro_Charge__c, ACVUtility.newESTInstance( date.today() ), 'The Retro Charge Date was expected to be today' );
        
    }

    @IsTest
    static void updateRetroAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships'
        );
        insert acct;

        acct = [ SELECT Id, Date_of_Retro_Charge__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_of_Retro_Charge__c, null, 'The Retro Charge Date was expected to be empty' );

        Test.startTest();
            acct.Buyer_s_Assurance_Exceptions__c = DateStampBuyerAssuranceOnAccount.RETRO_CHARGE;
            update acct;
        Test.stopTest();

        acct = [ SELECT Id, Date_of_Retro_Charge__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_of_Retro_Charge__c, ACVUtility.newESTInstance( date.today() ), 'The Retro Charge Date was expected to be today' );
        
    }

    @IsTest
    static void insertDenyAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships',
            Buyer_s_Assurance_Exceptions__c = DateStampBuyerAssuranceOnAccount.DENY
        );

        Test.startTest();
            insert acct;
        Test.stopTest();

        acct = [ SELECT Id, Date_of_Deny__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_of_Deny__c, ACVUtility.newESTInstance( date.today() ), 'The Deny Date was expected to be today' );
        
    }

    @IsTest
    static void updateDenyAccount(){
        
        Account acct = new Account(
            Name = 'Smith Dealerships'
        );
        insert acct;

        acct = [ SELECT Id, Date_of_Deny__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_of_Deny__c, null, 'The Deny Date was expected to be empty' );

        Test.startTest();
            acct.Buyer_s_Assurance_Exceptions__c = DateStampBuyerAssuranceOnAccount.DENY;
            update acct;
        Test.stopTest();

        acct = [ SELECT Id, Date_of_Deny__c FROM Account WHERE Id = :acct.Id ];
        system.assertEquals( acct.Date_of_Deny__c, ACVUtility.newESTInstance( date.today() ), 'The Deny Date was expected to be today' );
        
    }

}