@isTest
public class VerifyAccountActiveStatusBatchTest {
    public static final Id licenseId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Dealer_License').getRecordTypeId();
    public static final Id resaleId = Schema.SObjectType.Dealer_Docs__c.getRecordTypeInfosByDeveloperName().get('Resale_Certificate').getRecordTypeId();

    @isTest
    static void runTest() {
        //need today's date
        Date today = System.Today();
        Date future = System.Today().addMonths(5);
        //need some accounts
        List<Account> accountList = new List<Account>();
        //and two where Set_Active_Account_Check_Date__c is today (compliant)
        accountList.add(new Account(Name = 'Account1', legal_name__c='Account1', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Compliant', Set_Active_Account_Check_Date__c = today));
        accountList.add(new Account(Name = 'Account2', legal_name__c='Account2', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Compliant', Set_Active_Account_Check_Date__c = today));
        //make one with the field set to today but marked as not compliant
        accountList.add(new Account(Name = 'Account3', legal_name__c='Account3', dealer_type__c='1',IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Out Of Compliance', Set_Active_Account_Check_Date__c = today));
        //insert accounts
        insert accountList;
        //need to create some dealer docs that are linked to the accounts
        List<Dealer_Docs__c> docList = new List<Dealer_Docs__c>();
        //make a valid dealer doc in a special state for one of the accounts (license)
        docList.add(new Dealer_Docs__c(Account__c = accountList[0].Id, Expiration_Date__c = future, RecordTypeId = licenseId, Document_State__c = 'DE', License_Number__c = '33333', Compliant__c = true));
        //make a valid doc not in a special state for the second account (resale)
        docList.add(new Dealer_Docs__c(Account__c = accountList[1].Id, No_Expiration__c = true, RecordTypeId = resaleId, Document_State__c = 'NY', Permit_Resale_Number__c = '22222', Compliant__c = true));
        //insert docs
        insert docList;
        //need to re-set the Dealer_Doc_Compliance
        List<Account> forUpdate = [SELECT Id, Name, Dealer_Doc_Compliance__c, Set_Active_Account_Check_Date__c FROM Account];
        for (Account a : forUpdate) {
            if (a.Name == 'Account3') {
                a.Dealer_Doc_Compliance__c = 'Out Of Compliance'; //need to reset this because it will change when the docs are inserted
                //a.Set_Active_Account_Check_Date__c = today; //this will be set two weeks from now with the trigger so need to re-set
            }
            else if (a.Name == 'Account1' || a.Name == 'Account2') {
                a.Dealer_Doc_Compliance__c = 'Compliant'; //need to reset this because it will change when the docs are inserted
                //a.Set_Active_Account_Check_Date__c = today; //this will be set to two weeks from now with the trigger so need to re-set
            }
        }
        //update accounts
        update forUpdate;
        //and the date check fields because they will get changed when the docs are inserted/doc_compliance is updated
        List<Account> forUpdate2 = [SELECT Id, Name, Dealer_Doc_Compliance__c, Set_Active_Account_Check_Date__c FROM Account];
        System.debug(forUpdate2);
        for (Account ac : forUpdate2) {
            ac.Set_Active_Account_Check_Date__c = today; //again? what if above i only update the compliance, not the date so it's not as redundant?
        }
        //update again
        update forUpdate2; //this is dumb and i hate it
        //run batch
        Test.startTest();
            VerifyAccountActiveStatusBatch batch = new VerifyAccountActiveStatusBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
        //query
        List<Account> checkAccounts = [SELECT Id, Dealer_Doc_Compliance__c, Set_Active_Account_Check_Date__c FROM Account ORDER BY Name ASC];
        //system.asserts
        System.assertEquals('Compliant', checkAccounts[0].Dealer_Doc_Compliance__c); //should remain compliant because it has the correct docs
        System.assertEquals(null, checkAccounts[0].Set_Active_Account_Check_Date__c); //should null out when this runs through the batch
        System.assertEquals('Out Of Compliance', checkAccounts[1].Dealer_Doc_Compliance__c); //should be out of compliance because it doesn't have the right docs
        System.assertEquals(null, checkAccounts[1].Set_Active_Account_Check_Date__c); //should null out when this runs through the batch
        System.assertEquals('Out Of Compliance', checkAccounts[2].Dealer_Doc_Compliance__c); //should remain out of compliance
        System.assertEquals(null, checkAccounts[2].Set_Active_Account_Check_Date__c); //should null out when this runs through the batch
    }

    @isTest
    static void bulkTest() {
        Date today = System.Today();
        //create 200 accounts
        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < 50; i ++) {
            bulkAccounts.add(new Account(Name = 'Account' + i, IST_Account_Owner__c = UserInfo.getUserId(), Dealer_Doc_Compliance__c = 'Compliant', Dealer_Type__c = 'Independent', legal_name__c='Account '+i));
        }
        //insert
        insert bulkAccounts;
        //update the accounts to reset the Set_Active_Account_Check_Date
        List<Account> updateAccounts = [SELECT Id, Set_Active_Account_Check_Date__c FROM Account];
        for (Account a : updateAccounts) {
            a.Set_Active_Account_Check_Date__c = today;
        }
        update updateAccounts;
        //run batch
        Test.startTest();
            VerifyAccountActiveStatusBatch batch = new VerifyAccountActiveStatusBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
    }

    @isTest
    static void errorCheck() {
        //populate errorList
        VerifyAccountActiveStatusBatch.errorList.add('error');
        //run batch
        Test.startTest();
            VerifyAccountActiveStatusBatch batch = new VerifyAccountActiveStatusBatch();
            Batch.executeScheduledLogic();
        Test.stopTest();
    }
}