@IsTest
public class InspectionRequestTest {
    @TestSetup
    static void createAccount() {

        Account a = TestUtility.createAccount();
        insert a;

        FSLTestUtility.createAllStructureWithParentST( 'Buffalo', '14209' );

    }

    @isTest
    static void createAppointmentInspectionRequest(){

        Id accId = [SELECT Id FROM Account LIMIT 1]?.Id;
        Integer numberOfVehicles = 10;
        Id standardInspectionWTID = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection']?.Id;

        Map<Id, Integer> vehicleCountMap = new Map<Id, Integer>{
            standardInspectionWTID  => numberOfVehicles
        };

        String timeSelection = 'ASAP';


        Test.startTest();
        InspectionRequest.createInspectionRequest(accId, vehicleCountMap, timeSelection);
        Test.stopTest();

        system.assert([SELECT Number_of_Standard_Inspection__c FROM Inspection_Request__c LIMIT 1]?.Number_of_Standard_Inspection__c == numberOfVehicles, 'Incorrect number of Standard Inspection Vehicles on Inspection Request');
    }

    @isTest
    static void createRevolvingAppointmentInspectionRequest(){

        Id accId = [SELECT Id FROM Account LIMIT 1]?.Id;
        Integer numberOfVehicles = 10;
        Id standardInspectionWTID = [SELECT Id FROM WorkType WHERE Work_Type_Unique_ID__c = 'inspection']?.Id;

        Test.startTest();
        InspectionRequest.createRevolvingInspectionRequest(accId, numberOfVehicles, standardInspectionWTID);
        Test.stopTest();

        system.assert([SELECT Number_of_Standard_Inspection__c FROM Inspection_Request__c LIMIT 1]?.Number_of_Standard_Inspection__c == numberOfVehicles, 'Incorrect number of Standard Inspection Vehicles on Inspection Request');
    }

}