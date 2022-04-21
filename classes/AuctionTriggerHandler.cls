/**
 * This is a legacy class that was on the old frame work and has since been updated to the new one
 * This is responsible for the majority of Auction logic that was implemented by Huron
 * @author Bill Sutton
 * @since 2019
 * 
 * @group Auction
 */
public class AuctionTriggerHandler extends TriggerInterface{
    /**
     * Auctions Statuses that are known to mean an Auction was won
     */
    public static Set<String> AUCTION_SUCCESSFUL_STATUSES {get;set;}
    /**
     * Auction Statuses that are known to mean an Auction was lost
     */
    public static Set<String> AUCTION_FAILURE_STATUSES {get;set;}

    /**
     * Initiallizes public class variable with System Labels
     */
    public AuctionTriggerHandler() {
        if(System.Label.AUCTION_SUCCESSFUL_STATUSES != null){
            String aucSucStatLabel = System.Label.AUCTION_SUCCESSFUL_STATUSES;
            AUCTION_SUCCESSFUL_STATUSES = new Set<String>(aucSucStatLabel.split(','));
        }

        if(System.Label.AUCTION_FAILURE_STATUSES != null){
            String aucFailStatLabel = System.Label.AUCTION_FAILURE_STATUSES;
            AUCTION_FAILURE_STATUSES = new Set<String>(aucFailStatLabel.split(','));
        }
    }
    /**
     * Runs the Logic of before insert
     * @param newList New List of Auctions from the Framework 
     */
    public override void beforeInsert(List<SObject> newList){
        uncheckMostRecent((List<Auction__c>)newList);
        stampRelevantRecommendedPrice((List<Auction__c>)newList);
        AuctionLightsConcatenationUpdate.run((List<Auction__c>)newList);
    }

    /**
     * Runs the Logic of before update
     * @param oldList Old Map of Auctions from the Framework
     * @param newList New Map of Auctions from the Framework
     */
    public override void beforeUpdate(List<SObject> oldList, List<SObject> newList){
        AuctionLightsConcatenationUpdate.run((List<Auction__c>)newList);
    }

    /**
     * Runs the Logic of after insert
     * @param newMap New Map of Auctions from the Framework
     */
    public override void afterInsert(Map<Id, SObject> newMap) {
        determineVehicleRecentSeller((Map<Id,Auction__c>)newMap);
        createDealMakerOpportunity.runCleanUp((Map<Id,Auction__c>)newMap);
    }

    /**
     * Runs the Logic of after update
     * @param oldMap Old Map of Auctions from the Framework
     * @param newMap New Map of Auctions from the Framework
     */
    public override void afterUpdate(Map<Id,SObject> oldMap, Map<Id,SObject> newMap) {
       determineVehicleRecentSellerUpdate((Map<Id,Auction__c>)newMap, (Map<Id,Auction__c>)oldMap);
        createDealMakerOpportunity.run((Map<Id,Auction__c>)newMap, (Map<Id,Auction__c>)oldMap);
        CloseWonDealmakerOpportunities.run((Map<Id,Auction__c>)newMap, (Map<Id,Auction__c>)oldMap);
        AuctionUtility.afterUpdateLogic((Map<Id,Auction__c>)newMap, (Map<Id,Auction__c>)oldMap);
    }

    /**
     * Determins a vehicles mostrecent seller based on the Auctions we pass
     * @param newAuctions The Auctions we are referencing
     */
    public static void determineVehicleRecentSeller (Map<Id,Auction__c> newAuctions) {
        Map<Id,List<Auction__c>> mVehicleIdToAuction = new Map<Id,List<Auction__c>>();

        for (Auction__c aucObj :newAuctions.values()) {

            if (aucObj.vehicle_id__c != null) {

                if (mVehicleIdToAuction.containsKey(aucObj.vehicle_id__c)) {
                    mVehicleIdToAuction.get(aucObj.vehicle_id__c).add(aucObj);
                } else {
                    mVehicleIdToAuction.put(aucObj.vehicle_id__c, new List<Auction__c > {aucObj});
                }
            }
        }

        Map<Id,Vehicle__c> mVehiclesToUpdate = new Map<Id,Vehicle__c>();

        for (Vehicle__c vehicle :[SELECT Id, Most_Recent_Seller__c, Recent_Seller_s_Total_Runs__c, Recent_Seller_s_Failed_Runs__c, Recent_Seller_Successful_Run_Number__c
                                 FROM Vehicle__c WHERE Id IN :mVehicleIdToAuction.keySet()]) {
            Boolean updateVehicle = false;

            for (Auction__c vehUpdatedAuction :mVehicleIdToAuction.get(vehicle.Id)) {
                System.debug('4I:' + vehUpdatedAuction);

                if (vehicle.Most_Recent_Seller__c != vehUpdatedAuction.Seller_Dealership__c && vehUpdatedAuction.Seller_Dealership__c != null) {
                    System.debug('MostRecentSeller Change - insert');
                    vehicle.Most_Recent_Seller__c = vehUpdatedAuction.Seller_Dealership__c;
                    vehicle.Recent_Seller_s_Total_Runs__c = 0;
                    vehicle.Recent_Seller_s_Failed_Runs__c = 0;
                    vehicle.Recent_Seller_Successful_Run_Number__c = 0;
                    updateVehicle = true;
                }

                //Check if auction is closed successful
                if (AUCTION_SUCCESSFUL_STATUSES.contains(vehUpdatedAuction.Status__c) && vehicle.Most_Recent_Seller__c == vehUpdatedAuction.Seller_Dealership__c) {
                    //update total runs and successful run number
                    System.debug('Successful auction - insert');
                    vehicle.Recent_Seller_s_Total_Runs__c = vehicle.Recent_Seller_s_Total_Runs__c != null ? vehicle.Recent_Seller_s_Total_Runs__c + 1:1;
                    vehicle.Recent_Seller_Successful_Run_Number__c = vehicle.Recent_Seller_s_Total_Runs__c;
                    updateVehicle = true;
                //check if auction is closed failure
                } else if (AUCTION_FAILURE_STATUSES.contains(vehUpdatedAuction.Status__c) && vehicle.Most_Recent_Seller__c == vehUpdatedAuction.Seller_Dealership__c) {
                    //update total runs and failed run number
                    System.debug('Failed auction - insert');
                    vehicle.Recent_Seller_s_Total_Runs__c = vehicle.Recent_Seller_s_Total_Runs__c != null ? vehicle.Recent_Seller_s_Total_Runs__c + 1 : 1;
                    vehicle.Recent_Seller_s_Failed_Runs__c = vehicle.Recent_Seller_s_Failed_Runs__c  != null ?vehicle.Recent_Seller_s_Failed_Runs__c + 1:1;
                    updateVehicle = true;
                }
            }

            if (updateVehicle) {
                System.debug('runs insert veh:'+vehicle);
                mVehiclesToUpdate.put(vehicle.Id,vehicle);
            }   
        }

        if (mVehiclesToUpdate.size() > 0) {
            update mVehiclesToUpdate.values();
        }
    }

    /**
     * Determins if we need to update the vehicles most recent seller on auction updates
     * @param newAuctions The new Auction Map
     * @param oldAuctions the old Auction Map
     */
    public static void determineVehicleRecentSellerUpdate(Map<Id,Auction__c> newAuctions, Map<Id,Auction__c> oldAuctions) {
        Map<Id,List<Auction__c>> mVehicleIdToAuction = new Map<Id,List<Auction__c>>();

        for (Auction__c aucObj :newAuctions.values()) {

            if (aucObj.vehicle_id__c != null) {

                if (mVehicleIdToAuction.containsKey(aucObj.vehicle_id__c)) {
                    mVehicleIdToAuction.get(aucObj.vehicle_id__c).add(aucObj);
                } else {
                    mVehicleIdToAuction.put(aucObj.vehicle_id__c, new List<Auction__c>{aucObj});
                }
            }
        }

        Map<Id,Vehicle__c> mVehiclesToUpdate = new Map<Id,Vehicle__c>();
        
        for (Vehicle__c vehicle :[SELECT Id, Most_Recent_Seller__c, Recent_Seller_s_Total_Runs__c, Recent_Seller_s_Failed_Runs__c, Recent_Seller_Successful_Run_Number__c 
                                    FROM Vehicle__c WHERE Id IN :mVehicleIdToAuction.keySet()]) {
            Boolean updateVehicle = false;

            for (Auction__c vehUpdatedAuction :mVehicleIdToAuction.get(vehicle.Id)) {
                System.debug('4U:' + vehUpdatedAuction);
                Auction__c oldAuction = oldAuctions.get(vehUpdatedAuction.Id);

                if (vehicle.Most_Recent_Seller__c != vehUpdatedAuction.Seller_Dealership__c && vehUpdatedAuction.Seller_Dealership__c != null) {
                    System.debug('MostRecentSeller Change - update');
                    vehicle.Most_Recent_Seller__c = vehUpdatedAuction.Seller_Dealership__c;
                    vehicle.Recent_Seller_s_Total_Runs__c = 0;
                    vehicle.Recent_Seller_s_Failed_Runs__c = 0;
                    vehicle.Recent_Seller_Successful_Run_Number__c = 0;
                    updateVehicle = true;
                }

                //Check if auction is closed successful
                if (oldAuction.Status__c != null && oldAuction.Status__c != vehUpdatedAuction.Status__c && AUCTION_SUCCESSFUL_STATUSES.contains(vehUpdatedAuction.Status__c) && !AUCTION_SUCCESSFUL_STATUSES.contains(oldAuction.Status__c)
                    && vehicle.Most_Recent_Seller__c == vehUpdatedAuction.Seller_Dealership__c) {
                    //update total runs and successful run number
                    System.debug('Successful auction - update');
                    vehicle.Recent_Seller_s_Total_Runs__c = vehicle.Recent_Seller_s_Total_Runs__c != null ? vehicle.Recent_Seller_s_Total_Runs__c + 1 : 1;
                    vehicle.Recent_Seller_Successful_Run_Number__c = vehicle.Recent_Seller_s_Total_Runs__c;
                    updateVehicle = true;
                //check if auction is closed failure
                } else if (oldAuction.Status__c != null && oldAuction.Status__c != vehUpdatedAuction.Status__c && AUCTION_FAILURE_STATUSES.contains(vehUpdatedAuction.Status__c) && !AUCTION_FAILURE_STATUSES.contains(oldAuction.Status__c) 
                    && vehicle.Most_Recent_Seller__c == vehUpdatedAuction.Seller_Dealership__c) {
                    //update total runs and failed run number
                    System.debug('Failed auction - update');
                    vehicle.Recent_Seller_s_Total_Runs__c = vehicle.Recent_Seller_s_Total_Runs__c != null ? vehicle.Recent_Seller_s_Total_Runs__c + 1 : 1;
                    vehicle.Recent_Seller_s_Failed_Runs__c = vehicle.Recent_Seller_s_Failed_Runs__c != null ? vehicle.Recent_Seller_s_Failed_Runs__c += 1 : 1;
                    updateVehicle = true;
                }
            }

            if (updateVehicle)  {
                mVehiclesToUpdate.put(vehicle.Id,vehicle);
            }   
        }

        if (mVehiclesToUpdate.size() > 0) {
            update mVehiclesToUpdate.values();
        }
    }
    
    /**
     * Will take a list of auctions and determin if the auctions are the most recent for the related vehicle
     * @param newAuctions The Auctions we are checking for
     */
    public static void uncheckMostRecent(List<Auction__c> newAuctions){
        List<Auction__c> lAuctions = new List<Auction__c>();
        
        Set<id> vehicleIDs = new Set<Id>();
        for(Auction__c a : newAuctions){
        vehicleIDs.add(a.Vehicle_id__c);
        }
        //If auction has no vehicle info 
        vehicleIDs.remove(null);
        if(vehicleIDs.isEmpty()){
            return;
        }
        //The query for this loop should only return one value but if for some reason it doesn't any other Auctions that have
        //Most_Recent_Auction__c set to true will be changed to false.
        for(Auction__c relatedAuction : [SELECT Vehicle_id__c, Most_Recent_Auction__c FROM Auction__c WHERE Vehicle_id__c IN :vehicleIDs AND Most_Recent_Auction__C = true]){
        //System.debug('Related Auction found');
        relatedAuction.Most_Recent_Auction__c = false;
        lAuctions.add(relatedAuction);
        }
        
        update lAuctions;
    }

    /**
     * Takes a list of Auctions and updates the Recommended Price fields
     * @param newAuctions The Auctions that are going to be updated with the related Vehicles Recommended Prices
     */
    public static void stampRelevantRecommendedPrice(List<Auction__c> newAuctions){
        Set<Id> vehicleIds = new Set<Id>();
        for(Auction__c a : newAuctions){
            vehicleIDs.add(a.Vehicle_id__c);
        }

        Map<Id,Vehicle__c> vehicleMap = new Map<Id,Vehicle__c>([SELECT Id, Recommended_Price_Ceiling__c, Recommended_Price_Floor__c, Most_Recent_Price_Recommendation_Date__c, Recommended_Price_Created_By__c 
                                                            FROM Vehicle__c
                                                            WHERE Id IN :vehicleIds]);
        
        for(Auction__c a : newAuctions){
            if(vehicleMap.get(a.Vehicle_ID__c) != null && vehicleMap.get(a.Vehicle_ID__c).Most_Recent_Price_Recommendation_Date__c!= null){
                a.Relevant_Recommended_Price_Date__c = vehicleMap.get(a.Vehicle_ID__c).Most_Recent_Price_Recommendation_Date__c;
            }
            if(vehicleMap.get(a.Vehicle_ID__c) != null && vehicleMap.get(a.Vehicle_ID__c).Recommended_Price_Ceiling__c!= null){
                a.Relevant_Recommended_Ceiling_Price__c = vehicleMap.get(a.Vehicle_ID__c).Recommended_Price_Ceiling__c;
            }
            if(vehicleMap.get(a.Vehicle_ID__c) != null && vehicleMap.get(a.Vehicle_ID__c).Recommended_Price_Floor__c!= null){
                a.Relevant_Recommended_Floor_Price__c = vehicleMap.get(a.Vehicle_ID__c).Recommended_Price_Floor__c;
            }
            if(vehicleMap.get(a.Vehicle_ID__c) != null && vehicleMap.get(a.Vehicle_ID__c).Recommended_Price_Created_By__c!= null){
                a.Relevant_Recommended_Price_Created_By__c = vehicleMap.get(a.Vehicle_ID__c).Recommended_Price_Created_By__c;
            }
        }
    }
}