/**
 * This class holds the logic for the Launch Auction Modal
 * @author James Andre LaCour
 */
public class LaunchAuctionCont {
    /****************Global Variables**********************/
    public final static String DISABLED_CLASS_NAME = 'disableDiv';
    /****************Inner Classes************************/
    public class DataWrapper{
        public String statusMessage;
        public Integer statusCode;
        public List<LaunchOption> launchOptionsList;
        public List<InventoryRowLaunch> ilcsToShowList;
        public DataWrapper(){
            statusMessage = '';
            statusCode = 200;
            launchOptionsList = new List<LaunchOption>();
            ilcsToShowList = new List<InventoryRowLaunch>();
        }
    }
    public class LaunchOption{
        public String title;
        public String subTitleEligible;
        public String subTitleIneligible;
        public List<RunListSendController.ConditionReportWrapper> eligibleList;
        public List<RunListSendController.InventoryRow> ineligibleList;
        public String className;
        public LaunchOption(){
            title = '';
            subTitleEligible = '';
            subTitleIneligible = '';
            eligibleList = new List<RunListSendController.ConditionReportWrapper>();
            ineligibleList = new List<RunListSendController.InventoryRow>();
            className = 'slds-box slds-box_x-small slds-p-bottom_small ';       //Default value, disabledDiv can be added based on eligibility of option
        }
    }
    public class InventoryRowLaunch extends InventoryLifeCycleListViewController.InventoryRow{
        public String startDateTime;
    }
    /****************Helper Methods***********************/
    /**
     * intialize is called on load of Launch Auction Modal
     * Gets the records and determines which of the selected is eligible for a Launch Option
     * @return JsonString of the DataWrapper
     */
    @AuraEnabled
    public static string intialize( String ilcRowsJson ){
        DataWrapper dw = new DataWrapper();
        try{
            // Currently using the logic in RunListSendController. Will be brought over later when the items are deleted.
            RunListSendController.ReturnWrapper eligibilityWrapper = (RunListSendController.ReturnWrapper)JSON.deserialize(RunListSendController.doInit(ilcRowsJson),RunListSendController.ReturnWrapper.class);
            // Send to Run List Option
            /*LaunchOption runList = new LaunchOption();
            runList.title = 'Run List';
            if( rw.eligibleCRs != null ){
                runList.eligibleList.addAll(rw.eligibleCRs);
                String middleTemp = rw.eligibleCRs.size() == 1 ? ' item is ' : ' items are ';
                runList.subTitleEligible = runList.eligibleList.size() + middleTemp + 'ready to send to run list';
            }else{
                runList.subTitleEligible = '0 items are ready to send to run list';
                runList.className = runList.className + DISABLED_CLASS_NAME;
            }
            if( rw.invalidILCList != null ){
                runList.ineligibleList.addAll(rw.invalidILCList);
                String middleTemp = rw.invalidILCList.size() == 1 ? ' is ' : ' are ';
                runList.subTitleIneligible = runList.ineligibleList.size() + middleTemp + ' not eligible based on status criteria';
            }else{
                runList.subTitleIneligible = '';
            }
            dw.launchOptionsList.add(runList);*/
            // Launch to Live Option
            LaunchOption live = new LaunchOption();
            live.title = 'Live';
            if( eligibilityWrapper.eligibleCRs != null ){
                live.eligibleList.addAll(eligibilityWrapper.eligibleCRs);
                String middleTemp = eligibilityWrapper.eligibleCRs.size() == 1 ? ' item is ' : ' items are ';
                live.subTitleEligible = live.eligibleList.size() + middleTemp + 'ready to send to live';
            }else{
                live.subTitleEligible = '0 items are ready to send to live';
                live.className = live.className + DISABLED_CLASS_NAME;
            }
            if( eligibilityWrapper.invalidILCList != null ){
                live.ineligibleList.addAll(eligibilityWrapper.invalidILCList);
                String middleTemp = eligibilityWrapper.invalidILCList.size() == 1 ? ' is ' : ' are ';
                live.subTitleIneligible = live.ineligibleList.size() + middleTemp + ' not eligible based on status criteria';
            }else{
                live.subTitleIneligible = '';
            }
            dw.launchOptionsList.add(live);
        }catch( Exception ex ){
            dw.statusCode = 400;
            dw.statusMessage = 'There was an error with the intiailization of Launch Auction.';
            system.debug(ex.getMessage());
        }
        return JSON.serialize(dw);
    }
    /**
     * Called to Launch an Auction. Determines where we are launching to
     * @return JsonString of the DataWrapper
     */
    @AuraEnabled
    public static string launchAuction( String ilcRowsJson, String launchType ){
        DataWrapper dw = new DataWrapper();
        switch on launchType{
            when 'Run List'{
                // dw = launchToRunList(ilcRowsJson);
            }
            when 'Live'{
                dw = launchToLive(ilcRowsJson);
            }
            when else{
                // Error message for Invalid Launch Type
                dw.statusCode = 400;
                dw.statusMessage = 'The Launch Type you selected is not valid. Please contact a Salesforce Admin to resolve your issue.';
            }
        }
        return JSON.serialize(dw);
    }
    public static DataWrapper launchToLive( String ilcRowsJson ){
        DataWrapper dw = new DataWrapper();
        List<InventoryRowLaunch> ilcRows = (List<InventoryRowLaunch>)JSON.deserialize(ilcRowsJson,List<InventoryRowLaunch>.class);
        Map<Id,InventoryRowLaunch> ilcIdToRowMap = new Map<Id,InventoryRowLaunch>();
        for( InventoryRowLaunch irl : ilcRows ){
            ilcIdToRowMap.put( irl.Id, irl );
        }
        Map<String,Contact> runningUserEmailContactMap = ACVUtility.getAcvUserId( new Set<String>{ UserInfo.getUserEmail() } );
        Contact runningUser = runningUserEmailContactMap.get( UserInfo.getUserEmail() );
        if( runningUser == null ){
            dw.statusCode = 400;
            dw.statusMessage = 'There was an error with finding your User record. Please contact a Salesforce admin.';
        }
        // Gathers the data together in the Request strcuture
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(RunListSendController.doInit(ilcRowsJson),RunListSendController.ReturnWrapper.class);
        Map<Id,LaunchToLiveAPI.LiveAuctionLaunch> ilcIdToRunListLaunchAuctionMap = new Map<Id,LaunchToLiveAPI.LiveAuctionLaunch>();
        Map<Integer,Id> crIdToIlcIdMap = new Map<Integer,Id>();
        for( RunListSendController.ConditionReportWrapper crw : rw.eligibleCRs ){
            // Reserve Price is adjusted based on edit
            crw.reservePrice = ilcIdToRowMap.get(crw.ilcId).reserve;
            // Z is added at the end of the time for the endpoint
            String thisLaunchDateTimeUTC = ilcIdToRowMap.get(crw.ilcId).startDateTime == null ? null : String.valueOfGMT( Datetime.valueOf( ilcIdToRowMap.get(crw.ilcId).startDateTime) ) + 'Z';
            ilcIdToRunListLaunchAuctionMap.put( crw.ilcId, LaunchToLiveAPI.createLiveSend( Integer.valueOf(runningUser.Id__c), crw.reservePrice, null, Integer.valueOf(crw.savedAuctionId), thisLaunchDateTimeUTC ) );
            crIdToIlcIdMap.put( Integer.valueOf(crw.savedAuctionId), crw.ilcId );
        }
        // Sends to API
        HttpRequest req = LaunchToLiveAPI.createLiveListRequest(ilcIdToRunListLaunchAuctionMap.values());
        system.debug(req.getBody());
        HttpResponse res = new Http().send(req);
        Map<Id,Inventory_Life_Cycle__c> ilcsToUpdateMap = new Map<Id,Inventory_Life_Cycle__c>();
        if( res.getStatusCode() >= 400 ){
            dw.statusCode = 400;
            dw.statusMessage = 'There was an issue with your request. Please contact a Salesforce Administrator to help you with the Condition Report(s) you wish to schedule.';
            SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.FATAL, res.getBody(), 'LaunchAuctionCont', ACVUtility.currentLineNumber(), runningUser.Id ), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
        }else{
            //Makes two messages - one for success and one for error. Both have the potential to show up
            LaunchToLiveAPI.LiveResponse rlsRes = (LaunchToLiveAPI.LiveResponse)JSON.deserialize( res.getBody(), LaunchToLiveAPI.LiveResponse.class );
            if( rlsRes.data.successes != null && rlsRes.data.successes.size() > 0 ){
                //If success, we update the Inventory Life Cycle Status to indicate its Scheduled
                system.debug( rlsRes.data.successes.size() );
                system.debug( rlsRes.data.successes );
                for( AuctionLaunchExt.ResponseData successResponse : rlsRes.data.successes ){
                    Id thisIlcId = crIdToIlcIdMap.get(successResponse.saved_auction_id);
                    Inventory_Life_Cycle__c tempILC = new Inventory_Life_Cycle__c();
                    tempILC.Processing_Status__c = AuctionLaunchExt.SCHEDULING_PREFIX + LaunchToLiveAPI.LIVE_LAUNCHING_STATUS_SUFFIX;
                    tempILC.Id = thisIlcId;
                    ilcsToUpdateMap.put(tempIlc.Id, tempILC);
                }
            }
            // For Errors, we wil want to keep the ilc in the table so return that row
            Set<Id> ilcRowsToShowErrorSet = new Set<Id>();
            if( rlsRes.data.errors != null && rlsRes.data.errors.size() > 0 ){
                for( AuctionLaunchExt.ResponseData errorResponse : rlsRes.data.errors ){
                    Id thisIlcId = crIdToIlcIdMap.get(errorResponse.saved_auction_id);
                    ilcRowsToShowErrorSet.add(thisIlcId);
                }
            }
            if( ilcRowsToShowErrorSet.size() > 0 ){
                for( InventoryRowLaunch thisIlcRow : ilcRows ){
                    if( ilcRowsToShowErrorSet.contains(thisIlcRow.Id) ){
                        dw.ilcsToShowList.add(thisIlcRow);
                    }
                }
            }
            // Final Update to show the status is scheduled
            if( ilcsToUpdateMap.size() > 0 ){
                try{
                    update ilcsToUpdateMap.values();
                }catch( Exception ex ){
                    dw.statusCode = 400;
                    dw.statusMessage += 'There was an issue updating the Inventory records for your successful cars sent to Live Auction. Please do not resend to Live as your cars have been properly scheduled; an Admin has been notified.';
                    SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.ERROR, ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), runningUser.Id), createSFErrorRecords( ilcIdToRunListLaunchAuctionMap.keySet(), ex.getMessage() ), new Set<String>() ) ;
                }
            }
            if(ilcRowsToShowErrorSet.size() > 0){
                dw.statusCode = 202;
                dw.statusMessage = 'Not all of the cars could successfully schedule. Please try again with the remaining cars in the table';
                SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.Error, 'Failed during RunlistSend', 'RunListSendController', ACVUtility.currentLineNumber(), runningUser.Id ), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
            }
        }
        return dw;
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
        log.componentName = 'LWC - Launch Auction Modal';

        log.location = 'LaunchAuctionCont Line #' + String.valueOf(lineNumber);
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
    /*public static DataWrapper launchToRunList( String ilcRowsJson ){
        DataWrapper dw = new DataWrapper();
        List<InventoryRowLaunch> ilcRows = (List<InventoryRowLaunch>)JSON.deserialize(ilcRowsJson,List<InventoryRowLaunch>.class);
        Map<Id,InventoryRowLaunch> ilcIdToRowMap = new Map<Id,InventoryRowLaunch>();
        for( InventoryRowLaunch irl : ilcRows ){
            ilcIdToRowMap.put( irl.Id, irl );
        }
        User runningUser = RunListSendController.getRunningUserInfoFromId( UserInfo.getUserId() );
        // Gathers the data together in the Request strcuture
        RunListSendController.ReturnWrapper rw = (RunListSendController.ReturnWrapper)JSON.deserialize(RunListSendController.doInit(ilcRowsJson),RunListSendController.ReturnWrapper.class);
        Map<Id,RunListApi.RunListAuctionLaunch> ilcIdToRunListLaunchAuctionMap = new Map<Id,RunListApi.RunListAuctionLaunch>();
        Map<Integer,Id> crIdToIlcIdMap = new Map<Integer,Id>();
        for( RunListSendController.ConditionReportWrapper crw : rw.eligibleCRs ){
            // Z is added at the end of the time for the endpoint
            String thisLaunchDateTimeUTC = ilcIdToRowMap.get(crw.ilcId).startDateTime == null ? null : String.valueOfGMT( Datetime.valueOf( ilcIdToRowMap.get(crw.ilcId).startDateTime) ) + 'Z';
            ilcIdToRunListLaunchAuctionMap.put( crw.ilcId, RunListAPI.createRunListSend( Integer.valueOf(runningUser.Id__c), crw.reservePrice, null, Integer.valueOf(crw.savedAuctionId), thisLaunchDateTimeUTC ) );
            crIdToIlcIdMap.put( Integer.valueOf(crw.savedAuctionId), crw.ilcId );
        }
        // Sends to API
        HttpRequest req = RunListAPI.createSendToRunListlRequest(ilcIdToRunListLaunchAuctionMap.values());
        system.debug(req.getBody());
        HttpResponse res = new Http().send(req);
        Map<Id,Inventory_Life_Cycle__c> ilcsToUpdateMap = new Map<Id,Inventory_Life_Cycle__c>();
        if( res.getStatusCode() >= 400 ){
            dw.statusCode = 400;
            dw.statusMessage = 'There was an issue with your request. Please contact a Salesforce Administrator to help you with the Condition Report(s) you wish to schedule.';
            SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.FATAL, res.getBody(), 'LaunchAuctionCont', ACVUtility.currentLineNumber(), runningUser.Id ), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND );
        }else{
            //Makes two messages - one for success and one for error. Both have the potential to show up
            RunListAPI.RunListResponse rlsRes = (RunListAPI.RunListResponse)JSON.deserialize( res.getBody(), RunListAPI.RunListResponse.class );
            if( rlsRes.data.successes != null && rlsRes.data.successes.size() > 0 ){
                //If success, we update the Inventory Life Cycle Status to indicate its Scheduled
                for( AuctionLaunchExt.ResponseData successResponse : rlsRes.data.successes ){
                    Id thisIlcId = crIdToIlcIdMap.get(successResponse.saved_auction_id);
                    Inventory_Life_Cycle__c tempILC = new Inventory_Life_Cycle__c();
                    tempILC.Processing_Status__c = RunListSendController.SCHEDULING_TO_RUNLIST_STATUS;
                    tempILC.Id = thisIlcId;
                    ilcsToUpdateMap.put(tempIlc.Id, tempILC);
                }
            }
            // For Errors, we wil want to keep the ilc in the table so return that row
            Set<Id> ilcRowsToShowErrorSet = new Set<Id>();
            if( rlsRes.data.errors != null && rlsRes.data.errors.size() > 0 ){
                for( AuctionLaunchExt.ResponseData errorResponse : rlsRes.data.errors ){
                    Id thisIlcId = crIdToIlcIdMap.get(errorResponse.saved_auction_id);
                    ilcRowsToShowErrorSet.add(thisIlcId);
                }
            }
            if( ilcRowsToShowErrorSet.size() > 0 ){
                for( InventoryRowLaunch thisIlcRow : ilcRows ){
                    if( ilcRowsToShowErrorSet.contains(thisIlcRow.Id) ){
                        dw.ilcsToShowList.add(thisIlcRow);
                    }
                }
            }
            // Final Update to show the status is scheduled
            if( ilcsToUpdateMap.size() > 0 ){
                try{
                    update ilcsToUpdateMap.values();
                }catch( Exception ex ){
                    dw.statusCode = 400;
                    dw.statusMessage += 'There was an issue updating the Inventory records for your successful cars sent to run list. Please do not resend to run list as your cars have been properly scheduled; an Admin has been notified.';
                    SplunkHelper.buildAndProcessLog( createLog(SplunkHelper.LOGLEVEL.ERROR, ex.getMessage(), ex.getStackTraceString(), ex.getLineNumber(), runningUser.Id), createSFErrorRecords( ilcIdToRunListLaunchAuctionMap.keySet(), ex.getMessage() ), new Set<String>() ) ;
                }
            }
            if(ilcRowsToShowErrorSet.size() > 0){
                dw.statusCode = 202;
                dw.statusMessage = 'Not all of the cars could successfully schedule. Please try again with the remaining cars in the table';
                SplunkHelper.buildAndProcessIntegrationLog( createLog(SplunkHelper.LOGLEVEL.Error, 'Failed during RunlistSend', 'RunListSendController', ACVUtility.currentLineNumber(), runningUser.Id ), req, res, SplunkHelper.INTEGRATION_DIRECTION.OUTBOUND);
            }
        }
        return dw;
    }*/
}