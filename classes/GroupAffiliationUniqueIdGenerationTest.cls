@istest
public with sharing class GroupAffiliationUniqueIdGenerationTest {
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
        insert groupAffList;
        delete [Select id, Status_Code__c, Request_Message__c From Integration_Result__c ];

    }
    public static testMethod void TestGroupAffIdGenerationUponInsert(){
        //Generate a unique group_account id upon creation of a Group Affiliation
        Group_Affiliation__c newGrpAff = new Group_Affiliation__c();
        newGrpAff = [SELECT ID, Unique_Affiliation__c FROM Group_Affiliation__c LIMIT 1];
        // insert newGrpAff;
        System.debug(newGrpAff);
        System.assert(newGrpAff.Unique_Affiliation__c != null, 'Unique Id for Group Affiliation is Null when it shouldnt be');      
    }
    public static testMethod void TestGroupAffIdGenerationUponUpdate(){
        //Generate a unique group_account id upon update of a group Affiliation if one does not already exist
        Group_Affiliation__c newGrpAff = new Group_Affiliation__c();
        newGrpAff = [SELECT ID, Unique_Affiliation__c FROM Group_Affiliation__c Limit 1];
        
        newGrpAff.Unique_Affiliation__c = null;
        update newGrpAff;
        newGrpAff = [SELECT ID, Unique_Affiliation__c FROM Group_Affiliation__c LIMIT 1];
        
        System.debug(newGrpAff);
        System.assert(newGrpAff.Unique_Affiliation__c != null, 'Unique Id for Group Affiliation is Null when it shouldnt be');      
    }
    public static testMethod void TestGroupAffIdDuplicateErrorUponInsert(){
        //Check for Error message when attempting to Insert a new Group affiliation with an already existing combination of group_account
        system.debug([Select id, account__c, group__c From group_affiliation__c]);
        Account ac = [Select id From Account Where Name='seller'];
        Group__c gr = [Select id From Group__c Limit 1];
        Group_Affiliation__c newGrpAff = new Group_Affiliation__c();
        newGrpAff = (new Group_Affiliation__c(Account__c=ac.id, Group__c=gr.id));

        //Should see a Duplicate_value error message becasuse the Unique_Affiliation__c field is a unique field
        Boolean goterror = false;
            try{
                insert newGrpAff;
            }catch(Exception exc){
                if(exc.getMessage().contains('DUPLICATE_VALUE')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'Duplicate Value check has failed allowing two duplicate Group Affiliations to be created');   
    }        
    public static testMethod void TestGroupAffIdAccountChangeErrorUponInsert(){
        //Check an error message will fire when attempting to Change the Account field on an already exisitng group affiliation
        Account acOld = [Select id From Account Where Name='seller'];
        Account acNew = [Select id From Account Where Name='buyer'];
        Group_Affiliation__c newGrpAff = new Group_Affiliation__c();
        newGrpAff = [SELECT ID, Unique_Affiliation__c, Account__c, Group__c FROM Group_Affiliation__c Where Account__c=:acOld.id];
        // insert newGrpAff;
        system.debug(acOld);
        system.debug(acNew);
        system.debug(newGrpAff);
        //Check that GroupAffiliationAccountChangeError fires when attempting ot change an Account field
        Boolean goterror = false;
            try{
                newGrpAff.Account__c=acNew.id;
                update newGrpAff;
                system.debug(newGrpAff);
            }catch(Exception exc){
                if(exc.getMessage().contains('Cannot change Group Affiliation account after creation')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'Validation Rule to prevent Account record change on Group Affiliation has failed');   
    }
}