@istest
public class ParentOrganizationChangeEventTest {
    @TestSetup
    static void makeData(){
        System.Debug('Make data 1');
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Dealership_ID__c = '456', legal_Name__c='parent', dealer_type__c='1', Name='parent',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Dealership_ID__c = '457', legal_Name__c='parent2', dealer_type__c='1',Name='parent2',IST_Account_Owner__c =UserInfo.getUserId(),BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account(Dealership_ID__c = '123', legal_Name__c='child', dealer_type__c='1',Name='child',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account( Name='noID parent',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList.add(new Account( Name='noID child',IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountList;
        System.Debug('Make data 2');

        Account p = [Select id From Account Where Name='parent'];
        Account p2 = [Select id, Dealership_ID__c, RecordType.DeveloperName From Account Where Name='parent2'];
        List<Account> accountList2 = New List<Account>();
        accountList2.add(new Account(Dealership_ID__c = '124', Name='child2', legal_Name__c='child2', dealer_type__c='1',ParentId=p.id, IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        accountList2.add(new Account(Dealership_ID__c = '125', Name='child3', legal_Name__c='child3', dealer_type__c='1',ParentId=p2.id,  IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert accountList2;
        System.Debug('Make data 3');
        delete [Select id, Status_Code__c, Request_Message__c From Integration_Result__c];

    }
    @istest
    static void AddParentAccountTest()  {
        //Add parent account to child
        Account ch = new Account();
        ch = [Select id From Account Where Name='child'];
        Account pa = [Select id From Account Where Name='parent'];
        ch.ParentId=pa.id;
        update ch;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:ch.id];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'add-parent-organization'
        System.assert(integrationTest.Request_Message__c.contains('add-parent-organization'), 'Adding Parent account to a child did not fire an add-parent-organization event');

    }
    @istest
    static void ChangeParentAccountTest()  {
        //Update parent account of child
        Account ch = new Account();
        ch = [Select id, ParentId From Account Where Name='child2'];  
        Account pa = [Select id From Account Where Name='parent2'];
        ch.ParentId=pa.id;
        update ch;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:ch.id];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'update-parent-organization'
        System.assert(integrationTest.Request_Message__c.contains('update-parent-organization'), 'Updating Parent account to a child did not fire an update-parent-organization event');

    }
    @istest
    static void RemoveParentAccountTest()  {
        //Update parent account of child
        Account ch = new Account();
        ch = [Select id, ParentId From Account Where Name='child3'];  
        ch.ParentId=null;
        update ch;
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:ch.id];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'update-parent-organization'
        System.assert(integrationTest.Request_Message__c.contains('remove-parent-organization'), 'Removing Parent account to a child did not fire a remove-parent-organization event');

    }
    @istest
    static void AddParentUponAccountCreateTest()  {
        //Add parent account to child
        System.debug([Select id From Account Where Name='child4']);
        System.debug([Select id From Account Where Dealership_ID__c = '126']);
        System.debug([Select id From Account Where Name='parent']);
        Account pa = [Select id From Account Where Name='parent'];
        Account ch = new Account();
        ch = (new Account(Dealership_ID__c = '126', Name='child4', legal_Name__c='child4', dealer_type__c='1',ParentId=pa.id,  IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        insert ch;
        System.debug([Select id, ParentId, Name From Account Where Name='child4']);
        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c From Integration_Result__c Where recordId__c=:ch.id];

        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Fired Platform Event is event type 'add-parent-organization'
        System.assert(integrationTest.Request_Message__c.contains('add-parent-organization'), 'Adding Parent account to a child up child creation did not fire an add-parent-organization event');
    }
    @istest
    static void InsertParentFailureTest()  {
        //Attempt to add a Standard Parent Account to a Child Account without a Dealership Id
        Account pa = [Select id From Account Where Name='noID parent'];
        Account ch = new Account();
        ch = (new Account(Dealership_ID__c = '126', Name='child5', legal_Name__c='child5', dealer_type__c='1',ParentId=pa.id,  IST_Account_Owner__c = UserInfo.getUserId(),BillingStreet='123 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US'));
        Boolean goterror = false;
        
        try{
            insert ch;
        }catch(Exception exc){
            if(exc.getMessage().contains('Parent Account must be a Valid ACV Dealership with a Dealer ID and be a Standard Account type')){
                goterror = true;
            }        
        }
        
        //Confirm Validation Rule 'Parent_Account_must_be_Dealership' error has fired
        System.assert(goterror, 'Validation Rule did not fire as expected for Parent Account record without Dealership_Id__c populated');
    }
}