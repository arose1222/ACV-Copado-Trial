@isTest
public class WorkTypeGanttColorTest {

        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
  
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

    @IsTest
    static void TestNewUrgentSAValuationDomain() {
        
        FSL_Special_Gantt_Color_Setting__mdt urgentServiceApptMetadata = [SELECT Label, Color__c FROM FSL_Special_Gantt_Color_Setting__mdt WHERE Label = 'Valuation Domain' LIMIT 1];

        User u = [SELECT Id, FirstName, LastName FROM User WHERE Name = 'Valuation Domain' LIMIT 1];

        workType siWorkType = FSLWorkProcessUtility.availableWTMap.get('inspection');
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        ServiceTerritory svcTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();

        System.runAs(u) {
            FSLTestUtility.generateWork( siWorkType, siWorkType, testAccount, '14225', svcTerr, 1 );
        }

        Test.stopTest();

        ServiceAppointment svcAppt = [SELECT Id, FSL__GanttColor__c FROM ServiceAppointment LIMIT 1];
        system.assertEquals(urgentServiceApptMetadata.Color__c, svcAppt.FSL__GanttColor__c);
    }

    @IsTest
    static void TestLiveAppraisalSA() {
        
        FSL_Special_Gantt_Color_Setting__mdt liveAppraisalColorMetadata = [SELECT Label, Color__c FROM FSL_Special_Gantt_Color_Setting__mdt WHERE Label = 'Live Appraisal' LIMIT 1];
        workType siWorkType = FSLWorkProcessUtility.availableWTMap.get('inspection');
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        ServiceTerritory svcTerr = [SELECT Id FROM ServiceTerritory LIMIT 1];

        Test.startTest();
            FSLTestUtility.generateWork( siWorkType, siWorkType, testAccount, '14225', svcTerr, 1 );
        	ServiceAppointment svcAppt = [SELECT Id, FSL__GanttColor__c, Live_Appraisal_Event__c FROM ServiceAppointment LIMIT 1];
        	svcAppt.Live_Appraisal_Event__c = true;
        	update svcAppt;
        Test.stopTest();

        svcAppt = [SELECT Id, FSL__GanttColor__c FROM ServiceAppointment LIMIT 1];
        system.assertEquals(liveAppraisalColorMetadata.Color__c, svcAppt.FSL__GanttColor__c, 
                            'Expected = ' + liveAppraisalColorMetadata.Color__c + '   Actual = ' + svcAppt.FSL__GanttColor__c);
    }
    
}