public class EasyPost_ShipmentController {

	public EasyPost_ShipmentController() {
		
	}

	@InvocableMethod
	public static void CreateEasyPostShipment(List<Id> caseId){
		List<Case> lTitleCases = [SELECT Id, Easypost_Parcel_Predefined_Package__c, Easypost_Parcel_Weight__c,
                          Default_Delivery_City__c,  Default_Delivery_Country__c, Buyer_Name__c, ContactPhone, Default_Delivery_State__c,
                         Default_Delivery_Address__c, Default_Delivery_Address_Line2__c, Default_Delivery_Postal_Code__c, EasyPost_Shipping_Service__c
                         FROM Case WHERE Id IN :caseId];
        System.debug('case: ' + lTitleCases);
        System.enqueueJob(New EasyPostQueueableJob('Create Shipment', lTitleCases, null));

	}

}