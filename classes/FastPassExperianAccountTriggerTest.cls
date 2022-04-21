@isTest
public class FastPassExperianAccountTriggerTest {	
    static testMethod void checkExperianObjectCreatedByAccount(){
        Account acc = new Account();
		acc.Name = 'Test Account';
        acc.FastPass_Approval__c = 'In Progress';
        insert acc;
        test.startTest();
        List <Account> accList = [SELECT Id FROM Account WHERE Id = :acc.Id];
        List <EXPRN__Exp_Business_Info__c> exp_business_info_list = [SELECT Id, EXPRN__Account_Name__c 
                                                                FROM EXPRN__Exp_Business_Info__c 
                                                                WHERE EXPRN__Account_Name__c = :acc.Id];

        system.assertEquals(1,accList.size());
        test.stopTest();
    }
    
    /*
    static testMethod void checkExperianObjectUpdatedByAccount(){
        Account acc = new Account();
		acc.Name = 'Test Account';
        acc.FastPass_Approval__c = '';
        insert acc;
        acc.FastPass_Approval__c = 'In Progress';
		update acc;
        test.startTest();
        List <EXPRN__Exp_Business_Info__c> exp_business_info_list = [SELECT Id, EXPRN__Account_Name__c 
                                                                FROM EXPRN__Exp_Business_Info__c 
                                                                WHERE EXPRN__Account_Name__c = :acc.Id];

        system.assertEquals(1,exp_business_info_list.size());
        test.stopTest();
    }
	*/
}