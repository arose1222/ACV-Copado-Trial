/**
 * This class is the Extension controller for the AuctinoKillWrapper.vfpage
 * and the controller for the AuctionKill.lwc
 * @author James Andre LaCour
 */
public without sharing class AuctionKillController {
    /****************Class Variables**********************/
    public List<Inventory_Life_Cycle__c> selectedRecords {get;set;}     //Used in VFPage
    public String selectedRecordsJSON {get;set;}                        //Used in VFPage
    public static final Set<String> INELIGIBLE_KILL_STATUSES_SET = new Set<String>{ 'Vehicle Sold', 'Vehicle Unsold' };
    /****************Inner Classes************************/
    /**
     * This inner class host the return wrapper that we send back to
     * the LWC on init and submit
     * @author James Andre LaCour
     */
    public class ReturnWrapper{
        public String errorMessage;
        public String successMessage;
        public List<InvalidInventoryLifeCycle> invalidILCList;
        public List<AuctionWrapper> eligibleAuctions;
        public Contact runningUser;
        public List<String> activeOpenSections;
        public ReturnWrapper(){
            errorMessage = null;
            successMessage = null;
            invalidILCList = null;
            eligibleAuctions = null;
            runningUser = null;
            activeOpenSections=new List<String>();
        }
    }
    /**
     * This inner class is a structure to hold Auction data allowing
     * it to display on the LWC
     * @author James Andre LaCour
     */
    public class AuctionWrapper{
        public Id id;
        public String vin;
        public String yearMakeModelTrim;
        public String idUrl;
        public String auctionId;
        public String status;
        public String name;
        public Decimal reservePrice;
        public AuctionWrapper(Inventory_Life_Cycle__c ilc){
            id = ilc.Most_Recent_Auction__c;
            idURL = '/' + ilc.Most_Recent_Auction__c;
            vin = ilc.VIN__c;
            yearMakeModelTrim = ilc.Year_Make_Model_Trim_Text__c;
            auctionId = ilc.Most_Recent_Auction__r.Id__c;
            status = ilc.Most_Recent_Auction__r.status__c;
            name = ilc.Most_Recent_Auction__r.Name;
            reservePrice = ilc.Most_Recent_Auction__r.floor_price__c;
        }
        public AuctionWrapper(){/*Blank default constructor*/}
    }
    /**
     * Inner class for ILC's that are ineligible to be killed
     * @author James Andre LaCour
     */
    public class InvalidInventoryLifeCycle{
        public Inventory_Life_Cycle__c ilc;
        public String errorMessage;
        public InvalidInventoryLifeCycle( Inventory_Life_Cycle__c ilc, String errorMessage ){
            this.ilc = ilc;
            this.errorMessage = errorMessage;
        }
    }
    /****************Class Constructors*******************/
    /**
     * Constructor for the VF Page needed when this class is being used as a List Button
     * This allows us to get the selected values from the list view
     * @param controller - Salesforce Standard Class that allows you to get results from List Views
     */
    public AuctionKillController(ApexPages.StandardSetController controller) {
        // From the New Inventory Life Cycle View
        if( ApexPages.currentPage().getParameters().get('ilcJson') != '' && ApexPages.currentPage().getParameters().get('ilcJson') != null && ApexPages.currentPage().getParameters().get('ilcJson') != 'undefined' ){
            selectedRecordsJSON = ApexPages.currentPage().getParameters().get('ilcJson');
        }else{
        // From the standard Salesforce Inventory Life Cycle View
            selectedRecords = controller.getSelected();
            selectedRecordsJSON = JSON.serialize(selectedRecords);
        }
    }
    /****************Helper Methods***********************/
    /**
     * intialize method to gather data on LWC load
     * @param ilcJsonString - A JSON serialized string of the List of selected records from the List View (passed in via the VF Page)
     * @return JSON String of a Return Wrapper
     */
    @AuraEnabled(Cacheable=true)
    public static String doInit( String ilcJsonString ){
        //User must have ACV User Id populated for this call out
        ReturnWrapper rw = new ReturnWrapper();
        String runningUserEmailAddress = UserInfo.getUserEmail();
        Map<String, Contact> runningUserMap = ACVUtility.getAcvUserId( new Set<String>{ runningUserEmailAddress } );
        if( runningUserMap.size() != 1 || (runningUserMap.size() == 1 && runningUserMap.get( runningUserEmailAddress ) != null && String.isBlank(runningUserMap.get( runningUserEmailAddress ).Id__c))){
            rw.errorMessage = 'Sorry, we are seeing issues with your access to use this tool. Please contact your Salesforce Administrator.';
            return JSON.serialize(rw);
        }else{
            rw.runningUser = runningUserMap.get( runningUserEmailAddress );
        }
        //ilcJsonString comes in as a JSON List string so first we need to deserialized it to a List and then 
        //Cast it to a Map to actually get the values
        Set<Id> ilcIds = new Set<Id>();
        List<Object> selectedIlcList = (List<Object>)JSON.deserializeUntyped(ilcJsonString);
        for( Object ilc : selectedIlcList ){
            Map<String,Object> ilcFieldMap = (Map<String,Object>)ilc;
            ilcIds.add((Id)ilcFieldMap.get('Id'));
        }
        //if no records were selected, throw an error
        if( ilcIds.size() == 0 ){
            rw.errorMessage = 'To use this tool, you must select at least one Inventory Life Cycle row.';
            return JSON.serialize(rw);
        }
        List<Inventory_Life_Cycle__c> ilcList = [ SELECT Id, VIN__c, Year_Make_Model_Trim__c, Most_Recent_Auction__c, Status__c, Year_Make_Model_Trim_Text__c,
                                                         Most_Recent_Auction__r.Name, Most_Recent_Auction__r.Id__c, Most_Recent_Auction__r.status__c,Most_Recent_Auction__r.Floor_Price__c
                                                  FROM Inventory_Life_Cycle__c WHERE Id IN :ilcIds 
        ];
        for( Inventory_Life_Cycle__c ilc : ilcList ){
            String errorMessage = getErrorMessage( ilc );
            if( String.isBlank( errorMessage ) ){
                AuctionWrapper aw = new AuctionWrapper(ilc);
                if(rw.eligibleAuctions == null) rw.eligibleAuctions = new List<AuctionWrapper>();
                rw.eligibleAuctions.add(aw);
                rw.activeOpenSections.add('Auctions');
            }else{
                if(rw.invalidILCList == null ) rw.invalidILCList = new List<InvalidInventoryLifeCycle>();
                rw.invalidILCList.add( new InvalidInventoryLifeCycle(ilc, errorMessage) );
                rw.activeOpenSections.add('ILCS');
            }
        }
        //If none of the Inventory Life Cycle records have a Most Recent Auction, throw an error message
        if( rw.eligibleAuctions == null || rw.eligibleAuctions.size() == 0 ){
            rw.errorMessage = 'Sorry, none of the selected records have an eligible Auction to end.';
            return JSON.serialize(rw);
        }
        rw.successMessage = 'Successful';
        return JSON.serialize(rw);
    }
    /**
     * runs on submission of LWC
     * @param dataSubmitWrapperJSON - A JSON serialized string of the data needed on return to save
     * @return JSON String of a Return Wrapper. Mainly hosts success or error message
     */
    @AuraEnabled
    public static String submitKillAuction( String dataSubmitWrapperJSON ){
        ReturnWrapper rw = new ReturnWrapper();
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSubmitWrapperJSON);
        List<Integer> auctionIds = new List<Integer>();
        Map<Integer,AuctionWrapper> auctionIdToAuctionWrapper = new Map<Integer,AuctionWrapper>();
        //Gathers data from the submission Json
        for( Object obj : (List<Object>)dataMap.get('auctions') ){
            Map<String,Object> objMap = (Map<String,Object>)obj;
            auctionIds.add( Integer.valueOf(objMap.get('auctionId')) );     //Used in Callout
            AuctionWrapper awTemp = new AuctionWrapper();
            awTemp.vin = String.valueOf(objMap.get('vin'));
            awTemp.name = String.valueOf(objMap.get('name'));
            awTemp.id = (Id)objMap.get('id');
            auctionIdToAuctionWrapper.put(Integer.valueOf(objMap.get('auctionId')),awTemp);
        }
        //Gets running User info from the return that we got on Intialize
        Map<String,Object> runningAcvUser = (Map<String,Object>)dataMap.get('currentUser');
        Integer acvUserId = Integer.valueOf(runningAcvUser.get('ID__c'));
        String userEmail = String.valueOf(runningAcvUser.get('Email'));
        //one note is used for all Auctions
        String notes = String.valueOF(dataMap.get('notes'));
        HttpResponse res = new Http().send( AuctionKillAPI.createAuctionKillRequest(auctionIds, acvUserId, userEmail, notes) );
        List<Auction__c> auctionsToUpdate = new List<Auction__c>();
        if( res.getStatusCode() >= 400 ){
            rw.errorMessage = 'There was an issue with your request. Please contact a Salesforce Administrator to help you with the Auction(s) you wish to end.';
        }else{
            //Makes two messages - one for success and one for error. Both have the potential to show up
            AuctionKillApiResponse akRes = AuctionKillApiResponse.parse(res.getBody());
            if( akRes.data.successes != null && akRes.data.successes.size() > 0 ){
                rw.successMessage = 'These Auction(s) were successfully ended:\n';
                //If success, we update the Auction Status to indicate its been ended
                for( AuctionKillApiResponse.Data successResponse : akRes.data.successes ){
                    AuctionWrapper aw = auctionIdToAuctionWrapper.get(successResponse.auctionid);
                    Auction__c tempAuction = new Auction__c();
                    tempAuction.status__c = AuctionKillAPI.AUCTION_KILL_STATUS;
                    tempAuction.Id = aw.id;
                    auctionsToUpdate.add(tempAuction);
                    rw.successMessage += 'VIN: ' + aw.vin + ' Auction #' + aw.name + '\n'; 
                }
            }
            if( akRes.data.errors != null && akRes.data.errors.size() > 0 ){
                rw.errorMessage = 'There were errors with some of the Auctions. Here is a list:\n';
                for( AuctionKillApiResponse.Data errorResponse : akRes.data.errors ){
                    AuctionWrapper aw = auctionIdToAuctionWrapper.get(errorResponse.auctionid);
                    rw.errorMessage += 'VIN: ' + aw.vin + ' Auction #' + aw.name + ' - ' + errorResponse.message + '\n'; 
                }
            }
            if( auctionsToUpdate.size() > 0 ){
                update auctionsToUpdate;
            }
        }
        return JSON.serialize(rw);
    }
    /**
     * Returns an Error message based on the ILC and condition's
     * @param ilc - the Inventory Record that has an error message
     * @return string with the proper Error MEssage
     */
    public static String getErrorMessage( Inventory_Life_Cycle__c ilc ){
        String errorMessage = '';
        if( String.isBlank(ilc.Most_Recent_Auction__c) ){
            errorMessage = 'No Auction Record Found';
        }else if( ilc.Status__c.startsWithIgnoreCase(AuctionLaunchExt.SCHEDULING_PREFIX) ){
            errorMessage = 'This Inventory record can not be terminated as it is currently processing';
        }else if( INELIGIBLE_KILL_STATUSES_SET.contains(ilc.Status__c) ){
            errorMessage = 'A car in Vehicle Sold or Unsold can not be killed';
        }
        return errorMessage;
    }
}