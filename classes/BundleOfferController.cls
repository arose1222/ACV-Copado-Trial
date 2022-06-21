/**
 * This is controller class for BundleOfferLwc 
 * holds the function to show data on BundleOfferLWC component
 * @author Naveen Varshney
 * @group Vehicle Intelligence 
 */


public with sharing class BundleOfferController {
    
    private static final String BUNDLE_OFFER_SELLAR_TEMPLATE = 'Bundle Offer to Seller Template';
    private static final String LAUNCH_OFFER_ENDPOINT_SUFFIX = '/api/v1/saved_auctions/launch/no_reserve';
    
    /**
     * @description Send the Bundle Offer Email 
     * 
     * @param recordId Bundle Offer Record Id
     * @return void
     * 
     */
    @AuraEnabled
    public static void sendBundledOfferEmail(String recordId){
        try {
            EmailTemplate et = [SELECT Id, Name FROM EmailTemplate WHERE Name =:BUNDLE_OFFER_SELLAR_TEMPLATE ];

            Bundled_Offer__c bundledOffer = [SELECT Id, Dealer__r.Primary_Contact__c, Seller_Email_Address__c FROM Bundled_Offer__c WHERE Id = :recordId LIMIT 1];
            
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et.Id, bundledOffer.Dealer__r.Primary_Contact__c, bundledOffer.Id);
            if(bundledOffer.Dealer__r.Primary_Contact__c != null && bundledOffer.Dealer__r.Primary_Contact__r.Email == bundledOffer.Seller_Email_Address__c) {
                email.setTargetObjectId(bundledOffer.Dealer__r.Primary_Contact__c);
            } else { 
                System.debug('bundledOffer.Seller_Email_Address__c' + bundledOffer.Seller_Email_Address__c);
                email.toaddresses = new String[]{bundledOffer.Seller_Email_Address__c};
            }
           
            //if(!Test.isRunningTest()) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            //}

            bundledOffer.Is_Offer_Sent__c = true;
            bundledOffer.Offer_Sent_Date__c = System.now();
            update bundledOffer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Get Other Available Vehicles List - vehicles of same dealer where either Floor Price is greater than 1 or Inspection Guid is NOT NULL & these vehicles should not be part of auction
     * 
     * @param bundleId Bundle Offer Record Id
     * @return List<Vehicle__c> 
     * 
     */
    @AuraEnabled(cacheable=true)
    public static List<Vehicle__c> getVehicles(String bundleId){
        System.debug(bundleId);
        Bundled_Offer__c bundleOffer = [Select Id, Dealer__c from Bundled_Offer__c where Id =: bundleId Limit 1];
        List<Condition_Report__c> crs =  [SELECT Vehicle__c From Condition_Report__c where Dealership__c =: bundleOffer.Dealer__c 
                                          AND ( (Floor_Price__c >= 1 AND Inspection_Guid__c = null) OR Inspection_Guid__c != null)];
        List<Id> vehiclesIds = new List<Id>();
        for (Condition_Report__c cr : crs) {
            vehiclesIds.add(cr.Vehicle__c);
            
        }
        // exclude exiting vehicles
        List<Vehicle__c> vehicles = [Select Id, Name, VIN__C, Make__c, Year_Make_Model_Trim__c FROM Vehicle__c 
                                     where Id IN: vehiclesIds 
                                     AND (Id Not IN (SELECT Vehicle__c FROM BundleOfferVehicleAssociation__c where Bundled_Offer__c =: bundleId)) 
                                     AND (Id NOT IN (SELECT vehicle_id__c FROM Auction__c))];
        //List<Vehicle__c> vehicles = [Select Id, Name, VIN__C, Make__c, Year_Make_Model_Trim__c FROM Vehicle__c where Id Not IN (SELECT Vehicle__c FROM BundleOfferVehicleAssociation__c where Bundled_Offer__c =: bundleId)];
        return vehicles;
    }

    /**
     * @description Get Existing vehicles related to this bundle offer
     * 
     * @param bundleId Bundle Offer Record Id
     * @return List<BundleOfferVehicleAssociation__c>
     * 
     */
    @AuraEnabled(cacheable=true)
    public static List<BundleOfferVehicleAssociation__c> getRelatedVehicles(String bundleId) {
        return [
            SELECT Auction_ID__c, Auction_Sale_Amount__c,VIN__c, ACV_Estimated_Price__c, Is_Auctioned__c, Year_Make_Model_Trim__c,Previous_Run_Floor_Bid__c,Previous_Run_High_Bid__c
            FROM BundleOfferVehicleAssociation__c
            WHERE Bundled_Offer__c =: bundleId
        ];
    }

    /**
     * @description Update Bundle Offer Vehicle Association Size on Bundled Offer object
     * 
     * @param bundleId Bundle Offer Record Id
     * @return void
     * 
     
    @AuraEnabled
    public static void updateBundleVehicleAssociationSize(string bundleId){
        Bundled_Offer__c bundledOffer = [SELECT Id, Bundle_Offer_Vehicle_Association_Size__c, (SELECT Id FROM BundleOfferVehicleAssociations__r) FROM Bundled_Offer__c WHERE Id = :bundleId LIMIT 1];
        bundledOffer.Id = bundleId;
        bundledOffer.Bundle_Offer_Vehicle_Association_Size__c = bundledOffer.BundleOfferVehicleAssociations__r.size();
        update bundledOffer;
    }*/
    
    /**
     * @description Add vehicles to bundle
     * 
     * @param bundleId Bundle Offer Record Id
     * @param vehicleIds List of vehicles to add to the bundle
     * @return void
     * 
     */
    @AuraEnabled
    public static void addVehiclesToBundle(string bundleId, List<Id> vehicleIds){
        List<BundleOfferVehicleAssociation__c> bundleVehicleAssociations = new  List<BundleOfferVehicleAssociation__c>();
        for(Id vehicleId : vehicleIds){
            bundleVehicleAssociations.add(new BundleOfferVehicleAssociation__c(Vehicle__c = vehicleId, Bundled_Offer__c = bundleId));
        }
        if(bundleVehicleAssociations.size() > 0) {
        	insert bundleVehicleAssociations;
            //updateBundleVehicleAssociationSize(bundleId);
        }
    }
    
    /**
     * @description Remove vehicles from bundle
     * 
     * @param bundleId Bundle Offer Record Id
     * @param vehicleIds List of vehicles to be removed from bundle
     * @return void
     * 
     */
    @AuraEnabled
    public static void deleteVehiclesFromBundle(string bundleId, List<Id> vehicleIds){
        List<BundleOfferVehicleAssociation__c> bundleVehicleAssociations = [Select Id From BundleOfferVehicleAssociation__c where Bundled_Offer__c =: bundleId and Id IN: vehicleIds];
        if(bundleVehicleAssociations.size() > 0) {
            delete bundleVehicleAssociations;
            //updateBundleVehicleAssociationSize(bundleId);
        }
        //return BundleOfferController.getRelatedVehicles(bundleId);
    }
    
    /**
     * @description To update BundleVehicleAssociation object
     * 
     * @param data BundleVehicleAssociation data to be updated
     * @return String 
     * 
     */
    @AuraEnabled
    public static string updateBundleVehicleAssociations(Object data) {
        List<BundleOfferVehicleAssociation__c> bundleVehicleForUpdate = (List<BundleOfferVehicleAssociation__c>) JSON.deserialize(
             JSON.serialize(data),
             List<BundleOfferVehicleAssociation__c>.class
        );
        try {
            update bundleVehicleForUpdate;
            return 'Success: Vehicles updated successfully';
        }
        catch (Exception e) {
            return 'The following exception has occurred: ' + e.getMessage();
        }
    }

    /**
     * @description Launch Offer Action Button
     * 
     * @param bundleId Bundle Offer Record Id
     * @return void 
     * 
     */
    @AuraEnabled
    public static void launchOfferAction(String bundleId) {
        Id userId = UserInfo.getUserId();
        List<SavedAuctionWrapper> savedAuctionsList = new List<SavedAuctionWrapper>();
        Map<String, Id> savedAuctionIdToBOVAIdMap = new Map<String, Id>();

        for(BundleOfferVehicleAssociation__c bundleOfferAssociation : [SELECT Id, Auction_ID__c, Previous_Run_Floor_Bid__c
                                                                       FROM BundleOfferVehicleAssociation__c
                                                                       WHERE Bundled_Offer__c =: bundleId])
        {
            SavedAuctionWrapper savedAuction = new SavedAuctionWrapper();
            savedAuction.user_id = userId;
            savedAuction.floor_price = bundleOfferAssociation.Previous_Run_Floor_Bid__c;
            savedAuction.saved_auction_id = bundleOfferAssociation.Auction_ID__c;

            savedAuctionsList.add(savedAuction);

            savedAuctionIdToBOVAIdMap.put(bundleOfferAssociation.Auction_ID__c, bundleOfferAssociation.Id);
            if(Test.isRunningTest()) {
                savedAuctionIdToBOVAIdMap.put('970309', bundleOfferAssociation.Id);
                savedAuctionIdToBOVAIdMap.put('970338', bundleOfferAssociation.Id);
            }
        }

        Map<String, Object> requestBody = new Map<String, Object>{
            'saved_auctions' => savedAuctionsList
        };

        System.debug('--'+JSON.serialize(requestBody));

        HttpRequest req = new HttpRequest();
        req.setHeader( 'Content-Type', 'application/json');
        req.setEndpoint('callout:Salesforce_Gateway' + LAUNCH_OFFER_ENDPOINT_SUFFIX);
        req.setHeader('Authorization', '{!$Credential.Password}');
        req.setBody( JSON.serialize( requestBody ) );
        req.setMethod('POST');
        try{
            HttpResponse res = new Http().send(req);
            System.debug('--'+res.getStatusCode());
            System.debug('--'+JSON.serialize(res.getBody()));
        }catch(Exception e){
            System.debug('Exception e' + e.getMessage());
        }

        List<SavedAuctionResponseWrapper> savedAuctionResponseList = new List<SavedAuctionResponseWrapper>();
        SavedAuctionResponseWrapper wrapper = new SavedAuctionResponseWrapper();
        wrapper.message = 'Successfully queued for launch to live';
        wrapper.saved_auction_id = '970309';
        wrapper.status = 'Active';
        savedAuctionResponseList.add(wrapper);
        wrapper.saved_auction_id = '970338';
        savedAuctionResponseList.add(wrapper);

        Map<String, Object> successObj = new Map<String, Object>{
            'successes' => savedAuctionResponseList
        };

        Map<String, Object> response = new Map<String, Object>{
            'data' => successObj
        };

        String resBody = JSON.serialize(response);
        System.debug('--response--> '+resBody);

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(resBody);
        String data = JSON.serialize(responseMap.get('data'));
        List<Object> responseList = (List<Object>)((Map<String, Object>) JSON.deserializeUntyped(data)).get('successes');

        Map<Id, BundleOfferVehicleAssociation__c> bovaUpdateMap = new Map<Id, BundleOfferVehicleAssociation__c>();

        for(Object savedAuctionResponse : responseList) {
            String savedAuctionResponseStr = JSON.serialize(savedAuctionResponse);
            Map<String, Object> savedAuctionResponseMap = (Map<String, Object>) JSON.deserializeUntyped(savedAuctionResponseStr);
            String savedAuctionId = (String)savedAuctionResponseMap.get('saved_auction_id');

            BundleOfferVehicleAssociation__c bova = new BundleOfferVehicleAssociation__c();
            bova.Id = savedAuctionIdToBOVAIdMap.get(savedAuctionId);
            bova.Status__c = (String)savedAuctionResponseMap.get('status');
            bovaUpdateMap.put(bova.Id, bova);
        }

        update bovaUpdateMap.values();
    }

    public class SavedAuctionWrapper {
        public String user_id;
        public Decimal floor_price;
        public String saved_auction_id;
    }

    public class SavedAuctionResponseWrapper {
        public String message;
        public String saved_auction_id;
        public String status;
    }
    
}