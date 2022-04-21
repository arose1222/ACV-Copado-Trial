@isTest
    class updateCasesOnVINchangeTEST     {
    static testMethod void validateVINchange() {
        
    //Create new account record
        Account a = new Account (Name='Test Exceptions Update');
        insert a;
    //Create new vehicle records    
        Vehicle__c v = new Vehicle__c (Name='987654321');     
        Vehicle__c v1 = new Vehicle__c (Name='9876543210');
        insert v;
        insert v1;
    //Create new auction record
        Auction__c au = new Auction__c (Name='987654321', Vehicle_id__c=v.id);
        insert au;
    //Create new case record
        Case c = new Case (Status='New', Origin='Web', Buyer_Confusion__c='No', AccountId=a.id, Auction_number__c=au.id, Vehicle__c=v.id);
        insert c;
    //Update auction record
        au.vehicle_id__c=v1.id;
        update au;
        }
            }