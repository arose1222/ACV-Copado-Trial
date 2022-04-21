/**
 * Controller Class of PreviousAuctionAlert LWC Component
 * @author Ravi Shukla
 * @since Jan 31st, 2022
 */
public class PreviousAuctionAlertController {
    
    @AuraEnabled
    public static boolean getCaseStatus(String caseId){
        List<Case> listCase = new List<Case>();
        List<Auction__c> listAuction = new List<Auction__c>();
        boolean status = false; 
        listCase = [Select id,RecordType.DeveloperName, VIN__c from Case where id =:caseId and RecordType.DeveloperName = 'Arbitration_Claim'];
        if(listCase.size()>0){
            listAuction = [select id, Name from Auction__c where VIN__c =:listCase[0].VIN__c];
            if(listAuction.size()>1){
              status = true;  
            }
            
        }else{
            status = false;
        } 
        
        return status;
    }
    
}