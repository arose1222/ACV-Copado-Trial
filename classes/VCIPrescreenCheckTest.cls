@IsTest
public with sharing class VCIPrescreenCheckTest {
    
    private static string mockDataAdvancedLogic = '{"DeveloperName":"testCriteria","Active__c":true,"Inspection_Field__c":"dealershipId","Trigger_Value__c":"100","Value_Type__c":"Integer","Prescreen_Reason__c":"Test Reason"}';
    //metadata record


    @TestSetup
    static void makeData(){
        SalesforceGatewayUserCreateLogic.disableGatewayLogic();

        Account account = TestUtility.createAccount();        account.Dealership_Id__c = '2147479405';
        insert account;

        List<Contact> cList = new List<Contact>();

        Contact contact = TestUtility.createContact(account);
        contact.Identity_Id__c = '40dc053e-d826-4b28-b911-759e5c145760';
        contact.CR_Review__c = false;
        cList.add(contact);

        Contact reviewContact = TestUtility.createContact(account);
        contact.Identity_Id__c = '40dc053e-d826-4b28-b911-759e5c145761';
        contact.CR_Review__c = true;
        contact.Prescreen_Type__c = 'New';
        cList.add(reviewContact);

        insert cList;
    }


    @isTest
    public static void prescreenReasonTest(){
        CR_Review_Trigger__mdt crt = (CR_Review_Trigger__mdt)JSON.deserializeStrict(mockDataAdvancedLogic, CR_Review_Trigger__mdt.class);
        //construct 2 wrappers
        InspectionDefinition idef1 = PrescreenServiceInspectionReviewTest.defaultIDef();
        idef1.inspectorIdentityId = '40dc053e-d826-4b28-b911-759e5c145760';
        PrescreenServiceHelper.InspectionWrapper wrapper1 = new PrescreenServiceHelper.InspectionWrapper(idef1, new Set<String>());

        InspectionDefinition idef2 = PrescreenServiceInspectionReviewTest.defaultIDef();
        idef2.inspectorIdentityId = '40dc053e-d826-4b28-b911-759e5c145761';
        PrescreenServiceHelper.InspectionWrapper wrapper2 = new PrescreenServiceHelper.InspectionWrapper(idef2, new Set<String>());

        Map<String, PrescreenServiceHelper.InspectionWrapper> testMap = new Map<String, PrescreenServiceHelper.InspectionWrapper>();
        testMap.put('a', wrapper1);
        testMap.put('b', wrapper2);
        //call method

        VciPrescreenCheck check = new VciPrescreenCheck();
        Map<String, PrescreenServiceHelper.InspectionWrapper> testResultList = check.handle(testMap, crt);

        //check for reason
        Integer count = 0;
        for(PrescreenServiceHelper.InspectionWrapper wrapper : testResultList.values()){
            if(wrapper.prescreenReasons.size() > 0){
                count++;
            }
        }
        
        system.assert(count == 1);
    }

    



}