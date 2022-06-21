@istest
public class GroupChangeEventTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        List<Group__c> groupList = new List<Group__c>();
        groupList.add(TestUtility.createGroup('TEST GROUP 1'));
        insert groupList;
        delete [Select id, Status_Code__c, Request_Message__c From Integration_Result__c ];

    }
    @istest
    static void UpdateGroupNameTest()  {
        //Update Group Name
        Group__c g = new Group__c();
        g = [Select id From group__c Where Name='TEST GROUP 1'];
        g.Disable_Bid_Visibility__c =TRUE;
        update g;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Limit 1];
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-organization-group'
        System.assert(integrationTest.Request_Message__c.contains('update-organization-group'), 'Changing Group name does not generate update-organization-group Platform Event');
    }
    @istest
    static void UpdateGroupActiveFlagTest()  {
        //Update Group Name
        Group__c g = new Group__c();
        g = [Select id From group__c Where Name='TEST GROUP 1'];
        g.Active__c =false;
        update g;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Limit 1];
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'update-organization-group'
        System.assert(integrationTest.Request_Message__c.contains('update-organization-group'), 'Changing Group active status does not generate update-organization-group Platform Event');
    }
    @istest
    static void InsertGroupTest()  {
        //insert Group 
        Group__c gro = new Group__c();
        gro = (new Group__c(Name='TEST GROUP 2', Active__c=true));
        insert gro;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Limit 1];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'create-organization-group'
        System.assert(integrationTest.Request_Message__c.contains('create-organization-group'), 'Inserting Group does not generate create-organization-group Platform Event');
    }
}