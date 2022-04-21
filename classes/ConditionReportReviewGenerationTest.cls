@isTest
public class ConditionReportReviewGenerationTest {
    private static string mockDataLocalString = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"420","Value_Type__c":"String"}]';
    private static string mockDataDuplicateValueTest= '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"420","Value_Type__c":"String"},{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"420","Value_Type__c":"String"}]';
    private static string mockDataRemoteBoolean = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"VCI__r.Account.Active__c","Trigger_Value__c":"True","Value_Type__c":"Boolean"}]';
    private static string mockDataLocalInteger = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"420","Value_Type__c":"Integer"}]';
    private static string mockDataLocalDouble = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"Floor_Price__c","Trigger_Value__c":"420.00","Value_Type__c":"Double"}]';
    private static string mockDataAdvancedLogicCRDuplicate = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Class_Name__c":"createPrescreenForDuplicateCR","Is_Advanced_Logic__c":true}]';
    private static string mockDataAdvancedLogicNegative = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Class_Name__c":"","Is_Advanced_Logic__c":true}]';
    private static string mockDataDuplicateValueTest2= '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"42","Value_Type__c":"String"},{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Class_Name__c":"createPrescreenForDuplicateCR","Is_Advanced_Logic__c":true}]';
    private static string mockDataSingleReasonTest = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"Floor_Price__c","Trigger_Value__c":"420.00","Value_Type__c":"Double", "Prescreen_Reason__c":"Floor Price"}]';
    private static string mockDataDoubleReasonTest = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"Floor_Price__c","Trigger_Value__c":"420.00","Value_Type__c":"Double", "Prescreen_Reason__c":"Floor Price"},{"DeveloperName":"testCriteria1","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"420","Value_Type__c":"String", "Prescreen_Reason__c":"Bad Item"}]';
    private static string mockDataSingleReasonTestNoName = '[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"Floor_Price__c","Trigger_Value__c":"420.00","Value_Type__c":"Double"}]';
    private static string mockCustomQueue ='[{"DeveloperName":"testCriteria","NamespacePrefix":"","Active__c":true,"Query_Path__c":"ACV_Saved_Auction_Id__c","Trigger_Value__c":"420","Value_Type__c":"String"}]';
    @isTest 
    static void testCustomAssignedQueue(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockCustomQueue, List<CR_Review_Trigger__mdt>.class);
        ConditionReportReviewGeneration.mockMetadata[0].Assigned_Queue__r = (CR_Review_Queue_Priority__mdt)JSON.deserializeStrict('{"DeveloperName":"Test_Queue_CR_Review","MasterLabel":"Test Queue CR Review","Priority__c":-9999}', CR_Review_Queue_Priority__mdt.class);
        
        Group grp = [ SELECT Id FROM Group WHERE DeveloperName = 'Test_Queue_CR_Review' LIMIT 1 ];
        System.runAs( new User(Id = UserInfo.getUserId()) ){
            QueuesObject q1 = new QueueSObject(QueueId = grp.id, SObjectType = 'Condition_Report_Prescreen__c');
            insert q1;
        }
        Test.startTest();
            Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1);
            insert cr;
        Test.stopTest();
        List<Condition_Report_Prescreen__c> crrList = [select id, OwnerId from Condition_Report_Prescreen__c];
        System.assertEquals(grp.Id, crrList[0].OwnerId,'Expected Assigned to Test Queue CR Review');
    }
    @isTest 
    static void testCustomAssignedQueuePriorityCheck(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockCustomQueue, List<CR_Review_Trigger__mdt>.class);
        ConditionReportReviewGeneration.mockMetadata[0].Assigned_Queue__r = (CR_Review_Queue_Priority__mdt)JSON.deserializeStrict('{"DeveloperName":"Test_Queue_CR_Review","MasterLabel":"Test Queue CR Review","Priority__c":0}', CR_Review_Queue_Priority__mdt.class);
        ConditionReportReviewGeneration.mockMetadata.addAll((List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockCustomQueue, List<CR_Review_Trigger__mdt>.class));
        ConditionReportReviewGeneration.mockMetadata[1].Assigned_Queue__r = (CR_Review_Queue_Priority__mdt)JSON.deserializeStrict('{"DeveloperName":"Test_Queue_CR_Higher_Priority","MasterLabel":"Test Queue CR Higher Priority","Priority__c":-9999}', CR_Review_Queue_Priority__mdt.class);
        ConditionReportReviewGeneration.mockMetadata[1].Query_Path__c = 'Floor_Price__c';
        ConditionReportReviewGeneration.mockMetadata[1].Value_Type__c = 'Double';
        ConditionReportReviewGeneration.mockMetadata[1].Prescreen_Reason__c = 'Floor Price';
        ConditionReportReviewGeneration.mockMetadata[1].Trigger_Value__c = '1';
        List<Group> grpList = [ SELECT Id FROM Group WHERE DeveloperName IN ('Test_Queue_CR_Review','Test_Queue_CR_Higher_Priority') LIMIT 2 ];
        System.runAs( new User(Id = UserInfo.getUserId()) ){
            List<QueuesObject> queuesObjectList = new List<QueuesObject>();
            for( Group grp : grpList ){
                queuesObjectList.add(new QueueSObject(QueueId = grp.id, SObjectType = 'Condition_Report_Prescreen__c'));
            }
            insert queuesObjectList;
        }
        Test.startTest();
            Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1);
            insert cr;
        Test.stopTest();
        List<Condition_Report_Prescreen__c> crrList = [select id, OwnerId, Owner.Name from Condition_Report_Prescreen__c];
        System.assertEquals('Test Queue CR Higher Priority', crrList[0].Owner.Name,'Expected Assigned to CR Queue');
    }
    @isTest
    static void testDuplicateCRMultipleUpdatesOldCRWithNoFloorPrice(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataAdvancedLogicCRDuplicate, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='421', vehicle__c = v.id);
        insert cr;
        Test.setCreatedDate(cr.Id,System.Today().addDays(-1));
        Condition_Report__c cr1 = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1, vehicle__c = v.id);
        insert cr1;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(0, crrList.size(),'Expected 0 Condition Report Review, found: '+crrList.size());
    }

    @isTest
    static void testDuplicateCRMultipleUpdates(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataAdvancedLogicCRDuplicate, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='421',Floor_Price__c = 1, vehicle__c = v.id);
        insert cr;
        Test.setCreatedDate(cr.Id,System.Today().addDays(-1));
        Condition_Report__c cr1 = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1, vehicle__c = v.id);
        insert cr1;
        update cr1;
        update cr1;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found: '+crrList.size());
    }


    @TestSetup
    static void makeData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Account a = new Account(Name='Bill Test', Active__c = true, legal_name__c='Bill Test', Dealer_type__c='1', BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US', phone= '1234567890');
        insert a;
        Contact c = new Contact(FirstName = 'Bill', LastName = 'Test', AccountId = a.id, email='test@email.com');
        insert c;
        Group grp1 = new Group( Name = 'Test Queue CR Review', DeveloperName = 'Test_Queue_CR_Review', Type = 'Queue' );
        Group grp2 = new Group( Name = 'Test Queue CR Higher Priority', DeveloperName = 'Test_Queue_CR_Higher_Priority', Type = 'Queue' );
        insert new List<Group>{grp1,grp2};
        // CR Queue is created in reality, so duplicate detected is triggered. Keeping here so we know thats where other CR Prescreens would go if assigned queue is not populated
        //Group grp2 = new Group( Name = 'CR Queue', DeveloperName = 'CR_Queue', Type = 'Queue' );
        }

    @isTest
    static void test1Cr1ConditionNoName(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataSingleReasonTestNoName, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00, vehicle__c = v.id);
        insert cr;
        List<Condition_Report_Prescreen__c> crpsList = [select id from Condition_Report_Prescreen__c where Condition_Report__c = :cr.id];
        List<Prescreen_Reason__c> prList = [Select id, Name from Prescreen_Reason__c where Condition_Report_Prescreen__c = :crpsList[0].id];
        System.assert(prList.size() == 0, 'Prescreen Reason was found when none should exist');
    }

    @isTest
    static void test2Cr1Condition(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataSingleReasonTest, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        Vehicle__c v2 = new Vehicle__c(id__c = '1231', VIN__c = '123jf3245432232');
        insert v;
        insert v2;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='421',Floor_Price__c = 1, vehicle__c = v.id);
        insert cr;
        Test.setCreatedDate(cr.Id,System.Today().addDays(-1));
        List<Condition_Report__c> testList = new List<Condition_Report__c>();
        testList.add(new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 420.00, vehicle__c = v.id));
        testList.add(new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='42', Floor_Price__c = 420.00, vehicle__c = v2.id));
        insert testList;
        List<Prescreen_Reason__c> prList = [Select id, Name from Prescreen_Reason__c];
        System.assert(prList.size() == 2, 'More or less than 2 Prescreen Reason was found');
    }

    @isTest
    static void test1Cr2Condition(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataDoubleReasonTest, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00, vehicle__c = v.id);
        insert cr;
        List<Condition_Report_Prescreen__c> crpsList = [select id from Condition_Report_Prescreen__c where Condition_Report__c = :cr.id];
        List<Prescreen_Reason__c> prList = [Select id, Name from Prescreen_Reason__c where Condition_Report_Prescreen__c = :crpsList[0].id];
        System.assert(prList.size() == 2, 'More or less than 2 Prescreen Reason was found');
        //System.assert(prList[0].Name == 'Floor Price', 'Reason Name does not match');
    }

    @isTest
    static void test1Cr1Condition(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataSingleReasonTest, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00, vehicle__c = v.id);
        insert cr;
        List<Condition_Report_Prescreen__c> crpsList = [select id from Condition_Report_Prescreen__c where Condition_Report__c = :cr.id];
        List<Prescreen_Reason__c> prList = [Select id, Name from Prescreen_Reason__c where Condition_Report_Prescreen__c = :crpsList[0].id];
        System.assert(prList.size() == 1, 'More or less than 1 Prescreen Reason was found');
        System.assert(prList[0].Name == 'Floor Price', 'Reason Name does not match');
    }

    @isTest
    static void test2CRsWithDifferentConditions(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataDuplicateValueTest2, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        Vehicle__c v2 = new Vehicle__c(id__c = '1231', VIN__c = '123jf3245432232');
        insert v;
        insert v2;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='421',Floor_Price__c = 1, vehicle__c = v.id);
        insert cr;
        Test.setCreatedDate(cr.Id,System.Today().addDays(-1));
        List<Condition_Report__c> testList = new List<Condition_Report__c>();
        testList.add(new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1, vehicle__c = v.id));
        testList.add(new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='42', Floor_Price__c = 1, vehicle__c = v2.id));
        insert testList;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(2, crrList.size(),'Expected 2 Condition Report Review, found : '+crrList.size());
    }

    @isTest
    static void testBadApexClass(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataAdvancedLogicNegative, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr1 = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1, vehicle__c = v.id);
        try{
            insert cr1;
        }
        Catch(Exception e){ 
            system.assert(e.getMessage().contains('CR Prscreen Generation: handler class not found for '), 'Error Messages Do Not Match');
        }
        
    }

    @isTest
    static void testDuplicateCR(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataAdvancedLogicCRDuplicate, List<CR_Review_Trigger__mdt>.class);
        Vehicle__c v = new Vehicle__c(id__c = '123', VIN__c = '123jf3245432234');
        insert v;
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='421',Floor_Price__c = 1, vehicle__c = v.id);
        insert cr;
        Test.setCreatedDate(cr.Id,System.Today().addDays(-1));
        Condition_Report__c cr1 = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1, vehicle__c = v.id);
        insert cr1;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testLocalString(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalString, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420');
        insert cr;
        cr.Floor_Price__c = 1;
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testLocalStringDuplicateField(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataDuplicateValueTest, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', Floor_Price__c = 1);
        insert cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testRemoteBoolean(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataRemoteBoolean, List<CR_Review_Trigger__mdt>.class);
        Contact  c = [select id from contact limit 1];
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', VCI__c = c.id);
        insert cr;
        cr.Floor_Price__c = 1; 
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testRemoteBooleanBadValues(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataRemoteBoolean, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',CR_Doc_Complete__c = false);
        insert cr;
        cr.Floor_Price__c = 1;
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(0, crrList.size(),'Expected 0 Condition Report Review, found 1 or more');
    }

     @isTest
    static void testLocalInteger(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalInteger, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',CR_Doc_Complete__c = false);
        insert cr;
        cr.Floor_Price__c = 1;
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

     @isTest
    static void testLocalDouble(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalDouble, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00, CR_Doc_Complete__c = false);
        insert cr;
        cr.Floor_Price__c = 1;
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

     @isTest
    static void testLocalDoubleInsertOnlyTrueCondition(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalDouble, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00);
        insert cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

      @isTest
    static void testLocalDoubleInsertOnlyFalseCondition(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalDouble, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420', CR_Doc_Complete__c = false);
        insert cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(0, crrList.size(),'Expected 0 Condition Report Review, found 1');
    }

         @isTest
    static void testLocalDoubleUpsertOnlyTrueCondition(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalDouble, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00);
        upsert cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testRemoteBooleanInsert(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataRemoteBoolean, List<CR_Review_Trigger__mdt>.class);
        Contact  c = [select id from contact limit 1];
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00, VCI__c = c.id);
        insert cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testRemoteBooleanUpsert(){
        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataRemoteBoolean, List<CR_Review_Trigger__mdt>.class);
        Contact  c = [select id from contact limit 1];
        Condition_Report__c cr = new Condition_Report__c(Name='TestCR', ACV_Saved_Auction_Id__c='420',Floor_Price__c = 420.00, VCI__c = c.id);
        insert cr;
        List<Condition_Report_Prescreen__c> crrList = [select id from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
    }

    @isTest
    static void testSellerDealership(){
        Account acctRecord = new Account(
            Name = 'Sutton Dealerships',
            legal_name__c = 'Sutton Dealerships',
            Dealer_Type__c = '1',
            Phone = '1234567890'
        );
        insert acctRecord;
        Vehicle__c vehicleRecord = new Vehicle__c(
            Name = '12345678901234567', Make__c = 'CHEVY', Model__c = 'TRAX', Year__c = '2017', 
            VIN__c = '12345678901234567', Most_Recent_Seller__c = acctRecord.Id
        );
        insert vehicleRecord;

        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalString, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(
            Name='TestCR', ACV_Saved_Auction_Id__c='420',CR_Doc_Complete__c= false, Vehicle__c = vehicleRecord.Id, Dealership__c = acctRecord.id
        );
        insert cr;
        System.assert(![Select id, CR_Doc_Complete__c from Condition_Report__c where id = :cr.id limit 1].CR_Doc_Complete__c);
        cr.CR_Doc_Complete__c = true;
        cr.Floor_Price__c = 2;
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id, seller_dealership__c from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
        System.assertEquals(
            acctRecord.id, crrList[0].Seller_Dealership__c,'Seller Dealership Id did not match the original Seller Account Id'
        );
    }

    @isTest
    static void testDuplicatePrevention(){
        Account acctRecord = new Account(
            Name = 'Sutton Dealerships',
            legal_name__c = 'Sutton Dealerships',
            Dealer_Type__c = '1',
            Phone = '1234567890'
        );
        insert acctRecord;
        Vehicle__c vehicleRecord = new Vehicle__c(
            Name = '12345678901234567', Make__c = 'CHEVY', Model__c = 'TRAX', Year__c = '2017', 
            VIN__c = '12345678901234567', Most_Recent_Seller__c = acctRecord.Id
        );
        insert vehicleRecord;

        ConditionReportReviewGeneration.mockMetadata = (List<CR_Review_Trigger__mdt>)JSON.deserializeStrict(mockDataLocalString, List<CR_Review_Trigger__mdt>.class);
        Condition_Report__c cr = new Condition_Report__c(
            Name='TestCR', ACV_Saved_Auction_Id__c='420',CR_Doc_Complete__c= false, Vehicle__c = vehicleRecord.Id, Dealership__c = acctRecord.id
        );
        insert cr;
        System.assert(![Select id, CR_Doc_Complete__c from Condition_Report__c where id = :cr.id limit 1].CR_Doc_Complete__c);
        cr.CR_Doc_Complete__c = true;
        cr.Floor_Price__c = 2;
        update cr;
        cr.Floor_Price__c = 0;
        update cr;
        cr.Floor_Price__c = 20;
        update cr;
        List<Condition_Report_Prescreen__c> crrList = [select id, seller_dealership__c from Condition_Report_Prescreen__c];
        System.assertEquals(1, crrList.size(),'Expected 1 Condition Report Review, found 0');
        System.assertEquals(
            acctRecord.id, crrList[0].Seller_Dealership__c,'Seller Dealership Id did not match the original Seller Account Id'
        );
    }
}