/**
 * 
 * @description Test class for AccountComplianceMassReevaluationBatch that checks for no errors after running through the batch process to evaluate each account for compliance status
 * @author Kendall Priebe
 * @since 4/14/2022
 * @group Sales
 */
@isTest
public with sharing class AccountComplianceMassReevaluationTest { //the biggest issue with this batch is that it relies on all of the docs to be marked compliant correctly, but idk about that
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @isTest
    static void batchTest() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        //need several accounts to test in the batch
        List<Account> accountList = new List<Account>();
        accountList.add(new Account(Name = 'Account1', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '111', Active__c = true, legal_Name__c='Account1', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', phone= '1234567890')); //this one will have two compliant docs
        accountList.add(new Account(Name = 'Account2', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '222', Active__c = true, legal_Name__c='Account2', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14215', BillingCountry='US', phone= '1234567890')); //this one will have two compliant docs but the license is in a special state
        accountList.add(new Account(Name = 'Account3', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '333', Active__c = false, legal_Name__c='Account3', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14216', BillingCountry='US', phone= '1234567890')); //this one will have one compliant license in DE
        accountList.add(new Account(Name = 'Account4', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '444', Active__c = true, legal_Name__c='Account4', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14217', BillingCountry='US', phone= '1234567890')); //this one will only have a resale cert
        accountList.add(new Account(Name = 'Account5', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '555', Active__c = true, legal_Name__c='Account5', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14218', BillingCountry='US', phone= '1234567890')); //this one will only have a resale cert but in a special state
        accountList.add(new Account(Name = 'Account6', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '666', Active__c = false, legal_Name__c='Account6', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14219', BillingCountry='US', phone= '1234567890')); //this one will only have a license in a normal state
        accountList.add(new Account(Name = 'Account7', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '777', Active__c = true, legal_Name__c='Account7', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14221', BillingCountry='US', phone= '1234567890')); //this one will only have expired docs
        accountList.add(new Account(Name = 'Account8', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '888', Active__c = false, legal_Name__c='Account8', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14222', BillingCountry='US', phone= '1234567890')); //this one will have a valid license, but an expired resale
        accountList.add(new Account(Name = 'Account9', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '999', Active__c = true, legal_Name__c='Account9', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14233', BillingCountry='US', phone= '1234567890')); //this one will not have docs at all
        accountList.add(new Account(Name = 'Account10', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '101', Active__c = true, legal_Name__c='Account10', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14244', BillingCountry='US', phone= '1234567890')); //this owne will have two compliant docs - control
        accountList.add(new Account(Name = 'Account11', IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '1111', Active__c = true, legal_Name__c='Account11', dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14255', BillingCountry='US', phone= '1234567890')); //this one will not have docs at all - control
        insert accountList;

        Contact c = TestUtility.createContact(accountList[0]);
        insert c;

        List<Affiliation__c> affList = new List<Affiliation__c>();
        Affiliation__c aff = TestUtility.createAffiliation( accountList[0], c );
        affList.add( aff );
        Affiliation__c aff1 = TestUtility.createAffiliation( accountList[1], c );
        affList.add( aff1 );
        Affiliation__c aff2 = TestUtility.createAffiliation( accountList[2], c );
        affList.add( aff2 );
        Affiliation__c aff3 = TestUtility.createAffiliation( accountList[3], c );
        affList.add( aff3 );
        Affiliation__c aff4 = TestUtility.createAffiliation( accountList[4], c );
        affList.add( aff4 );
        Affiliation__c aff5 = TestUtility.createAffiliation( accountList[5], c );
        affList.add( aff5 );
        Affiliation__c aff6 = TestUtility.createAffiliation( accountList[6], c );
        affList.add( aff6 );
        Affiliation__c aff7 = TestUtility.createAffiliation( accountList[7], c );
        affList.add( aff7 );
        Affiliation__c aff8 = TestUtility.createAffiliation( accountList[8], c );
        affList.add( aff8 );
        Affiliation__c aff9 = TestUtility.createAffiliation( accountList[9], c );
        affList.add( aff9 );
        insert affList;

        //going to need expiration dates (maybe one in future and one in past)
        Date future = System.today().addMonths(5);
        Date past = System.today().addMonths(-5);

        //going to need a variety of dealer docs for these accounts
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '11111', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '22222', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '33333', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, RecordTypeId = licenseId, Document_State__c = 'OR', License_Number__c = '44444', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[2].Id, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '55555', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[3].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '66666', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[4].Id, RecordTypeId = resaleId, Document_State__c = 'DE', Permit_Resale_Number__c = '77777', No_Expiration__c = true, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[5].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '88888', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[6].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '99999', Expiration_Date__c = past, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[6].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '10101', Expiration_Date__c = past, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[7].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '111111', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[7].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '12121', Expiration_Date__c = past, Compliant__c = false));
        docList.add(new Dealer_Docs__c(Account__c = accountList[9].Id, RecordTypeId = licenseId, Document_State__c = 'FL', License_Number__c = '13131', Expiration_Date__c = future, Compliant__c = true));
        docList.add(new Dealer_Docs__c(Account__c = accountList[9].Id, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '14141', Expiration_Date__c = future, Compliant__c = true));
        insert docList;
        
        //need to update some of the accounts to be incorrect with doc status
        for (Account a : accountList) {
            if (a.Name == 'Account1' || a.Name == 'Account2' || a.Name == 'Account3') {
                a.Dealer_Doc_Compliance__c = 'Out Of Compliance';
                a.Inactive_Sub_Status__c = '1';
            }
            else if (a.Name != 'Account10' && a.Name != 'Account11') {
                a.Dealer_Doc_Compliance__c = 'Compliant';
            }
        }
        update accountList;
        
        //run batch
        //start test
        Test.startTest();
        //run batch
            TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
            SchedulableContext sc = null;
            AccountComplianceMassReevaluationBatch batch = new AccountComplianceMassReevaluationBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();
        //noooooot really sure how to check that this is running correctly since we're not updating records right now
    }

    /**
     * @see https://acvauctions.atlassian.net/browse/SI-525
     */
    static void bulkTest() {
        //create a date
        Date past = System.Today().addMonths(-5);
        //create some accounts
        List<Account> accountList = new List<Account>();
        for (Integer i = 0; i < 50; i ++) {
            accountList.add(new Account(Name = 'Account' + i, legal_Name__c='Account' + i, dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), Dealership_Id__c = '1' + i, Active__c = true, BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14299', BillingCountry='US', phone= '1234567890'));
        }
        //insert account
        insert accountList;
        //create 200 dealer docs
        List<Dealer_Docs__c> bulkDocs = new List<Dealer_Docs__c>();
        for (Integer i = 0; i < 50; i ++) {
            bulkDocs.add(new Dealer_Docs__c(Account__c = accountList[i].Id, Expiration_Date__c = past, RecordTypeId = resaleId, Document_State__c = 'FL', Permit_Resale_Number__c = '11111'));
        }
        //insert docs
        insert bulkDocs;
        //update accounts to be compliant
        for (Account a : accountList) {
            a.Dealer_Doc_Compliance__c = 'Compliant';
        }
        update accountList;
        //run through batch
        //start test
        Test.startTest();
        //run batch
            SchedulableContext sc = null;
            AccountComplianceMassReevaluationBatch batch = new AccountComplianceMassReevaluationBatch();
            Batch.execute(sc);
        //stop test
        Test.stopTest();
        //test "pass" condition is: no errors thrown
    }

    // @isTest
    // static void errorTest() {
    //     //populate errorList
    //     AccountComplianceMassReevaluationBatch.errorList.add('error');
    //     //start test
    //     Test.startTest();
    //     //run batch
    //         SchedulableContext sc = null;
    //         AccountComplianceMassReevaluationBatch batch = new AccountComplianceMassReevaluationBatch();
    //         Batch.execute(sc);
    //     //stop test
    //     Test.stopTest();
    // }
}