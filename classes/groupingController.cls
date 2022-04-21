public class groupingController {
    
    @AuraEnabled(cacheable = true)
    public static String generateExistingGroups(){
        List<LWCUtility.Picklist> returnList = new List<LWCUtility.Picklist>();
        for(Group__c g:[Select Id, Name from Group__c]){
            returnList.add(new LWCUtility.Picklist(g.Name,g.Id));
        }

        return JSON.serialize(returnList);
    }

    @AuraEnabled
    public static void  generateNewGroup(String inputString){
        system.debug('this thing');
        newGroupWrapper ngw = (newGroupWrapper)JSON.deserialize(inputString, newGroupWrapper.class);
        system.debug(ngw);
        if(ngw.groupList.size() > 0){
            set<id> accountIdSet = new set<id>();
            List<Group_Affiliation__c> gaList = new List<Group_Affiliation__c>();
            for(Group_Affiliation__c ga :[select id, Account__c from Group_Affiliation__c where Group__c in :ngw.groupList]){
                accountIdSet.add(ga.Account__c);
                system.debug('GA');
                system.debug(ga);
            }
            system.debug(accountIdSet);
            if(accountIdSet.size() > 0){
                for(Id i :accountIdSet){
                    System.debug('account loop');
                    gaList.add(new Group_Affiliation__c(Account__c = i, Group__c = ngw.groupId));
                }
            }
            if(gaList.size() > 0){
                System.debug('ga list: '+gaList);
                insert gaList;
            }
        }
    }

    public class newGroupWrapper{
        public String groupId;
        public List<String> groupList = new List<String>();

        public newGroupWrapper(){
            this.groupId = '';
            this.groupList = new List<String>();
        }

        public newGroupWrapper(String gId, List<String> gList){
            this.groupId = gId;
            this.groupList = gList;
        }
    }
}