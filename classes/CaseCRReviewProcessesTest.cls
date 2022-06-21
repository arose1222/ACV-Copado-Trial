@isTest
public class CaseCRReviewProcessesTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        insert new CaseTriggerFlag__c(Name='Default', Enabled__c = true);
        List<Account> accountList = New List<Account>();
        accountList.add(new Account(Name='seller',IST_Account_Owner__c =UserInfo.getUserId()));
        accountList.add(new Account(Name='buyer',IST_Account_Owner__c = UserInfo.getUserId()));
        insert accountList;
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(FirstName='seller', LastName='seller', accountId=accountList[0].id));
        contactList.add(new Contact(FirstName='buyer', LastName='buyer', accountId=accountList[1].id));
        insert contactList;
        vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
        insert newCar;
        vehicle__c newCar1 = new vehicle__c(year__c='2010',make__c='test make', model__c='test model', vin__c = '1234567890102031');
        insert newCar1;
        auction__c newAuction = new auction__c(status__c = 'Active', end_time__c = System.Now(),Buyer_Dealership__c = accountList[1].id, 
        Seller_Dealership__c = accountList[0].id,Floor_Price__c = 500, Winning_Bid_Price__c = 450, vehicle_id__c = newCar.id);
        insert newAuction;
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Arbitration Claim').getRecordTypeId();
        Case newCase = new Case(accountId = accountList[0].id,RecordTypeId = arbRecordType, Vehicle__c = newCar.id);
        insert newCase;
    }

    

    //Process test: Date/Time stamp on Case Reviews. DONE
    @isTest 
    static void dateTimeStamponCase() {
        Test.startTest();
        //These status values can only be picked with CR Review or Arbitration Claims
        Id arbRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CR Review').getRecordTypeId();
        Auction__c a = [SELECT id FROM Auction__c LIMIT 1 ];
        case newCase = new case(RecordTypeId = arbRecordType, Status = 'New', Auction_Number__c = a.Id);
        insert newCase;

        newCase = [select status, Date_Time_Case_Status_Under_Review__c from case where Id = : newCase.Id limit 1 ];
        System.assertEquals( null , newCase.Date_Time_Case_Status_Under_Review__c);
        CaseCRReviewProcesses.beforeUpdateToggle();
        newCase.status = 'Under Review';
        update newCase;
        newCase = [select status, Date_Time_Case_Status_Under_Review__c from case where Id = : newCase.Id limit 1 ];
        System.assertNotEquals( null , newCase.Date_Time_Case_Status_Under_Review__c);


        System.Debug('dateTimeStamponCase CPU Time: ' + String.valueOf(Limits.getCpuTime()));
        Test.stopTest();
    }
    @isTest
    static void testToggles(){
        Boolean foo = false;
        CaseCRReviewProcesses.beforeInsertToggle();
        CaseCRReviewProcesses.beforeInsertToggle(foo);
        CaseCRReviewProcesses.afterInsertToggle();
        CaseCRReviewProcesses.afterInsertToggle(foo);
        CaseCRReviewProcesses.beforeUpdateToggle();
        CaseCRReviewProcesses.beforeUpdateToggle(foo);
        CaseCRReviewProcesses.afterUpdateToggle();
        CaseCRReviewProcesses.afterUpdateToggle(foo);
    }
}