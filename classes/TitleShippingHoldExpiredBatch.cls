global class TitleShippingHoldExpiredBatch extends SchedulingInterface implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global static List<SplunkHelper.SFErrorRecord> errorList = new List<SplunkHelper.SFErrorRecord>();
    global static Set<String> succesIdList = new Set<String>();
    global static String errorStackTraceString = '';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Title_Information').getRecordTypeId();
        String query = 'select id, Hold_For_Payment__c, Account.BillingState,Auction_Number__r.payment_method__c,Auction_Number__r.payment_status__c,';
        query += 'Account.BillingStreet, Account.BillingPostalCode, Account.Name,Account.Phone,Seller_Dealership__r.BillingCity,';
        query += 'Seller_Dealership__r.BillingStreet, Seller_Dealership__r.BillingState, Seller_Dealership__r.BillingPostalCode, Seller_Dealership__r.Name,Seller_Dealership__r.Phone';
        query += ' from case where Hold_For_Payment__c = YESTERDAY';
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Case> scope) {
        Map<Id, EasyPostShipmentRequest> caseToAddressMap = new Map<Id, EasyPostShipmentRequest>();
        for(Case c :scope){
            EasyPostShipmentRequest epShipment = new EasyPostShipmentRequest();
            epShipment.shipment = new EasyPostShipmentRequest.Shipment();
            epShipment.shipment.To_address = TitlesShippingAutomation.generateACVToAddress();
            epShipment.shipment.From_address = TitlesShippingAutomation.generateFromAddress(c.Seller_Dealership__r.Name, c.Seller_Dealership__r.BillingStreet, c.Seller_Dealership__r.BillingCity, c.Seller_Dealership__r.BillingState, 'US', c.Seller_Dealership__r.BillingPostalCode, c.Seller_Dealership__r.Phone);
            epShipment.shipment.parcel = new EasyPostShipmentRequest.Parcel();
            //epShipment.shipment.parcel.predefined_package = 'FedExEnvelope'; 
            epShipment.shipment.parcel.weight = 10; 
            caseToAddressMap.put(c.id,epShipment);
        }
        List<Case> updateRecLst = TitlesShippingAutomation.generateShippingLabel(caseToAddressMap);
        List<Database.SaveResult> dbResultLst = Database.update( updateRecLst, FALSE );
        for ( Integer index = 0; index < dbResultLst.size(); index++ ) {
            Database.SaveResult dbResultRec = dbResultLst[index]; 
            Case caseUpdated = updateRecLst[index];
            if ( !dbResultRec.isSuccess() ) {
                List<String> errList = new List<String>();
                for(Database.Error err :dbResultRec.getErrors()){
                    errList.add(err.getMessage());
                }
                errorList.add(new SplunkHelper.SFErrorRecord( JSON.serialize( caseUpdated ), string.join(errList,',')));
            }
            else{
                succesIdList.add(dbResultRec.id);
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        SplunkHelper.Log log = new SplunkHelper.Log();
        log.componentName = 'TitleShippingHoldExpiredBatch';
        log.sfObject = 'Case';
        log.domainSet = new Set<SplunkHelper.DOMAIN>();
        log.domainSet.add(SplunkHelper.DOMAIN.POST_TRANSACTION);
        log.logLevel = errorList.size() > 0 ? SplunkHelper.LOGLEVEL.ERROR : SplunkHelper.LOGLEVEL.INFO;
        log.setContext(SplunkHelper.CONTEXT_TYPE.BATCH);
        log.sfRecordId = bc.getJobId();
        log.stackTrace = 'TitleShippingHoldExpiredBatch.finish: '+ACVUtility.currentLineNumber()+2;
        log.location = 'TitleShippingHoldExpiredBatch.finish: '+ACVUtility.currentLineNumber()+1;
        SplunkHelper.processBatchLog(log, errorList, succesIdList);
    }

    public override void executeScheduledLogic() {
        //schedule
        TitleShippingHoldExpiredBatch almb = new TitleShippingHoldExpiredBatch();
        Database.executeBatch(almb, 20);
    } 
}