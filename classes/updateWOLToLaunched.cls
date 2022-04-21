public without sharing class updateWOLToLaunched extends TriggerInterface{

    private final static String STANDARD_INSPECTION = 'Standard Inspection';
    
    public override void beforeInsert(List<sObject> newList){
        makeReadyToLaunch(newList);
    }

    public static void makeReadyToLaunch(List<SObject> triggerNew){
        List<Auction__c> auctionList = (List<Auction__c>)triggerNew;
        List<String> vinList = new List<String>();
        for(Auction__c a :auctionList){
            if(!String.isBlank(a.VIN__c)){
                vinList.add(a.VIN__c.toUpperCase());
            }
        }

        List<WorkOrderLineItem> wolUpdateList = new List<WorkOrderLineItem>();
        for(WorkOrderLineItem wol :[Select id, status from WorkOrderLineItem where VIN__c in :vinList AND Status = 'Ready to Launch' AND WorkType.Name = :STANDARD_INSPECTION ]){
            wol.status = 'Launched';
            wolUpdateList.add(wol);
        }

        if(wolUpdateList.size() > 0){
            update wolUpdateList;
        }
    }
}