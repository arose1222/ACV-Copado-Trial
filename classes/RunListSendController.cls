/**
 * This class is the Extension controller for the RunListSendWrapper.vfpage
 * and the controller for the RunListSend.lwc
 * @author James Andre LaCour
 */
public without sharing class RunListSendController {
    /****************Class Variables**********************/
    public List<Inventory_Life_Cycle__c> selectedRecords {get;set;}     //Used in VFPage
    public String selectedRecordsJSON {get;set;}                        //Used in VFPage
    public static final String SCHEDULING_TO_RUNLIST_STATUS = AuctionLaunchExt.SCHEDULING_PREFIX + RunListAPI.RUN_LIST_LAUNCHING_STATUS_SUFFIX;
    /****************Inner Classes************************/
    /**
     * This inner class host the return wrapper that we send back to
     * the LWC on init and submit
     * @author James Andre LaCour
     */
    public class ReturnWrapper{
        public String errorMessage;
        public String successMessage;
        public List<InventoryRow> invalidILCList;
        public List<ConditionReportWrapper> eligibleCRs;
        public Set<String> activeOpenSections;
        public ReturnWrapper(){
            errorMessage = null;
            successMessage = null;
            invalidILCList = null;
            eligibleCRs = null;
            activeOpenSections=new Set<String>();
        }
    }
    /**
     * This inner class is a structure to hold Condition Report data allowing
     * it to display on the LWC
     * @author James Andre LaCour
     */
    public class ConditionReportWrapper{
        public Id id;
        public String vin;
        public String yearMakeModelTrim;
        public String idUrl;
        public String savedAuctionId;
        public String ilcId;
        public Decimal reservePrice;
        public ConditionReportWrapper(Inventory_Life_Cycle__c ilc){
            id = ilc.Most_Recent_Condition_Report__c;
            idURL = '/' + ilc.Most_Recent_Condition_Report__c;
            vin = ilc.VIN__c;
            yearMakeModelTrim = ilc.Year_Make_Model_Trim__c;
            savedAuctionId = ilc.Most_Recent_Condition_Report__r.ACV_Saved_Auction_Id__c;
            reservePrice = ilc.Most_Recent_Condition_Report__r.floor_price__c;
            ilcId = ilc.Id;
        }
    public ConditionReportWrapper(){/*Blank default constructor*/}
    }
    /**
     * This inner class is a structure to hold an Inventory Record with Message
     * @author James Andre LaCour
     */
    public class InventoryRow{
        public Inventory_Life_Cycle__c ilc;
        public string errorMessage;
        public InventoryRow( Inventory_Life_Cycle__c ilc, String message ){
            this.ilc = ilc;
            this.errorMessage = message;
        }
        public InventoryRow(){/*Blank default constructor*/}
    }
    /****************Class Constructors*******************/
    /**
     * Constructor for the VF Page needed when this class is being used as a List Button
     * This allows us to get the selected values from the list view
     * @param controller - Salesforce Standard Class that allows you to get results from List Views
     */
    public RunListSendController(ApexPages.StandardSetController controller) {
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
        ReturnWrapper rw = new ReturnWrapper();
        //User must have ACV USer Id Populate dfor this Callout
        User runningUser = getRunningUserInfoFromId( UserInfo.getUserId() );
        if( runningUser == null || String.isBlank(runningUser.Id__c) ){
            rw.errorMessage = 'Sorry, we are seeing issues with your access to use this tool. Please contact your Salesforce Administrator.';
            return JSON.serialize(rw);
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
        //Gather Condition Report data from Inventory Life Cycle
        List<Inventory_Life_Cycle__c> ilcList = [ SELECT Id, Client__c, Client__r.Name, VIN__c, Year_Make_Model_Trim__c, Year_Make_Model_Trim_Text__c, Most_Recent_Condition_Report__c, Status__c, Client__r.Dealership_Id__c,
                                                         Most_Recent_Condition_Report__r.ACV_Saved_Auction_Id__c, Most_Recent_Condition_Report__r.Floor_Price__c
                                                  FROM Inventory_Life_Cycle__c WHERE Id IN :ilcIds 
        ];
        //Generate a set of Dealerships to there Related Contacts as you must be part of the Dealership to send to run list
        Set<Id> dealershipAcctIds = new Set<Id>();
        for( Inventory_Life_Cycle__C ilc : ilcList ){
            if( ilc.Client__c != null && !dealershipAcctIds.contains(ilc.Client__c) ) dealershipAcctIds.add(ilc.Client__c);
        }
        Map<Id, Set<String>> dealerAcctIdToRealtedContactsMap = new Map<Id, Set<String>>();
        if( dealershipAcctIds.size() > 0 ){
            for( Affiliation__c af : [SELECT Id, Contact__c, Contact__r.Id__c, Account__c FROM Affiliation__c WHERE Account__c IN :dealershipAcctIds AND Active__c = true ] ){
                if( dealerAcctIdToRealtedContactsMap.get(af.Account__c) == null ) dealerAcctIdToRealtedContactsMap.put( af.Account__c, new Set<String>() );
                if( af.Contact__c != null && String.isNotBlank(af.Contact__r.Id__c) ){
                    dealerAcctIdToRealtedContactsMap.get(af.Account__c).add(af.Contact__r.Id__c);
                }
            }
        }
        for( Inventory_Life_Cycle__c ilc : ilcList ){
            if( !ilc.Status__c.startsWithIgnoreCase(AuctionLaunchExt.SCHEDULING_PREFIX) && String.isNotBlank(ilc.Most_Recent_Condition_Report__c) && 
                ilc.Client__c != null && dealerAcctIdToRealtedContactsMap.get(ilc.Client__c) != null && dealerAcctIdToRealtedContactsMap.get(ilc.Client__c).contains(runningUser.Id__c ) 
            ){
                //If we don't have the needed items for the endpoint OR, don't allow it to send
                if( String.isBlank(ilc.Most_Recent_Condition_Report__r.ACV_Saved_Auction_Id__c) /*|| ilc.Most_Recent_Condition_Report__r.Floor_Price__c == null || ilc.Most_Recent_Condition_Report__r.Floor_Price__c < 20 || ilc.Most_Recent_Condition_Report__r.Floor_Price__c == 999999*/ ){
                    if(rw.invalidILCList == null ) rw.invalidILCList = new List<InventoryRow>();
                    rw.invalidILCList.add( new InventoryRow(ilc, getErrorMessage(ilc, dealerAcctIdToRealtedContactsMap, runningUser)) );
                    rw.activeOpenSections.add('ILCS');
                }else{
                    //can send
                    ConditionReportWrapper cw = new ConditionReportWrapper(ilc);
                    if(rw.eligibleCRs == null) rw.eligibleCRs = new List<ConditionReportWrapper>();
                    rw.eligibleCRs.add(cw);
                    rw.activeOpenSections.add('CRS');
                }
            }else{
                //If not attached to a Condition Report or user is not in dealership, can't send
                if(rw.invalidILCList == null ) rw.invalidILCList = new List<InventoryRow>();
                rw.invalidILCList.add( new InventoryRow(ilc, getErrorMessage(ilc, dealerAcctIdToRealtedContactsMap, runningUser)) );
                rw.activeOpenSections.add('ILCS');
            }
        }
        //If none of the Inventory Life Cycle records have a Most Recent Condition Report, throw an error message
        if( rw.eligibleCRs == null || rw.eligibleCRs.size() == 0 ){
            rw.errorMessage = 'Sorry, none of the selected records have an eligible Condition Report to Send to Run List.';
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
    public static String submitSendToRunList( String dataSubmitWrapperJSON ){
        System.debug(dataSubmitWrapperJSON);
        ReturnWrapper rw = new ReturnWrapper();
        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(dataSubmitWrapperJSON);
        List<Integer> crIds = new List<Integer>();
        Map<Integer,ConditionReportWrapper> crIdToConditionReportWrapper = new Map<Integer,ConditionReportWrapper>();
        //Gathers data from the submission Json
        User runningUser = getRunningUserInfoFromId( UserInfo.getUserId() );
        List<RunListAPI.RunListAuctionLaunch> runListAuctionLaunchList = new List<RunListAPI.RunListAuctionLaunch>();
        Set<String> ilcIds = new Set<String>();
        for( Object obj : (List<Object>)dataMap.get('crs') ){
            Map<String,Object> objMap = (Map<String,Object>)obj;
            crIds.add( Integer.valueOf(objMap.get('savedAuctionId')) );     //Used in Callout
            ConditionReportWrapper crTemp = new ConditionReportWrapper();
            crTemp.vin = String.valueOf(objMap.get('vin'));
            crTemp.yearMakeModelTrim = String.valueOf(objMap.get('yearMakeModelTrim'));
            crTemp.id = (Id)objMap.get('id');
            crTemp.ilcId = (Id)objMap.get('ilcId');
            crTemp.reservePrice = (Decimal)objMap.get('reservePrice');
            crTemp.savedAuctionId = String.valueOf(objMap.get('savedAuctionId'));
            crIdToConditionReportWrapper.put(Integer.valueOf(crTemp.savedAuctionId),crTemp);
            runListAuctionLaunchList.add( RunListAPI.createRunListSend(Integer.valueOf(runningUser.Id__c), crTemp.reservePrice, null, Integer.valueOf(crTemp.savedAuctionId)) );
            ilcIds.add(crTemp.ilcId);
        }
        // Sends to API
        HttpRequest req = RunListAPI.createSendToRunListlRequest(runListAuctionLaunchList);
        HttpResponse res = new Http().send(req);
        system.debug(res.getBody());
        Map<Id,Inventory_Life_Cycle__c> ilcsToUpdateMap = new Map<Id,Inventory_Life_Cycle__c>();
        if( res.getStatusCode() >= 400 ){
            rw.errorMessage = 'There was an issue with your request. Please contact a Salesforce Administrator to help you with the Condition Report(s) you wish to end.';
            SplunkHelper.buildAndProcessIntegrationLog(createLog(SplunkHelper.LOGLEVEL.FATAL, res.getBody(), 'RunListSendController', ACVUtility.currentLineNumber(), runningUser.Id ), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
        }else{
            //Makes two messages - one for success and one for error. Both have the potential to show up
            RunListAPI.RunListResponse rlsRes = (RunListAPI.RunListResponse)JSON.deserialize( res.getBody(), RunListAPI.RunListResponse.class );
            if( rlsRes.data.successes != null && rlsRes.data.successes.size() > 0 ){
                rw.successMessage = 'These Condition Report(s) were successfully sent to the Run List:\n';
                //If success, we update the Condition Report Status to indicate its Scheduled
                for( AuctionLaunchExt.ResponseData successResponse : rlsRes.data.successes ){
                    ConditionReportWrapper crw = crIdToConditionReportWrapper.get(successResponse.saved_auction_id);
                    Inventory_Life_Cycle__c tempILC = new Inventory_Life_Cycle__c();
                    tempILC.Processing_Status__c = SCHEDULING_TO_RUNLIST_STATUS;
                    tempILC.Id = crw.ilcId;
                    ilcsToUpdateMap.put(tempIlc.Id, tempILC);
                    rw.successMessage += 'VIN: ' + crw.vin + ' Floor Price: ' + crw.reservePrice + '\n';
                    ilcIds.remove(crw.ilcId);
                }
            }
            if( rlsRes.data.errors != null && rlsRes.data.errors.size() > 0 ){
                rw.errorMessage = 'There were errors with some of the Condition Reports. Here is a list:\n';
                for( AuctionLaunchExt.ResponseData errorResponse : rlsRes.data.errors ){
                    ConditionReportWrapper crw = crIdToConditionReportWrapper.get(errorResponse.saved_auction_id);
                    rw.errorMessage += 'VIN: ' + crw.vin + ' - ' + errorResponse.message + '\n'; 
                }
            }
            if( ilcsToUpdateMap.size() > 0 ){
                try{
                    update ilcsToUpdateMap.values();
                    if(ilcIds.size() > 0){
                        SplunkHelper.buildAndProcessIntegrationLog(createLog(SplunkHelper.LOGLEVEL.Error, 'Failed during RunlistSend', 'RunListSendController', ACVUtility.currentLineNumber(), runningUser.Id ), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
                    }
                }catch( Exception ex ){
                    if(rw.errorMessage == null) rw.errorMessage = '';
                    rw.errorMessage += 'There was an issue updating the Inventory records for your successful cars sent to run list. Please do not resend to run list as your cars have been properly scheduled; an Admin has been notified.';
                    SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.ERROR, ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), runningUser.Id), createSFErrorRecords( ilcsToUpdateMap.keySet(), ex.getMessage() ), new Set<String>() ) ;
                }
            }
        }
        return JSON.serialize(rw);
    }
    /**
     * Gets the ACV Id from the Running User
     * @param ilc - the Inventory Record that has an error message
     * @param dealerAcctIdToRealtedContactsMap - Dealler Account Id to the Affiliation records related
     * @param runningUser - the Running User who navigated to this page
     * @return string with the proper Error MEssage
     */
    public static String getErrorMessage( Inventory_Life_Cycle__c ilc, Map<Id, Set<String>> dealerAcctIdToRealtedContactsMap, User runningUser){
        String errorMessage = '';
        if( ilc.Most_Recent_Condition_Report__c == null || String.isBlank(ilc.Most_Recent_Condition_Report__r.ACV_Saved_Auction_Id__c) ){
            errorMessage = 'No Saved Auction Id to schedule this car.';
        }else if( ilc.Status__c.startsWithIgnoreCase(AuctionLaunchExt.SCHEDULING_PREFIX) ){
            errorMessage = 'This car is currently in process of being scheduled.';
        }else if(ilc.Client__c == null || String.isBlank(ilc.Client__r.Dealership_Id__c) ){
            errorMessage = 'This Inventory record is not linked to a valid Dealer';
        }else if( dealerAcctIdToRealtedContactsMap.get(ilc.Client__c) == null || (ilc.Client__c != null && dealerAcctIdToRealtedContactsMap.get(ilc.Client__c) != null && !dealerAcctIdToRealtedContactsMap.get(ilc.Client__c).contains(runningUser.Id__c)) ){
            errorMessage = 'You do not have access to the following dealership id: ' + ilc.Client__r.Dealership_Id__c;
        }//else if( ilc.Most_Recent_Condition_Report__r.Floor_Price__c == null || /*ilc.Most_Recent_Condition_Report__r.Floor_Price__c < 20 ||*/ ilc.Most_Recent_Condition_Report__r.Floor_Price__c == 999999 ){
         //   errorMessage = 'The Condition Report does not have a valid Floor Price value: Floor Price = ' + ilc.Most_Recent_Condition_Report__r.Floor_Price__c;
         //}
        else{
            errorMessage = 'There was an error with your request. Please contact an Admin.';
        }
        return errorMessage;
    }
    /**
     * Gets the ACV Id from the Running User
     * @param runningUserId - The Salesforce User Id we wish to get the ACV User Id from
     * @return running User record
     */
    public static User getRunningUserInfoFromId( Id runningUserId ){
        List<User> users = new List<User>();
        users = [ SELECT Id, Id__c FROM User WHERE Id = :runningUserId LIMIT 1 ];
        if( users.size() > 0 ){
            return users[0];
        }else{
            return null;
        }
    }
    /**
     * Gets the ACV Id from the Running User
     * @param loglevel - ERROR, FATAL, INFO, DEBUG, WARN, or PERFORMANCE
     * @param message - error message
     * @param stackTrace - Full Detailed Stack Trace
     * @param lineNumber - Line Number that the error has happened on
     * @param record - record ids
     * @return SplunkHelper.log
     */
    public static SplunkHelper.Log createLog( SplunkHelper.LOGLEVEL loglevel, String message, String stackTrace, Integer lineNumber, String recordId ){
        SplunkHelper.Log log = new SplunkHelper.log();
        log.domainSet = new Set<SplunkHelper.DOMAIN>{SplunkHelper.DOMAIN.SUPPLY};
        log.sfObject = 'Inventory Life Cycle';
        log.version = 'v1';
        log.componentName = 'LWC - Send to Run List';

        log.location = 'RunListSendController Line #' + String.valueOf(lineNumber);
        log.message = message;
        log.stackTrace = stackTrace;
        log.logLevel = loglevel;
        log.sfRecordId = recordId;
        log.setContext(SplunkHelper.CONTEXT_TYPE.LWC);
        return log;
    }
    /**
     * Gets the ACV Id from the Running User
     * @param inventoryLifeCycleIds - Id set of Inventory Life Cycle Records
     * @param errorMessage - error message
     * @return SplunkHelper.SFErrorRecord
     */
    public static List<SplunkHelper.SFErrorRecord> createSFErrorRecords( Set<Id> inventoryLifeCycleIds, String errorMessage ){
        List<SplunkHelper.SFErrorRecord> sfErrorRecords = new List<SplunkHelper.SFErrorRecord>();
        for( Id ilcId : new List<Id>(inventoryLifeCycleIds) ){
            sfErrorRecords.add( new SplunkHelper.SFErrorRecord(ilcId,errorMessage) );
        }
        return sfErrorRecords;
    }
}