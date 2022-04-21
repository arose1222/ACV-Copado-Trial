trigger updateCasesOnISTAccountOwnerchange on Account
                                         (before update) {
    
    Map<Id, Account> acctsWithNewISTAccountOwner = new Map<Id, Account>();
    
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if (   (Trigger.old[i].IST_Account_Owner__c != Trigger.new[i].IST_Account_Owner__c)
           )  {
            acctsWithNewISTAccountOwner.put(Trigger.old[i].id,
                                      Trigger.new[i]);
        }
    }

    List<Case> updatedCases= new List<Case>();
  
    for (Case c : [SELECT id, accountId, IST_Account_Owner_Lookup__c
                      FROM case
                      WHERE accountId 
                            in :acctsWithNewISTAccountOwner.keySet()]) {
        Account parentAccount = acctsWithNewISTAccountOwner.get(c.accountId);
        c.IST_Account_Owner_Lookup__c = parentAccount.IST_Account_Owner__c;
    
        updatedCases.add(c);
    }
    update updatedCases;
}