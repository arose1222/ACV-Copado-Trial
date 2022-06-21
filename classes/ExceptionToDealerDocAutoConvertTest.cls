@isTest
private class ExceptionToDealerDocAutoConvertTest {
    public static final Id licenseId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Exception__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

	    @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        //dates
        Date future = System.Today().addMonths(5);
        Date past = System.Today().addMonths(-5);
        //user
        String uniqueUserName = 'Adminuser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'test', Email='Adminuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',TimeZoneSidKey='America/New_York', ProfileId = p.Id, UserName=uniqueUserName, isActive = true);

        insert u;
        PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = 'Bypass_Dealer_Doc_Exception_Validations'];
        PermissionSetAssignment permAssign = new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = permSet.Id);
        insert permAssign;
        //account
        System.runAs(u) {
            insert new Account(Name = 'Test Account', Dealership_Id__c = '1111', Legal_Name__c = 'Test Account', Active__c = false, IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Type__c = 'Independent');
            //resale certs
            List<Exception__c> exList = new List<Exception__c>();
            exList.add(new Exception__c(Name = 'test', Dealer_Id__c = '1111', RecordTypeId = resaleId, Document_State__c = 'FL', Date_Signed__c = past, Permit_Resale_Number__c = '11111'));
            exList.add(new Exception__c(Name = 'test', Dealer_Id__c = '1111', RecordTypeId = resaleId, Document_State__c = 'FL', Date_Signed__c = past, Permit_Resale_Number__c = '22222'));
            exList.add(new Exception__c(Name = 'test', Dealer_Id__c = '1111', RecordTypeId = resaleId, Document_State__c = 'FL', Date_Signed__c = past, Permit_Resale_Number__c = '33333'));
            exList.add(new Exception__c(Name = 'test', Dealer_Id__c = '1111', RecordTypeId = resaleId, Document_State__c = 'FL', Date_Signed__c = past, Permit_Resale_Number__c = '44444'));
            exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CO', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = future, License_Number_ML__c = '55555', License_Number_Dealer_Entered__c = '66666'));
            exList.add(new Exception__c(Name = '1', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CO', Expiration_Date_ML__c = past, Expiration_Date_Dealer_Entered__c = past, License_Number_ML__c = '77777', License_Number_Dealer_Entered__c = '88888'));
            exList.add(new Exception__c(Name = '2', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'AZ', Document_State_Dealer_Entered__c = 'AZ', Expiration_Date_Dealer_Entered__c = past, License_Number_ML__c = '99999', License_Number_Dealer_Entered__c = '00000'));
            exList.add(new Exception__c(Name = '3', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'VT', Document_State_Dealer_Entered__c = 'VT', License_Number_ML__c = '101010', License_Number_Dealer_Entered__c = '121212'));
            exList.add(new Exception__c(Name = '4', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CO', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = future, License_Number_ML__c = '131313', License_Number_Dealer_Entered__c = '141414'));
            exList.add(new Exception__c(Name = '5', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CO', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = future, License_Number_ML__c = '151515', License_Number_Dealer_Entered__c = '161616'));
        
            insert exList;
        }
    }

    @isTest
    static void resaleTests() {
        //dates
        Date future = System.Today().addMonths(5);
        Date past = System.Today().addMonths(-5);
        //on update
        List<Exception__c> exListRes = [SELECT Id, Dealer_Id__c, RecordTypeId, Document_State__c, Date_Signed__c, Expiration_Date__c, Permit_Resale_Number__c, Review_Decision__c, Status__c FROM Exception__c WHERE RecordTypeId = :resaleId];
        for (Exception__c e : exListRes) {
            if (e.Permit_Resale_Number__c == '11111') {
                e.Expiration_Date__c = future;
                e.Compliant__c = true;
                e.Review_Status__c = 'Complete';
                e.Review_Decision__c = 'Current and Compliant Document';
                e.Status__c = 'Closed';
            }
            else if (e.Permit_Resale_Number__c == '22222') {
                e.Expiration_Date__c = past;
                e.Review_Decision__c = 'Historical Document';
                e.Status__c = 'Closed';
            }
            else if (e.Permit_Resale_Number__c == '33333') {
                e.Review_Decision__c = 'Invalid Document'; //should be able to save this with the changes to the validation rules
                e.Status__c = 'Closed';
            }
            else if (e.Permit_Resale_Number__c == '44444') {
                e.Review_Decision__c = 'Poor Document Quality'; //should be able to save this with the changes to the validation rules
                e.Status__c = 'Closed';
            }
        }
        update exListRes;
        //resale w/ expDate in future - successful convert
        //resale w/ expDate in past - successful convert
        //resale w/ invalid/poor quality - not converted (maybe one of each)

        //query for dealer docs
        List<Dealer_Docs__c> docList = [SELECT Id, Permit_Resale_Number__c FROM Dealer_Docs__c ORDER BY Permit_Resale_Number__c ASC];
        System.assertEquals(2, docList.size());
        System.assertEquals('11111', docList[0].Permit_Resale_Number__c);
        System.assertEquals('22222', docList[1].Permit_Resale_Number__c);
    }

    @isTest
    static void licenseTestsInsert() {
        //dates
        Date future = System.Today().addMonths(5);
        Date past = System.Today().addMonths(-5);
        //query for user
        User u = [SELECT Id FROM User WHERE Email = 'Adminuser@testorg.com' AND isActive = true LIMIT 1];
        //on insert
        List<Exception__c> exList = new List<Exception__c>();
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CT', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = future, License_Number_ML__c = '11111', License_Number_Dealer_Entered__c = '11111', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CT', Expiration_Date_ML__c = past, Expiration_Date_Dealer_Entered__c = past, License_Number_ML__c = '22222', License_Number_Dealer_Entered__c = '22222', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'VT', Document_State_Dealer_Entered__c = 'VT', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = future, License_Number_ML__c = '33333', License_Number_Dealer_Entered__c = '33333', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'AZ', Document_State_Dealer_Entered__c = 'AZ', Expiration_Date_ML__c = past, Expiration_Date_Dealer_Entered__c = past, License_Number_ML__c = '44444', License_Number_Dealer_Entered__c = '44444', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'VT', Document_State_Dealer_Entered__c = 'VT', Expiration_Date_ML__c = null, Expiration_Date_Dealer_Entered__c = null, License_Number_ML__c = '55555', License_Number_Dealer_Entered__c = '55555', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'AZ', Document_State_Dealer_Entered__c = 'AZ', Expiration_Date_ML__c = null, Expiration_Date_Dealer_Entered__c = null, License_Number_ML__c = '66666', License_Number_Dealer_Entered__c = '66666', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CT', Expiration_Date_ML__c = null, Expiration_Date_Dealer_Entered__c = null, License_Number_ML__c = '77777', License_Number_Dealer_Entered__c = '77777', Manual_Validation_Required__c = false));
        exList.add(new Exception__c(Name = '0', Dealer_Id__c = '1111', RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CO', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = past, License_Number_ML__c = '88888', License_Number_Dealer_Entered__c = '99999'));
        System.runAs(u) {
            insert exList;
        }

        //query for docs
        List<Dealer_Docs__c> docList = [SELECT Id, Compliant__c, Document_Expired__c, Compliance_Issues__c FROM Dealer_Docs__c ORDER BY License_Number__c ASC];
        System.assertEquals(2, docList.size());
        System.assertEquals(true, docList[0].Compliant__c);
        System.assertEquals(false, docList[1].Compliant__c);
        System.assertEquals('Document expired', docList[1].Compliance_Issues__c);
    }

    @isTest
    static void licenseTestsUpdate() {
        //dates
        Date future = System.Today().addMonths(5);
        Date past = System.Today().addMonths(-5);
        //on update
        List<Exception__c> exListLic = [SELECT Id, Dealer_Id__c, RecordTypeId, Document_State__c, Document_State_ML__c, Document_State_Dealer_Entered__c, Expiration_Date__c, Expiration_Date_ML__c, Expiration_Date_Dealer_Entered__c, No_Expiration__c, License_Number__c, License_Number_ML__c, License_Number_Dealer_Entered__c, Review_Decision__c, Status__c FROM Exception__c WHERE RecordTypeId = :licenseId];
        for (Exception__c e : exListLic) {
            if (e.License_Number_ML__c == '55555') {
                e.Expiration_Date__c = future;
                e.Document_State__c = e.Document_State_ML__c;
                e.License_Number__c = e.License_Number_ML__c;
                e.Compliant__c = true;
                e.Review_Status__c = 'Complete';
                e.Review_Decision__c = 'Current and Compliant Document';
                e.Status__c = 'Closed';
            }
            else if (e.License_Number_ML__c == '77777') {
                e.Expiration_Date__c = past;
                e.Document_State__c = e.Document_State_ML__c;
                e.License_Number__c = e.License_Number_ML__c;
                e.Review_Decision__c = 'Historical Document';
                e.Status__c = 'Closed';
            }
            else if (e.License_Number_ML__c == '99999') {
                e.No_Expiration__c = true;
                e.Document_State__c = e.Document_State_ML__c;
                e.License_Number__c = e.License_Number_ML__c;
                e.Compliant__c = true;
                e.Review_Status__c = 'Complete';
                e.Review_Decision__c = 'Current and Compliant Document';
                e.Status__c = 'Closed';
            }
            else if (e.License_Number_ML__c == '101010') {
                e.No_Expiration__c = true;
                e.Document_State__c = e.Document_State_ML__c;
                e.License_Number__c = e.License_Number_ML__c;
                e.Compliant__c = true;
                e.Review_Status__c = 'Complete';
                e.Review_Decision__c = 'Current and Compliant Document';
                e.Status__c = 'Closed';
            }
            else if (e.License_Number_ML__c == '131313') {
                e.Review_Decision__c = 'Invalid Document'; //should be able to save this with the changes to the validation rules
                e.Status__c = 'Closed';
            }
            else if (e.License_Number_ML__c == '151515') {
                e.Review_Decision__c = 'Poor Document Quality'; //should be able to save this with the changes to the validation rules
                e.Status__c = 'Closed';
            }
        }
        update exListLic;
        //license w/ expDate in future - successful convert
        //license w/ expDate in past - successful convert
        //license w/ no expDate (AZ or VT) - successful convert (maybe one of each)
        //license w/ invalid/poor quality - not converted (maybe one of each)

        //query for dealer docs
        List<Dealer_Docs__c> docList2 = [SELECT Id, License_Number__c FROM Dealer_Docs__c ORDER BY Name ASC];
        System.assertEquals(4, docList2.size());
        System.assertEquals('55555', docList2[0].License_Number__c);
        System.assertEquals('77777', docList2[1].License_Number__c);
        System.assertEquals('99999', docList2[2].License_Number__c);
        System.assertEquals('101010', docList2[3].License_Number__c);
    }

    @isTest
    static void emailFields() {
        //dates
        Date future = System.Today().addMonths(5);
        Date past = System.Today().addMonths(-5);
        //on insert
        User u = [SELECT Id, Email FROM User WHERE Email = 'Adminuser@testorg.com' AND isActive = true LIMIT 1];
        Account a = new Account(Name = 'Test 2', Legal_Name__c = 'Test 2', Dealership_Id__c = '2222', Active__c = false, IST_Account_Owner__c = u.Id, Dealer_Type__c = 'Independent');
        System.runAs(u) {
            insert a; //running as user should set the Account Owner to that user
        }
        Contact c = TestUtility.createContact(a);
        insert c;
        c.Email = u.Email;
        update c;
        a.Primary_Contact__c = c.Id;
        update a;
        List<Exception__c> exList2 = new List<Exception__c>();
        exList2.add(new Exception__c(Name = 'test2', Dealer_Id__c = a.Dealership_Id__c, RecordTypeId = resaleId, Document_State__c = 'FL', Date_Signed__c = past, Permit_Resale_Number__c = '11111'));
        exList2.add(new Exception__c(Name = 'test2', Dealer_Id__c = a.Dealership_Id__c, RecordTypeId = licenseId, Document_State_ML__c = 'CT', Document_State_Dealer_Entered__c = 'CO', Expiration_Date_ML__c = future, Expiration_Date_Dealer_Entered__c = future, License_Number_ML__c = '22222', License_Number_Dealer_Entered__c = '33333'));

        System.runAs(u) {
            insert exList2;
        }
        //make sure email fields and acctName are populated for both record types
        exList2 = [SELECT Id, Related_Account_Name__c, IST_Account_Manager_Email__c, Primary_Contact_Email__c, TM_Email__c FROM Exception__c WHERE Name = 'test2'];
        System.assertEquals('Test 2', exList2[0].Related_Account_Name__c);
        System.assertEquals('Test 2', exList2[1].Related_Account_Name__c);
        System.assertEquals(u.Email, exList2[0].IST_Account_Manager_Email__c);
        System.assertEquals(u.Email, exList2[1].IST_Account_Manager_Email__c);
        System.assertEquals(u.Email, exList2[0].Primary_Contact_Email__c);
        System.assertEquals(u.Email, exList2[1].Primary_Contact_Email__c);
        System.assertEquals(u.Email, exList2[0].TM_Email__c);
        System.assertEquals(u.Email, exList2[1].TM_Email__c);
    }
}