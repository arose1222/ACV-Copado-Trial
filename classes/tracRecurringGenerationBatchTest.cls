/**
 * Created by zdeng on 9/25/2019.
 * @see https://acvauctions.atlassian.net/browse/SI-564
 * @description Deprecated test class
 */

public class tracRecurringGenerationBatchTest {
//     @TestSetup
//     static void setUpData(){
//         Data_Schedule__c ds = new Data_Schedule__c();
//         ds.Frequency__c = 'Daily';
//         ds.Active__c = true;
//         ds.Horizon_Type__c = 'Months';
//         ds.Horizon_Length__c = 12;
//         ds.Batch_Size__c = 50;
//         insert ds;

//         insert FSLTestUtility.createWorkTypes();
//         WorkType wt2 = FSLWorkProcessUtility.availableWTMap.get( 'inspection' );

//         OperatingHours oh = new OperatingHours();
//         oh.Name = 'vciTest';
//         insert oh;

//         ServiceTerritory stParent = new ServiceTerritory();
//         stParent.Name = 'vciTestParent';
//         stParent.IsActive = true;
//         stParent.OperatingHoursId = oh.Id;
//         insert stParent;

//         ServiceTerritory st = new ServiceTerritory();
//         st.Name = 'vciTest';
//         st.IsActive = true;
//         st.OperatingHoursId = oh.Id;
//         st.ParentTerritoryId = stParent.Id;
//         insert st;

//         Account ac = TestUtility.createAccount();
//         ac.Name = 'vciTest';
//         ac.Service_Territory__c = st.Id;
//         insert ac;


//         Timeline__c tl0 = new Timeline__c();
//         tl0.Account__c = ac.Id;
//         tl0.Is_Active__c = TRUE;
//         tl0.Start_Date__c = Date.newInstance(2020,3,23);
//         tl0.Average_Number_Cars__c = 1;
// //        tl0.End_Date__c = Date.newInstance(2019,9,22).addMonths(6);
//         // tl0.Was_Modified__c = false;
//         tl0.Is_Active__c = true;
// 		tl0.Work_Type__c = wt2.id;
//         insert tl0;

//         Occurrence__c occ0 = tracGenerate_Test.generateTestOcc(tl0, 'testocc0', tracConstants.FREQUENCY_MONTHLY, 2, tracDateUtils.FRIDAY, tracDateUtils.THIRD);
//         insert  occ0;

//     }
//     @IsTest
//     static void testBehavior() {
//         Test.startTest();
//         tracRecurringGenerationBatch b = new tracRecurringGenerationBatch();
//         Id batchId = Database.executeBatch(b);

// //        Timeline__c tl = [SELECT Id FROM Timeline__c];
// //        tl.Start_Date__c = Date.newInstance(2020,3,23);
// //        update tl;
// //
// //        Occurrence__c occ = [SELECT Id FROM Occurrence__c];
// //        occ.Day__c = tracDateUtils.THURSDAY;
// //        update occ;
// //
// //        b = new tracRecurringGenerationBatch();
// //        Id batchId1 = Database.executeBatch(b);
//         Test.stopTest();

//         List<WorkOrder> wos = [SELECT Id,EndDate,StartDate FROM WorkOrder];
//         List<ServiceAppointment> sas = [SELECT Id FROM ServiceAppointment];
//         System.debug(wos);
// //        System.assertEquals(6,sas.size());
//     }
}