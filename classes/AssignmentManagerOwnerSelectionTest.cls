/**
 * @author            : ACV Legacy
 * @group             : Scheduling
 * @last modified on  : 04-13-2022
 * @last modified by  : dilan.chaves@globant.com
**/
@ isTest
public with sharing class AssignmentManagerOwnerSelectionTest {
    @TestSetup
    static void makeData(){
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
        
        List<Asset_Verification_Owners__mdt> avoList = [SELECT User_Record_Id__c FROM Asset_Verification_Owners__mdt WHERE Active__c = TRUE];

        Id firstPersonId = avoList.get(0).User_Record_Id__c;

        System.assertEquals(firstPersonId, wo.OwnerId, 'The owner id for this Asset Verification work order is not correct.');
    }
}