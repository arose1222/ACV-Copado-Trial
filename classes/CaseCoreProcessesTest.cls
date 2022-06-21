@isTest
public class CaseCoreProcessesTest {
    @TestSetup
    static void makeData(){
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId()));
        accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id));
        contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id));
        insert contactList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
        vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
        insert newCar1;
        auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[1].id, 
        Seller_Dealership__c = accountList[0].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
        insert newAuction;
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Case newCase = new Case(accountId = accountList[0].id,RecordTypeId = arbRecordType, Vehicle__c = newCar.id);
        insert newCase;
    }
    @istest 
    static void changeCaseOwnertoTakeCaseID(){
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        //System.debug('Current User: ' + UserInfo.getUserName());
        List<User> userList = [SELECT Id FROM USER ];
        Id tempUserId = [SELECT Id FROM Group WHERE Name = 'CR Queue' LIMIT 1].Id;
        Auction__c auct = new Auction__c();
        insert auct;
        Case newCase = new Case(Take_Case_ID__c = UserInfo.getUserId(), OwnerId = tempUserID, Auction_Number__c = auct.Id);
        insert newCase;
        newCase = [SELECT Id, Take_Case_ID__c, Status FROM Case WHERE Id = :newCase.Id LIMIT 1];
        Complaint__c newComp = new Complaint__c(Arbitration_Id__c = newCase.Id, Claim_Parent_Type__c = 'Driveability', Claim_Type__c = 'Driveability - Other'); //hoping i don't have to declare record type here
        insert newComp;
        //System.Debug(newCase.Take_Case_ID__c);

        CaseCoreProcesses.reset();
        System.runAs(u){
            newCase.Take_Case_Id__c = tempUserId;
            newCase.Claim_Manually_Submitted_Date__c = System.today();
            update newcase;
        }

        newCase = [SELECT Take_Case_ID__c, Status FROM Case WHERE Id = :newCase.Id LIMIT 1];
        //System.Debug(newCase.Take_Case_ID__c);

        system.assertequals('Working' , newcase.status  );
        system.assertequals(tempUserId, newcase.take_case_id__c);
        //System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    //Process test: Populate IST Account Owner on Case. DONE
    @isTest
    static void populateISTAccountOwneronCase(){
        Test.startTest();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        Account newaccount = New Account(IST_Account_Owner__c =UserInfo.getUserId(), Name='seller', Buyer_s_assurance_exceptions__c = 'Goodwill');
        insert newaccount;

        Case newCase = new Case(  accountId = newaccount.id, status= 'New', Buyer_s_Assurance_Exceptions__c = 'Goodwill'); // IST_Account_Owner_Lookup__c = newaccount.ist_account_owner__C 
        insert newCase; 
        
        newCase = [Select AccountId, Status, IST_Account_Owner_Lookup__c from Case limit 1 ];

        system.assertNotEquals(null, newCase.IST_Account_Owner_Lookup__c,'IST Account Owner not set');
        //System.Debug('CPU Time: ' + String.valueOf(Limits.getCpuTime()));
        Test.stopTest();

    }
    @IsTest
    static void testNewArbWithAuction(){
      List<Account> accountList = [select id from account where name = 'buyer'];
      List<Auction__c> auctionList = [select id from Auction__c];
      Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
      Case newCase = new Case(Auction_Number__c = auctionList[0].id,RecordTypeId = arbRecordType);
      insert newCase;
      newCase = [SELECT AccountId, ContactId FROM Case WHERE Id = :newCase.Id];
      System.assertEquals([SELECT Id FROM Account WHERE Name = 'buyer'].Id, newCase.AccountId);
      //System.Debug('testNewArbWithAuction CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @IsTest
    static void testNewArbWithOutAuction(){
      List<Account> accountList = [select id from account where name = 'buyer'];
      List<Auction__c> auctionList = [select id from Auction__c];
      Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
      Case newCase = new Case(accountId = accountList[0].id, RecordTypeId = arbRecordType);
      insert newCase;
      newCase = [SELECT Vehicle__c, Auction_Number__C, ContactId FROM Case WHERE Id = :newCase.Id];
      System.assertEquals(null, newCase.Vehicle__c);
      //System.Debug('testNewArbWithOutAuction CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @IsTest
    static void testArbUpdateVehicle(){
      List<Account> accountList = [select id from account where name = 'buyer'];
      List<Case> caseList = [select id, vehicle__c from case];
      List<vehicle__c> carList = [select id from vehicle__c where vin__c = '1234567890102031'];
      caseList[0].vehicle__c = carList[0].id;
      update caseList;
      System.assertEquals('1234567890102031',[SELECT Vehicle_VIN__c FROM Case WHERE Id = :caseList[0].Id].Vehicle_VIN__C);
      //System.Debug('testArbUpdateVehicle CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    @istest
    static void stampPrimaryContactOnCase(){
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        
        Contact conRec = [ SELECT Id, AccountId FROM Contact LIMIT 1 ];
        update new Account( 
          Id = conRec.AccountId, Primary_Contact__c = conRec.Id
        );

        Case newCase = new Case( 
            accountId = conRec.AccountId, status= 'New', Seller_Dealership__c = conRec.AccountId
        );
        
        Test.startTest();
          insert newCase;
          newCase = [ SELECT Id, Seller_Contact__c FROM Case WHERE Id = :newCase.Id ];
          System.assertEquals( newCase.Seller_Contact__c, conRec.Id, 'The Seller Contact should be populated on Case Insert' );
        Test.stopTest();

    }
}