@istest
public with sharing class AffiliationUniqueIdGenerationTest {
    @testSetup
    Static void createTestData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Id acvuserRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('ACV User').getRecordTypeId();
        
        Account a = new Account(Dealership_ID__c = '456', Name='seller',legal_Name__c='seller', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a;
        Contact c = new Contact(FirstName = 'test', LastName='Contact1', AccountId = a.id, id__c='123', RecordTypeId = acvuserRecordTypeId, email='test1@email.com');
        insert c;
        Account a2 = new Account(Dealership_ID__c = '123', Name='buyer',legal_Name__c='buyer', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a2;
        Contact c2 = new Contact(FirstName = 'test', LastName='Contact2', AccountId = a2.id, id__c='456', RecordTypeId = acvuserRecordTypeId, email='test@email.com');
        insert c2;
        Account a3 = new Account(Name='NoId',legal_Name__c='NoId', dealer_type__c='1',BillingStreet='158 main st', BillingState='NY', BillingCity='Buffalo', BillingPostalCode='14214', BillingCountry='US');
        insert a3;
        Contact c3 = new Contact(FirstName = 'test', LastName='Contact3', AccountId = a3.id, email='test@email.com');
        insert c3;
        Affiliation__c af1 = new Affiliation__c(Account__c=a.id, Contact__c=c.id, Active__c=true, type__c='rep');
        insert af1;
        System.Debug('Affiliation__c:');
        System.Debug(af1);
        // Affiliation__c a2 = new Affiliation__c(Account__c=a2, Contact__c=c2, Active__c=true);
        // insert a2;
        // Affiliation__c a3 = new Affiliation__c(Account__c=a3, Contact__c=c3, Active__c=true);
        // insert a3;


    }
    public static testMethod void TestAffIdGenerationUponInsert(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Generate a unique group_account id upon creation of a Group Affiliation
        Affiliation__c newAff = new Affiliation__c();
        newAff = [SELECT ID, Id__c FROM Affiliation__c LIMIT 1];
        // insert newGrpAff;
        System.debug(newAff);
        System.assert(newAff.Id__c != null, 'Unique Id for Affiliation is Null when it shouldnt be');      
    }
    public static testMethod void TestAffIdGenerationUponUpdate(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Generate a unique group_account id upon update of a group Affiliation if one does not already exist
        Affiliation__c newAff = new Affiliation__c();
        newAff = [SELECT ID, Id__c FROM Affiliation__c Limit 1];
        
        newAff.Id__c = null;
        update newAff;
        newAff = [SELECT ID, Id__c FROM Affiliation__c LIMIT 1];
        
        System.debug(newAff);
        System.assert(newAff.id__c != null, 'Unique Id for Affiliation is Null when it shouldnt be');      
    }
    public static testMethod void TestAffIdDuplicateErrorUponInsert(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check for Error message when attempting to Insert a new Group affiliation with an already existing combination of group_account
        system.debug([Select id, account__c, contact__c, id__c From Affiliation__c]);
        Account a = [Select id From Account Where Name='seller'];
        Contact c = [Select id From Contact Where LastName='Contact1'];
        Affiliation__c newAff = new Affiliation__c();
        newAff = (new Affiliation__c(Account__c=a.id, Contact__c=c.id, type__c='rep'));

        //Should see a Duplicate_value error message becasuse the Unique_Affiliation__c field is a unique field
        Boolean goterror = false;
            try{
                insert newAff;
            }catch(Exception exc){
                if(exc.getMessage().contains('DUPLICATE_VALUE')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'Duplicate Value check has failed allowing two duplicate Affiliations to be created');   
    }        
    public static testMethod void TestAffIdAccountChangeErrorUponInsert(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        //Check an error message will fire when attempting to Change the Account field on an already exisitng group affiliation
        Account acOld = [Select id From Account Where Name='seller'];
        Account acNew = [Select id From Account Where Name='buyer'];
        Affiliation__c newAff = new Affiliation__c();
        newAff = [SELECT ID, id__c, Account__c, Contact__c FROM Affiliation__c Where Account__c=:acOld.id];
        // insert newGrpAff;
        system.debug(acOld);
        system.debug(acNew);
        system.debug(newAff);
        //Check that GroupAffiliationAccountChangeError fires when attempting ot change an Account field
        Boolean goterror = false;
            try{
                newAff.Account__c=acNew.id;
                update newAff;
                system.debug(newAff);
            }catch(Exception exc){
                if(exc.getMessage().contains('Cannot change Affiliation account after creation')){
                    goterror = true;
                }        
            }
        System.assert(goterror, 'Validation Rule to prevent Account record change on Affiliation has failed');   
    }
}