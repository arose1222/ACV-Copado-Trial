@isTest
public class AssignmentManagerVehicleUpdateTest {

    // @TestSetup
    // static void makeData(){
    //     List<Account> accountList = New List<Account>();
    //     Account acct = TestUtility.createAccount('seller');
    //     acct.IST_Account_Owner__c =UserInfo.getUserId();
    //     accountList.add(acct);
    //     insert accountList;

    //     List<Vehicle__c> vLst = new List<Vehicle__c>();
    //     vehicle__c newCar = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1234567890102030');
    //     vLst.add( newCar );
    //     vehicle__c newCar2 = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '0302010987654321');
    //     vLst.add( newCar2 );
    //     vehicle__c newCar3 = new vehicle__c(year__c='2009',make__c='test make', model__c='test model', vin__c = '1c4rdjdg7fc101441');
    //     vLst.add( newCar3 );
    //     insert vLst;

    //     FSLTestUtility.createAllStructureWithParentST( 'Buffalo' , '14209' );
    //     WorkType siwt =[ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection' LIMIT 1 ];
    //     WorkType avwt =[ SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'verification' LIMIT 1 ];

    //     List<WorkOrder> woLst = new List<WorkOrder>();

    //     WorkOrder wo = new WorkOrder(AccountId = accountList[0].id,status='New', WorkTypeId = siwt.id);
    //     woLst.add( wo );
    //     WorkOrder wo1 = new WorkOrder(AccountId = accountList[0].id,status='New', WorkTypeId = siwt.id);
    //     woLst.add( wo1 );
    //     WorkOrder avwo = new WorkOrder(AccountId = accountList[0].id, status = 'New', WorkTypeId = avwt.id);
    //     woLst.add( avwo );
    //     insert woLst;

    //     List<WorkOrderLineItem> woliLst = new List<WorkOrderLineItem>();

    //     WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId = wo.id, vin__c = '1234567890102030', Status='New', WorkTypeId = siwt.id);
    //     woliLst.add( woli );
    //     WorkOrderLineItem woli1 = new WorkOrderLineItem(WorkOrderId = wo.id, vin__c = '1C4RDJDG7FC101441', Status='New', WorkTypeId = siwt.id);
    //     woliLst.add( woli1 );
    //     WorkOrderLineItem avwoli = new WorkOrderLineItem(WorkOrderId = avwo.id, vin__c = '0302010987654321', Status='New', WorkTypeId = avwt.id);
    //     woliLst.add( avwoli );
    //     insert woliLst;

    // }

    // @IsTest
    // static void updateVehicleStatusLowerCaseVins(){
    //     Condition_Report__c cr = new Condition_Report__c(VIN__c = '1c4rdjdg7fc101441');
    //     test.startTest();
    //     insert cr;
    //     test.stopTest();

    //     List<WorkOrderLineItem> carList = [SELECT id, Status from WorkOrderLineItem WHERE vin__c = '1C4RDJDG7FC101441'];
    //     System.debug(carList[0].Status);
    //     system.assert(carList[0].Status == 'In Progress', 'The Vehicle Status is not Marked as Complete');

    // }

    // @IsTest
    // static void updateVehicleStatus(){
    //     Condition_Report__c cr = new Condition_Report__c(VIN__c = '1234567890102030');
    //     test.startTest();
    //     insert cr;
    //     test.stopTest();

    //     List<WorkOrderLineItem> carList = [select id, Status from WorkOrderLineItem WHERE vin__c = '1234567890102030'];
    //     system.assert(carList[0].Status == 'In Progress', 'The Vehicle Status is not Marked as Complete');

    // }

    // @IsTest
    // static void updateVehicleStatus2(){
    //     Condition_Report__c cr = new Condition_Report__c(VIN__c = '1234567890102030',CR_Doc_Complete__c = false);
    //     insert cr;
    //     test.startTest();
    //         cr.CR_Doc_Complete__c = true;
    //         update cr;
    //         cr.CR_in_Review__c = true;
    //         update cr;
    //         cr.Awaiting_Floor_Price__c = true;
    //         update cr;
    //         cr.Floor_Price__c = 50;
    //         update cr;
    //     test.stopTest();

    //     List<WorkOrderLineItem> carList = [select id, Status from WorkOrderLineItem WHERE vin__c = '1234567890102030'];
    //     System.debug(carList);
    //     System.debug(carList[0].Status);
    //     system.assert(carList[0].Status == 'Ready To Launch', 'The Vehicle Status is not Marked as Ready To Launch');

    // }

    // @IsTest
    // static void updateVehicleStatus3(){
    //     Condition_Report__c cr = new Condition_Report__c(VIN__c = '1234567890102030',CR_Doc_Complete__c = false);
    //     insert cr;
    //     test.startTest();
    //     cr.CR_Doc_Complete__c = true;
    //     update cr;
    //     cr.CR_in_Review__c = true;
    //     update cr;
    //     cr.Awaiting_Floor_Price__c = true;
    //     update cr;
    //     cr.Floor_Price__c = 50;
    //     update cr;
    //     //test.stopTest();

    //     List<Vehicle__c> v = [select id from Vehicle__c where Vin__c = '1234567890102030'];

    //     Auction__c a = new Auction__c(Vin__c = '1234567890102030');
    //     insert a;

    //     List<WorkOrderLineItem> carList = [select id, Status from WorkOrderLineItem WHERE vin__c = '1234567890102030'];
    //     system.assert(carList[0].Status == 'Launched', 'The Vehicle Status is not Marked as Launched');

    // }

    // @IsTest
    // static void preventAssetVerificationWorkType(){
    //     Condition_Report__c cr = new Condition_Report__c(VIN__c = '0302010987654321');
    //     Condition_Report__c cr2 = new Condition_Report__c(VIN__c = '1234567890102030');
    //     List<Condition_Report__c> crList = new List<Condition_Report__c>();
    //     crList.add(cr);
    //     crList.add(cr2);
    //     test.startTest();
    //     insert crList;
    //     test.stopTest();

    //     List<WorkOrderLineItem> carList = [select id, Status from WorkOrderLineItem where VIN__c = '1234567890102030'];
    //     List<WorkOrderLineItem> carList2 = [select id, Status from WorkOrderLineItem where VIN__c = '0302010987654321'];
    //     system.debug(carList);
    //     system.debug(carList2);
    //     system.assert(carList[0].Status == 'In Progress' && carList2[0].Status == 'New', 'The vehicle was not filtered');
    // }

    // @IsTest
    // static void preventAssetVerificationWorkType2(){
    //     Condition_Report__c cr = new Condition_Report__c(VIN__c = '0302010987654321',CR_Doc_Complete__c = false);
    //     Condition_Report__c cr2 = new Condition_Report__c(VIN__c = '1234567890102030', CR_Doc_Complete__c = false);
    //     List<Condition_Report__c> crList = new List<Condition_Report__c>();
    //     crList.add(cr);
    //     crList.add(cr2);

    //     insert crList;
    //     test.startTest();

    //     for(Condition_Report__c conRep : crList){
    //         conRep.CR_Doc_Complete__c = true;
    //     }
    //     update crList;

    //     for(Condition_Report__c conRep : crList){
    //         conRep.CR_in_Review__c = true;
    //     }
    //     update crList;

    //     for(Condition_Report__c conRep : crList){
    //         conRep.Awaiting_Floor_Price__c = true;
    //     }
    //     update crList;

    //     for(Condition_Report__c conRep : crList){
    //         conRep.Floor_Price__c = 50;
    //     }
    //     update crList;

    //     List<WorkOrderLineItem> carList = [select id, Status from WorkOrderLineItem where VIN__c = '1234567890102030'];
    //     system.debug(carList[0].Status);
    //     List<WorkOrderLineItem> carList2 = [select id, Status from WorkOrderLineItem where VIN__c = '0302010987654321'];
    //     system.debug(carList2[0].Status);
    //     system.assert(carList[0].Status == 'Ready To Launch' && carList2[0].Status == 'New', 'The vehicle was not filtered');

    //     test.stopTest();
    // }

    // @IsTest
    // static void preventAssetVerificationWorkType3(){
    //     Test.startTest();
    //         Condition_Report__c cr = new Condition_Report__c(VIN__c = '0302010987654321',CR_Doc_Complete__c = false);
    //         Condition_Report__c cr2 = new Condition_Report__c(VIN__c = '1234567890102030', CR_Doc_Complete__c = false);
    //         List<Condition_Report__c> crList = new List<Condition_Report__c>();
    //         crList.add(cr);
    //         crList.add(cr2);


    //         insert crList;
    //         for(Condition_Report__c conRep : crList){
    //             conRep.CR_Doc_Complete__c = true;
    //         }
    //         update crList;

    //         for(Condition_Report__c conRep : crList){
    //             conRep.CR_in_Review__c = true;
    //         }
    //         update crList;

    //         for(Condition_Report__c conRep : crList){
    //             conRep.Awaiting_Floor_Price__c = true;
    //         }
    //         update crList;

    //         for(Condition_Report__c conRep : crList){
    //             conRep.Floor_Price__c = 50;
    //         }
    //         update crList;

    //         Auction__c a = new Auction__c(Vin__c = '0302010987654321');
    //         Auction__c a2 = new Auction__c(Vin__c = '1234567890102030');
    //         List<Auction__c> aList = new List<Auction__c>();
    //         aList.add(a);
    //         aList.add(a2);
    //         insert aList;

    //         List<WorkOrderLineItem> carList = [select id, Status from WorkOrderLineItem where VIN__c = '1234567890102030'];
    //         List<WorkOrderLineItem> carList2 = [select id, Status from WorkOrderLineItem where VIN__c = '0302010987654321'];

    //         system.debug(carList);
    //         system.debug(carList2);

    //         system.assert(carList[0].Status == 'Launched' && carList2[0].Status == 'New', 'The vehicle was not filtered');
    //     Test.stopTest();
    // }
}