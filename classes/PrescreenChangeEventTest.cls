@istest
public class PrescreenChangeEventTest {
        @TestSetup
    static void makeData() {
        TriggerFramework.mockMetaData = new List<TriggerHandler__mdt>();

        Account a = TestUtility.createAccount();
        insert a;
        User u = TestUtility.createUser();
        u.id__c = '123456';
        insert u;
        Contact c = TestUtility.createContact(a);
        insert c;
        Vehicle__c v = TestUtility.createVehicle();
        insert v;
        Condition_Report__c cr = TestUtility.createCr(v);
        insert cr;
        Condition_Report_Prescreen__c crp = TestUtility.createPrescreen(cr,a,c);
        crp.Inspection_Id__c = '123456789';
        crp.vehicle__c = v.id;
        crp.OwnerId = u.id;
        insert crp;
        // Prescreen_Reason__c pr = new Prescreen_Reason__c(Name = 'Virtual Lift', Condition_Report_Prescreen__c = crp.id);
        // insert pr;
        CR_Question__c cq = new CR_Question__c(Condition_Report_Prescreen__c = crp.id, Question_Notes_Photos__c = 'TEST NOTES 1', Question_Type__c = 'Mechanicals');
        insert cq;
        CR_Question__c cq1 = new CR_Question__c(Condition_Report_Prescreen__c = crp.id, Question_Notes_Photos__c = 'TEST NOTES 2', Question_Type__c = 'Exterior');
        insert cq1;
        List<Integration_Result__c> ircIdList = new List<Integration_Result__c>();
        for(Integration_Result__c irc : [Select id, Status_Code__c, Request_Message__c From Integration_Result__c]){
            ircIdList.add(irc);
        }
        System.debug(ircIdList);
        delete ircIdList;


    }
    @istest
    static void PrescreenApprovedEventTest()  {
        //Update Active flag
        Condition_Report_Prescreen__c crp = [SELECT Id, Status__c FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c = '123456789'];

        List<Condition_Report_Prescreen__c> prescreenList = [SELECT Id, Status__c FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c = '123456789'];
        PrescreenChangeEvent.prescreenEvent(prescreenList, prescreenChangeEvent.subStatus.approved_with_changes, prescreenChangeEvent.EventType.prescreen_approved);

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c where recordId__c=:crp.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'organization-activated'
        System.assert(integrationTest.Request_Message__c.contains('prescreen-approved'), 'Firing prescreenApprovedEvent class does not generate platform event');
        delete integrationTest;

    }
    @istest
    static void PrescreenRejectedEventTest()  {
        //Update Active flag
        Condition_Report_Prescreen__c crp = [SELECT Id, Status__c FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c = '123456789'];

        List<Condition_Report_Prescreen__c> prescreenList = [SELECT Id, Status__c FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c = '123456789'];
        PrescreenChangeEvent.prescreenEvent(prescreenList, prescreenChangeEvent.subStatus.rejected_with_feedback, prescreenChangeEvent.EventType.prescreen_rejected);
        // System.debug([SELECT Id, id__c FROM User WHERE id__c = '123456']);
        // System.debug([SELECT Id, Status__c, ownerid FROM Condition_Report_Prescreen__c WHERE Inspection_Id__c = '123456789']);

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c where recordId__c=:crp.id];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'organization-activated'
        System.assert(integrationTest.Request_Message__c.contains('prescreen-rejected'), 'Firing prescreenRejectedEvent class does not generate platform event');
        System.assert(integrationTest.Request_Message__c.contains('TEST NOTES 1^#TEST NOTES 2'), 'Firing prescreenAutoApproveEvent class does not generate platform event with joined list of CR questions');
        System.assert(integrationTest.Request_Message__c.contains('Prescreener_Id__c=123456'), 'Firing prescreenAutoApproveEvent class does not generate platform event with OwnerId populated');
        delete integrationTest;

    }
    @istest
    static void PrescreenAutoApprovedEventTest()  {
        //Update Active flag
        List<InspectionDefinition> idefList = new List<InspectionDefinition>{PrescreenServiceInspectionReviewTest.defaultIDef()};

        PrescreenChangeEvent.prescreenAutoApproveEvent(idefList);

        Integration_Result__c integrationTest= [Select id, Status_Code__c, Request_Message__c, Status_Message__c From Integration_Result__c where recordId__c=:idefList[0].InspectionId];
        System.debug(integrationTest);
        
        System.assertEquals(200, integrationTest.Status_Code__c);
        //Confirm Event type is 'organization-activated'
        System.assert(integrationTest.Request_Message__c.contains('prescreen-approved'), 'Firing prescreenAutoApproveEvent class does not generate platform event');
        System.assert(integrationTest.Request_Message__c.contains('Auto-Approved'), 'Firing prescreenAutoApproveEvent class does not generate platform event with auto-approve substatus');
        delete integrationTest;

    }
}