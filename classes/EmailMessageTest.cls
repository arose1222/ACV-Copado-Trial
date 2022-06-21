@istest
public class EmailMessageTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        String uniqueUserName = 'Adminuser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
//         User u = new User(Alias = 'admint', Email='adminuser@testorg.com',
//         EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
//         LocaleSidKey='en_US', TimeZoneSidKey='America/New_York', ProfileId = p.Id,
//          UserName=uniqueUserName);
// insert u;
        User u = TestUtility.createSystemAdministratorUser();
        System.runAs(u) {
            Test.setMock(HttpCalloutMock.class, New AcvIntegrationQueueableMock());
            Account actObj = TestUtility.createAccount();
            insert actObj;
            Contact contactObj = TestUtility.createContact(actObj);
            insert contactObj;
            Vehicle__c vehicleObj = TestUtility.createVehicle();
            insert vehicleObj;
            Auction__c auctionObj = TestUtility.createAuction(actObj, contactObj, vehicleObj);
            auctionObj.Payment_Status__c = 'Pending';
            insert auctionObj;
            Case caseObj = TestUtility.createCase(auctionObj,vehicleObj,actObj,contactObj);
            caseObj.Claim_Manually_Submitted_Date__c = Date.today() - 7;
            insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
            insert caseObj;

            Account tAcctObj = TestUtility.createTransportAcct();
            insert tAcctObj;
            Transportation_Address__c addressObj = TestUtility.createAddress();
            insert addressObj;
            Case tCaseObj = TestUtility.createTransportCase(addressObj, actObj, contactObj, auctionObj);
            tCaseObj.Transporter_Account__c = tAcctObj.Id;
            tCaseObj.Expected_Delivery__c = Date.Today() - 7;
            insert tCaseObj;
        }
    } 

    @isTest static void testCreateArb(){
        Case testCase = [SELECT Id,CreatedById,IsClosedOnCreate,Auction_Number_Case__c, Auction_Number__c FROM Case WHERE Subject='Testing' LIMIT 1];
        System.assertEquals(1,[SELECT Id, Auction_Number__r.Open_Arbitration_Cases__c FROM Case WHERE Id = :testCase.Id].Auction_Number__r.Open_Arbitration_Cases__c);
        Contact testContact = [SELECT Id, Email FROM Contact LIMIT 1];
        String arbToAddress;
        EmailToCase_Mapping__mdt arbACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Arb' LIMIT 1];
        if(arbACVIntegrationObj != null){
            arbToAddress = arbACVIntegrationObj.ToAddress__c;
        }
        String body = '\n\nReport Email:\n'+testContact.Email+'\n\nAuction ID:\n'+testCase.Auction_Number_Case__c+'\n\n';
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress = arbToAddress,
            ParentId = testCase.Id,
            TextBody = body
        );
        Test.startTest();
            insert testEmailMsg;
        Test.stopTest();
    }
    @isTest static void testAcceptedCDEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Order ID: ' + testTransportCase.Auction_Number_Case__c + ' has been ACCEPTED by Test Transporter',
            ParentId=testCase.Id
            );
        system.debug(testEmailMsg);
        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT Id, ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Case testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(emailMsg.ParentId, testTransportCase.Id);
        System.assertEquals('Accepted',testTransportCaseUpdated.Status);
    }

    @isTest static void testPickedUpCDEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Order ID: ' + testTransportCase.Auction_Number_Case__c + ' has been PICKED UP by Test Transporter',
            ParentId=testCase.Id
            );

        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Case testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

            System.assertEquals(emailMsg.ParentId, testTransportCase.Id);
            System.assertEquals('Picked-Up',testTransportCaseUpdated.Status);
    
    }

    @isTest static void testCancelledCDEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Order ID: ' + testTransportCase.Auction_Number_Case__c + ' has been CANCELLED by Test Transporter',
            ParentId=testCase.Id
            );

        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Account testTransportAcct = [SELECT Id, Number_of_Times_Cancelled__c, Number_of_Times_Declined__c FROM Account WHERE Name = 'Test Transporter' Limit 1];
            Case testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(emailMsg.ParentId, testTransportCase.Id);
        System.assertEquals('Cancelled by Transporter',testTransportCaseUpdated.Status);
        System.assertEquals(1, testTransportAcct.Number_of_Times_Cancelled__c);
        
    }
    @isTest static void testDeclinedCDEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }

        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Order ID: ' + testTransportCase.Auction_Number_Case__c + ' has been DECLINED by Test Transporter',
            ParentId=testCase.Id
            );

        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Account testTransportAcct = [SELECT Id, Number_of_Times_Cancelled__c, Number_of_Times_Declined__c FROM Account WHERE Name = 'Test Transporter' Limit 1];
            Case testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(emailMsg.ParentId, testTransportCase.Id);
        System.assertEquals('Ready-to-Post',testTransportCaseUpdated.Status);
        System.assertEquals(1, testTransportAcct.Number_of_Times_Declined__c);


    }
    @isTest static void testDeliveredCDEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }

        String dateInbod = string.valueOf(Date.Today());
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Order ID: ' + testTransportCase.Auction_Number_Case__c + ' has been DELIVERED by Test Transporter',
            ParentId=testCase.Id,
            TextBody='* Please do not reply to this email. It was sent from an unattended mailbox, and replies are not reviewed. See below for contact information. *\n\nDear ACV Auctions Inc,\n\nThis email is to inform you that GM Car Carrier has marked Order ID 1234567 as picked up on '+dateInbod+' by GM Car Carrier. You may view the order in detail below:\n\nhttps://www.centraldispatch.com/protected/dispatch/view?dsid=19844917\n\nBelow is a summary of the order:\n\nOrder ID: 1234567\nPickup: Vestal, NY 13850\nDelivery: Tonawanda, NY 14150\nVehicle: 2011 Toyota Corolla LE\nShip Via: Open\nVehicles Run: Yes\nPickup Estimated: 2019-04-09\nCarrier Pay: 250.00\nDriver:\nDriver Phone:\nDispatch Instructions: acv auctions email bol to bol@acvauctionscom'
            );

        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Case testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(emailMsg.ParentId, testTransportCase.Id);
        System.assertEquals('Delivered',testTransportCaseUpdated.Status);

    }

    @isTest static void testFailedPostEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Central Dispatch Import Log - ACV Auctions Inc (acvcars)',
            TextBody='Dear ACV Auctions Inc:\n\nBelow are the results of your recent email import message.\n\nPlease note: By default, results are only sent when there are warnings or when one or more vehicle listings are corrected or fail to post. If you would like to receive an email for every vehicle listing that is posted (regardless of status) go to My Account and check “Email Import | Send Full Report”.\n\nIf you have questions or comments, please use the Contact Us page:\n\nhttp://www.centraldispatch.com/contact-us\nSUMMARY — Your import email message resulted in the following:\n\nDeleted: 0          (Vehicles removed from Central Dispatch)\nFailed To Post: 1   (Vehicles that DID NOT POST due to an error)\nWarning: 0          (Vehicles posted with warnings)\nCorrected: 0        (Vehicles posted with valid zip codes -- corrected)\nMisspelled: 0       (Vehicles posted with city name spelling corrected)\nValidated: 0        (Vehicles posted with valid zip codes okay)\nIdentical: 0        (Vehicles identical to currently posted vehicles)\nTotal Posted: 1  (Total count of vehicles posted)\nDETAILS:\n--VEHICLES THAT FAILED TO POST: 1\n\n      > '+testTransportCase.Auction_Number_Case__c+',bryant,ar,72022,dallas,tx,75236,350,0.00,check,delivery,quickpay,open,operable,2019-04-18,2019-05-18,acv auctions - email bol to bol@acvauctions.com,||||yama2867j80900000\nVIN cannot be decoded\n--VEHICLES POSTED WITH WARNINGS: 0\n\n--VEHICLES POSTED WITH VALID ZIP CODES — CORRECTED: NONE\n\n--VEHICLES POSTED WITH CITY NAME SPELLING CORRECTED: NONE\n\n--VEHICLES POSTED WITH VALID ZIP CODES OKAY: NONE',
            ParentId=testCase.Id
            );

        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Case testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(emailMsg.ParentId, testTransportCase.Id);
        System.assertEquals('Failed Post',testTransportCaseUpdated.Status);

    }

    @isTest static void testStatusUpdateWithNoActionEmail(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='Central Dispatch Import Log - ACV Auctions Inc (acvcars)',
            TextBody='Dear ACV Auctions Inc:\n\nBelow are the results of your recent email import message.\n\nPlease note: By default, results are only sent when there are warnings or when one or more vehicle listings are corrected or fail to post. If you would like to receive an email for every vehicle listing that is posted (regardless of status) go to My Account and check “Email Import | Send Full Report”.\n\nIf you have questions or comments, please use the Contact Us page:\n\nhttp://www.centraldispatch.com/contact-us\nSUMMARY — Your import email message resulted in the following:\n\nDeleted: 0          (Vehicles removed from Central Dispatch)\nFailed To Post: 0   (Vehicles that DID NOT POST due to an error)\nWarning: 0          (Vehicles posted with warnings)\nCorrected: 0        (Vehicles posted with valid zip codes -- corrected)\nMisspelled: 0       (Vehicles posted with city name spelling corrected)\nValidated: 0        (Vehicles posted with valid zip codes okay)\nIdentical: 0        (Vehicles identical to currently posted vehicles)\nTotal Posted: 1  (Total count of vehicles posted)\nDETAILS:\n--VEHICLES THAT FAILED TO POST: 1\n\n      > '+testTransportCase.Auction_Number_Case__c+',bryant,ar,72022,dallas,tx,75236,350,0.00,check,delivery,quickpay,open,operable,2019-04-18,2019-05-18,acv auctions - email bol to bol@acvauctions.com,||||yama2867j80900000\nVIN cannot be decoded\n--VEHICLES POSTED WITH WARNINGS: 0\n\n--VEHICLES POSTED WITH VALID ZIP CODES — CORRECTED: NONE\n\n--VEHICLES POSTED WITH CITY NAME SPELLING CORRECTED: NONE\n\n--VEHICLES POSTED WITH VALID ZIP CODES OKAY: NONE',
            ParentId=testCase.Id
            );

        Test.startTest();
            insert testEmailMsg;
            //EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            List<Case> testTransportCaseUpdated = [SELECT Id, Status, Number_of_Times_Declined__c, Number_of_Times_Cancelled__c, Date_First_Accepted__c, Date_Last_Accepted__c,
                                        Date_Picked_Up__c, Expected_Delivery__c, Marked_Picked_Up_in_CD__c, Auction_Number_Case__c FROM Case WHERE id = :testCase.id Limit 1];
        Test.stopTest();
        System.assertEquals(0,testTransportCaseUpdated.size());

    }

    @isTest static void testBOLEmailInternal(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='BOL upload for ACV Auctions',
            ParentId=testCase.Id,
            TextBody='BOL upload for ACV Auctions \n\n' + '     Auction/Order: ' + testTransportCase.Auction_Number_Case__c + '\n' + '      Carrier: ACV Auctions'
            );

        System.debug(testEmailMsg);

        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Case testTransportCaseUpdated = [SELECT Id, BOL_Received__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(true, testTransportCaseUpdated.BOL_Received__c);
    }

    @isTest static void testBOLEmailExternal(){
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Testing' LIMIT 1];
        Case testTransportCase = [SELECT Id, Auction_Number_Case__c, Transporter_Account__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        String transToAddress;
        EmailToCase_Mapping__mdt transACVIntegrationObj = [select Id, DeveloperName, MasterLabel, ToAddress__c
            from EmailToCase_Mapping__mdt where MasterLabel =: 'New Trans' LIMIT 1];
        if(transACVIntegrationObj != null){
            transToAddress = transACVIntegrationObj.ToAddress__c;
        }
        EmailMessage testEmailMsg = new EmailMessage(
            ToAddress=transToAddress,
            Subject='BOL: ' + testTransportCase.Auction_Number_Case__c + ' - ACV Auctions',
            ParentId=testCase.Id
            );

        System.debug(testEmailMsg);
        Test.startTest();
            insert testEmailMsg;
            EmailMessage emailMsg = [SELECT ParentId FROM EmailMessage WHERE Id = :testEmailMsg.Id ];
            Case testTransportCaseUpdated = [SELECT Id, BOL_Received__c, Auction_Number_Case__c FROM Case WHERE Subject = 'Test Transport Case' Limit 1];
        Test.stopTest();

        System.assertEquals(true, testTransportCaseUpdated.BOL_Received__c);
    }
}