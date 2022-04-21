/**
 * @description A supporting component that is used by DisplayRelatedFields LWC. 
 * 				DisplayRelatedFields LWC is used to display related fields in the specified order.
 * 				Requirements: https://acvauctions.atlassian.net/browse/TDO-473
 * 
 *              It is using 'Unit_Tests' record in Display_Related_Fields__mdt Custom Metadata.
 * 
 * @author Manmeet Vaseer
 * @date 09/24/2021
 * 
 */
@isTest
public class DisplayRelatedFieldsControllerTest {

    @isTest
    static void testGetFieldLabelValuePairs()	{
        Test.startTest();
                
        String acctUniqueName = 'Test EasyPostControllerTest';
        Account newAcct = TestUtility.createAccount(acctUniqueName);        
        Contact newContact = TestUtility.createContact(newAcct);
        Vehicle__c newVehicle = TestUtility.createVehicle();
        
        Auction__c newAuction = TestUtility.createAuction(newAcct, newContact, newVehicle);
        newAuction.end_time__c = System.today();
        newAuction.Payment_Status__c='Paid';
        newAuction.Payment_Method__c = 'adi';

        SObject[] newObjs = new SObject[] {newAcct, newContact, newVehicle, newAuction};
        insert newObjs;
        
		Case newTitleCase = TestUtility.createTitleCase(newAuction, newAcct, newContact);
        newTitleCase.Odometer_Reading__c = '123467';
        newTitleCase.AccountId = newAcct.Id;
		newTitleCase.Seller_Contact__c = newContact.Id;
        newTitleCase.Status = 'New';
        
        newObjs = new SObject[] {newTitleCase};
        insert newObjs;
        
        Quality_Control__c qc = new Quality_Control__c();
        qc.Case__c = newTitleCase.Id;
        insert qc;

        Test.stopTest();
        
        String recId = qc.Id;
        String metadataTypeRecName='Unit_Tests';
        String json = DisplayRelatedFieldsController.getFieldLabelValuePairs(recId, metadataTypeRecName);
        System.assert(!String.isBlank(json));
        
        List<DisplayRelatedFieldsController.Payload> fieldLableValuePairs = (List<DisplayRelatedFieldsController.Payload>)System.JSON.deserialize(json, List<DisplayRelatedFieldsController.Payload>.class);
        System.assertEquals(21, fieldLableValuePairs.size(), 'Total number of Label=Value pairs are incorrect.');
        Integer totalProcessed = 0;
        for(DisplayRelatedFieldsController.Payload pl : fieldLableValuePairs)	{
            if(pl.label == 'Odometer') {
                System.assertEquals(newTitleCase.Odometer_Reading__c, pl.value);
                totalProcessed = totalProcessed + 1;
            }
            else if(pl.label == 'Payment Status') {
                System.assertEquals(newAuction.Payment_Status__c, pl.value);
                totalProcessed = totalProcessed + 1;
            }
            else if(pl.label == 'Payment Method') {
                System.assertEquals(newAuction.Payment_Method__c, pl.value);
                totalProcessed = totalProcessed + 1;
            }
            else if(pl.label == 'Buyer Billing Street') {
                System.assertEquals(newAcct.BillingStreet, pl.value);
                totalProcessed = totalProcessed + 1;
            }
            else if(pl.label == 'Seller Contact Name') {
                System.assertEquals(newContact.firstName + ' ' + newContact.lastName, pl.value);
                totalProcessed = totalProcessed + 1;
            }
        }

        System.assertEquals(5, totalProcessed, 'Incorrect number of totalProcessed values.');        
    }
}