@isTest
    class updateCasesOnBuyerExceptionschangeTEST {
    static testMethod void validateBuyerException() {
        
    //Create new account record
        Account a = new Account (Name='Test Exceptions Update', Buyer_s_Assurance_Exceptions__c='Goodwill');
        insert a;
    //Create new case record
        Case c = new Case (Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=a.id);
        insert c;
    //Update account record
        a.Buyer_s_Assurance_Exceptions__c = 'Deny';
        update a;
        
            }
        }