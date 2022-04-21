/**
 * @description A component to generate EasyPost tracking number and postage labels on Case & Quality Control objects.
 * 				Requirements: https://acvauctions.atlassian.net/browse/TDO-183
 * 
 * @author Manmeet Vaseer
 * @date 07/20/2021
 * 
 * @revision 08/17/2021 Added functionality for Buyer Floor Plan address (https://acvauctions.atlassian.net/browse/TDO-238).
 * 						Use Floor Plan address if 'Sent Title to Buyer' field is not checked in the Floor_Plan_Setting__mdt custom metadata.
 * 						Otherwise, use Buyer Address if 'Sent Title to Buyer' field is checked in the Floor_Plan_Setting__mdt.
 */
public class EasyPostController {
    public static String TITLE_INFO_RT = TitleStatusTransitionTriggerHandler.TITLE_INFO_RT;
    public static String[] USER_PROFILE_NAMES = TitleStatusTransitionTriggerHandler.USER_PROFILE_NAMES;

    /**
     * It is called by EasyPost LWC. It saves the tracking and postage label info in the Case or Quality Control object.
     * For Quality Control object, it generates the two tracking info. One for 'Ship To' and another for 'Return to ACV'.
     * 
     * @param recordId Case or Quality Control record Id
     * @param jsonShippingLabels JSON string that has tracking info. See EasyPost controller (under persistShippingLabels method) for a sample message.
     *                           The first JSON record has tracking info for 'Ship To' address.
     *                           The 2nd JSON record has tracking info for 'Return To ACV' address.
     * @param isQualityControl If true, recordId is for Quality Control object, otherwise it is for Case object.
     * @param buyerSellerIndicator Tells if the postage label is for buyer or seller. This paramerter 'contains' Buyer or Seller substring.
     * @param contactEmail 	External Email address of the dealership or floorplan. This email address will be used by the 
     * 						Workflow Rules (Return Postage Label Ready Email Notification Buyer & Return Postage Label Ready Email Notification FloorPlan) to send emails
     * 						with Return Postage Shipping Label link.
     * 
     * @return Always returns true unless an exception is thrown.
     */
    @AuraEnabled(cacheable=false)    
    public static Boolean saveShippingLabels(String recordId, String jsonShippingLabels, Boolean isQualityControl, String buyerSellerIndicator, String contactEmail, String contactName){
        if(String.isBlank(buyerSellerIndicator)) throw new AuraException('Missing buyerSellerIndicator parameter. It is a required parameter in saveShippingLabels() call.');
           
		Boolean isBuyer = false;
		if(buyerSellerIndicator.toLowerCase().contains('buyer')) isBuyer = true;
           
        List<SObject> updateObjs = new List<SObject>();
        
        Id titlesRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(TITLE_INFO_RT).getRecordTypeId();
        Map<ID, Profile> profiles = new Map<ID, Profile>([SELECT Id, Name FROM Profile WHERE Name IN :USER_PROFILE_NAMES]);
        
        List<TrackShipping> trackingInfo = (List<TrackShipping>)System.JSON.deserialize(jsonShippingLabels, List<TrackShipping>.class);

        if(isQualityControl)	{ 
            List<Quality_Control__c> qcRecs = [SELECT Id, Seller_To_ACV_Label__c, Seller_To_ACV_Tracking_Code__c, ACV_To_Seller_Label__c, ACV_To_Seller_Tracking_Code__c, 
                                               Buyer_To_ACV_Label__c, Buyer_To_ACV_Tracking_Code__c, ACV_To_Buyer_Label__c, ACV_To_Buyer_Tracking_Code__c,
                                               Case__r.Id, Case__r.Status, Case__r.Update_Status__c, Case__r.RecordTypeId FROM Quality_Control__c WHERE Id = :recordId];
            if(qcRecs != null && qcRecs.size() > 0)	{
                Quality_Control__c qcRec = qcRecs[0];
                if(trackingInfo.size() > 0)	{ // Update Ship To tracking info.
                    if(isBuyer)	{
                        qcRec.ACV_To_Buyer_Tracking_Code__c = trackingInfo[0].trackingCode;
                        qcRec.ACV_To_Buyer_Label__c = trackingInfo[0].link;
                    }
                    else {
                        qcRec.ACV_To_Seller_Tracking_Code__c = trackingInfo[0].trackingCode;
                        qcRec.ACV_To_Seller_Label__c = trackingInfo[0].link;                        
                    }
                }
                if(trackingInfo.size() > 1)	{ // Update Retrun Address tracking info.
                    if(isBuyer)	{
                        qcRec.Buyer_To_ACV_Tracking_Code__c = trackingInfo[1].trackingCode;
                        qcRec.Buyer_To_ACV_Label__c = trackingInfo[1].link;
                        
                        // Trigger Workflow Rule
                        qcRec.Return_Postage_Label_Email__c = null;
                        qcRec.Return_Postage_Label_Contact_Name__c = null;
                        qcRec.Send_Postage_Email_To_Buyer__c = false;
                        if(!String.isBlank(contactEmail))	{
                            qcRec.Return_Postage_Label_Email__c = contactEmail;
                            qcRec.Return_Postage_Label_Contact_Name__c = contactName;
                            qcRec.Send_Postage_Email_To_Buyer__c = true;
                        }                        
                    }
                    else {
                        qcRec.Seller_To_ACV_Tracking_Code__c = trackingInfo[1].trackingCode;
                        qcRec.Seller_To_ACV_Label__c = trackingInfo[1].link;                        
                    }                    
                }
                
                if(qcRec.Case__r.RecordTypeId == titlesRecordType && profiles.get(UserInfo.getProfileId()) != null)	{
                    if(isBuyer)	qcRec.Case__r.Update_Status__c = 'Problem';
                    else	qcRec.Case__r.Update_Status__c = 'Return to Seller';
                }
                else {
                    if(isBuyer)	qcRec.Case__r.Status = 'Problem';
                    else	qcRec.Case__r.Status = 'Return to Seller';
                }   
                
                updateObjs.add(qcRec);
                updateObjs.add(qcRec.Case__r);
            }
        }
        else { // it is a Case record
            List<Case> caseRecs = [SELECT Id, Easypost_Tracker__c, Easypost_Tracker_URL__c, Status, Update_Status__c, RecordTypeId FROM Case WHERE Id = :recordId];
            if(caseRecs != null && caseRecs.size() > 0)	{
                Case caseRec = caseRecs[0];
                //if(String.isBlank(caseRec.Easypost_Tracker__c))	{ // User likes to overwrite the tracking info (for now)
                    if(trackingInfo.size() > 0)	{ // Update Ship To tracking info.
                        caseRec.Easypost_Tracker__c = trackingInfo[0].trackingCode;
                        caseRec.Easypost_Tracker_URL__c = trackingInfo[0].link;
                    }
                    
                    if(caseRec.RecordTypeId == titlesRecordType && profiles.get(UserInfo.getProfileId()) != null)	{
                        caseRec.Update_Status__c = 'Sent';
                    }
                    else {
                        caseRec.Status = 'Sent';                    
                    }   
                    
                    updateObjs.add(caseRec);
                /*}
                else {
                    throw new AuraException('Tracking code already exists in the Case record.');
                }*/
            }
        }

		update updateObjs;
        
		return true;        
    }

    /**
     * It is called by EasyPost LWC. It calls the Easy Post APIs to generate the shipping tracking info.
     * 
     * @param jsonAddress Shipping address used to generate the tracking info. Sample message:
                          {
                                "zip":"14228",
                                "street":"12 Test St",
                                "state":"NY",
                                "name":"Account Bulk#A (Seller)",
                                "country":"US",
                                "city":"Buffalo"
                          }
     * @parm needReturnAddressPostageLabel If true, also generate Return postage to ACV. 
     * @param isQualityControl True if it is a Quality Control record, otherwise it is a Case record.
     * @param recordId Record Id of either Quality Control or Case obect.
     * 
     * @return Return a JSON List that contains tracking/postage info for 'Ship To' at index-0.
     * And, if needReturnAddressPostageLabel true, it will also have tracking/postage info for 'Return To ACV' at index-1.
     * 
     */
    @AuraEnabled(cacheable=true)    
    public static String generateShippingLabels(String jsonAddress, Boolean needReturnAddressPostageLabel, Boolean isQualityControl, String recordId, String namePrefix){
        if(String.isBlank(namePrefix)) namePrefix = '';
        
        String ownerName = null;
        if(isQualityControl && !String.isBlank(recordId))	{
            List<Quality_Control__c> recs = [SELECT Owner.Name FROM Quality_Control__c WHERE Id = :recordId];
            if(recs != null && recs.size() > 0) ownerName = namePrefix + recs[0].Owner.Name;
        }
        else if (!String.isBlank(recordId)) {
            List<Case> recs = [SELECT Owner.Name FROM Case WHERE Id = :recordId];            
            if(recs != null && recs.size() > 0) ownerName = namePrefix + recs[0].Owner.Name;
        }
        
        EasyPostComponentController epController = new EasyPostComponentController(false);
        return epController.generateLabel(jsonAddress, needReturnAddressPostageLabel, ownerName);
    }
    
    /**
     * It is called by EasyPost LWC. It fetch various shipping addresses from Account object.
     * 
     * @param recordId Case or Quality Control record Id
     * @param isQualityControl If true, recordId is for Quality Control object, otherwise it is for Case object.
     * @param isRetrieveBuyerAddress If true, fetch all addresses related to Buyer Account.
     * @param isRetrieveSellerAddress If true, fetch all address related to Seller Account.
     * @param isRetrieveBuyerFloorPlanAddress If true, use Floor Plan address if 'Sent Title to Buyer' field is not checked in the Floor_Plan_Setting__mdt.
     * 
     * @return JSON Payload containing all addresses along with some misc info.
     * 
     */
    @AuraEnabled(cacheable=true)    
    public static String getAddresses(String recordId, Boolean isQualityControl, Boolean isRetrieveBuyerAddress, Boolean isRetrieveSellerAddress, Boolean isRetrieveBuyerFloorPlanAddress) {
        Payload retPayload = new Payload();
            
        String theQuery = buildAddressesQuery(recordId, isQualityControl, isRetrieveBuyerAddress, isRetrieveSellerAddress);
        List<Case> qCases = Database.query(theQuery);
        if(qCases != null && qCases.size() > 0)	{
            Floor_Plan_Setting__mdt caseFloorPlan = null;
            if(isRetrieveBuyerFloorPlanAddress) caseFloorPlan = floorPlanMap.get(qCases.get(0).Payment_Method__c);
            retPayload = buildPayload(qCases.get(0), isRetrieveBuyerAddress, isRetrieveSellerAddress, caseFloorPlan);
        }
        
        if(isQualityControl)	retPayload.trackingCode = getQcTrackingCode(recordId);
        return JSON.serialize(retPayload);
    }

    private static final Map<String, Floor_Plan_Setting__mdt> floorPlanMap {
        // Load all floor plans where a title goes directly to the floor plan address (instead of buyer address)
        get {
            Map<String, Floor_Plan_Setting__mdt> floorPlanMap = new Map<String, Floor_Plan_Setting__mdt>();
            for ( Floor_Plan_Setting__mdt fp :[ SELECT Id, Send_Title_to_Buyer__c, Payment_Method_API_Name__c, Name__c, Company__c, Street1__c, Street2__c,
                                               City__c, State__c, Zip__c, Country__c, Phone__c, Email__c
                                               FROM Floor_Plan_Setting__mdt WHERE Send_Title_to_Buyer__c = false]) {
                                                   floorPlanMap.put(fp.Payment_Method_API_Name__c, fp);
                                               }
            return floorPlanMap;
        }
        set;
    }

    private static Payload buildPayload(Case pCase, Boolean isRetrieveBuyerAddress, Boolean isRetrieveSellerAddress, Floor_Plan_Setting__mdt caseFloorPlan)	{
        Payload returnPayload = new Payload();
        if(pCase == null) return returnPayload;
        
        List<PayloadAddressOption> addressOptions = new List<PayloadAddressOption>();
        if(caseFloorPlan != null)	{
            addressOptions.addAll(buildBuyerFloorPlanAddressPayload(pCase, caseFloorPlan));            
        }
        else if(isRetrieveBuyerAddress)	{
            addressOptions.addAll(buildBuyerAddressPayload(pCase));
        }
        
        if(isRetrieveSellerAddress)	{
            addressOptions.addAll(buildSellerAddressPayload(pCase));            
        }
        
        returnPayload.trackingCode = pCase.Easypost_Tracker__c;        
        returnPayload.addressOptions = addressOptions;
        return returnPayload;        
    }
    
    private static List<PayloadAddressOption> buildBuyerFloorPlanAddressPayload(Case pCase, Floor_Plan_Setting__mdt caseFloorPlan)	{
        List<PayloadAddressOption> addressOptions = new List<PayloadAddressOption>();
        
        // Buyer Floor Plan Notes
        PayloadNotes plNotes = new PayloadNotes();
        
        PayloadMiscInfo plMiscInfo = new PayloadMiscInfo();
        plMiscInfo.caseNumber = pCase.CaseNumber;
            
        // Floor Plan Address
        if(!String.isBlank(caseFloorPlan.Street1__c))	{
            PayloadAddress plAddress = new PayloadAddress();            
            plAddress.name = caseFloorPlan.Name__c;
            plAddress.company = caseFloorPlan.Company__c;
            plAddress.street = caseFloorPlan.Street1__c;
            plAddress.street2 = caseFloorPlan.Street2__c;
            plAddress.city = caseFloorPlan.City__c;
            plAddress.state = caseFloorPlan.State__c;
            plAddress.country = caseFloorPlan.Country__c;
            plAddress.zip = caseFloorPlan.Zip__c;
            plAddress.email = caseFloorPlan.Email__c;
        
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Buyer Floor Plan Address';
            plAddrOption.value = plAddressValue;
            addressOptions.add(plAddrOption);
        }
        else if(!String.isBlank(caseFloorPlan.Payment_Method_API_Name__c))	{
            PayloadAddress plAddress = new PayloadAddress();            
            plAddress.name = caseFloorPlan.Payment_Method_API_Name__c;
            plAddress.street = '<No Address Info Found>';
        }
                
        return addressOptions;
    }
    
    private static List<PayloadAddressOption> buildBuyerAddressPayload(Case pCase)	{
        List<PayloadAddressOption> addressOptions = new List<PayloadAddressOption>();
        
        // Buyer Notes
        PayloadNotes plNotes = new PayloadNotes();
        plNotes.legalNotes = pCase.Account.Legal_Address_Note__c;
        plNotes.pickupNotes = pCase.Account.Pickup_Notes__c;
        plNotes.dealershipNotes = pCase.Account.Dealership_Notes__c;
        plNotes.titleMailingAddressNotes = pCase.Account.Title_Mailing_Address_Note__c;
        
        PayloadMiscInfo plMiscInfo = new PayloadMiscInfo();
        plMiscInfo.caseNumber = pCase.CaseNumber;
            
        // Billing Address
        if(!String.isBlank(pCase.Account.BillingStreet))	{
            PayloadAddress plAddress = new PayloadAddress();
            plAddress.name = pCase.Account.Name;
            plAddress.street = pCase.Account.BillingStreet;
            plAddress.city = pCase.Account.BillingCity;
            plAddress.state = pCase.Account.BillingState;
            plAddress.country = pCase.Account.BillingCountry;
            plAddress.zip = pCase.Account.BillingPostalCode;
        	plAddress.email = pCase.ContactEmail;
            
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Buyer Billing Address';
            plAddrOption.value = plAddressValue;
            addressOptions.add(plAddrOption);
        }
        
        // Legal Address
        if(!String.isBlank(pCase.Account.Legal_Street__c))	{
            PayloadAddress plAddress = new PayloadAddress();
            plAddress.name = pCase.Account.Name;
            plAddress.street = pCase.Account.Legal_Street__c;
            plAddress.city = pCase.Account.Legal_City__c;
            plAddress.state = pCase.Account.Legal_State__c;
            plAddress.country = pCase.Account.Legal_Country__c;
            plAddress.zip = pCase.Account.Legal_Zip_Code__c;
        	plAddress.email = pCase.ContactEmail;
        
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Buyer Legal Address';
            plAddrOption.value = plAddressValue;            
            addressOptions.add(plAddrOption);
        }

        // Title Address
        if(!String.isBlank(pCase.Account.Title_Mailing_Street__c))	{
            PayloadAddress plAddress = new PayloadAddress();
            plAddress.name = pCase.Account.Name;
            plAddress.street = pCase.Account.Title_Mailing_Street__c;
            plAddress.city = pCase.Account.Title_Mailing_City__c;
            plAddress.state = pCase.Account.Title_Mailing_State__c;
            plAddress.country = ''; //pCase.Account.Title_Mailing_Zip_Code__c;
            plAddress.zip = pCase.Account.Title_Mailing_Zip_Code__c;
        	plAddress.email = pCase.ContactEmail;
            
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Buyer Title Address';
            plAddrOption.value = plAddressValue;            
            addressOptions.add(plAddrOption);
        }
        
        return addressOptions;
    }

    private static List<PayloadAddressOption> buildSellerAddressPayload(Case pCase)	{
        List<PayloadAddressOption> addressOptions = new List<PayloadAddressOption>();
        
        // Seller Notes
        PayloadNotes plNotes = new PayloadNotes();
        plNotes.legalNotes = pCase.Seller_Dealership__r.Legal_Address_Note__c;
        plNotes.pickupNotes = pCase.Seller_Dealership__r.Pickup_Notes__c;
        plNotes.dealershipNotes = pCase.Seller_Dealership__r.Dealership_Notes__c;
        plNotes.titleMailingAddressNotes = pCase.Seller_Dealership__r.Title_Mailing_Address_Note__c;
        
        PayloadMiscInfo plMiscInfo = new PayloadMiscInfo();
        plMiscInfo.caseNumber = pCase.CaseNumber;
        
        // Billing Address
        if(!String.isBlank(pCase.Seller_Dealership__r.BillingStreet))	{
            PayloadAddress plAddress = new PayloadAddress();
            plAddress.name = pCase.Seller_Dealership__r.Name;
            plAddress.street = pCase.Seller_Dealership__r.BillingStreet;
            plAddress.city = pCase.Seller_Dealership__r.BillingCity;
            plAddress.state = pCase.Seller_Dealership__r.BillingState;
            plAddress.country = pCase.Seller_Dealership__r.BillingCountry;
            plAddress.zip = pCase.Seller_Dealership__r.BillingPostalCode;
            plAddress.email = pCase.Seller_Contact_Email__c;
            
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Seller Billing Address';
            plAddrOption.value = plAddressValue;
            addressOptions.add(plAddrOption);
        }
        
        // Legal Address
        if(!String.isBlank(pCase.Seller_Dealership__r.Legal_Street__c))	{
            PayloadAddress plAddress = new PayloadAddress();
            plAddress.name = pCase.Seller_Dealership__r.Name;
            plAddress.street = pCase.Seller_Dealership__r.Legal_Street__c;
            plAddress.city = pCase.Seller_Dealership__r.Legal_City__c;
            plAddress.state = pCase.Seller_Dealership__r.Legal_State__c;
            plAddress.country = pCase.Seller_Dealership__r.Legal_Country__c;
            plAddress.zip = pCase.Seller_Dealership__r.Legal_Zip_Code__c;
            plAddress.email = pCase.Seller_Contact_Email__c;
            
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Seller Legal Address';
            plAddrOption.value = plAddressValue;            
            addressOptions.add(plAddrOption);
        }
        
        // Title Address
        if(!String.isBlank(pCase.Seller_Dealership__r.Title_Mailing_Street__c))	{
            PayloadAddress plAddress = new PayloadAddress();
            plAddress.name = pCase.Seller_Dealership__r.Name;
            plAddress.street = pCase.Seller_Dealership__r.Title_Mailing_Street__c;
            plAddress.city = pCase.Seller_Dealership__r.Title_Mailing_City__c;
            plAddress.state = pCase.Seller_Dealership__r.Title_Mailing_State__c;
            plAddress.country = ''; //pCase.Seller_Dealership__r.Title_Mailing_Zip_Code__c;
            plAddress.zip = pCase.Seller_Dealership__r.Title_Mailing_Zip_Code__c;
            plAddress.email = pCase.Seller_Contact_Email__c;
            
            PayloadAddressValue plAddressValue = new PayloadAddressValue();
            plAddressValue.address = plAddress;
            plAddressValue.notes = plNotes;
            plAddressValue.miscInfo = plMiscInfo;
            
            PayloadAddressOption plAddrOption = new PayloadAddressOption();
            plAddrOption.label = 'Seller Title Address';
            plAddrOption.value = plAddressValue;            
            addressOptions.add(plAddrOption);
        }
        
        return addressOptions;
    }
    
    private static String getQcTrackingCode(String recordId)	{
        String qcTrackingCode = null;
        List<Quality_Control__c> qcRecs = [SELECT Ship_To_Tracking_Code__c FROM Quality_Control__c WHERE Id = :recordId];
        if(qcRecs.size() > 0) qcTrackingCode = qcRecs.get(0).Ship_To_Tracking_Code__c;
        return qcTrackingCode;
    }
    
    private static String buildAddressesQuery(String recordId, Boolean isQualityControl, Boolean isRetrieveBuyerAddress, Boolean isRetrieveSellerAddress)	{
        String returnQuery = 'SELECT Id, ';
        String fromObject = 'FROM Case ';
        String whereRecrodId = recordId;
        String qcTrackingCode = null;
        if(isQualityControl) {
            whereRecrodId = null;
            List<Quality_Control__c> qcRecs = [SELECT Case__c FROM Quality_Control__c WHERE Id = :recordId];
            if(qcRecs.size() > 0) whereRecrodId = qcRecs.get(0).Case__c;
        }
        
        if(isRetrieveBuyerAddress) {
            returnQuery = returnQuery + 'ContactEmail, Account.Name, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingCountry, Account.BillingPostalCode, ' +
            'Account.Legal_Street__c, Account.Legal_City__c, Account.Legal_State__c, Account.Legal_Country__c, Account.Legal_Zip_Code__c, ' +
            'Account.Title_Mailing_Street__c, Account.Title_Mailing_City__c, Account.Title_Mailing_State__c, Account.Title_Mailing_Zip_Code__c, ' +
            'Account.Legal_Address_Note__c, Account.Pickup_Notes__c, Account.Dealership_Notes__c, Account.Title_Mailing_Address_Note__c, ';
        }
        
        if(isRetrieveSellerAddress) {
            returnQuery = returnQuery + 'Seller_Contact_Email__c, Seller_Dealership__r.Name, Seller_Dealership__r.BillingStreet, Seller_Dealership__r.BillingCity, Seller_Dealership__r.BillingState, Seller_Dealership__r.BillingCountry, Seller_Dealership__r.BillingPostalCode, ' +
            'Seller_Dealership__r.Legal_Street__c, Seller_Dealership__r.Legal_City__c, Seller_Dealership__r.Legal_State__c, Seller_Dealership__r.Legal_Country__c, Seller_Dealership__r.Legal_Zip_Code__c, ' +
            'Seller_Dealership__r.Title_Mailing_Street__c, Seller_Dealership__r.Title_Mailing_City__c, Seller_Dealership__r.Title_Mailing_State__c, Seller_Dealership__r.Title_Mailing_Zip_Code__c, ' +
            'Seller_Dealership__r.Legal_Address_Note__c, Seller_Dealership__r.Pickup_Notes__c, Seller_Dealership__r.Dealership_Notes__c, Seller_Dealership__r.Title_Mailing_Address_Note__c, ';
        }
		        
        returnQuery = returnQuery + 'CaseNumber, Easypost_Tracker__c, Payment_Method__c ';
        
        if(!String.isBlank(whereRecrodId))	{
        	returnQuery = returnQuery + fromObject + 'WHERE Id = \'' + whereRecrodId + '\'';
        }
        else {
            throw new AuraException('Invalid Record Id : ' + whereRecrodId + ' for recordId parameter: ' + recordId);
        }
        
        return returnQuery;
    }

    public class Payload {
        public String trackingCode;
        public List<PayloadAddressOption> addressOptions;
    }
    
    public class PayloadAddressOption	{
        public String label;
        public PayloadAddressValue value;
    }    

    public class PayloadAddressValue	{
        public PayloadAddress address;
        public PayloadNotes notes;
        public PayloadMiscInfo miscInfo;
    }    
    
    public class PayloadAddress	{        
        public String name;        
        public String company;        
        public String street;
        public String street2;
        public String city;
        public String state;
        public String country;
        public String zip;
        public String email;
    }

    public class PayloadNotes	{        
        public String legalNotes;
        public String pickupNotes;
        public String dealershipNotes;
        public String titleMailingAddressNotes;
    }    
    
    public class PayloadMiscInfo	{        
        public String caseNumber;
    }    
    
    public class TrackShipping	{
        String trackingCode;
        String link;
        String label_zpl_url;
    }   
}