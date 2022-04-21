public class EasyPostComponentController {
    private Boolean genZPL = false;

    public EasyPostComponentController(Boolean foo) {
        this.genZPL = foo;
    }

    // EasyPostComponentController.main();
    /*public static void main() {
        String addr = '{"zip":"14228","street":"12 Test St","state":"NY","name":"Account Bulk#A (Auction Buyer)","country":"US","city":"Buffalo"}';
        EasyPostComponentController e = new EasyPostComponentController(false);
        e.generateLabel(addr, true);
    }*/
    
    public String generateLabel(String jsonAddress, Boolean needReturnAddressPostageLabel, String ownerName) {
        List<String> postageLabels = new List<String>();
        
        String shipTo = generateLabel(jsonAddress);
        postageLabels.add(shipTo);
        
        if(needReturnAddressPostageLabel)	{
            addressWrapper incomingAddy = (addressWrapper)System.JSON.deserialize(jsonAddress,addressWrapper.class);
            
            EasyPostShipmentRequest.From_Address fromAddy = new EasyPostShipmentRequest.From_Address();
            fromAddy.name = incomingAddy.name;
            fromAddy.company = incomingAddy.company;
            fromAddy.street1 = incomingAddy.street;
            fromAddy.street2 = incomingAddy.street2;
            fromAddy.city = incomingAddy.city;
            fromAddy.state = incomingAddy.state;
            fromAddy.country = incomingAddy.country;
            fromAddy.zip = incomingAddy.zip;
            fromAddy.phone = '8005534070';

            EasyPostShipmentRequest.To_Address toAddy = new EasyPostShipmentRequest.To_Address();
            if(!String.isBlank(ownerName)) toAddy.name = ownerName;
            toAddy.company = 'ACV Auctions & ACV Transport, LLC.';
            toAddy.street1 = '640 Ellicott St';
            toAddy.street2 = 'suite 321';
            toAddy.city = 'Buffalo';
            toAddy.state = 'NY';
            toAddy.country = 'US';
            toAddy.zip = '14203';
            toAddy.phone = '8005534070';
    
            String returnPostageLabel = generateLabel(fromAddy, toAddy);
        	postageLabels.add(returnPostageLabel);
        }
        
        return '[' + String.join(postageLabels, ',') + ']';
    }
    
    public String generateLabel(String jsonAddress) {
        addressWrapper incomingAddy = (addressWrapper)System.JSON.deserialize(jsonAddress,addressWrapper.class);
        
        //create from address
        EasyPostShipmentRequest.From_Address fromAddy = new EasyPostShipmentRequest.From_Address();
        //this line below controls the from address for ALL Easy Post APIs
        fromAddy.company = 'ACV Auctions & ACV Transport, LLC.';
        fromAddy.street1 = '640 Ellicott St';
        fromAddy.street2 = 'suite 321';
        fromAddy.city = 'Buffalo';
        fromAddy.state = 'NY';
        fromAddy.country = 'US';
        fromAddy.zip = '14203';
        fromAddy.phone = '8005534070';

        EasyPostShipmentRequest.To_Address toAddy = new EasyPostShipmentRequest.To_Address();
        toAddy.name = incomingAddy.name;
        toAddy.company = incomingAddy.company;
        toAddy.street1 = incomingAddy.street;
        toAddy.street2 = incomingAddy.street2;
        toAddy.city = incomingAddy.city;
        toAddy.state = incomingAddy.state;
        toAddy.country = incomingAddy.country;
        toAddy.zip = incomingAddy.zip;
        toAddy.phone = '8005534070';
        
        return generateLabel(fromAddy, toAddy);        
    }
    
    public String generateLabel(EasyPostShipmentRequest.From_Address fromAddy, EasyPostShipmentRequest.To_Address toAddy) {
        EasyPostShipmentRequest eps = new EasyPostShipmentRequest();

        EasyPostShipmentRequest.Parcel Parcel = new EasyPostShipmentRequest.Parcel();
        Parcel.predefined_package = 'FedExEnvelope';
        Parcel.weight = 10;

        // Get the current time
        Datetime dt = DateTime.now();

        //create full body
        eps.shipment = new EasyPostShipmentRequest.shipment();
        eps.shipment.parcel = Parcel;
        eps.shipment.To_Address = toAddy;
        eps.shipment.From_Address = fromAddy;
        eps.shipment.options = futureDate(dt);

        Http h = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('callout:EasyPost/v2/shipments' );
        request.setHeader('Authorization', '{!$Credential.Password}');
        request.setBody(System.JSON.serialize(eps));
        request.setTimeout(60000);
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = h.send(request);

        EasyPostShipmentResponse EPResponse = EasyPostShipmentResponse.parse(response.getBody());
        String rateId = '';
        String rateService = '';
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
            for(EasyPostShipmentResponse.Rates rate : EPResponse.Rates){
                if(rate.service == 'STANDARD_OVERNIGHT'){
                    rateId = rate.id;
                    rateService = rate.service;
                }
            }

            // No STANDARD_OVERNIGHT available then use PRIORITY
            if(rateId == ''){
                for(EasyPostShipmentResponse.Rates rate : EPResponse.Rates){
                    if(rate.service == 'PRIORITY_OVERNIGHT'){
                        rateId = rate.id;
                        rateService = rate.service;
                    }
                }
            }

            System.debug(rateId);

            if(rateId != ''){
                Http h2 = new Http();
                HttpRequest request2 = new HttpRequest();
                request2.setMethod('POST');
                request2.setEndpoint('callout:EasyPost/v2/shipments/' + EPResponse.id + '/buy');
                request2.setHeader('Authorization', '{!$Credential.Password}'+':');
                request2.setBody('{"rate":{"id":"'+rateId+'"}}');
                request2.setTimeout(60000);
                request2.setHeader('Content-Type', 'application/json');
                HttpResponse response2 = h2.send(request2);
                if(response2.getStatusCode() == 200 || response2.getStatusCode() == 201){
                    EasyPostShipmentBuyResponse buyResponse = EasyPostShipmentBuyResponse.parse(response2.getBody());
                    if (genZPL) {
                        EasyPostShipmentBuyResponse zplResponse = convertLabeltoZPL(EPResponse.id);
                        return '{"trackingCode":"'+ zplResponse.tracking_code +
                               '","link":"'+ zplResponse.postage_label.label_url +
                               '","label_zpl_url":"' + zplResponse.postage_label.label_zpl_url + '"}';
                    }
                    String returnString = '{"trackingCode":"'+buyResponse.tracking_code+
                                          '","link":"'+buyResponse.postage_label.label_url+
                                          '","label_zpl_url":"'+buyResponse.postage_label.label_zpl_url+'"}';
                    return returnString;
                }
                else{
                    createSplunkLog(acvutility.currentLineNumber(), 
                                    'generateLabel()', 
                                    SplunkHelper.LOGLEVEL.ERROR, 'EasyPostComponentController', 
                                    response2.getBody(), 
                                    'Case/Quality Control');
                    return JSON.serialize(response2.getBody());
                }
            }
            else{
                return 'No STANDARD_OVERNIGHT or PRIORITY_OVERNIGHT Available';
            }
        }
        else{
            createSplunkLog(acvutility.currentLineNumber(), 
                            'generateLabel()', 
                            SplunkHelper.LOGLEVEL.ERROR, 'EasyPostComponentController', 
                            response.getBody(), 
                            'Case/Quality Control');
            return JSON.serialize(response.getBody());
        }
    }

    @AuraEnabled
    public static String GenerateShipping(string jsonAddress){
        EasyPostComponentController EPCC = new EasyPostComponentController(false);
        return EPCC.generateLabel(jsonAddress);
    }

    public EasyPostShipmentBuyResponse convertLabeltoZPL(String shipmentId){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint( 'callout:EasyPost/v2/shipments/'+shipmentId+'/label?file_format=ZPL' );
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setTimeout(60000);
        req.setHeader('Content-Type', 'application/json');
        HttpResponse resp = http.send(req);
        return EasyPostShipmentBuyResponse.parse(resp.getBody());
    }

    public static void createSplunkLog(Integer lineNumber,String stackTrace, SplunkHelper.LOGLEVEL LogLevel, String Location, String Message, String sfObject){
        SplunkHelper.Log infolog = new SplunkHelper.Log();
        infoLog.version = 'v1'; // We don't have versions yet
        infoLog.logLevel = LogLevel;
        infoLog.location = Location+ ':' + lineNumber;
        infoLog.message = message;
        infoLog.stackTrace = stackTrace;
        infoLog.sfRecordId = UserInfo.getUserId();
        infoLog.componentName = Location;
        infoLog.sfObject = sfObject;
        infoLog.domainSet = new Set<SplunkHelper.DOMAIN>{ SplunkHelper.DOMAIN.POST_TRANSACTION};
        System.debug(stackTrace);
        if(!Test.isRunningTest()){
        	SplunkHelper.buildAndProcessLog(infolog);
        }
    }
    
    /**
     * futureDate   Calculate if label should be generated for future date
     *
     * @param Datetime dt   Datetime to reference for setting date_advance option for EasyPost
     * @return EasyPostShipmentRequest.options
     */
    public EasyPostShipmentRequest.options futureDate(Datetime dt) {
        String dayOfWeek = dt.format('EEEE');
        Integer GMTHour = dt.hourGMT();
        Integer offSet = 0;

        if (ACVUtility.isDSTActiveInEST(dt)){
            offSet = 1;
        }

        EasyPostShipmentRequest.options Options = new EasyPostShipmentRequest.options();
        // If the label is generated after 1 pm EST on a Saturday, set date_advance two days forward
        if (dayOfWeek == 'Saturday' &&  GMTHour >= (17 + offSet) ) {
            Options.date_advance = 2;
        }
        // After 6 PM Est set date_advance to 1
        else if ( GMTHour >= (22 + offSet) ) {
            Options.date_advance = 1;
        }
        else {
            Options.date_advance = 0;
        }
        return Options;
    }

    public class addressWrapper{
        public string name;
        public string company;
        public string street;
        public string street2;
        public string city;
        public string state;
        public string country;
        public string zip;
    }
}