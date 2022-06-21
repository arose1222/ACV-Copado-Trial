@ isTest
public with sharing class AssignmentManagerOwnerSelectionTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();
        Account a = TestUtility.createAccount('test');
        insert a;
        FSLTestUtility.createAllStructureWithParentST( /*'Great Lakes',*/ 'Buffalo', '14209' );
        insert new workType(name='Remote Inspection', EstimatedDuration=10, Work_Type_Unique_ID__c = 'Remote Inspection' );
    }

    @isTest
    public static void assetVerficationOwnerAssignment(){
        List<Account> aList = [Select id from account];
        List<assignmentManagerCreateWorkLinesCont.jsonVin> newVinList = new List<assignmentManagerCreateWorkLinesCont.jsonVin>();
        assignmentManagerCreateWorkLinesCont.jsonVin inboundLine = new assignmentManagerCreateWorkLinesCont.jsonVin();
        inboundLine.color = 'Bleu';
        inboundLine.inspectiontype = 'verification';
        inboundLine.lotId = aList[0].id;
        inboundLine.vin = '123456789';
        inboundLine.make = 'Joop';
        inboundLine.model = 'Wrongler';
        inboundLine.uuid = '734789289432799054890';
        newVinList.add(inboundLine);
        assignmentManagerCreateWorkLinesCont.createWorkOrders(JSON.serialize(newVinList));
        WorkOrder wo = [SELECT Id, OwnerId FROM WorkOrder LIMIT 1];
        system.debug('WO: ' + wo);
        Map<Id, Asset_Verification_Owners__mdt> avoMap = new Map<Id, Asset_Verification_Owners__mdt>([SELECT User_Record_Id__c FROM Asset_Verification_Owners__mdt WHERE Active__c = true]);
        Boolean match = false;
        for(Asset_Verification_Owners__mdt avo : avoMap.values()){
            if(wo.OwnerId == avo.User_Record_Id__c){
                match = true;
            }
        }
        system.assert(match == true, 'The owner id for this Asset Verification work order is not correct.');
    }
}