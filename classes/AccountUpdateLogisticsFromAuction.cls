public class AccountUpdateLogisticsFromAuction {
    public static List<String> accountErrorList = new List<String>();
    public static List<String> auctionErrorList = new List<String>();

    public static void run(List<Auction__c> auctionList) {
        List<Auction__c> acceptedAuctions = new List<Auction__c>();
        List<Auction__c> unwoundAuctions = new List<Auction__c>();
        Set<Id> acceptedIds = new Set<Id>();
        Set<Id> unwoundIds = new Set<Id>();
        for (Auction__c a : auctionList) {
            if (a.Status__c == 'Ended_Unwound') {
                unwoundAuctions.add(a);
                unwoundIds.add(a.Buyer_Dealership__c); //this won't cause issues if the buyer is null, right?
                unwoundIds.add(a.Seller_Dealership__c);
            }
            else {
                acceptedAuctions.add(a);
                acceptedIds.add(a.Buyer_Dealership__c);
                acceptedIds.add(a.Seller_Dealership__c);
            }
        }

        if (!acceptedIds.isEmpty()) {
            Map<Id, Account> acceptedAccountMap = new Map<Id, Account>([SELECT Id, Name, Date_of_First_Buy__c, Date_of_Last_Purchase__c, Purchases_All_Time__c, MTD_Purchases__c, MTD_Sales__c, Date_of_Last_Sale__c, Date_of_First_Sale__c, Wholesale_Units_Sold__c, All_Time_Sales_Gross__c FROM Account WHERE Id IN :acceptedIds FOR UPDATE]);

            acceptedAccountMap = updateLastSaleDate(acceptedAuctions, acceptedAccountMap);
            for (Id a : acceptedAccountMap.keySet()) {
                System.debug(acceptedAccountMap.get(a).Name);
                System.debug(acceptedAccountMap.get(a));
            }
            acceptedAccountMap = insertFirstPurchaseDate(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = insertFirstSaleDate(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = updateLastPurchaseDate(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = updateAllTimePurchases(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = updateMTDPurchased(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = updateMTDSold(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = updateNetSales(acceptedAuctions, acceptedAccountMap);
            acceptedAccountMap = updateGrossSales(acceptedAuctions, acceptedAccountMap);
            flagToggle(acceptedAuctions);
            //update acceptedAccountMap.values();

            for (Id a : acceptedAccountMap.keySet()) {
                System.debug(acceptedAccountMap.get(a).Name);
                System.debug(acceptedAccountMap.get(a));
            }
            Database.SaveResult[] mesgList = Database.update(acceptedAccountMap.values(), false); //will this get errors from running account logistics or no?
            for (Database.SaveResult upRes : mesgList) {
                System.debug(upRes);
                if (!upRes.isSuccess()) {
                    System.debug(upRes.getErrors());
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    AccountUpdateLogisticsFromAuction.accountErrorList.add(errMesg);
                }
            }
        }

        if (!unwoundIds.isEmpty()) {
            Map<Id, Account> unwoundAccountMap = new Map<Id, Account>([SELECT Id, Date_of_First_Buy__c, Date_of_Last_Purchase__c, Date_of_Last_Sale__c, Date_of_First_Sale__c, Purchases_All_Time__c, MTD_Purchases__c, MTD_Sales__c, Purchase_Last_Month__c, Flagged_for_Unwind_Batch__c, Go_Green_Seller__c, Wholesale_Units_Sold__c, All_Time_Sales_Gross__c FROM Account WHERE Id IN :unwoundIds FOR UPDATE]);

            unwoundAccountMap = rollbackFlagger(unwoundAuctions, unwoundAccountMap);
            unwoundAccountMap = rollbackAllTimePurchases(unwoundAuctions, unwoundAccountMap);
            unwoundAccountMap = rollbackMTDAndLastMonthPurchased(unwoundAuctions, unwoundAccountMap);
            unwoundAccountMap = rollbackMTDSold(unwoundAuctions, unwoundAccountMap);
            unwoundAccountMap = rollbackNetSales(unwoundAuctions, unwoundAccountMap);
            flagToggle(unwoundAuctions);
            //update unwoundAccountMap.values();

            Database.SaveResult[] mesgList = Database.update(unwoundAccountMap.values(), false); //will this get errors from running account logistics or no?
            for (Database.SaveResult upRes : mesgList) {
                if (!upRes.isSuccess()) {
                    //error message
                    Database.Error errors = upRes.getErrors()[0];
                    String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                    AccountUpdateLogisticsFromAuction.accountErrorList.add(errMesg);
                }
            }
        }
    }

    //rollbackFlagger
    public static Map<Id, Account> rollbackFlagger(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering rollbackFlagger');
        for (Auction__c unwd : filteredAuctionList) {
            // System.debug(unwd.End_Time__c);
            // System.debug(accountMap.get(unwd.Buyer_Dealership__c).Date_of_First_Buy__c);
            // System.debug(accountMap.get(unwd.Buyer_Dealership__c).Date_of_Last_Purchase__c);
            // System.debug(accountMap.get(unwd.Seller_Dealership__c).Date_of_Last_Sale__c);
            if (unwd.Buyer_Dealership__c != null) {
                if (accountMap.get(unwd.Buyer_Dealership__c) != null) {
                    // System.debug('unwind buyer not null and buyer found in accountMap');
                    // System.debug('Date of Last Purchase: ' + accountMap.get(unwd.Buyer_Dealership__c).Date_of_Last_Purchase__c);
                    if (unwd.End_Time__c == accountMap.get(unwd.Buyer_Dealership__c).Date_of_First_Buy__c) {
                        // System.debug('enter buyerFirst');
                        accountMap.get(unwd.Buyer_Dealership__c).Flagged_for_Unwind_Batch__c = 'buyerFirst';
                    }
                    else if (unwd.End_Time__c == accountMap.get(unwd.Buyer_Dealership__c).Date_of_Last_Purchase__c) {
                        // System.debug('enter buyerLast');
                        accountMap.get(unwd.Buyer_Dealership__c).Flagged_for_Unwind_Batch__c = 'buyerLast';
                    }

                    if (unwd.End_Time__c == accountMap.get(unwd.Buyer_Dealership__c).Date_of_First_Buy__c && unwd.End_Time__c == accountMap.get(unwd.Buyer_Dealership__c).Date_of_Last_Purchase__c) {
                        // System.debug('enter firstAndLast');
                        accountMap.get(unwd.Buyer_Dealership__c).Flagged_for_Unwind_Batch__c = 'firstAndLast';
                    }
                }
            }
            
            if (accountMap.get(unwd.Seller_Dealership__c) != null) {
                if ((unwd.End_Time__c == accountMap.get(unwd.Seller_Dealership__c).Date_of_Last_Sale__c) && (accountMap.get(unwd.Seller_Dealership__c).Go_Green_Seller__c == false)) {
                    //could do the check for go green in here
                    // System.debug('enter seller');
                    accountMap.get(unwd.Seller_Dealership__c).Flagged_for_Unwind_Batch__c = 'seller';
                }
            }
        }
        return accountMap;
    }

    //Insert First Purchase Date
    public static Map<Id, Account> insertFirstPurchaseDate(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering first purchase date');
        Map<Id, Date> accountTimeMap = new Map<Id, Date>();
        for (Auction__c a : filteredAuctionList) {
            if (a.Buyer_Dealership__c != null) {
                if (accountMap.get(a.Buyer_Dealership__c).Date_of_First_Buy__c == null) {
                    Integer Day = a.End_Time__c.Day();
                    Integer Month = a.End_Time__c.Month();
                    Integer Year = a.End_Time__c.Year();
                    DateTime tempTime = DateTime.newInstance(Year, Month, Day, 12, 0, 0);
                    Date actualDate = tempTime.date();
                    //Date actualDate = Date.newInstance(Year,Month,Day);
                    //Date actualDate = date.valueOf(a.End_Time__c);
                    accountTimeMap.put(a.Buyer_Dealership__c, actualDate);
                }
                //having this check here instead of below makes the code cleaner and removes unnessesary code
            }
            // if (accountTimeMap.get(a.Buyer_Dealership__c) == null && a.Buyer_Dealership__c != null) {
            //     accountTimeMap.put(a.Buyer_Dealership__c, a.End_Time__c);
            // }
            // else if (accountTimeMap.get(a.Buyer_Dealership__c) > a.End_Time__c && a.Buyer_Dealership__c != null) {
            //     accountTimeMap.put(a.Buyer_Dealership__c, a.End_Time__c);
            // }
        }

        for (Id accId : accountTimeMap.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).Date_of_First_Buy__c = accountTimeMap.get(accId);
            }
        }
        return accountMap;
    }

    public static Map<Id, Account> insertFirstSaleDate(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering first sale date');
        Map<Id, Date> accountTimeMap = new Map<Id, Date>();
        for (Auction__c a : filteredAuctionList) {
            if (a.Seller_Dealership__c != null) {
                if (accountMap.get(a.Seller_Dealership__c).Date_of_First_Sale__c == null) {
                    Integer Day = a.End_Time__c.Day();
                    Integer Month = a.End_Time__c.Month();
                    Integer Year = a.End_Time__c.Year();
                    DateTime tempTime = DateTime.newInstance(Year, Month, Day, 12, 0, 0);
                    Date actualDate = tempTime.date();
                    //Date actualDate = Date.newInstance(Year,Month,Day);
                    //Date actualDate = date.valueOf(a.End_Time__c);
                    accountTimeMap.put(a.Seller_Dealership__c, actualDate);
                }
            }
        }

        for (Id accId : accountTimeMap.keySet()) {
            if (accountMap.get(accId) != null) {
                // System.debug('Value of accountTimeMap: ' + date.valueOf(accountTimeMap.get(accId)));
                accountMap.get(accId).Date_of_First_Sale__c = accountTimeMap.get(accId);
                // System.debug('New Value for Date_of_First_Sale__c: ' + accountMap.get(accId).Date_of_First_Sale__c);
            }
        }
        return accountMap;
    }

    //Update Last Purchase Date
    public static Map<Id, Account> updateLastPurchaseDate(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap){
        // System.debug('entering last purchase date');
        Map<Id, Date> accountTimeMap = new Map<Id, Date>();
        for (Auction__c a : filteredAuctionList) {
            if (a.Buyer_Dealership__c != null && accountMap.get(a.Buyer_Dealership__c).Date_of_Last_Purchase__c != null) {
                if (a.End_Time__c > accountMap.get(a.Buyer_Dealership__c).Date_of_Last_Purchase__c) {
                    Integer Day = a.End_Time__c.Day();
                    Integer Month = a.End_Time__c.Month();
                    Integer Year = a.End_Time__c.Year();
                    DateTime tempTime = DateTime.newInstance(Year, Month, Day, 12, 0, 0);
                    Date actualDate = tempTime.date();
                    //Date actualDate = Date.newInstance(Year,Month,Day);
                    //Date actualDate = date.valueOf(a.End_Time__c);
                    accountTimeMap.put(a.Buyer_Dealership__c, actualDate);
                }
                //so this should now only add the auction's end time to accountTimeMap if the end time is newer than date of last purchase
            }
            else if (a.Buyer_Dealership__c != null && accountMap.get(a.Buyer_Dealership__c).Date_of_Last_Purchase__c == null) {
                Integer Day = a.End_Time__c.Day();
                Integer Month = a.End_Time__c.Month();
                Integer Year = a.End_Time__c.Year();
                DateTime tempTime = DateTime.newInstance(Year, Month, Day, 12, 0, 0);
                Date actualDate = tempTime.date();
                //Date actualDate = Date.newInstance(Year,Month,Day);
                //Date actualDate = date.valueOf(a.End_Time__c);
                accountTimeMap.put(a.Buyer_Dealership__c, actualDate);
            }
            // if (accountTimeMap.get(a.Buyer_Dealership__c) == null && a.Buyer_Dealership__c != null) {
            //     accountTimeMap.put(a.Buyer_Dealership__c, a.End_Time__c);
            // }
            // else if (accountTimeMap.get(a.Buyer_Dealership__c) < a.End_Time__c && a.Buyer_Dealership__c != null) {
            //     accountTimeMap.put(a.Buyer_Dealership__c, a.End_Time__c);
            // }
        }

        for (Id accId : accountTimeMap.keySet()) {
            if (accountMap.get(accId) != null) { // i think i technically don't need this check but i'll keep it in anyway
                accountMap.get(accId).Date_of_Last_Purchase__c = accountTimeMap.get(accId);
            }
        }
        return accountMap;
    }

    //Update Last Sale Date
    public static Map<Id, Account> updateLastSaleDate(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering last sale date');
        Map<Id, Date> accountTimeMap = new Map<Id, Date>();
        for (Auction__c a : filteredAuctionList) {
            if (a.Seller_Dealership__c != null && accountMap.get(a.Seller_Dealership__c).Date_of_Last_Sale__c != null) {
                if (a.End_Time__c > accountMap.get(a.Seller_Dealership__c).Date_of_Last_Sale__c) {
                    Integer Day = a.End_Time__c.Day();
                    Integer Month = a.End_Time__c.Month();
                    Integer Year = a.End_Time__c.Year();
                    DateTime tempTime = DateTime.newInstance(Year, Month, Day, 12, 0, 0);
                    Date actualDate = tempTime.date();
                    //Date actualDate = Date.newInstance(Year,Month,Day);
                    //Date actualDate = date.valueOf(a.End_Time__c);
                    accountTimeMap.put(a.Seller_Dealership__c, actualDate);
                }
                //so this should now only add the auction's end time to the accountTimeMap if the end time is newer than the last sold date
            }
            else if (a.Seller_Dealership__c != null && accountMap.get(a.Seller_Dealership__c).Date_of_Last_Sale__c == null) {
                Integer Day = a.End_Time__c.Day();
                Integer Month = a.End_Time__c.Month();
                Integer Year = a.End_Time__c.Year();
                DateTime tempTime = DateTime.newInstance(Year, Month, Day, 12, 0, 0);
                Date actualDate = tempTime.date();
                //Date actualDate = Date.newInstance(Year,Month,Day);
                //Date actualDate = date.valueOf(a.End_Time__c);
                accountTimeMap.put(a.Seller_Dealership__c, actualDate);
            }
            // if (accountTimeMap.get(a.Seller_Dealership__c) == null) {
            //     accountTimeMap.put(a.Seller_Dealership__c, a.End_Time__c);
            // }
            // else if (accountTimeMap.get(a.Seller_Dealership__c) < a.End_Time__c) {
            //     accountTimeMap.put(a.Seller_Dealership__c, a.End_Time__c);
            // }
        }
        for (Id accId : accountTimeMap.keySet()) {
            // System.debug(accountTimeMap.get(accId));
            // System.debug(accountTimeMap);
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).Date_of_Last_Sale__c = accountTimeMap.get(accId);
                //System.debug(accountMap.get(accId).Date_of_Last_Sale__c);
            }
        }
        return accountMap;
    }

    //MTD Purchased
    public static Map<Id, Account> updateMTDPurchased(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering MTD purchased');
        Map<Id, Integer> MTDPurchases = new Map<Id, Integer>();
        for (Auction__c a : filteredAuctionList) {
            if (a.End_Time__c >= System.Today().toStartofMonth()) {
                if (a.Buyer_Dealership__c != null) {
                    if (MTDPurchases.get(a.Buyer_Dealership__c) == null) {
                        MTDPurchases.put(a.Buyer_Dealership__c, 1);
                    }
                    else {
                        MTDPurchases.put(a.Buyer_Dealership__c, (MTDPurchases.get(a.Buyer_Dealership__c) + 1));
                    }
                }
            }
        }

        for (Id accId : MTDPurchases.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).MTD_Purchases__c = accountMap.get(accId).MTD_Purchases__c + MTDPurchases.get(accId);
            }
        }
        return accountMap;
    }

    //Rollback MTD Purchased and Last Month Purchased
    public static Map<Id, Account> rollbackMTDAndLastMonthPurchased(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering rollback MTD and last month purchased');
        Map<Id, Integer> MTDPurchases = new Map<Id, Integer>();
        Map<Id, Integer> lastMonthPurchases = new Map<Id, Integer>();

        for (Auction__c a : filteredAuctionList) {
            if (a.Buyer_Dealership__c != null) {
                if ((a.End_Time__c <= System.Today().toStartofMonth().addDays(-1)) && (a.End_Time__c >= System.Today().toStartOfMonth().addMonths(-1))) {
                    //decrease Purchase_Last_Month__c
                    if (lastMonthPurchases.get(a.Buyer_Dealership__c) == null) {
                        lastMonthPurchases.put(a.Buyer_Dealership__c, 1);
                    }
                    else {
                        lastMonthPurchases.put(a.Buyer_Dealership__c, (lastMonthPurchases.get(a.Buyer_Dealership__c) + 1));
                    }
                }
                else if (a.End_Time__c >= System.Today().toStartOfMonth()) {
                    //decrease MTD_Purchases__c
                    if (MTDPurchases.get(a.Buyer_Dealership__c) == null) {
                        MTDPurchases.put(a.Buyer_Dealership__c, 1);
                    }
                    else {
                        MTDPurchases.put(a.Buyer_Dealership__c, (MTDPurchases.get(a.Buyer_Dealership__c) + 1));
                    }
                }
            }
        }

        for (Id accId : lastMonthPurchases.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).Purchase_Last_Month__c = accountMap.get(accId).Purchase_Last_Month__c - lastMonthPurchases.get(accId);
            }
        }
        for (Id accId : MTDPurchases.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).MTD_Purchases__c = accountMap.get(accId).MTD_Purchases__c - MTDPurchases.get(accId);
            }
        }
        return accountMap;
    }

    //MTD Sold
    public static Map<Id, Account> updateMTDSold(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        //this is also going to need a rollback function like for MTD Purchased but without last month
        Map<Id, Integer> MTDSales = new Map<Id, Integer>();
        for (Auction__c a : filteredAuctionList) {
            if (a.End_Time__c >= System.Today().toStartofMonth()) {
                if (a.Seller_Dealership__c != null) {
                    if (MTDSales.get(a.Seller_Dealership__c) == null) {
                        MTDSales.put(a.Seller_Dealership__c, 1);
                    }
                    else {
                        MTDSales.put(a.Seller_Dealership__c, (MTDSales.get(a.Seller_Dealership__c) + 1));
                    }
                }
            }
        }

        for (Id accId : MTDSales.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).MTD_Sales__c = accountMap.get(accId).MTD_Sales__c + MTDSales.get(accId);
            }
        }
        return accountMap;
    }

    //rollback MTD Sold
    public static Map<Id, Account> rollbackMTDSold(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        Map<Id, Integer> MTDSales = new Map<Id, Integer>();

        for (Auction__c a : filteredAuctionList) {
            if (a.Seller_Dealership__c != null) {
                if (a.End_Time__c >= System.Today().toStartOfMonth()) {
                    //decrease MTD_Sales__c
                    if (MTDSales.get(a.Seller_Dealership__c) == null) {
                        MTDSales.put(a.Seller_Dealership__c, 1);
                    }
                    else {
                        MTDSales.put(a.Seller_Dealership__c, (MTDSales.get(a.Seller_Dealership__c) + 1));
                    }
                }
            }
        }

        for (Id accId : MTDSales.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).MTD_Sales__c = accountMap.get(accId).MTD_Sales__c - MTDSales.get(accId);
            }
        }
        return accountMap;
    }

    //All Time Purchases
    //if 0 search historical data, if not 0 just look at recent purchases?
    public static Map<Id, Account> updateAllTimePurchases(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering all time purchases');
        Map<Id, Integer> allTimePurchases = new Map<Id, Integer>();

        for (Auction__c a : filteredAuctionList) {
            if (a.Buyer_Dealership__c != null) {
                if (allTimePurchases.get(a.Buyer_Dealership__c) == null) {
                    allTimePurchases.put(a.Buyer_Dealership__c, 1);
                }
                else {
                    allTimePurchases.put(a.Buyer_Dealership__c, (allTimePurchases.get(a.Buyer_Dealership__c) + 1));
                }
            }
        }

        for (Id accId : allTimePurchases.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).Purchases_All_Time__c = accountMap.get(accId).Purchases_All_Time__c + allTimePurchases.get(accId);
            }
        }
        return accountMap;
    }

    public static Map<Id, Account> rollbackAllTimePurchases(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering rollback all time purchased');
        //pass in list of auctions where:
        //buyer_dealership != null
        //status = ended_unwound
        //for each account decrease Purchases_All_Time__c by 1
        Map<Id, Integer> allTimePurchases = new Map<Id, Integer>();
        for (Auction__c a : filteredAuctionList) {
            if (a.Buyer_Dealership__c != null) {
                if (allTimePurchases.get(a.Buyer_Dealership__c) == null) {
                    allTimePurchases.put(a.Buyer_Dealership__c, 1);
                }
                else {
                    allTimePurchases.put(a.Buyer_Dealership__c, (allTimePurchases.get(a.Buyer_Dealership__c) + 1));
                }
            }
        }

        for (Id accId : allTimePurchases.keySet()) {
            if (accountMap.get(accId) != null) {
                accountMap.get(accId).Purchases_All_Time__c = accountMap.get(accId).Purchases_All_Time__c - allTimePurchases.get(accId);
            }
        }
        return accountMap;
    }

    //this maps to the All Time Sales (Net) field
    public static Map<Id, Account> updateNetSales(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering net sales');
        //need to figure out if Wholesale_Units_Sold__c will be populated with code or not
        //also, need to figure out if i need to handle unwinds for it (if we are calculating net or gross)
        Map<Id, Integer> wholesaleUnitsSold = new Map<Id, Integer>();

        for (Auction__c a : filteredAuctionList) {
            if (a.Seller_Dealership__c != null) {
                if (wholesaleUnitsSold.get(a.Seller_Dealership__c) == null) {
                    wholesaleUnitsSold.put(a.Seller_Dealership__c, 1);
                }
                else {
                    wholesaleUnitsSold.put(a.Seller_Dealership__c, (wholesaleUnitsSold.get(a.Seller_Dealership__c) + 1));
                }
            }
        }

        for (Id accId : wholesaleUnitsSold.keySet()) {
            if (accountMap.get(accId) != null) {
                //Adjusted this to check if whole sale units is null while Kendall is waiting for the report in forder to data load
                if(accountMap.get(accId).Wholesale_Units_Sold__c != null){
                    accountMap.get(accId).Wholesale_Units_Sold__c = accountMap.get(accId).Wholesale_Units_Sold__c + wholesaleUnitsSold.get(accId);
                }
            }
        }
        return accountMap;
    }

    public static Map<Id, Account> rollbackNetSales(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering rollback net sales');
        Map<Id, Integer> wholesaleUnitsSold = new Map<Id, Integer>();
        for (Auction__c a : filteredAuctionList) {
            if (a.Seller_Dealership__c != null) {
                if (wholesaleUnitsSold.get(a.Seller_Dealership__c) == null) {
                    wholesaleUnitsSold.put(a.Seller_Dealership__c, 1);
                }
                else {
                    wholesaleUnitsSold.put(a.Seller_Dealership__c, (wholesaleUnitsSold.get(a.Seller_Dealership__c) + 1));
                }
            }
        }

        for (Id accId : wholesaleUnitsSold.keySet()) {
            if (accountMap.get(accId) != null) {
                if (accountMap.get(accId).Wholesale_Units_Sold__c != null && accountMap.get(accId).Go_Green_Seller__c == false) {
                    accountMap.get(accId).Wholesale_Units_Sold__c = accountMap.get(accId).Wholesale_Units_Sold__c - wholesaleUnitsSold.get(accId);
                }
            }
        }
        return accountMap;
    }

    //this maps to the All Time Sales (Gross) field
    //this does not get unwound
    public static Map<Id, Account> updateGrossSales(List<Auction__c> filteredAuctionList, Map<Id, Account> accountMap) {
        // System.debug('entering gross sales');
        //need to figure out if All_Time_Sales_Gross__c will be populated with code or not
        Map<Id, Integer> grossSales = new Map<Id, Integer>();

        for (Auction__c a : filteredAuctionList) {
            if (a.Seller_Dealership__c != null) {
                if (grossSales.get(a.Seller_Dealership__c) == null) {
                    grossSales.put(a.Seller_Dealership__c, 1);
                }
                else {
                    grossSales.put(a.Seller_Dealership__c, (grossSales.get(a.Seller_Dealership__c) + 1));
                }
            }
        }

        for (Id accId : grossSales.keySet()) {
            if (accountMap.get(accId) != null) {
                if(accountMap.get(accId).All_Time_Sales_Gross__c != null){
                    accountMap.get(accId).All_Time_Sales_Gross__c = accountMap.get(accId).All_Time_Sales_Gross__c + grossSales.get(accId);
                }
            }
        }
        return accountMap;
    }

    public static void flagToggle(List<Auction__c> filteredAuctionList) {
        // System.debug('entering counter toggle');
        for (Auction__c a : filteredAuctionList) {
            a.Counted_for_Account_Logistics__c = !a.Counted_for_Account_Logistics__c;
        }

        Database.SaveResult[] mesgList = Database.update(filteredAuctionList, false); //will this get errors from running account logistics or no?
        for (Database.SaveResult upRes : mesgList) {
            if (!upRes.isSuccess()) {
                //error message
                Database.Error errors = upRes.getErrors()[0];
                String errMesg = 'ERROR on Id: ' + upRes.getId() + '<br/>With Status Code of: ' + errors.getStatusCode() + '<br/>And Error of: ' + errors.getMessage();
                AccountUpdateLogisticsFromAuction.auctionErrorList.add(errMesg);
            }
        }
    }
}