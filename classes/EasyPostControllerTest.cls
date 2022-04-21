/**
 * @description A component to generate EasyPost tracking number and postage labels on Case & Quality Control objects.
 * 
 * @author Manmeet Vaseer
 * @date 07/20/2021
 * 
 */
@isTest
public class EasyPostControllerTest {
    
	@isTest
    static void saveShippingLabels()	{
        Test.startTest();
                
        String acctUniqueName = 'Test EasyPostControllerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Status = 'New';
        
        SObject[] newObjs = new SObject[] {newAcct, newContact, newVehicle, newAuction, newTitleCase};
        insert newObjs;
        
        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;
        
        String recordId = qc.Id;
        String jsonShippingLabels = '[{"trackingCode":"281659026431","link":"https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20210720/e6730fd4062b45d3acb53d648d3f24d0.png","label_zpl_url":"null"},{"trackingCode":"281659029967","link":"https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20210720/540c3cf8f1e547e493c60e190420f058.png","label_zpl_url":"null"}]';
        Boolean isQualityControl = true;
        
        String buyerSellerIndicator = 'Buyer Billing Address';
        String contactEmail='m@v.com'; 
        String contactName='Buyer Dealer Name';
        Boolean result = EasyPostController.saveShippingLabels(recordId, jsonShippingLabels, isQualityControl, buyerSellerIndicator, contactEmail, contactName);
        System.assertEquals(true, result, 'Unable to save shipping lablels.');    
        
        qc = [SELECT Id, Seller_To_ACV_Label__c, Seller_To_ACV_Tracking_Code__c, ACV_To_Seller_Label__c, ACV_To_Seller_Tracking_Code__c, 
              Buyer_To_ACV_Label__c, Buyer_To_ACV_Tracking_Code__c, ACV_To_Buyer_Label__c, ACV_To_Buyer_Tracking_Code__c,
              Send_Postage_Email_To_Buyer__c, 	Return_Postage_Label_Email__c, Return_Postage_Label_Contact_Name__c FROM Quality_Control__c WHERE Id = :recordId];
        System.assertEquals('281659026431', qc.ACV_To_Buyer_Tracking_Code__c, 'Invalid Ship_To_Tracking_Code__c');    
        System.assertEquals('https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20210720/e6730fd4062b45d3acb53d648d3f24d0.png', qc.ACV_To_Buyer_Label__c, 'Invalid Ship_To_Postage_Label_URL__c');    
        System.assertEquals('281659029967', qc.Buyer_To_ACV_Tracking_Code__c, 'Invalid Return_Address_Tracking_Code__c');    
        System.assertEquals('https://easypost-files.s3-us-west-2.amazonaws.com/files/postage_label/20210720/540c3cf8f1e547e493c60e190420f058.png', qc.Buyer_To_ACV_Label__c, 'Invalid Return_Address_Postage_Label_URL__c');
        System.assertEquals(false, qc.Send_Postage_Email_To_Buyer__c, 'Workflow trigger field should be false.');    
        System.assertEquals(contactEmail, qc.Return_Postage_Label_Email__c, 'Return Postage Label Email does not match.');    
        System.assertEquals(contactName, qc.Return_Postage_Label_Contact_Name__c, 'Return Postage Label Contact Name does not match.');    
        
        Test.stopTest();
    }
    
	@isTest
    static void testGetAddresses()	{
        Test.startTest();

        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test EasyPostControllerTest';
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newTitlesUser, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        insert newTitleCase;

        String recordId = newTitleCase.Id;
        Boolean isQualityControl = false;
        Boolean isRetrieveBuyerAddress = true;
        Boolean isRetrieveSellerAddress = true;
        Boolean isRetrieveBuyerFloorPlanAddress = false;
        String jsonPayload = EasyPostController.getAddresses(recordId, isQualityControl, isRetrieveBuyerAddress, isRetrieveSellerAddress, isRetrieveBuyerFloorPlanAddress);
        
        System.assertNotEquals(null, jsonPayload, 'JSON Payload is null.');
        EasyPostController.Payload pl = (EasyPostController.Payload)System.JSON.deserialize(jsonPayload, EasyPostController.Payload.class);
        System.assertNotEquals(null, pl, 'Could not Deserialize JSON Payload.');
        
        System.assertNotEquals(null, pl.addressOptions, 'No Addresses found.');
		System.assertEquals(6, pl.addressOptions.size(), 'There should be 6 addresses.');
        
        Integer addrCounter = 0;
        for(EasyPostController.PayloadAddressOption pao : pl.addressOptions)	{
            if(pao.label == 'Buyer Billing Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Test EasyPostControllerTest Buyer', value.address.name, 'Buyer Billing Address Name not matching.');
				System.assertEquals('12 Test St', value.address.street, 'Buyer Billing Address Street not matching.');
				System.assertEquals('Buffalo', value.address.city, 'Buyer Billing Address City not matching.');
				System.assertEquals('NY', value.address.state, 'Buyer Billing Address State not matching.');
				System.assertEquals('US', value.address.country, 'Buyer Billing Address Country not matching.');
				System.assertEquals('14228', value.address.zip, 'Buyer Billing Address Zip not matching.');

				System.assertEquals('Buyer Legal Address Notes.', value.notes.legalNotes, 'Buyer Legal Notes not matching.');
				System.assertEquals('Buyer Pickup Notes.', value.notes.pickupNotes, 'Buyer Pickup Notes not matching.');
				System.assertEquals('Buyer Dealership Notes.', value.notes.dealershipNotes, 'Buyer Dealership Notes not matching.');
				System.assertEquals('Buyer Title Mailing Address Notes.', value.notes.titleMailingAddressNotes, 'Buyer Title Mailing Address Notes not matching.');
                
				System.assertNotEquals(null, value.miscInfo.caseNumber, 'Buyer Case Number is null.');
            }
            else if(pao.label == 'Buyer Legal Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Test EasyPostControllerTest Buyer', value.address.name, 'Buyer Legal Address Name not matching.');
				System.assertEquals('Buyer Legal Street', value.address.street, 'Buyer Legal Address Street not matching.');
				System.assertEquals('Buyer Legal City', value.address.city, 'Buyer Legal Address City not matching.');
				System.assertEquals('Buyer Legal State', value.address.state, 'Buyer Legal Address State not matching.');
				System.assertEquals('L Country', value.address.country, 'Buyer Legal Address Country not matching.');
				System.assertEquals('L Zip', value.address.zip, 'Buyer Legal Address Zip not matching.');

				System.assertEquals('Buyer Legal Address Notes.', value.notes.legalNotes, 'Buyer Legal Notes not matching.');
				System.assertEquals('Buyer Pickup Notes.', value.notes.pickupNotes, 'Buyer Pickup Notes not matching.');
				System.assertEquals('Buyer Dealership Notes.', value.notes.dealershipNotes, 'Buyer Dealership Notes not matching.');
				System.assertEquals('Buyer Title Mailing Address Notes.', value.notes.titleMailingAddressNotes, 'Buyer Title Mailing Address Notes not matching.');
                
				System.assertNotEquals(null, value.miscInfo.caseNumber, 'Buyer Case Number is null.');
            }
            else if(pao.label == 'Buyer Title Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Test EasyPostControllerTest Buyer', value.address.name, 'Buyer Title Address Name not matching.');
				System.assertEquals('Buyer Title Street', value.address.street, 'Buyer Title Address Street not matching.');
				System.assertEquals('Buyer Title City', value.address.city, 'Buyer Title Address City not matching.');
				System.assertEquals('Buyer Title State', value.address.state, 'Buyer Title Address State not matching.');
				//System.assertEquals('T Country', value.address.country, 'Buyer Title Address Country not matching.');
				System.assertEquals('T Zip', value.address.zip, 'Buyer Title Address Zip not matching.');

				System.assertEquals('Buyer Legal Address Notes.', value.notes.legalNotes, 'Buyer Title Notes not matching.');
				System.assertEquals('Buyer Pickup Notes.', value.notes.pickupNotes, 'Buyer Pickup Notes not matching.');
				System.assertEquals('Buyer Dealership Notes.', value.notes.dealershipNotes, 'Buyer Dealership Notes not matching.');
				System.assertEquals('Buyer Title Mailing Address Notes.', value.notes.titleMailingAddressNotes, 'Buyer Title Mailing Address Notes not matching.');
                
				System.assertNotEquals(null, value.miscInfo.caseNumber, 'Buyer Case Number is null.');
            }
            else if(pao.label == 'Seller Billing Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Test EasyPostControllerTest Seller', value.address.name, 'Seller Billing Address Name not matching.');
				System.assertEquals('12 Test St', value.address.street, 'Seller Billing Address Street not matching.');
				System.assertEquals('Buffalo', value.address.city, 'Seller Billing Address City not matching.');
				System.assertEquals('NY', value.address.state, 'Seller Billing Address State not matching.');
				System.assertEquals('US', value.address.country, 'Seller Billing Address Country not matching.');
				System.assertEquals('14228', value.address.zip, 'Seller Billing Address Zip not matching.');

				System.assertEquals('Seller Legal Address Notes.', value.notes.legalNotes, 'Seller Legal Notes not matching.');
				System.assertEquals('Seller Pickup Notes.', value.notes.pickupNotes, 'Seller Pickup Notes not matching.');
				System.assertEquals('Seller Dealership Notes.', value.notes.dealershipNotes, 'Seller Dealership Notes not matching.');
				System.assertEquals('Seller Title Mailing Address Notes.', value.notes.titleMailingAddressNotes, 'Seller Title Mailing Address Notes not matching.');
                
				System.assertNotEquals(null, value.miscInfo.caseNumber, 'Seller Case Number is null.');
            }
            else if(pao.label == 'Seller Legal Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Test EasyPostControllerTest Seller', value.address.name, 'Seller Legal Address Name not matching.');
				System.assertEquals('Seller Legal Street', value.address.street, 'Seller Legal Address Street not matching.');
				System.assertEquals('Seller Legal City', value.address.city, 'Seller Legal Address City not matching.');
				System.assertEquals('Seller Legal State', value.address.state, 'Seller Legal Address State not matching.');
				System.assertEquals('L Country', value.address.country, 'Seller Legal Address Country not matching.');
				System.assertEquals('L Zip', value.address.zip, 'Seller Legal Address Zip not matching.');

				System.assertEquals('Seller Legal Address Notes.', value.notes.legalNotes, 'Seller Legal Notes not matching.');
				System.assertEquals('Seller Pickup Notes.', value.notes.pickupNotes, 'Seller Pickup Notes not matching.');
				System.assertEquals('Seller Dealership Notes.', value.notes.dealershipNotes, 'Seller Dealership Notes not matching.');
				System.assertEquals('Seller Title Mailing Address Notes.', value.notes.titleMailingAddressNotes, 'Seller Title Mailing Address Notes not matching.');
                
				System.assertNotEquals(null, value.miscInfo.caseNumber, 'Seller Case Number is null.');
            }
            else if(pao.label == 'Seller Title Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Test EasyPostControllerTest Seller', value.address.name, 'Seller Title Address Name not matching.');
				System.assertEquals('Seller Title Street', value.address.street, 'Seller Title Address Street not matching.');
				System.assertEquals('Seller Title City', value.address.city, 'Seller Title Address City not matching.');
				System.assertEquals('Seller Title State', value.address.state, 'Seller Title Address State not matching.');
				//System.assertEquals('T Country', value.address.country, 'Seller Title Address Country not matching.');
				System.assertEquals('T Zip', value.address.zip, 'Seller Title Address Zip not matching.');

				System.assertEquals('Seller Legal Address Notes.', value.notes.legalNotes, 'Seller Title Notes not matching.');
				System.assertEquals('Seller Pickup Notes.', value.notes.pickupNotes, 'Seller Pickup Notes not matching.');
				System.assertEquals('Seller Dealership Notes.', value.notes.dealershipNotes, 'Seller Dealership Notes not matching.');
				System.assertEquals('Seller Title Mailing Address Notes.', value.notes.titleMailingAddressNotes, 'Seller Title Mailing Address Notes not matching.');
                
				System.assertNotEquals(null, value.miscInfo.caseNumber, 'Seller Case Number is null.');
            }
        }
        
        System.assertEquals(pl.addressOptions.size(), addrCounter, 'There should be 6 addresses processed.');

        Test.stopTest();
    }
    
	@isTest
    static void testGetAddressesFloorPlan()	{
        Test.startTest();
        
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test EasyPostControllerTest';
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newTitlesUser, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Payment_Method__c = 'adi'; // Send_Title_to_Buyer__c=false
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        insert newTitleCase;

        String recordId = newTitleCase.Id;
        Boolean isQualityControl = false;
        Boolean isRetrieveBuyerAddress = true;
        Boolean isRetrieveSellerAddress = false;
        Boolean isRetrieveBuyerFloorPlanAddress = true;
        String jsonPayload = EasyPostController.getAddresses(recordId, isQualityControl, isRetrieveBuyerAddress, isRetrieveSellerAddress, isRetrieveBuyerFloorPlanAddress);
        
        System.assertNotEquals(null, jsonPayload, 'JSON Payload is null.');
        EasyPostController.Payload pl = (EasyPostController.Payload)System.JSON.deserialize(jsonPayload, EasyPostController.Payload.class);
        System.assertNotEquals(null, pl, 'Could not Deserialize JSON Payload.');
        
        System.assertNotEquals(null, pl.addressOptions, 'No Addresses found.');
		System.assertEquals(1, pl.addressOptions.size(), 'There should be 1 addresses.');
        
        Integer addrCounter = 0;
        for(EasyPostController.PayloadAddressOption pao : pl.addressOptions)	{
            if(pao.label == 'Buyer Billing Address')	{
                System.assert(true, 'Should not have returned Buyer Billing Address as the buyer is using the Floor Plan and Send_Title_to_Buyer__c=false');
            }
            else if(pao.label == 'Buyer Legal Address')	{
                System.assert(true, 'Should not have returned Buyer Legal Address as the buyer is using the Floor Plan and Send_Title_to_Buyer__c=false');
            }
            else if(pao.label == 'Buyer Title Address')	{
                System.assert(true, 'Should not have returned Buyer Title Address as the buyer is using the Floor Plan and Send_Title_to_Buyer__c=false');
            }
            else if(pao.label == 'Seller Billing Address')	{
                System.assert(true, 'Should not have returned Seller Billing Address as isRetrieveSellerAddress=false');
            }
            else if(pao.label == 'Seller Legal Address')	{
                System.assert(true, 'Should not have returned Seller Legal Address as isRetrieveSellerAddress=false');
            }
            else if(pao.label == 'Seller Title Address')	{
                System.assert(true, 'Should not have returned Seller Title Address as isRetrieveSellerAddress=false');
            }
            else if(pao.label == 'Buyer Floor Plan Address')	{
                addrCounter = addrCounter + 1;
                EasyPostController.PayloadAddressValue value = pao.value;
				System.assertEquals('Michael Yayapur', value.address.name, 'Floor Plan Address Name not matching.');
				System.assertEquals('ADI Partners', value.address.company, 'Floor Plan Company not matching.');
				System.assertEquals('211 E Six Forks Rd', value.address.street, 'Floor Plan Address Street not matching.');
				System.assertEquals('Ste 113', value.address.street2, 'Floor Plan Address Street2 not matching.');
				System.assertEquals('Raleigh', value.address.city, 'Floor Plan Address City not matching.');
				System.assertEquals('NC', value.address.state, 'Floor Plan Address State not matching.');
				System.assertEquals('US', value.address.country, 'Floor Plan Address Country not matching.');
				System.assertEquals('27609', value.address.zip, 'Floor Plan Address Zip not matching.');
            }
            
        }
        
        System.assertEquals(pl.addressOptions.size(), addrCounter, 'There should be 1 address processed.');

        Test.stopTest();
    }

	@isTest
    static void testGetAddressesFloorPlanBuyer()	{
        Test.startTest();
        
        Profile p = [SELECT Name, Id FROM Profile WHERE Name = 'Titles'];
        User newTitlesUser = TestUtility.createUser(p.Id);
        
        String acctUniqueName = 'Test EasyPostControllerTest';
        Account newBuyerAcct = TestUtility.createAccount(acctUniqueName + ' Buyer'); 
		newBuyerAcct.Legal_Street__c = 'Buyer Legal Street';
        newBuyerAcct.Legal_City__c = 'Buyer Legal City';
        newBuyerAcct.Legal_State__c = 'Buyer Legal State';
        newBuyerAcct.Legal_Country__c = 'L Country';
        newBuyerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newBuyerAcct.Title_Mailing_Street__c = 'Buyer Title Street';
        newBuyerAcct.Title_Mailing_City__c = 'Buyer Title City';
        newBuyerAcct.Title_Mailing_State__c = 'Buyer Title State';
        newBuyerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newBuyerAcct.Legal_Address_Note__c = 'Buyer Legal Address Notes.';
        newBuyerAcct.Pickup_Notes__c = 'Buyer Pickup Notes.';
        newBuyerAcct.Dealership_Notes__c = 'Buyer Dealership Notes.';
        newBuyerAcct.Title_Mailing_Address_Note__c = 'Buyer Title Mailing Address Notes.';
        
        Account newSellerAcct = TestUtility.createAccount(acctUniqueName + ' Seller');  
		newSellerAcct.Legal_Street__c = 'Seller Legal Street';
        newSellerAcct.Legal_City__c = 'Seller Legal City';
        newSellerAcct.Legal_State__c = 'Seller Legal State';
        newSellerAcct.Legal_Country__c = 'L Country';
        newSellerAcct.Legal_Zip_Code__c = 'L Zip';
        
		newSellerAcct.Title_Mailing_Street__c = 'Seller Title Street';
        newSellerAcct.Title_Mailing_City__c = 'Seller Title City';
        newSellerAcct.Title_Mailing_State__c = 'Seller Title State';
        newSellerAcct.Title_Mailing_Zip_Code__c = 'T Zip';
        
        newSellerAcct.Legal_Address_Note__c = 'Seller Legal Address Notes.';
        newSellerAcct.Pickup_Notes__c = 'Seller Pickup Notes.';
        newSellerAcct.Dealership_Notes__c = 'Seller Dealership Notes.';
        newSellerAcct.Title_Mailing_Address_Note__c = 'Seller Title Mailing Address Notes.';
        
        Contact newContact = TestUtility.createContact(newSellerAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();

        SObject[] newObjs = new SObject[] {newTitlesUser, newBuyerAcct, newSellerAcct, newContact, newVehicle};
        insert newObjs;
        
        Auction__c newAuction = TestUtility.createAuction(newSellerAcct, newContact, newVehicle);
        newAuction.Buyer_Dealership__c = newBuyerAcct.Id;
        newAuction.Seller_Dealership__c = newSellerAcct.Id;
        newAuction.Payment_Method__c = 'bbt'; // Send_Title_to_Buyer__c=true
        insert newAuction;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newBuyerAcct, newContact);
        newTitleCase.AccountId = newBuyerAcct.Id;
        newTitleCase.Seller_Dealership__c = newSellerAcct.Id;
        newTitleCase.Status = 'New';
        insert newTitleCase;

        String recordId = newTitleCase.Id;
        Boolean isQualityControl = false;
        Boolean isRetrieveBuyerAddress = true;
        Boolean isRetrieveSellerAddress = false;
        Boolean isRetrieveBuyerFloorPlanAddress = true;
        String jsonPayload = EasyPostController.getAddresses(recordId, isQualityControl, isRetrieveBuyerAddress, isRetrieveSellerAddress, isRetrieveBuyerFloorPlanAddress);
        
        System.assertNotEquals(null, jsonPayload, 'JSON Payload is null.');
        EasyPostController.Payload pl = (EasyPostController.Payload)System.JSON.deserialize(jsonPayload, EasyPostController.Payload.class);
        System.assertNotEquals(null, pl, 'Could not Deserialize JSON Payload.');
        
        System.assertNotEquals(null, pl.addressOptions, 'No Addresses found.');
		System.assertEquals(3, pl.addressOptions.size(), 'There should be 3 addresses.');
        
        Integer addrCounter = 0;
        for(EasyPostController.PayloadAddressOption pao : pl.addressOptions)	{
            if(pao.label == 'Buyer Billing Address')	{
                addrCounter = addrCounter + 1;
            }
            else if(pao.label == 'Buyer Legal Address')	{
                addrCounter = addrCounter + 1;
            }
            else if(pao.label == 'Buyer Title Address')	{
                addrCounter = addrCounter + 1;
            }
            else if(pao.label == 'Seller Billing Address')	{
                System.assert(true, 'Should not have returned Seller Billing Address as isRetrieveSellerAddress=false');
            }
            else if(pao.label == 'Seller Legal Address')	{
                System.assert(true, 'Should not have returned Seller Legal Address as isRetrieveSellerAddress=false');
            }
            else if(pao.label == 'Seller Title Address')	{
                System.assert(true, 'Should not have returned Seller Title Address as isRetrieveSellerAddress=false');
            }
            else if(pao.label == 'Buyer Floor Plan Address')	{
                System.assert(true, 'Should not have returned Buyer Floor Plan Address as Send_Title_to_Buyer__c=true');
            }            
        }
        
        System.assertEquals(pl.addressOptions.size(), addrCounter, 'There should be 3 address processed.');

        Test.stopTest();
    }    
}