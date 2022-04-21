public class TitlesShippingAutomation{

    /**
     *
     */
    public static void validateSendingLabel(List<Id> CaseIDList){
        List<Floor_Plan_Setting__mdt> floorplanMapping = [select id, Send_Title_to_Buyer__c, Payment_Method_API_Name__c, Name__c, Company__c, Street1__c, Street2__c, City__c, State__c, Zip__c, 
        Country__c, Phone__c, Email__c 
        from Floor_Plan_Setting__mdt];
        List<String> blockedRegionList = TitlesAPI.getAllBlockedRegions();
        List<Case> sendToBuyerCaseList = new List<Case>();
        List<Case> sendToFloorPlanCaseList = new List<Case>();
        List<Case> sendToHoldList = new List<Case>();
        List<Case> finalUpdateList = new List<Case>();
        List<Case> sendToACVCaseList = new List<Case>();
        for (Case c :[select id, Digital_Title__c, Hold_For_Payment__c, Account.BillingState,Auction_Number__r.payment_method__c,Auction_Number__r.payment_status__c,
        Account.BillingStreet, Account.BillingPostalCode, Account.Name,Account.Phone, Easypost_Tracker__c, Account.BillingCity,
        Seller_Dealership__r.BillingStreet, Seller_Dealership__r.BillingState, Seller_Dealership__r.BillingCity, Seller_Dealership__r.BillingPostalCode, Seller_Dealership__r.Name,Seller_Dealership__r.Phone,
        Account.Title_Mailing_City__c, Account.Title_Mailing_Country__c, Account.Title_Mailing_State__c, Account.Title_Mailing_Street__c, Account.Title_Mailing_Zip_Code__c,
        Seller_Dealership__r.Title_Mailing_Street__c, Seller_Dealership__r.Title_Mailing_State__c, Seller_Dealership__r.Title_Mailing_City__c, Seller_Dealership__r.Title_Mailing_Zip_Code__c
        from case where id in :CaseIDList]) {
            if (floorPlanProcessing(c, floorplanMapping) != 'floorplan' && String.isNotBlank(c.Account.BillingState) & String.isNotBlank(c.Auction_Number__r.payment_status__c) & String.isNotBlank(c.Auction_Number__r.payment_Method__c) & blockedRegionList.contains(c.Account.BillingState) && isPaidFor(c.Auction_Number__r.payment_status__c, c.Auction_Number__r.payment_Method__c)){
                sendToACVCaseList.add(c);
            }
            if (achCheckProcessing(c)){
                sendToBuyerCaseList.add(c);
            }
            else{
                String floorPlanResult = floorPlanProcessing(c, floorplanMapping);
                if(floorPlanResult == 'buyer'){
                    sendToBuyerCaseList.add(c);
                }
                else if(floorPlanResult == 'floorplan'){
                    sendToFloorPlanCaseList.add(c);
                }
                else if(floorPlanResult == 'Hold'){
                    sendToHoldList.add(c);
                }
                /*else if(floorPlanResult == ''){
                    c.Digital_Title_Problem__c = true;
                    c.Digital_Title_Problem_Reason__c = 'Floorplan not configured';
                    sendToHoldList.add(c);
                }*/
            }
        }


        if(sendToHoldList.size() > 0){
            for(Case c :sendToHoldList){
                c.Hold_For_Payment__c = system.today().addDays(5);
                finalUpdateList.add(c);
            }
        }

        //generateShippingLabels
        Map<Id, EasyPostShipmentRequest> caseToAddressMap = new Map<Id, EasyPostShipmentRequest>();
        if(sendToBuyerCaseList.size() > 0){
            for(Case c :sendToBuyerCaseList){
                EasyPostShipmentRequest epShipment = new EasyPostShipmentRequest();
                epShipment.shipment = new EasyPostShipmentRequest.Shipment();
                //added logic to the line below to account for Title Address information
                epShipment.shipment.To_address = String.isBlank(c.Account.Title_Mailing_Street__c) ? generateToAddress(c.Account.Name, c.Account.BillingStreet, c.Account.BillingCity, c.Account.BillingState, 'US', c.Account.BillingPostalCode, c.Account.Phone) : generateToAddress(c.Account.Name, c.Account.Title_Mailing_Street__c, c.Account.Title_Mailing_City__c, c.Account.Title_Mailing_State__c, 'US', c.Account.Title_Mailing_Zip_Code__c, c.Account.Phone);
                epShipment.shipment.From_address = String.isBlank(c.Seller_Dealership__r.Title_Mailing_Street__c) ? generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.BillingStreet, c.Seller_Dealership__r.BillingCity, c.Seller_Dealership__r.BillingState, 'US', c.Seller_Dealership__r.BillingPostalCode, c.Seller_Dealership__r.Phone) : generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.Title_Mailing_Street__c, c.Seller_Dealership__r.Title_Mailing_City__c, c.Seller_Dealership__r.Title_Mailing_State__c, 'US', c.Seller_Dealership__r.Title_Mailing_Zip_Code__c, c.Seller_Dealership__r.Phone);
                epShipment.shipment.parcel = new EasyPostShipmentRequest.Parcel();
                //epShipment.shipment.parcel.predefined_package = 'FedExEnvelope'; 
                epShipment.shipment.parcel.weight = 10; 
                caseToAddressMap.put(c.id,epShipment);
            }
        }
        if(sendToFloorPlanCaseList.size() > 0){
            Map<String, Floor_Plan_Setting__mdt> fpMap = createFloorPlanMapFromList(floorplanMapping);
            for(Case c :sendToFloorPlanCaseList){
                EasyPostShipmentRequest epShipment = new EasyPostShipmentRequest();
                if ( fpMap.get(c.Auction_Number__r.Payment_Method__c) == null ) {
                    /*c.Digital_Title_Problem__c = true;
                    c.Digital_Title_Problem_Reason__c = 'The Payment Method/Floorplan is not configured';
                    finalUpdateList.add(c);*/
                } else {
                    Floor_Plan_Setting__mdt fp = fpMap.get(c.Auction_Number__r.Payment_Method__c);
                    epShipment.shipment = new EasyPostShipmentRequest.Shipment();
                    epShipment.shipment.To_address = generateToAddress(fp.Name__c, fp.Company__c, fp.Street1__c, fp.Street2__c, fp.City__c, fp.State__c, fp.Country__c, fp.Zip__c, fp.Phone__c);
                    epShipment.shipment.From_address = String.isBlank(c.Seller_Dealership__r.Title_Mailing_Street__c) ? generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.BillingStreet, c.Seller_Dealership__r.BillingCity, c.Seller_Dealership__r.BillingState, 'US', c.Seller_Dealership__r.BillingPostalCode, c.Seller_Dealership__r.Phone) : generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.Title_Mailing_Street__c, c.Seller_Dealership__r.Title_Mailing_City__c, c.Seller_Dealership__r.Title_Mailing_State__c, 'US', c.Seller_Dealership__r.Title_Mailing_Zip_Code__c, c.Seller_Dealership__r.Phone);
                    epShipment.shipment.parcel = new EasyPostShipmentRequest.Parcel();
                    //epShipment.shipment.parcel.predefined_package = 'FedExEnvelope'; 
                    epShipment.shipment.parcel.weight = 10;
                    caseToAddressMap.put(c.id,epShipment);
                }
            }
            //do logic to get floor plan address
        }
        if(sendToACVCaseList.size() > 0){
            for(case c:sendToACVCaseList){
                EasyPostShipmentRequest epShipment = new EasyPostShipmentRequest();
                epShipment.shipment = new EasyPostShipmentRequest.Shipment();
                epShipment.shipment.To_address = generateACVToAddress();
                epShipment.shipment.From_address = String.isBlank(c.Seller_Dealership__r.Title_Mailing_Street__c) ? generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.BillingStreet, c.Seller_Dealership__r.BillingCity, c.Seller_Dealership__r.BillingState, 'US', c.Seller_Dealership__r.BillingPostalCode, c.Seller_Dealership__r.Phone) : generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.Title_Mailing_Street__c, c.Seller_Dealership__r.Title_Mailing_City__c, c.Seller_Dealership__r.Title_Mailing_State__c, 'US', c.Seller_Dealership__r.Title_Mailing_Zip_Code__c, c.Seller_Dealership__r.Phone);
                epShipment.shipment.parcel = new EasyPostShipmentRequest.Parcel();
                //epShipment.shipment.parcel.predefined_package = 'FedExEnvelope'; 
                epShipment.shipment.parcel.weight = 10; 
                caseToAddressMap.put(c.id,epShipment);
            }
        }

        if(caseToAddressMap.size() > 0){
            finalUpdateList.addAll(generateShippingLabel(caseToAddressMap));
        }

        if(finalUpdateList.size()>0){
            update finalUpdateList;
        }
        
            //case put into working status auto generate shipping label(use this logic to see if we can generate the label)
            //build custom metadata to hold floor plan -> shipping to options(to buyer or floor plan) also look for approved payment status
            //need a trigger that looks for payment status update to auto generate the shipping label
            //need a batch to go through and look for "expired" cases that will update the shipping to be to ACV and payment status != paid, deposited or approved
            //default to ACV capital
    }

    public static List<Case> generateShippingLabel(Map<Id,EasyPostShipmentRequest> shipMap){
        List<Case> caseList = new List<Case>();
        for(Id ship : shipMap.keySet()){
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('callout:EasyPost/v2/shipments');
            request.setHeader('Authorization', '{!$Credential.Password}');
            request.setBody(System.JSON.serialize(shipMap.get(ship)));
            request.setTimeout(60000);
            request.setHeader('Content-Type', 'application/json');
            HttpResponse response = new Http().send(request);

            EasyPostShipmentResponse EPResponse = EasyPostShipmentResponse.parse(response.getBody());
            String rateId = '';
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                for(EasyPostShipmentResponse.Rates rate : EPResponse.Rates){
                    if(rate.service == 'STANDARD_OVERNIGHT'){
                        rateId = rate.id;
                    }
                    makeLog(request, response, ACVUtility.currentLineNumber(), 'TitlesShippingAutomation.generateShippingLabel', SplunkHelper.LOGLEVEL.INFO, response.getStatus());
                }

                // No STANDARD_OVERNIGHT available then use PRIORITY
                if(rateId == ''){
                    for(EasyPostShipmentResponse.Rates rate : EPResponse.Rates){
                        if(rate.service == 'PRIORITY_OVERNIGHT'){
                            rateId = rate.id;
                        }
                    }
                }
                if(rateId != ''){
                    Http h2 = new Http();
                    HttpRequest request2 = new HttpRequest();
                    request2.setMethod('POST');
                    request2.setEndpoint('callout:EasyPost/v2/shipments/'+EPResponse.id+'/buy');
                    request2.setHeader('Authorization', '{!$Credential.Password}'+':');
                    request2.setBody('{"rate":{"id":"'+rateId+'"}}');
                    request2.setTimeout(60000);
                    request2.setHeader('Content-Type', 'application/json');
                    HttpResponse response2 = h2.send(request2);
                    if(response2.getStatusCode() == 200 || response2.getStatusCode() == 201){
                        EasyPostShipmentBuyResponse buyResponse = EasyPostShipmentBuyResponse.parse(response2.getBody());
                        caseList.add(new Case(Id = ship,Easypost_Tracker__c = buyResponse.tracking_code, Easypost_PostageLabel_Label_URL__c = buyResponse.postage_label.label_url, Digital_Title_Problem_Reason__c = '', Digital_Title_Problem__c = false));
                        makeLog(request2, response2, ACVUtility.currentLineNumber(), 'TitlesShippingAutomation.generateShippingLabel', SplunkHelper.LOGLEVEL.INFO, response2.getStatus());
                    }
                    /*else{
                        caseList.add(new Case(Id = ship, Digital_Title_Problem__c = true, Digital_Title_Problem_Reason__c = 'Easy Post Error', Title_Problems_Date__c = system.today()));
                        makeLog(request2, response2, ACVUtility.currentLineNumber(), 'TitlesShippingAutomation.generateShippingLabel', SplunkHelper.LOGLEVEL.ERROR, 'Easy Post Error');
                    }*/
                }
                /*else{
                    caseList.add(new Case(Id = ship, Digital_Title_Problem__c = true, Digital_Title_Problem_Reason__c = 'No Acceptable Rate', Title_Problems_Date__c = system.today()));
                    makeLog(request, response, ACVUtility.currentLineNumber(), 'TitlesShippingAutomation.generateShippingLabel', SplunkHelper.LOGLEVEL.ERROR, 'No Acceptable Rate');
                }*/
            }
            /*else{
                caseList.add(new Case(Id = ship, Digital_Title_Problem__c = true, Digital_Title_Problem_Reason__c = 'Easy Post Error',Title_Problems_Date__c = system.today()));
                makeLog(request, response, ACVUtility.currentLineNumber(), 'TitlesShippingAutomation.generateShippingLabel', SplunkHelper.LOGLEVEL.ERROR, 'Easy Post Error');
            }*/
        }
        return caseList;
    }

    public static void makeLog(HttpRequest request, HttpResponse result, Integer lineNumber, String stackTrace, SplunkHelper.LOGLEVEL LogLevel, String message){
        SplunkHelper.Log infoLog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = 'TitlesShippingAutomation:' + lineNumber;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = 'TitlesShippingAutomation';
        infoLog.sfObject = 'Case';
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.POST_TRANSACTION};
        SplunkHelper.processIntegrationLog(infoLog, request, result, SplunkHelper.INTEGRATION_DIRECTION.INBOUND );
    }

    public static Boolean achCheckProcessing(Case c){
        if(c.Auction_Number__r.payment_method__c== 'ach' && isPaidFor(c.Auction_Number__r.payment_status__c, c.Auction_Number__r.payment_method__c)){
            return true;
        }
        else if(c.Auction_Number__r.payment_method__c== 'check' && isPaidFor(c.Auction_Number__r.payment_status__c, c.Auction_Number__r.payment_method__c)){
            return true;
        }
        else{
            return false;
        }
    }

    public static String floorPlanProcessing(Case c, List<Floor_Plan_Setting__mdt> fpm){
        for(Floor_Plan_Setting__mdt fp :fpm){
            if(String.isNotBlank(c.Auction_Number__r.payment_method__c) && c.Auction_Number__r.payment_method__c == fp.Payment_Method_API_Name__c){
                if(isPaidFor(c.Auction_Number__r.payment_status__c, c.Auction_Number__r.payment_method__c)){
                    if(fp.Send_Title_To_Buyer__c){
                        return 'buyer';
                    }
                    else{
                        return 'floorplan';
                    }
                }
                else{
                    return 'hold';
                }
            }
        }
        return '';
    }

    public static map<String,Floor_Plan_Setting__mdt> createFloorPlanMapFromList(List<Floor_Plan_Setting__mdt> input){
        Map<String, Floor_Plan_Setting__mdt> output = new Map<String, Floor_Plan_Setting__mdt>();
        for(Floor_Plan_Setting__mdt f :input){
            output.put(f.Payment_Method_API_Name__c, f);
        }
        return output;
    }

    /**
     * isPaidFor
     *  Check if the auction is paid for
     * @param  String paymentStatus     payment status of Auction
     * @param  String paymentMethod     payment method of Auction
     * @return  Boolean
     */
    public static boolean isPaidFor(String paymentStatus, String paymentMethod ) {
        List<String> paymentStatusLst = new List<String>{ 'Paid', 'Approved', 'to_be_floored', 'deposited', 'ta_on_file' };

        // ach_push payment method ignores this rule but other payment statuses must be in the paymentStatusLst
        if ( String.isNotBlank(paymentStatus) &&  paymentStatusLst.contains(paymentStatus) || paymentMethod == 'ach_push' ) {
            return true;
        }
        return false;
    }

    public static EasyPostShipmentRequest.To_address generateToAddress(String name, String Company, String Street, String Street2, String City, String State, String Country, String zip, String phone){
        EasyPostShipmentRequest.To_address address = generateToAddress(name, Street, City, State, Country, zip, phone);
        address.street2 = Street2;
        address.company = Company;
        return address;
    }

    public static EasyPostShipmentRequest.To_address generateToAddress(String name, String Street, String City, String State, String Country, String zip, String phone){
        EasyPostShipmentRequest.To_address address = new EasyPostShipmentRequest.To_address();
        address.name = name;
        address.street1 = Street;
        address.city = City;
        address.state = State;
        address.country = Country;
        address.zip = zip;
        address.phone = String.isNotBlank(phone) ? phone: '8005534070';

        return address;
    }


    public static EasyPostShipmentRequest.From_address generateFromAddress(String name, String Street, String City, String State, String Country, String zip, String phone){
        EasyPostShipmentRequest.From_address address = new EasyPostShipmentRequest.From_address();
        address.name = name;
        address.street1 = Street;
        address.city = City;
        address.state = State;
        address.country = Country;
        address.zip = zip;
        address.phone = String.isNotBlank(phone) ? phone: '8005534070';

        return address;
    }


    public static EasyPostShipmentRequest.To_address generateACVToAddress(){
        return generateToAddress('','ACV Auctions & ACV Transport, LLC.', '640 Ellicott St','suite 321', 'Buffalo', 'NY', 'US', '14203', '8005534070');
    }
}