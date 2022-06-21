@isTest
public class groupingControllerTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;
        Group__c g = TestUtility.createGroup('ACV group test 1');
        insert g;
        List<Account> aList = new List<Account>();
        aList.add(a);
        insert TestUtility.createGroupAffiliation(g,aList);
    }

    @isTest
    static void testGettingGroups(){
        List<LWCUtility.Picklist> ngw = (List<LWCUtility.Picklist>)JSON.deserialize(groupingController.generateExistingGroups(), List<LWCUtility.Picklist>.class);
        System.assert(ngw.size() > 0, 'No Groups Retruned');
    }

    @isTest
    static void testCreateNewGroup(){
        List<Group__c> gList = [Select Id from Group__c];
        Group__c g = TestUtility.createGroup('ACV group test 2');
        insert g;
        List<String> idList = new List<String>();
        idList.add(gList[0].Id);
        String s = JSON.serialize(new groupingController.newGroupWrapper(g.id,idList));
        //next line is just for line coverage and holds no logical value
        groupingController.newGroupWrapper gw = new groupingController.newGroupWrapper();
        groupingController.generateNewGroup(s);
        system.assert([select id, Account__c from Group_Affiliation__c where Group__c = :g.id].size() == 1, 'More or less than one GA is present');
    }
}