/**
 * 
 * @description Test class for HandleAccountTeamChanges that ensures correct updates happen dependent on different scenarios
 * @author Aaron Richbart
 * @since 4/1/2022
 * @group Sales
 */
@isTest
public class HandleAccountTeamChangesTest {

    public static Integer RECORD_COUNT = 5;

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Related_Case_Object_Access'];
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Inside Sales - Account Managers Unwind'];

        User originalOwner = TestUtility.createUser();
        insert originalOwner;
        User newOwner = TestUtility.createUser(p.Id);
        insert newOwner;

        Account acc = TestUtility.createAccount('With Owner');
        acc.IST_Account_Owner__c = originalOwner.Id;
        insert acc;

        Contact con = TestUtility.createContact(acc);
        insert con;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c auc = TestUtility.createAuction(acc,con,v);
        insert auc;

        List<Case> allCases = new List<Case>();
        allCases.add(TestUtility.createCase(auc, v, acc, con));
        allCases.add(TestUtility.createTitleCase(auc,acc,con));
        allCases.add(TestUtility.createSupportCase(acc));
        insert allCases;

        System.runAs(originalOwner){
            Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(allCases[2],acc);
            ci.Assigned_To__c = originalOwner.id;
            insert ci;
            // Need to create this under runAs to prevent DML exception. 
            insert new PermissionSetAssignment(AssigneeId = newOwner.id, PermissionSetId = ps.Id);
        }
    }

    @isTest
    static void testISTAccountRepChange(){
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        Account acc = [SELECT Id, IST_Account_Owner__c FROM Account WHERE Name = 'With Owner'];
        acc.IST_Account_Owner__c = newUser.Id;
        Test.StartTest();
            update acc;
        Test.StopTest();

        for(Case c : [SELECT Id, OwnerId FROM Case WHERE RecordType.DeveloperName = 'Support' AND AccountId = :acc.Id AND Status != 'Closed']){  
            System.assertEquals(newUser.Id,c.OwnerId,'Owner should be updated to new IST Account Owner on Account');
        }

        for(Customer_Inquiry__c ci : [SELECT Id, OwnerId, Assigned_To__c, CreatedById FROM Customer_Inquiry__c WHERE Account__c = :acc.Id AND Status__c != 'Closed']){ 
            System.assertEquals(newUser.Id,ci.OwnerId,'Owner should be updated to new IST Account Owner on Account');
            System.assertEquals(newUser.Id,ci.Assigned_To__c,'Assigned To should be updated to new IST Account Owner on Account when previous assigned to equals createdBy');
        }
    }

    @isTest
    static void testISTAccountRepChangeOnBuyerOp(){
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
        Account buyerAccount = TestUtility.createAccount('Buyer');
        buyerAccount.IST_Account_Owner__c = UserInfo.getUserId();
        insert buyerAccount;

        Case titleCase = [SELECT Id, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        titleCase.AccountId = buyerAccount.Id;
        update titleCase;

        Customer_Inquiry__c ci = [SELECT Id, Ops_Case__c, Call_Bucket__c, Call_Type__c, Assigned_To__c FROM Customer_Inquiry__c];
        ci.Call_Bucket__c = 'Titles';
        ci.Call_Type__c = 'Seller Title Status';
        ci.Ops_Case__c = titleCase.Id;
        ci.Assigned_To__c = UserInfo.getUserId();
        update ci;
        
        buyerAccount.IST_Account_Owner__c = newUser.Id;
        Test.StartTest();
            update buyerAccount;
        Test.StopTest();

        for(Customer_Inquiry__c inq : [SELECT Id, Assigned_To__c, CreatedById FROM Customer_Inquiry__c]){ 
            System.assertEquals(newUser.Id,inq.Assigned_To__c,'Assigned To should be updated to new IST Account Owner on ops case buyer Account');
        }
    }

    @isTest
    static void testISTAccountRepChangeAccountAndOpSame(){
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
        Account buyerAccount = TestUtility.createAccount('Buyer');
        buyerAccount.IST_Account_Owner__c = UserInfo.getUserId();
        insert buyerAccount;

        Case titleCase = [SELECT Id, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        titleCase.AccountId = buyerAccount.Id;
        update titleCase;

        Customer_Inquiry__c ci = [SELECT Id, Ops_Case__c, Call_Bucket__c, Call_Type__c, Assigned_To__c, Account__c FROM Customer_Inquiry__c];
        ci.Call_Bucket__c = 'Titles';
        ci.Call_Type__c = 'Seller Title Status';
        ci.Ops_Case__c = titleCase.Id;
        ci.Assigned_To__c = UserInfo.getUserId();
        ci.Account__c = buyerAccount.Id;
        update ci;
        
        buyerAccount.IST_Account_Owner__c = newUser.Id;
        Test.StartTest();
            update buyerAccount;
        Test.StopTest();

        for(Customer_Inquiry__c inq : [SELECT Id, Assigned_To__c, CreatedById FROM Customer_Inquiry__c]){ 
            System.assertEquals(newUser.Id,inq.Assigned_To__c,'Assigned To should be updated to new IST Account Owner on ops case buyer Account');
        }
    }

    @isTest
    static void testISTAccountRepChangedToNull(){
        Test.StartTest();
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        Account acc = [SELECT Id, IST_Account_Owner__c FROM Account WHERE Name = 'With Owner'];
        acc.IST_Account_Owner__c = null;
        update acc;
        Test.StopTest();

        for(Case c : [SELECT Id, OwnerId FROM Case WHERE RecordType.DeveloperName = 'Support' AND AccountId = :acc.Id AND Status != 'Closed']){  
            System.assertNotEquals(newUser.Id,c.OwnerId,'Owner should not be updated to when IST Account Owner changed to null');
        }

        for(Customer_Inquiry__c ci : [SELECT Id, OwnerId, Assigned_To__c, CreatedById FROM Customer_Inquiry__c WHERE Account__c = :acc.Id AND Status__c != 'Closed']){  
            System.assertNotEquals(newUser.Id,ci.OwnerId,'Owner should not be updated when IST Account Owner changed to null');
            System.assertNotEquals(newUser.Id,ci.Assigned_To__c,'Assigned To should not be updated when IST Account Owner changed to null');
        }
    }

    @isTest
    static void testISTAccountRepChangedToDoNotCall(){
        Test.StartTest();
        User doNotCall = [SELECT Id FROM User WHERE FirstName = 'Do' AND LastName = 'Not Call'];
        
        Account acc = [SELECT Id, IST_Account_Owner__c FROM Account WHERE Name = 'With Owner'];
        acc.IST_Account_Owner__c = doNotCall.Id;
        update acc;
        
        Test.StopTest();

        for(Case c : [SELECT Id, OwnerId FROM Case WHERE RecordType.DeveloperName = 'Support' AND AccountId = :acc.Id AND Status != 'Closed']){  
            System.assertNotEquals(doNotCall.Id,c.OwnerId,'Owner should not be updated to when IST Account Owner changed to Do Not Call');
        }

        for(Customer_Inquiry__c ci : [SELECT Id, OwnerId, Assigned_To__c, CreatedById FROM Customer_Inquiry__c WHERE Account__c = :acc.Id AND Status__c != 'Closed']){  
            System.assertNotEquals(doNotCall.Id,ci.OwnerId,'Owner should not be updated when IST Account Owner changed to Do Not Call');
            System.assertNotEquals(doNotCall.Id,ci.Assigned_To__c,'Assigned To should not be updated when IST Account Owner changed to Do Not Call');
        }
    }

    @isTest
    static void testISTAccountRepChangedNoOpsUpdate(){
        Test.StartTest();
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        Account acc = [SELECT Id, IST_Account_Owner__c FROM Account WHERE Name = 'With Owner']; 
        acc.IST_Account_Owner__c = newUser.Id;
        update acc;
        
        Test.StopTest();

        for(Case c : [SELECT Id, OwnerId FROM Case WHERE RecordType.DeveloperName = 'Title_Information' AND AccountId = :acc.Id]){  
            System.assertNotEquals(newUser.Id,c.OwnerId,'Owner should not be updated on Title when IST Account Owner changed');
        }
    }
   
    @isTest
    static void testAddAndUpdateTitleSpecialist(){
        Test.StartTest();
            Account sellerAcc = TestUtility.createAccount('Seller');
            insert sellerAcc;
            
            Case titleCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
            titleCase.Seller_Dealership__c = sellerAcc.Id;
            titleCase.Status = 'Closed Unwound';
            update titleCase;
            
            Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c FROM Customer_Inquiry__c];
            inqBefore.Call_Bucket__c = 'Titles';
            inqBefore.Call_Type__c = 'Seller Title Status';
            inqBefore.Ops_Case__c = titleCase.Id;
            update inqBefore;
            
            User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
            
            
            sellerAcc.Title_Specialist__c = newUser.Id;
            update sellerAcc;
        Test.StopTest();

        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        System.assertEquals(newUser.Id,inqAfterAdd.Assigned_To__c,'Assigned To should be updated to new value of Title Specialist');

        sellerAcc.Title_Specialist__c = inqBefore.Assigned_To__c;
        update sellerAcc;

        Customer_Inquiry__c inqAfterChange = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        System.assertEquals(inqBefore.Assigned_To__c,inqAfterChange.Assigned_To__c,'Assigned To should be updated to new value of Title Specialist');
        
    }

    @isTest
    static void testUpdateTitleSpecialistToNull(){
        Test.StartTest();
        Account acc = [SELECT Id, Title_Specialist__c FROM Account WHERE Name = 'With Owner']; 
        acc.Title_Specialist__c = null;
        update acc;
        Test.StopTest();

        Customer_Inquiry__c inqAfterNull = [SELECT Id, Assigned_To__c, OwnerId FROM Customer_Inquiry__c WHERE Account__c = :acc.Id]; 
        System.assertEquals(inqAfterNull.OwnerId,inqAfterNull.Assigned_To__c,'Assigned To should be unchanged and stay same as Owner');
        System.assertNotEquals(null,inqAfterNull.Assigned_To__c,'Assigned To should not be changed to null');
    }

    @isTest
    static void testAddTitleSpecialistInquiryWithOps(){

        Test.StartTest();
        Account sellerAcc = TestUtility.createAccount('Seller');
        insert sellerAcc;
        
        Case titleCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        titleCase.Seller_Dealership__c = sellerAcc.Id;
        titleCase.Status = 'Problem';
        update titleCase;
        
        Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c FROM Customer_Inquiry__c];
        inqBefore.Call_Bucket__c = 'Titles';
        inqBefore.Call_Type__c = 'Seller Title Status';
        inqBefore.Ops_Case__c = titleCase.Id;
        update inqBefore;
        
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        sellerAcc.Title_Specialist__c = newUser.Id;
        update sellerAcc;
    
        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        Test.StopTest();
        System.assertEquals(newUser.Id,inqAfterAdd.Assigned_To__c,'Assigned To should be updated to new value of Title Specialist');
    }

    // @isTest //changing the CSA will no longer update 48 hr notice request CIs
    // static void testAddAndUpdateCustomerSuccessAdvocate(){
    //     Account sellerAcc = TestUtility.createAccount('Seller');
    //     insert sellerAcc;
        
    //     Case titleCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
    //     titleCase.Seller_Dealership__c = sellerAcc.Id;
    //     update titleCase;
        
    //     Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c FROM Customer_Inquiry__c];
    //     inqBefore.Call_Bucket__c = 'Titles';
    //     inqBefore.Call_Type__c = '48 Hour Notice Request';
    //     inqBefore.Ops_Case__c = titleCase.Id;
    //     update inqBefore;
        
    //     User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
    //     Test.StartTest();
    //     sellerAcc.Customer_Success_Advocate__c = newUser.Id;
    //     update sellerAcc;
    //     Test.StopTest();

    //     Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
    //     System.assertEquals(newUser.Id,inqAfterAdd.Assigned_To__c,'Assigned To should be updated to new value of Customer Success Advocate');

    //     sellerAcc.Customer_Success_Advocate__c = inqBefore.Assigned_To__c;
    //     update sellerAcc;

    //     Customer_Inquiry__c inqAfterChange = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
    //     System.assertEquals(inqBefore.Assigned_To__c,inqAfterChange.Assigned_To__c,'Assigned To should be updated to new value of Customer Success Advocate');
        
    // }

    @isTest
    static void testSpecialistChangeAssignedToBuyer(){
        Test.StartTest();
            Account sellerAcc = TestUtility.createAccount('Seller');
            insert sellerAcc;
            
            Case titleCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
            titleCase.Seller_Dealership__c = sellerAcc.Id;
            titleCase.Status = 'Working';
            update titleCase;
            
            Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c, CreatedById FROM Customer_Inquiry__c];
            inqBefore.Call_Bucket__c = 'Titles';
            inqBefore.Call_Type__c = 'Seller Title Status';
            inqBefore.Ops_Case__c = titleCase.Id;
            inqBefore.Assigned_To__c = UserInfo.getUserId();
            update inqBefore;
            
            User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
            
            
            sellerAcc.Title_Specialist__c = newUser.Id;
            update sellerAcc;
        Test.StopTest();

        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        System.assertEquals(inqBefore.CreatedById, inqAfterAdd.Assigned_To__c,'Assigned To should be updated to the buyer IST Account Owner');
        
    }

    @isTest
    static void testSpecialistUpdatedRelatedArb_ciAccount(){
        Account sellerAcc = TestUtility.createAccount('Seller');
        insert sellerAcc;
        
        Case arbCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Arbitration_Claim'];
        arbCase.Seller_Dealership__c = sellerAcc.Id;
        update arbCase;
        
        Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c, CreatedById FROM Customer_Inquiry__c];
        inqBefore.Call_Bucket__c = 'Arbitration';
        inqBefore.Call_Type__c = 'Payout Dispute';
        inqBefore.Ops_Case__c = arbCase.Id;
        inqBefore.Assigned_To__c = UserInfo.getUserId();
        update inqBefore;
        
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
        Test.StartTest();
        sellerAcc.Title_Specialist__c = newUser.Id;
        update sellerAcc;
        Test.StopTest();

        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        System.assertEquals(inqBefore.CreatedById, inqAfterAdd.Assigned_To__c,'Assigned To should be updated to the IST Account Owner of the account on the CI');
        
    }

    @isTest
    static void testSpecialistUpdatedRelatedArb_opsBuyer(){
        Account sellerAcc = TestUtility.createAccount('Seller');
        insert sellerAcc;
        
        Case arbCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Arbitration_Claim'];
        arbCase.Seller_Dealership__c = sellerAcc.Id;
        update arbCase;
        
        Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c, CreatedById, Account__c FROM Customer_Inquiry__c];
        inqBefore.Call_Bucket__c = 'Arbitration';
        inqBefore.Call_Type__c = 'Payout Dispute';
        inqBefore.Ops_Case__c = arbCase.Id;
        inqBefore.Assigned_To__c = UserInfo.getUserId();
        inqBefore.Account__c = sellerAcc.Id;
        update inqBefore;
        
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
        Test.StartTest();
        sellerAcc.Title_Specialist__c = newUser.Id;
        update sellerAcc;
        Test.StopTest();

        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        System.assertEquals(inqBefore.CreatedById, inqAfterAdd.Assigned_To__c,'Assigned To should be updated to the IST Account Owner of the buyer account on the CIs ops case');
        
    }

    @isTest
    static void testSpecialistUpdatedRelatedArb_ciCreatedBy(){
        Test.StartTest();
        Account sellerAcc = TestUtility.createAccount('Seller');
        insert sellerAcc;
        
        Case arbCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Arbitration_Claim'];
        arbCase.Seller_Dealership__c = sellerAcc.Id;
        update arbCase;

        Account acc = new Account(Id = arbCase.AccountId, IST_Account_Owner__c = null);
        update acc;
        
        Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c, CreatedById, Account__c FROM Customer_Inquiry__c];
        inqBefore.Call_Bucket__c = 'Arbitration';
        inqBefore.Call_Type__c = 'Payout Dispute';
        inqBefore.Ops_Case__c = arbCase.Id;
        inqBefore.Assigned_To__c = UserInfo.getUserId();
        inqBefore.Account__c = sellerAcc.Id;
        update inqBefore;
        
        User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
        
        sellerAcc.Title_Specialist__c = newUser.Id;
        update sellerAcc;
        
        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
       
        Test.StopTest();
        System.assertEquals(inqBefore.CreatedById, inqAfterAdd.Assigned_To__c,'Assigned To should be updated to the creator of the CI');
        
    }

    @isTest
    static void testUpdateCustomerSuccessAdvocateToNull(){
        Test.StartTest();
        Account acc = [SELECT Id, Customer_Success_Advocate__c FROM Account WHERE Name = 'With Owner']; 
        acc.Customer_Success_Advocate__c = null;
        update acc;
        Test.StopTest();

        Customer_Inquiry__c inqAfterNull = [SELECT Id, Assigned_To__c, OwnerId FROM Customer_Inquiry__c WHERE Account__c = :acc.Id]; 
        System.assertEquals(inqAfterNull.OwnerId,inqAfterNull.Assigned_To__c,'Assigned To should be unchanged and stay same as Owner');
        System.assertNotEquals(null,inqAfterNull.Assigned_To__c,'Assigned To should not be changed to null');
    }

    /**
     * @see https://acvauctions.atlassian.net/browse/SI-568
     */
    @isTest
    static void testBulkAccountISTRepChangesToSupportCase() {
        String mockMetaDataString = '';
        mockMetaDataString += '{"DeveloperName": "AccountTriggerHandlerBeforeUpdate", '
            + '"NamespacePrefix": "",'
            + '"Before_Update__c": "true", '
            + '"sObject__c": "Account", "Class_Name__c": "AccountTriggerHandler"},';
        mockMetaDataString = '[' + mockMetaDataString.substringBeforeLast(',') + ']';
        TriggerFrameWork.mockMetaData = (List<TriggerHandler__mdt>) JSON.deserializeStrict(mockMetaDataString, List<TriggerHandler__mdt>.class);

        List<Account> acctList = new List<Account>();
        List<Case> caseList = new List<Case>();

        for (Integer i = 0; i < RECORD_COUNT; i ++) {
            acctList.add(TestUtility.createAccount('Test ' + i));
            acctList[i].IST_Account_Owner__c = UserInfo.getUserId();
        }
        insert acctList;
        
        for (Integer i = 0; i < RECORD_COUNT; i ++) {
            caseList.add(TestUtility.createSupportCase(acctList[i]));
        }
        insert caseList;

        User u = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        
        for (Account a : acctList) {
            a.IST_Account_Owner__c = u.Id;
        }
        // need an account that doesn't update
        acctList[RECORD_COUNT / 2].IST_Account_Owner__c = UserInfo.getUserId();
        
        Test.startTest();
            TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
            update acctList;
        Test.stopTest();

        caseList = [SELECT Id, OwnerId, Account.Name FROM Case WHERE Account.Name != 'With Owner' AND RecordType.Name = 'Support' ORDER BY Account.Name ASC];
        for (Case c : caseList) {
            if (c.Account.Name == 'Test ' + RECORD_COUNT / 2) {
                System.assertEquals(UserInfo.getUserId(), c.OwnerId);
            }
            else {
                System.assertEquals(u.Id, c.OwnerId);
            }
        }
    }

    @isTest
    static void testBulkAccountISTRepChangesToCI() {
        Integer i = 0;
        List<Account> acctList = new List<Account>();
        List<Case> supportCaseList = new List<Case>();
        List<Customer_Inquiry__c> ciList = new List<Customer_Inquiry__c>();
        for (i = 0; i < 25; i ++) {
            acctList.add(TestUtility.createAccount('Test ' + i));
            acctList[i].IST_Account_Owner__c = UserInfo.getUserId();
        }
        insert acctList;
        for (i = 0; i < 25; i ++) {
            supportCaseList.add(TestUtility.createSupportCase(acctList[i]));
        }
        insert supportCaseList;
        //insert ci's
        for (i = 0; i < 25; i ++) {
            if (i == 1 || i == 7 || i == 12) {
                ciList.add(new Customer_Inquiry__c(Account__c = acctList[i].Id, Assigned_To__c = UserInfo.getUserId(), Support_Case__c = supportCaseList[i].Id));
            }
            else {
                ciList.add(new Customer_Inquiry__c(Account__c = acctList[i].Id, Support_Case__c = supportCaseList[i].Id));
            }
        }
        insert ciList;
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
        for (Account a : acctList) {
            a.IST_Account_Owner__c = u.Id; // 0050q0000038EHJAA2
        }
        Test.startTest();    
            update acctList;
        Test.stopTest();

        ciList = [SELECT Id, OwnerId, Assigned_To__c, Support_Case__r.OwnerId FROM Customer_Inquiry__c WHERE Account__r.Name != 'With Owner'];
        for (Customer_Inquiry__c c : ciList) {
            System.assertEquals(u.Id, c.Support_Case__r.OwnerId);
            if (c.Assigned_To__c != null) {
                System.assertEquals(u.Id, c.OwnerId);
                System.assertEquals(u.Id, c.Assigned_To__c);
            }
            else {
                System.assertEquals(u.Id, c.OwnerId);
            }
        }
    }

    @isTest
    static void testUpdateBothAtTheSameTime() {
        Test.StartTest();
            User oldUser = [SELECT Id FROM User WHERE Profile.Name != 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
            Account sellerAcc = TestUtility.createAccount('Seller');
            sellerAcc.Title_Specialist__c = oldUser.Id;
            sellerAcc.Customer_Success_Advocate__c = oldUser.Id;
            insert sellerAcc;
            
            Case titleCase = [SELECT Id, AccountId, Seller_Dealership__c, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
            titleCase.Seller_Dealership__c = sellerAcc.Id;
            titleCase.Status = 'Problem';
            update titleCase;
            
            Customer_Inquiry__c inqBefore = [SELECT Id, Call_Type__c, Call_Bucket__c, Assigned_To__c, Ops_Case__c, CreatedById FROM Customer_Inquiry__c];
            inqBefore.Call_Bucket__c = 'Titles';
            inqBefore.Call_Type__c = 'Seller Title Status';
            inqBefore.Ops_Case__c = titleCase.Id;
            inqBefore.Assigned_To__c = oldUser.Id;
            update inqBefore;
            
            User newUser = [SELECT Id FROM User WHERE Profile.Name = 'Inside Sales - Account Managers Unwind' AND UserName LIKE 'testuser%@test.com'];
            
            
            sellerAcc.Title_Specialist__c = newUser.Id;
            sellerAcc.Customer_Success_Advocate__c = UserInfo.getUserId();
            update sellerAcc;
        Test.StopTest();
        Customer_Inquiry__c inqAfterAdd = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Id = :inqBefore.Id]; 
        System.assertEquals(newUser.Id, inqAfterAdd.Assigned_To__c,'Assigned To should be updated to the buyer IST Account Owner');
    }
}