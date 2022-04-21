@isTest
public class CaseCreateUtilityControllerTest {
    @TestSetup
    static void makeData() {
        Account acc = TestUtility.createAccount('Test');
        acc.BillingState = 'NY';
        insert acc;
        Contact con = TestUtility.createContact(acc);
        insert con;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c auc = TestUtility.createAuction(acc,con,v);
        insert auc;

        List<Case> caseList = new List<Case>();
        Case titleCase = TestUtility.createTitleCase(auc,acc,con);
        caseList.add(titleCase);
        Case supportCase = TestUtility.createSupportCase(acc);
        caseList.add(supportCase);
        insert caseList;

        Customer_Inquiry__c ci = TestUtility.createCustomerInquiry(caseList[1],acc);
        ci.Call_Bucket__c = 'Titles';
        ci.Call_Type__c = 'Buyer Title Status';
        ci.Status__c = 'Working';
        ci.Auction__c = auc.Id;
        ci.Call_Count__c = 1;
        insert ci;
    }

    @isTest
    static void testInitialQueryCallAccount() {
        Account a = [SELECT Id, Dealership_Id__c FROM Account];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = a.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
            String jsonString = CaseCreateUtilityController.initialQuery(a.Id);
        Test.stopTest();

        System.assertEquals(true, jsonString.contains('Account'));
        System.assertEquals('[{"title":"Test","subtitle":"' + a.Dealership_Id__c + ' • Buffalo • NY","sObjectType":"Account","id":"' + a.Id + '","icon":"standard:account"}]', jsonString);
    }

    @isTest
    static void testInitialQueryCallAuction() {
        Auction__c a = [SELECT Id FROM Auction__c];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = a.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
            String jsonString = CaseCreateUtilityController.initialQuery(a.Id);
        Test.stopTest();

        System.assertEquals(true, jsonString.contains('Auction__c'));
        System.assertEquals('"Auction__c ' + a.Id + '"', jsonString);
    }

    @isTest
    static void testInitialQueryCallCase() {
        Id titleId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        Case c = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
            String jsonString = CaseCreateUtilityController.initialQuery(c.Id);
        Test.stopTest();

        System.assertEquals(true, jsonString.contains('Case'));
        System.assertEquals(true, jsonString.contains('"Id":"' + c.Id + '","RecordTypeId":"' + titleId + '"')); //jsonstring is too long and complex to do a literal comparison
    }

    @isTest
    static void testNegativeInitialQuery() {
        Contact c = [SELECT Id FROM Contact];
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        Test.startTest();
            String jsonString = CaseCreateUtilityController.initialQuery(c.Id);
        Test.stopTest();

        System.assertEquals('', jsonString);
    }

    @isTest
    static void testFindOwnerNoIST() {
        Account a = [SELECT Id FROM Account];

        Test.startTest();
            String inquiryOwner = CaseCreateUtilityController.findOwner(a.Id);
        Test.stopTest();

        System.assertEquals('NO IST', inquiryOwner, 'When an account has no IST_Account_Owner__c, we return NO IST');
    }

    @isTest
    static void testFindOwnerWithIST() {
        Account a = [SELECT Id, IST_Account_Owner__c FROM Account];
        a.IST_Account_Owner__c = UserInfo.getUserId();
        update a;

        Test.startTest();
            String inquiryOwner = CaseCreateUtilityController.findOwner(a.Id);
        Test.stopTest();

        System.assertEquals(UserInfo.getUserId(), inquiryOwner, 'If the account has an IST_Account_Owner__c, it is returned');
    }

    @isTest
    static void testFindOwnerWithDoNotCall() {
        User doNotCall = [SELECT Id FROM User WHERE FirstName = 'Do' AND LastName = 'Not Call'];

        Account a = [SELECT Id, IST_Account_Owner__c FROM Account];
        a.IST_Account_Owner__c = doNotCall.Id;
        update a;

        Test.startTest();
            String inquiryOwner = CaseCreateUtilityController.findOwner(a.Id);
        Test.stopTest();

        System.assertEquals('NO IST', inquiryOwner, 'When an account has an IST_Account_Owner__c of DO NOT CALL, we return NO IST');
    }

    @isTest
    static void testSetOpsCase() {
        Case newTitle = [SELECT Id, Auction_Number__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        Case oldTitle = newTitle.clone();
        oldTitle.CreatedDate = System.today().addDays(-5);
        oldTitle.ACV_Titles_External_ID__c = ACVUtility.NewGuid();
        insert oldTitle;

        Test.startTest();
            String opsInfo = CaseCreateUtilityController.setOpsCase('Title_Information', newTitle.Auction_Number__c);
        Test.stopTest();

        System.assertEquals(newTitle.Id, opsInfo, 'setOpsCase should return the newest case that matches recordType and auction');
    }
    
    @isTest
    static void testSetOpsCaseNoOps() {
        Case titleCase = [SELECT Id, Auction_Number__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];

        Test.startTest();
            String opsInfo = CaseCreateUtilityController.setOpsCase('Transportation', titleCase.Auction_Number__c);
        Test.stopTest();

        System.assertEquals(null, opsInfo, 'When no matching recordType and auction exist, return null');
    }

    @isTest
    static void testCreateCaseWithOneResolvedTitleInquiry() {
        Case titleCase = [SELECT Id, Auction_Number__c, AccountId, ContactId FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];

        String jsonString = '[{"uuid":"b42e54ff-306a-434a-929d-9616ce8c16ab","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes","resolved":true,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":"' + titleCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],' +
                            '"callTypeOptions":[]}]';
        
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(titleCase.AccountId, currentUserId, titleCase.ContactId, jsonString);
        Test.stopTest();

        Case supportCase = [SELECT Id, Status, AccountId, ContactId, RecordType.DeveloperName FROM Case WHERE Id = :supportCaseId];

        System.assertEquals('Closed', supportCase.Status, '');
        System.assertEquals(titleCase.AccountId, supportCase.AccountId, '');
        System.assertEquals(titleCase.ContactId, supportCase.ContactId, '');
        System.assertEquals('Support', supportCase.RecordType.DeveloperName, '');

        Customer_Inquiry__c ci = [SELECT Id, Status__c, First_Call_Resolution__c, OwnerId, Account__c, Call_Bucket__c, Call_Type__c, Call_Count__c, Initial_Inquiry_Comment__c, Most_Recent_Inquiry_Comment__c, Ops_Case__c, Priority__c, Assigned_To__c  
                                    FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId];

        System.assertEquals('Closed', ci.Status__c, '');
        System.assertEquals(true, ci.First_Call_Resolution__c, '');
        System.assertEquals(currentUserId, ci.OwnerId, '');
        System.assertEquals(titleCase.AccountId, ci.Account__c, '');
        System.assertEquals('Titles', ci.Call_Bucket__c, '');
        System.assertEquals('Seller Title Status', ci.Call_Type__c, '');
        System.assertEquals(1, ci.Call_Count__c, '');
        System.assertEquals('notes', ci.Initial_Inquiry_Comment__c, '');
        System.assertEquals(null, ci.Most_Recent_Inquiry_Comment__c, '');
        System.assertEquals(titleCase.Id, ci.Ops_Case__c, '');
        System.assertEquals('Low', ci.Priority__c, '');
        System.assertEquals(currentUserId, ci.Assigned_To__c, '');
        
        List<Inquiry_Comment__c> commentList = [SELECT Id, Auction__c, Inquiry_Notes__c, Ops_Case__c, RecordType.DeveloperName, Support_Case__c FROM Inquiry_Comment__c WHERE Customer_Inquiry__c = :ci.Id];

        System.assertEquals(1, commentList.size(), '');
        System.assertEquals('Inquiry_Comment', commentList[0].RecordType.DeveloperName, '');
        System.assertEquals('notes', commentList[0].Inquiry_Notes__c, '');
    }
    
    @isTest
    static void testCreateCaseWithOneExistingInquiry() {
        Case titleCase = [SELECT Id, Auction_Number__c, AccountId, ContactId FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        Customer_Inquiry__c existingCI = [SELECT Id FROM Customer_Inquiry__c WHERE Call_Bucket__c = 'Titles' AND Call_Type__c = 'Buyer Title Status'];

        String jsonString = '[{"uuid":"b42e54ff-306a-434a-929d-9616ce8c16ab","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Buyer Title Status","callNotes":"notes","resolved":false,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":"' + titleCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],' +
                            '"callTypeOptions":[]}]';
        
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(titleCase.AccountId, currentUserId, titleCase.ContactId, jsonString);
        Test.stopTest();

        Case supportCase = [SELECT Id, Status, AccountId, ContactId, RecordType.DeveloperName FROM Case WHERE Id = :supportCaseId];

        System.assertEquals('Closed', supportCase.Status, 'New support case should be closed when created if no new inquiries associated'); 
        System.assertEquals(titleCase.AccountId, supportCase.AccountId, '');
        System.assertEquals(titleCase.ContactId, supportCase.ContactId, '');
        System.assertEquals('Support', supportCase.RecordType.DeveloperName, '');

        Inquiry_Comment__c junctionIC = [SELECT Id, Auction__c, Inquiry_Notes__c, Ops_Case__c, RecordType.DeveloperName, Customer_Inquiry__c, Customer_Inquiry__r.Call_Count__c FROM Inquiry_Comment__c WHERE Support_Case__c = :supportCase.Id];
        System.assertEquals(existingCI.Id, junctionIC.Customer_Inquiry__c, '');
        System.assertEquals(titleCase.Auction_Number__c, junctionIC.Auction__c, '');
        System.assertEquals(2, junctionIC.Customer_Inquiry__r.Call_Count__c, '');
        
        Inquiry_Comment__c notesIC = [SELECT Id, Inquiry_Notes__c FROM Inquiry_Comment__c WHERE Customer_Inquiry__c = :junctionIC.Customer_Inquiry__c AND RecordType.DeveloperName = 'Inquiry_Comment'];
        System.assertEquals('notes', notesIC.Inquiry_Notes__c, '');
    }

    @isTest
    static void testCreateCaseWithMultipleNewInquiries() {
        User advocate = TestUtility.createUser();
        insert advocate;

        Case titleCase = [SELECT Id, Auction_Number__c, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        titleCase.Seller_Dealership__c = titleCase.AccountId;
        update titleCase;

        Account acc = [SELECT Id, Customer_Success_Advocate__c FROM Account WHERE Id = :titleCase.AccountId];
        acc.Customer_Success_Advocate__c = advocate.Id;
        update acc;

        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":"' + titleCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]},' +
                            '{"uuid":"9df61cfe-edd9-4cb5-bb13-1fa5c2a3ba6f","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Sales","callType":"Dealmaker","callNotes":"","resolved":true,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":null,"callBucketLabel":"Sales","callBucketOptions":[],"callTypeOptions":[]}]';
        
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(titleCase.AccountId, currentUserId, '', jsonString);
        Test.stopTest();

        Case supportCase = [SELECT Id, Status, AccountId, ContactId, RecordType.DeveloperName FROM Case WHERE Id = :supportCaseId];

        System.assertEquals('Working', supportCase.Status, '');
        System.assertEquals(titleCase.AccountId, supportCase.AccountId, '');
        System.assertEquals(null, supportCase.ContactId, '');
        System.assertEquals('Support', supportCase.RecordType.DeveloperName, '');

        List<Customer_Inquiry__c> inquiries = [SELECT Id, Status__c, OwnerId, Account__c, Call_Bucket__c, Call_Type__c, Call_Count__c, Initial_Inquiry_Comment__c, Most_Recent_Inquiry_Comment__c, Ops_Case__c, Priority__c, Assigned_To__c  
                                    FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId];
        for (Customer_Inquiry__c ci : inquiries) {
            if (ci.Call_Bucket__c == 'Sales') {
                System.assertEquals('Closed', ci.Status__c, '');
                System.assertEquals(titleCase.AccountId, ci.Account__c, '');
                System.assertEquals('Dealmaker', ci.Call_Type__c, '');
                System.assertEquals(null, ci.Initial_Inquiry_Comment__c, '');
                System.assertEquals(null, ci.Ops_Case__c, '');
                System.assertEquals(currentUserId, ci.Assigned_To__c, '');
            }
            else {
                System.assertEquals('Titles', ci.Call_Bucket__c, '');
                System.assertEquals('New', ci.Status__c, '');
                System.assertEquals(titleCase.AccountId, ci.Account__c, '');
                System.assertEquals('Seller Title Status', ci.Call_Type__c, '');
                System.assertEquals('notes1', ci.Initial_Inquiry_Comment__c, '');
                System.assertEquals(titleCase.Id, ci.Ops_Case__c, '');
                System.assertEquals(currentUserId, ci.Assigned_To__c, '');
            }
            System.assertEquals(currentUserId, ci.OwnerId, '');
            System.assertEquals(1, ci.Call_Count__c, '');
            System.assertEquals(null, ci.Most_Recent_Inquiry_Comment__c, '');
            System.assertEquals('Low', ci.Priority__c, '');
        }
    }

    @isTest
    static void testAssignedToForReturnToSeller() {
        User specialist = TestUtility.createUser();
        insert specialist;

        Case titleCase = [SELECT Id, Auction_Number__c, AccountId, Status FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        titleCase.Seller_Dealership__c = titleCase.AccountId;
        titleCase.Status = 'Return to Seller';
        update titleCase;

        Account acc = [SELECT Id, Title_Specialist__c FROM Account WHERE Id = :titleCase.AccountId];
        acc.Title_Specialist__c = specialist.Id;
        update acc;

        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":"' + titleCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';
        
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(titleCase.AccountId, currentUserId, '', jsonString);
        Test.stopTest();

        System.assertEquals(specialist.Id, [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId].Assigned_To__c);
    }

    @isTest
    static void testThreeExistingCIsWithDifferingPrioritiesAndAssignedTo() {
        Case titleCase = [SELECT Id, Auction_Number__c, AccountId FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        titleCase.Seller_Dealership__c = titleCase.AccountId;
        update titleCase;
        Account a = new Account(Id = titleCase.AccountId);
        update a;
        Case sc = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Support'];
        List<Customer_Inquiry__c> cis = new List<Customer_Inquiry__c>();
        Customer_Inquiry__c ci1 = TestUtility.createCustomerInquiry(sc, a);
        ci1.Call_Bucket__c = 'Sales';
        ci1.Call_Type__c = 'Dealmaker';
        ci1.Status__c = 'Working';
        ci1.Auction__c = titleCase.Auction_Number__c;
        ci1.Call_Count__c = 4;
        cis.add(ci1);
        Customer_Inquiry__c ci2 = TestUtility.createCustomerInquiry(sc, a);
        ci2.Call_Bucket__c = 'Helpdesk';
        ci2.Call_Type__c = 'Ghost Bid';
        ci2.Status__c = 'Closed';
        ci2.Auction__c = titleCase.Auction_Number__c;
        ci2.Call_Count__c = 2;
        ci2.First_Call_Resolution__c = true;
        cis.add(ci2);
        insert cis;

        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Buyer Title Status","callNotes":"notes1","resolved":true,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":"' + titleCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]},' +
                            '{"uuid":"9df61cfe-edd9-4cb5-bb13-1fa5c2a3ba6f","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Sales","callType":"Dealmaker","callNotes":"","resolved":false,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":null,"callBucketLabel":"Sales","callBucketOptions":[],"callTypeOptions":[]},' + 
                            '{"uuid":"9df61cfe-edd9-4cb5-bb13-1fa5c2a3ba6c","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Helpdesk","callType":"Ghost Bid","callNotes":"","resolved":false,' +
                            '"relatedAccount":"' + titleCase.AccountId + '","relatedOpsCase":null,"callBucketLabel":"Helpdesk","callBucketOptions":[],"callTypeOptions":[]}]';
        
        Id currentUserId = UserInfo.getUserId();

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(titleCase.AccountId, currentUserId, '', jsonString);
        Test.stopTest();

        for(Customer_Inquiry__c c : [SELECT Id, Status__c, Priority__c, Call_Count__c, Call_Bucket__c, First_Call_Resolution__c FROM Customer_Inquiry__c]) {
            if (c.Call_Bucket__c == 'Sales') {
                System.assertEquals('High', c.Priority__c);
                System.assertEquals(5, c.Call_Count__c);
            }
            else if (c.Call_Bucket__c == 'Titles') {
                System.assertEquals('Closed', c.Status__c);
                System.assertEquals(2, c.Call_Count__c);
            }
            else if (c.Call_Bucket__c == 'Helpdesk') {
                System.assertEquals('New', c.Status__c);
                System.assertEquals(false, c.First_Call_Resolution__c);
                System.assertEquals(3, c.Call_Count__c);
                System.assertEquals('High', c.Priority__c);
            }
        }
        
        sc = [SELECT Id, Status, Priority FROM Case WHERE RecordType.DeveloperName = 'Support' AND Id != :supportCaseId]; //or should we check both of them?
        System.assertEquals('Working', sc.Status);
        System.assertEquals('High', sc.Priority);
    }

    @isTest
    static void testCheckTitle() {
        Case c = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        CaseCreateUtilityController.TitleWrapper result = CaseCreateUtilityController.checkTitle(c.Id); //, 'Seller Title Status'

        System.assertEquals('Received', result.status);
    }

    @isTest
    static void testCheckTitle48HourSubmitValidation1() {
        Case c = [SELECT Id, CaseNumber, Auction_Number__c, AccountId, Status, Auction_Number__r.Name FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        c.Seller_Dealership__c = c.AccountId;
        update c;

        Auction__c auc = new Auction__c(Id = c.Auction_Number__c, Blue_Light__c = true);
        update auc;

        Test.startTest();
        CaseCreateUtilityController.TitleWrapper result = CaseCreateUtilityController.checkTitle(c.Id); //, '48 Hour Notice Request'
        Test.stopTest();

        //System.assertEquals('allowedCaseNumber:'+ c.CaseNumber, status);
        System.assertEquals('Received', result.Status);
        System.assertEquals(c.Auction_Number__r.Name, result.AuctionNumber);
        System.assertEquals(false, result.FortyEightHrEligible);
    }

    @isTest
    static void testCheckTitle48HourSubmitValidation2() {
        Test.startTest();
        Case c = [SELECT Id, CaseNumber, Auction_Number__c, AccountId, Status, Auction_Number__r.Name FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        c.Seller_Dealership__c = c.AccountId;
        c.Title_Sent_Date__c = System.today().addDays(-5);
        c.Status = 'Problem';
        update c;
        
        Auction__c auc = new Auction__c(Id = c.Auction_Number__c, Blue_Light__c = true);
        update auc;
        
        Account acc = new Account(Id = c.AccountId, BillingState = 'CA');
        update acc;

        CaseCreateUtilityController.TitleWrapper result = CaseCreateUtilityController.checkTitle(c.Id); //, '48 Hour Notice Request'
        Test.stopTest();

        //System.assertEquals('allowedCaseNumber:'+ c.CaseNumber, status);
        System.assertEquals('Problem', result.Status);
        System.assertEquals(c.Auction_Number__r.Name, result.AuctionNumber);
        System.assertEquals(false, result.FortyEightHrEligible);
    }

    @isTest
    static void testCheckTitle48HourSubmitValidation3() {
        Case c = [SELECT Id, CaseNumber, Auction_Number__c, AccountId, Status, Auction_Number__r.Name FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        c.Seller_Dealership__c = c.AccountId;
        c.Status = 'Problem';
        update c;

        Auction__c auc = new Auction__c(Id = c.Auction_Number__c, Blue_Light__c = false, Payment_Status__c = 'hold_on_file');
        update auc;

        Account acc = new Account(Id = c.AccountId, Ta_hold_buyer__c = false);
        update acc;

        Test.startTest();
        CaseCreateUtilityController.TitleWrapper result = CaseCreateUtilityController.checkTitle(c.Id); //, '48 Hour Notice Request'
        Test.stopTest();

        //System.assertEquals('allowedCaseNumber:'+ c.CaseNumber, status);
        System.assertEquals('Problem', result.Status);
        System.assertEquals(c.Auction_Number__r.Name, result.AuctionNumber);
        System.assertEquals(false, result.FortyEightHrEligible);
    }

    @isTest
    static void testGetContactsAffiliated() {
        Account a = [SELECT Id, Dealership_Id__c, Name FROM Account];
        Contact c = [SELECT Id, Email, Name, Phone FROM Contact];
        Affiliation__c aff = TestUtility.createAffiliation(a,c);
        aff.Active__c = true;
        insert aff;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        List<String> selectedIds = new List<String>();
        selectedIds.add(a.Id);
        Test.startTest();
            String jsonString = JSON.serialize(CaseCreateUtilityController.getContacts('test', selectedIds));
        Test.stopTest();

        System.assertEquals(true, jsonString.contains('Contact'));
        System.assertEquals('[{"title":"' + c.Name + '","subtitle":"' + a.Name + ' • ' + a.Dealership_Id__c + ' • ' + c.Email + ' • ' + c.Phone + '","sObjectType":"Contact","id":"' + c.Id + '","icon":"standard:contact"}]', jsonString);
    }

    @isTest
    static void testGetContactsNotAffiliated() {
        Account a = [SELECT Id, Dealership_Id__c, Name FROM Account];
        Contact c = TestUtility.createDealerContact(a);
        insert c;

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = c.Id;
        Test.setFixedSearchResults(fixedSearchResults);

        List<String> selectedIds = new List<String>();
        selectedIds.add(a.Id);
        Test.startTest();
            String jsonString = JSON.serialize(CaseCreateUtilityController.getContacts('test', selectedIds));
        Test.stopTest();

        c = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id = :c.Id];

        System.assertEquals(true, jsonString.contains('Contact'));
        System.assertEquals('[{"title":"' + c.Name + '","subtitle":"' + a.Name + ' • ' + a.Dealership_Id__c + ' • ' + c.Email + ' • ' + c.Phone + '","sObjectType":"Contact","id":"' + c.Id + '","icon":"standard:contact"}]', jsonString);
    }

    @isTest
    static void testAssignedToWithTwoTitles() {
        Case newCase = [SELECT Id, AccountId, Seller_Dealership__c, CreatedDate, Auction_Number__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        Case oldCase = newCase.clone();
        oldCase.ACV_Titles_External_Id__c = ACVUtility.NewGuid();
        oldCase.CreatedDate = System.Today().addDays(-5);
        insert oldCase;

        newCase.Seller_Dealership__c = newCase.AccountId;
        update newCase;
        //need two titles for one auction
        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + newCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + newCase.AccountId + '","relatedOpsCase":"' + newCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(newCase.AccountId, UserInfo.getUserId(), '', jsonString);
        Test.stopTest();

        Customer_Inquiry__c ci = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId];
        System.assertEquals(UserInfo.getUserId(), ci.Assigned_To__c);
    }

    @isTest
    static void testAssignedToNullSellerStatusSet2() {
        User advocate = TestUtility.createUser();
        insert advocate;
        User accountRep = TestUtility.createUser();
        insert accountRep;
        Account acc = TestUtility.createAccount('Test 2');
        acc.Customer_Success_Advocate__c = advocate.Id;
        acc.IST_Account_Owner__c = accountRep.Id;
        insert acc;
        Case newCase = [SELECT Id, AccountId, Auction_Number__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        newCase.AccountId = acc.Id;
        update newCase;
        //need two titles for one auction
        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + newCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + newCase.AccountId + '","relatedOpsCase":"' + newCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';
        String jsonString2 = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed83c1f1","auctionId":"' + newCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"48 Hour Notice Request","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + acc.Id + '","relatedOpsCase":"' + newCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(newCase.AccountId, UserInfo.getUserId(), '', jsonString);
            Id supportCaseId2 = CaseCreateUtilityController.logAnInteraction(acc.Id, UserInfo.getUserId(), '', jsonString2);
        Test.stopTest();

        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c, Call_Type__c FROM Customer_Inquiry__c WHERE (Support_Case__c = :supportCaseId OR Support_Case__c = :supportCaseId2)]) {
            if (c.Call_Type__c == '48 Hour Notice Request') {
                System.assertEquals(null, c.Assigned_To__c); //advocate.Id //queue48Hr[0].Id
            }
            else {
                System.assertEquals(accountRep.Id, c.Assigned_To__c);
            }
        }
    }

    @isTest
    static void testAssignedToNullSellerStatusSet1SellerPopulated() {
        Test.startTest();
            User specialist = TestUtility.createUser();
            insert specialist;
            Account acc = TestUtility.createAccount('Test 2');
            acc.Title_Specialist__c = specialist.Id;
            insert acc;
            Auction__c auc = [SELECT Id FROM Auction__c];
            Auction__c newAuc = auc.clone();
            insert newAuc;
            Case newCase = [SELECT Id, AccountId, Auction_Number__c, Status, Seller_Dealership__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
            newCase.Status = 'Problem';
            newCase.Seller_Dealership__c = newCase.AccountId;
            update newCase;
            Case newCase2 = newCase.clone();
            newCase2.ACV_Titles_External_Id__c = ACVUtility.NewGuid();
            newCase2.Seller_Dealership__c = acc.Id;
            newCase2.Status = 'Closed Unwound';
            newCase2.Auction_Number__c = newAuc.Id;
            insert newCase2;
            
            String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + newCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes1","resolved":false,' +
                                '"relatedAccount":"' + newCase.AccountId + '","relatedOpsCase":"' + newCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';
            String jsonString2 = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed83c1f1","auctionId":"' + newCase2.Auction_Number__c + '","callBucket":"Title_Information","callType":"Buyer Title Status","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + newCase2.AccountId + '","relatedOpsCase":"' + newCase2.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';


            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(newCase.AccountId, UserInfo.getUserId(), '', jsonString);
            Id supportCaseId2 = CaseCreateUtilityController.logAnInteraction(acc.Id, UserInfo.getUserId(), '', jsonString2);
        Test.stopTest();

        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c, Should_Assign_To__c, Call_Type__c FROM Customer_Inquiry__c WHERE (Support_Case__c = :supportCaseId OR Support_Case__c = :supportCaseId2)]) {
            if (c.Call_Type__c == 'Buyer Title Status') {
                System.assertEquals(specialist.Id, c.Assigned_To__c);
            }
            else {
                System.assertEquals(null, c.Assigned_To__c);
                System.assertEquals('Specialist', c.Should_Assign_To__c);
            }
        }
    }

    @isTest
    static void testAssignedToNullSellerStatusSet1SellerNotPopulated() {
        User advocate = TestUtility.createUser();
        insert advocate;
        Account acc = TestUtility.createAccount('Test 2');
        acc.Customer_Success_Advocate__c = advocate.Id;
        insert acc;
        Case newCase = [SELECT Id, AccountId, Auction_Number__c, Status, Seller_Dealership__c FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];
        newCase.Status = 'Working';
        update newCase;
        
        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + newCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Buyer Reported Problem","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + newCase.AccountId + '","relatedOpsCase":"' + newCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';
        String jsonString2 = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed83c1f1","auctionId":"' + newCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Buyer Title Status","callNotes":"notes1","resolved":false,' +
                            '"relatedAccount":"' + acc.Id + '","relatedOpsCase":"' + newCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(newCase.AccountId, UserInfo.getUserId(), '', jsonString);
            Id supportCaseId2 = CaseCreateUtilityController.logAnInteraction(acc.Id, UserInfo.getUserId(), '', jsonString2);
        Test.stopTest();

        for (Customer_Inquiry__c c : [SELECT Id, Assigned_To__c, Call_Type__c, Should_Assign_To__c FROM Customer_Inquiry__c WHERE (Support_Case__c = :supportCaseId OR Support_Case__c = :supportCaseId2)]) {
            if (c.Call_Type__c == 'Buyer Title Status') {
                System.assertEquals(advocate.Id, c.Assigned_To__c);
            }
            else {
                System.assertEquals(null, c.Assigned_To__c);
                System.assertEquals('Specialist', c.Should_Assign_To__c);
            }
        }
    }

    @isTest
    static void testFullHappyPathLogInteraction() {
        Id currentUserId = UserInfo.getUserId();
        Case titleCase = [SELECT Id, Auction_Number__c, AccountId, Account.Name FROM Case WHERE RecordType.DeveloperName = 'Title_Information'];

        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = titleCase.AccountId;
        Test.setFixedSearchResults(fixedSearchResults);
        
        Test.startTest();
            String initialQueryResult = CaseCreateUtilityController.initialQuery(titleCase.Id);
            List<LookupSearchResult> accounts = CaseCreateUtilityController.getAccounts(titleCase.Account.Name);
            String accId = JSON.serialize(accounts).substringBetween('id":"','"');
            System.assertEquals(titleCase.AccountId, accId);

            String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"' + titleCase.Auction_Number__c + '","callBucket":"Title_Information","callType":"Seller Title Status","callNotes":"notes1","resolved":false,' +
            '"relatedAccount":"' + accId + '","relatedOpsCase":"' + titleCase.Id + '","callBucketLabel":"Titles","callBucketOptions":[],"callTypeOptions":[]}]';

            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(accId, currentUserId, '', jsonString);
        Test.stopTest();

        for (Customer_Inquiry__c ci : [SELECT Id, First_Call_Resolution__c, Status__c, OwnerId, Account__c, Call_Bucket__c, Call_Type__c, Call_Count__c, Initial_Inquiry_Comment__c, Most_Recent_Inquiry_Comment__c, Ops_Case__c, Priority__c, Assigned_To__c FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId]) {
            System.assertEquals('New', ci.Status__c);
            System.assertEquals(false, ci.First_Call_Resolution__c);
            System.assertEquals(currentUserId, ci.OwnerId);
            System.assertEquals(accId, ci.Account__c);
            System.assertEquals('Titles', ci.Call_Bucket__c);
            System.assertEquals('Seller Title Status', ci.Call_Type__c);
            System.assertEquals(1, ci.Call_Count__c);
            System.assertEquals('notes1', ci.Initial_Inquiry_Comment__c);
            System.assertEquals(null, ci.Most_Recent_Inquiry_Comment__c);
            System.assertEquals(titleCase.Id, ci.Ops_Case__c);
            System.assertEquals('Low', ci.Priority__c);
            System.assertEquals(currentUserId, ci.Assigned_To__c);
        }
    }

    @isTest
    static void testCheckAffiliationCreateAccessTitleUser(){ 
        String uniqueUserName = 'user' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Title Manager'];
        User titleUser = TestUtility.createUser(p.Id);
        Boolean hasAccess;

        Test.startTest();
        System.runAs(titleUser){
            hasAccess = CaseCreateUtilityController.checkAffiliationCreateAccess();
        }
        Test.stopTest();

        System.assertEquals(false,hasAccess, 'Titles users do not have access to create affiliations');
    }

    @isTest
    static void testCheckAffiliationCreateAccessAdmin(){ 
        Test.startTest();
            Boolean hasAccess = CaseCreateUtilityController.checkAffiliationCreateAccess();
        Test.stopTest();

        System.assertEquals(true,hasAccess, 'System Admin should have access to create affiliations');
    }

    @isTest
    static void testInquiryCreationWithoutAuction() {
        Account a = [SELECT Id FROM Account];

        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"","callBucket":"Sales","callType":"Other","callNotes":"notes1","resolved":true,' +
                            '"relatedAccount":"' + a.Id + '","relatedOpsCase":null,"callBucketLabel":"Sales","callBucketOptions":[],"callTypeOptions":[]}]';

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(a.Id, UserInfo.getUserId(), '', jsonString);
        Test.stopTest();

        Customer_Inquiry__c ci = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId];
        System.assertEquals(UserInfo.getUserId(), ci.Assigned_To__c, 'If the related account does not have a IST Account Owner, the creating user should become the assigned To');
    }

    @isTest
    static void testInquiryCreationWithoutAuctionWithAccountRep() {
        //test in question
        User accountRep = TestUtility.createSystemAdministratorUser();
        insert accountRep;

        Account a = [SELECT Id, IST_Account_Owner__c FROM Account];
        a.IST_Account_Owner__c = accountRep.Id;
        update a;

        String jsonString = '[{"uuid":"d7ea313d-eda8-435f-a97c-6397ed81c1f0","auctionId":"","callBucket":"Sales","callType":"Other","callNotes":"notes1","resolved":true,' +
                            '"relatedAccount":"' + a.Id + '","relatedOpsCase":null,"callBucketLabel":"Sales","callBucketOptions":[],"callTypeOptions":[]}]';

        Test.startTest();
            Id supportCaseId = CaseCreateUtilityController.logAnInteraction(a.Id, UserInfo.getUserId(), '', jsonString);
        Test.stopTest();

        Customer_Inquiry__c ci = [SELECT Id, Assigned_To__c FROM Customer_Inquiry__c WHERE Support_Case__c = :supportCaseId];
        System.assertEquals(accountRep.Id, ci.Assigned_To__c, 'IST Account Owner of related account should become assigned to');
    }

    @isTest
    static void testCheckPermissions() {
        Boolean testBool = CaseCreateUtilityController.checkPermissions();
        System.assertEquals(true, testBool); //tests are run by system admin users and the method gets running user info
        User tm = [SELECT Id FROM User WHERE Profile.Name = 'Territory Manager' AND IsActive = true LIMIT 1];
        System.runAs(tm) {
            Boolean testBool2 = CaseCreateUtilityController.checkPermissions();
            System.assertEquals(false, testBool2);
        }
    }
}