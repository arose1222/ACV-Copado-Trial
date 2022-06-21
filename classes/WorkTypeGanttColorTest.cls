@isTest
public class WorkTypeGanttColorTest {

    @TestSetup
    public static void makeData() {
  
        // Create Account (needed for Work Order):
        Account vciAccount = TestUtility.createAccount('vciTestAccount');
        insert vciAccount;

        FSLTestUtility.createAllStructureWithParentST('Cheektowaga', '14225');
    }


    @IsTest
    static void TestNewSA() {
        
        workType siWorkType = FSLWorkProcessUtility.availableWTMap.get('inspection');
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        ServiceTerritory svcTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
            FSLTestUtility.generateWork( siWorkType, siWorkType, testAccount, '14225', svcTerr, 1 );
        Test.stopTest();

        ServiceAppointment svcAppt = [SELECT Id, FSL__GanttColor__c FROM ServiceAppointment LIMIT 1];
        system.assertEquals(siWorkType.Work_Type_Color__c, svcAppt.FSL__GanttColor__c, 
                            'Expected = ' + siWorkType.Work_Type_Color__c + '   Actual = ' + svcAppt.FSL__GanttColor__c);
    }

}