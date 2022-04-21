@isTest
    class updateCasesOnISTAccountOwnerchangeTEST {
    static testMethod void validateISTAccountOwner() {
        
    //Create new account record
        Account a = new Account (Name='Test ISTOWNER Update', IST_Account_Owner__c ='0050a00000Hqq4jAAB');
        insert a;
    //Create new case record
        Case c = new Case (Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=a.id);
        insert c;
    //Update account record
        a.IST_Account_Owner__c = '0050a00000HqZm5AAF';
        update a;
        
            }
        }