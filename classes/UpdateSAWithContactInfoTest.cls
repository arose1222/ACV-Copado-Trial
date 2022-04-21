@isTest
public class UpdateSAWithContactInfoTest {

    static String dealerEmail = 'dealerbros@gmail.com.test';
    static String directions = 'Drive forward and make 4 righthand turns at the corner';
    static String name = 'Johnny Smith';
    static String phone = '1234567890';
    static String email = 'johnnysmith@gmail.com.test';
    static String externalAssignmentId = 'April262021TEST';
    static String externalLink = 'externalLink';
    static String externalLinkCode = 'externalLinkCode';
    static String description = 'description';
    static String dealerName = 'dealer name';

    @TestSetup
    static void makeData(){
        Account a = TestUtility.createAccount();
        insert a;
        FSLTestUtility.createData( a, 1 );
    }

    @IsTest
    static void insertNewLineItem(){
        WorkOrderLineItem existingWOLI = [ SELECT Id, WorkTypeId, WorkOrderId FROM WorkOrderLineItem LIMIT 1 ];

        Test.startTest();
            WorkOrderLineItem testNewWOLI = new WorkOrderLineItem(
                WorkTypeId = existingWOLI.WorkTypeId,
                WorkOrderId = existingWOLI.WorkOrderId
            );
            testNewWOLI = updateWithContactInfo( testNewWOLI );
            insert testNewWOLI;
        Test.stopTest();

        assertResults();
    }

    @IsTest
    static void updateLineItem(){
        WorkOrderLineItem existingWOLI = [ SELECT Id, WorkTypeId, WorkOrderId FROM WorkOrderLineItem LIMIT 1 ];

        Test.startTest();
            existingWOLI = updateWithContactInfo( existingWOLI );
            update existingWOLI;
        Test.stopTest();

        assertResults();
    }

    private static void assertResults() {
        ServiceAppointment sa = [ SELECT Id, Customer_Email__c, Driving_Directions__c, Contact_Name__c,
                                    Contact_Phone_Number__c, Contact_Mobile_Number__c, Contact_Email__c,
                                    External_Assignment_Id__c, External_Link__c, External_Link_Code__c, 
                                    Inspection_Notes__c, Dealership_Name__c
                                    FROM ServiceAppointment LIMIT 1 ];

        System.assertEquals( dealerEmail, sa.Customer_Email__c, 'Unexpected Email Set' );
        System.assertEquals( directions, sa.Driving_Directions__c, 'Unexpected Email Set' );
        System.assertEquals( name, sa.Contact_Name__c, 'Unexpected Email Set' );
        System.assertEquals( phone, sa.Contact_Phone_Number__c, 'Unexpected Email Set' );
        System.assertEquals( phone, sa.Contact_Mobile_Number__c, 'Unexpected Email Set' );
        System.assertEquals( email, sa.Contact_Email__c, 'Unexpected Email Set' );
        System.assertEquals( externalAssignmentId, sa.External_Assignment_Id__c, 'Unexpected External Assignment ID' );
        System.assertEquals( externalLink, sa.External_Link__c, 'Unexpected External Link' );
        System.assertEquals( externalLinkCode, sa.External_Link_Code__c, 'Unexpected External Link Code' );
        System.assertEquals( description, sa.Inspection_Notes__c, 'Unexpected Description' );
        System.assertEquals( dealerName, sa.Dealership_Name__c, 'Unexpected Dealership Name' );
    }

    private static WorkOrderLineItem updateWithContactInfo( WorkOrderLineItem providedWOLI ) {
        providedWOLI.Customer_Email__c = dealerEmail;
        providedWOLI.Driving_Directions__c = directions;
        providedWOLI.Contact_Name__c = name;
        providedWOLI.Contact_Phone_Number__c = phone;
        providedWOLI.Contact_Mobile_Number__c = phone;
        providedWOLI.Contact_Email__c = email;
        providedWOLI.External_Assignment_Id__c = externalAssignmentId;
        providedWOLI.External_Link__c = externalLink;
        providedWOLI.External_Link_Code__c = externalLinkCode;
        providedWOLI.Description = description;
        providedWOLI.Dealership_Name__c = dealerName;
        return providedWOLI;
    }
}