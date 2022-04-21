trigger updateCasesOnBuyerExceptionschange on Account
                                         (before update) {
    
    Map<Id, Account> acctsWithNewBuyerExceptions = new Map<Id, Account>();
    
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (   (Trigger.old[i].Buyer_s_Assurance_Exceptions__c != Trigger.new[i].Buyer_s_Assurance_Exceptions__c)
           )  {
            acctsWithNewBuyerExceptions.put(Trigger.old[i].id,
                                      Trigger.new[i]);
        }
    }

    List<Case> updatedCases= new List<Case>();
  
    for (Case c : [SELECT id, accountId, Buyer_s_Assurance_Exceptions__c
                      FROM case
                      WHERE accountId 
                            in :acctsWithNewBuyerExceptions.keySet()]) {
        Account parentAccount = acctsWithNewBuyerExceptions.get(c.accountId);
        c.Buyer_s_Assurance_Exceptions__c = parentAccount.Buyer_s_Assurance_Exceptions__c;
    
        updatedCases.add(c);
    }
    update updatedCases;
}