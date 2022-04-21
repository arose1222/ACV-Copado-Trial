@isTest
public class CaseArbitrationProcessesTest {
    @TestSetup
    static void makeData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        String uniqueUserName = 'Adminuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        // User u = new User(Alias = 'admint', Email='adminuser@testorg.com',
        // EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        // LocaleSidKey='en_US',TimeZoneSidKey='America/New_York', ProfileId = p.Id,
        //  UserName=uniqueUserName);
        User u = TestUtility.createUser();

        System.runAs(u){
            insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
            List<Account> accountList = New List<Account>();
            accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId()));
            accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId()));
            insert accountList;
            List<Contact> contactList = new List<Contact>();
            contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id, email='test@email.com'));
            contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id, email='test@email.com'));
            insert contactList;
            vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
            insert newCar;
            vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
            insert newCar1;
            auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[1].id, 
            Seller_Dealership__c = accountList[0].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
            insert newAuction;
            Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
            Case newCase = new Case(accountId = accountList[0].id,RecordTypeId = arbRecordType, Vehicle__c = newCar.id, Claim_Manually_Submitted_Date__c = Date.today());
            insert newCase;
        }
        //add to another method. call method
        Group grp = new Group();
        grp.name = 'Arbitration';
        grp.Type = 'Regular'; 
        insert grp; 
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        insert grpMem1;
    }
    //Arb Denial - Indicate on Parent Case when Child Case is Closed -DONE
    @isTest 
    static void arbDenialChildCaseClosed(){
        case parentcase = new case ();
        insert parentCase;
        System.debug('Parent Case Inserted');

        case childcase = new case(status = 'New');
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support').getRecordTypeId();

        childcase.parentId = parentCase.id;
        childcase.type = 'Arbitration Denial';
        childcase.recordtypeid = arbRecordtype;
        insert childcase;
        System.debug('Child Case Inserted');

        childcase.status = 'Closed';
        CaseArbitrationProcesses.afterUpdateToggle(false);
        update childcase;
        System.debug('Child Case Updated');


        parentcase = [select Arb_Denial_Child_Case_Closed__c from case where id = :parentcase.id limit 1];

        
        System.assertEquals(true, parentcase.arb_denial_child_case_closed__c, 'Parent case does not show child case closed');
        System.Debug('arbDenialChildCaseClosed CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }

    //Process test: Date/Time stamp on Case Reviews. DONE
    @isTest 
    static void dateTimeStamponCase() {
        Test.startTest();
        //These status values can only be picked with CR Review or Arbitration Claims
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Auction__c a = [SELECT id FROM Auction__c LIMIT 1 ];
        case newCase = new case(RecordTypeId = arbRecordType, Status = 'New', Auction_Number__c = a.Id);
        insert newCase;

        newCase = [select status, Date_Time_Case_Status_Under_Review__c from case where Id = : newCase.Id limit 1 ];
        System.assertEquals( null , newCase.Date_Time_Case_Status_Under_Review__c);
        CaseArbitrationProcesses.beforeUpdateToggle(false);
        newCase.status = 'Under Review';
        update newCase;
        newCase = [select status, Date_Time_Case_Status_Under_Review__c from case where Id = : newCase.Id limit 1 ];
        System.assertNotEquals( null , newCase.Date_Time_Case_Status_Under_Review__c);


        System.Debug('dateTimeStamponCase CPU Time: ' + String.valueOf(Limits.getCpuTime()));
        Test.stopTest();
    }
    //Credit/Check: Successful creation of credit ***************************************************************************************************************
    @isTest 
    static void sellerIssueCheckSuccess(){
        Test.startTest();
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Auction__c a = [SELECT id FROM Auction__c LIMIT 1 ];
        case newCase = new case(RecordTypeId = arbRecordType, Status = 'New', Auction_Number__c = a.Id);
        insert newCase;
        Complaint__c newComplaint = new Complaint__c(arbitration_id__c = newCase.Id, valid__c = 'Yes', Reviewed_Avoidable__c = true, Reviewed_Avoidable_Reason__c = true, Reviewed_Invalid_Reason__c = true, Reviewed_Valid__c = true);
        insert newComplaint;
        Resolution__c newResolution = new Resolution__c(Case__c = newCase.Id, 
                                                        complaint_id__c = newComplaint.Id, 
                                                        Amount__c =decimal.valueOf('600'), 
                                                        Resolution__c = 'Seller Issue Check', 
                                                        description__c = 'Test Description', 
                                                        Goodwill__c = false);
        insert newResolution;
        CaseArbitrationProcesses.afterUpdateToggle(false);
        newCase = [SELECT Status FROM Case WHERE Id = : newCase.Id limit 1];
        newCase.status = 'Closed';
        update newCase;
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c WHERE Case__c =:newCase.Id];
        Decimal expected = 2;
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);        
        Test.stopTest();
    }

    @isTest 
    static void createCreditSuccess(){
        Test.startTest();
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Auction__c a = [SELECT id FROM Auction__c LIMIT 1 ];
        case newCase = new case(RecordTypeId = arbRecordType, Status = 'New', Auction_Number__c = a.Id);
        insert newCase;
        Complaint__c newComplaint = new Complaint__c(arbitration_id__c = newCase.Id, valid__c = 'Yes', Reviewed_Avoidable__c = true, Reviewed_Avoidable_Reason__c = true, Reviewed_Invalid_Reason__c = true, Reviewed_Valid__c = true);
        insert newComplaint;
        Resolution__c newResolution = new Resolution__c(Case__c = newCase.Id, 
                                                        complaint_id__c = newComplaint.Id, 
                                                        Amount__c =decimal.valueOf('600'), 
                                                        Resolution__c = 'ACV Credit Assigned', 
                                                        description__c = 'Test Description', 
                                                        Goodwill__c = false);
        insert newResolution;
        CaseArbitrationProcesses.afterUpdateToggle(false);
        newCase = [SELECT Status FROM Case WHERE Id = : newCase.Id limit 1];
        System.debug('newCase: ' + newCase.Status);
        System.debug('newCase.Id: ' + newCase.Id);
        newCase.status = 'Closed';
        update newCase;
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c WHERE Case__c =:newCase.Id];
        Decimal expected = 1;
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);        
        Test.stopTest();
    }

    @isTest 
    static void createCheckSuccess(){
        Test.startTest();
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Auction__c a = [SELECT id FROM Auction__c LIMIT 1 ];
        case newCase = new case(RecordTypeId = arbRecordType, Status = 'New', Auction_Number__c = a.Id);
        insert newCase;
        Complaint__c newComplaint = new Complaint__c(arbitration_id__c = newCase.ID, valid__c = 'Yes', Reviewed_Avoidable__c = true, Reviewed_Avoidable_Reason__c = true, Reviewed_Invalid_Reason__c = true, Reviewed_Valid__c = true);
        insert newComplaint;
        Resolution__c newResolution = new Resolution__c(Case__c = newCase.Id, 
                                                        complaint_id__c = newComplaint.Id, 
                                                        Amount__c =decimal.valueOf('600'), 
                                                        Resolution__c = 'ACV Issue Check', 
                                                        description__c = 'Test Description', 
                                                        Goodwill__c = false);
        insert newResolution;
        CaseArbitrationProcesses.afterUpdateToggle(false);
        newCase = [SELECT Status FROM Case WHERE Id = : newCase.Id limit 1];
        newCase.status = 'Closed';
        update newCase;
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c WHERE Case__c =:newCase.Id];
        Decimal expected = 1;
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);        
        Test.stopTest();
    }

    
    //***************************************************************************************************************

    // arb denial approval process entry - DONE
    // Commented out 2/3/20 to remove status of Denial Pending
    // @istest 
    // static void arbDenialApprovalProcessEntry(){
    //     auction__C newauction = new auction__c();
    //     insert newauction;
    //     Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
    //     case newcase = new case();
    //     newcase = [select recordtypeid, status from case limit 1 ];
    //     newcase.auction_number__C = newauction.id;
    //     newcase.reason_for_denial__C ='Part Exclusion';
    //     newcase.recordtypeid = arbRecordtype;
    //     newcase.status = 'Denial Pending';
    //     newcase.Buyer_Confusion__c = 'No';
    //     newcase.IST_Account_Owner_Lookup__c = UserInfo.getUserId();
    //     update newcase;

    //     newcase = [select recordtypeid,Denial_Status__c,IST_Account_Owner_Lookup__c, status from case where id = :newcase.id limit 1 ]; 
    //     system.assertequals('Closed',  newcase.status);
    //     system.assertequals('Denial Pending', newcase.Denial_Status__c);
    //     System.Debug('arbDenialApprovalProcessEntry CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    // }

    //Process: Sync Buyers Assurance Exceptions DONE
    @isTest 
    static void syncBuyersAsssuranceExceptions(){
        account newaccount = new account();
        newaccount = [select id,Buyer_s_Assurance_Exceptions__c from account limit 1];
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        case newcase= new case(AccountId = newaccount.id,Buyer_s_Assurance_Exceptions__c='Goodwill', RecordTypeId = arbRecordType);
        insert newcase;

        Test.startTest();
        newCase = [select Buyer_s_Assurance_Exceptions__c,AccountId from case where accountid = :newaccount.id limit 1 ];
        system.assertequals('Goodwill', newcase.Buyer_s_Assurance_Exceptions__c);
        newcase.Buyer_s_Assurance_Exceptions__c = 'Deny';
        CaseArbitrationProcesses.afterUpdateToggle(false);

        System.debug('Starting Update on New Case');
        update newcase;
        Test.stopTest();

        newaccount = [select id,Buyer_s_Assurance_Exceptions__c from account where id = :newAccount.Id limit 1];
        system.assertequals('Deny', newaccount.Buyer_s_Assurance_exceptions__C);

        System.Debug('syncBuyersAsssuranceExceptions CPU Time: ' + String.valueOf(Limits.getCpuTime()));
    }
    @isTest
    static void calculateArbRollups(){
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Auction__c auc = [SELECT Id,Open_Arbitration_Cases__c, Closed_Arbitration_Cases__c FROM Auction__c LIMIT 1];
        System.assertEquals(0, auc.Open_Arbitration_Cases__c);
        Case arbCase = [SELECT Id,Auction_Number__c FROM Case WHERE Auction_Number__c = null LIMIT 1];
        arbCase.Auction_Number__c = auc.Id;
        System.debug('FIRST CASE UPDATE STARTED');
        update arbCase;
        
        auc = [SELECT Id,Open_Arbitration_Cases__c, Closed_Arbitration_Cases__c FROM Auction__c LIMIT 1];
        System.assertEquals(1, auc.Open_Arbitration_Cases__c);
        // CaseArbitrationProcesses.beforeInserttoggle(false);
        // CaseArbitrationProcesses.afterInserttoggle(false);
        System.debug('SECOND CASE INSERT STARTED');
        Test.startTest();
        insert new Case(Auction_Number__c = auc.Id, RecordTypeId = arbRecordType);
        Test.stopTest();
        
        auc = [SELECT Id,Open_Arbitration_Cases__c, Closed_Arbitration_Cases__c FROM Auction__c LIMIT 1];
        System.assertEquals(2, auc.Open_Arbitration_Cases__c);

    }
    @IsTest
    static void testToggles(){
        Boolean foo = false;
        CaseArbitrationProcesses.beforeInsertToggle();
        CaseArbitrationProcesses.beforeInsertToggle(foo);
        CaseArbitrationProcesses.afterInsertToggle();
        CaseArbitrationProcesses.afterInsertToggle(foo);
        CaseArbitrationProcesses.beforeUpdateToggle();
        CaseArbitrationProcesses.beforeUpdateToggle(foo);
        CaseArbitrationProcesses.afterUpdateToggle();
        CaseArbitrationProcesses.afterUpdateToggle(foo);
    }
}