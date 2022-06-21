@isTest
private class DealerDocInfoAccountPopulationTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //need four accounts
        List<Account> acctList = new List<Account>();
        acctList.add(TestUtility.createAccount('Test 1'));
        acctList.add(TestUtility.createAccount('Test 2'));
        acctList.add(TestUtility.createAccount('Test 3'));
        acctList.add(TestUtility.createAccount('Test 4'));
        insert acctList;
        //contacts
        List<Contact> contList = new List<Contact>();
        contList.add(TestUtility.createContact(acctList[0]));
        contList.add(TestUtility.createContact(acctList[1]));
        contList.add(TestUtility.createContact(acctList[2]));
        contList.add(TestUtility.createContact(acctList[3]));
        insert contList;
        //affiliations
        List<Affiliation__c> affList = new List<Affiliation__c>();
        affList.add(TestUtility.createAffiliation(acctList[0], contList[0]));
        affList.add(TestUtility.createAffiliation(acctList[1], contList[1]));
        affList.add(TestUtility.createAffiliation(acctList[2], contList[2]));
        affList.add(TestUtility.createAffiliation(acctList[3], contList[3]));
        insert afflist;
        //need dealer docs
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '33333', S3_Link__c ='S3Link_33333',  Account__c = acctList[1].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '44444',  S3_Link__c ='S3Link_44444',  Account__c = acctList[1].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true));
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '77777',  S3_Link__c ='S3Link_77777', Account__c = acctList[2].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = false));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '88888', S3_Link__c ='S3Link_88888',  Account__c = acctList[2].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = false));
        docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '99999', S3_Link__c ='S3Link_99999',  Account__c = acctList[3].Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = false));
        docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '00000', S3_Link__c ='S3Link_00000',  Account__c = acctList[3].Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = false));
        insert docList;
    }

    @isTest
    static void populateLicenseAndResaleNum() {
        Test.startTest();
            //query for account
            Account a = [SELECT Id FROM Account WHERE Name = 'Test 1'];
            //create two new docs
            List<Dealer_Docs__c> doclist = new List<Dealer_Docs__c>();
            docList.add(new Dealer_Docs__c(RecordTypeId = licenseId, License_Number__c = '11111', S3_Link__c ='S3Link_11111',  Account__c = a.Id, Document_State__c = 'AZ', No_Expiration__c = true, Compliant__c = true));
            docList.add(new Dealer_Docs__c(RecordTypeId = resaleId, Permit_Resale_Number__c = '22222', S3_Link__c ='S3Link_22222', Account__c = a.Id, Document_State__c = 'AK', No_Expiration__c = true, Compliant__c = true));
            //insert
            insert doclist;
            //check updates on account
            a = [SELECT Id, License_Number__c, Permit_Resale_Number__c, License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account WHERE Name = 'Test 1'];
            System.assertEquals('11111', a.License_Number__c);
            System.assertEquals('22222', a.Permit_Resale_Number__c);
            System.assertEquals('S3Link_11111', a.License_S3_Link__c);
            System.assertEquals('S3Link_22222', a.Permit_Resale_S3_Link__c);
        Test.stopTest();
    }

    @isTest
    static void updateLicenseAndResaleNum() {
        Test.startTest();
            //query for docs
            List<Dealer_Docs__c> docList = [SELECT Id, RecordTypeId, License_Number__c, Permit_Resale_Number__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Test 2'];
            //update
            for (Dealer_Docs__c d : docList) {
                if (d.RecordTypeId == licenseId) {
                    d.License_Number__c = '55555';
                    d.S3_Link__c='S3Link_55555';
                }
                else {
                    d.Permit_Resale_Number__c = '66666';
                    d.S3_Link__c='S3Link_66666';
                }
            }
            update docList;
            //query account
            Account a = [SELECT Id, License_Number__c, Permit_Resale_Number__c , License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account WHERE Name = 'Test 2'];
            //system.asserts
            System.assertEquals('55555', a.License_Number__c);
            System.assertEquals('66666', a.Permit_Resale_Number__c);
            System.assertEquals('S3Link_55555', a.License_S3_Link__c);
            System.assertEquals('S3Link_66666', a.Permit_Resale_S3_Link__c);
        Test.stopTest();
    }

    @isTest
    static void updateComplianceIndicator() {
        Test.startTest();
            //query for docs
            List<Dealer_Docs__c> docList = [SELECT Id, RecordTypeId, Compliant__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Test 3'];
            //update
            for (Dealer_Docs__c d : docList) {
                d.Compliant__c = true;
            }
            update docList;
            //query account
            Account a = [SELECT Id, License_Number__c, Permit_Resale_Number__c,  License_S3_Link__c, Permit_Resale_S3_Link__c FROM Account WHERE Name = 'Test 3'];
            //system.asserts
            System.assertEquals('77777', a.License_Number__c);
            System.assertEquals('88888', a.Permit_Resale_Number__c);
            System.assertEquals('S3Link_77777', a.License_S3_Link__c);
            System.assertEquals('S3Link_88888', a.Permit_Resale_S3_Link__c);
        Test.stopTest();
    }

    @isTest
    static void resaleFirst() {
        Test.startTest();
            List<Dealer_Docs__c> docList = [SELECT Id, Compliant__c FROM Dealer_Docs__c WHERE Account__r.Name = 'Test 4'];

            for (Dealer_Docs__c d : docList) {
                d.Compliant__c = true;
            }
            update docList;

            List<Account> acctList = [SELECT Id, License_Number__c, Permit_Resale_Number__c,  License_S3_Link__c, Permit_Resale_S3_Link__c  FROM Account WHERE Name = 'Test 4'];
            //system.asserts
            System.assertEquals('00000', acctList[0].License_Number__c);
            System.assertEquals('99999', acctList[0].Permit_Resale_Number__c);
            System.assertEquals('S3Link_00000', acctList[0].License_S3_Link__c);
            System.assertEquals('S3Link_99999', acctList[0].Permit_Resale_S3_Link__c);
        Test.stopTest();
    }
}