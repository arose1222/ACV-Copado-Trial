@isTest
private class DealerDocInfoAccountPopulationBatchTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @TestSetup
    static void makeData(){
        List<Account> acctList = new List<Account>();
        acctList.add(TestUtility.createAccount('Test 1'));
        acctList.add(TestUtility.createAccount('Test 2'));
        acctList.add(TestUtility.createAccount('Test 3'));
        acctList.add(TestUtility.createAccount('Test 4'));
        acctList.add(TestUtility.createAccount('Test 5'));
        
        insert acctList;

        //contacts
        List<Contact> contList = new List<Contact>();
        contList.add(TestUtility.createContact(acctList[0]));
        contList.add(TestUtility.createContact(acctList[1]));
        contList.add(TestUtility.createContact(acctList[2]));
        contList.add(TestUtility.createContact(acctList[3]));
        contList.add(TestUtility.createContact(acctList[4]));

        insert contList;

        
        //affiliations
        List<Affiliation__c> affList = new List<Affiliation__c>();
        affList.add(TestUtility.createAffiliation(acctList[0], contList[0]));
        affList.add(TestUtility.createAffiliation(acctList[1], contList[1]));
        affList.add(TestUtility.createAffiliation(acctList[2], contList[2]));
        affList.add(TestUtility.createAffiliation(acctList[3], contList[3]));
        affList.add(TestUtility.createAffiliation(acctList[4], contList[4]));

        insert affList;

            
    }

    /*  
        Testing accounts with missing links with license/resale numbers present. One of the account has 2 resales. The 

        Total of 5 accounts. 
        Account Name - Test 1 : 1 license and 1 resale
        Account Name - Test 2 : 1 license and 2 resale. Different resale numbers. Latest S3 link is updated based on CreatedDate
        Account Name - Test 3 : No dealer docs
        Account Name - Test 4 : 1 license 
        Account Name - Test 5 : 1 resale
    */
    @isTest
    static void runTest() {
       
        //start test
        Test.startTest();
        List<Account> acctList = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account ORDER BY Name ASC]; 
        
        //dates
        Date crDate1 = System.Today().addDays(-10);
        Date crDate2 = System.Today().addDays(-5);
        Date expDate1 = System.Today().addDays(5);
        Date expDate2 = System.Today().addDays(10);

        //need docs for appropriate accounts
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '11111', S3_Link__c= 'http://s3.acvauctions/license1.pdf', Account__c = acctList[0].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '22222', S3_Link__c= 'http://s3.acvauctions/resale1.pdf', Account__c = acctList[0].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '33333',  S3_Link__c= 'http://s3.acvauctions/license2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '44444',  S3_Link__c= 'http://s3.acvauctions/resale2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '88888',  S3_Link__c= 'http://s3.acvauctions/resale2_updated.pdf', Account__c = acctList[1].Id, Document_State__c = 'FL', Expiration_Date__c = expDate2, Compliant__c = true, CreatedDate= crDate2));
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '55555', S3_Link__c= 'http://s3.acvauctions/license4.pdf', Account__c = acctList[3].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '66666', S3_Link__c= 'http://s3.acvauctions/resale5.pdf', Account__c = acctList[4].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        
        insert docList;

        for(Account a: acctList)
        {
            a.License_S3_Link__c= null;
            a.Permit_Resale_S3_Link__c= null;
        }
        update acctList;

        
        System.assertEquals(null, acctList[0].License_S3_Link__c);
        System.assertEquals(null, acctList[0].Permit_Resale_S3_Link__c);
        System.assertEquals(null, acctList[1].License_S3_Link__c);
        System.assertEquals(null, acctList[1].Permit_Resale_S3_Link__c);
        System.assertEquals(null, acctList[2].License_S3_Link__c);
        System.assertEquals(null, acctList[2].Permit_Resale_S3_Link__c);
        System.assertEquals(null, acctList[3].License_S3_Link__c);
        System.assertEquals(null, acctList[3].Permit_Resale_S3_Link__c);
        System.assertEquals(null, acctList[4].License_S3_Link__c);
        System.assertEquals(null, acctList[4].Permit_Resale_S3_Link__c);

        //run batch
        SchedulableContext sc = null;
        DealerDocInfoAccountPopulationBatch batch = new DealerDocInfoAccountPopulationBatch();
        Batch.execute(sc);
        
        //stop test
        Test.stopTest();
        List<Account> acctListUpdated = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account ORDER BY Name ASC]; 
        
        System.assertEquals('http://s3.acvauctions/license1.pdf', acctListUpdated[0].License_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/resale1.pdf', acctListUpdated[0].Permit_Resale_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/license2.pdf', acctListUpdated[1].License_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/resale2_updated.pdf', acctListUpdated[1].Permit_Resale_S3_Link__c); // latest of 2 resales.
        System.assertEquals(null, acctListUpdated[2].License_S3_Link__c);
        System.assertEquals(null, acctListUpdated[2].Permit_Resale_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/license4.pdf', acctListUpdated[3].License_S3_Link__c);
        System.assertEquals(null, acctListUpdated[3].Permit_Resale_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/resale5.pdf', acctListUpdated[4].Permit_Resale_S3_Link__c);
        System.assertEquals(null, acctListUpdated[4].License_S3_Link__c);
      
    }



     /*  
        Testing accounts with missing links and missing license number. If the license number is missing then link is not copied.
     */
   
    @isTest
    static void AccountsWithMissingLicenseNumberTest() {
       
        //start test
        Test.startTest();
        List<Account> acctList = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account ORDER BY Name ASC];

        //dates
        Date crDate1 = System.Today().addDays(-10);
        Date crDate2 = System.Today().addDays(-5);
        Date expDate1 = System.Today().addDays(5);
        Date expDate2 = System.Today().addDays(10);

        //need docs for appropriate accounts
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '11111', S3_Link__c= 'http://s3.acvauctions/license1.pdf', Account__c = acctList[0].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '22222', S3_Link__c= 'http://s3.acvauctions/resale1.pdf', Account__c = acctList[0].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '33333',  S3_Link__c= 'http://s3.acvauctions/license2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '44444',  S3_Link__c= 'http://s3.acvauctions/resale2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '88888',  S3_Link__c= 'http://s3.acvauctions/resale2_updated.pdf', Account__c = acctList[1].Id, Document_State__c = 'FL', Expiration_Date__c = expDate2, Compliant__c = true, CreatedDate= crDate2));
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '55555', S3_Link__c= 'http://s3.acvauctions/license4.pdf', Account__c = acctList[3].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '66666', S3_Link__c= 'http://s3.acvauctions/resale5.pdf', Account__c = acctList[4].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        
        insert docList;

        acctList[0].License_Number__c= null;//resetting the license number to null
        acctList[0].Permit_Resale_S3_Link__c= null;
        acctList[0].License_S3_Link__c= null;
        update acctList;
        
        System.assertEquals(null, acctList[0].License_S3_Link__c);
        System.assertEquals(null, acctList[0].Permit_Resale_S3_Link__c);
   
        //run batch
        SchedulableContext sc = null;
        DealerDocInfoAccountPopulationBatch batch = new DealerDocInfoAccountPopulationBatch();
        Batch.execute(sc);
        
        //stop test
        Test.stopTest();
        List<Account> acctListUpdated = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account WHERE Name= 'Test 1' ORDER BY Name ASC];
        
        System.assertEquals(null, acctListUpdated[0].License_S3_Link__c);// License S3 is copied since license number is null on the account record.
        System.assertEquals('http://s3.acvauctions/resale1.pdf', acctListUpdated[0].Permit_Resale_S3_Link__c);
      
    }

    /*  
        Testing accounts with multiple resales with same resale number. Latest S3 link is copied.    
     */
   
    @isTest
    static void AccountWithMultipleDealerDocsWithSameNumber() {
       
        //start test
        Test.startTest();
       /*
        List<Dealer_Docs__c> dealerDocs = [SELECT Id, Permit_Resale_Number__c FROM Dealer_Docs__c WHERE  Permit_Resale_Number__c = '88888' ORDER BY Name ASC]; 
        dealerDocs[0].Permit_Resale_Number__c= '44444';
        update dealerDocs;
        */
        List<Account> acctList = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c, Permit_Resale_Number__c FROM Account ORDER BY Name ASC]; 

        //dates
        Date crDate1 = System.Today().addDays(-10);
        Date crDate2 = System.Today().addDays(-5);
        Date expDate1 = System.Today().addDays(5);
        Date expDate2 = System.Today().addDays(10);

        //need docs for appropriate accounts
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '11111', S3_Link__c= 'http://s3.acvauctions/license1.pdf', Account__c = acctList[0].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '22222', S3_Link__c= 'http://s3.acvauctions/resale1.pdf', Account__c = acctList[0].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '33333',  S3_Link__c= 'http://s3.acvauctions/license2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '44444',  S3_Link__c= 'http://s3.acvauctions/resale2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '44444',  S3_Link__c= 'http://s3.acvauctions/resale2_updated.pdf', Account__c = acctList[1].Id, Document_State__c = 'FL', Expiration_Date__c = expDate2, Compliant__c = true, CreatedDate= crDate2));
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '55555', S3_Link__c= 'http://s3.acvauctions/license4.pdf', Account__c = acctList[3].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '66666', S3_Link__c= 'http://s3.acvauctions/resale5.pdf', Account__c = acctList[4].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        
        insert docList;

        acctList[1].Permit_Resale_S3_Link__c= null;
        acctList[1].License_S3_Link__c= null;
        acctList[1].Permit_Resale_Number__c= '44444';
        update acctList;

        System.assertEquals(null, acctList[1].License_S3_Link__c);
        System.assertEquals(null, acctList[1].Permit_Resale_S3_Link__c);

        //run batch
        SchedulableContext sc = null;
        DealerDocInfoAccountPopulationBatch batch = new DealerDocInfoAccountPopulationBatch();
        Batch.execute(sc);
        
        //stop test
        Test.stopTest();
        List<Account> acctListUpdated = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account WHERE Name= 'Test 2' ORDER BY Name ASC];
        
        System.assertEquals('http://s3.acvauctions/license2.pdf', acctListUpdated[0].License_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/resale2_updated.pdf', acctListUpdated[0].Permit_Resale_S3_Link__c);// Latest link based on created date is copied.
      
    }

    /*  
        Testing accounts with multiple resale documents with different resale number. Resale number needs to be matched to copy the link.
     */
   
    @isTest
    static void AccountWithMultipleDealerDocsWithDifferentNumber() {
       
        //start test
        Test.startTest();
        
        List<Account> acctList = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c, Permit_Resale_Number__c FROM Account ORDER BY Name ASC]; 
        
        //dates
        Date crDate1 = System.Today().addDays(-10);
        Date crDate2 = System.Today().addDays(-5);
        Date expDate1 = System.Today().addDays(5);
        Date expDate2 = System.Today().addDays(10);

        //need docs for appropriate accounts
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '11111', S3_Link__c= 'http://s3.acvauctions/license1.pdf', Account__c = acctList[0].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '22222', S3_Link__c= 'http://s3.acvauctions/resale1.pdf', Account__c = acctList[0].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '33333',  S3_Link__c= 'http://s3.acvauctions/license2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '44444',  S3_Link__c= 'http://s3.acvauctions/resale2.pdf', Account__c = acctList[1].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '88888',  S3_Link__c= 'http://s3.acvauctions/resale2_updated.pdf', Account__c = acctList[1].Id, Document_State__c = 'FL', Expiration_Date__c = expDate2, Compliant__c = true, CreatedDate= crDate2));
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '55555', S3_Link__c= 'http://s3.acvauctions/license4.pdf', Account__c = acctList[3].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true, CreatedDate= crDate1));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '66666', S3_Link__c= 'http://s3.acvauctions/resale5.pdf', Account__c = acctList[4].Id, Document_State__c = 'FL', Expiration_Date__c = expDate1, Compliant__c = true, Document_Expired__c = true, CreatedDate= crDate1)); 
        
        insert docList;
                
        
        //System.assertEquals('88888', acctList[1].Permit_Resale_Number__c);
        acctList[1].Permit_Resale_S3_Link__c= null;
        acctList[1].License_S3_Link__c= null;
        acctList[1].Permit_Resale_Number__c= '44444';
        update acctList;


        System.assertEquals(null, acctList[1].License_S3_Link__c);
        System.assertEquals(null, acctList[1].Permit_Resale_S3_Link__c);

        //run batch
        SchedulableContext sc = null;
        DealerDocInfoAccountPopulationBatch batch = new DealerDocInfoAccountPopulationBatch();
        Batch.execute(sc);
        
        //stop test
        Test.stopTest();
        List<Account> acctListUpdated = [SELECT Id, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account WHERE Name= 'Test 2' ORDER BY Name ASC];
        
        System.assertEquals('http://s3.acvauctions/license2.pdf', acctListUpdated[0].License_S3_Link__c);
        System.assertEquals('http://s3.acvauctions/resale2.pdf', acctListUpdated[0].Permit_Resale_S3_Link__c);// resale link matching the number is copied even though 88888 has latest create date.
      
    }

    /*
    @isTest
    static void bulkTest() {
        Test.startTest();
        //need 25 accounts
            List<Account> accountList = new List<Account>();
            List<Contact> contactList = new List<Contact>();
            List<Affiliation__c> affilList = new List<Affiliation__c>();
            for (Integer i = 0; i < 1; i ++) { //do i need to include the four accounts in the MakeData in the total of 25 here? and make it 21? yep...
                accountList.add(TestUtility.createAccount('TestAccount' + i));
            }
            insert accountList;
            for (Integer i = 0; i < 1; i ++) {
                contactList.add(TestUtility.createContact(accountList[i]));
            }
            insert contactList;
            for (Integer i = 0; i < 1; i ++) {
                affilList.add(TestUtility.createAffiliation(accountList[i], contactList[i]));
            }
            insert affilList;
            //need two docs for each
            List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
            for (Integer i = 0; i < 1; i ++) {
                docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '11111', Account__c = accountList[i].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true));
                docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '22222', Account__c = accountList[i].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true));
            }
            insert docList;
        //run batch
        //start test
        //run batch
            SchedulableContext sc = null;
            DealerDocInfoAccountPopulationBatch batch = new DealerDocInfoAccountPopulationBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();
        //test "pass" condition is: no errors thrown - if error, drop batch size
    }
 */
    @isTest
    static void errorCheck() { //for code coverage
        //populate errorList
        DealerDocInfoAccountPopulationBatch.errorList.add('error');
        //start test
        Test.startTest();
        //run batch
            SchedulableContext sc = null;
            DealerDocInfoAccountPopulationBatch batch = new DealerDocInfoAccountPopulationBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();
    }
   
}