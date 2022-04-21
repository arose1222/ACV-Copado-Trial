@isTest
public class BatchframeworkTesting {

    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        insert a;
    }


    @isTest
    public static void basicTestBtachRunner(){
        Test.startTest();
        ACVUtility.scheduleJob(System.now().addMinutes(2), 'BatchRunner');
        Test.stopTest();
    }
    @isTest
    public static void basicTestBtachRunnerDelete(){
        Test.startTest();
        Database.executeBatch(new BatchTemplateBatch('SELECT ID From Account', 'Delete', 'SUPERTEST'));
        Test.stopTest();
        system.assert([SELECT COUNT() FROM Account] == 0, 'Account found when should not be');
    }

    @isTest
    public static void basicTestBtachRunnerUpdate(){
        Test.startTest();
        Database.executeBatch(new BatchTemplateBatch('SELECT ID From Account', 'Blank Update', 'SUPERTEST'));
        Test.stopTest();
        system.assert([SELECT COUNT() FROM Account] == 1, 'Account is not in the system');
    }

    @isTest
    public static void basicTestBtachRunnerDeleteError(){
        Test.startTest();
        BatchUtilityClass.testingFlag = true;
        ACVUtility.scheduleJob(System.now().addMinutes(2), 'BatchRunner');
        Test.stopTest();
    }

    @isTest
    public static void basicTestBtachRunnerUpdateError(){
        Test.startTest();
        BatchUtilityClass.testingFlag = true;
        Database.executeBatch(new BatchTemplateBatch('SELECT ID From Account', 'Blank Update', 'SUPERTEST'));
        Test.stopTest();
    }
}