trigger updateCasesOnVINchange on Auction__c
                                         (before update) {
    
    Map<Id, Auction__c> auctionsWithNewVIN = new Map<Id, Auction__c>();
    
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (   (Trigger.old[i].vehicle_id__c != Trigger.new[i].vehicle_id__c)
           )  {
            auctionsWithNewVIN.put(Trigger.old[i].id,
                                      Trigger.new[i]);
        }
    }

    List<Case> updatedCases= new List<Case>();
  
    for (Case c : [SELECT id, auction_number__c, vehicle__c
                      FROM case
                      WHERE auction_number__c 
                            in :auctionsWithNewVIN.keySet()]) {
        Auction__c parentAuction = auctionsWithNewVIN.get(c.auction_number__c);
        c.vehicle__c = parentAuction.vehicle_id__c;
    
        updatedCases.add(c);
    }
    update updatedCases;
}