public class AffiliationPrimaryContactMatch extends TriggerInterface{
    
    public override void afterInsert(List<Sobject> newList){
        //typecast the newList to a list of Affiliations
        List<Affiliation__c> affList = (List<Affiliation__c>)newList;

        Map<String,Affiliation__c> affMap = new Map<String,Affiliation__c>();
        for(Affiliation__c aff :affList){
            affMap.put(aff.Name, aff);
        }

        affList = [SELECT Id, Contact__c, Account__c, Account__r.Primary_Contact__c, Primary_Contact__c from Affiliation__c where Name in: affMap.keySet()];

        //filter the list of Affiliations to only Affiliations with primary contact checkbox true
        affList = AffiliationPrimaryContactMatch.filterByPrimaryContactCheckbox(affList, true);

        //confirm list size is greater than 0
        if(affList.size() > 0){
            //filter list of Affiliations to make sure the new and old primary contact do not match
            affList = AffiliationPrimaryContactMatch.filterByDifferentPrimaryContact(affList);
        }

        //confirm list size is greater than 0 again
        if (affList.size() > 0){
            //update the new primary contact on the accounts
            AffiliationPrimaryContactMatch.updatePrimaryContacts(affList);

            //remove the checked field on the old affiliations
            AffiliationPrimaryContactMatch.uncheckPreviousPrimaryContactAffiliations(affList);

        }   
    }
    
    public override void afterUpdate(List<Sobject> oldList, List<Sobject> newlist){
        //typecast the Lists to Affiliation lists

        List<Affiliation__c> oAffList = (List<Affiliation__c>)oldList;
        List<Affiliation__c> newAffList = (List<Affiliation__c>)newList;

        Map<String,Affiliation__c> affMap = new Map<String,Affiliation__c>();

        //duplicate the lists, as those from triggers are read only

        for(Affiliation__c aff : newAffList){
            affMap.put(aff.Name, aff);
        }
 
        newAffList = [SELECT id, Name, Contact__c, Account__c, Account__r.Primary_Contact__c, Primary_Contact__c, 
            Account__r.Name, Contact__r.Name
        from Affiliation__c where Name in: affMap.keySet()];
        
        List<Affiliation__c> oldAffList = new List<Affiliation__c>();
        for(Affiliation__c aff: oAffList){
            oldAffList.add(aff.clone(true, true, false, false));        
        }
   
        //filter the list to only affiliations that switched their checkbox from false to true
        newAffList = AffiliationPrimaryContactMatch.filterByPrimaryContactCheckBox(oldAffList, newAffList);

        //confirm list size is greater than 0
        if(newAffList.size() > 0){
            //filter list of Affiliations to make sure old and new primary contact do not match
            newAffList = AffiliationPrimaryContactMatch.filterByDifferentPrimaryContact(newAffList);
        }

        if (newAffList.size() > 0){
            //update the new primary contact on the accounts
            AffiliationPrimaryContactMatch.updatePrimaryContacts(newAffList);

            //remove the checked field on the old affiliations
            AffiliationPrimaryContactMatch.uncheckPreviousPrimaryContactAffiliations(newAffList);
        } 

        oAffList = (List<Affiliation__c>)oldList;
        newAffList = (List<Affiliation__c>)newList;

        List<Affiliation__c> uncheckedAffList = new List<Affiliation__c>();
        Set<Id> acctIdSet = new Set<Id>();

        for ( Integer index = 0; index < newAffList.size(); index++ ) {
            if ( oAffList[index].Primary_Contact__c != newAffList[index].Primary_Contact__c && !newAffList[index].Primary_Contact__c ) {
                acctIdSet.add( newAffList[index].Account__c );
            }            
        }
        AffiliationPrimaryContactMatch.checkAccountNoPrimary(acctIdSet);
    }

    /*
            The updatePrimaryContacts function takes an input of a list of affiliations. 
            The affiliation has an Account__c and Contact__c lookup field
            For every affiliation, this function goes to the account and makes the account's Primary_Contact__c the same as the affiliation's Contact
            the list of accounts is then updated
    */
    public static void updatePrimaryContacts(List<Affiliation__c> affList){

        List<Account> accList = new List<Account>();
        for(Affiliation__c affiliation : affList){
            Account acc = new Account(
                id = affiliation.Account__c
            );
            acc.Primary_Contact__c = affiliation.Contact__c;
            if(AffiliationPrimaryContactMatch.findAccountMatch(acc, accList) == null){
                accList.add(acc);
            }
        }

        update accList;
    }

    //returns the affiliation from affList that matches, else returns null
    public static Affiliation__c findAffiliationMatch(Affiliation__c affiliation, List<Affiliation__c> affList){
        for(Affiliation__c aff : affList){
            if(affiliation.id == aff.id){
                return aff;
            }
        }
        return null;
    }
    

    //returns the account from accList that matches, else returns null
    public static Account findAccountMatch(Account acc, List<Account> accList){
        for(Account a : accList){
            if (a.id == acc.id){
                return a;
            }
        }
        return null;
    }

    //takes a list of affiliations and returns only the affiliations with the value equivalent to keptValue for the checkbox field Primary_Contact__c
    public static List<Affiliation__c> filterByPrimaryContactCheckbox(List<Affiliation__c> affList, boolean keptValue){
        

        //if the primary contact checkbox is mismatched, remove that affiliation from the list
        List<Integer> indices = new List<Integer>();
        for(Affiliation__c affiliation : affList){
            if(affiliation.primary_contact__c != keptValue){
                indices.add(affList.indexOf(affiliation));
            }
        }

        for(integer i = indices.size() - 1; i >= 0; i = i - 1){
            affList.remove(indices.get(i));
        }
        indices.clear();


        return affList;
    }

    //takes a 2 lists of affiliations and returns only the affiliations where
    //      1) the affiliation is in both lists AND
    //      2) in the old list the checkbox field Primary_Contact__c is false AND
    //      3) in the new list the checkbox field Primary_Contact__c is true
    public static List<Affiliation__c> filterByPrimaryContactCheckbox(List<Affiliation__c> oldAffList, List<Affiliation__c> newAffList){


        //remove any affiliations from the new list, if they have primary contact false
        newAffList = AffiliationPrimaryContactMatch.filterByPrimaryContactCheckbox(newAffList, true);

        //remove any affiliations from the previous list, if they have primary contact true
        oldAffList = AffiliationPrimaryContactMatch.filterByPrimaryContactCheckbox(oldAffList, false);

        //of the remaining affiliations, only keep it if it exists on both the prev and new lists
        if (newAffList.size() > 0 && oldAffList.size() > 0){

            List<integer> indices = new List<integer>();
            Affiliation__c matchingAff = new Affiliation__c();

            for(Affiliation__c affiliation : newAffList){
                matchingAff = null;
                matchingAff = findAffiliationMatch(affiliation, oldAffList);
                if(matchingAff == null){
                    indices.add(newAffList.indexOf(affiliation));
                }                
            }
            //remove elements from newList
            for(integer i = indices.size() - 1; i >= 0; i = i - 1){
                newAffList.remove(indices.get(i));

            }
            indices.clear();
        }

        return newAffList;
    }

    //takes a list of affiliations and only returns affiliations where the fields Account__r.Primary_Contact__c and Contact__c are not equivalent
    public static List<Affiliation__c> filterByDifferentPrimaryContact(List<Affiliation__c> affList){

        //Go through list of Affiliations
        List<integer> indices = new List<integer>();

        for (Affiliation__c affiliation : affList){
            //check if the Affiliation's Contact and Account's Primary Contact match
            if (affiliation.Contact__c == affiliation.Account__r.Primary_Contact__c){
                //Remove affiliation from the list
                indices.add(affList.indexOf(affiliation));
            }
        }

        for(integer i = indices.size() - 1; i >= 0; i = i - 1){
            affList.remove(indices.get(i));

        }

        return affList;
    }

    //takes a list of affiliations. The function creates a list of Accounts that are pointed to by the affiliations.
    //The function then finds all affiliations that point to the list of Accounts
    //if the affiliation's contact does not match the account's primary contact then the affiliation's Primary_Contact__c checkbox is made false
    //The function then updates all the affected affiliations. This will cause 1 level of recursion
    //This function only updates affiliations that have their Primary__Contact__c checkbox false, so recursive loop should be avoidable by using filterByPrimaryContactCheckbox
    public static void uncheckPreviousPrimaryContactAffiliations(List<Affiliation__c> affList){

        //Make a set of ids of appropriate accounts
        Set<String> accIdList = new Set<String>();
        for(Affiliation__c affiliation : affList){
            accIdList.add(affiliation.Account__c);
        }

        //Get a new list of all affiliations that point to any of the accounts
        List<Affiliation__c> previousAffiliations = new List<Affiliation__c>();
        if(accIdList.size() > 0){
            previousAffiliations.addAll([SELECT id, contact__c, account__c, primary_contact__c, account__r.Primary_Contact__c FROM Affiliation__c WHERE Account__c IN :accIdList]);
        }

        //Go through list of Affiliations if the affiliation's contact does not match the new primary contact of the account, uncheck it
        for(Affiliation__c affiliation : previousAffiliations){
            if(affiliation.contact__c != affiliation.account__r.Primary_Contact__c){
                affiliation.primary_contact__c = false;
            }
        }
        previousAffiliations = AffiliationPrimaryContactMatch.filterByPrimaryContactCheckbox(previousAffiliations, false);

        if (previousAffiliations.size() > 0){
            system.debug('RECURSION ENTER');
            update previousAffiliations;   
            system.debug('RECURSION EXIT');
        }
    }

    public static void checkAccountNoPrimary( Set<Id> acctIdSet ) {
        List<Account> updateAcctLst = new List<Account>();

        for ( Account acct : [ SELECT Id, Name, Primary_Contact__c, ( Select Id, Contact__r.Name, primary_contact__c FROM Affiliations__r WHERE 
            Primary_Contact__c = TRUE ) FROM Account WHERE Id IN :acctIdSet AND Primary_Contact__c != null ] ) {
                if ( acct.Affiliations__r == null || ( acct.Affiliations__r != null && acct.Affiliations__r.isEmpty() ) ) {
                    updateAcctLst.add( new Account(
                        Id = acct.Id, Primary_Contact__c = null
                    ) );
                }
        }
        if ( updateAcctLst != null && !updateAcctLst.isEmpty() ) {
            update updateAcctLst;
        }
    }
}