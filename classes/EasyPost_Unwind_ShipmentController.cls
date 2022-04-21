public  class EasyPost_Unwind_ShipmentController {

	@InvocableMethod
	public static void CreateEasyPostShipment_Unwind (List<Id> caseId) {
		List<Case> lUnwindCases = [SELECT Id, Easypost_Parcel_Predefined_Package__c, Easypost_Parcel_Weight__c,
                          Default_Pickup_City__c,  Default_Pickup_Country__c, Buyer_Name__c, ContactPhone, Default_Pickup_State__c,
                         Pickup_Address__c, Pick_Up_Address_Line_2__c, Default_Pickup_Postal_Code__c, EasyPost_Shipping_Service__c
                         FROM Case WHERE Id IN :caseId];
        System.debug('case: ' + lUnwindCases);
        System.enqueueJob(New EasyPostQueueableJob('Create Shipment Unwind', lUnwindCases, null));
	}
}