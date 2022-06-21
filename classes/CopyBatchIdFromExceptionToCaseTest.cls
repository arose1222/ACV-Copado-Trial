@isTest
public with sharing class CopyBatchIdFromExceptionToCaseTest {
    
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount();
        insert a;
        Contact c = TestUtility.createContact(a);
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Auction__c au = TestUtility.createAuction(a,c,v);
        insert au;
        Case title = TestUtility.createTitleCase(au, a, c);
        insert title;
        Case title2 = TestUtility.createTitleCase(au, a, c);
        insert title2;
    }

    @isTest
    static void testStandardFlow(){
        List<Case> clist = [select id from case];
        //if(clist.size() > 0){
            Exception__c e = new Exception__c(Batch_Id__c = '123');
            insert e;
            e.Related_Case__c = clist[0].id;
            update e;
        //}
        System.assertEquals(1,[Select Id from Case Where Batch_Id__c = '123'].size());
        //System.assert([Select Id from Case Where Batch_Id__c = '123'].size() == 1, 'Multiple Cases with the same batch Id, or No Cases found');
    }

    @isTest
    static void testBlankBatchId(){
        List<Case> clist = [select id from case];
        //if(clist.size() > 0){
            Exception__c e = new Exception__c();
            insert e;
            e.Related_Case__c = clist[0].id;
            update e;
        //}

        System.assert([Select Id from Case Where Batch_Id__c != null].size() < 1, 'Cases with Batch Id when there shouldnt be one');
    }

    @isTest
    static void testChangingACase(){
        List<Case> clist = [select id from case];
        //if(clist.size() > 1){
            Exception__c e = new Exception__c(Batch_Id__c = '123');
            insert e;
            e.Related_Case__c = clist[0].id;
            update e;
            e.Related_Case__c = clist[1].id;
            update e;
        //}
        System.assertEquals(1,[Select Id from Case Where Batch_Id__c = '123'].size());
        //System.assert([Select Id from Case Where Batch_Id__c = '123'].size() == 1, 'Multiple Cases with the same batch Id, or No Cases found');
    }

    @isTest
    static void testInsertExceptionWithCase(){
        List<Case> clist = [SELECT Id FROM Case];
        Exception__c exc = new Exception__c(Batch_Id__c = '42069', Related_Case__c = clist[0].Id);
        insert exc;

        System.assertEquals(1, [SELECT Id FROM Case WHERE Batch_Id__c = '42069'].size());
    }    
}