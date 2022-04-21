public with sharing class DealMakerView2 {
    @AuraEnabled(cacheable=true)
    //method that does the query to pull in the deal maker opportunities
    public static List<Opportunity> getOpportunities(String searchTerm){
        Type stringList = Type.forName('List<String>');
        List<String> searchList = (List<String>) JSON.deserialize(searchTerm, stringList);
        if (searchList.size()>0) {
          
            List<Opportunity> oppResults = new List<Opportunity>();
            List<Opportunity> deals = [SELECT ID, Auction__r.id__c, Buyer_Dealership__r.Name, Buyer_Dealership__r.id, Buyer_Primary_Contact__c, Buyer_Primary_Contact__r.ID__c, Seller_Dealership__r.Name, Seller_Dealership__r.Id, Price_Variance__c, Auction_End_Date_Time__c, High_Bid__c, Floor_Value__c, Auction_Notes_2__c, Seller_IST__r.Name, Seller_IST__r.Id, Buyer_IST__r.Name, Buyer_IST__c, Name, Buyer_IST__r.Id, Seller_Region__c, VIN_Last_Six__c
                                                 FROM Opportunity
                                                 WHERE RecordType.Name = 'Deal Maker' 
                                                 AND Auction_End_Date_Time__c = TODAY 
                                                 AND Opty_Auction_Status__c = 'counter_sent' 
                                                 AND (
                                                        (Seller_IST__r.CaseSafe_ID__c IN : searchList OR Buyer_IST__r.CaseSafe_ID__c IN : searchList)
                                                        OR Seller_Dealership__r.Territory_Name__c IN : searchList
                                                        OR Seller_DealerShip__r.Service_Territory__r.ParentTerritoryId IN :searchList
                                                     )
                                                 ORDER BY Auction_End_Date_Time__c DESC];

            return deals;
        } 
        else {
            List<opportunity> deals = [SELECT ID, Auction__r.id__c, Buyer_Dealership__r.Name, Buyer_Dealership__r.id, Buyer_Primary_Contact__c, Buyer_Primary_Contact__r.ID__c, Seller_Dealership__r.Name, Seller_Dealership__r.Id, Price_Variance__c, Auction_End_Date_Time__c, High_Bid__c, Floor_Value__c, Auction_Notes_2__c, Seller_IST__r.Name, Seller_IST__r.Id, Buyer_IST__r.Name, Buyer_IST__c, Name, Buyer_IST__r.Id, Seller_Region__c, VIN_Last_Six__c
                FROM Opportunity
                WHERE RecordType.Name = 'Deal Maker'
                AND Auction_End_Date_Time__c = TODAY
                AND Opty_Auction_Status__c = 'counter_sent'
                ORDER BY Auction_End_Date_Time__c DESC LIMIT 100];
            return deals;

        }
    }

    @AuraEnabled
    //method that the lookupfilter uses to pull up the options
    public static List<LookupSearchResult> searchTheTerm(String searchTerm){
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        if (String.isNotEmpty(searchTerm)) {
            searchTerm += '*';

            List<List<sObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING 
                                                User(Id, Name, FirstName, LastName), 
                                                //TODO repalce geopoint with Maps
                                                //geopointe__GP_Assignment_Area__c(Id, Name),
                                                ServiceTerritory(id, Name WHERE ParentTerritoryId = null)];
            ServiceTerritory [] regionList = ((List<ServiceTerritory>) searchResults[1]);
            for (ServiceTerritory rl : regionList){
                results.add(new LookupSearchResult(rl.Id , 'Account', 'standard:account', rl.Name , 'Region'));
            }                                    
            // geopointe__GP_Assignment_Area__c [] territoryList = ((List<geopointe__GP_Assignment_Area__c>) searchResults[1]);
            // for (geopointe__GP_Assignment_Area__c gp : territoryList) {
            //     results.add(new LookupSearchResult(gp.Id, 'Account', 'standard:account', gp.Name, 'Territory'));
            // }
            String accountIcon = 'standard:user';
            User [] userList = ((List<User>) searchResults[0]);
            for (User u : userList) {
                results.add(new LookupSearchResult(u.Id, 'User', accountIcon, u.Name, 'Sell/Buy IST' ));
            }
        } 
        return results;
    }

    @AuraEnabled
    //method that is used to save the User's filters so if they leave the page and come back they still have them and do not have to reinput them
    public static void filterSave(List<String> searchWords){
        List<User> userFilters = [Select ID, Deal_Maker_Filter_Save__c FROM User WHERE User.Name = : userInfo.getName()];
        userFilters[0].Deal_Maker_Filter_Save__c = JSON.serialize(searchWords);
        update userFilters;
    }

    @AuraEnabled
    //method that is called everytime the page loads to see if the user has any saved filters and if so loads them into the build method
    public static List<LookupSearchResult> loadFilterList(){
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        List<User> userFilt = [Select ID, Deal_Maker_Filter_Save__c FROM User WHERE User.Name = : userInfo.getName()];

        List<String> filterList = (List<String>)JSON.deserialize(userFilt[0].Deal_Maker_Filter_Save__c, List<String>.class);

        String accountIcon = 'standard:user';
        for (User u : [SELECT id, name FROM user WHERE name in :filterList]) {
            results.add(new LookupSearchResult(u.Id, 'User', accountIcon, u.Name, 'Sell/Buy IST' ));
        }

        // for (geopointe__GP_Assignment_Area__c gp : [SELECT id, name FROM geopointe__GP_Assignment_Area__c WHERE name in :filterList]) {
        //     results.add(new LookupSearchResult(gp.Id, 'Account', 'standard:account', gp.Name, 'Territory'));
        // }
        
        for (ServiceTerritory rl: [SELECT id, Name FROM ServiceTerritory WHERE name in :filterList]){
            results.add(new LookupSearchResult(rl.Id, 'Service Territory', 'standard:account', rl.Name, 'Region'));
        }

        return results;
    }

    @AuraEnabled
    public static List<Opportunity> getSellerInfo(String sellOpp){
        List<Opportunity> oppResults = new List<Opportunity>();
        List<Opportunity> sellDealInfo = [SELECT Seller_Dealership__r.Name, Seller_Primary_Contact__r.Name, Seller_Primary_Contact__r.Phone, Seller_Primary_Contact__r.Email, Seller_Dealership__r.BillingAddress, Seller_Dealership__r.Id
                                            FROM Opportunity
                                            WHERE Id = :sellOpp];
        return sellDealInfo;

    }
    @AuraEnabled
    public static List<Opportunity> getBuyerInfo(String buyOpp){
        List<Opportunity> oppResults = new List<Opportunity>();
        List<Opportunity> buyDealInfo = [SELECT Buyer_Dealership__r.Name, Buyer_Primary_Contact__r.Name, Buyer_Primary_Contact__r.Phone, Buyer_Primary_Contact__r.Email, Buyer_Dealership__r.BillingAddress, Buyer_Dealership__r.Id
                                            FROM Opportunity
                                            WHERE Id = :buyOpp];
        return buyDealInfo;

    }
    @AuraEnabled
    public static List<Opportunity> getVehicleInfo(String vehOpp){
        List<Opportunity> oppResults = new List<Opportunity>();
        List<Opportunity> vehicleInfo = [SELECT VIN__c, Auction__r.Auction_Lights__c, Auction__r.odometer__c, Auto_sell__c, Auction__r.Year_Make_Model__c, Auction__r.vehicle_id__r.Year__c, Auction__r.vehicle_id__r.Make__c, Auction__r.vehicle_id__r.Model__c, Auction__r.vehicle_id__r.Trim__c
                                            FROM Opportunity
                                            WHERE Id = :vehOpp];
        return vehicleInfo;

    }


    //method to query for the notes field for note updates from users 
    // @AuraEnabled
    // public static void notesSave (String noteInput, String idField){
    //     List<Opportunity> oppUpdate = [SELECT Id, Auction_Notes_2__c FROM Opportunity WHERE Id = :idField];
    //     for(Opportunity o: oppUpdate){
    //         o.Auction_Notes_2__c = noteInput;
    //     }
    //     update oppUpdate;
    // }
}