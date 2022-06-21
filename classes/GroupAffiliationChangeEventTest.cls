@istest
public class GroupAffiliationChangeEventTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account( Name='noID',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountList;
        List<Group__c> groupList = new List<Group__c>();
        groupList.add(new Group__c(Name='TEST GROUP 1', Active__c=true));
        insert groupList;
        List<Group_Affiliation__c> groupAffList = new List<Group_Affiliation__c>();
        groupAffList.add(new Group_Affiliation__c(Account__c=accountList[0].id, Group__c=groupList[0].id, Active__c=true));
        groupAffList.add(new Group_Affiliation__c(Account__c=accountList[1].id, Group__c=groupList[0].id, Active__c=false));
        insert groupAffList;
        delete [Select id, Status_Code__c, Request_Message__c From Integration_Result__c ];
    }
    @istest
    static void UpdateGroupAffFlagFalseTest()  {
        //Flip active flag to False for an already existing Group Affiliation record
        Group_Affiliation__c ga = new Group_Affiliation__c();
        ga = [Select id From Group_Affiliation__c Where Account__r.Name='seller'];
        ga.Active__c=false;
        update ga;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:ga.id];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'remove-group-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('remove-group-affiliation'), 'Flipping Active Flag to False does not fire remove-group-affiliation Platform Event');

    }
    @istest
    static void UpdateGroupAffFlagTrueTest()  {
        //Flip active flag to True for an already existing Group Affiliation record
        Group_Affiliation__c ga = new Group_Affiliation__c();
        ga = [Select id From Group_Affiliation__c Where Account__r.Dealership_ID__c ='123'];
        ga.Active__c=true;
        update ga;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:ga.id];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'add-group-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('add-group-affiliation'), 'Flipping Active Flag to False does not fire remove-group-affiliation Platform Event');
    }
    @istest
    static void CreateGroupAffFailureTest()  {
        //Attempt to add a Standard Account to a Group Affiliation without a Dealership Id
        Account ac = [Select id From Account Where Name='noID'];
        Group__c gr = [Select id From Group__c Where Name='TEST GROUP 1'];
        Group_Affiliation__c gaff = new Group_Affiliation__c();
        gaff = (new Group_Affiliation__c(Account__c=ac.id, Group__c=gr.id));
        Boolean goterror = false;
        
        try{
            insert gaff;
        }catch(Exception exc){
            if(exc.getMessage().contains('Group affiliation to a Standard Account type must have a Dealership Id')){
                goterror = true;
            }        
        }
        
        //Confirm Validation Rule 'Standard_Account_must_have_Org_ID' error has fired
        System.assert(goterror, 'Validation Rule did not fire as expected for related Account record without Dealership_Id__c populated');
    }
    @istest
    static void InsertGroupAffTest()  {
        //Insert a new Group Affiliation with Active Flag defaulting to True
        Account a = [Select id, RecordType.DeveloperName From Account Where Name='seller'];
        Group__c g = (new Group__c(Name='TEST GROUP 2', Active__c=true));
        insert g;
        
        Group_Affiliation__c gaf = new Group_Affiliation__c();
        gaf = (new Group_Affiliation__c(Account__c=a.id, Group__c=g.id));
        insert gaf;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:gaf.id];
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'add-group-affiliation'
        System.assert(integrationTest.Request_Message__c.contains('add-group-affiliation'), 'Flipping Active Flag to False does not fire remove-group-affiliation Platform Event');
    }
}