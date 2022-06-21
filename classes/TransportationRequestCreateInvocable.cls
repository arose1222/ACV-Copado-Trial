public class TransportationRequestCreateInvocable {
    
    private static string endpointURL = '/api/v1/transportation/create';

    @InvocableMethod 
    public static List<TransportationFlowResult> TransportationRequestCreate(List<Case> inputList){
        Case inputCase = inputList[0];
        Contact pickupContact;
        Contact deliveryContact;

        System.debug(inputCase.Seller_Contact__c);
        System.debug(inputCase.ContactId);
        if(inputCase.Seller_Contact__c != null){
            pickupContact = [Select id, Name, Email, Phone From Contact Where id = :inputCase.Seller_Contact__c];
        }
        if(inputCase.ContactId != null){
            deliveryContact = [Select id, Name, Email, Phone From Contact Where id = :inputCase.ContactId];
        }
        System.debug(pickupContact);
        System.debug(deliveryContact);

        if(inputCase.Auction_Number__c != null){
            Auction__c auctionData = [Select id, id__c, Release_Pickup_Phrase__c, vehicle_id__c, vehicle_id__r.vin__c, vehicle_id__r.year__c, vehicle_id__r.make__c, vehicle_id__r.model__c,
            vehicle_id__r.trim__c, vehicle_id__r.class_name__c, vehicle_id__r.Vehicle_Is_Oversize__c, ACV_inop__c, Seller_Dealership__r.Dealership_id__c, buyer_dealership__r.Dealership_Id__c,
            Seller_Dealership__r.Primary_Contact__r.Name, Seller_Dealership__r.Primary_Contact__r.Phone, Seller_Dealership__r.Primary_Contact__r.Email,  buyer_dealership__r.Primary_Contact__r.Name, 
            buyer_dealership__r.Primary_Contact__r.Phone, buyer_dealership__r.Primary_Contact__r.Email, Seller_Inventory_Id__c From Auction__c Where id = :inputCase.Auction_Number__c];
            TransportationRequestCreateObject trco = convertCaseToCalloutObject(inputCase, auctionData, pickupContact, DeliveryContact);
            List<TransportationFlowResult> result = runCalloutLogic(trco);
            return result;
            }
        else{
            Vehicle__c vehicleData = [Select Name, year__c, make__c, model__c, trim__c, class_name__c, Vehicle_Is_Oversize__c From vehicle__c Where id = :inputCase.vehicle__c];
            Account pickupDealer = [Select id, Name, Dealership_Id__c From Account where id = :inputCase.Seller_Dealership__c];
            Account deliveryDealer = [Select id, Name, Dealership_Id__c From Account where id = :inputCase.AccountId];
            TransportationRequestCreateObject trco = convertCaseToNonCaptiveCalloutObject(inputCase, vehicleData, pickupContact, DeliveryContact, pickupDealer, deliveryDealer);
            List<TransportationFlowResult> result = runCalloutLogic(trco);
            return result;
        }
        

    }
    private static List<TransportationFlowResult> runCalloutLogic(TransportationRequestCreateObject inputRequest){
            // List<TransportationFlowResult> newResult = new List<TransportationFlowResult>();
            // TransportationFlowResult r = new TransportationFlowResult();
            // r.resCode = '400';
            // r.legacyId = '123';
            // r.transpoGuid = 'guid-1234';
            // r.errorMessage = 'Zip Code is invalid';
            // newResult.add(r);
            // return newResult;
            // Response will have status as well, need to apply this to the case status 
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http h = new Http();
            req.setMethod('POST');
            req.setEndpoint( 'callout:Salesforce_Gateway' + endpointURL );
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', '{!$Credential.Password}');
            req.setTimeout(120000);
            req.setBody(JSON.serialize(inputRequest));
            try{
                res = h.send(req);
            }
            catch(Exception e){
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber());
            }
            if(res.getStatusCode() >= 200 && res.getStatusCode() < 300){
                TransportationSuccessObject tso = TransportationSuccessObject.parse(res.getBody());

                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.INFO, ACVUtility.currentLineNumber());

                List<TransportationFlowResult> newResult = new List<TransportationFlowResult>();
                TransportationFlowResult r = new TransportationFlowResult();
                r.resCode = string.valueOf(res.getStatusCode());
                r.legacyId = string.valueOf(tso.data.acvLegacyTransportId);
                r.transpoGuid = tso.data.id;
                r.distance = tso.data.distance;
                System.debug(tso.data.status);
                if(tso.data.status == 'Ready-to-Post'){
                    r.status = 'Ready-to-Post';
                }
                else{
                    r.status = 'Awaiting Release';
                }
                System.debug(r);
                newResult.add(r);
                return newResult;
                // return new list<string>{String.valueOf(tso.data.acvLegacyTransportId),tso.data.id};
            }
            else{
                TransportationErrorObject teo = TransportationErrorObject.parse(res.getBody());
                
                sendHTTPLog(req,res, SplunkHelper.LOGLEVEL.ERROR, ACVUtility.currentLineNumber());

                List<TransportationFlowResult> newResult = new List<TransportationFlowResult>();
                TransportationFlowResult r = new TransportationFlowResult();
                r.resCode = string.valueOf(res.getStatusCode());
                r.errorMessage = teo.errors[0];
                newResult.add(r);
                return newResult;
            }
    }
    private static void sendHTTPLog(HttpRequest req, HttpResponse res, SplunkHelper.LOGLEVEL logLevel, Integer lineNumber){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'TransportationRequestCreateInvocable:' + lineNumber;
        infoLog.message = res.getStatus();
        infoLog.stackTrace = 'TransportationRequestCreateInvocable: '+lineNumber;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'TransportationRequestCreateInvocable';
        infoLog.sfObject = 'Case';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.POST_TRANSACTION};
        //SplunkHelper.buildandProcessLog( infoLog );
        SplunkHelper.buildAndProcessIntegrationLog(infoLog, req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
    }

    private static TransportationRequestCreateObject convertCaseToCalloutObject(Case inputCase, Auction__c auctionData, Contact pickupContact, Contact deliveryContact){
        TransportationRequestCreateObject returnObject = new TransportationRequestCreateObject();

        returnObject.requestType = 'OUT_OF_APP';
        //REQ - not the case anymore
        // returnObject.acvLegacyTransportId;
        returnObject.acvAuctionId = auctionData.id__c;
        returnObject.notes = inputCase.Transportation_Notes__c;
        //REQ
        returnObject.priceCustomerPrePromotion = inputCase.Buyer_Price__c;
        returnObject.priceCustomerCharged = inputCase.Price_Pre_Promotion__c;
        //REQ
        returnObject.releaseSecretPhrase = auctionData.Release_Pickup_Phrase__c;
        returnObject.vehicle = new TransportationRequestCreateObject.vehicle();
        //REQ
        returnObject.vehicle.vin = auctionData.vehicle_id__r.vin__c;
        //REQ
        returnObject.vehicle.year = string.isNotBlank(auctionData.vehicle_id__r.year__c) ? integer.valueOf(auctionData.vehicle_id__r.year__c) : null;
        //REQ
        returnObject.vehicle.make = auctionData.vehicle_id__r.make__c;
        //REQ
        returnObject.vehicle.model = auctionData.vehicle_id__r.model__c;
        returnObject.vehicle.trim = auctionData.vehicle_id__r.trim__c;
        returnObject.vehicle.className = auctionData.vehicle_id__r.class_name__c;
        returnObject.vehicle.isOversize = auctionData.vehicle_id__r.Vehicle_Is_Oversize__c;
        returnObject.vehicle.isInoperable = auctionData.ACV_inop__c;
        
        returnObject.pickupLocation = new TransportationRequestCreateObject.pickupLocation();
        // REQ
        returnObject.pickupLocation.dealershipId = integer.valueOf(auctionData.Seller_Dealership__r.Dealership_id__c);
        //REQ
        returnObject.pickupLocation.addressName = inputCase.Pickup_Address_Name__c;
        //REQ
        returnObject.pickupLocation.addressLineOne = inputCase.Pickup_Address__c;
        // returnObject.addressLineTwo 
        // returnObject.addressLineThree 
        // returnObject.addressLineFour 
        //REQ
        returnObject.pickupLocation.addressCity = inputCase.Default_Pickup_City__c;
        //REQ
        returnObject.pickupLocation.addressRegion = inputCase.Default_Pickup_State__c;
        //REQ
        returnObject.pickupLocation.addressPostalCode = inputCase.Default_Pickup_Postal_Code__c;
        //REQ
        returnObject.pickupLocation.addressCountry = inputCase.Default_Pickup_Country__c;
        returnObject.pickupLocation.contactName = auctionData.Seller_Dealership__r.Primary_Contact__r.Name;
        returnObject.pickupLocation.contactPhone = auctionData.Seller_Dealership__r.Primary_Contact__r.Phone;
        returnObject.pickupLocation.contactEmail = auctionData.Seller_Dealership__r.Primary_Contact__r.Email;
        returnObject.pickupLocation.inventoryId = auctionData.Seller_Inventory_Id__c;
        returnObject.pickupLocation.notes = inputCase.Seller_Pick_Up_Notes__c;
        if(pickupContact != null){
            returnObject.pickupLocation.contactName = pickupContact.Name;        
            returnObject.pickupLocation.contactPhone = pickupContact.Phone;
            returnObject.pickupLocation.contactEmail = pickupContact.Email;
        }
        else{
            returnObject.pickupLocation.contactName = inputCase.Seller_Name__c;        
            returnObject.pickupLocation.contactPhone = inputCase.Seller_Contact_Phone__c;
            returnObject.pickupLocation.contactEmail = inputCase.Seller_Contact_Email__c;
        }

        returnObject.deliveryLocation = new TransportationRequestCreateObject.deliveryLocation();
        //REQ
        returnObject.deliveryLocation.dealershipId = integer.valueOf(auctionData.buyer_Dealership__r.Dealership_id__c);
        //REQ
        returnObject.deliveryLocation.addressName = inputCase.Delivery_Address_Name__c;
        //REQ
        returnObject.deliveryLocation.addressLineOne = inputCase.Default_Delivery_Address__c;
        // returnObject.addressLineTwo 
        // returnObject.addressLineThree 
        // returnObject.addressLineFour 
        //REQ
        returnObject.deliveryLocation.addressCity = inputCase.Default_Delivery_City__c;
        //REQ
        returnObject.deliveryLocation.addressRegion = inputCase.Default_Delivery_State__c;
        //REQ
        returnObject.deliveryLocation.addressPostalCode = inputCase.Default_Delivery_Postal_Code__c;
        //REQ
        returnObject.deliveryLocation.addressCountry = inputCase.Default_Delivery_Country__c;
        if(deliveryContact != null){
            returnObject.deliveryLocation.contactName = deliveryContact.Name;        
            returnObject.deliveryLocation.contactPhone = deliveryContact.Phone;
            returnObject.deliveryLocation.contactEmail = deliveryContact.Email;
        }
        else{
            returnObject.deliveryLocation.contactName = inputCase.Buyer_Name__c;        
            returnObject.deliveryLocation.contactPhone = inputCase.ContactPhone;
            returnObject.deliveryLocation.contactEmail = inputCase.ContactEmail;
        }

        //There wont be an inventory Id for the buyer since we have seller inventory id ONLY
        // returnObject.deliveryLocation.inventoryId = 
        returnObject.deliveryLocation.notes = inputCase.Buyer_Pickup_Notes__c;
        return returnObject;
    }
    private static TransportationRequestCreateObject convertCaseToNonCaptiveCalloutObject(Case inputCase, Vehicle__c vehicleData, Contact pickupContact, Contact deliveryContact, Account pickupDealer, Account deliveryDealer){
        TransportationRequestCreateObject returnObject = new TransportationRequestCreateObject();

        returnObject.requestType = 'NON_CAPTIVE';
        //REQ - not the case anymore
        // returnObject.acvLegacyTransportId;
        // returnObject.acvAuctionId = auctionData.id__c;
        returnObject.notes = inputCase.Transportation_Notes__c;
        //REQ
        returnObject.priceCustomerPrePromotion = inputCase.Buyer_Price__c;
        returnObject.priceCustomerCharged = inputCase.Price_Pre_Promotion__c;
        //REQ
        // returnObject.releaseSecretPhrase = auctionData.Release_Pickup_Phrase__c;
        returnObject.vehicle = new TransportationRequestCreateObject.vehicle();
        //REQ
        returnObject.vehicle.vin = vehicleData.Name;
        //REQ
        returnObject.vehicle.year = string.isNotBlank(vehicleData.year__c) ? integer.valueOf(vehicleData.year__c) : null;
        //REQ
        returnObject.vehicle.make = vehicleData.make__c;
        //REQ
        returnObject.vehicle.model = vehicleData.model__c;
        returnObject.vehicle.trim = vehicleData.trim__c;
        returnObject.vehicle.className = vehicleData.class_name__c;
        returnObject.vehicle.isOversize = vehicleData.Vehicle_Is_Oversize__c;
        returnObject.vehicle.isInoperable = inputCase.Inop__c;
        
        returnObject.pickupLocation = new TransportationRequestCreateObject.pickupLocation();
        // REQ
        returnObject.pickupLocation.dealershipId = integer.valueOf(pickupDealer.Dealership_id__c);
        //REQ
        returnObject.pickupLocation.addressName = inputCase.Pickup_Address_Name__c;
        //REQ
        returnObject.pickupLocation.addressLineOne = inputCase.Pickup_Address__c;
        // returnObject.addressLineTwo 
        // returnObject.addressLineThree 
        // returnObject.addressLineFour 
        //REQ
        returnObject.pickupLocation.addressCity = inputCase.Default_Pickup_City__c;
        //REQ
        returnObject.pickupLocation.addressRegion = inputCase.Default_Pickup_State__c;
        //REQ
        returnObject.pickupLocation.addressPostalCode = inputCase.Default_Pickup_Postal_Code__c;
        //REQ
        returnObject.pickupLocation.addressCountry = inputCase.Default_Pickup_Country__c;
        returnObject.pickupLocation.notes = inputCase.Seller_Pick_Up_Notes__c;
        if(pickupContact != null){
            returnObject.pickupLocation.contactName = pickupContact.Name;        
            returnObject.pickupLocation.contactPhone = pickupContact.Phone;
            returnObject.pickupLocation.contactEmail = pickupContact.Email;
        }
        else{
            returnObject.pickupLocation.contactName = inputCase.Seller_Name__c;        
            returnObject.pickupLocation.contactPhone = inputCase.Seller_Contact_Phone__c;
            returnObject.pickupLocation.contactEmail = inputCase.Seller_Contact_Email__c;
        }

        returnObject.deliveryLocation = new TransportationRequestCreateObject.deliveryLocation();
        //REQ
        returnObject.deliveryLocation.dealershipId = integer.valueOf(deliveryDealer.Dealership_id__c);
        //REQ
        returnObject.deliveryLocation.addressName = inputCase.Delivery_Address_Name__c;
        //REQ
        returnObject.deliveryLocation.addressLineOne = inputCase.Default_Delivery_Address__c;
        // returnObject.addressLineTwo 
        // returnObject.addressLineThree 
        // returnObject.addressLineFour 
        //REQ
        returnObject.deliveryLocation.addressCity = inputCase.Default_Delivery_City__c;
        //REQ
        returnObject.deliveryLocation.addressRegion = inputCase.Default_Delivery_State__c;
        //REQ
        returnObject.deliveryLocation.addressPostalCode = inputCase.Default_Delivery_Postal_Code__c;
        //REQ
        returnObject.deliveryLocation.addressCountry = inputCase.Default_Delivery_Country__c;
        if(deliveryContact != null){
            returnObject.deliveryLocation.contactName = deliveryContact.Name;        
            returnObject.deliveryLocation.contactPhone = deliveryContact.Phone;
            returnObject.deliveryLocation.contactEmail = deliveryContact.Email;
        }
        else{
            returnObject.deliveryLocation.contactName = inputCase.Buyer_Name__c;        
            returnObject.deliveryLocation.contactPhone = inputCase.ContactPhone;
            returnObject.deliveryLocation.contactEmail = inputCase.ContactEmail;
        }

        //There wont be an inventory Id for the buyer since we have seller inventory id ONLY
        // returnObject.deliveryLocation.inventoryId = 
        returnObject.deliveryLocation.notes = inputCase.Buyer_Pickup_Notes__c;
        return returnObject;
    }
    public class TransportationFlowResult{
        @invocableVariable
        public string resCode;
        @invocableVariable
        public string legacyId;
        @invocableVariable
        public string transpoGuid;
        @invocableVariable
        public string errorMessage;
        @invocableVariable
        public Integer distance;
        @invocableVariable
        public string status;   
    } 
}