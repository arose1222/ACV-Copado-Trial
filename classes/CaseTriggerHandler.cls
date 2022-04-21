public class CaseTriggerHandler extends TriggerHandler {
    private static CaseTriggerFlag__c CaseTriggerFlag = CaseTriggerFlag__c.getOrgDefaults();
    public static List<String> userNames {get;set;}
    public static Set<String> TITLE_OUTBOUND_STATUSES {get;set;}

    public CaseTriggerHandler() {
        List<Integration_User_Name__mdt> lACVIntegrationObj = [select MasterLabel from Integration_User_Name__mdt];
        userNames = new List<String>();
        for(Integration_User_Name__mdt obj :lACVIntegrationObj ){
            userNames.add(obj.MasterLabel);
        }
        
        if(System.Label.TITLE_OUTBOUND_STATUSES != null){
            String titleOutboundLabel = System.Label.TITLE_OUTBOUND_STATUSES;
            if(titleOutboundLabel != null){
                TITLE_OUTBOUND_STATUSES = new Set<String>(titleOutboundLabel.split(','));
            }
        }
    }
    
    protected override void beforeInsert(){
        if(CaseTriggerFlag.Enabled__c){
            CaseArbitrationProcesses.beforeInsert(Trigger.new);
            CaseCoreProcesses.beforeInsert(Trigger.new);
            //CaseTitlesProcesses.beforeInsert(Trigger.new);
            CaseTransportationProcesses.beforeInsert(Trigger.new);
            CaseUnwindProcesses.beforeInsert(Trigger.new);
        }
    }

    protected override void afterInsert() {
        if(CaseTriggerFlag.Enabled__c){
            createArb();
            //caseUtility.runArbProcesses(Trigger.newMap, Trigger.oldMap);
            //CaseUtility.calculateArbsRollup(Trigger.newMap, Trigger.oldMap);
            CaseArbitrationProcesses.afterInsert(Trigger.newMap, Trigger.oldMap);
            // CreateDealerDocumentCase.runCaseCreate(Trigger.newMap);
            // CreateDealerDocumentCase.caseClosedLogic(Trigger.newMap);
            CaseTransportationProcesses.afterInsert(Trigger.newMap, Trigger.oldMap);
            CaseUnwindProcesses.afterInsert(Trigger.newMap, Trigger.oldMap);
            AccountUpdateLogisticsFromCase.run(trigger.new);
            //CaseTitlesProcesses.afterInsert(Trigger.newMap, Trigger.oldMap);
        }
    }

    protected override void beforeUpdate(){
        if(CaseTriggerFlag.Enabled__c){
            CaseCoreProcesses.beforeUpdate(Trigger.newMap,Trigger.oldMap);
            //CaseTitlesProcesses.beforeUpdate(Trigger.newMap,Trigger.oldMap);
            CaseTransportationProcesses.beforeUpdate(Trigger.newMap,Trigger.oldMap);
            CaseArbitrationProcesses.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            CaseUnwindProcesses.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            CaseCRReviewProcesses.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    
    protected override void afterUpdate() {
        if(CaseTriggerFlag.Enabled__c){
            updateArb();
            //updateTitle();
            //caseUtility.runArbProcesses(Trigger.newMap, Trigger.oldMap);
            //CreateDealerDocumentCase.runCaseCreate(Trigger.newMap);
            //CaseUtility.calculateArbsRollup(Trigger.newMap, Trigger.oldMap);
            CaseArbitrationProcesses.afterUpdate(Trigger.newMap,Trigger.oldMap);
            //CreateDealerDocumentCase.caseClosedLogic(Trigger.newMap);
            CaseTransportationProcesses.afterUpdate(Trigger.newMap,Trigger.oldMap);
            CaseUnwindProcesses.afterUpdate(Trigger.newMap,Trigger.oldMap);
            AccountUpdateLogisticsFromCase.run(trigger.new);
            //CaseTitlesProcesses.afterUpdate(Trigger.newMap, Trigger.oldMap);
            //TitleChangeEvent.run(Trigger.newMap,Trigger.oldMap);
            //dlrs.RollupService.triggerHandler(Case.SObjectType);
            
            //sendTrans();(Not Needed unless we want real time integrations)
        }
    }

    public static boolean isUpdateArb = false;
    public static boolean isCreateArb = false;
    public static boolean isUpdateTrans = false;
    public static boolean isCreateTrans = false;
    public static boolean isUpdateAuc = false;
    public static boolean isUpdateTitle = false;

    //Commented out until Trans Deployment
    /*public static void sendTrans(){
        Id transRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        if(!isupdateTrans){
            isupdateTrans = true;
            for (Case caseObj: (List <Case>) Trigger.New){
                if(caseObj.RecordTypeId == transRecordTypeId && caseObj.ACV_Transportation_Request_Id__c != null && caseObj.Send_to_ACV__c == true && !System.isQueueable() && !userNames.contains(UserInfo.getUserName())){
                    System.debug('send Trans');
                    System.enqueueJob(new AcvIntegrationQueueableJob('Update Trans', new List<Case> {caseObj}, null));

                }
            }
        }
    }*/
     
    public static void createArb() {
        Id arbRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId(); 
        if(!iscreateArb){
            iscreateArb = True;
            for (case caseObj:(List < Case > ) Trigger.New) {
                if(caseObj.RecordTypeId == arbRecordTypeId && caseObj.Auction_Number_Case__c != null && caseObj.id__c == null && !System.isQueueable() && !userNames.contains(UserInfo.getUserName())) {
                    System.debug('create Arb');
                    System.enqueueJob(New AcvIntegrationQueueableJob('Create Arb', New List < Case > {
                        caseObj
                    },null));
                }
             }
        }
    }

    public static void updateArb() {
        Id arbRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        if (!isupdateArb) {
            Map < id,case > oldOps = (Map < id,case > ) Trigger.oldMap;
            Map < id,case > newOps = (Map < id,case > ) Trigger.newMap;
            for (case caseObj:newOps.values()) { 
                //If Arb Case is updated in SFDC and it is closed and it has an external id then update the Arb in ACV to close it
                if(caseObj.RecordTypeId == arbRecordTypeId && caseObj.Auction_Number_Case__c != null && caseObj.id__c != null && caseObj.IsClosed && !System.isQueueable() && !userNames.contains(UserInfo.getUserName())) {
                    System.debug('update Arb');
                    System.enqueueJob(New AcvIntegrationQueueableJob('Update Arb', New List < Case > {
                        caseObj
                    },null));
                //If Arb Case is updated in SFDC and it is not closed and it does not have an external id then create the Arb in ACV
                }else if(caseObj.RecordTypeId == arbRecordTypeId && caseObj.Auction_Number_Case__c != null && caseObj.id__c == null && caseObj.IsClosed == false && !System.isQueueable() && !userNames.contains(UserInfo.getUserName())) {
                    System.debug('update Arb');
                    System.enqueueJob(New AcvIntegrationQueueableJob('Create Arb', New List < Case > {
                        caseObj
                    },null));
                }
            }
            isupdateArb = true;
        } 
    }
    
    public static void updateTitle() {
        Id titleRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        if (!isUpdateTitle) {
            Map<Id,Case> oldCases = (Map<Id,Case>) Trigger.oldMap;
            Map<Id,Case> newCases = (Map<Id,Case>) Trigger.newMap;
            List<Case> lTitleCasesToSend = new List<Case>();
            for (case caseObj:newCases.values()){ 
                //If Title Case is updated in SFDC and then update the Title in ACV Tools if the Status has changed and is one of the statuses that should be sent to ACV tools
                if(caseObj.RecordTypeId == titleRecordTypeId && caseObj.Auction_Number_Case__c != null && ((caseObj.Status != oldCases.get(caseObj.Id).Status && TITLE_OUTBOUND_STATUSES.contains(caseObj.Status))|| caseObj.seller_payment_method__c != oldCases.get(caseObj.Id).seller_payment_method__c || caseObj.seller_payment_tracking_number__c != oldCases.get(caseObj.Id).seller_payment_tracking_number__c || caseObj.Title_Sent_Date__c != oldCases.get(caseObj.id).Title_Sent_Date__c || caseObj.Title_Received_Date__c != oldCases.get(caseObj.id).Title_Received_Date__c || caseObj.Easypost_Tracker__c != oldCases.get(caseObj.id).Easypost_Tracker__c ) && !System.isQueueable() && !userNames.contains(UserInfo.getUserName())){
                    System.debug('update Title');
                    lTitleCasesToSend.add(caseObj);
                }
            }
            if(lTitleCasesToSend.size() > 0){
                System.enqueueJob(new AcvIntegrationQueueableJob('Update Title', lTitleCasesToSend, null));
                isUpdateTitle = true;
            }
        }
    }
    
    /*
    public static void LimitOneTransportationCase(List<Case> lCase) {
        Set<Id> aucIds = new Set<Id>();
        Map<Id, Case> mCases = new Map<Id, Case>();

        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();


        for(Case tCase :lCase){
            if(tCase.RecordTypeId == caseRecordTypeId){
                if(tCase.Auction_Number__c != null){
                    aucIds.add(tCase.Auction_Number__c);
                }       
            }
        }   
        if(aucIds.size() >0){
            List<Case> lTransCases = [SELECT Id, Auction_Number__c, RecordTypeId, RecordType.Name FROM Case WHERE Auction_Number__c IN :aucIds AND RecordType.Name = 'Transportation' AND IsClosed = false];
            for(Case tCase :lTransCases){
                mCases.put(tCase.Auction_Number__c, tCase);
            }
            for(Case tCase :lCase){
                if(tCase.RecordTypeId == caseRecordTypeId){
                    if(mCases.keySet().contains(tCase.Auction_Number__c)){
                        tCase.addError('Open Transportation case already associated with selected Auction');
                    }               
                }
            }   
        }
    }*/


    /*
    public static void LimitOneTitleCase(List<Case> lCase) {
        Id sysAdminId = [SELECT Id from Profile where name = 'System Administrator' LIMIT 1].Id;
        
        if(UserInfo.getProfileId() != sysAdminId){
            Set<Id> aucIds = new Set<Id>();
            Map<Id, Case> mCases = new Map<Id, Case>();

            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();


            for(Case tCase :lCase){
                if(tCase.RecordTypeId == caseRecordTypeId){
                    if(tCase.Auction_Number__c != null){
                        aucIds.add(tCase.Auction_Number__c);
                    }       
                }
            }
            if(aucIds.size() >0){
                List<Case> lTitleCases = [SELECT Id, Auction_Number__c, RecordTypeId, RecordType.Name FROM Case WHERE Auction_Number__c IN :aucIds AND RecordType.DeveloperName = 'Title_Information'];
                for(Case tCase :lTitleCases){
                    mCases.put(tCase.Auction_Number__c, tCase);
                }
                for(Case tCase :lCase){
                    if(tCase.RecordTypeId == caseRecordTypeId){
                        if(mCases.keySet().contains(tCase.Auction_Number__c)){
                            tCase.addError('Title case already associated with selected Auction');
                        }               
                    }
                }
            }
        }
    }*/
    /*
    public static void StampAddressInfoOnTitle(List<Case> lCase){
        Set<Id> aucIds = new Set<Id>();
        for(Case c :lCase){
            aucIds.add(c.Auction_Number__c);
        }
        
        System.debug(aucIds);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Title Information').getRecordTypeId();
        System.debug(caseRecordTypeId);
        Map<Id,Auction__c> mapAuctions = new Map<Id, Auction__c>([SELECT id, buyer_dealership__c, buyer_dealership__r.BillingStreet,
                                            buyer_dealership__r.BillingCity, buyer_dealership__r.BillingState, buyer_dealership__r.BillingPostalCode,
                                            buyer_dealership__r.BillingCountry FROM Auction__c WHERE id IN :aucIds]);
        for(Case tCase :lCase){
            if(tCase.RecordTypeId == caseRecordTypeId && tCase.Auction_Number__c != null && mapAuctions.get(tCase.Auction_Number__c) != null){
                tCase.Default_Delivery_Address__c = mapAuctions.get(tCase.Auction_Number__c).buyer_dealership__r.BillingStreet;
                tCase.Default_Delivery_City__c = mapAuctions.get(tCase.Auction_Number__c).buyer_dealership__r.BillingCity;
                tCase.Default_Delivery_State__c = mapAuctions.get(tCase.Auction_Number__c).buyer_dealership__r.BillingState;
                tCase.Default_Delivery_Postal_Code__c = mapAuctions.get(tCase.Auction_Number__c).buyer_dealership__r.BillingPostalCode;
                tCase.Default_Delivery_Country__c = mapAuctions.get(tCase.Auction_Number__c).buyer_dealership__r.BillingCountry;


            }
        }
    }*/
}