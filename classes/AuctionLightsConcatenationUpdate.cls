public class AuctionLightsConcatenationUpdate {
    public static void run(List<Auction__c> objectList) {
        List<Auction__c> auctionList = (List<Auction__c>)objectList;
        for (Auction__c a : auctionList) {
            if (a.Green_Light__c == true && a.Yellow_Light__c == true && a.Blue_Light__c == true) {
                a.Auction_Lights_Concatenation__c = 'gyb';
            }
            else if (a.Green_Light__c == true && a.Yellow_Light__c == true && a.Blue_Light__c == false) {
                a.Auction_Lights_Concatenation__c = 'gy';
            }
            else if (a.Green_Light__c == true && a.Yellow_Light__c == false && a.Blue_Light__c == true) {
                a.Auction_Lights_Concatenation__c = 'gb';
            }
            else if (a.Green_Light__c == false && a.Yellow_Light__c == true && a.Blue_Light__c == true) {
                a.Auction_Lights_Concatenation__c = 'yrb';
            }
            else if (a.Green_Light__c == true && a.Yellow_Light__c == false && a.Blue_Light__c == false) {
                a.Auction_Lights_Concatenation__c = 'g';
            }
            else if (a.Green_Light__c == false && a.Yellow_Light__c == true && a.Blue_Light__c == false) {
                a.Auction_Lights_Concatenation__c = 'yr';
            }
            else if (a.Green_Light__c == false && a.Yellow_Light__c == false && a.Blue_Light__c == true) {
                a.Auction_Lights_Concatenation__c = 'rb';
            }
            else if (a.Green_Light__c == false && a.Yellow_Light__c == false && a.Blue_Light__c == false) {
                a.Auction_Lights_Concatenation__c = 'r';
            }
        }
    }
}