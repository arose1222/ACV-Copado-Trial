public class CreateDealMakerOpportunity {

    public static final List<String> triggeringStatuses = new List<String> {'awaiting_acceptance', 'counter_original_declined', 'counter_sent', 'ended_declined'};

    public static void Run(Map<Id,Auction__c> auctionMapNew, Map<Id,Auction__c> auctionMapOld) {
        List<Opportunity> oppListNew = new List<Opportunity>();
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        Set<Id> auctionSetIdFailed = new Set<Id>();
        Set<Id> accountSetIdNew = new Set<Id>();
        Id DealMakerOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Maker').getRecordTypeId();
        List<User> defaultUser = [select Id from user where userName LIKE '%kdamian@acvauctions.com%'];

        // Loop through Auctions
        for (Auction__c a :auctionMapNew.Values()) {

            // If the Auction status changed and new status is a "failed" status
            if (auctionMapOld.get(a.id).status__c != a.status__c && triggeringStatuses.contains(a.status__c)) {
                // Save Auction Ids for Auctions with new failed status
                auctionSetIdFailed.add(a.Id);

                if (a.Seller_Dealership__c != null) {
                    // Save Auction Seller Account ID
                    accountSetIdNew.add(a.Seller_Dealership__c);
                }     

                if (a.Buyer_Dealership__c != null) {
                    // Save Auction Buyer Account ID
                    accountSetIdNew.add(a.Buyer_Dealership__c);
                }
            }
        }
        
        // Retrieve Account info using the Auction Seller (or Buyer) Account ID for populating new Oppty fields later
        Map<Id,Account> accountMapRelated = new Map<Id,Account>([Select Id, Name, IST_Account_Owner__c, Primary_Contact__c from Account where Id in :accountSetIdNew]);

        // Check for OPEN Opportunities that exist for Auctions (with failed statuses).  Will use to Update Opptys (vs Insert).
        Set<String> oppSetOpenDupExists = new Set<String>();
        for (Opportunity oppty : [ SELECT Id, Auction__c, Auction__r.Id__c, Auction_ID__c, isClosed 
                                   FROM Opportunity 
                                   WHERE Auction__c IN :auctionSetIdFailed AND isClosed = FALSE ] ) {

//            oppSetOpenDupExists.add (oppty.Auction_ID__c);

//            if ( !String.isBlank( oppty.Auction__r.Id__c ) ) {
//                oppSetOpenDupExists.add (oppty.Auction__r.Id__c);
//            }
 
            // Existing Open Opportunities should always be added so that they are updated instead of inserted.
            // Use the Auction External ID reference in case the Open Opportunity Auction_ID is blank.
            oppSetOpenDupExists.add (oppty.Auction__r.Id__c);
        }


        /* * * * * * *  INSERT New Opportunities  * * * * * * */

        // Loop through the Auctions with failed status
        for (Id a :auctionSetIdFailed) {

            // If auction & seller account are not null & OPEN Opportunity does NOT exist for this Auction
            // ... the Oppty Update part is not an "Else" to this "If" because this Loops through Auctions
            if (auctionMapNew.get(a) != null 
                && accountMapRelated.get (auctionMapNew.get(a).Seller_Dealership__c) != null 
                && !oppSetOpenDupExists.contains (auctionMapNew.get(a).Id__c)) {

                Opportunity newOp = new Opportunity ( 
                    AccountId = auctionMapNew.get(a).Seller_Dealership__c, 
                    Auction__c = a,
                    Auction_ID__c = auctionMapNew.get(a).Id__c,
                    Auction_End_Date_Time__c = auctionMapNew.get(a).end_time__c, 
                    Buyer_Dealership__c = auctionMapNew.get(a).Buyer_Dealership__c, 
                    Buyer_IST__c = auctionMapNew.get(a).Buyer_Dealership__c != null ? accountMapRelated.get(auctionMapNew.get(a).Buyer_Dealership__c).IST_Account_Owner__c : null, 
                    Buyer_Primary_Contact__c = auctionMapNew.get(a).Buyer_Dealership__c != null ? accountMapRelated.get(auctionMapNew.get(a).Buyer_Dealership__c).Primary_Contact__c : null, 
                    Closedate = system.today().addDays(1), 
                    Floor_Price__c = auctionMapNew.get(a).Floor_Price__c, 
                    Name = 'Deal Maker - ' + accountMapRelated.get(auctionMapNew.get(a).Seller_Dealership__c).Name + ' - ' + auctionMapNew.get(a).id__c, 
                    OwnerId = accountMapRelated.get(auctionMapNew.get(a).Seller_Dealership__c).IST_Account_Owner__c,
                    RecordTypeId = DealMakerOppRecordType, 
                    Seller_Dealership__c = auctionMapNew.get(a).Seller_Dealership__c, 
                    Seller_IST__c = accountMapRelated.get(auctionMapNew.get(a).Seller_Dealership__c).IST_Account_Owner__c, 
                    Seller_Primary_Contact__c = accountMapRelated.get(auctionMapNew.get(a).Seller_Dealership__c).Primary_Contact__c, 
                    StageName = 'New', 
                    Winning_Bid__c = auctionMapNew.get(a).Winning_Bid_Price__c
                );

                if (newOp.OwnerId == null) {
                    newOp.OwnerId = defaultUser[0].id; //currently not covered by test code, would be a good project to have test code refactored
                }

                oppListNew.add(newOp);

            } else if (accountMapRelated.get (auctionMapNew.get(a).Seller_Dealership__c) == null && accountMapRelated.get (auctionMapNew.get(a).Buyer_Dealership__c) == null) {
                System.debug(' ********** DO NOT CREATE AN OPPORTUNITY ********** BOTH Seller and Buyer CANNOT be NULL **********');

            } else if (accountMapRelated.get (auctionMapNew.get(a).Seller_Dealership__c) == null) {
                System.debug(' ********** DO NOT CREATE AN OPPORTUNITY ********** Seller CANNOT be NULL even if Buyer is NOT NULL **********');
            }
        }

        // if we have Opportunities in our list we insert the list of New Opportunities
        if (oppListNew.size() > 0) {
            insert oppListNew;
        }


        /* * * * * * *  UPDATE Existing Open Opportunities  * * * * * * */

        // If auction and auction seller account are not null & OPEN Opportunity DOES exist for this Auction
        for (Opportunity oUpd :[Select id, Auction__c, Auction__r.Id__c, Auction_ID__c, isClosed, AccountId, Auction_End_Date_Time__c, Buyer_Dealership__c, Buyer_IST__c, Buyer_Primary_Contact__c, 
                                       Closedate, Floor_Price__c, Name, OwnerId, RecordTypeId, Seller_Dealership__c, Seller_IST__c, Seller_Primary_Contact__c, Winning_Bid__c
                                 FROM Opportunity 
//                                WHERE Auction_ID__c in :oppSetOpenDupExists AND isClosed = FALSE]) {
                                WHERE Auction__r.Id__c in :oppSetOpenDupExists AND isClosed = FALSE]) {

            if (auctionMapOld.get(oUpd.Auction__c).Seller_Dealership__c != auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c) {
                oUpd.AccountId = auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c;
                oUpd.OwnerId = accountMapRelated.get(auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c).IST_Account_Owner__c;
                oUpd.Seller_Dealership__c = auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c;
                oUpd.Seller_IST__c = accountMapRelated.get(auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c).IST_Account_Owner__c;
                oUpd.Seller_Primary_Contact__c = accountMapRelated.get(auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c).Primary_Contact__c;
            }

            if ((auctionMapOld.get(oUpd.Auction__c).Seller_Dealership__c != auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c) || (auctionMapOld.get(oUpd.Auction__c).id__c != auctionMapNew.get(oUpd.Auction__c).id__c)) {
                    oUpd.Name = 'Deal Maker - ' + accountMapRelated.get(auctionMapNew.get(oUpd.Auction__c).Seller_Dealership__c).Name + ' - ' + auctionMapNew.get(oUpd.Auction__c).id__c;
            }

            if ( String.isBlank( oUpd.Auction_Id__c ) ) {
                oUpd.Auction_Id__c = oUpd.Auction__r.Id__c;
            }

            // oUpd.Auction__c = oUpd.Auction__c;

            if (auctionMapOld.get(oUpd.Auction__c).end_time__c != auctionMapNew.get(oUpd.Auction__c).end_time__c) {
                oUpd.Auction_End_Date_Time__c = auctionMapNew.get(oUpd.Auction__c).end_time__c;
            }

            if (auctionMapOld.get(oUpd.Auction__c).Buyer_Dealership__c != auctionMapNew.get(oUpd.Auction__c).Buyer_Dealership__c) {
                oUpd.Buyer_Dealership__c = auctionMapNew.get(oUpd.Auction__c).Buyer_Dealership__c;
                oUpd.Buyer_IST__c = auctionMapNew.get(oUpd.Auction__c).Buyer_Dealership__c != null ? accountMapRelated.get(auctionMapNew.get(oUpd.Auction__c).Buyer_Dealership__c).IST_Account_Owner__c : null;
                oUpd.Buyer_Primary_Contact__c = auctionMapNew.get(oUpd.Auction__c).Buyer_Dealership__c != null ? accountMapRelated.get(auctionMapNew.get(oUpd.Auction__c).Buyer_Dealership__c).Primary_Contact__c : null;
            }

            oUpd.Closedate = system.today().addDays(1);

            if (auctionMapOld.get(oUpd.Auction__c).Floor_Price__c != auctionMapNew.get(oUpd.Auction__c).Floor_Price__c) {
                oUpd.Floor_Price__c = auctionMapNew.get(oUpd.Auction__c).Floor_Price__c;
            }

            oUpd.RecordTypeId = DealMakerOppRecordType;

            // oUpd.StageName = 'New';

            if (auctionMapOld.get(oUpd.Auction__c).Winning_Bid_Price__c != auctionMapNew.get(oUpd.Auction__c).Winning_Bid_Price__c) {
                oUpd.Winning_Bid__c = auctionMapNew.get(oUpd.Auction__c).Winning_Bid_Price__c;
            }

            if (oUpd.OwnerId == null) {
                oUpd.OwnerId = defaultUser[0].id; //currently not covered by test code, would be a good project to have test code refactored
            }

            oppListUpdate.add(oUpd);
        }

        if (oppListUpdate.size() > 0) {
            update oppListUpdate;
        }
    }


    public static void runCleanUp(Map<Id,Auction__c> auctionMapNew) {
        Id DealMakerOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Deal Maker').getRecordTypeId();
        Map<Id,Id> dealerCarMap = new Map<Id,Id>();
        List<Id> auctionListIdOutstanding = new List<Id>();
        List<Opportunity> opportunityListUpdate = new List<Opportunity>();

        for (Auction__c a :auctionMapNew.values()) {

            if (a.vehicle_id__c != null || a.Seller_Dealership__c != null) {

                if (!dealerCarMap.keyset().contains(a.vehicle_id__c)) {
                    dealerCarMap.put(a.vehicle_id__c, a.Seller_Dealership__c);
                }
            }
        }

        for (Auction__c a :[SELECT id, vehicle_id__c, Seller_Dealership__c 
                              FROM Auction__c 
                             WHERE vehicle_id__c in :dealerCarMap.keyset() AND Seller_Dealership__c in :dealerCarMap.values() AND id NOT IN :Trigger.NewMap.keySet()]) {

            if (dealerCarMap.get(a.vehicle_id__c) != null && a.Seller_Dealership__c == dealerCarMap.get(a.vehicle_id__c)) {
                auctionListIdOutstanding.add(a.id);
            }
        }

        // Take the list of old auctions and find the related opportunities then close them
        for (Opportunity o :[SELECT Id, StageName, Objection__c, Auction_ID__c 
                               FROM Opportunity 
                              WHERE isClosed = FALSE AND Auction__c in :auctionListIdOutstanding AND RecordTypeId = :DealMakerOppRecordType AND Auction__c NOT IN :Trigger.NewMap.keySet()]){

            o.Objection__c = 'ACV Fees'; // might need to revisit this, currently field validation rule is blocking close unless we populate this
            o.StageName = 'Closed Lost';
            o.Auction_ID__c = '';
            opportunityListUpdate.add(o);
        }

        // if we have opportunities to update then do it
        if (opportunityListUpdate.size() > 0) {
            update opportunityListUpdate;
        }
    }
}