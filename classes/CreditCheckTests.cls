@isTest
public class CreditCheckTests {

    @TestSetup
    static void makeData(){
        //add to another method. call method
        Group grp = new Group();
        grp.name = 'Credit Test Budget';
        grp.Type = 'Regular'; 
        insert grp; 
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = UserInfo.getUserId();
        grpMem1.GroupId = grp.Id;
        insert grpMem1;
    }

    static void makeData2(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId(),Organization_Credit_Id__c='1234', legal_name__c='seller', Dealer_Type__c='1',Dealership_ID__c = '1'));
        accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId(),Organization_Credit_Id__c='5678', legal_name__c='seller', Dealer_Type__c='1',Dealership_ID__c = '2'));
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
        Budget__c newBudget = new Budget__c(Name='Test Budget',Starting_Balance__c=1000);
        insert newBudget;        
        String officialRecordId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get('Credit').getRecordTypeId();
        Credits_Checks__c newCredit = new Credits_Checks__c(Name='a07m000000DRW4f', OwnerId=UserInfo.getUserId(), Dealer__c=accountList[0].id, Payment_Type__c='ACV Credit Assigned', Amount_Requested__c = 600, RecordTypeId=officialRecordId, Explanation__c='Data Explanation', Budget_Name__c=newBudget.Id);
        insert newCredit;
    }
 
    // Verifies getObjectInfo returns the correct string if input is correct
    @isTest 
    static void controllerReturn(){
        makeData2();
        Test.startTest();
        List<Auction__c> recordInfo = [SELECT buyer_dealership__c, Seller_Dealership__c, Id FROM Auction__c LIMIT 1];
        Budget__c bud = [SELECT Id FROM Budget__c LIMIT 1];
        Salesforce_Setting__mdt defaultExpirationDateExtension = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Credit_Expiration_Day' LIMIT 1 ];
        String expected = '{"showSlamDunkCheckbox":true,"objectName":"Auction__c","expirationDate":"' + String.valueOf(Date.Today().addDays(Integer.valueOf(defaultExpirationDateExtension.Value__c))) + '","budgetList":[{"budgetName":"Test Budget","budgetId":"'+ bud.Id +'"}],"budgetInfo":null,"auctionInfo":{"sellerDealer":{"territoryManagerName":"' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '","territoryManagerEmail":"' + UserInfo.getUserEmail() + '","name":"seller","key":"' + recordInfo[0].Seller_Dealership__c + '"},"buyerDealer":{"territoryManagerName":"' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + '","territoryManagerEmail":"' + UserInfo.getUserEmail() + '","name":"buyer","key":"' + recordInfo[0].buyer_dealership__c + '"}}}';
        String actual = CreditCheckController.getObjectInfo(recordInfo[0].Id);
        Test.stopTest();
        System.assertEquals(expected, actual);
    }

    // Tests if credit is created by correct input
    @isTest 
    static void createCreditTest(){
        makeData2();
        List<Credits_Checks__c> startingCredits = [SELECT Name, Id FROM Credits_Checks__c];
        Test.startTest();
        String budgetId = [SELECT Id FROM Budget__c].Id;
        List<Auction__c> recordInfo = [SELECT buyer_dealership__c, Seller_Dealership__c, Id FROM Auction__c LIMIT 1]; 
        String inputObject = '{"slamDunk":false,"currentObjectType":"Auction__c","expirationDate":"2020-04-04","selectedDealer":"' + recordInfo[0].buyer_dealership__c + '","otherDealer":"' + recordInfo[0].Seller_Dealership__c + '","resolution":"ACV Credit Assigned","enteredAmount":"600","selectedBudget":"'+ budgetId +'","selectedRecord":"Credit","secondaryRecord":"","creditReason":"Goodwill","selectedRootCause":"Component Not Covered","enteredExplanation":"Test Explanation","caseId":"","currentId":"' + recordInfo[0].Id + '","goodwill":"","budget":""}';
        CreditCheckController.createCreditRecord(inputObject);
        Decimal expected = 2;
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c];
        Test.stopTest();          
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);
    }
    @isTest
    static void createCreditFromAccountTest(){
        makeData2();
        List<Credits_Checks__c> startingCredits = [SELECT Name, Id FROM Credits_Checks__c];
        Test.startTest();
        String budgetId = [SELECT Id FROM Budget__c].Id;
        List<Account> accountInfo = [SELECT Id, Name FROM Account LIMIT 1]; 
        String inputObject = '{"slamDunk":false,"currentObjectType":"Account","expirationDate":"2020-04-04","selectedDealer":"' + accountInfo[0].Id + '","otherDealer":"","resolution":"ACV Credit Assigned","enteredAmount":"600","selectedBudget":"'+ budgetId +'","selectedRecord":"Credit","secondaryRecord":"","creditReason":"Promotion","selectedRootCause":"Promotion","enteredExplanation":"Test Explanation","caseId":"","currentId":"' + accountInfo[0].Id + '","goodwill":"","budget":""}';
        CreditCheckController.createCreditRecord(inputObject);
        Decimal expected = 2;
        List<Credits_Checks__c> creditList = [SELECT Id, Auction__c, Case__c, Dealer__c FROM Credits_Checks__c];
        Test.stopTest();          
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);
        System.assertEquals( creditList[0].Dealer__c, accountInfo[0].Id, 'The Incorrect dealer was connected' );
        System.assert( String.isBlank(creditList[0].Auction__c), 'Should be linked to no Auciton' );
        System.assert( String.isBlank(creditList[0].Case__c), 'Should be linked to no Case' );
    }
    // Tests if check is created by correct input
    @isTest 
    static void createCheckTest(){
        makeData2();
        List<Credits_Checks__c> startingCredits = [SELECT Name, Id FROM Credits_Checks__c];
        Test.startTest();
        String budgetId = [SELECT Id FROM Budget__c].Id;
        List<Auction__c> recordInfo = [SELECT buyer_dealership__c, Seller_Dealership__c, Id FROM Auction__c LIMIT 1]; 
        String inputObject = '{"slamDunk":false,"currentObjectType":"Auction__c","selectedDealer":"' + recordInfo[0].buyer_dealership__c + '","otherDealer":"' + recordInfo[0].Seller_Dealership__c + '","resolution":"ACV Issue Check","enteredAmount":"600","selectedBudget":"'+ budgetId +'","selectedRecord":"Credit","secondaryRecord":"","creditReason":"Goodwill","selectedRootCause":"Component Not Covered","enteredExplanation":"Test Explanation","caseId":"","currentId":"' + recordInfo[0].Id + '","goodwill":"","budget":""}';
        CreditCheckController.createCreditRecord(inputObject);
        Decimal expected = 2;
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c];
        Test.stopTest();          
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);
    }

    // Tests if Budget automatically updates Current Balance when created
    @isTest 
    static void createBudget(){
        makeData2();
        Test.startTest();
        Budget__c setupBudget = [SELECT Name, Id, Starting_Balance__c, Current_Balance__c FROM Budget__c];
        Decimal expected = setupBudget.Starting_Balance__c;
        Decimal actual = setupBudget.Current_Balance__c;
        Test.stopTest();
        System.assertEquals(expected, actual);
    }

    // Tests if Budget automatically updates Current Balance when Adjusted Budget Balance is added
    @isTest 
    static void updateBudget(){
        makeData2();
        Test.startTest();
        Budget__c setupBudget = [SELECT Name, Id, Starting_Balance__c, Current_Balance__c, Adjusted_Budget_Balance__c FROM Budget__c];
        setupBudget.Adjusted_Budget_Balance__c = 2000;
        update setupBudget;
        Test.stopTest();
        Budget__c setupBudgetUpdated = [SELECT Name, Id, Starting_Balance__c, Current_Balance__c, Adjusted_Budget_Balance__c FROM Budget__c];
        Decimal expected = setupBudgetUpdated.Adjusted_Budget_Balance__c;
        Decimal actual = setupBudgetUpdated.Current_Balance__c;
        System.assertEquals(expected, actual);
    }

    // Tests if credit is Adjustment Credit is created in Sf: Amount 600
    @isTest 
    static void positiveAdjustment(){
        makeData2();
        Test.startTest();
        List<Credits_Checks__c> startingCredits = [SELECT Name, Id FROM Credits_Checks__c];
        String budgetId = [SELECT Id FROM Budget__c].Id;
        Id recordId = [SELECT Id FROM Credits_Checks__c].Id;
        String inputObject = '{"currentObjectType":"Credits_Checks__c","selectedDealer":"","otherDealer":"","resolution":"ACV Credit Assigned","enteredAmount":"600","selectedBudget":"","selectedRecord":"Credit","secondaryRecord":"","creditReason":"","selectedRootCause":"","enteredExplanation":"Test Explanation","caseId":"","currentId":"' + recordId + '","goodwill":"","budget":""}';
        CreditCheckController.createCreditRecord(inputObject);
        Test.stopTest();
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c];
        Decimal expected = 2;
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);
    }

    // Tests if credit is Adjustment Debit is created in Sf: Amount 600
    @isTest 
    static void debitAdjustment(){
        makeData2();
        Test.startTest();
        List<Credits_Checks__c> startingCredits = [SELECT Name, Id FROM Credits_Checks__c];
        String budgetId = [SELECT Id FROM Budget__c].Id;
        Id recordId = [SELECT Id FROM Credits_Checks__c].Id;
        String inputObject = '{"currentObjectType":"Credits_Checks__c","selectedDealer":"","otherDealer":"","resolution":"ACV Credit Deduction","enteredAmount":"600","selectedBudget":"","selectedRecord":"Credit","secondaryRecord":"","creditReason":"","selectedRootCause":"","enteredExplanation":"Test Explanation","caseId":"","currentId":"' + recordId + '","goodwill":"","budget":""}';
        CreditCheckController.createCreditRecord(inputObject);
        Test.stopTest();
        List<Credits_Checks__c> creditList = [SELECT Id FROM Credits_Checks__c];
        Decimal expected = 2;
        Decimal actual = creditList.size();
        System.assertEquals(expected, actual);
    }
    
    @isTest 
    static void addCredit(){
        makeData2();
        Credits_Checks__c setupCred = [SELECT Id, Amount_Requested__c, Amount_Approved__c, Approval_Status__c,ACV_User_Id__c,Dealership_ID__c FROM Credits_Checks__c];
        TestingUtility.SingleRequestMock loginRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock creditRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2, "data": {"errors": [],"successes": [{"expires_after":60,"amount": 600,"applicable_to": "buyer_fees","authorized_by": 34233,"cause_auction": null,"cause_notes": "","cause_type": 2,"expiration": "2020-05-21 00:00:00","expired": false,"id": 29,"remaining_amount":600,"salesforce_id": "'+setupCred.id+'","timestamp": "2020-03-21 00:59:18"}]}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:ACVAuth2',loginRes);
        multiCall.put('callout:CreditAPI/bulk_create',creditRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Salesforce_Setting__mdt defaultExpirationDateExtension = [ SELECT Id, Value__c FROM Salesforce_Setting__mdt WHERE DeveloperName = 'Default_Credit_Expiration_Day' LIMIT 1 ];
        Test.startTest();
        setupCred.Amount_Approved__c = setupCred.Amount_Requested__c;
        setupCred.Approval_Status__c = 'Approved';
        setupCred.ACV_User_Id__c = '34233';
        setupCred.Dealership_ID__c = '1234';
        setupCred.Expiration_Date__c = Date.Today().addDays(Integer.valueOf(defaultExpirationDateExtension.Value__c));
        update setupCred;
        Test.stopTest();
        String expected = 'Done Successful';
        String actual = [SELECT Approval_Status__c FROM Credits_Checks__c].Approval_Status__c;
        System.assertEquals(expected, actual);
    }

    @isTest 
    static void addDebit(){
        makeData2();
        Credits_Checks__c setupCred = [SELECT Id, Amount_Requested__c, Amount_Approved__c, Approval_Status__c,ACV_User_Id__c,Dealership_ID__c, Adjustment__c,Payment_Type__c FROM Credits_Checks__c];
        TestingUtility.SingleRequestMock loginRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"user_id": 34233,"session_token": "a41a7c86-7b30-4305-a13d-b54c65a17a0a","code": "200"}}',null);
        TestingUtility.SingleRequestMock accountRes = new TestingUtility.SingleRequestMock(200, 'OK','{"api_version": 2,"data": {"_links": {"transactions": {"href": "/v2/credits/organizationcreditaccounts/17/transactions","methods": ["GET"]}},"accountTotal": 1000,"created": "2020-03-21 00:59:18","id": 1234,"owner": 998,"totalTransactions": 0,"updated": "2020-03-21 00:59:18"}}',null);
        TestingUtility.SingleRequestMock adjustRes = new TestingUtility.SingleRequestMock(200,'OK','{"api_version": 2,"data": {"adjustments": [{"account_id": 13,"amount": 100,"id": 28}]}}',null);
        Map<String,HttpCalloutMock> multiCall = new Map<String,HttpCalloutMock>();
        multiCall.put('callout:ACVAuth2',loginRes);
        multiCall.put('callout:CreditAPI/organizationcreditaccounts/1234',accountRes);
        multiCall.put('callout:CreditAPI/organizationcreditaccounts/1234/make_adjustment',adjustRes);
        Test.setMock(HttpCalloutMock.class, new TestingUtility.MultiRequestMock(multiCall));
        Test.startTest();
        setupCred.Payment_Type__c = 'ACV Credit Deduction';
        setupCred.Adjustment__c = true;
        setupCred.Amount_Approved__c = setupCred.Amount_Requested__c;
        setupCred.Approval_Status__c = 'Approved';
        setupCred.ACV_User_Id__c = '34233';
        setupCred.Dealership_ID__c = '1234';
        update setupCred;
        Test.stopTest();
        String expected = 'Done Successful';
        String actual = [SELECT Approval_Status__c FROM Credits_Checks__c].Approval_Status__c;
        System.assertEquals(expected, actual);
    }

    String full = '{"api_version": 2, "data": {"errors": [{"attempted_create": {"account_id": 14,"amount": 1,"authorizer":78179,"credit_cause_type": "Goodwill"},"error": {"message": "[\'A credit must have some form of supported source data\']","name": "ValidationError"}}],"successes": [{"amount": 500,"applicable_to": "buyer_fees","authorized_by": 78179,"cause_auction": null,"cause_notes": "","cause_type": 2,"expiration": "2020-05-21 00:00:00","expired": false,"id": 29,"remaining_amount":500,"salesforce_id": "1","timestamp": "2020-03-21 00:59:18"}]}}';

    @isTest
    static void checkAffectingBudget(){
        makeData2();
        List<Budget__c> b = [ SELECT Id, Current_Balance__c FROM Budget__c LIMIT 1 ];
        System.assert(b.size() > 0, 'No Budget Found');
        List<Account> acct = [ SELECT Id FROM Account LIMIT 1 ];
        System.assert(acct.size() > 0, 'No Account Found');

        String checkRTId = Schema.SObjectType.Credits_Checks__c.getRecordTypeInfosByDeveloperName().get('Check').getRecordTypeId();
        Test.startTest();
            Credits_Checks__c newCheck = new Credits_Checks__c(Name='Test Budget', Approval_Status__c = 'Approved', Amount_Approved__c = 600, OwnerId=UserInfo.getUserId(), Dealer__c=acct[0].id, Payment_Type__c='ACV Issue Check', Amount_Requested__c = 600, RecordTypeId=checkRTId, Explanation__c='Data Explanation', Budget_Name__c=b[0].Id);
            insert newCheck;
        Test.stopTest();
        List<Budget__c> budgetToCheck = [ SELECT Id, Current_Balance__c FROM Budget__c WHERE Id = :b[0].Id LIMIT 1 ];
        List<Credits_Checks__c> checkTocheck = [ SELECT Id, Amount_Approved__c FROM Credits_Checks__c WHERE ID = :newCheck.Id LIMIT 1 ];
        System.assertEquals(budgetToCheck[0].Current_Balance__c, b[0].Current_Balance__c - checkToCheck[0].Amount_Approved__c, 'The budget was not correctly updated');
    }
}