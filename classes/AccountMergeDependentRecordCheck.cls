public with sharing class AccountMergeDependentRecordCheck {
    

    public static Boolean AccountMergeDependentRecordCheck(Account Acc) {

        Boolean auctionFound = false;
        Boolean caseFound = false;
        if(Acc.Auctions__r.size() > 0 || Acc.BuyerAuctions__r.size() > 0){
            auctionFound = true;
        }
        if(Acc.Cases.size() > 0 || Acc.Cases1__r.size() > 0){
            caseFound = true;
        }
        if(auctionFound || caseFound){
            return true;
        }
        return false; 
    }
}