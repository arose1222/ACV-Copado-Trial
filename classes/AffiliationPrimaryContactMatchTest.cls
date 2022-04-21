@isTest
public class AffiliationPrimaryContactMatchTest {
    @TestSetup
    static void makeData(){
        
    }


    @isTest 
    public static void singleInsert(){
        List<Account> acctList = new List<Account>();
        Account acct1 = TestUtility.createAccount('Account 1');
        Account acct2 = TestUtility.createAccount('Account 2');
        Account acct3 = TestUtility.createAccount('Account 3');
        Account acct4 = TestUtility.createAccount('Account 4');
        acctList.add(acct1);
        acctList.add(acct2);
        acctList.add(acct3);
        acctList.add(acct4);
        insert acctList;

        List<Contact> ctctList = new List<Contact>();
        Contact ctct1 = TestUtility.createContact(acct1);
        Contact ctct2 = TestUtility.createContact(acct2);
        Contact ctct3 = TestUtility.createContact(acct3);
        Contact ctct4 = TestUtility.createContact(acct4);
        ctctList.add(ctct1);
        ctctList.add(ctct2);
        ctctList.add(ctct3);
        ctctList.add(ctct4);
        insert ctctList;



        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff1 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct1.id, Primary_Contact__c = true, Type__c = 'admin');
        affList.add(aff1);

        test.startTest();
        insert affList;
        test.stopTest();
        
        List<Account> acctTestResult = new List<Account>();
        acctTestResult = [SELECT Primary_Contact__c FROM ACCOUNT WHERE id =: acct1.id];
        system.debug(acctTestResult);
        system.assert(acctTestResult[0].Primary_Contact__c == aff1.Contact__c);

    }

    @isTest
    public static void singleUpdate(){
        List<Account> acctList = new List<Account>();
        Account acct1 = TestUtility.createAccount('Account 1');
        Account acct2 = TestUtility.createAccount('Account 2');
        Account acct3 = TestUtility.createAccount('Account 3');
        Account acct4 = TestUtility.createAccount('Account 4');
        acctList.add(acct1);
        acctList.add(acct2);
        acctList.add(acct3);
        acctList.add(acct4);
        insert acctList;

        List<Contact> ctctList = new List<Contact>();
        Contact ctct1 = TestUtility.createContact(acct1);
        Contact ctct2 = TestUtility.createContact(acct2);
        Contact ctct3 = TestUtility.createContact(acct3);
        Contact ctct4 = TestUtility.createContact(acct4);
        ctctList.add(ctct1);
        ctctList.add(ctct2);
        ctctList.add(ctct3);
        ctctList.add(ctct4);
        insert ctctList;



        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff1 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct1.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff2 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct2.id, Primary_Contact__c = false, Type__c = 'admin');
        affList.add(aff1);
        affList.add(aff2);
        insert affList;


        test.startTest();
        aff2.Primary_Contact__c = true;
        update aff2;
        test.stopTest();
        
        List<Account> acctTestResult = new List<Account>();
        acctTestResult = [SELECT Name, Primary_Contact__c FROM ACCOUNT WHERE id =: acct1.id];
        system.debug(aff1);
        system.debug(aff2);
        system.debug(acctTestResult);
        system.assert(acctTestResult[0].Primary_Contact__c == aff2.Contact__c);

    }

    @isTest
    public static void oneAccountManyContacts(){
        Account acct1 = TestUtility.createAccount('Account 1');
        insert acct1;

        List<Contact> ctctList = new List<Contact>();
        Contact ctct1 = TestUtility.createContact(acct1);
        Contact ctct2 = TestUtility.createContact(acct1);
        Contact ctct3 = TestUtility.createContact(acct1);
        Contact ctct4 = TestUtility.createContact(acct1);
        ctctList.add(ctct1);
        ctctList.add(ctct2);
        ctctList.add(ctct3);
        ctctList.add(ctct4);
        insert ctctList;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff1 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct1.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff2 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct2.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff3 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct3.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff4 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct4.id, Primary_Contact__c = false, Type__c = 'admin');
        affList.add(aff1);
        affList.add(aff2);
        affList.add(aff3);
        affList.add(aff4);
        insert affList;

        test.startTest();
        for(Affiliation__c aff : affList){
            aff.Primary_Contact__c = true;
        }
        system.debug('affList: ' + affList);
        update affList;
        test.stopTest();


        List<Affiliation__c> affTestResult = new List<Affiliation__c>();
        affTestResult = [SELECT id, Account__c, Contact__c, Primary_Contact__c FROM Affiliation__c WHERE Account__c =: acct1.id];

        integer count = 0;
        for(Affiliation__c aff : affTestResult){
            if(aff.Primary_Contact__c == true){
                count = count + 1;
            }
        }
        
        system.debug('Count: ' + count);
        system.assert(count == 1);

    }

    @isTest
    public static void manyAccountsOneContact(){
        List<Account> acctList = new List<Account>();
        Account acct1 = TestUtility.createAccount('Account 1');
        Account acct2 = TestUtility.createAccount('Account 2');
        Account acct3 = TestUtility.createAccount('Account 3');
        Account acct4 = TestUtility.createAccount('Account 4');
        acctList.add(acct1);
        acctList.add(acct2);
        acctList.add(acct3);
        acctList.add(acct4);
        insert acctList;

        List<Contact> ctctList = new List<Contact>();
        Contact ctct1 = TestUtility.createContact(acct1);
        ctctList.add(ctct1);
        insert ctctList;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff1 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct1.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff2 = new Affiliation__c(Account__c = acct2.id, Contact__c = ctct1.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff3 = new Affiliation__c(Account__c = acct3.id, Contact__c = ctct1.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff4 = new Affiliation__c(Account__c = acct4.id, Contact__c = ctct1.id, Primary_Contact__c = false, Type__c = 'admin');
        affList.add(aff1);
        affList.add(aff2);
        affList.add(aff3);
        affList.add(aff4);
        insert affList;

        test.startTest();
        for(Affiliation__c aff : affList){
            aff.Primary_Contact__c = true;
        }
        system.debug('affList: ' + affList);
        update affList;
        test.stopTest();

        List<Account> acctTestResult = new List<Account>();
        acctTestResult = [SELECT id, Primary_Contact__c FROM Account WHERE Primary_Contact__c =: ctct1.id];

        system.assert(acctTestResult.size() == 4);

    }

    @isTest
    public static void manyAccountsManyContacts(){
        List<Account> acctList = new List<Account>();
        Account acct1 = TestUtility.createAccount('Account 1');
        Account acct2 = TestUtility.createAccount('Account 2');
        Account acct3 = TestUtility.createAccount('Account 3');
        Account acct4 = TestUtility.createAccount('Account 4');
        acctList.add(acct1);
        acctList.add(acct2);
        acctList.add(acct3);
        acctList.add(acct4);
        insert acctList;

        List<Contact> ctctList = new List<Contact>();
        Contact ctct1 = TestUtility.createContact(acct1);
        Contact ctct2 = TestUtility.createContact(acct2);
        Contact ctct3 = TestUtility.createContact(acct3);
        Contact ctct4 = TestUtility.createContact(acct4);
        ctctList.add(ctct1);
        ctctList.add(ctct2);
        ctctList.add(ctct3);
        ctctList.add(ctct4);
        insert ctctList;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        // Account 1 Affiliations
        Affiliation__c aff0 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct1.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff1 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct2.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff2 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct3.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff3 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct4.id, Primary_Contact__c = false, Type__c = 'admin');
        
        // Account 2 Affiliations
        Affiliation__c aff4 = new Affiliation__c(Account__c = acct2.id, Contact__c = ctct1.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff5 = new Affiliation__c(Account__c = acct2.id, Contact__c = ctct2.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff6 = new Affiliation__c(Account__c = acct2.id, Contact__c = ctct3.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff7 = new Affiliation__c(Account__c = acct2.id, Contact__c = ctct4.id, Primary_Contact__c = false, Type__c = 'admin');
        
        // Account 3 Affiliations
        Affiliation__c aff8 = new Affiliation__c(Account__c = acct3.id, Contact__c = ctct1.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff9 = new Affiliation__c(Account__c = acct3.id, Contact__c = ctct2.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff10 = new Affiliation__c(Account__c = acct3.id, Contact__c = ctct3.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff11 = new Affiliation__c(Account__c = acct3.id, Contact__c = ctct4.id, Primary_Contact__c = false, Type__c = 'admin');
        
        // Account 4 Affiliations
        Affiliation__c aff12 = new Affiliation__c(Account__c = acct4.id, Contact__c = ctct1.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff13 = new Affiliation__c(Account__c = acct4.id, Contact__c = ctct2.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff14 = new Affiliation__c(Account__c = acct4.id, Contact__c = ctct3.id, Primary_Contact__c = false, Type__c = 'admin');
        Affiliation__c aff15 = new Affiliation__c(Account__c = acct4.id, Contact__c = ctct4.id, Primary_Contact__c = true, Type__c = 'admin');

        affList.add(aff0);
        affList.add(aff1);
        affList.add(aff2);
        affList.add(aff3);
        affList.add(aff4);
        affList.add(aff5);
        affList.add(aff6);
        affList.add(aff7);
        affList.add(aff8);
        affList.add(aff9);
        affList.add(aff10);
        affList.add(aff11);
        affList.add(aff12);
        affList.add(aff13);
        affList.add(aff14);
        affList.add(aff15);
        insert affList;

        test.startTest();
            // Switch Primary Account on Account 2
            affList[4].Primary_Contact__c = true;
            affList[5].Primary_Contact__c = false;
            // Switch Primary Contact on Account 3
            affList[10].Primary_Contact__c = false;
            affList[11].Primary_Contact__c = true;
            // Turn off Primary Contact on Account 4, No Primary Account
            //Alex removed this test case because we no longer want Accounts to be without a Primary - AffiliationPrimaryorAdminChangeCheck
            // affList[15].Primary_Contact__c = false;
            update affList;
        test.stopTest();

        List<Account> acctTestResult = new List<Account>();
        acctTestResult = [SELECT id, Primary_Contact__c, Primary_Contact__r.Name FROM Account];

        boolean pass = true;
        for(account a : acctTestResult){
            if(a.id == affList[0].Account__c && a.Primary_Contact__c != affList[0].Contact__c){
                pass = false;
                system.debug('Failure 1');
            }
            if(a.id == affList[4].Account__c && a.Primary_Contact__c != affList[4].Contact__c){
                pass = false;
                system.debug('Failure 2');
            }
            if(a.id == affList[11].Account__c && a.Primary_Contact__c != affList[11].Contact__c){
                pass = false;
                system.debug('Failure 3');
            }
            // if(a.id == acct4.id && a.Primary_Contact__c != null){
            //     pass = false;
            //     system.debug('Failure 4');
            // }       
        }
        system.assert(pass);

    }
        //missing fields - dealer id, contact id, 2 primary contacts at same time for same dealership, duplicate dealership member id (id__c)

    @isTest
    public static void oneAccountTwoPrimaries(){
        List<Account> acctList = new List<Account>();
        Account acct1 = TestUtility.createAccount('Account 1');
        Account acct2 = TestUtility.createAccount('Account 2');
        acctList.add(acct1);
        acctList.add(acct2);
        insert acctList;

        List<Contact> ctctList = new List<Contact>();
        Contact ctct1 = TestUtility.createContact(acct1);
        Contact ctct2 = TestUtility.createContact(acct2);
        ctctList.add(ctct1);
        ctctList.add(ctct2);
        insert ctctList;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        // Account 1 Affiliations
        Affiliation__c aff0 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct1.id, Primary_Contact__c = true, Type__c = 'admin');
        Affiliation__c aff1 = new Affiliation__c(Account__c = acct1.id, Contact__c = ctct2.id, Primary_Contact__c = true, Type__c = 'admin');

        affList.add(aff0);
        affList.add(aff1);

        test.startTest();
            insert affList;
        test.stopTest();

        List<Account> acctTestResult = new List<Account>();
        acctTestResult = [SELECT id, Primary_Contact__c, Primary_Contact__r.Name FROM Account];

        system.assert( acctTestResult[0].Primary_Contact__c != affList[1].Contact__c );
        Integer countOfPrimary = [ SELECT Count() FROM Affiliation__c WHERE Primary_Contact__c = TRUE ];
        system.assertEquals( 1, countOfPrimary, 'The primary affiliation count is incorrect' );

    }
}